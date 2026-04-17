param(
  [string]$EnvFile = '.env.dev',
  [string]$ComposeFile = 'compose.dev.yml',
  [string]$BaseUrl = 'http://localhost:81',
  [string]$ApiPath = '/api/v1/project/list',
  [switch]$Skip502,
  [switch]$Skip504
)

$ErrorActionPreference = 'Stop'

function Compose([string]$CommandArgs) {
  $cmd = "docker compose --env-file $EnvFile -f $ComposeFile $CommandArgs"
  Write-Host "> $cmd" -ForegroundColor Cyan
  Invoke-Expression $cmd
}

function HitApi([string]$Label, [int]$TimeoutSec = 130) {
  $url = "$BaseUrl$ApiPath"
  Write-Host "[$Label] GET $url (timeout=${TimeoutSec}s)" -ForegroundColor Yellow
  $code = & curl.exe -sS -o NUL -w "%{http_code}" --max-time $TimeoutSec $url
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[$Label] curl failed (exit=$LASTEXITCODE)" -ForegroundColor Red
    return "CURL_FAIL"
  }
  Write-Host "[$Label] HTTP $code" -ForegroundColor Green
  return $code
}

function GetBackContainerId() {
  $id = Compose 'ps -q kit3d-back'
  return ($id | Select-Object -Last 1).Trim()
}

Write-Host "=== Nginx config check ===" -ForegroundColor Magenta
Compose 'exec -T kit3d-proxy nginx -t'

Write-Host "=== Baseline ===" -ForegroundColor Magenta
$baseline = HitApi 'Baseline' 30

if (-not $Skip502) {
  Write-Host "=== Test 502: stop back ===" -ForegroundColor Magenta
  Compose 'stop kit3d-back'
  Start-Sleep -Seconds 2
  $code502 = HitApi 'Expect-502' 20
  if ($code502 -ne '502') {
    Write-Host "[WARN] expected 502, got $code502" -ForegroundColor Red
  }
  Compose 'start kit3d-back'
  Start-Sleep -Seconds 5
  [void](HitApi 'After-back-start' 30)
}

if (-not $Skip504) {
  Write-Host "=== Test 504: pause back ===" -ForegroundColor Magenta
  $backId = GetBackContainerId
  if ([string]::IsNullOrWhiteSpace($backId)) {
    throw 'kit3d-back container id not found'
  }

  Write-Host "> docker pause $backId" -ForegroundColor Cyan
  docker pause $backId | Out-Null

  try {
    # /api/ default read timeout is 120s in current conf
    $code504 = HitApi 'Expect-504' 130
    if ($code504 -ne '504') {
      Write-Host "[WARN] expected 504, got $code504" -ForegroundColor Red
    }
  }
  finally {
    Write-Host "> docker unpause $backId" -ForegroundColor Cyan
    docker unpause $backId | Out-Null
    Start-Sleep -Seconds 3
    [void](HitApi 'After-back-unpause' 30)
  }
}

Write-Host "=== Proxy log tail (latest 80 lines) ===" -ForegroundColor Magenta
Compose 'logs --tail 80 kit3d-proxy'

Write-Host "=== Done ===" -ForegroundColor Magenta
