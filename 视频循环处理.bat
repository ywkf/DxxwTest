@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: =============== 设置所有文件夹路径 ===============
set "folder1=D:\edge download\视频批量剪辑大师\保存视频\圈子素材"			:: 源1	
set "folder2=E:\Richard\Documents\MuMu共享文件夹\圈子作品1"				:: 输出1	
set "folder3=%folder1%\已处理视频"										:: 备份1	
set "folder4=D:\edge download\视频批量剪辑大师\保存视频\舒压首选，柔和笛子伴奏+鸟鸣虫叫，简直不要太好听"				:: 源2
set "folder5=E:\Richard\Documents\MuMu共享文件夹\圈子作品2"				:: 输出2	
set "folder4_backup=%folder4%\已处理视频"								:: 备份2	

:: =============== 第一部分：处理文件夹1的10个视频 ===============

:: 检查文件夹3是否存在，不存在则创建
if not exist "%folder3%" (
    mkdir "%folder3%"
    echo [初始化] 已创建文件夹3: "%folder3%"
)

:: --- 循环检测：若 folder1 为空，将备份视频移回 folder1 ---
set "hasVideo=0"
for /f %%i in ('dir /b /a-d "%folder1%\*" 2^>nul ^| findstr /i "\.mp4$ \.avi$ \.mkv$ \.mov$ \.wmv$ \.flv$"') do set "hasVideo=1"
if !hasVideo!==0 (
    echo [循环] folder1 中没有视频，尝试从备份文件夹恢复...
    if exist "%folder3%\*" (
        move "%folder3%\*" "%folder1%\" >nul 2>nul
        if !errorlevel!==0 (
            echo [循环] 已将备份视频全部移回 folder1
        ) else (
            echo [错误] 移回视频时出现问题，请检查。
            pause
            exit /b 1
        )
    ) else (
        echo [循环] 备份文件夹也为空，无视频可恢复。操作终止。
        pause
        exit /b
    )
)

:: 清空文件夹2
echo [阶段1] 正在清空文件夹2...
if exist "%folder2%\*" (
    del /q /f "%folder2%\*" 2>nul
    echo [阶段1] 文件夹2已清空
)

:: 从文件夹1复制10个视频到文件夹2
echo [阶段1] 正在从文件夹1复制10个视频到文件夹2...
set count1=0
for /f "delims=" %%f in ('dir /b /a-d "%folder1%\*" 2^>nul ^| findstr /i "\.mp4$ \.avi$ \.mkv$ \.mov$ \.wmv$ \.flv$"') do (
    if !count1! lss 10 (
        copy "%folder1%\%%f" "%folder2%\" >nul
        set /a count1+=1
        echo [复制1-!count1!] "%%f"
    )
)

:: 将文件夹1的这10个视频移动到文件夹3
echo [阶段1] 正在将10个视频移动到文件夹3...
set count1_moved=0
for /f "delims=" %%f in ('dir /b /a-d "%folder1%\*" 2^>nul ^| findstr /i "\.mp4$ \.avi$ \.mkv$ \.mov$ \.wmv$ \.flv$"') do (
    if !count1_moved! lss 10 (
        move "%folder1%\%%f" "%folder3%\" >nul
        set /a count1_moved+=1
        echo [移动1-!count1_moved!] "%%f"
    )
)

:: =============== 最终统计 ===============
echo.
echo [操作统计]
echo 文件夹1处理: %count1_moved%/10 个视频
echo 文件夹2现有: %count1% 个视频
echo 备份文件夹现有: %count1_moved% 个视频