from datetime import datetime,timedelta, timezone

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from sqlalchemy import select

from app.config import ACCESS_TOKEN_MINUTES, GOOGLE_CLIENT_ID, JWT_ALGORITHM, JWT_SECRET
from app.database import get_db
from app.models import User


router = APIRouter(prefix="/auth", tags=["Auth"])
bearer = HTTPBearer(auto_error=False)

class GoogleAuthRequest(BaseModel):
    id_token: str = Field(min_length=20, max_length=5000)
    
    
    
def user_to_dict(u: User) -> dict:
    return {
        "id": u.id,
        "email": u.email,
        "name": u.name,
        "picture_url": u.picture_url,
        "student_class": u.student_class,
    }
    

def create_access_token(user_id: int) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),
        "iat": now,
        "exp": now + timedelta(minutes=ACCESS_TOKEN_MINUTES),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def get_current_user(
    creds: HTTPAuthorizationCredentials | None  = Depends(bearer),
    db: Session = Depends(get_db),
) -> User:
    if creds is None:
        raise HTTPException(
            status_code=401,
            detail="Login required")
    try:
        data = jwt.decode(creds.credentials, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        user_id = int(data.get("sub"))
        
    except (jwt.PyJWTError, ValueError, KeyError):
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired token")
    user = db.get(User, user_id)
    if user is None or not user.is_active:
        raise HTTPException(
            status_code=401,
            detail="User not found or inactive")
       
    return user
        
@router.post("/google")
def google_login(body: GoogleAuthRequest, db: Session = Depends(get_db)):
    if not GOOGLE_CLIENT_ID or len(JWT_SECRET) < 32:
        raise HTTPException(status_code=503, detail="Login settings incomplete. Check backend/.env.")

    try:
        info = google_id_token.verify_oauth2_token(
            body.id_token, google_requests.Request(), GOOGLE_CLIENT_ID
        )
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid Google token")
    except Exception as e:
        print(f"Google verify error: {type(e).__name__}")
        raise HTTPException(status_code=503, detail="Could not reach Google. Try again.")

    if not info.get("email_verified"):
        raise HTTPException(status_code=401, detail="Google email is not verified")

    sub = info["sub"]
    email = info.get("email")
    name = (info.get("name") or "")[:60] or None
    picture = (info.get("picture") or "")[:500] or None

    user = db.scalars(select(User).where(User.google_sub == sub)).first()
    if user is None and email:
        user = db.scalars(select(User).where(User.email == email)).first()

    if user is None:
        user = User(google_sub=sub, email=email, name=name, picture_url=picture)
        db.add(user)
    else:
        user.google_sub = sub
        user.picture_url = picture or user.picture_url
        if not user.name:
            user.name = name

    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account disabled")

    db.commit()
    db.refresh(user)

    return {
        "access_token": create_access_token(user.id),
        "token_type": "bearer",
        "user": user_to_dict(user),
    }


@router.get("/me")
def me(user: User = Depends(get_current_user)):
    return user_to_dict(user)
        
        