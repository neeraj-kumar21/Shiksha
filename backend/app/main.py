from fastapi import FastAPI

app = FastAPI(
    title="SHIKSHA API",
    description="Student Learning, Assessment & Career Guidance Platform",
    version="1.0.0"
)


@app.get("/")
def home():
    return {
        "message": "Welcome to SHIKSHA",
        "status": "API is running"
    }