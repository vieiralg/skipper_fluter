$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path "$PSScriptRoot\.."
$flutterWeb = Join-Path $projectRoot "build\web"

if (!(Test-Path -LiteralPath (Join-Path $flutterWeb "index.html"))) {
  Push-Location $projectRoot
  flutter build web --base-href /
  Pop-Location
}

Start-Process powershell -ArgumentList @(
  "-NoExit",
  "-Command",
  "Set-Location -LiteralPath '$flutterWeb'; python -m http.server 8080"
)

Start-Process powershell -ArgumentList @(
  "-NoExit",
  "-Command",
  "Set-Location -LiteralPath '$PSScriptRoot'; npm run dev"
)

"Abra http://localhost:5173/ no navegador. O jogo Flutter sera carregado pelo iframe em http://localhost:8080/."
