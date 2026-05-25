# UpdateSetting.ps1 (最终修正版)
# 功能：修改 setting.json, interface.json, 视频循环处理.bat
# 用法：右键 -> 使用 PowerShell 运行

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $scriptDir "resource\pipeline\setting.json"
$interfacePath = Join-Path $scriptDir "interface.json"
$batPath = Join-Path $scriptDir "视频循环处理.bat"

# ========== 第一部分：处理 setting.json ==========
if (-not (Test-Path $jsonPath)) {
    Write-Host "[错误] 未找到配置文件: $jsonPath" -ForegroundColor Red
    Write-Host "请确保脚本位于 MaaDxxw 根目录（与 resource 文件夹同级）" -ForegroundColor Yellow
    Read-Host "按回车键退出"
    exit 1
}

$originalContent = [System.IO.File]::ReadAllText($jsonPath, [System.Text.UTF8Encoding]::new($false))

# --- 提取当前手机号、密码 ---
$inputTextMatches = [regex]::Matches($originalContent, '(?<="input_text":\s*")[^"]+')
if ($inputTextMatches.Count -ge 2) {
    $currentPhone = $inputTextMatches[0].Value
    $currentPwd   = $inputTextMatches[1].Value
} else {
    $currentPhone = "未找到"
    $currentPwd   = "未找到"
}

# --- 提取当前 bat 路径 ---
$batMatch = [regex]::Match($originalContent, '(?<="/c",\s*")[^"]+')
$currentBat = if ($batMatch.Success) { $batMatch.Value } else { "未找到" }

# --- 提取当前“已登录账号”的用户名 ---
$userNameMatch = [regex]::Match($originalContent, '"已登录账号"[\s\S]*?"expected"\s*:\s*\[\s*"([^"]+)"')
if ($userNameMatch.Success) {
    $currentUserName = $userNameMatch.Groups[1].Value
} else {
    $currentUserName = "未找到"
}

Write-Host "========== 当前配置 (setting.json) ==========" -ForegroundColor Cyan
Write-Host "[手机号]         $currentPhone"
Write-Host "[密码]           $currentPwd"
Write-Host "[已登录用户名]   $currentUserName"
Write-Host "[Bat路径]        $currentBat"
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. 修改手机号 ---
$newPhone = Read-Host "请输入新手机号（直接回车保留原值）"
if ([string]::IsNullOrWhiteSpace($newPhone)) {
    $newPhone = $currentPhone
    Write-Host "→ 未修改手机号" -ForegroundColor DarkGray
} else {
    Write-Host "→ 手机号已更新为: $newPhone" -ForegroundColor Green
}
Write-Host ""

# --- 2. 修改密码 ---
$newPwd = Read-Host "请输入新密码（直接回车保留原值）"
if ([string]::IsNullOrWhiteSpace($newPwd)) {
    $newPwd = $currentPwd
    Write-Host "→ 未修改密码" -ForegroundColor DarkGray
} else {
    Write-Host "→ 密码已更新" -ForegroundColor Green
}
Write-Host ""

# --- 3. 修改已登录用户名 ---
Write-Host "当前已登录用户名为: $currentUserName" -ForegroundColor DarkCyan
$newUserName = Read-Host "请输入新用户名（直接回车则设置为 '申请认证'）"
if ([string]::IsNullOrWhiteSpace($newUserName)) {
    $newUserName = "申请认证"
    Write-Host "→ 用户名已设置为 '申请认证'" -ForegroundColor Green
} else {
    Write-Host "→ 用户名已更新为: $newUserName" -ForegroundColor Green
}
Write-Host ""

# --- 4. 自动修正 Bat 路径 ---
$targetBat = Join-Path $scriptDir "视频循环处理.bat"
$newBatPath = $targetBat -replace '\\', '\\'
Write-Host "→ Bat 路径自动修正为: $targetBat" -ForegroundColor Green
Write-Host ""

