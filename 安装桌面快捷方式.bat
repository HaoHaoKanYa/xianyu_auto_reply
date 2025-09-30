@echo off
chcp 65001 > nul
title 安装桌面快捷方式

echo ========================================
echo        安装闲鱼系统桌面快捷方式
echo ========================================
echo.

:: 获取当前脚本路径
set "SCRIPT_DIR=%~dp0"
set "DESKTOP=%USERPROFILE%\Desktop"

echo [信息] 项目路径: %SCRIPT_DIR%
echo [信息] 桌面路径: %DESKTOP%
echo.

:: 创建一键启动快捷方式（推荐）
echo [1/4] 创建一键启动快捷方式（推荐）...
powershell -Command ^
"$WshShell = New-Object -comObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%DESKTOP%\闲鱼系统.lnk'); ^
$Shortcut.TargetPath = '%SCRIPT_DIR%一键启动管理界面.bat'; ^
$Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; ^
$Shortcut.Description = '闲鱼自动回复系统 - 一键启动（推荐）'; ^
$Shortcut.Save()"

if exist "%DESKTOP%\闲鱼系统.lnk" (
    echo [成功] 一键启动快捷方式已创建
) else (
    echo [失败] 一键启动快捷方式创建失败
)

:: 创建主启动快捷方式
echo [2/4] 创建Python启动快捷方式...
powershell -Command ^
"$WshShell = New-Object -comObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%DESKTOP%\闲鱼自动回复系统-Python.lnk'); ^
$Shortcut.TargetPath = '%SCRIPT_DIR%启动闲鱼系统.bat'; ^
$Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; ^
$Shortcut.Description = '闲鱼自动回复系统 - Python模式'; ^
$Shortcut.Save()"

if exist "%DESKTOP%\闲鱼自动回复系统-Python.lnk" (
    echo [成功] Python启动快捷方式已创建
) else (
    echo [失败] Python启动快捷方式创建失败
)

:: 创建Docker启动快捷方式
echo [3/4] 创建Docker启动快捷方式...
powershell -Command ^
"$WshShell = New-Object -comObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%DESKTOP%\闲鱼系统-Docker.lnk'); ^
$Shortcut.TargetPath = '%SCRIPT_DIR%启动闲鱼系统-Docker.bat'; ^
$Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; ^
$Shortcut.Description = '闲鱼自动回复系统 - Docker模式'; ^
$Shortcut.Save()"

if exist "%DESKTOP%\闲鱼系统-Docker.lnk" (
    echo [成功] Docker启动快捷方式已创建
) else (
    echo [失败] Docker启动快捷方式创建失败
)

:: 创建系统管理快捷方式
echo [4/4] 创建系统管理快捷方式...
powershell -Command ^
"$WshShell = New-Object -comObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%DESKTOP%\闲鱼系统管理.lnk'); ^
$Shortcut.TargetPath = 'powershell.exe'; ^
$Shortcut.Arguments = '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%闲鱼系统启动器.ps1\"'; ^
$Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; ^
$Shortcut.Description = '闲鱼自动回复系统 - 高级管理器'; ^
$Shortcut.Save()"

if exist "%DESKTOP%\闲鱼系统管理.lnk" (
    echo [成功] 系统管理快捷方式已创建
) else (
    echo [失败] 系统管理快捷方式创建失败
)

:: 创建状态检查快捷方式
echo [额外] 创建状态检查快捷方式...
powershell -Command ^
"$WshShell = New-Object -comObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%DESKTOP%\闲鱼系统状态.lnk'); ^
$Shortcut.TargetPath = '%SCRIPT_DIR%系统状态检查.bat'; ^
$Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; ^
$Shortcut.Description = '闲鱼自动回复系统 - 状态检查'; ^
$Shortcut.Save()"

:: 创建停止快捷方式
echo [额外] 创建停止快捷方式...
powershell -Command ^
"$WshShell = New-Object -comObject WScript.Shell; ^
$Shortcut = $WshShell.CreateShortcut('%DESKTOP%\停止闲鱼系统.lnk'); ^
$Shortcut.TargetPath = '%SCRIPT_DIR%停止闲鱼系统.bat'; ^
$Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; ^
$Shortcut.Description = '闲鱼自动回复系统 - 停止服务'; ^
$Shortcut.Save()"

echo.
echo ========================================
echo              安装完成！
echo ========================================
echo.
echo [完成] 桌面快捷方式已创建，包括:
echo   • 闲鱼系统.lnk                (一键启动，推荐★)
echo   • 闲鱼自动回复系统-Python.lnk  (Python模式)
echo   • 闲鱼系统-Docker.lnk          (Docker模式)
echo   • 闲鱼系统管理.lnk             (高级管理)
echo   • 闲鱼系统状态.lnk             (状态检查)
echo   • 停止闲鱼系统.lnk             (停止服务)
echo.
echo [推荐] 新手用户请使用"闲鱼系统"快捷方式（一键启动）
echo [提示] 双击后系统将自动启动并打开管理界面
echo.
echo [下一步] 是否要立即启动系统？(Y/N)
set /p start_now="请选择: "

if /i "%start_now%"=="Y" (
    echo [信息] 正在启动系统...
    start "" "%DESKTOP%\闲鱼系统.lnk"
) else (
    echo [信息] 您可以稍后双击桌面图标启动系统
)

echo.
pause