param(
  [Parameter(Mandatory = $false)]
  [string]$VaultRoot = "C:\Users\claww\Data\Obsidian\知识图谱",

  [Parameter(Mandatory = $false)]
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"


function Write-Info([string]$Message) {
  Write-Host $Message
}

function Ensure-Dir([string]$Path) {
  if ($DryRun) {
    Write-Info "DIR  : $Path"
    return
  }
  if (!(Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Write-TextFile([string]$Path, [string]$Content) {
  if ($DryRun) {
    Write-Info "WRITE: $Path"
    return
  }
  $dir = Split-Path -Parent $Path
  Ensure-Dir $dir
  Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
}

function New-ShortId {
  return ([guid]::NewGuid().Guid.Replace("-", "")).Substring(0, 16)
}

$surfaceDir = Join-Path $VaultRoot "02-知识图谱\SolidWorks\03-模块窗口\03-曲面"
$canvasPath = Join-Path $VaultRoot "02-知识图谱\SolidWorks\白板思维导图.canvas"

Ensure-Dir $surfaceDir

$files = @{}

$files[(Join-Path $surfaceDir "03-曲面.md")] = @(
  "# 03-曲面",
  "",
  "[[01-曲面生成]]",
  "[[02-曲面编辑]]",
  "[[03-面操作]]",
  "[[04-修剪与延伸]]",
  "[[05-缝合曲面]]",
  "[[06-曲面实体化]]",
  "",
  "## 相关",
  "[[04-参考几何体]]",
  "[[05-曲线]]"
) -join "`n"

$files[(Join-Path $surfaceDir "01-曲面生成.md")] = @(
  "# 01-曲面生成",
  "",
  "[[01-01-拉伸曲面]]",
  "[[01-02-旋转曲面]]",
  "[[01-03-扫描曲面]]",
  "[[01-04-放样曲面]]",
  "[[01-05-边界曲面]]",
  "[[01-06-填充曲面]]",
  "[[01-07-自由样式]]"
) -join "`n"

$files[(Join-Path $surfaceDir "01-01-拉伸曲面.md")] = "# 01-01 拉伸曲面"
$files[(Join-Path $surfaceDir "01-02-旋转曲面.md")] = "# 01-02 旋转曲面"
$files[(Join-Path $surfaceDir "01-03-扫描曲面.md")] = "# 01-03 扫描曲面"
$files[(Join-Path $surfaceDir "01-04-放样曲面.md")] = "# 01-04 放样曲面"
$files[(Join-Path $surfaceDir "01-05-边界曲面.md")] = "# 01-05 边界曲面"
$files[(Join-Path $surfaceDir "01-06-填充曲面.md")] = "# 01-06 填充曲面"
$files[(Join-Path $surfaceDir "01-07-自由样式.md")] = "# 01-07 自由样式"

$files[(Join-Path $surfaceDir "02-曲面编辑.md")] = @(
  "# 02-曲面编辑",
  "",
  "[[02-01-平面区域]]",
  "[[02-02-等距曲面]]",
  "[[02-03-曲面展平]]",
  "[[02-04-圆角]]",
  "[[02-05-直纹曲面]]"
) -join "`n"

$files[(Join-Path $surfaceDir "02-01-平面区域.md")] = "# 02-01 平面区域"
$files[(Join-Path $surfaceDir "02-02-等距曲面.md")] = "# 02-02 等距曲面"
$files[(Join-Path $surfaceDir "02-03-曲面展平.md")] = "# 02-03 曲面展平"
$files[(Join-Path $surfaceDir "02-04-圆角.md")] = "# 02-04 圆角"
$files[(Join-Path $surfaceDir "02-05-直纹曲面.md")] = "# 02-05 直纹曲面"

$files[(Join-Path $surfaceDir "03-面操作.md")] = @(
  "# 03-面操作",
  "",
  "[[03-01-删除面]]",
  "[[03-02-替换面]]",
  "[[03-03-删除孔]]"
) -join "`n"

$files[(Join-Path $surfaceDir "03-01-删除面.md")] = "# 03-01 删除面"
$files[(Join-Path $surfaceDir "03-02-替换面.md")] = "# 03-02 替换面"
$files[(Join-Path $surfaceDir "03-03-删除孔.md")] = "# 03-03 删除孔"

$files[(Join-Path $surfaceDir "04-修剪与延伸.md")] = @(
  "# 04-修剪与延伸",
  "",
  "[[04-01-延伸曲面]]",
  "[[04-02-剪裁曲面]]",
  "[[04-03-解除剪裁曲面]]"
) -join "`n"

$files[(Join-Path $surfaceDir "04-01-延伸曲面.md")] = "# 04-01 延伸曲面"
$files[(Join-Path $surfaceDir "04-02-剪裁曲面.md")] = "# 04-02 剪裁曲面"
$files[(Join-Path $surfaceDir "04-03-解除剪裁曲面.md")] = "# 04-03 解除剪裁曲面"

$files[(Join-Path $surfaceDir "05-缝合曲面.md")] = "# 05-缝合曲面"

$files[(Join-Path $surfaceDir "06-曲面实体化.md")] = @(
  "# 06-曲面实体化",
  "",
  "[[06-01-加厚]]",
  "[[06-02-加厚切除]]",
  "[[06-03-使用曲面切除]]"
) -join "`n"

$files[(Join-Path $surfaceDir "06-01-加厚.md")] = "# 06-01 加厚"
$files[(Join-Path $surfaceDir "06-02-加厚切除.md")] = "# 06-02 加厚切除"
$files[(Join-Path $surfaceDir "06-03-使用曲面切除.md")] = "# 06-03 使用曲面切除"

foreach ($kv in $files.GetEnumerator()) {
  Write-TextFile -Path $kv.Key -Content $kv.Value
}

if (!(Test-Path -LiteralPath $canvasPath)) {
  Write-Info "SKIP: 找不到白板文件：$canvasPath"
  exit 0
}

Write-Info "EDIT : $canvasPath"

if ($DryRun) {
  Write-Info "DONE : DryRun 结束（未写入白板）"
  exit 0
}

$raw = Get-Content -LiteralPath $canvasPath -Raw -Encoding UTF8
$canvas = $raw | ConvertFrom-Json

$targetFilePath = "02-知识图谱/SolidWorks/03-模块窗口/03-曲面/03-曲面.md"
$curveImgPathCandidates = @(
  "曲面.png",
  "02-知识图谱/SolidWorks/99-图片/曲面.png"
)

$surfaceNode = $canvas.nodes | Where-Object { $_.type -eq "file" -and $_.file -eq $targetFilePath } | Select-Object -First 1
if (!$surfaceNode) {
  $surfaceNode = [pscustomobject]@{
    id     = (New-ShortId)
    type   = "file"
    file   = $targetFilePath
    x      = 580
    y      = -760
    width  = 400
    height = 400
    color  = "1"
  }
  $canvas.nodes += $surfaceNode
}

$curveImgNode = $null
foreach ($p in $curveImgPathCandidates) {
  $curveImgNode = $canvas.nodes | Where-Object { $_.type -eq "file" -and $_.file -eq $p } | Select-Object -First 1
  if ($curveImgNode) { break }
}
if ($curveImgNode) {
  $edge = $canvas.edges | Where-Object { $_.fromNode -eq $curveImgNode.id -and $_.toNode -eq $surfaceNode.id } | Select-Object -First 1
  if (!$edge) {
    $canvas.edges += [pscustomobject]@{
      id       = (New-ShortId)
      fromNode = $curveImgNode.id
      fromSide = "right"
      toNode   = $surfaceNode.id
      toSide   = "left"
    }
  }
} else {
  Write-Warning "白板里没找到“曲面.png”节点；已跳过连线。"
}

# 在白板里把「曲面」的聚类索引页也引出来（类似草图的“草图命令/草图实体操作”）
$clusterNotes = @(
  "02-知识图谱/SolidWorks/03-模块窗口/03-曲面/01-曲面生成.md",
  "02-知识图谱/SolidWorks/03-模块窗口/03-曲面/02-曲面编辑.md",
  "02-知识图谱/SolidWorks/03-模块窗口/03-曲面/03-面操作.md",
  "02-知识图谱/SolidWorks/03-模块窗口/03-曲面/04-修剪与延伸.md",
  "02-知识图谱/SolidWorks/03-模块窗口/03-曲面/05-缝合曲面.md",
  "02-知识图谱/SolidWorks/03-模块窗口/03-曲面/06-曲面实体化.md"
)

$existingClusterNodes = @(
  $canvas.nodes | Where-Object { $_.type -eq "file" -and ($clusterNotes -contains $_.file) }
)

if ($existingClusterNodes.Count -gt 0) {
  $baseX = [int]$existingClusterNodes[0].x
  $baseY = [int]$existingClusterNodes[0].y
} else {
  $baseX = [int]$surfaceNode.x + [int]$surfaceNode.width + 60
  $baseY = [int]$surfaceNode.y
}

$stepY = 440

for ($i = 0; $i -lt $clusterNotes.Count; $i++) {
  $notePath = $clusterNotes[$i]
  $noteNode = $canvas.nodes | Where-Object { $_.type -eq "file" -and $_.file -eq $notePath } | Select-Object -First 1

  if (!$noteNode) {
    $noteNode = [pscustomobject]@{
      id     = (New-ShortId)
      type   = "file"
      file   = $notePath
      x      = $baseX
      y      = ($baseY + ($i * $stepY))
      width  = 400
      height = 400
      color  = "1"
    }
    $canvas.nodes += $noteNode
  }

  $noteEdge = $canvas.edges | Where-Object { $_.fromNode -eq $surfaceNode.id -and $_.toNode -eq $noteNode.id } | Select-Object -First 1
  if (!$noteEdge) {
    $canvas.edges += [pscustomobject]@{
      id       = (New-ShortId)
      fromNode = $surfaceNode.id
      fromSide = "right"
      toNode   = $noteNode.id
      toSide   = "left"
    }
  }
}

($canvas | ConvertTo-Json -Depth 50) | Set-Content -LiteralPath $canvasPath -Encoding UTF8

Write-Info "DONE : 已生成曲面笔记，并更新白板链接"




