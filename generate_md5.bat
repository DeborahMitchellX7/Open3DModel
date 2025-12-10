@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo 3D Model MD5 Generator
echo ========================================
echo.

:: Set output files
set OUTPUT_FILE=MD5.md
set TEMP_FILE=temp_md5.txt
set CURRENT_DIR=%cd%

:: Clear or create output file
(echo.) > "%OUTPUT_FILE%"
:: Format date and time, remove day of week
for /f "tokens=2-4 delims=/ " %%a in ("%date%") do set "fdate=%%a/%%b/%%c"
(echo Generated: %fdate% %time%) >> "%OUTPUT_FILE%"
(echo.) >> "%OUTPUT_FILE%"
(echo ^| File Path ^| MD5 Hash ^|) >> "%OUTPUT_FILE%"
(echo ^| --------- ^| -------- ^|) >> "%OUTPUT_FILE%"

:: Counter
set /a COUNT=0

echo Scanning files...
echo.

:: Scan .fbx files
for /r %%f in (*.fbx) do (
    set "filepath=%%f"
    echo !filepath! | findstr /i "\.git" >nul
    if errorlevel 1 (
        set "relpath=%%f"
        set "relpath=!relpath:%CURRENT_DIR%\=!"
        echo Processing: !relpath!
        set "md5="
        certutil -hashfile "%%f" MD5 | findstr /v ":" | findstr /v "CertUtil" > "%TEMP_FILE%"
        set /p md5=<"%TEMP_FILE%"
        if defined md5 set "md5=!md5: =!"
        (echo ^| !relpath! ^| !md5! ^|) >> "%OUTPUT_FILE%"
        set /a COUNT+=1
    )
)

:: Scan .glb files
for /r %%f in (*.glb) do (
    set "filepath=%%f"
    echo !filepath! | findstr /i "\.git" >nul
    if errorlevel 1 (
        set "relpath=%%f"
        set "relpath=!relpath:%CURRENT_DIR%\=!"
        echo Processing: !relpath!
        set "md5="
        certutil -hashfile "%%f" MD5 | findstr /v ":" | findstr /v "CertUtil" > "%TEMP_FILE%"
        set /p md5=<"%TEMP_FILE%"
        if defined md5 set "md5=!md5: =!"
        (echo ^| !relpath! ^| !md5! ^|) >> "%OUTPUT_FILE%"
        set /a COUNT+=1
    )
)

:: Scan .obj files
for /r %%f in (*.obj) do (
    set "filepath=%%f"
    echo !filepath! | findstr /i "\.git" >nul
    if errorlevel 1 (
        set "relpath=%%f"
        set "relpath=!relpath:%CURRENT_DIR%\=!"
        echo Processing: !relpath!
        set "md5="
        certutil -hashfile "%%f" MD5 | findstr /v ":" | findstr /v "CertUtil" > "%TEMP_FILE%"
        set /p md5=<"%TEMP_FILE%"
        if defined md5 set "md5=!md5: =!"
        (echo ^| !relpath! ^| !md5! ^|) >> "%OUTPUT_FILE%"
        set /a COUNT+=1
    )
)

:: Scan .usdz files
for /r %%f in (*.usdz) do (
    set "filepath=%%f"
    echo !filepath! | findstr /i "\.git" >nul
    if errorlevel 1 (
        set "relpath=%%f"
        set "relpath=!relpath:%CURRENT_DIR%\=!"
        echo Processing: !relpath!
        set "md5="
        certutil -hashfile "%%f" MD5 | findstr /v ":" | findstr /v "CertUtil" > "%TEMP_FILE%"
        set /p md5=<"%TEMP_FILE%"
        if defined md5 set "md5=!md5: =!"
        (echo ^| !relpath! ^| !md5! ^|) >> "%OUTPUT_FILE%"
        set /a COUNT+=1
    )
)

:: ========================================
:: Start calculating directory MD5
:: ========================================

echo.
echo Calculating directory MD5...
echo.

set TEMP_CONCAT=temp_concat.txt
set TEMP_DIRS=temp_dirs.txt
set /a DIR_COUNT=0

