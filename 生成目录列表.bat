@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: 定义变量
set "html_file=index.html"
set "title=WOD 日志目录"
set "exclude=.git __pycache__ .github node_modules"

:: 清空原有 index.html
echo ^<!DOCTYPE html^> > "%html_file%"
echo ^<html lang="zh-CN"^> >> "%html_file%"
echo ^<head^> >> "%html_file%"
echo     ^<meta charset="UTF-8"^> >> "%html_file%"
echo     ^<title^>%title%^</title^> >> "%html_file%"
echo     ^<style^> >> "%html_file%"
echo         body { >> "%html_file%"
echo             font-family: "微软雅黑", Arial, sans-serif; >> "%html_file%"
echo             max-width: 800px; >> "%html_file%"
echo             margin: 50px auto; >> "%html_file%"
echo             padding: 0 20px; >> "%html_file%"
echo             background-color: #f8f9fa; >> "%html_file%"
echo         } >> "%html_file%"
echo         h1 { >> "%html_file%"
echo             color: #212529; >> "%html_file%"
echo             border-bottom: 2px solid #0d6efd; >> "%html_file%"
echo             padding-bottom: 10px; >> "%html_file%"
echo             margin-bottom: 30px; >> "%html_file%"
echo         } >> "%html_file%"
echo         .dir-link { >> "%html_file%"
echo             display: block; >> "%html_file%"
echo             padding: 12px 18px; >> "%html_file%"
echo             margin: 8px 0; >> "%html_file%"
echo             background-color: #ffffff; >> "%html_file%"
echo             border: 1px solid #dee2e6; >> "%html_file%"
echo             border-radius: 6px; >> "%html_file%"
echo             text-decoration: none; >> "%html_file%"
echo             color: #0d6efd; >> "%html_file%"
echo             transition: all 0.2s ease; >> "%html_file%"
echo         } >> "%html_file%"
echo         .dir-link:hover { >> "%html_file%"
echo             background-color: #e9ecef; >> "%html_file%"
echo             border-color: #0d6efd; >> "%html_file%"
echo             color: #0a58ca; >> "%html_file%"
echo         } >> "%html_file%"
echo     ^</style^> >> "%html_file%"
echo ^</head^> >> "%html_file%"
echo ^<body^> >> "%html_file%"
echo     ^<h1^>%title%^</h1^> >> "%html_file%"

:: 遍历当前目录下的所有文件夹，生成链接
for /d %%i in (*) do (
    :: 跳过排除的文件夹
    set "skip=0"
    for %%e in (%exclude%) do (
        if "%%i"=="%%e" set "skip=1"
    )
    if !skip! equ 0 (
        :: 生成指向子文件夹 index.html 的链接
        echo     ^<a class="dir-link" href="./%%i/index.html"^>%%i^</a^> >> "%html_file%"
    )
)

:: 结束 HTML 标签
echo ^</body^> >> "%html_file%"
echo ^</html^> >> "%html_file%"

:: 执行成功提示
echo ==============================
echo 操作完成！
echo 已生成 %html_file% 文件，包含所有子文件夹链接
echo 请将文件推送到 GitHub/Gitee 仓库
echo ==============================
pause