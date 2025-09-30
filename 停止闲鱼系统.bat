@echo off
chcp 65001 > nul
title 停止闲鱼自动回复系统

echo ========================================
echo        闲鱼自动回复系统停止器
echo ========================================
echo.

:: 切换到项目目录
cd /d "%~dp0"

echo [信息] 正在停止系统...

:: 停止Python进程
echo [信息] 停止Python进程...
taskkill /f /im python.exe /fi "WINDOWTITLE eq 闲鱼自动回复系统*" > nul 2>&1

:: 停止Docker容器
echo [信息] 停止Docker容器...
docker stop xianyu-auto-reply > nul 2>&1
docker rm xianyu-auto-reply > nul 2>&1

echo.
echo [完成] 闲鱼自动回复系统已停止
echo.
pause