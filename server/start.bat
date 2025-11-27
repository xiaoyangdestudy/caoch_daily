@echo off
chcp 65001 >nul
echo ========================================
echo Coach Daily Server - 快速启动
echo ========================================
echo.

cd /d "%~dp0"

echo [1/3] 检查依赖是否已安装...
if not exist "node_modules\" (
    echo ⚠️  依赖未安装，正在安装...
    call npm install
    if errorlevel 1 (
        echo ❌ 安装失败，请检查Node.js环境
        pause
        exit /b 1
    )
) else (
    echo ✓ 依赖已安装
)

echo.
echo [2/3] 检查环境配置...
if not exist ".env" (
    echo ⚠️  .env文件不存在，使用默认开发配置
)

echo.
echo [3/3] 启动开发服务器...
echo ========================================
echo 按 Ctrl+C 停止服务器
echo ========================================
echo.

npm run dev
