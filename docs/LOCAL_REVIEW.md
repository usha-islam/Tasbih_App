# Local UI review — 2026-10-16

Changes are local and uncommitted.

## UI changes

- Dhikr Tasbih uses a full-width, top-aligned column inside consistent 20px horizontal padding.
- CounterSurface explicitly centers its circular child. Its outer diameter is 232 logical pixels, constrained by available width.
- A rounded, lightly bordered reading card centers the title, Arabic, transliteration, meaning, and existing source context.
- Long readings retain their Arabic font size inside a labelled scroll area.
- Redundant remaining-count and session-target labels were removed from Dhikr Tasbih. Personal target editing remains available.
- Undo/reset and sound/vibration controls precede the separate completion section. Completion space is measured from its actual wrapped contents using Visibility, not a fixed height.
- English uses bundled Lato regular, bold, italic, and bold italic. Arabic keeps bundled Noto Naskh Arabic.
- Bottom-navigation icons use dark green and target chips use soft green borders.
- Manual session persistence, confirmation dialogs, unique custom IDs, and ordered counter saves from the earlier local work are preserved.

## Executed validation

- flutter analyze: no issues.
- flutter test: all 56 tests passed.
- 30 screen-matrix tests: Android and iOS widget platform behavior × five viewport sizes × three text scales.
- Viewports: 320×568, 360×640, 390×844, 412×915, 844×390.
- Text scales: 1.0, 1.3, 2.0; simulated safe-area padding and keyboard insets.
- Flows: Tasbih, target bottom sheet and validation, reset confirmation, Daily Dhikr, prayer details, Ayatul Kursi counter, custom daily form, Dhikr List/search, custom library form, individual counter, deletion confirmation.
- Stress cases: long custom names, full Arabic verse, large counts, wrapped controls and keyboard-visible forms.
- 15 focused geometry tests verify the reading card and circle remain centered and stationary through target−1 → target → undo below → target → beyond → undo.
- Regression tests cover rapid saves, target changes, reset/cancel, reopen persistence, duplicate-name migration, independent deletion, queue failure recovery, milestone vibration requests, Next dhikr, and manual prayer-session isolation.
- Actual headless Chrome at 390×844: short reading, completion, undo, long Arabic and browser reload persistence. The counter's accessible inner bounds stayed x=87, y=302, width=216, height=216 at counts 2, 3, 4 and undo to 3 (outer ring diameter 232).
- Actual Chrome screenshots also checked the long Arabic page at 320×568, 360×640, 412×915 and 844×390. The outer page and long reading have separate scroll regions.
- No browser page errors during the capture flow.

## Screenshots

Captured with clean temporary browser storage; before images show the local app immediately before this UI change.

| State | Before | After |
| --- | --- | --- |
| Short dhikr | [Before](screenshots/before-counter.png) | [After](screenshots/after-counter.png) |
| Completed | [Before](screenshots/before-completed.png) | [After](screenshots/after-completed.png) |

[Updated home](screenshots/after-home.png) · [Ayatul Kursi](screenshots/after-ayatul-kursi.png)

## Limits

Android/iOS layout behavior was simulated in Flutter widget tests on Windows.
No physical Android/iOS device or native emulator was available. Actual mobile
keyboard behavior, sound output, vibration hardware and native process-restart
persistence still need device checks. Vibration was tested through a recording
platform mock, not claimed as a hardware test.

SharedPreferences writes are serialized and errors are surfaced; this is not a
transactional database or a guarantee against OS termination during an in-flight
write. Legacy custom-name data is retained as a recovery backup. Older duplicate
names shared one progress record, so migration copies that record to each new
independent entry and displays an explanation.

Reading source qualifications are recorded in [CONTENT_SOURCES.md](CONTENT_SOURCES.md).
Font provenance and licenses are under [assets/fonts](../assets/fonts/README.md).

