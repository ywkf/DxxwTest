# UpdateSetting.ps1
# 功能：修改 setting.json 中的手机号、密码、bat路径，以及 interface.json 中的端口号
# 用法：右键 -> 使用 PowerShell 运行

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $scriptDir "resource\pipeline\setting.json"
$interfacePath = Join-Path $scriptDir "interface.json"

# ========== 第一部分：处理 setting.json ==========
if (-not (Test-Path $jsonPath)) {
    Write-Host "[错误] 未找到配置文件: $jsonPath" -ForegroundColor Red
    Write-Host "请确保脚本位于 MaaDxxw 根目录（与 resource 文件夹同级）" -ForegroundColor Yellow
    Read-Host "按回车键退出"
    exit 1
}

$originalContent = [System.IO.File]::ReadAllText($jsonPath, [System.Text.UTF8Encoding]::new($false))

# 提取当前值
$inputTextMatches = [regex]::Matches($originalContent, '(?<="input_text":\s*")[^"]+')
if ($inputTextMatches.Count -ge 2) {
    $currentPhone = $inputTextMatches[0].Value
    $currentPwd   = $inputTextMatches[1].Value
} else {
    $currentPhone = "未找到"
    $currentPwd   = "未找到"
}
$batMatch = [regex]::Match($originalContent, '(?<="/c",\s*")[^"]+')
$currentBat = if ($batMatch.Success) { $batMatch.Value } else { "未找到" }

Write-Host "========== 当前配置 (setting.json) ==========" -ForegroundColor Cyan
Write-Host "[手机号] $currentPhone"
Write-Host "[密码]   $currentPwd"
Write-Host "[Bat路径] $currentBat"
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 获取新值
$newPhone = Read-Host "请输入新手机号（直接回车保留原值）"
if ([string]::IsNullOrWhiteSpace($newPhone)) {
    $newPhone = $currentPhone
    Write-Host "→ 未修改手机号" -ForegroundColor DarkGray
} else {
    Write-Host "→ 手机号已更新为: $newPhone" -ForegroundColor Green
}
Write-Host ""

$newPwd = Read-Host "请输入新密码（直接回车保留原值）"
if ([string]::IsNullOrWhiteSpace($newPwd)) {
    $newPwd = $currentPwd
    Write-Host "→ 未修改密码" -ForegroundColor DarkGray
} else {
    Write-Host "→ 密码已更新" -ForegroundColor Green
}
Write-Host ""

$targetBat = Join-Path $scriptDir "视频循环处理.bat"
$newBatPath = $targetBat -replace '\\', '\\'
Write-Host "→ Bat 路径自动修正为: $targetBat" -ForegroundColor Green
Write-Host ""

# 执行替换（保留格式）
$modifiedContent = $originalContent
if ($currentPhone -ne "未找到" -and $newPhone -ne $currentPhone) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentPhone), $newPhone
}
if ($currentPwd -ne "未找到" -and $newPwd -ne $currentPwd) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentPwd), $newPwd
}
if ($currentBat -ne "未找到" -and $newBatPath -ne $currentBat) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentBat), $newBatPath
}

try {
    [System.IO.File]::WriteAllText($jsonPath, $modifiedContent, [System.Text.UTF8Encoding]::new($false))
    Write-Host "[成功] setting.json 已更新（格式保留）" -ForegroundColor Green
} catch {
    Write-Host "[错误] 保存 setting.json 失败: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

Write-Host ""

# ========== 第二部分：处理 interface.json 中的端口号 ==========
if (-not (Test-Path $interfacePath)) {
    Write-Host "[警告] 未找到 interface.json 文件，跳过端口号修改: $interfacePath" -ForegroundColor Yellow
} else {
    $interfaceContent = [System.IO.File]::ReadAllText($interfacePath, [System.Text.UTF8Encoding]::new($false))

    # 提取当前端口号（匹配 "name": "端口号" 后面的 "default": "xxxx"）
    $portPattern = '(?<="name":\s*"端口号",[\s\S]*?"default":\s*")[^"]+'
    $portMatch = [regex]::Match($interfaceContent, $portPattern)
    if ($portMatch.Success) {
        $currentPort = $portMatch.Value
    } else {
        $currentPort = "未找到"
    }

    Write-Host "========== 当前配置 (interface.json) ==========" -ForegroundColor Cyan
    Write-Host "[端口号] $currentPort"
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""

    $newPort = Read-Host "请输入新端口号（直接回车保留原值）"
    if ([string]::IsNullOrWhiteSpace($newPort)) {
        $newPort = $currentPort
        Write-Host "→ 未修改端口号" -ForegroundColor DarkGray
    } else {
        Write-Host "→ 端口号已更新为: $newPort" -ForegroundColor Green
    }
    Write-Host ""

    if ($currentPort -ne "未找到" -and $newPort -ne $currentPort) {
        # 替换端口号（精确替换，保留格式）
        $newInterfaceContent = $interfaceContent -replace [regex]::Escape($currentPort), $newPort
        try {
            [System.IO.File]::WriteAllText($interfacePath, $newInterfaceContent, [System.Text.UTF8Encoding]::new($false))
            Write-Host "[成功] interface.json 已更新（端口号已修改）" -ForegroundColor Green
        } catch {
            Write-Host "[错误] 保存 interface.json 失败: $($_.Exception.Message)" -ForegroundColor Red
            Read-Host "按回车键退出"
            exit 1
        }
    } else {
        Write-Host "[信息] 端口号未发生变化，无需修改" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "========== 最终修改汇总 ==========" -ForegroundColor Cyan
Write-Host "[手机号] $newPhone"
Write-Host "[密码]   $newPwd"
Write-Host "[Bat路径] $newBatPath"
if (Test-Path $interfacePath) { Write-Host "[端口号] $newPort" }
Write-Host "================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "所有操作完成，按任意键退出..." -ForegroundColor Yellow
Read-Host > $null