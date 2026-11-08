"""Run the pest classifier on a folder of test images and print the results.

Usage (from pest_terminator/backend/):
    uv run python scripts/test_predictions.py                    # all images in ../assets
    uv run python scripts/test_predictions.py --images some/dir  # a different folder
    uv run python scripts/test_predictions.py --api http://localhost:8000   # go through the running server
    uv run python scripts/test_predictions.py --csv results.csv  # also save the table

By default the model runs in this process using the same code as POST /api/predict,
so the FastAPI server does not need to be running.
"""
import argparse
import csv
import sys
import time
from collections import Counter
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_DIR))  # So `app` can be imported when run as a script

IMAGE_TYPES = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
LOW_CONFIDENCE = 0.70  # Below this the app says "Not very sure" or "Unsure"


def predict_local(path: Path) -> dict:
    from app.features.predict.classifier import classify
    return classify(path.read_bytes())


def predict_api(path: Path, base_url: str) -> dict:
    import httpx  # Installed with fastapi[standard]

    with path.open("rb") as f:
        response = httpx.post(
            f"{base_url.rstrip('/')}/api/predict",
            files={"file": (path.name, f)},
            timeout=60,
        )
    response.raise_for_status()
    return response.json()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--images", type=Path, default=BACKEND_DIR.parent / "assets",
                        help="Folder of images to test (default: pest_terminator/assets)")
    parser.add_argument("--api", metavar="URL", help="Send images to a running server instead of loading the model here")
    parser.add_argument("--csv", type=Path, help="Also write the results to this CSV file")
    args = parser.parse_args()

    images = sorted(p for p in args.images.iterdir() if p.suffix.lower() in IMAGE_TYPES)
    if not images:
        print(f"No images found in {args.images}")
        return 1

    mode = f"API at {args.api}" if args.api else "local model"
    print(f"Testing {len(images)} images from {args.images} using the {mode}\n")

    rows, failures = [], []
    start = time.perf_counter()
    for path in images:
        try:
            result = predict_api(path, args.api) if args.api else predict_local(path)
        except Exception as e:
            failures.append((path.name, e))
            continue
        top = result["top"]
        rows.append({
            "image": path.name,
            "species": result["species"],
            "confidence": result["confidence"],
            "second": top[1]["label"] if len(top) > 1 else "",
            "second_confidence": top[1]["confidence"] if len(top) > 1 else 0.0,
        })
    elapsed = time.perf_counter() - start

    # Results table
    name_width = min(max(len(r["image"]) for r in rows), 60) if rows else 10
    print(f"{'Image':<{name_width}}  {'Prediction':<15} {'Conf.':>7}   {'Next best':<15} {'Conf.':>7}")
    print("-" * (name_width + 52))
    for r in rows:
        flag = "  <- low" if r["confidence"] < LOW_CONFIDENCE else ""
        name = r["image"] if len(r["image"]) <= name_width else r["image"][: name_width - 3] + "..."
        print(f"{name:<{name_width}}  {r['species']:<15} {r['confidence']:>7.2%}   "
              f"{r['second']:<15} {r['second_confidence']:>7.2%}{flag}")

    # Summary
    print(f"\n{len(rows)} predicted, {len(failures)} failed, {elapsed:.1f}s total")
    if rows:
        avg = sum(r["confidence"] for r in rows) / len(rows)
        low = sum(r["confidence"] < LOW_CONFIDENCE for r in rows)
        print(f"Average confidence: {avg:.2%}   Below {LOW_CONFIDENCE:.0%}: {low}")
        print("Predicted species: " + ", ".join(f"{s} ({n})" for s, n in Counter(r["species"] for r in rows).most_common()))
    for name, error in failures:
        print(f"FAILED {name}: {error}")

    if args.csv and rows:
        with args.csv.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(rows[0]))
            writer.writeheader()
            writer.writerows(rows)
        print(f"\nSaved results to {args.csv}")

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
