param(
  [Parameter(Mandatory = $true)]
  [string]$CanvasPath,

  [Parameter(Mandatory = $true)]
  [string]$OutPngPath,
  [Parameter(Mandatory = $false)]
  [string]$RootFile,


  [Parameter(Mandatory = $false)]
  [int]$MaxWidth = 1800,

  [Parameter(Mandatory = $false)]
  [int]$MaxHeight = 1000,

  [Parameter(Mandatory = $false)]
  [int]$Margin = 40
)

$ErrorActionPreference = "Stop"


Add-Type -AssemblyName System.Drawing

function ShortLabel([string]$p) {
  if ([string]::IsNullOrWhiteSpace($p)) { return "" }
  $name = [System.IO.Path]::GetFileNameWithoutExtension($p)
  # 去掉前缀数字：03-曲面 -> 曲面
  $name = $name -replace '^[0-9]{2,3}(-[0-9]{2})?-', ''
  return $name
}

$raw = Get-Content -LiteralPath $CanvasPath -Raw -Encoding UTF8
$canvas = $raw | ConvertFrom-Json

$allNodes = @($canvas.nodes | Where-Object { $_.type -eq "file" -or $_.type -eq "text" })
if ($allNodes.Count -eq 0) { throw "canvas 里没有可渲染节点：$CanvasPath" }

if (![string]::IsNullOrWhiteSpace($RootFile)) {
  $nodeById = @{}
  foreach ($n in $canvas.nodes) { $nodeById[$n.id] = $n }

  $root = $canvas.nodes | Where-Object { $_.type -eq "file" -and $_.file -eq $RootFile } | Select-Object -First 1
  if (!$root) { throw "找不到 RootFile 对应节点：$RootFile" }

  $adj = @{}
  foreach ($e in @($canvas.edges)) {
    if (![string]::IsNullOrWhiteSpace($e.fromNode) -and ![string]::IsNullOrWhiteSpace($e.toNode)) {
      if (!$adj.ContainsKey($e.fromNode)) { $adj[$e.fromNode] = New-Object System.Collections.Generic.List[string] }
      if (!$adj.ContainsKey($e.toNode)) { $adj[$e.toNode] = New-Object System.Collections.Generic.List[string] }
      $adj[$e.fromNode].Add([string]$e.toNode) | Out-Null
      $adj[$e.toNode].Add([string]$e.fromNode) | Out-Null
    }
  }

  $queue = New-Object System.Collections.Generic.Queue[string]
  $seen = New-Object System.Collections.Generic.HashSet[string]
  $queue.Enqueue([string]$root.id)
  $seen.Add([string]$root.id) | Out-Null

  while ($queue.Count -gt 0) {
    $cur = $queue.Dequeue()
    if ($adj.ContainsKey($cur)) {
      foreach ($nxt in $adj[$cur]) {
        if ($seen.Add([string]$nxt)) { $queue.Enqueue([string]$nxt) }
      }
    }
  }

  $nodes = @($allNodes | Where-Object { $seen.Contains([string]$_.id) })
} else {
  $nodes = $allNodes
}

if ($nodes.Count -eq 0) { throw "没有可渲染节点（过滤后为空）：$CanvasPath" }

# 计算边界（只用可视节点）
$minX = [double]::PositiveInfinity
$minY = [double]::PositiveInfinity
$maxX = [double]::NegativeInfinity
$maxY = [double]::NegativeInfinity

foreach ($n in $nodes) {
  $x = [double]$n.x
  $y = [double]$n.y
  $w = [double]$n.width
  $h = [double]$n.height
  if ($x -lt $minX) { $minX = $x }
  if ($y -lt $minY) { $minY = $y }
  if (($x + $w) -gt $maxX) { $maxX = $x + $w }
  if (($y + $h) -gt $maxY) { $maxY = $y + $h }
}

$contentW = [Math]::Max(1.0, $maxX - $minX)
$contentH = [Math]::Max(1.0, $maxY - $minY)

$scaleX = ($MaxWidth - 2 * $Margin) / $contentW
$scaleY = ($MaxHeight - 2 * $Margin) / $contentH
$scale = [Math]::Min($scaleX, $scaleY)
$scale = [Math]::Max(0.05, [Math]::Min($scale, 1.0))

$imgW = [int][Math]::Ceiling($contentW * $scale + 2 * $Margin)
$imgH = [int][Math]::Ceiling($contentH * $scale + 2 * $Margin)

