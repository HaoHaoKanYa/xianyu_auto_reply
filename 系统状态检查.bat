@echo off
chcp 65001 > nul
title 闲鱼自动回复系统 - 系统状态

echo ========================================
echo       闲鱼自动回复系统 - 系统状态
echo ========================================
echo.

:: 切换到项目目录
cd /d "%~dp0"

echo [信息] 检查系统运行状态...
echo.

:: 检查端口占用
echo === 端口状态检查 ===
netstat -an | findstr ":8080" > nul 2>&1
if errorlevel 1 (
    echo [状态] 8080端口未被占用
) else (
    echo [状态] 8080端口正在使用中
    netstat -ano | findstr ":8080"
)
echo.

:: 检查Python进程
echo === Python进程检查 ===
tasklist | findstr "python.exe" > nul 2>&1
if errorlevel 1 (
    echo [状态] 未检测到Python进程
) else (
    echo [状态] Python进程运行中:
    tasklist | findstr "python.exe"
)
echo.

:: 检查Docker容器
echo === Docker容器检查 ===
docker ps | findstr "xianyu-auto-reply" > nul 2>&1
if errorlevel 1 (
    echo [状态] Docker容器未运行
) else (
    echo [状态] Docker容器运行中:
    docker ps | findstr "xianyu-auto-reply"
)
echo.

:: 尝试访问服务
echo === 服务可用性检查 ===
curl -s -o nul -w "HTTP状态码: %%{http_code}" http://localhost:8080/health 2>nul
if errorlevel 1 (
    echo [状态] 服务不可访问 (可能未启动或启动中)
) else (
    echo [状态] 服务正常运行
    echo [地址] http://localhost:8080
)
echo.

echo === 快速操作 ===
echo [1] 打开系统管理界面
echo [2] 查看Docker日志
echo [3] 重启系统
echo [0] 退出
echo.
set /p choice="请选择操作 (0-3): "

if "%choice%"=="1" (
    start http://localhost:8080
    echo [完成] 已打开管理界面
)
if "%choice%"=="2" (
    docker logs -f xianyu-auto-reply
)
if "%choice%"=="3" (
    echo [信息] 正在重启系统...
    call "停止闲鱼系统.bat"
    timeout /t 3 > nul
    call "启动闲鱼系统-Docker.bat"
)

echo.
pause