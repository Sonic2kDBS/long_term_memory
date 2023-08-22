@echo off

echo WARNING: This script is untested, please confirm you backed up all important data.
echo.

set /p UserInput=Do you wish to continue? (yes/no): 

if /i not "%UserInput%"=="yes" (
    echo Script terminated by user.
    exit /b
)

SET BASE_DIR=./user_data/bot_memories

REM Generate a timestamp in YYYYMMDD_HHMMSS format
FOR /F "tokens=2 delims==" %%i in ('wmic os get localdatetime /format:list') do set datetime=%%i
SET TIMESTAMP=%datetime:~0,8%_%datetime:~8,6%

SET OUTPUT_DIR=./user_data/bot_csv_outputs/%TIMESTAMP%

REM Create output directory
IF NOT EXIST "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Loop through each directory inside the base directory
for /D %%i in (%BASE_DIR%/*) do (
    REM Get the directory name (which corresponds to the person's name)
    SET "person_name=%%~nxi"
    
    REM Form the SQLite DB path
    SET db_path=%%i/long_term_memory.db
    
    REM Form the CSV output path
    SET csv_output=%OUTPUT_DIR%/%person_name%.csv
    
    echo Dumping %db_path% -> %csv_output%
    
    REM Dump the database content to CSV
    sqlite3 "%db_path%" ".mode csv" ".output %csv_output%" "SELECT * FROM long_term_memory ORDER BY timestamp;" ".quit"
)

echo Data has been dumped to the respective CSVs!

