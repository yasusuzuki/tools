@echo off

@rem このスクリプトのファイルが格納されているフォルダを取得
set DIRNAME=%~dp0

set FROM_FILE="C:\TEMP\from"
set TO_FILE="%DIRNAME%\copyto"
set SIM_MODE="false"

java  -cp "%DIRNAME%\bin" CopyFileRecursively %FROM_FILE% %TO_FILE% %SIM_MODE%

