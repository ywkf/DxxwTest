# UpdateSetting.ps1
# 右键 -> 使用 PowerShell 运行

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $scriptDir "resource\pipeline\setting.json"

if (-not (Test-Path $jsonPath)) {
    Write-Host "[错误] 未找到配置文件: $jsonPath" -ForegroundColor Red
    Write-Host "请确保脚本位于 MaaDxxw 根目录（与 resource 文件夹同级）" -ForegroundColor Yellow
    Read-Host "按回车键退出"
    exit 1
}

# 读取原始内容（UTF-8 无 BOM）
$originalContent = [System.IO.File]::ReadAllText($jsonPath, [System.Text.UTF8Encoding]::new($false))

# ---------- 1. 提取当前值 ----------
# 提取所有 "input_text": "xxx" 中的值
$inputTextMatches = [regex]::Matches($originalContent, '(?<="input_text":\s*")[^"]+')
if ($inputTextMatches.Count -ge 2) {
    $currentPhone = $inputTextMatches[0].Value   # 第一个是手机号
    $currentPwd   = $inputTextMatches[1].Value   # 第二个是密码
} else {
    $currentPhone = "未找到"
    $currentPwd   = "未找到"
}

# 提取 bat 路径
$batMatch = [regex]::Match($originalContent, '(?<="/c",\s*")[^"]+')
$currentBat = if ($batMatch.Success) { $batMatch.Value } else { "未找到" }

# 显示当前值
Write-Host "========== 当前配置 ==========" -ForegroundColor Cyan
Write-Host "[手机号] $currentPhone"
Write-Host "[密码]   $currentPwd"
Write-Host "[Bat路径] $currentBat"
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# ---------- 2. 获取新值 ----------
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

# ---------- 3. 直接字符串替换（保留格式）----------
$modifiedContent = $originalContent

# 替换手机号
if ($currentPhone -ne "未找到" -and $newPhone -ne $currentPhone) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentPhone), $newPhone
}

# 替换密码
if ($currentPwd -ne "未找到" -and $newPwd -ne $currentPwd) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentPwd), $newPwd
}

# 替换 bat 路径
if ($currentBat -ne "未找到" -and $newBatPath -ne $currentBat) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentBat), $newBatPath
}

# ---------- 4. 保存文件 ----------
try {
    [System.IO.File]::WriteAllText($jsonPath, $modifiedContent, [System.Text.UTF8Encoding]::new($false))
    Write-Host "[成功] 配置文件已更新（原始格式完全保留）" -ForegroundColor Green
} catch {
    Write-Host "[错误] 保存文件失败: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# ---------- 5. 显示修改结果 ----------
Write-Host ""
Write-Host "========== 修改后配置 ==========" -ForegroundColor Cyan
Write-Host "[手机号] $newPhone"
Write-Host "[密码]   $newPwd"
Write-Host "[Bat路径] $newBatPath"
Write-Host "=============================" -ForegroundColor Cyan

Write-Host ""
Write-Host "操作完成，按任意键退出..." -ForegroundColor Yellow
Read-Host > $null