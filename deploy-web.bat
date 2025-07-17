@echo off
echo ========================================
echo TrashIQ Web Deployment Script
echo ========================================
echo.

echo [1/3] Building Flutter web app...
cd /d "c:\Users\lavir\OneDrive\Desktop\Project 1\TrashIQ\frontend"
call flutter build web
if %errorlevel% neq 0 (
    echo Build failed! Please check for errors.
    pause
    exit /b 1
)

echo.
echo [2/3] Build completed successfully!
echo.

echo [3/3] Ready for deployment!
echo.
echo Your web app is built in: frontend\build\web
echo.
echo ========================================
echo Deployment Options:
echo ========================================
echo.
echo Option 1 - Pre-built + GitHub + Vercel (EASIEST):
echo   1. Build is already done! ✅
echo   2. Push to GitHub: git add . && git commit -m "Add web deployment" && git push
echo   3. Import to Vercel from GitHub
echo   4. Set Output Directory: frontend/build/web
echo   5. Set Build Command: echo "Using pre-built files"
echo   6. Deploy! 🚀
echo.
echo Option 2 - GitHub + Vercel Auto-build:
echo   1. Push code: git add . && git commit -m "Add web deployment" && git push
echo   2. Import to Vercel (will use build.sh script)
echo   3. Vercel installs Flutter and builds automatically
echo.
echo Option 3 - Vercel CLI:
echo   1. Install: npm i -g vercel
echo   2. Login:   vercel login
echo   3. Deploy:  vercel
echo.
echo Option 4 - Local Test:
echo   Your local server is running at: http://localhost:8080
echo.
echo ========================================
pause
