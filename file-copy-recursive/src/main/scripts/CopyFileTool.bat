@echo off

if "%1" == "" (
   echo "エラー：　このスクリプトは、コピー元のショートカットを示す引数が１つ必要です。"
   pause
   exit /B
)

@rem このスクリプトのファイルが格納されているフォルダを取得
set DIRNAME=%~dp0

set FROM_FILE=%1
@rem Linuxでいうdirname。%FROM_FILE%のひとつ１のフォルダを指す
for %%I IN ( %FROM_FILE% ) do set "TO_FILE=%%~dpI"
set TO_FILE=%1
set SIM_MODE="false"

java  -cp "%DIRNAME%\bin" CopyFileRecursively %FROM_FILE% %TO_FILE% %SIM_MODE%

