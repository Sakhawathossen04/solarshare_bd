# SolarShare BD ☀️

**Smart Community Solar Trading and Settlement Network** — a Flutter app prototype
inspired by the PowerPeers (Netherlands) energy-sharing concept, rebuilt from scratch
for Bangladesh with ** Bangla + English ** support.

⚠️ **Prototype / demo notice:** all data is *simulated*. The app never bypasses a
utility meter and shows no real electricity trading. Real settlement requires
utility approval under Bangladesh regulations (Electricity Act / Net Metering).

## Features

| Screen | What it shows |
|---|---|
| **Onboarding** | 3 slides, Bangla/English switcher |
| **Login** | Demo login as Producer / Consumer / Admin |
| **Home** | Today's generation, self-use, export/import, earnings, meter status, hourly energy chart, 7-day AI solar forecast |
| **Market** | Eligible surplus listing (producer), nearby producers + buy + local match ratio (consumer), area demand |
| **Wallet** | Balance, **settlement calculator** (consumer ৳11/kWh, producer ৳9/kWh, other costs ৳1/kWh), payment history |
| **Insights** | PowerPeers-style hourly/daily/monthly usage & cost charts |
| **Admin** | Meter validation, area-wise statistics, system alerts, audit log |

## Settlement model (from the project doc)

```
Consumer collection = settled kWh × ৳11
Producer payment    = settled kWh × ৳9
Other costs         = settled kWh × ৳1
Remaining           = collection − payment − other   (NOT profit: utility costs,
                                                      taxes & losses still apply)
```

## Build

### Locally
```bash
flutter pub get
flutter run            # debug
flutter build apk      # release APK at build/app/outputs/flutter-apk/
```

### GitHub Actions (no local Flutter needed)
1. Create a GitHub repo and push this whole folder.
2. The included workflow `.github/workflows/build_apk.yml` runs on every push
   to `main`: installs Flutter, `flutter pub get`, `flutter analyze`,
   `flutter build apk --release`.
3. Download the APK from **Actions → latest run → Artifacts → solarshare-bd-apk**.

## Project structure

```
lib/
  core/          theme, l10n (bn/en), services (sim data, session, settlement)
  models/        meter reading, users, offers, trades, txns, alerts
  screens/       onboarding, auth, home, market, wallet, insights, admin, settings
  widgets/       shared UI components
assets/icons/    new SolarShare BD logo & launcher icons (generated)
android/         Gradle config (package com.solarshare.bd)
```

## Roadmap (from the doc)

1. ✅ App + simulated meter data prototype (this repo)
2. Backend: Python FastAPI + PostgreSQL (energy ledger, matching engine)
3. AI forecasting (scikit-learn) & grid simulation
4. Controlled hardware pilot with utility & qualified engineers
