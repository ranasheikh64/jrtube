# Backend Setup & Run Guide

This guide explains how to start the FastAPI backend and Redis Server on your Windows machine.

## 1. Prerequisites (Redis)

Yes, **you must have Redis running** in the background for the backend to work, because it relies on Redis for caching the temporary video URLs!

### How to run Redis on Windows:
Since Redis doesn't officially support Windows natively anymore, you have two options:

**Option A: Using Memurai (Easiest for Windows)**
1. Download [Memurai](https://www.memurai.com/) (It's a Redis-compatible cache for Windows).
2. Install it. It automatically runs in the background on port `6379`.

**Option B: Using WSL (Windows Subsystem for Linux)**
1. Open your Ubuntu WSL terminal.
2. Run: `sudo apt install redis-server`
3. Start it: `sudo service redis-server start`

*As long as Redis is running on `localhost:6379`, the FastAPI app will find it automatically.*

## 2. Running the FastAPI Backend

Open a new PowerShell terminal and follow these steps:

### Step 1: Navigate to the backend folder
```powershell
cd "e:\rana project\video_viewer\backend"
```

### Step 2: Create a virtual environment (Recommended)
```powershell
python -m venv venv
.\venv\Scripts\activate
```

### Step 3: Install dependencies
```powershell
pip install -r requirements.txt
```

### Step 4: Run the server!
```powershell
uvicorn app.main:app --reload
```
You should see output saying: `Application startup complete.`
The API will now be running at `http://127.0.0.1:8000`.

## 3. Connecting Flutter to the Backend

The API is fully implemented in Flutter inside `lib/core/network/network_caller.dart`.

### How it handles different devices:
- **Windows Desktop App:** The Flutter app connects to `http://127.0.0.1:8000`.
- **Android Emulator:** The Flutter app connects to `http://10.0.2.2:8000` (Because `127.0.0.1` inside an emulator refers to the emulator itself, not your PC).
- **Physical Android Phone:** If you run the app on a real phone via USB, you must find your computer's local IP address (e.g., `192.168.0.105`) using `ipconfig` in CMD, and replace the `baseUrl` in `network_caller.dart` with that IP.

Everything is set up and ready to go!
