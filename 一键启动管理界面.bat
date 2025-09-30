@echo off
:: 闲鱼自动回复系统 - 一键启动管理界面
title 启动中...

:: 隐藏窗口图标设置
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )

:: 切换到项目目录  
cd /d "%~dp0"

:: 检查服务是否已运行
curl -s -o nul http://localhost:8080/health 2>nul
if not errorlevel 1 (
    :: 服务已运行，直接打开管理界面
    start http://localhost:8080
    exit /b 0
)

:: 服务未运行，需要启动
echo 正在启动闲鱼自动回复系统...

:: 检查启动方式优先级: Docker > Python
docker --version > nul 2>&1
if not errorlevel 1 (
    docker info > nul 2>&1
    if not errorlevel 1 (
        :: 使用Docker启动
        echo 使用Docker模式启动...
        docker stop xianyu-auto-reply > nul 2>&1
        docker rm xianyu-auto-reply > nul 2>&1
        if not exist "data" mkdir data
        
        if exist "Dockerfile" (
            docker build -t xianyu-auto-reply . > nul 2>&1
            docker run -d -p 8080:8080 -v "%cd%\data:/app/data" --name xianyu-auto-reply xianyu-auto-reply > nul 2>&1
        ) else (
            docker run -d -p 8080:8080 -v "%cd%\data:/app/data" --name xianyu-auto-reply python:3.11-slim > nul 2>&1
        )
        goto :wait_service
    )
)

:: 使用Python启动
python --version > nul 2>&1
if errorlevel 1 (
    echo 错误：未检测到Python或Docker环境
    echo 请先安装Python 3.11+或Docker Desktop
    pause
    exit /b 1
)

echo 使用Python模式启动...
if exist "venv\Scripts\activate.bat" call venv\Scripts\activate.bat
start /b python Start.py

:wait_service
:: 等待服务启动
echo 等待服务启动中...
for /l %%i in (1,1,120) do (
    curl -s -o nul http://localhost:8080/health 2>nul
    if not errorlevel 1 (
        :: 服务启动成功，打开管理界面
        start http://localhost:8080
        echo 管理界面已打开：http://localhost:8080
        timeout /t 2 > nul
        exit /b 0
    )
    timeout /t 1 /nobreak > nul
)

:: 超时仍然尝试打开
echo 启动可能需要更长时间，正在打开管理界面...
start http://localhost:8080
exit /b 0