@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
title 生成目录索引...

echo ^<!DOCTYPE html^> > index.html
echo ^<html lang="zh-CN"^> >> index.html
echo ^<head^> >> index.html
echo     ^<meta charset="UTF-8"^> >> index.html
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> index.html
echo     ^<title^>文件目录索引^</title^> >> index.html
echo     ^<style^> >> index.html
echo         body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; background: #f5f5f5; color: #333; margin: 0; padding: 20px; } >> index.html
echo         .container { max-width: 1000px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); } >> index.html
echo         h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; margin-top: 0; } >> index.html
echo         .group { margin-bottom: 25px; } >> index.html
echo         .group-title { font-size: 18px; font-weight: 600; color: #3498db; margin: 15px 0 10px; cursor: pointer; user-select: none; padding: 8px 12px; background: #f8f9fa; border-radius: 6px; } >> index.html
echo         .group-title:hover { color: #2980b9; background: #e9ecef; } >> index.html
echo         .folder-list { list-style: none; padding: 0; margin: 0 0 0 10px; display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 10px; } >> index.html
echo         .folder-item { background: #ecf0f1; padding: 12px 15px; border-radius: 6px; transition: transform 0.2s, box-shadow 0.2s; } >> index.html
echo         .folder-item:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); } >> index.html
echo         .folder-item a { text-decoration: none; color: #2c3e50; font-weight: 500; display: flex; align-items: center; } >> index.html
echo         .folder-item a::before { content: "\1F4C1"; margin-right: 10px; font-size: 18px; } >> index.html
echo         .date { font-size: 12px; color: #7f8c8d; margin-left: auto; } >> index.html
echo         .no-group { color: #95a5a6; font-style: italic; } >> index.html
echo     ^</style^> >> index.html
echo ^</head^> >> index.html
echo ^<body^> >> index.html
echo     ^<div class="container"^> >> index.html
echo         ^<h1^>📁 文件目录索引^</h1^> >> index.html

set "currentGroup="
set "hasGroups=0"

for /f "delims=" %%d in ('dir /ad /b ^| findstr /v /i "^\."') do (
    set "folderName=%%~nxd"
    set "groupName="
    set "displayName=!folderName!"
    
    set "temp=!folderName:*[=!"
    if not "!temp!"=="!folderName!" (
        for /f "delims=]" %%g in ("!temp!") do set "groupName=%%g"
        call :removePrefix "!folderName!" displayName
    )
    
    for /f "delims=" %%a in ('powershell "(Get-Item '%%d').LastWriteTime.ToString('yyyy-MM-dd HH:mm')"') do set "modTime=%%a"
    
    if "!groupName!"=="" set "groupName=未分组"
    
    if not "!groupName!"=="!currentGroup!" (
        if not "!currentGroup!"=="" (
            echo         ^</ul^> >> index.html
            echo     ^</div^> >> index.html
        )
        echo     ^<div class="group"^> >> index.html
        if "!groupName!"=="未分组" (
            echo         ^<div class="group-title no-group" onclick="toggleGroup(this)"^>📂 !groupName! ▶^</div^> >> index.html
        ) else (
            echo         ^<div class="group-title" onclick="toggleGroup(this)"^>📂 !groupName! ▶^</div^> >> index.html
        )
        echo         ^<ul class="folder-list" style="display: none;"^> >> index.html
        set "currentGroup=!groupName!"
        set "hasGroups=1"
    )
    
    echo         ^<li class="folder-item"^>^<a href="%%~nxd/index.html"^>!displayName!^<span class="date"^>!modTime!^</span^>^</a^>^</li^> >> index.html
)

if "!hasGroups!"=="1" (
    echo         ^</ul^> >> index.html
    echo     ^</div^> >> index.html
) else (
    echo     ^<p style="color: #95a5a6; font-style: italic;"^>暂无文件夹^</p^> >> index.html
)

echo     ^</div^> >> index.html
echo     ^<script^> >> index.html
echo         function toggleGroup(el) { >> index.html
echo             const ul = el.nextElementSibling; >> index.html
echo             if (ul.style.display === 'none') { >> index.html
echo                 ul.style.display = 'grid'; >> index.html
echo                 el.innerHTML = el.innerHTML.replace('▶', '▼'); >> index.html
echo             } else { >> index.html
echo                 ul.style.display = 'none'; >> index.html
echo                 el.innerHTML = el.innerHTML.replace('▼', '▶'); >> index.html
echo             } >> index.html
echo         } >> index.html
echo     ^</script^> >> index.html
echo ^</body^> >> index.html
echo ^</html^> >> index.html

echo.
echo ✅ 成功生成 index.html!
pause
exit /b

:removePrefix
set "fullName=%~1"
set "result=%fullName%"
:loop
set "temp=!result:*]=!"
if not "!temp!"=="!result!" (
    set "result=!temp!"
    goto loop
)
for /f "tokens=* delims= " %%s in ("!result!") do set "%~2=%%s"
goto :eof