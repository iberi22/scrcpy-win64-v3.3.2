@echo off
rem scrcpy-usb.bat
rem Uso: scrcpy-usb.bat [--tcpip [PORT]]
rem - Por defecto conecta por USB al dispositivo (-d) si hay uno conectado.
rem - Opciones: mantiene la pantalla despierta mientras el dispositivo esté enchufado (--stay-awake)
rem - Oculta el teclado en pantalla con --display-ime-policy=hide
rem - Ajustes: 60 fps, bitrate moderado para baja latencia (4M)

setlocal enabledelayedexpansion

set "ADB=%~dp0adb.exe"
set "SCRCPY=%~dp0scrcpy.exe"

rem Leer argumento --tcpip opcional
set "USE_TCPIP=0"
set "TCPIP_PORT=5555"
set "USE_VIRTUAL=0"
set "USE_UHID=0"
if "%1"=="--tcpip" (
    set "USE_TCPIP=1"
    if not "%2"=="" set "TCPIP_PORT=%2"
)
if "%1"=="--virtual" (
    set "USE_VIRTUAL=1"
)
if "%1"=="--uhid" (
    set "USE_UHID=1"
)

echo Usando ADB: %ADB%

rem Verificar adb disponible
if not exist "%ADB%" (
    echo ERROR: no se encontro adb.exe en la carpeta. Asegurate de tener el paquete completo.
    pause
    goto :EOF
)

rem Mostrar dispositivos
echo Comprobando dispositivos ADB...
"%ADB%" devices

rem Comprobar si 'adb devices' muestra alguna linea con la palabra 'device' (estado conectado)
"%ADB%" devices | findstr /C:"device" >nul 2>&1
if %errorlevel%==0 (
    echo Al menos un dispositivo aparece en 'adb devices'.
) else (
    echo No se encontraron dispositivos ADB. Conecta el telefono por USB y activa Depuracion USB.
    pause
    goto :EOF
)

echo DEBUG_1: despues comprobacion de dispositivos
echo DEBUG_USE_TCPIP: %USE_TCPIP%

rem Si se solicita, habilitar modo tcpip en el dispositivo conectado y desconectar USB
if "%USE_TCPIP%"=="1" goto :DO_TCPIP

echo DEBUG_2: despues comprobacion TCPIP

rem Opciones recomendadas para baja latencia y 60 FPS
set "BITRATE=4M"
set "FPS=60"
set "SCREEN_OFF_TIMEOUT=86400"

echo Lanzando scrcpy por USB con las mejores opciones para latencia...
echo  - bitrate %BITRATE%  - max-fps %FPS%  - mantener pantalla encendida mientras este enchufado
if %USE_VIRTUAL%==1 (
    echo  - MODO VIRTUAL: se usara --new-display y --display-ime-policy=hide para intentar ocultar el teclado
)
if %USE_UHID%==1 (
    echo  - MODO UHID: se usara --keyboard=uhid para simular teclado fisico (requiere configuracion en el telefono)
    echo    -> En el telefono: Ajustes -> Sistema -> Idiomas y entrada -> Teclado fisico -> desactiva 'Mostrar teclado virtual'
    echo    -> Para abrir esa pantalla via ADB: "%ADB%" shell am start -a android.settings.HARD_KEYBOARD_SETTINGS
)

rem Guardar valor actual de show_ime_with_hard_keyboard (para restaurar luego)
set "OLD_SHOW_IME=-1"
set "TMPFILE=%TEMP%\scrcpy_show_ime.txt"
if exist "%TMPFILE%" del "%TMPFILE%" >nul 2>&1
"%ADB%" shell settings get secure show_ime_with_hard_keyboard > "%TMPFILE%" 2>nul
if exist "%TMPFILE%" (
    set /p OLD_SHOW_IME=<"%TMPFILE%"
    del "%TMPFILE%" >nul 2>&1
)

rem Intentar desactivar la muestra del teclado virtual cuando haya teclado fisico
echo Desactivando la opcion 'show virtual keyboard with hardware keyboard' temporalmente...
"%ADB%" shell settings put secure show_ime_with_hard_keyboard 0 >nul 2>&1

echo DEBUG_3: despues put show_ime

rem Lanzar scrcpy en background y luego intentar ocultar el teclado con KEYCODE_BACK
echo Iniciando scrcpy en background...
if %USE_VIRTUAL%==1 (
    start "scrcpy" /B "%SCRCPY%" -d -b %BITRATE% --max-fps %FPS% --stay-awake --screen-off-timeout=%SCREEN_OFF_TIMEOUT% --new-display --display-ime-policy=hide --window-title "Android USB (virtual)" --always-on-top
) else (
    rem Construir comando base
    set "SCRCPY_CMD=%SCRCPY% -d -b %BITRATE% --max-fps %FPS% --stay-awake --screen-off-timeout=%SCREEN_OFF_TIMEOUT% --window-title "Android USB" --always-on-top"
    if %USE_UHID%==1 (
        set "SCRCPY_CMD=%SCRCPY_CMD% --keyboard=uhid"
    )
    start "scrcpy" /B %SCRCPY_CMD%
)

rem Esperar un momento a que scrcpy arranque
timeout /t 1 >nul

echo Intentando ocultar el teclado virtual (enviando KEYCODE_BACK)...
"%ADB%" shell input keyevent 4 >nul 2>&1

rem Esperar a que scrcpy termine (comprobando proceso scrcpy.exe)
echo Esperando a que scrcpy finalice para restaurar la configuracion IME...
:WAIT_SCRCPY
tasklist /FI "IMAGENAME eq scrcpy.exe" 2>nul | findstr /I "scrcpy.exe" >nul
if %errorlevel%==0 (
    timeout /t 1 >nul
    goto :WAIT_SCRCPY
)

echo DEBUG_4: scrcpy finalizado

rem Restaurar valor anterior de show_ime_with_hard_keyboard
if not "%OLD_SHOW_IME%"=="-1" (
    echo Restaurando la opcion show_ime_with_hard_keyboard a %OLD_SHOW_IME%...
    "%ADB%" shell settings put secure show_ime_with_hard_keyboard %OLD_SHOW_IME% >nul 2>&1
)

endlocal

:DO_TCPIP
echo Habilitando tcpip en el dispositivo (puerto %TCPIP_PORT%)...
"%ADB%" tcpip %TCPIP_PORT%
echo Ahora desconecta el cable USB y ejecuta el script scrcpy-wifi.bat o usa: "%SCRCPY%" --tcpip=%TCPIP_PORT%
pause
goto :EOF
