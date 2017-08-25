@echo off
rem must clear out the previous ERRORLEVEL
set ERRORLEVEL=0
SETLOCAL ENABLEDELAYEDEXPANSION

set filename=""

if [%1]==[] goto usage
if [%2]==[] ( 
        goto usage 
    ) else (
        set filename=%2
        call :test_file
    )
if [%3]==[] ( 
        goto usage 
    ) else (
        set filename=%3
        call :test_file
    )
if [%4]==[] ( 
        goto usage 
    ) else (
        set filename=%4
        call :test_file
    )
if [%5]==[] goto usage

if ERRORLEVEL 1 (
    echo "ERROR Occured exiting script"
    EXIT /B %ERRORLEVEL%
    )

echo "Creating the pipeline"

fly -t %1 set-pipeline -c %2 -l %3 -l %4 -p %5 -n

fly -t %1 unpause-pipeline -p %5

EXIT /B %ERRORLEVEL%

:test_file

if not exist %filename% (
        echo File %filename% does not exist
        SET ERRORLEVEL=1
      ) else (
        rem This is a valid entry but need to check if directory or file
        if exist %filename%\NUL (
          echo %filename% is a directory.  Please enter valid filename.
          SET ERRORLEVEL=1
        ) else (
          rem This is a valid file so continue
          SET ERRORLEVEL=0
        )
      )
EXIT /B %ERRORLEVEL%

:usage

echo %0 usage: %0 concourse-target pipeline.yml config.yml credentials.yml pipeline-name\

set ERRORLEVEL=1

:end
