"""Fine-tune YOLO11n-cls on the pest_animals_v1 animal crops (empty excluded: the detector handles presence)."""
import sys
from ultralytics import YOLO

DATA, EPOCHS = sys.argv[1], int(sys.argv[2])
model = YOLO('yolo11n-cls.pt')          # ImageNet-pretrained, 1.6M params
model.train(data=DATA, epochs=EPOCHS, imgsz=224, batch=64, device='cpu', workers=4,
            patience=5, seed=42, deterministic=True, project='runs', name='pest_cls_v1', exist_ok=True,
            plots=True)
