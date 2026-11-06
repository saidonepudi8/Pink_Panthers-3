"""Species classifier: wraps the trained YOLO11n-cls model (pest_cls_v1.pt)."""
import io
import os
import threading
from pathlib import Path

from PIL import Image

# backend/app/features/predict/classifier.py -> pest_terminator/assets/model/pest_cls_v1.pt
MODEL_PATH = Path(__file__).resolve().parents[4] / "assets" / "model" / "pest_cls_v1.pt"
IMG_SIZE = 224  # Training image size (see assets/model/args.yaml)

# Stop ultralytics from pip-installing packages at runtime (it tries this for unknown image formats)
os.environ.setdefault("YOLO_AUTOINSTALL", "false")


class InvalidImageError(ValueError):
    """Raised when the uploaded bytes can't be decoded as an image."""


_model = None
_model_lock = threading.Lock()


def get_model():
    """Load the model once (thread-safe) and reuse it for every request."""
    global _model
    with _model_lock:
        if _model is None:
            from ultralytics import YOLO  # Imported lazily so the rest of the API starts fast

            if not MODEL_PATH.exists():
                raise FileNotFoundError(f"Model weights not found at {MODEL_PATH}")
            _model = YOLO(str(MODEL_PATH), task="classify")
        return _model


def classify(image_bytes: bytes, top_k: int = 3) -> dict:
    """Run the classifier on raw image bytes. Returns the top species and the next best guesses."""
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception as e:
        raise InvalidImageError("Uploaded file is not a valid image.") from e

    model = get_model()
    result = model.predict(image, imgsz=IMG_SIZE, device="cpu", verbose=False)[0]
    probs = result.probs

    top = [
        {"label": model.names[i], "confidence": float(probs.data[i])}  # Raw softmax probability, unrounded
        for i in probs.top5[:top_k]
    ]
    return {
        "species": top[0]["label"],
        "confidence": top[0]["confidence"],
        "top": top,
    }
