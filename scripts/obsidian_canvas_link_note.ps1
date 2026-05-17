param(
  [Parameter(Mandatory = $false)]
  [string]$VaultRoot = "C:\Users\claww\Data\Obsidian\知识图谱",

  [Parameter(Mandatory = $true)]
  [string]$CanvasRelativePath,

  [Parameter(Mandatory = $true)]
  [string]$FromImageFile,

  [Parameter(Mandatory = $true)]
  [string]$ToNoteFile,

  [Parameter(Mandatory = $false)]
  [int]$X = 580,

  [Parameter(Mandatory = $false)]
  [int]$Y = -760,

  [Parameter(Mandatory = $false)]
  [int]$Width = 400,

  [Parameter(Mandatory = $false)]
  [int]$Height = 400,

  [Parameter(Mandatory = $false)]
  [string]$Color = "1",

  [Parameter(Mandatory = $false)]
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function New-ShortId {
  ([guid]::NewGuid().Guid.Replace("-", "")).Substring(0, 16)
}

function Write-Info([string]$Message) {
  Write-Host $Message
}

$canvasPath = Join-Path $VaultRoot $CanvasRelativePath
if (!(Test-Path -LiteralPath $canvasPath)) {
  throw "找不到 canvas：$canvasPath"
}

Write-Info "LOAD : $canvasPath"
$raw = Get-Content -LiteralPath $canvasPath -Raw -Encoding UTF8
$canvas = $raw | ConvertFrom-Json

$noteNode = $canvas.nodes | Where-Object { $_.type -eq "file" -and $_.file -eq $ToNoteFile } | Select-Object -First 1
if (!$noteNode) {
  $noteNode = [pscustomobject]@{
    id     = (New-ShortId)
    type   = "file"
    file   = $ToNoteFile
    x      = $X
    y      = $Y
    width  = $Width
    height = $Height
    color  = $Color
  }
  $canvas.nodes += $noteNode
  Write-Info "ADD  : note node ($ToNoteFile)"
} else {
  Write-Info "HAVE : note node ($ToNoteFile)"
}

$imgNode = $canvas.nodes | Where-Object { $_.type -eq "file" -and $_.file -eq $FromImageFile } | Select-Object -First 1
if (!$imgNode) {
  throw "canvas 里没找到图片节点：$FromImageFile"
}

$edge = $canvas.edges | Where-Object { $_.fromNode -eq $imgNode.id -and $_.toNode -eq $noteNode.id } | Select-Object -First 1
if (!$edge) {
  $canvas.edges += [pscustomobject]@{
    id       = (New-ShortId)
    fromNode = $imgNode.id
    fromSide = "right"
    toNode   = $noteNode.id
    toSide   = "left"
  }
  Write-Info "ADD  : edge $($imgNode.id) -> $($noteNode.id)"
} else {
  Write-Info "HAVE : edge $($imgNode.id) -> $($noteNode.id)"
}

if ($DryRun) {
  Write-Info "DONE : DryRun（未写入 canvas）"
  exit 0
}

($canvas | ConvertTo-Json -Depth 50) | Set-Content -LiteralPath $canvasPath -Encoding UTF8
Write-Info "DONE : 已写入 canvas"


