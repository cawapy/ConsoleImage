@echo off
setlocal enableDelayedExpansion

if "%~1" == "" @(
    echo.%~n0: Missing argument 1>&2
    exit /b 1
)

call :getConsoleDimensions width height || exit /b 1

rem Need utf-8 to print the half fg/bg pixel "▄" correctly as this script is stored utf-8 encoded
chcp 65001 >NUL

rem Imagemagick's TXT format scans pixels row by row.
rem But here, one output character covers 2 pixels of 2 adjacent rows (even+odd) of same column,
rem So better scanning column by column = transposing
for /f "tokens=1,3,4,5 skip=1 delims=,(): " %%A in ('magick "%~1" -resize %width%x%height% -transpose TXT:-') do @(

    if %%A == 0 (
        set line=1
        set "odd="
    )
    set /a x=%%B / 256
    set /a y=%%C / 256
    set /a z=%%D / 256

    if defined odd (
        set "value=[38;2;!x!;!y!;!z!m▄"
    ) else (
        set "value=[48;2;!x!;!y!;!z!m"
    )
    set "variable=lines_!line!"
    call set "!variable!=%%!variable!%%!value!"

    if defined odd (
        set "odd="
        set /a line=line+1
    ) else (
        set "odd=1"
    )
)

for /l %%x in (1 1 %line%) do @(
    set "var=lines_%%x"
    call echo %%!var!%%[0m
)
exit /b 0

:getConsoleDimensions
    set "%~1="
    set "%~2="
    for /f "skip=2 tokens=2 delims=: " %%i in ('mode con:') do @(
        if not defined %~2 @(
            set "%~2=%%~i"
        ) else if not defined %~1 @(
            set "%~1=%%~i"
            exit /b 0
        )
    )
    echo.%~n0: Could not determine console dimensions 1>&2
    exit /b 1

