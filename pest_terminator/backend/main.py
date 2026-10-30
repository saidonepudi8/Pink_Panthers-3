from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?", 
    allow_methods=["GET"],
)

@app.get("/")
def main():
    return {"message": "Yooooo"}

@app.get("/api/spray")
def spray():
    return {"status": "200", "message": f"Sprayed pesticide."} # Temporary to test connection