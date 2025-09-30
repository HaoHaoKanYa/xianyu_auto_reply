@echo off
chcp 65001 > nul
title 闲鱼自动回复系统

echo ========================================
echo        闲鱼自动回复系统启动器
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

echo [信息] Python环境检测正常
echo.

:: 检查虚拟环境
if exist "venv\Scripts\activate.bat" (
    echo [信息] 检测到虚拟环境，正在激活...
    call venv\Scripts\activate.bat
) else (
    echo [提示] 未检测到虚拟环境，使用系统Python环境
)

:: 检查依赖包
echo [信息] 检查依赖包...
python -c "import fastapi, uvicorn, loguru" > nul 2>&1
if errorlevel 1 (
    echo [警告] 缺少必要依赖包，正在安装...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo [错误] 依赖包安装失败，请检查网络连接
        pause
        exit /b 1
    )
)

:: 检查Playwright浏览器
echo [信息] 检查Playwright浏览器...
python -c "from playwright.sync_api import sync_playwright; sync_playwright().start()" > nul 2>&1
if errorlevel 1 (
    echo [警告] Playwright浏览器未安装，正在安装...
    playwright install chromium
)

echo.
echo [信息] 正在启动闲鱼自动回复系统...
echo [提示] 系统启动后将自动打开管理界面
echo [提示] 按 Ctrl+C 可以停止系统
echo.

:: 后台启动系统
start /b python Start.py

:: 等待服务启动
echo [信息] 等待服务启动中...
timeout /t 15 /nobreak > nul

:: 检查服务是否启动成功
for /l %%i in (1,1,30) do (
    curl -s -o nul http://localhost:8080/health
    if not errorlevel 1 (
        echo [成功] 服务启动完成！
        echo [信息] 正在打开管理界面...
        start http://localhost:8080
        goto :service_ready
    )
    timeout /t 2 /nobreak > nul
)

echo [警告] 服务启动超时，请手动访问: http://localhost:8080
start http://localhost:8080

:service_ready
echo.
echo ========================================
echo        闲鱼自动回复系统已启动
echo ========================================
echo [地址] http://localhost:8080
echo [状态] 系统正在后台运行
echo [提示] 关闭此窗口将停止系统
echo ========================================
echo.
echo 按任意键停止系统并退出...
pause > nul

:: 停止系统
echo [信息] 正在停止系统...
taskkill /f /im python.exe > nul 2>&1
echo [完成] 系统已停止