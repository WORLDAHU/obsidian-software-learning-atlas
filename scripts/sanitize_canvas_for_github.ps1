param(
  [Parameter(Mandatory = $true)]
  [string]$CanvasPath,

  [Parameter(Mandatory = $false)]
  [switch]$RemoveTextNodes,

  [Parameter(Mandatory = $false)]
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"


function Write-Info([string]$Message) {
  Write-Host $Message
}

if (!(Test-Path -LiteralPath $CanvasPath)) {
  throw "找不到 canvas：$CanvasPath"
}

$raw = Get-Content -LiteralPath $CanvasPath -Raw -Encoding UTF8
$canvas = $raw | ConvertFrom-Json

$origNodeCount = @($canvas.nodes).Count
$origEdgeCount = @($canvas.edges).Count

if ($RemoveTextNodes) {
  $textIds = @($canvas.nodes | Where-Object { $_.type -eq "text" } | Select-Object -ExpandProperty id)
  if ($textIds.Count -gt 0) {
    $canvas.nodes = @($canvas.nodes | Where-Object { $_.type -ne "text" })
    $canvas.edges = @($canvas.edges | Where-Object { ($textIds -notcontains $_.fromNode) -and ($textIds -notcontains $_.toNode) })
    Write-Info "RM   : text nodes = $($textIds.Count)"
  } else {
    Write-Info "SKIP : no text nodes"
  }
}

$newNodeCount = @($canvas.nodes).Count
$newEdgeCount = @($canvas.edges).Count

Write-Info ("INFO : nodes {0} -> {1}, edges {2} -> {3}" -f $origNodeCount, $newNodeCount, $origEdgeCount, $newEdgeCount)

if ($DryRun) {
  Write-Info "DONE : DryRun（未写入）"
  exit 0
}

($canvas | ConvertTo-Json -Depth 50) | Set-Content -LiteralPath $CanvasPath -Encoding UTF8
Write-Info "DONE : 已写入"

\n