:: Add directory MD5 header
(echo.) >> "%OUTPUT_FILE%"
(echo ## Directory MD5) >> "%OUTPUT_FILE%"
(echo.) >> "%OUTPUT_FILE%"
(echo ^| Directory ^| Files ^| MD5 Hash ^|) >> "%OUTPUT_FILE%"
(echo ^| --------- ^| ----- ^| -------- ^|) >> "%OUTPUT_FILE%"

:: Collect all directories containing 3D model files
if exist "%TEMP_DIRS%" del "%TEMP_DIRS%"
set TEMP_RELDIRS=temp_reldirs.txt
if exist "%TEMP_RELDIRS%" del "%TEMP_RELDIRS%"

for /r %%f in (*.fbx *.glb *.obj *.usdz) do (
    set "filepath=%%f"
    echo !filepath! | findstr /i "\.git" >nul
    if errorlevel 1 (
        set "dirpath=%%~dpf"
        set "relpath=%%~dpf"
        set "relpath=!relpath:%CURRENT_DIR%\=!"
        echo !dirpath! >> "%TEMP_DIRS%"
        echo !relpath! >> "%TEMP_RELDIRS%"
    )
)

:: Remove duplicate directories
if exist "%TEMP_DIRS%" (
    sort "%TEMP_DIRS%" > "%TEMP_DIRS%.sorted"
    sort "%TEMP_RELDIRS%" > "%TEMP_RELDIRS%.sorted"
    type nul > "%TEMP_DIRS%"
    type nul > "%TEMP_RELDIRS%"
    
    set "last_dir="
    for /f "usebackq delims=" %%d in ("%TEMP_DIRS%.sorted") do (
        set "current_dir=%%d"
        if "!current_dir!" neq "!last_dir!" (
            echo !current_dir! >> "%TEMP_DIRS%"
            set "last_dir=!current_dir!"
        )
    )
    
    set "last_dir="
    for /f "usebackq delims=" %%d in ("%TEMP_RELDIRS%.sorted") do (
        set "current_dir=%%d"
        if "!current_dir!" neq "!last_dir!" (
            echo !current_dir! >> "%TEMP_RELDIRS%"
            set "last_dir=!current_dir!"
        )
    )
    
    del "%TEMP_DIRS%.sorted"
    del "%TEMP_RELDIRS%.sorted"
)

:: Process each directory - read both absolute and relative paths
if exist "%TEMP_DIRS%" (
    set /a line_num=0
    for /f "usebackq delims=" %%d in ("%TEMP_DIRS%") do (
        set /a line_num+=1
        set "dirpath=%%d"
        
        :: Read corresponding relative path
        set /a rel_line=0
        for /f "usebackq delims=" %%r in ("%TEMP_RELDIRS%") do (
            set /a rel_line+=1
            if !rel_line! equ !line_num! (
                set "reldir=%%r"
            )
        )
        
        :: Remove trailing spaces from path
        for /l %%i in (1,1,10) do if "!dirpath:~-1!"==" " set "dirpath=!dirpath:~0,-1!"
        :: Ensure path ends with backslash
        if not "!dirpath:~-1!"=="\" set "dirpath=!dirpath!\"
        
        echo Processing directory: !reldir!
        
        :: Clear temporary concatenation file
        type nul > "%TEMP_CONCAT%"
        
        :: Collect MD5 of all files in directory (sorted by filename)
        set /a FILE_COUNT=0
        for /f "delims=" %%f in ('dir /b /a-d "!dirpath!" 2^>nul ^| sort') do (
            set "filename=%%f"
            set "skip=0"
            
            :: Skip temporary files and output file
            if "!filename!"=="%TEMP_FILE%" set "skip=1"
            if "!filename!"=="%TEMP_CONCAT%" set "skip=1"
            if "!filename!"=="%TEMP_DIRS%" set "skip=1"
            if "!filename!"=="%TEMP_RELDIRS%" set "skip=1"
            if "!filename!"=="temp_dirs.txt.sorted" set "skip=1"
            if "!filename!"=="temp_reldirs.txt.sorted" set "skip=1"
            if "!filename!"=="temp_line.txt" set "skip=1"
            if "!filename!"=="%OUTPUT_FILE%" set "skip=1"
            if "!filename!"=="desktop.ini" set "skip=1"
            if "!filename!"==".DS_Store" set "skip=1"
            
            if !skip! equ 0 (
                set "file_md5="
                certutil -hashfile "!dirpath!!filename!" MD5 | findstr /v ":" | findstr /v "CertUtil" > "%TEMP_FILE%"
                set /p file_md5=<"%TEMP_FILE%"
                if defined file_md5 (
                    set "file_md5=!file_md5: =!"
                    (echo !file_md5!)>> "%TEMP_CONCAT%"
                    set /a FILE_COUNT+=1
                )
            )
        )
        
        :: If directory has files, calculate combined MD5
        if !FILE_COUNT! gtr 0 (
            :: Calculate MD5 of the list of hashes directly
            certutil -hashfile "%TEMP_CONCAT%" MD5 | findstr /v ":" | findstr /v "CertUtil" > "%TEMP_FILE%"
            set /p dir_md5=<"%TEMP_FILE%"
            set "dir_md5=!dir_md5: =!"
            
            :: Write result - use temporary file to avoid special characters in path
            set TEMP_LINE=temp_line.txt
            echo ^| !reldir! ^| !FILE_COUNT! ^| !dir_md5! ^| > "!TEMP_LINE!"
            type "!TEMP_LINE!" >> "%OUTPUT_FILE%"
            del "!TEMP_LINE!"
            set /a DIR_COUNT+=1
        )
    )
)

:: Clean up all temporary files
if exist "%TEMP_FILE%" del "%TEMP_FILE%"
if exist "%TEMP_CONCAT%" del "%TEMP_CONCAT%"
if exist "%TEMP_DIRS%" del "%TEMP_DIRS%"
if exist "%TEMP_RELDIRS%" del "%TEMP_RELDIRS%"

echo.
echo ========================================
echo Scan completed!
echo Processed %COUNT% files
echo ========================================
echo.
pause
goto :eof

:: Calculate string length function
:getlen
setlocal enabledelayedexpansion
set "str=%~1"
set "len=0"
:getlen_loop
if defined str (
    set "str=!str:~1!"
    set /a len+=1
    goto :getlen_loop
)
endlocal & set "%~2=%len%"
goto :eof
