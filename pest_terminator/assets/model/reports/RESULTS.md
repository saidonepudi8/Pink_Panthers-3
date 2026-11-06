# pest_cls_v1: species classifier, baseline results

Trained 2026-10-22. Status: **trained and tested on the held-out split of `pest_animals_v1`. Not yet tested on Pi camera images.**

## Setup

- **Model:** YOLO11n-cls (Ultralytics 8.4.183, PyTorch 2.14.1), 1.6M parameters, ImageNet-pretrained, fine-tuned.
- **Input:** animal or person **crops** from `pest_animals_v1/crops`, resized to 224 px. This is a stage-2 classifier: a detector (MegaDetector, or a Pi detector) finds the animal first, and this model names it.
- **Classes (11):** beaver, bird, coyote, livestock, other_wildlife, person, pet, rabbit, rodent, squirrel, wild_pig. The dataset's "empty" class is left out because presence is the detector's job.
- **Data:** 9,677 train / 2,121 val / 2,167 test. Splits are by camera location, so no test location was seen in training.
- **Training:** 20 epochs, batch 64, seed 42, deterministic, CPU only (4 cores, about 1 hour). The full config is in `args.yaml`, the script in `train.py`.

## Test-set results (2,167 images, never used in training or model selection)

| metric | value |
|---|---|
| top-1 accuracy | **81.0%** |
| macro F1 | **0.813** |

| class | test images | precision | recall | F1 |
|---|---|---|---|---|
| person | 225 | 0.978 | 0.991 | 0.985 |
| beaver | 112 | 0.934 | 0.884 | 0.908 |
| wild_pig | 209 | 0.867 | 0.904 | 0.885 |
| livestock | 219 | 0.880 | 0.804 | 0.840 |
| rodent | 187 | 0.778 | 0.861 | 0.817 |
| coyote | 214 | 0.796 | 0.804 | 0.800 |
| squirrel | 195 | 0.790 | 0.810 | 0.800 |
| bird | 182 | 0.773 | 0.786 | 0.779 |
| rabbit | 205 | 0.778 | 0.771 | 0.775 |
| pet | 211 | 0.756 | 0.645 | 0.696 |
| other_wildlife | 208 | 0.629 | 0.678 | 0.653 |

**Most common mistakes:**
- livestock → other_wildlife (19)
- coyote → other_wildlife (18)
- pet → other_wildlife (18)
- pet → coyote (15)
- other_wildlife → coyote (14)
- rabbit → rodent (14)

Most errors involve the catch-all "other_wildlife" class or dog vs coyote. Both make sense: dogs and coyotes look alike in night IR, and "other_wildlife" mixes many species.

**Accuracy by source:**

| source | test images | accuracy |
|---|---|---|
| Open Images | 225 | 99.1% |
| ENA24 | 317 | 90.2% |
| iNaturalist | 112 | 88.4% |
| NACTI | 519 | 85.5% |
| AMMonitor | 239 | 77.0% |
| CSA | 157 | 75.2% |
| Channel Islands | 93 | 74.2% |
| Missouri | 87 | 72.4% |
| OSU | 87 | 66.7% |
| Caltech | 331 | 64.0% |

Caltech is hardest: its night IR frames show small animals.

**Validation accuracy by epoch:**

| epoch | val accuracy |
|---|---|
| 1 | 60.7% |
| 10 | 75.0% |
| 20 | 78.5% |

Validation accuracy was still creeping up at epoch 20, so a longer run or a GPU would likely add a little.

## Speed

| setup | time per image |
|---|---|
| PyTorch, batch 64, this container's CPU | 13 ms |
| ONNX Runtime, batch 1, same CPU | 2.9 ms |

**Not measured on a Raspberry Pi yet.** Expect it to be several times slower there.

## Caveats (read before quoting these numbers)

- **Person scores are inflated.** All test "person" images are ordinary Open Images photos, which look very different from trail-camera frames. Person recall on real Pi footage is unknown and must be measured. It matters for the policy check.
- Beaver test images are iNaturalist phone photos. About 15% of beaver labels are noisy (see the dataset README).
- Test accuracy (81.0%) is a little above validation (78.5%), probably because of the mix of sources in each split. Treat the numbers as about ±3 points.
- This is one run with one seed.

## Files

| file | what it is |
|---|---|
| `pest_cls_v1.pt` | Ultralytics weights |
| `pest_cls_v1.onnx` | ONNX export for the Pi or for onnxruntime |
| `test_metrics.json` | all test metrics, including the full confusion matrix |
| `confusion_matrix_normalized.png` | confusion matrix (validation split, from Ultralytics) |
| `results.png` | training curves |
| `train.py` | training script |
| `evaluate.py` | test scoring script |

## Use

```python
from ultralytics import YOLO
model = YOLO('pest_cls_v1.pt')            # or 'pest_cls_v1.onnx'
r = model.predict('crop.jpg', imgsz=224)[0]
print(r.names[r.probs.top1], float(r.probs.top1conf))
```
