@echo off
echo すべての引数(%%*): %*
echo 実行コマンドパス(%%0): %0
echo 引数1(%%1): %1

@rem このスクリプトのファイルが格納されているフォルダを取得
set DIRNAME=%~dp0

@rem ドラッグアンドドロップ　または　右クリックコンテキストメニューから送られたパラメータ
if "%~1" == "" (
    set FROM_FILE=%1
) else (
    set FROM_FILE="C:\TEMP\from"
)

@rem Linuxでいうdirname。%FROM_FILE%のひとつ１のフォルダをTO_FILEにセット
for %%I IN ( %FROM_FILE% ) do set "TO_FILE=%%~dpI"

set SIM_MODE="false"


java  -cp "%DIRNAME%\${project.artifactId}-${project.version}.jar" UISwing %FROM_FILE% %TO_FILE% %SIM_MODE%

pause


