
import os
import itertools
import threading

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from google import genai


# Load environment variables from backend/.env
load_dotenv(
       os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"),
       override=True,
)

# Initialize FastAPI application
app = FastAPI(
    title="SHIKSHA API",
    description="Student Learning, Assessment & Career Guidance Platform",
    version="1.0.0",
)


# Define request model
class AskRequest(BaseModel):
    question: str = Field(min_length=1, max_length=2000)


# Initialize Gemini client if an API key is available

# Load multiple Gemini API keys (comma separated) from backend/.env
keys = [k.strip() for k in os.getenv("GEMINI_API_KEYS", "").split(",") if k.strip()]
clients = [genai.Client(api_key=k) for k in keys]

_counter = itertools.count()
_lock = threading.Lock()


# Configure the Gemini model through backend/.env
MODEL_NAME = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")

def generate_with_pool(prompt: str):
    with _lock:
        start = next(_counter)  # round-robin: har request ko agli key

    last_error = None
    for i in range(len(clients)):
        c = clients[(start + i) % len(clients)]
        try:
            return c.models.generate_content(model=MODEL_NAME, contents=prompt)
        except Exception as e:
            last_error = e
            if "429" in str(e) or "503" in str(e):
                continue  # agli key try karo
            raise  # 404/401 jaise error seedha upar

    raise last_error


# Root endpoint
@app.get("/")
def home():
    return {
        "message": "Welcome to SHIKSHA",
        "status": "API is running",
    }


# Health check endpoint
@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "SHIKSHA API",
        "version": "1.0.0",
        "ai_configured": len(clients) > 0,
    }


# AI tutor endpoint
@app.post("/ask")
def ask_question(request: AskRequest):
    if not clients:
        raise HTTPException(
            status_code=503,
            detail="Gemini API keys are not configured. Check backend/.env.",
        )

    try:
        prompt = (
            "You are a SHIKSHA, a helpful and supportive AI tutor for "
            "Students. in class 9 to 12 . Explain concepts clearly,"
            "Use simple language, and show steps for academic questions. \n \n"
            f"Student's question: {request.question}"
        )

        answer = response.text

        if not answer:
            raise HTTPException(
                status_code=502,
                detail="Gemini returned an empty response.",
            )

        return {
            "question": request.question,
            "answer": answer,
            "ai_connected": True,
        }

    except HTTPException:
        raise

    except Exception as e:
       print(f"Gemini API error: {type(e).__name__}: {e}")

       raise HTTPException(
            status_code=502,
            detail=(
                f"Gemini request failed: {type(e).__name__}. "
                "Check the backend terminal for details."
            ),
        )

