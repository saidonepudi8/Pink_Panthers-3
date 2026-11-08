# Pest Terminator
> A solution to detect and alert farmers of pest infestation in farmlands.

Team Pink_Panthers-3
* Sai Donepudi - Team Lead
* Asmitha Dhamodharan - Team Member

Trello Board [Link](https://trello.com/b/RBRiEQpX/pinkpanthers-3)​

## What the project is

Animals like wild pigs, rodents, rabbits and birds can do serious damage to
crops before a farmer notices. Pest Terminator helps farmers find and deal with
them early:

1. **Spot.** When an animal is seen in a field, the app creates a **pest alert**
   with the field, crop, time and photo.
2. **Identify.** On the **Investigate** screen the farmer presses **Predict Pest**.
   The photo goes to a trained AI model, which names the animal and says how
   sure it is.
3. **Act.** If it's a real threat, the farmer presses **Spray pesticide**, and
   the backend tells an Arduino to switch on the sprayer.

The app is written in plain language for farmers, not for technical users.

### How the pieces fit together

```
Flutter app  ──HTTP──▶  FastAPI backend  ──▶  AI model (pest_cls_v1.pt)
 (alerts,               (localhost:8000)  └─▶  Arduino over serial (COM3) ──▶ sprayer relay
  investigate,
  Firebase auth)
```

| Part | Folder | What it does |
|---|---|---|
| Mobile/web app | `pest_terminator/lib/` | Flutter + GetX UI: login, reports (alerts list), investigate screen |
| Backend API | `pest_terminator/backend/` | FastAPI server for model predictions and spray commands |
| AI model | `pest_terminator/assets/model/` | Trained pest classifier, training/evaluation scripts and test reports |
| Hardware | `pest_terminator/arduino/` | Arduino UNO code that switches the spray relay on serial commands |

## Firebase configuration

Create `pest_terminator/lib/.env` from `pest_terminator/lib/.env.example` and
fill it with the Firebase app settings for each platform. These are client
configuration values, not secrets: Flutter bundles the `.env` asset into the
application, so do not put service-account credentials or private keys there.
Restrict Firebase API keys in Google Cloud and secure Firebase data with
Authentication, Firestore Security Rules, and App Check as appropriate.

`lib/firebase_options.dart` reads the environment asset, and `main.dart` loads it before initializing Firebase. 

## How to run

From `pest_terminator/`, run:

```sh
flutter pub get
flutter run
```

### Run the backend

The backend uses [uv](https://docs.astral.sh/uv/) and Python 3.15. In a second
terminal, from `pest_terminator/backend/`:

```sh
uv sync
uv run fastapi run main.py
```

The API runs at `http://localhost:8000` (the Android emulator reaches it at
`http://10.0.2.2:8000`). To point the app somewhere else, use
`flutter run --dart-define=API_BASE_URL=http://<host>:8000`.

Restart the backend after changing Python code: `fastapi run` does not auto-reload.

| Endpoint | Method | Purpose |
|---|---|---|
| `/` | GET | Health check |
| `/api/predict` | POST | Upload an image (`file` form field) and get the predicted animal |
| `/api/spray` | GET | Send the spray signal to the Arduino on `COM3` |

## AI model connection (Sai Donepudi)

The **Predict Pest** button on the Investigate screen is connected to the
trained species classifier, so farmers get a real prediction instead of demo data.

### The model

- **`pest_cls_v1.pt`**: a YOLO11n-cls classifier (Ultralytics), fine-tuned on animal photos at 224 px.
- **11 classes:** beaver, bird, coyote, livestock, other wildlife, person, pet,
  rabbit, rodent, squirrel, wild pig.
- **Test results:** 81.0% top-1 accuracy and 0.813 macro F1 on 2,167 held-out
  images from camera locations it never saw in training. The full report is in
  `assets/model/reports/RESULTS.md`.

### How a prediction works

1. The farmer presses **Predict Pest** (or **Re-run Prediction**).
2. `AlertsController.runPrediction()` clears the old results and shows a loading spinner.
3. `AlertsRepository.classify()` loads the alert's photo and `PredictService`
   uploads it to `POST /api/predict`.
4. The backend (`backend/app/features/predict/classifier.py`) runs the model on
   the photo and returns the top 3 animals with their probabilities:

   ```json
   {
     "species": "beaver",
     "confidence": 0.9995452761650085,
     "top": [
       {"label": "beaver", "confidence": 0.9995452761650085},
       {"label": "other_wildlife", "confidence": 0.00029306209762580693},
       {"label": "rodent", "confidence": 8.418282232014462e-05}
     ]
   }
   ```

5. The app turns the result into plain language for farmers:

   | Row | Example |
   |---|---|
   | Animal spotted | Beaver |
   | How sure the app is | Very sure (99.95%) |
   | Risk to crops | High |
   | Could also be | *(only shown for animals with a 5% chance or more)* |

   A footer shows when the check ran and reminds the farmer that the app is
   right about 8 out of 10 times, so they should look at the photo before spraying.

### Design notes

- **Exact confidence:** the backend sends the model's raw probability. The app
  shows 2 decimals and cuts off extra digits instead of rounding, so 99.954%
  shows as 99.95%, never a misleading 100%.
- **Confidence vs. accuracy:** "How sure the app is" is the model's confidence
  for *this* photo. The 81% figure is how often the model is right overall.
  A very sure answer can still be wrong.
- **Fast first prediction:** the model starts loading in a background thread
  when the server starts (a cold load takes 10–30 s). After that, a prediction
  takes about 0.1 s on CPU.
- **Thread-safe loading:** the model is loaded only once, even if a request
  arrives while it is still loading.
- **Safe errors:** a non-image upload returns `400` instead of crashing, and
  Ultralytics is stopped from trying to `pip install` packages at runtime.
  The app shows farmer-friendly messages such as *"Couldn't reach the pest checker."*
- **Why `.pt` and not `.onnx`:** `onnxruntime` has no wheels for Python 3.15 yet,
  so the backend uses Ultralytics/PyTorch, the same setup as `evaluate.py`.

### Files

| File | Role |
|---|---|
| `backend/main.py` | `POST /api/predict` endpoint, background model warm-up, CORS for POST |
| `backend/app/features/predict/classifier.py` | Loads `pest_cls_v1.pt` and runs predictions |
| `lib/services/predict_service.dart` | Uploads the image and parses the response |
| `lib/features/reports/data/alerts_repository.dart` | Builds the farmer-friendly result rows |
| `lib/features/reports/controllers/alert_controller.dart` | Runs predictions, loading/error state, re-run timestamp |
| `lib/features/investigate/screens/investigate_screen.dart` | Results card, Predict / Re-run button, "Checked at" footer |

### Next steps

- Load alert photos from the camera / Firestore instead of bundled assets
  (only the first sample alert has a photo right now).
- Fill in the alert's species after a prediction.
- Test the model on real field-camera photos; it has only been tested on the dataset so far.
