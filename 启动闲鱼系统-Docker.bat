@echo off
chcp 65001 > nul
title 闲鱼自动回复系统 - Docker版

echo ========================================
echo     闲鱼自动回复系统启动器(Docker版)
echo ========================================
echo.

:: 切换到项目目录
cd /d "%~dp0"

:: 检查Docker是否安装
docker --version > nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到Docker环境，请先安装Docker Desktop
    echo 下载地址: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo [信息] Docker环境检测正常
echo.

:: 检查Docker是否运行
docker info > nul 2>&1
if errorlevel 1 (
    echo [错误] Docker未运行，请先启动Docker Desktop
    pause
    exit /b 1
)

:: 停止已有容器
echo [信息] 检查并停止已有容器...
docker stop xianyu-auto-reply > nul 2>&1
docker rm xianyu-auto-reply > nul 2>&1

:: 创建数据目录
if not exist "data" mkdir data

:: 检查镜像构建方式
if exist "Dockerfile" (
    echo [信息] 检测到Dockerfile，正在构建镜像...
    docker build -t xianyu-auto-reply .
    if errorlevel 1 (
        echo [错误] Docker镜像构建失败
        pause
        exit /b 1
    )
    
    echo [信息] 正在启动容器...
    docker run -d ^
        -p 8080:8080 ^
        -v "%cd%\data:/app/data" ^
        --name xianyu-auto-reply ^
        --restart unless-stopped ^
        xianyu-auto-reply
) else (
    echo [信息] 使用预构建镜像启动...
    docker run -d ^
        -p 8080:8080 ^
        -v "%cd%\data:/app/data" ^
        --name xianyu-auto-reply ^
        --restart unless-stopped ^
        python:3.11-slim
)

if errorlevel 1 (
    echo [错误] 容器启动失败
    pause
    exit /b 1
)

echo.
echo [成功] 闲鱼自动回复系统已启动！
echo [提示] 系统地址: http://localhost:8080
echo [提示] 查看日志: docker logs -f xianyu-auto-reply
echo [提示] 停止系统: docker stop xianyu-auto-reply
echo.

:: 等待服务启动
echo [信息] 等待服务启动中...
for /l %%i in (1,1,60) do (
    curl -s -o nul http://localhost:8080/health 2>nul
    if not errorlevel 1 (
        echo [成功] 服务启动完成！
        echo [信息] 正在打开管理界面...
        start http://localhost:8080
        goto :docker_ready
    )
    if %%i==20 echo [提示] Docker容器启动中，请稍候...
    if %%i==40 echo [提示] 即将完成，请再等待片刻...
    timeout /t 1 /nobreak > nul
)

echo [警告] 启动超时，但仍尝试打开管理界面
start http://localhost:8080

:docker_ready
echo.
echo ========================================
echo        Docker版启动完成！
echo ========================================
echo [地址] http://localhost:8080
echo [状态] 容器正在后台运行
echo [管理] docker logs -f xianyu-auto-reply
echo [停止] docker stop xianyu-auto-reply
echo ========================================
echo [完成] 浏览器已自动打开管理界面
pause