# --- 替换操作 ---
$modifiedContent = $originalContent

# 手机号
if ($currentPhone -ne "未找到" -and $newPhone -ne $currentPhone) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentPhone), $newPhone
}
# 密码
if ($currentPwd -ne "未找到" -and $newPwd -ne $currentPwd) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentPwd), $newPwd
}
# 已登录用户名（仅替换 expected 中的第一个字符串）
if ($currentUserName -ne "未找到" -and $newUserName -ne $currentUserName) {
    $modifiedContent = $modifiedContent -replace '("已登录账号"[\s\S]*?"expected"\s*:\s*\[\s*")[^"]+"', ('${1}' + $newUserName + '"')
}
# Bat 路径
if ($currentBat -ne "未找到" -and $newBatPath -ne $currentBat) {
    $modifiedContent = $modifiedContent -replace [regex]::Escape($currentBat), $newBatPath
}

# 保存文件
try {
    [System.IO.File]::WriteAllText($jsonPath, $modifiedContent, [System.Text.UTF8Encoding]::new($false))
    Write-Host "[成功] setting.json 已更新（格式保留）" -ForegroundColor Green
} catch {
    Write-Host "[错误] 保存 setting.json 失败: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}
Write-Host ""

# ========== 第二部分：处理 interface.json ==========
if (-not (Test-Path $interfacePath)) {
    Write-Host "[警告] 未找到 interface.json 文件，跳过端口号修改: $interfacePath" -ForegroundColor Yellow
} else {
    $interfaceContent = [System.IO.File]::ReadAllText($interfacePath, [System.Text.UTF8Encoding]::new($false))

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

# ========== 第三部分：处理 视频循环处理.bat ==========
if (-not (Test-Path $batPath)) {
    Write-Host "[警告] 未找到 视频循环处理.bat 文件，跳过修改: $batPath" -ForegroundColor Yellow
} else {
    $batContent = [System.IO.File]::ReadAllText($batPath, [System.Text.UTF8Encoding]::new($false))

    # 提取当前素材库路径（folder1）
    $folder1Match = [regex]::Match($batContent, '(?<=set "folder1=)[^"]+')
    $currentFolder1 = if ($folder1Match.Success) { $folder1Match.Value } else { "未找到" }

    # 提取当前 MuMu图库路径（folder2）
    $folder2Match = [regex]::Match($batContent, '(?<=set "folder2=)[^"]+')
    $currentFolder2 = if ($folder2Match.Success) { $folder2Match.Value } else { "未找到" }

    # 提取当前处理数量：从注释中提取（最准确）
    $numMatch = [regex]::Match($batContent, '处理文件夹1的(\d+)个视频')
    if (-not $numMatch.Success) {
        $numMatch = [regex]::Match($batContent, '(?<=lss\s+)\d+')
    }
    if (-not $numMatch.Success) {
        $numMatch = [regex]::Match($batContent, '/(\d+)\s+个视频')
    }
    $currentNum = if ($numMatch.Success) { $numMatch.Groups[1].Value } else { "10" }

    Write-Host "========== 当前配置 (视频循环处理.bat) ==========" -ForegroundColor Cyan
    Write-Host "[素材库] $currentFolder1"
    Write-Host "[MuMu图库] $currentFolder2"
    Write-Host "[处理数量] $currentNum"
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host ""

    # 1. 新素材库路径
    Write-Host "请输入新的【素材库】路径（直接回车保留原值）:" -ForegroundColor Yellow
    $newFolder1 = Read-Host
    if ([string]::IsNullOrWhiteSpace($newFolder1)) {
        $newFolder1 = $currentFolder1
        Write-Host "→ 未修改素材库" -ForegroundColor DarkGray
    } else {
        Write-Host "→ 素材库已更新为: $newFolder1" -ForegroundColor Green
    }
    Write-Host ""

    # 2. 智能搜索所有 MuMu Movies 文件夹
    Write-Host "[搜索] 正在查找所有 MuMu 共享文件夹中的 Movies 目录..." -ForegroundColor Cyan

    # 收集候选路径（去重、仅保留存在的目录）
    $candidates = [System.Collections.ArrayList]@()

    # 如果当前 bat 中已有路径且该路径存在，先加入候选（方便保留原值）
    if ($currentFolder2 -ne "未找到" -and (Test-Path $currentFolder2)) {
        [void]$candidates.Add($currentFolder2)
    }

    # 获取真实的“文档”文件夹路径
    $realDocs = [Environment]::GetFolderPath('MyDocuments')
    # 获取默认的 C:\Users\用户名\Documents 路径
    $defaultDocs = Join-Path $env:USERPROFILE "Documents"

    # 检查多种可能的子路径组合
    $basePaths = @($realDocs, $defaultDocs) | Select-Object -Unique
    $subFolderNames = @("MuMu共享文件夹\Movies", "MuMu 共享文件夹\Movies", "MuMu共享文件夹\movies", "MuMu 共享文件夹\movies")

    foreach ($base in $basePaths) {
        foreach ($sub in $subFolderNames) {
            $testPath = Join-Path $base $sub
            if (Test-Path $testPath) {
                # 避免重复
                if ($candidates -notcontains $testPath) {
                    [void]$candidates.Add($testPath)
                }
            }
        }
    }

    # 如果没有找到任何路径，回退到手动输入
    if ($candidates.Count -eq 0) {
        Write-Host "[警告] 未找到任何 MuMu 共享文件夹中的 Movies 目录。" -ForegroundColor Yellow
        Write-Host "请手动输入【MuMu图库】路径（直接回车保留原值）:" -ForegroundColor Yellow
        $newFolder2 = Read-Host
        if ([string]::IsNullOrWhiteSpace($newFolder2)) {
            $newFolder2 = $currentFolder2
            Write-Host "→ 未修改 MuMu图库" -ForegroundColor DarkGray
        } else {
            Write-Host "→ MuMu图库 已更新为: $newFolder2" -ForegroundColor Green
        }
    }
    else {
        # 展示候选菜单
        Write-Host "`n找到以下 MuMu Movies 文件夹：" -ForegroundColor Green
        for ($i = 0; $i -lt $candidates.Count; $i++) {
            Write-Host "  [$($i+1)] $($candidates[$i])"
        }
        Write-Host "  [0] 手动输入其他路径"
        Write-Host ""

        do {
            $choice = Read-Host "请输入序号选择（直接回车使用第 1 个）"
            if ([string]::IsNullOrWhiteSpace($choice)) {
                $newFolder2 = $candidates[0]
                Write-Host "→ 已选择第 1 个路径" -ForegroundColor Green
                break
            }
            elseif ($choice -match '^\d+$') {
                $num = [int]$choice
                if ($num -eq 0) {
                    # 手动输入
                    $manual = Read-Host "请输入新的【MuMu图库】路径"
                    if ([string]::IsNullOrWhiteSpace($manual)) {
                        Write-Host "[错误] 路径不能为空，请重新选择。" -ForegroundColor Red
                        continue
                    }
                    $newFolder2 = $manual
                    Write-Host "→ MuMu图库 已设置为手动输入的路径" -ForegroundColor Green
                    break
                }
                elseif ($num -ge 1 -and $num -le $candidates.Count) {
                    $newFolder2 = $candidates[$num - 1]
                    Write-Host "→ 已选择第 $num 个路径" -ForegroundColor Green
                    break
                }
                else {
                    Write-Host "[错误] 无效序号，请重新输入。" -ForegroundColor Red
                }
            }
            else {
                Write-Host "[错误] 请输入数字序号。" -ForegroundColor Red
            }
        } while ($true)
    }
    Write-Host ""

    # 3. 新处理数量
    Write-Host "请输入新的【处理视频数量】（直接回车保留原值）:" -ForegroundColor Yellow
    $newNum = Read-Host
    if ([string]::IsNullOrWhiteSpace($newNum)) {
        $newNum = $currentNum
        Write-Host "→ 未修改处理数量" -ForegroundColor DarkGray
    } else {
        if ($newNum -match '^\d+$') {
            Write-Host "→ 处理数量已更新为: $newNum" -ForegroundColor Green
        } else {
            Write-Host "[错误] 输入不是有效数字，保留原值 $currentNum" -ForegroundColor Red
            $newNum = $currentNum
        }
    }
    Write-Host ""

    # 开始替换 bat 内容
    $newBatContent = $batContent

    # 替换路径
    if ($currentFolder1 -ne "未找到" -and $newFolder1 -ne $currentFolder1) {
        $newBatContent = $newBatContent -replace [regex]::Escape($currentFolder1), $newFolder1
    }
    if ($currentFolder2 -ne "未找到" -and $newFolder2 -ne $currentFolder2) {
        $newBatContent = $newBatContent -replace [regex]::Escape($currentFolder2), $newFolder2
    }

    # ===== 替换数量（已修正）=====
    if ($currentNum -ne "未找到" -and $newNum -ne $currentNum) {
        $newBatContent = $newBatContent -replace '(处理文件夹1的)\d+(个视频)', ('${1}' + $newNum + '${2}')
        $newBatContent = $newBatContent -replace '(lss\s+)\d+', ('${1}' + $newNum)
        $newBatContent = $newBatContent -replace '(复制)\d+(个视频)', ('${1}' + $newNum + '${2}')
        $newBatContent = $newBatContent -replace '(将)\d+(个视频移动到)', ('${1}' + $newNum + '${2}')
        $newBatContent = $newBatContent -replace '(%count1_moved%/)\d+( 个视频)', ('${1}' + $newNum + '${2}')
    }

    # 保存 bat 文件
    try {
        [System.IO.File]::WriteAllText($batPath, $newBatContent, [System.Text.UTF8Encoding]::new($false))
        Write-Host "[成功] 视频循环处理.bat 已更新（格式保留）" -ForegroundColor Green
    } catch {
        Write-Host "[错误] 保存 视频循环处理.bat 失败: $($_.Exception.Message)" -ForegroundColor Red
        Read-Host "按回车键退出"
        exit 1
    }
}
Write-Host ""

# ========== 第四部分：搜索 MuMu 模拟器并添加到系统环境变量 PATH ==========
Write-Host "========== 搜索 MuMu 模拟器根目录并配置 ADB ==========" -ForegroundColor Cyan

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[提示] 未以管理员身份运行。若要修改系统级PATH，请右键以管理员身份运行此脚本。" -ForegroundColor Yellow
    Write-Host "        当前将仅修改“用户级”PATH。" -ForegroundColor DarkGray
}

# ---------- 显示当前 PATH 中已存在的 MuMu 相关路径 ----------
Write-Host "[当前 PATH] 已存在的 MuMu/ADB 相关路径：" -ForegroundColor DarkCyan
$targetEnvPreview = if ($isAdmin) { 'Machine' } else { 'User' }
$currentPathPreview = [Environment]::GetEnvironmentVariable('Path', $targetEnvPreview)
if ($currentPathPreview) {
    $paths = $currentPathPreview -split ';' | Where-Object { $_ -match 'MuMu|adb|Netease' }
    if ($paths) {
        $paths | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    } else {
        Write-Host "  （未找到相关路径）" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  （当前 PATH 为空）" -ForegroundColor DarkGray
}
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# ---------- 自动发现所有 MuMu* 安装目录（递归深度2）----------
Write-Host "[扫描] 正在搜索所有磁盘上的 MuMu* 安装目录（含二级子目录）..." -ForegroundColor Cyan

$searchRoots = [System.Collections.ArrayList]@()
foreach ($drive in (Get-PSDrive -PSProvider FileSystem).Root) {
    $progPaths = @(
        Join-Path $drive "Program Files"
        Join-Path $drive "Program Files (x86)"
    )
    foreach ($prog in $progPaths) {
        if (Test-Path $prog) {
            if ($searchRoots -notcontains $prog) {
                [void]$searchRoots.Add($prog)
            }
        }
    }
}

$mumuDirs = [System.Collections.ArrayList]@()
foreach ($root in $searchRoots) {
    $found = Get-ChildItem -Path $root -Directory -Depth 2 -Filter "MuMu*" -ErrorAction SilentlyContinue
    foreach ($d in $found) {
        $fullPath = $d.FullName.TrimEnd('\')
        if ($mumuDirs -notcontains $fullPath) {
            [void]$mumuDirs.Add($fullPath)
        }
    }
}

# 不再单独显示所有 MuMu 目录，直接搜索 adb.exe
$adbCandidates = [System.Collections.ArrayList]@()
if ($mumuDirs.Count -eq 0) {
    Write-Host "[警告] 未找到任何 MuMu 安装目录。" -ForegroundColor Yellow
} else {
    foreach ($mumuDir in $mumuDirs) {
        $possibleSubDirs = @(
            "nx_main",
            "emulator\nemu\vmonitor\bin",
            "shell",
            "vmonitor\bin",
            "bin",
            "."
        )
        foreach ($sub in $possibleSubDirs) {
            $testPath = if ($sub -eq '.') { $mumuDir } else { Join-Path $mumuDir $sub }
            if (Test-Path $testPath) {
                $adbExe = Join-Path $testPath "adb.exe"
                if (Test-Path $adbExe) {
                    if ($adbCandidates -notcontains $testPath) {
                        [void]$adbCandidates.Add($testPath)
                    }
                }
            }
        }
    }
}

# ---------- 让用户选择 adb 路径 ----------
Write-Host ""
$selectedPath = $null

if ($adbCandidates.Count -gt 0) {
    Write-Host "找到以下包含 adb.exe 的目录：" -ForegroundColor Green
    for ($i=0; $i -lt $adbCandidates.Count; $i++) {
        Write-Host "  [$($i+1)] $($adbCandidates[$i])"
    }
    Write-Host "  [0] 手动输入其他路径"
    Write-Host "  [S] 跳过添加 PATH"
    Write-Host ""

    do {
        $choice = Read-Host "请输入序号选择（直接回车选择第 1 个）"
        if ([string]::IsNullOrWhiteSpace($choice)) {
            $selectedPath = $adbCandidates[0]
            Write-Host "→ 已选择第 1 个路径" -ForegroundColor Green
            break
        } elseif ($choice -eq '0') {
            $manual = Read-Host "请输入包含 adb.exe 的完整路径"
            if ([string]::IsNullOrWhiteSpace($manual)) {
                Write-Host "[错误] 路径不能为空，请重新选择。" -ForegroundColor Red
                continue
            }
            $manual = $manual.TrimEnd('\')
            if (-not (Test-Path (Join-Path $manual "adb.exe"))) {
                Write-Host "[警告] 该路径下未找到 adb.exe，是否仍要使用？(Y/N)" -ForegroundColor Yellow
                $confirm = Read-Host
                if ($confirm -ne 'Y' -and $confirm -ne 'y') {
                    continue
                }
            }
            $selectedPath = $manual
            Write-Host "→ 已手动输入路径" -ForegroundColor Green
            break
        } elseif ($choice -eq 'S' -or $choice -eq 's') {
            Write-Host "→ 跳过添加 PATH。" -ForegroundColor DarkGray
            break
        } elseif ($choice -match '^\d+$') {
            $num = [int]$choice
            if ($num -ge 1 -and $num -le $adbCandidates.Count) {
                $selectedPath = $adbCandidates[$num-1]
                Write-Host "→ 已选择第 $num 个路径" -ForegroundColor Green
                break
            } else {
                Write-Host "[错误] 无效序号，请重新输入。" -ForegroundColor Red
            }
        } else {
            Write-Host "[错误] 请输入数字序号或 S。" -ForegroundColor Red
        }
    } while ($true)
} else {
    Write-Host "[提示] 未自动发现包含 adb.exe 的路径。" -ForegroundColor Yellow
    Write-Host "你可以手动输入，或者输入 S 跳过。" -ForegroundColor Yellow
    do {
        $manual = Read-Host "请输入包含 adb.exe 的路径（输入 S 跳过）"
        if ($manual -eq 'S' -or $manual -eq 's') {
            Write-Host "→ 跳过添加 PATH。" -ForegroundColor DarkGray
            break
        }
        if ([string]::IsNullOrWhiteSpace($manual)) {
            Write-Host "[错误] 路径不能为空。" -ForegroundColor Red
            continue
        }
        $manual = $manual.TrimEnd('\')
        if (Test-Path (Join-Path $manual "adb.exe")) {
            $selectedPath = $manual
            Write-Host "→ 已确认路径有效" -ForegroundColor Green
            break
        } else {
            Write-Host "[警告] 指定路径下未找到 adb.exe，请重新输入。" -ForegroundColor Yellow
        }
    } while ($true)
}

# ---------- 添加 PATH（带确认）----------
if ($selectedPath) {
    $targetEnv = if ($isAdmin) { 'Machine' } else { 'User' }
    $currentPath = [Environment]::GetEnvironmentVariable('Path', $targetEnv)
    if ($currentPath -like "*$selectedPath*") {
        Write-Host "[信息] 路径已存在于 $targetEnv PATH 中，无需重复添加。" -ForegroundColor DarkGray
    } else {
        Write-Host "即将把以下路径添加到 $targetEnv 环境变量 PATH：" -ForegroundColor Cyan
        Write-Host "  $selectedPath" -ForegroundColor Yellow
        $confirmAdd = Read-Host "确认添加吗？(Y/N)"
        if ($confirmAdd -eq 'Y' -or $confirmAdd -eq 'y') {
            $newPath = "$currentPath;$selectedPath"
            [Environment]::SetEnvironmentVariable('Path', $newPath, $targetEnv)
            Write-Host "[成功] 已添加。新打开的终端窗口即可直接使用 adb 命令。" -ForegroundColor Green
        } else {
            Write-Host "[取消] 未修改 PATH。" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host "[操作] 未添加任何路径到 PATH。" -ForegroundColor DarkGray
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# ========== 最终汇总 ==========
Write-Host "========== 最终修改汇总 ==========" -ForegroundColor Cyan
Write-Host "[手机号] $newPhone"
Write-Host "[密码]   $newPwd"
Write-Host "[已登录用户名] $newUserName" 
Write-Host "[Bat路径] $newBatPath"
if (Test-Path $interfacePath) { Write-Host "[端口号] $newPort" }
if (Test-Path $batPath) {
    Write-Host "[素材库] $newFolder1"
    Write-Host "[MuMu图库] $newFolder2"
    Write-Host "[处理数量] $newNum"
}
Write-Host ""
Write-Host "========== 当前 PATH 中的 MuMu/ADB 相关路径 ==========" -ForegroundColor DarkCyan
$finalTargetEnv = if ($isAdmin) { 'Machine' } else { 'User' }
$finalPath = [Environment]::GetEnvironmentVariable('Path', $finalTargetEnv)
if ($finalPath) {
    $finalPaths = $finalPath -split ';' | Where-Object { $_ -match 'MuMu|adb|Netease' }
    if ($finalPaths) {
        $finalPaths | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    } else {
        Write-Host "  （未找到相关路径）" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  （PATH 为空）" -ForegroundColor DarkGray
}
Write-Host "================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "所有操作完成，按任意键退出..." -ForegroundColor Yellow
Read-Host > $null