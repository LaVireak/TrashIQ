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
echo Option 1 - Include Build Files (FASTEST):
echo   1. Build files already exist! ✅
echo   2. Add to git: git add frontend/build/web/ web/
echo   3. Commit: git commit -m "Include build files for deployment"
echo   4. Push: git push origin main
echo   5. Import to Vercel - deploys instantly! ⚡
echo.
echo Option 2 - Auto-Build on Vercel:
echo   1. Push code: git add . && git commit -m "Auto-build deployment" && git push
echo   2. Vercel runs setup-web.sh automatically
echo   3. Downloads Flutter and builds on their servers
echo.
echo RECOMMENDED: Use Option 1 for fastest deployment!
echo.
echo Option 3 - Local Test:
echo   Your local server is running at: http://localhost:8080
echo.
echo ========================================
pause
