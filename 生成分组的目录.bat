@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
del tmp_folders.txt 2>nul >nul

:: 核心逻辑：PowerShell按「字符」安全遍历+截取，彻底解决中文/特殊符号问题
for /f "delims=" %%d in ('powershell -Command "Get-ChildItem -Directory | Select-Object -ExpandProperty FullName"') do (
    set "fullFolder=%%d"
    :: 获取纯文件夹名（不含路径）
    for %%f in ("!fullFolder!") do set "folderName=%%~nxf"

    :: ================== 1. 安全截取后12位（按字符，不破坏中文） ==================
    for /f "delims=" %%s in ('powershell -Command "$str='!folderName!'; if($str.Length -ge 12){Write-Output $str.Substring($str.Length-12)}else{Write-Output $str}"') do (
        set "sortCode=%%s"
    )
    :: 不足12位补0（保证排序正确）
    if "!sortCode!"=="!folderName!" set "sortCode=000000000000"

    :: ================== 2. 安全截取前N-12位（显示名，去后12位） ==================
    for /f "delims=" %%n in ('powershell -Command "$str='!folderName!'; if($str.Length -ge 12){Write-Output $str.Substring(0, $str.Length-12)}else{Write-Output $str}"') do (
        set "displayName=%%n"
    )

    :: ================== 3. 解析 [分组] 前缀 ==================
    set "group=未分组"
    set "pureName=!displayName!"
    if "!displayName:~0,1!"=="[" (
        for /f "tokens=1 delims=]" %%g in ("!displayName!") do (
            set "group=%%g"
            set "group=!group:~1!"
            set "pureName=!displayName:*]=!"
        )
    )

    :: ================== 4. 获取修改时间 ==================
    for /f "delims=" %%t in ('powershell -Command "(Get-Item '!fullFolder!').LastWriteTime.ToString('yyyy-MM-dd HH:mm')"') do (
        set "time=%%t"
    )

    :: 写入临时文件（排序码|分组|全名|显示名|时间）
    echo !sortCode!^|!group!^|!fullFolder!^|!pureName!^|!time! >> tmp_folders.txt
)

:: ================== 排序（按数字字符串自然排序） ==================
if exist tmp_folders.txt (
    sort tmp_folders.txt /o sorted_folders.txt
)

:: ================== 生成HTML ==================
echo ^<!DOCTYPE html^> > index.html
echo ^<html lang="zh-CN"^> >> index.html
echo ^<head^> >> index.html
echo ^<meta charset="utf-8"^> >> index.html
echo ^<meta name="viewport" content="width=device-width, initial-scale=1"^> >> index.html
echo ^<style^> >> index.html
echo *{box-sizing:border-box;font-family:Microsoft YaHei,sans-serif;}body{background:#f5f7fa;padding:20px;max-width:1000px;margin:0 auto;}.group{background:white;border-radius:12px;margin-bottom:12px;box-shadow:0 2px 8px rgba(0,0,0,0.08);overflow:hidden;}.group-title{padding:14px 18px;background:#3b82f6;color:white;font-size:16px;font-weight:500;cursor:pointer;display:flex;justify-content:space-between;align-items:center;}.group-title:hover{background:#2563eb;}.item{padding:12px 18px;border-top:1px solid #f1f5f9;display:flex;justify-content:space-between;align-items:center;}.item a{color:#1e293b;text-decoration:none;display:block;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:70%;}.item:hover{background:#f8fafc;}.time{color:#64748b;font-size:14px;}.empty{text-align:center;padding:40px;color:#94a3b8;} >> index.html
echo ^</style^> >> index.html
echo ^<script^>function toggleGroup(g){let items=document.querySelectorAll('.group-'+g);items.forEach(i=>i.style.display=i.style.display=='none'?'flex':'none');} ^</script^> >> index.html
echo ^</head^> >> index.html
echo ^<body^> >> index.html

set "lastGroup="
set "groupIndex=0"

:: 读取排序后数据生成页面
for /f "tokens=1-5 delims=|" %%a in (sorted_folders.txt) do (
    set "sortCode=%%a"
    set "group=%%b"
    set "fullname=%%c"
    set "display=%%d"
    set "time=%%e"

    if "!group!" neq "!lastGroup!" (
        if not "!lastGroup!"=="" echo ^</div^> >> index.html
        set /a groupIndex+=1
        echo ^<div class="group"^> >> index.html
        echo ^<div class="group-title" onclick="toggleGroup(!groupIndex!)"^>!group! ^<span^>▼^</span^>^</div^> >> index.html
        set "lastGroup=!group!"
    )

    echo ^<div class="item group-!groupIndex!"^> >> index.html
    echo ^<a href="!fullname!/index.html" target="_blank" title="!display!"^>!display!^</a^> >> index.html
    echo ^<span class="time"^>!time!^</span^> >> index.html
    echo ^</div^> >> index.html
)

if !groupIndex! equ 0 (
    echo ^<div class="empty"^>暂无文件夹^</div^> >> index.html
) else (
    echo ^</div^> >> index.html
)

echo ^</body^> >> index.html
echo ^</html^> >> index.html

:: 清理临时文件
del tmp_folders.txt 2>nul >nul
del sorted_folders.txt 2>nul >nul

echo ✅ 生成完成！完美支持中文/特殊符号 & pause
exit /b