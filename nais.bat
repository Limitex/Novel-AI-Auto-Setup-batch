@echo off
setlocal enabledelayedexpansion

echo [36mNAIFU with NovelAI[0m
echo Batch file to set it up automatically.
echo :

rem # Checking status step.
echo Checking PC status...

rem ## Check for files that exist.
for /f "usebackq delims=" %%A in (`powershell "(Get-ChildItem -Path %CD% | Measure-Object).Count"`) do set fileCount=%%A
if not %fileCount% == 1 (
    echo [31mOther files found. Do not place any other files in the directory where this batch file is running.[0m
    echo Example directory structure
    echo : Directory
    echo :  ^|-[This batch file]
    echo :
    goto :EXIT
)
echo The directory is empty.

rem ## Check for the existence of Microsoft Visual C++ Runtime.
set /a count = 0
for /f "usebackq delims=" %%A in (`powershell -Command "Get-ChildItem -Path( 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall', 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') | %% { Get-ItemProperty $_.PsPath | Select-Object DisplayName} | findstr /r /c:'Microsoft Visual C++.*X64.*Runtime.*' /c:'Microsoft Visual C++.*Redistributable (x64).*'"`) do (
    echo %%A | findstr "Debug Minimum Additional Redistributable" > nul
    if not errorlevel 1 set /a count += 1
)
if %count% equ 0 (
    echo [33mCould not find Microsoft Visual C++ X64 Runtime.
    echo Software may not run properly.
    echo [34mhttps://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170
    echo [33mPress any key to continue.
    echo Press Ctrl + c to exit.[0m
    pause > nul
) else (
    echo Microsoft Visual C++ Runtime confirmed.
)

rem ## Check for the existence of Python + pip.
where python 2> nul > nul || (
    echo [31mCould not find Python.
    echo Install Python version 3.10 or higher.
    echo [34mhttps://www.python.org/downloads/[0m
    goto :EXIT
)
where pip 2> nul > nul || (
    echo [31mCould not find pip.
    echo [34mhttps://www.python.org/downloads/[0m
    goto :EXIT
)
echo Python + pip was confirmed.
echo An error may occur if the version is not 3.10 or higher.
echo This message is printed even on 3.10 and above.
echo :
echo [32mConfirmation completed.[0m

rem # Build step.
echo :
echo [33mThe process may take some time or may not be completed because of the Torrent downloading process during the process.[0m
echo :
echo Start build.

echo [36mUpdating pip...[0m
python -m pip install --upgrade pip

echo [36mInstalling required Python packages...[0m
pip install wheel
pip install torch torchvision torchaudio dotmap fastapi uvicorn omegaconf transformers sentence_transformers faiss-cpu einops pytorch_lightning ftfy scikit-image torchdiffeq jsonmerge --extra-index-url https://download.pytorch.org/whl/cu116

echo [36mPreparing aria2...[0m
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0-win-64bit-build1.zip','%CD%\aria2.zip')"
powershell Expand-Archive -Path "%CD%\aria2.zip" -DestinationPath "%CD%\aria2" > nul
del "%CD%\aria2.zip"
for /f "usebackq delims=" %%A in (`where /r "%CD%\aria2" *.exe`) do set ARIAPATH=%%A
move %ARIAPATH% %CD% > nul
rd /s /q "%CD%\aria2"

echo [36mDownload NAIFU...[0m
%CD%\aria2c.exe --seed-time=0 "magnet:?xt=urn:btih:4a4b483d4a5840b6e1fee6b0ca1582c979434e4d&dn=naifu"
del "%CD%\aria2c.exe"

echo [36mSetup...[0m
powershell Expand-Archive -Path "%CD%\naifu\program.zip" -DestinationPath "%CD%\naifu" > nul
del "%CD%\naifu\program.zip"

powershell -Command "[System.IO.File]::WriteAllLines(('%CD%\naifu\replaced.txt'), @((gc '%CD%\naifu\run.bat').Replace('%%~dp0%%VENV_DIR%%\Scripts\Python.exe', 'python').Replace('--host 0.0.0.0', '--host 127.0.0.1').Replace('--port=6969', '--port=80')), (New-Object 'System.Text.UTF8Encoding' -ArgumentList @($false)))" > nul
copy /y %CD%\naifu\replaced.txt %CD%\naifu\run.bat
del /q %CD%\naifu\replaced.txt

mkdir %CD%\naifu\others > nul
move %CD%\naifu\frontend-src.zip %CD%\naifu\others > nul
move %CD%\naifu\requirements.txt %CD%\naifu\others > nul
move %CD%\naifu\README.txt %CD%\naifu\others > nul
move %CD%\naifu\setup.bat %CD%\naifu\others > nul
move %CD%\naifu\setup.sh %CD%\naifu\others > nul
move %CD%\naifu\run.sh %CD%\naifu\others > nul

copy %CD%\naifu\static\icons\novelai-round.png %CD%\naifu\static\icons\novelai512.png > nul

echo [32mAll operations are complete.
echo You can run it from the run.bat file in naifu.[0m
echo ^(Done^)

:EXIT
pause
endlocal
exit