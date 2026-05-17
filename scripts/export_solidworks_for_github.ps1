param(
  [Parameter(Mandatory = $false)]
  [string]$VaultRoot = "C:\Users\claww\Data\Obsidian\知识图谱",

  [Parameter(Mandatory = $false)]
  [string]$OutDir = "C:\Users\claww\Documents\New project\examples\solidworks_vault",

  [Parameter(Mandatory = $false)]
  [switch]$Clean
)

$ErrorActionPreference = "Stop"


function Ensure-Dir([string]$Path) {
  if (!(Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Copy-Tree([string]$Src, [string]$Dst) {
  Ensure-Dir $Dst
  Copy-Item -Path (Join-Path $Src "*") -Destination $Dst -Recurse -Force
}

if ($Clean -and (Test-Path -LiteralPath $OutDir)) {
  Remove-Item -LiteralPath $OutDir -Recurse -Force
}
Ensure-Dir $OutDir

$srcSolidWorks = Join-Path $VaultRoot "02-知识图谱\SolidWorks"
$dstSolidWorks = Join-Path $OutDir  "02-知识图谱\SolidWorks"

if (!(Test-Path -LiteralPath $srcSolidWorks)) {
  throw "找不到 SolidWorks 目录：$srcSolidWorks"
}

Copy-Tree -Src $srcSolidWorks -Dst $dstSolidWorks

# 白板引用到的图片（从 canvas 里解析出来）
$canvasPath = Join-Path $srcSolidWorks "白板思维导图.canvas"
if (Test-Path -LiteralPath $canvasPath) {
  $raw = Get-Content -LiteralPath $canvasPath -Raw -Encoding UTF8
  $canvas = $raw | ConvertFrom-Json
  $imgFiles = $canvas.nodes |
    Where-Object { $_.type -eq "file" -and $_.file -match '\.(png|jpg|jpeg|webp)$' } |
    Select-Object -ExpandProperty file

  $imgFiles = $imgFiles | Sort-Object -Unique

  foreach ($img in $imgFiles) {
    # 这些图片通常在仓库根目录（VaultRoot）下
    $srcImg = Join-Path $VaultRoot $img
    if (Test-Path -LiteralPath $srcImg) {
      Copy-Item -LiteralPath $srcImg -Destination (Join-Path $OutDir $img) -Force
    }
  }
}

"DONE: $OutDir"