$bmp = New-Object System.Drawing.Bitmap $imgW, $imgH
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.Clear([System.Drawing.Color]::White)

$penEdge = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 120, 120), 2)
$penEdge.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor

$penBox = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 70, 70), 2)
$brushMd = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245, 249, 255))
$brushImg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(250, 245, 235))
$brushText = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245, 245, 245))
$brushLabel = [System.Drawing.Brushes]::Black

$font = New-Object System.Drawing.Font "Segoe UI", 14, ([System.Drawing.FontStyle]::Regular)

function ToScreenRect($n) {
  $sx = ($n.x - $minX) * $scale + $Margin
  $sy = ($n.y - $minY) * $scale + $Margin
  $sw = $n.width * $scale
  $sh = $n.height * $scale
  return [System.Drawing.RectangleF]::new([float]$sx, [float]$sy, [float]$sw, [float]$sh)
}

$nodeById = @{}
foreach ($n in $canvas.nodes) { $nodeById[$n.id] = $n }

# 尝试把图片节点真实渲染出来（而不是只画框）
$canvasDir = Split-Path -Parent $CanvasPath
$vaultRoot = Split-Path -Parent (Split-Path -Parent $canvasDir)

function Resolve-AssetPath([string]$rel) {
  if ([string]::IsNullOrWhiteSpace($rel)) { return $null }
  $p = $rel -replace '/', '\\'
  $try1 = Join-Path $vaultRoot $p
  if (Test-Path -LiteralPath $try1) { return $try1 }
  $try2 = Join-Path $canvasDir $p
  if (Test-Path -LiteralPath $try2) { return $try2 }
  return $null
}

# 先画边
foreach ($e in @($canvas.edges)) {
  if (!$nodeById.ContainsKey($e.fromNode) -or !$nodeById.ContainsKey($e.toNode)) { continue }
  $from = $nodeById[$e.fromNode]
  $to = $nodeById[$e.toNode]
  if (!($from.type -eq "file" -or $from.type -eq "text")) { continue }
  if (!($to.type -eq "file" -or $to.type -eq "text")) { continue }

  $rf = ToScreenRect $from
  $rt = ToScreenRect $to
  $p1 = [System.Drawing.PointF]::new($rf.Left + $rf.Width / 2, $rf.Top + $rf.Height / 2)
  $p2 = [System.Drawing.PointF]::new($rt.Left + $rt.Width / 2, $rt.Top + $rt.Height / 2)
  $g.DrawLine($penEdge, $p1, $p2)
}

# 再画节点
foreach ($n in $nodes) {
  $r = ToScreenRect $n
  $label = ""
  $brush = $brushText

  if ($n.type -eq "file") {
    if ($n.file -match '\.(png|jpg|jpeg|webp)$') {
      # 图片节点本身就能表达信息，不额外叠字，避免遮挡画面
      $label = ""
      $brush = $brushImg
    } else {
      $label = ShortLabel $n.file
      if ($n.file -match '\.md$') { $brush = $brushMd }
    }
  } elseif ($n.type -eq "text") {
    $label = "Text"
  }

  if ($n.type -eq "file" -and $n.file -match '\.(png|jpg|jpeg|webp)$') {
    $imgPath = Resolve-AssetPath $n.file
    if ($imgPath) {
      $img = [System.Drawing.Image]::FromFile($imgPath)
      try {
        $g.DrawImage($img, $r)
      } finally {
        $img.Dispose()
      }
      $g.DrawRectangle($penBox, $r.X, $r.Y, $r.Width, $r.Height)
    } else {
      $g.FillRectangle($brush, $r)
      $g.DrawRectangle($penBox, $r.X, $r.Y, $r.Width, $r.Height)
    }
  } else {
    $g.FillRectangle($brush, $r)
    $g.DrawRectangle($penBox, $r.X, $r.Y, $r.Width, $r.Height)
  }

  if (![string]::IsNullOrWhiteSpace($label)) {
    $layout = [System.Drawing.RectangleF]::new($r.X + 10, $r.Y + 10, $r.Width - 20, $r.Height - 20)
    $g.DrawString($label, $font, $brushLabel, $layout)
  }
}

$outDir = Split-Path -Parent $OutPngPath
if (!(Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$bmp.Save($OutPngPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()

"DONE: $OutPngPath"




