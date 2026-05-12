# Quality checks for i18n + Flutter static analysis (run from repo root).
# Usage: powershell -ExecutionPolicy Bypass -File tools/ci_i18n.ps1
$ErrorActionPreference = "Stop"
python tools/check_arb_parity.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Push-Location app
flutter gen-l10n
flutter analyze
if ($LASTEXITCODE -ne 0) { Pop-Location; exit $LASTEXITCODE }
flutter test
Pop-Location
