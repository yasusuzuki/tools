@echo off

@rem このスクリプトのファイルが格納されているフォルダを取得
set DIRNAME=%~dp0

@rem 32bit Windows環境ではswt-32.jarを使用してください
@rem 64bit Windows環境ではswt-64.jarを使用してください

java  -cp "%DIRNAME%\bin;%DIRNAME%\lib\swt-64.jar" UI

