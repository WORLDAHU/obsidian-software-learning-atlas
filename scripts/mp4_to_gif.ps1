$ErrorActionPreference = "Stop"

param(
  [Parameter(Mandatory = $true)]
  [string]$InMp4,

  [Parameter(Mandatory = $true)]
  [string]$OutGif,

  [Parameter(Mandatory = $false)]
  [int]$Width = 960,

  [Parameter(Mandatory = $false)]
  [int]$Fps = 12,

  [Parameter(Mandatory = $false)]
  [int]$StartSeconds = 0,

  [Parameter(Mandatory = $false)]
  [int]$DurationSeconds = 0
)

function Resolve-Ffmpeg {
  $candidates = @(
    $env:FFMPEG_PATH,
    "C:\\Program Files\\SOLIDWORKS Corp\\SOLIDWORKS\\FloXpress\\bin\\ffmpeg.exe",
    "C:\\Program Files\\SOLIDWORKS Corp\\SOLIDWORKS Flow Simulation\\binCFW\\ffmpeg.exe",
    "C:\\Program Files\\ANSYS_Install\\ANSYS Inc\\v242\\tp\\ffmpeg\\20071211\\winx64\\ffmpeg.exe"
  ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

  foreach ($p in $candidates) {
    if (Test-Path -LiteralPath $p) { return $p }
  }

  throw "找不到 ffmpeg.exe。可以设置环境变量 FFMPEG_PATH 指向 ffmpeg.exe。"
}

if (!(Test-Path -LiteralPath $InMp4)) { throw "找不到输入视频：$InMp4" }

$ffmpeg = Resolve-Ffmpeg

$outDir = Split-Path -Parent $OutGif
if (!(Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$palette = Join-Path $outDir "_palette.bmp"

$ssArgs = @()
if ($StartSeconds -gt 0) { $ssArgs += @("-ss", "$StartSeconds") }
if ($DurationSeconds -gt 0) { $ssArgs += @("-t", "$DurationSeconds") }

& $ffmpeg -hide_banner -y @ssArgs -i $InMp4 `
  -vf ("fps={0},scale={1}:-1:flags=lanczos,palettegen" -f $Fps, $Width) `
  -frames:v 1 -f image2 -c:v bmp $palette | Out-Null

& $ffmpeg -hide_banner -y @ssArgs -i $InMp4 -i $palette `
  -lavfi ("fps={0},scale={1}:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" -f $Fps, $Width) `
  -loop 0 $OutGif | Out-Null

Remove-Item -LiteralPath $palette -Force -ErrorAction SilentlyContinue

"DONE: $OutGif"


