# Pest Terminator
> A solution to detect and alert farmers of pest infestation in farmlands.

Team Pink_Panthers-3
* Sai Donepudi - Team Lead
* Asmitha Dhamodharan - Team Member

Trello Board [Link](https://trello.com/b/RBRiEQpX/pinkpanthers-3)​

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
