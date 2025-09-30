# 闲鱼自动回复系统启动器 (PowerShell版)
# 设置控制台编码为UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "闲鱼自动回复系统启动器"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "       闲鱼自动回复系统启动器" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 切换到脚本所在目录
Set-Location $PSScriptRoot

function Test-Command($command) {
    try {
        Get-Command $command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Show-Menu {
    Write-Host "请选择启动方式:" -ForegroundColor Green
    Write-Host "[1] Python直接运行 (推荐开发环境)" -ForegroundColor White
    Write-Host "[2] Docker容器运行 (推荐生产环境)" -ForegroundColor White
    Write-Host "[3] 检查系统状态" -ForegroundColor White
    Write-Host "[4] 停止所有服务" -ForegroundColor White
    Write-Host "[0] 退出" -ForegroundColor White
    Write-Host ""
}

function Start-PythonMode {
    Write-Host "[信息] 启动Python模式..." -ForegroundColor Blue
    
    # 检查Python
    if (-not (Test-Command "python")) {
        Write-Host "[错误] 未检测到Python环境，请先安装Python 3.11+" -ForegroundColor Red
        Write-Host "下载地址: https://www.python.org/downloads/" -ForegroundColor Yellow
        Read-Host "按回车键继续"
        return
    }
    
    Write-Host "[信息] Python环境检测正常" -ForegroundColor Green
    
    # 检查虚拟环境
    if (Test-Path "venv\Scripts\Activate.ps1") {
        Write-Host "[信息] 激活虚拟环境..." -ForegroundColor Blue
        & "venv\Scripts\Activate.ps1"
    }
    
    # 检查依赖
    Write-Host "[信息] 检查依赖包..." -ForegroundColor Blue
    try {
        python -c "import fastapi, uvicorn, loguru" 2>$null
    }
    catch {
        Write-Host "[警告] 缺少依赖包，正在安装..." -ForegroundColor Yellow
        pip install -r requirements.txt
    }
    
    # 启动系统
    Write-Host ""
    Write-Host "[信息] 正在启动闲鱼自动回复系统..." -ForegroundColor Green
    Write-Host "[提示] 系统启动后请访问: http://localhost:8080" -ForegroundColor Yellow
    Write-Host "[提示] 按 Ctrl+C 可以停止系统" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        python Start.py
    }
    catch {
        Write-Host "[错误] 系统启动失败" -ForegroundColor Red
        Read-Host "按回车键继续"
    }
}

function Start-DockerMode {
    Write-Host "[信息] 启动Docker模式..." -ForegroundColor Blue
    
    # 检查Docker
    if (-not (Test-Command "docker")) {
        Write-Host "[错误] 未检测到Docker环境" -ForegroundColor Red
        Write-Host "请安装Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
        Read-Host "按回车键继续"
        return
    }
    
    # 检查Docker运行状态
    try {
        docker info 2>$null | Out-Null
    }
    catch {
        Write-Host "[错误] Docker未运行，请先启动Docker Desktop" -ForegroundColor Red
        Read-Host "按回车键继续"
        return
    }
    
    Write-Host "[信息] Docker环境检测正常" -ForegroundColor Green
    
    # 停止现有容器
    Write-Host "[信息] 停止现有容器..." -ForegroundColor Blue
    docker stop xianyu-auto-reply 2>$null | Out-Null
    docker rm xianyu-auto-reply 2>$null | Out-Null
    
    # 创建数据目录
    if (-not (Test-Path "data")) {
        New-Item -ItemType Directory -Name "data" | Out-Null
    }
    
    # 构建并启动
    if (Test-Path "Dockerfile") {
        Write-Host "[信息] 构建Docker镜像..." -ForegroundColor Blue
        docker build -t xianyu-auto-reply .
        
        Write-Host "[信息] 启动容器..." -ForegroundColor Blue
        docker run -d `
            -p 8080:8080 `
            -v "${PWD}\data:/app/data" `
            --name xianyu-auto-reply `
            --restart unless-stopped `
            xianyu-auto-reply
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[成功] 系统已启动！" -ForegroundColor Green
        Write-Host "[地址] http://localhost:8080" -ForegroundColor Yellow
        Write-Host ""
        
        # 等待服务启动
        Write-Host "[信息] 等待服务启动..." -ForegroundColor Blue
        Start-Sleep -Seconds 10
        
        # 打开浏览器
        Start-Process "http://localhost:8080"
        Write-Host "[完成] 浏览器已打开管理界面" -ForegroundColor Green
    }
    else {
        Write-Host "[错误] 容器启动失败" -ForegroundColor Red
    }
    
    Read-Host "按回车键继续"
}

function Check-SystemStatus {
    Write-Host "[信息] 检查系统状态..." -ForegroundColor Blue
    Write-Host ""
    
    # 检查端口
    Write-Host "=== 端口状态 ===" -ForegroundColor Cyan
    $port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
    if ($port8080) {
        Write-Host "[状态] 8080端口正在使用中" -ForegroundColor Green
    } else {
        Write-Host "[状态] 8080端口未被占用" -ForegroundColor Yellow
    }
    
    # 检查Docker容器
    Write-Host ""
    Write-Host "=== Docker容器状态 ===" -ForegroundColor Cyan
    $container = docker ps --filter "name=xianyu-auto-reply" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($container -and $container.Length -gt 1) {
        Write-Host "[状态] Docker容器运行中:" -ForegroundColor Green
        Write-Host $container
    } else {
        Write-Host "[状态] Docker容器未运行" -ForegroundColor Yellow
    }
    
    # 检查服务可用性
    Write-Host ""
    Write-Host "=== 服务可用性 ===" -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -TimeoutSec 5 -ErrorAction Stop
        Write-Host "[状态] 服务正常运行 (HTTP $($response.StatusCode))" -ForegroundColor Green
        Write-Host "[地址] http://localhost:8080" -ForegroundColor Yellow
    }
    catch {
        Write-Host "[状态] 服务不可访问" -ForegroundColor Red
    }
    
    Write-Host ""
    Read-Host "按回车键继续"
}

function Stop-AllServices {
    Write-Host "[信息] 停止所有服务..." -ForegroundColor Blue
    
    # 停止Docker容器
    docker stop xianyu-auto-reply 2>$null | Out-Null
    docker rm xianyu-auto-reply 2>$null | Out-Null
    
    # 停止Python进程
    Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object {
        $_.MainWindowTitle -like "*闲鱼*"
    } | Stop-Process -Force
    
    Write-Host "[完成] 所有服务已停止" -ForegroundColor Green
    Read-Host "按回车键继续"
}

# 主循环
do {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       闲鱼自动回复系统启动器" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Show-Menu
    $choice = Read-Host "请选择 (0-4)"
    
    switch ($choice) {
        "1" { Start-PythonMode }
        "2" { Start-DockerMode }
        "3" { Check-SystemStatus }
        "4" { Stop-AllServices }
        "0" { 
            Write-Host "再见！" -ForegroundColor Green
            break 
        }
        default { 
            Write-Host "无效选择，请重试" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($choice -ne "0")