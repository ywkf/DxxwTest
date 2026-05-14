@echo off
chcp 65001 >nul
setlocal

:: 获取当前脚本所在目录（即 MaaDxxw 根目录）
set "SCRIPT_DIR=%~dp0"

:: 检查路径中是否有空格，如果路径本身包含空格，直接调用可能会被拆分。
:: 所以我们将完整路径作为参数传递给 PowerShell。
set "SCRIPT_PATH=%SCRIPT_DIR%UpdateSetting.ps1"

echo "正在尝试使用正确的参数执行脚本..."

:: 执行修正后的 PowerShell 脚本
:: 这样做是为了确保工作目录正确，并且执行策略被绕过
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& { Set-Location '%SCRIPT_DIR%'; & '%SCRIPT_PATH%'; Read-Host '脚本执行完成，按回车键退出...' }"

:end
endlocal