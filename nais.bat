@echo off
setlocal

set ARIA2_URI=https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0-win-64bit-build1.zip
set PYTHON_URI=https://www.python.org/ftp/python/3.10.8/python-3.10.8-embed-amd64.zip
set PYTHIN_PIP_URI=https://bootstrap.pypa.io/get-pip.py
set NAIFU_MAGNET="magnet:?xt=urn:btih:4a4b483d4a5840b6e1fee6b0ca1582c979434e4d&dn=naifu&tr=udp%%3a%%2f%%2ftracker.opentrackr.org%%3a1337%%2fannounce"

echo :
echo : [[36mNAIFU with NovelAI[0m]
echo : Batch file to set it up automatically.
echo :

@rem # Checking status step.

echo : Checking PC status...

@rem ## Check for files that exist.
for /f "usebackq delims=" %%A in (`powershell "(Get-ChildItem -Path %~dp0 | Measure-Object).Count"`) do set fileCount=%%A
if not %fileCount% == 1 (
    echo : [31mOther files found. Do not place any other files in the directory where this batch file is running.[0m
    echo :  Example directory structure
    echo :   Directory
    echo :    ^|-[This batch file]
    echo : 
    goto :EXIT
)
echo : The directory is empty.

@rem ## Check for the existence of Microsoft Visual C++ Runtime.
set /a count = 0
for /f "usebackq delims=" %%A in (`powershell -Command "Get-ChildItem -Path( 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall', 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') | %% { Get-ItemProperty $_.PsPath | Select-Object DisplayName} | findstr /r /c:'Microsoft Visual C++.*X64.*Runtime.*' /c:'Microsoft Visual C++.*Redistributable (x64).*'"`) do (
    echo %%A | findstr "Debug Minimum Additional Redistributable" > nul
    if not errorlevel 1 set /a count += 1
)
if %count% equ 0 (
    echo : [33mCould not find Microsoft Visual C++ X64 Runtime.[0m
    echo : [33mSoftware may not run properly.[0m
    echo : [34mhttps://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170[0m
    echo : [33mPress any key to continue.[0m
    echo : [33mPress Ctrl + c to exit.[0m
    pause > nul
) else (
    echo : Microsoft Visual C++ Runtime confirmed.
)

echo :
echo : [32mConfirmation completed.[0m

@rem # warning step

echo :
echo : Caution.
echo :
echo : [33mThis batch file uses Aria2 to download Magnet. Therefore, if the download does not proceed from 0%, we recommend that you review your router settings and configure DMZ, etc.[0m
echo : [33mDuring the installation of the Python module, a warning message such as "Path not followed" will be output, but this should be ignored as there is no problem with execution.[0m
echo :
echo : [33mPress any key to continue.[0m
pause > nul

@rem # Build step.

echo :
echo : Start the build step
echo :

@rem ## Download the aria2c tool
echo : Preparing the download tool.
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ARIA2_URI%','%~dp0aria2.zip')"
powershell Expand-Archive -Path "%~dp0aria2.zip" -DestinationPath "%~dp0aria2" > nul
del "%~dp0aria2.zip"
for /f "usebackq delims=" %%A in (`where /r "%~dp0aria2" *.exe`) do set ARIAPATH=%%A
move %ARIAPATH% %~dp0 > nul
rd /s /q "%~dp0aria2"

@rem ## Download the NAIFU
echo : Download the Naifu.
%~dp0aria2c.exe --seed-time=0 %NAIFU_MAGNET%
del "%~dp0aria2c.exe"

@rem ## Download Python
echo : Download the Python.
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PYTHON_URI%','%~dp0python.zip')"
powershell Expand-Archive -Path "%~dp0python.zip" -DestinationPath "%~dp0naifu\python" > nul
del "%~dp0python.zip"

@rem ## Preparing PIP
echo : Preparing for pip.
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PYTHIN_PIP_URI%','%~dp0get-pip.py')"
%~dp0naifu\python\python.exe %~dp0get-pip.py > nul
del %~dp0get-pip.py
powershell -Command "[System.IO.File]::WriteAllLines(('%~dp0replaced'), @((gc '%~dp0naifu\python\python310._pth').Replace('#import site', 'import site')), (New-Object 'System.Text.UTF8Encoding' -ArgumentList @($false)))" > nul
copy /y %~dp0replaced %~dp0naifu\python\python310._pth > nul
del /q %~dp0replaced

@rem ## Install Python modules
echo : Installs the modules required to run Naifu.
%~dp0naifu\python\Scripts\pip.exe install torch torchvision torchaudio dotmap fastapi uvicorn omegaconf transformers sentence_transformers faiss-cpu einops pytorch_lightning ftfy scikit-image torchdiffeq jsonmerge --extra-index-url https://download.pytorch.org/whl/cu116

@rem ## Compose the naifu
echo : Setting up Naifu.
powershell Expand-Archive -Path "%~dp0naifu\program.zip" -DestinationPath "%~dp0naifu" > nul
del "%~dp0naifu\program.zip"

powershell -Command "[System.IO.File]::WriteAllLines(('%~dp0replaced'), @((gc '%~dp0naifu\run.bat').Replace('%%~dp0%%VENV_DIR%%\Scripts\Python.exe', 'python\python.exe').Replace('--host 0.0.0.0', '--host 127.0.0.1').Replace('--port=6969', '--port=80')), (New-Object 'System.Text.UTF8Encoding' -ArgumentList @($false)))" > nul
copy /y %~dp0replaced %~dp0naifu\run.bat > nul
del /q %~dp0replaced

mkdir %~dp0naifu\others > nul
move %~dp0naifu\frontend-src.zip %~dp0naifu\others > nul
move %~dp0naifu\requirements.txt %~dp0naifu\others > nul
move %~dp0naifu\README.txt %~dp0naifu\others > nul
move %~dp0naifu\setup.bat %~dp0naifu\others > nul
move %~dp0naifu\setup.sh %~dp0naifu\others > nul
move %~dp0naifu\run.sh %~dp0naifu\others > nul
copy %~dp0naifu\static\icons\novelai-round.png %~dp0naifu\static\icons\novelai512.png > nul

echo : 
echo : [32mAll operations are complete.[0m
echo : [32mYou can run it from the run.bat file in naifu.[0m
echo :
echo : ^(Done^)
echo :

:EXIT
pause
endlocal
exit