# Namaz Alert

A Flutter app for prayer times, Qibla direction, Quran, Hadith, Tasbih, and daily good-deed reminders. Targets Android and iOS.

## Features

- **Prayer times** with a live countdown to the next prayer (AlAdhan API, location-based)
- **Qibla compass** using the device magnetometer + computed bearing to Mecca
- **Quran** reader with Arabic (Uthmani) text and English translation (Al Quran Cloud API)
- **Hadith of the day** rotating across major collections (open hadith-api)
- **Tasbih** digital dhikr counter with haptic feedback and cycling adhkar
- **Daily good deed** reminder
- **Light & dark themes**, switchable, with a calm teal/ivory/gold identity

## How this repo is structured

This repo contains the Flutter source only — `lib/`, `pubspec.yaml`, `assets/`, and the build workflow. The platform folders (`android/`, `ios/`) are **not** committed; the GitHub Actions workflow regenerates them with `flutter create` at build time, then injects the required permissions. This keeps the repo small and avoids platform-file version drift.

## Building the APK (no PC / Android Studio needed)

1. Create a new GitHub repository
2. Upload these files (use GitHub Desktop on a PC for reliable folder structure, or git)
3. Push to the `main` branch — the workflow in `.github/workflows/build.yml` runs automatically
4. Open the **Actions** tab → wait for the green check (~5-8 min)
5. Open the run → **Artifacts** → download `namaz-alert-debug-apk`
6. Extract the zip, copy `app-debug.apk` to your phone, install

## APIs used (all free, no key required)

- Prayer times & Qibla: `api.aladhan.com`
- Quran text & translations: `api.alquran.cloud`
- Hadith: `cdn.jsdelivr.net/gh/fawazahmed0/hadith-api`

## Permissions

- Internet — to fetch prayer times, Quran, and Hadith
- Location (fine/coarse) — for accurate prayer times and Qibla
- Notifications — for prayer alerts (notification scheduling is stubbed for a future update)
- Vibrate — for Tasbih haptics

## Notes / next steps

- Notification scheduling and adhan audio playback are scaffolded in dependencies but the scheduling logic is intentionally left as a follow-up (marked "Coming in a future update" in the More screen).
- Arabic text uses the Amiri font, loaded at runtime via the `google_fonts` package.
- Calculation method is currently fixed to Muslim World League; a picker is planned.
