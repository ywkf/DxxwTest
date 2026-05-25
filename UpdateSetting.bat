@echo off
chcp 65001 >nul
setlocal

:: ====== 自动请求管理员权限 ======
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在请求管理员权限...
    PowerShell -Command "Start-Process '%~f0' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

:: 获取当前脚本所在目录（即 MaaDxxw 根目录）
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_PATH=%SCRIPT_DIR%UpdateSetting.ps1"

echo "正在尝试使用正确的参数执行脚本..."

:: 执行修正后的 PowerShell 脚本
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& { Set-Location '%SCRIPT_DIR%'; & '%SCRIPT_PATH%'; Read-Host '脚本执行完成，按回车键退出...' }"

:end
endlocal