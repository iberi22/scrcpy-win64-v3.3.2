@echo off
rem --- Configuración: cambia IP y PORT si es necesario ---
set "IP=192.168.1.6"
rem Nota: la mayoría de dispositivos usan 5555; cambia a 36987 si tu dispositivo escucha ese puerto
set "PORT=35367"

echo Intentando conectar a %IP%:%PORT%...
rem Desconecta por si acaso y usa el adb incluido en la carpeta del paquete
"%~dp0adb.exe" disconnect %IP%:%PORT% >nul 2>&1

rem Intentar conectar
"%~dp0adb.exe" connect %IP%:%PORT%
timeout /t 1 >nul

rem Verificar que el dispositivo aparece en adb devices con la IP y puerto
"%~dp0adb.exe" devices | findstr /C:"%IP%:%PORT%" >nul
if %errorlevel%==0 (
	echo Conexión ADB establecida con %IP%:%PORT%.
) else (
	echo ERROR: no se pudo conectar a %IP%:%PORT%.
	echo Sugerencias para solucionar el problema:
	echo  1) Asegurate de que el telefono y el PC esten en la misma red Wi-Fi.
	echo  2) Activa "Opciones de desarrollador" y "Depuracion USB" en el telefono.
	echo  3) Conecta el telefono por USB y ejecuta: "adb tcpip %PORT%" (usa el adb del paquete si hace falta).
	echo     Ejemplo: "%~dp0adb.exe" tcpip %PORT%
	echo  4) Revisa en 'adb devices' que el dispositivo no aparezca como "unauthorized" (acepta la ventana en el telefono).
	echo  5) Comprueba firewalls/antivirus que puedan bloquear el puerto %PORT%.
	echo  6) Si tienes varias instalaciones de adb, fuerza el uso del de este paquete: "%~dp0adb.exe".
	pause
	goto :EOF
)

rem Lanzar scrcpy usando el ejecutable local para evitar conflictos con otras instalaciones
"%~dp0scrcpy.exe" -m 1024 --max-fps 60 --window-title "Android WiFi" --always-on-top --no-audio
pause
