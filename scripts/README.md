# Obsidian（SolidWorks）脚本说明

## 1) 生成「曲面」笔记结构 + 挂到白板

脚本：`scripts/solidworks_surface_scaffold.ps1`

- 预演（不写入）：  
  `powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\claww\Documents\New project\scripts\solidworks_surface_scaffold.ps1" -DryRun`
- 真正写入（会创建/覆盖曲面相关 md，并更新白板 canvas）：  
  `powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\claww\Documents\New project\scripts\solidworks_surface_scaffold.ps1"`

可选参数：

- 指定你的仓库根目录：`-VaultRoot "C:\Users\claww\Data\Obsidian\知识图谱"`

## 2) 给白板加「图片 → 笔记」连线（通用）

脚本：`scripts/obsidian_canvas_link_note.ps1`

- 预演：  
  `powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\claww\Documents\New project\scripts\obsidian_canvas_link_note.ps1" -CanvasRelativePath "02-知识图谱\SolidWorks\白板思维导图.canvas" -FromImageFile "曲面.png" -ToNoteFile "02-知识图谱/SolidWorks/03-模块窗口/03-曲面/03-曲面.md" -DryRun`
- 写入：去掉 `-DryRun`

## 3) 整理白板图片（移动到 99-图片 + 按关联笔记重命名）

脚本：`scripts/obsidian_canvas_organize_images.ps1`

- 预演：  
  `powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\claww\Documents\New project\scripts\obsidian_canvas_organize_images.ps1" -VaultRoot "C:\Users\claww\Documents\New project\examples\solidworks_vault" -CanvasRelativePath "02-知识图谱\SolidWorks\白板思维导图.canvas" -DryRun`
- 写入：去掉 `-DryRun`
