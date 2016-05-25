mkdir %PREFIX%\Scripts
mkdir %PREFIX%\share
xcopy %SRC_DIR%\bin\* %PREFIX%\Scripts /i /s
xcopy %SRC_DIR%\share\* %PREFIX%\share /i /s
