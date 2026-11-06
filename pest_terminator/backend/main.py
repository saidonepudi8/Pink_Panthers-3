# Start FastAPI backend with ``fastapi run main.py`` command. Ensure terminal is inside backend folder.
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import serial, threading, time

from app.features.predict.classifier import InvalidImageError, classify, get_model

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load the pest classifier in the background so the first prediction is fast
    # without blocking server startup (cold load can take ~30s).
    threading.Thread(target=get_model, daemon=True).start()
    yield

app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?", 
    allow_methods=["GET", "POST"],
)

@app.get("/")
def main():
    return {"message": "Yooooo"}

# Send bytes to Arduino through port
@app.get("/api/spray")
def spray():
    # Intialize serial comms
    arduino = serial.Serial(port='COM3', baudrate=9600, timeout=0.1)
    time.sleep(2)

    try:
        # Turn on LED for 1 second and turn off
        arduino.write(b'1')
        time.sleep(1)
        arduino.write(b'0')

    except Exception as e:
        return {"status": "500", "message": f"Error spraying pesticide: {e}"}
    finally:
        # Close serial comms
        arduino.close()

    # Send status message
    return {"status": "200", "message": f"Sprayed pesticide."}

# Classify the pest in an uploaded image with the trained model (assets/model/pest_cls_v1.pt).
# Sync def so FastAPI runs the CPU-bound inference in a worker thread.
@app.post("/api/predict")
def predict(file: UploadFile = File(...)):
    image_bytes = file.file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Empty image upload.")

    try:
        return classify(image_bytes)
    except InvalidImageError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")
