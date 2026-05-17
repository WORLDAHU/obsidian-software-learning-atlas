param(
  [Parameter(Mandatory = $false)]
  [string]$VaultRoot,

  [Parameter(Mandatory = $true)]
  [string]$CanvasRelativePath,

  [Parameter(Mandatory = $false)]
  [string]$ImagesTargetRelativeDir = "02-知识图谱\SolidWorks\99-图片",

  [Parameter(Mandatory = $false)]
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"


function Write-Info([string]$Message) { Write-Host $Message }

function Ensure-Dir([string]$Path) {
  if ($DryRun) { return }
  if (!(Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function New-FileNameFromNote([string]$notePath, [string]$ext) {
  $stem = [System.IO.Path]::GetFileNameWithoutExtension($notePath)
  # 去掉前缀数字（例如 01-特征 -> 特征）
  $stem = $stem -replace '^[0-9]{2,3}-', ''
  return "$stem$ext"
}

function Normalize-RelPath([string]$p) {
  # 把 Windows/重复分隔符统一成 Obsidian canvas 可用的正斜杠相对路径
  $p = $p -replace '\\\\', '/'
  $p = $p -replace '/{2,}', '/'
  return $p
}

if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
  $VaultRoot = Split-Path -Parent (Resolve-Path -LiteralPath (Join-Path (Get-Location) ".")).Path
}

$canvasPath = Join-Path $VaultRoot $CanvasRelativePath
if (!(Test-Path -LiteralPath $canvasPath)) { throw "找不到 canvas：$canvasPath" }

$raw = Get-Content -LiteralPath $canvasPath -Raw -Encoding UTF8
$canvas = $raw | ConvertFrom-Json

$idMap = @{}
foreach ($n in $canvas.nodes) { $idMap[$n.id] = $n }

$targetDirAbs = Join-Path $VaultRoot $ImagesTargetRelativeDir
Ensure-Dir $targetDirAbs

$imageNodes = @(
  $canvas.nodes | Where-Object { $_.type -eq "file" -and $_.file -match '\.(png|jpg|jpeg|webp)$' }
)

foreach ($imgNode in $imageNodes) {
  $oldRel = $imgNode.file

  # 已经在子目录里的不处理
  if ($oldRel -match '[\\/]' ) { continue }

  $oldAbs = Join-Path $VaultRoot $oldRel
  if (!(Test-Path -LiteralPath $oldAbs)) { continue }

  $ext = [System.IO.Path]::GetExtension($oldRel)
  $newName = $oldRel

  # 如果这张图只和一个“笔记节点”相连，就按该笔记命名（例如 特征.png）
  $connectedEdges = @($canvas.edges | Where-Object { $_.fromNode -eq $imgNode.id -or $_.toNode -eq $imgNode.id })
  $connectedNodes = @()
  foreach ($e in $connectedEdges) {
    $otherId = if ($e.fromNode -eq $imgNode.id) { $e.toNode } else { $e.fromNode }
    if ($idMap.ContainsKey($otherId)) { $connectedNodes += $idMap[$otherId] }
  }
  $connectedNoteNodes = @(
    $connectedNodes | Where-Object { $_.type -eq "file" -and $_.file -like "02-知识图谱/SolidWorks/*" -and $_.file -match '\.md$' }
  )

  if ($connectedNoteNodes.Count -eq 1) {
    $newName = New-FileNameFromNote -notePath $connectedNoteNodes[0].file -ext $ext
  }

  $newAbs = Join-Path $targetDirAbs $newName
  $newRel = Normalize-RelPath (($ImagesTargetRelativeDir -replace '\\','/') + "/" + $newName)

  if ($DryRun) {
    Write-Info "MOVE : $oldRel -> $newRel"
  } else {
    if (!(Test-Path -LiteralPath $newAbs)) {
      Move-Item -LiteralPath $oldAbs -Destination $newAbs -Force
    } else {
      # 目标已存在时，保留现有文件，避免覆盖
      Remove-Item -LiteralPath $oldAbs -Force
    }
    $imgNode.file = $newRel
  }
}

if ($DryRun) {
  Write-Info "DONE : DryRun（未写入 canvas）"
  exit 0
}

($canvas | ConvertTo-Json -Depth 50) | Set-Content -LiteralPath $canvasPath -Encoding UTF8
Write-Info "DONE : 已整理图片并更新 canvas"


