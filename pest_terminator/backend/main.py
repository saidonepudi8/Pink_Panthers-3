# Start FastAPI backend with ``fastapi run main.py`` command. Ensure terminal is inside backend folder.
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import serial, time

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?", 
    allow_methods=["GET"],
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