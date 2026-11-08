"""Score the trained classifier on the held-out test split: per-class P/R/F1, per-source accuracy, latency."""
import json, sys, time
from collections import Counter, defaultdict
from pathlib import Path
from ultralytics import YOLO

WEIGHTS, TEST, OUT = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
model = YOLO(str(WEIGHTS))
names = model.names
files = sorted(TEST.glob('*/*.jpg'))
y_true, y_pred, conf, src = [], [], [], []
t0 = time.perf_counter()
for i in range(0, len(files), 64):
    batch = files[i:i + 64]
    for f, r in zip(batch, model.predict([str(p) for p in batch], imgsz=224, device='cpu', verbose=False)):
        y_true.append(f.parent.name); y_pred.append(names[r.probs.top1])
        conf.append(float(r.probs.top1conf)); src.append(f.name.split('__')[0])
elapsed = time.perf_counter() - t0

classes = sorted(set(y_true))
cm = {t: Counter() for t in classes}
for t, p in zip(y_true, y_pred):
    cm[t][p] += 1
rows = []
for c in classes:
    tp = cm[c][c]; fn = sum(cm[c].values()) - tp; fp = sum(cm[t][c] for t in classes if t != c)
    p = tp / (tp + fp) if tp + fp else 0.0; r = tp / (tp + fn) if tp + fn else 0.0
    rows.append({'class': c, 'support': tp + fn, 'precision': round(p, 3), 'recall': round(r, 3),
                 'f1': round(2 * p * r / (p + r), 3) if p + r else 0.0})
acc = sum(t == p for t, p in zip(y_true, y_pred)) / len(y_true)
per_src = defaultdict(lambda: [0, 0])
for t, p, s in zip(y_true, y_pred, src):
    per_src[s][0] += t == p; per_src[s][1] += 1
top_conf = Counter((t, p) for t, p in zip(y_true, y_pred) if t != p).most_common(10)
res = {
    'test_images': len(y_true), 'top1_accuracy': round(acc, 4),
    'macro_f1': round(sum(r['f1'] for r in rows) / len(rows), 4),
    'per_class': rows,
    'per_source_accuracy': {s: {'n': n, 'acc': round(k / n, 3)} for s, (k, n) in sorted(per_src.items())},
    'most_common_confusions': [{'true': t, 'pred': p, 'count': n} for (t, p), n in top_conf],
    'confusion_matrix': {t: dict(cm[t]) for t in classes},
    'cpu_ms_per_image_batch64': round(1000 * elapsed / len(y_true), 1),
}
OUT.write_text(json.dumps(res, indent=2))
print(json.dumps({k: res[k] for k in ('test_images', 'top1_accuracy', 'macro_f1', 'cpu_ms_per_image_batch64')}))
for r in rows: print(r)
print(res['per_source_accuracy']); print(res['most_common_confusions'])
