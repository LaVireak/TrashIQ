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
echo Option 1 - GitHub + Vercel (RECOMMENDED):
echo   1. Push code to GitHub: git add . && git commit -m "Add web deployment" && git push
echo   2. Go to https://vercel.com
echo   3. Click "Import Project" and select your GitHub repo
echo   4. Vercel will auto-detect Flutter and deploy!
echo.
echo Option 2 - Vercel CLI:
echo   1. Install: npm i -g vercel
echo   2. Login:   vercel login
echo   3. Deploy:  vercel
echo   4. Set output directory to: frontend/build/web
echo.
echo Option 3 - Drag & Drop:
echo   1. Go to https://vercel.com
echo   2. Drag the "frontend\build\web" folder to deploy
echo.
echo Option 4 - Local Test:
echo   Your local server is running at: http://localhost:8080
echo.
echo ========================================
pause
