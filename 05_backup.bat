@echo off
REM ============================================================
REM РЕЗЕРВНОЕ КОПИРОВАНИЕ БД (PostgreSQL)
REM ============================================================
set PGPASSWORD=your_password
set BACKUP_DIR=%~dp0backups
set DATE=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set DATE=%DATE: =0%

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

pg_dump -U postgres -h localhost -F c -b -v -f "%BACKUP_DIR%\practice6_%DATE%.backup" practice6

echo Backup saved to %BACKUP_DIR%\practice6_%DATE%.backup
