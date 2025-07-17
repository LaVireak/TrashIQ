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
echo Option 1 - Automated GitHub + Vercel (RECOMMENDED):
echo   1. Web files are ready in /web directory! ✅
echo   2. Push to GitHub: git add . && git commit -m "Deploy to Vercel" && git push
echo   3. Import GitHub repo to Vercel
echo   4. Vercel runs setup-web.sh automatically
echo   5. Deploys from /web directory! 🚀
echo.
echo Option 2 - Manual Vercel Settings:
echo   - Output Directory: web
echo   - Build Command: chmod +x setup-web.sh && ./setup-web.sh
echo   - Install Command: echo "No install needed"
echo.
echo Option 3 - Local Test:
echo   Your local server is running at: http://localhost:8080
echo.
echo ========================================
pause
