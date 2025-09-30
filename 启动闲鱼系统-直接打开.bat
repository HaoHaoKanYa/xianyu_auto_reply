@echo off
chcp 65001 > nul
title 闲鱼自动回复系统 - 直接启动

echo ========================================
echo      闲鱼自动回复系统 - 一键启动
echo ========================================
echo.

:: 切换到项目目录
cd /d "%~dp0"

:: 检查Python是否安装
python --version > nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到Python环境，请先安装Python 3.11+
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)

:: 检查虚拟环境
if exist "venv\Scripts\activate.bat" (
    echo [信息] 激活虚拟环境...
    call venv\Scripts\activate.bat
)

:: 检查依赖包
python -c "import fastapi, uvicorn, loguru" > nul 2>&1
if errorlevel 1 (
    echo [信息] 安装依赖包...
    pip install -r requirements.txt > nul 2>&1
)

:: 检查服务是否已经在运行
curl -s -o nul http://localhost:8080/health 2>nul
if not errorlevel 1 (
    echo [提示] 服务已在运行，直接打开管理界面
    start http://localhost:8080
    echo [完成] 管理界面已打开
    timeout /t 3 > nul
    exit /b 0
)

echo [信息] 正在后台启动系统...
:: 后台启动Python服务
start /b "" python Start.py

:: 等待服务启动并自动打开浏览器
echo [信息] 等待服务启动中，请稍候...
for /l %%i in (1,1,60) do (
    curl -s -o nul http://localhost:8080/health 2>nul
    if not errorlevel 1 (
        echo [成功] 服务启动完成！
        echo [信息] 正在打开管理界面...
        timeout /t 2 > nul
        start http://localhost:8080
        goto :success
    )
    if %%i==20 echo [提示] 首次启动可能需要更长时间，请耐心等待...
    if %%i==40 echo [提示] 即将完成，请再等待片刻...
    timeout /t 1 /nobreak > nul
)

echo [警告] 启动超时，但仍尝试打开管理界面
start http://localhost:8080

:success
echo.
echo ========================================
echo          启动完成！
echo ========================================
echo [地址] http://localhost:8080
echo [状态] 系统正在后台运行
echo [提示] 浏览器已自动打开管理界面
echo [提示] 如需停止系统，请运行"停止闲鱼系统.bat"
echo ========================================
echo.
echo 按任意键关闭此窗口（系统将继续后台运行）...
pause > nul