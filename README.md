# Novel-AI-Auto-Setup-batch

Use of this batch file is at your own risk.

This is a batch file that downloads the leaked NovelAI (NAIFU) and automatically sets it up ready for use.
During the setup process, Aria2 is downloaded and Torrent downloaded using it, so the setup may not be completed.

## How to use

Naifu must be run on a PC with at least 8 GB of GPU memory.

Place this batch file in the newly created folder and run it. Also, if there are other files in the same directory, the setup will be interrupted.

If the Microsoft Visual C++ Runtime is not found during the installation process, the installer will start. Please install and run it again.
If a reboot is required, please reboot and run again.

> Python is now installed in the local Niafu directory, so Python and pip no longer need to be added to the environment variables and run.

## Manual Setup

### 0. Install Microsoft Visual C++ Redistributable Package

Install the X64

https://learn.microsoft.com/ja-JP/cpp/windows/latest-supported-vc-redist?view=msvc-170

### 1. Install Python (3.10 ~) + pip

https://www.python.org/downloads/

```
python --version 
pip --version
```

### 2. Install Python module

```
python -m pip install --upgrade pip

pip install wheel

pip install torch torchvision torchaudio dotmap fastapi uvicorn omegaconf transformers sentence_transformers faiss-cpu einops pytorch_lightning==1.7.7 ftfy scikit-image torchdiffeq jsonmerge --extra-index-url https://download.pytorch.org/whl/cu116
```

### 3. Aria2 Download (Magnet download tool)

https://github.com/aria2/aria2/releases/tag/release-1.36.0

DIRECTORY_PATH = Save Path

MAGNET = Torrent Magnet Link

```
./aria2c.exe --dir="DIRECTORY_PATH" --seed-time=0 "MAGNET"

./aria2c.exe --seed-time=0 "MAGNET"
```

### 4. NovelAI download (Naifu with NovelAI)

```
magnet:?xt=urn:btih:4a4b483d4a5840b6e1fee6b0ca1582c979434e4d&dn=naifu&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337%2fannounce
```

### 5. NovelAI Setup

1. extract `program.zip` in `naifu` to `naifu` directory (remove `program` at the end of path when extracting)

2. change path of `PYTHON` in `naifu/run.bat` to something you can refer to (`python` is OK)

3. change IP address of the last execution line of `naifu/run.bat` from `0.0.0.0` to `127.0.0.1` (local IP used for connection)

4. copy `static/icons/novelai-round.png` and rename it to `static/icons/novelai512.png

5. double-click `naifu/run.bat' to run Naifu

- If `ERROR: [Errno 11001] getaddrinfo failed` is displayed, change the port in the last execution line of `naifu/run.bat` because the port you set is in use and cannot be used

### Other Models 

1. overwrite the directory from `novelaileak/models` to `naifu/models`.

2. overwrite `naifu/models/modules/modules` to `naifu/models/modules` and fix it.

```
magnet:?xt=urn:btih:5bde442da86265b670a3e5ea3163afad2c6f8ecc&dn=novelaileak
```

## Reference

https://rentry.org/sdg_FAQ

## Other Referece

https://boards.4channel.org/g/thread/89031771#p89032728

https://github.com/AUTOMATIC1111/stable-diffusion-webui/discussions/2017
