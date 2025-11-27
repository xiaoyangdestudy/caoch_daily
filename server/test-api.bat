@echo off
chcp 65001 >nul
echo ========================================
echo Coach Daily API - 测试脚本
echo ========================================
echo.

set API_URL=http://localhost:3000

echo 测试API地址: %API_URL%
echo.
echo [1/5] 测试健康检查...
curl -s %API_URL%/health
echo.

echo.
echo [2/5] 测试注册用户...
set USERNAME=testuser_%RANDOM%
set PASSWORD=test123456
echo 用户名: %USERNAME%
echo 密码: %PASSWORD%

for /f "tokens=*" %%i in ('curl -s -X POST %API_URL%/api/auth/register -H "Content-Type: application/json" -d "{\"username\":\"%USERNAME%\",\"password\":\"%PASSWORD%\"}"') do set RESPONSE=%%i
echo %RESPONSE%
echo.

REM 提取token（简单方式，实际项目可能需要更复杂的解析）
echo.
echo [3/5] 测试登录...
for /f "tokens=*" %%i in ('curl -s -X POST %API_URL%/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"%USERNAME%\",\"password\":\"%PASSWORD%\"}"') do set LOGIN_RESPONSE=%%i
echo %LOGIN_RESPONSE%
echo.

echo.
echo [4/5] 测试API根路径...
curl -s %API_URL%/
echo.

echo.
echo [5/5] 测试完成！
echo ========================================
echo.
echo 提示：
echo   - 如果看到JSON响应，说明API正常工作
echo   - 可以使用Postman或Thunder Client进行更详细的测试
echo   - 查看server\README.md了解所有API端点
echo.
pause
