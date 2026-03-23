# SRC.md - Scrcpy Windows

> Utilidad de mirror de pantalla Android para Windows.

## Proyecto

- **Nombre:** scrcpy-win64-v3.3.2
- **Tipo:** Utility (Binary)
- **Descripción:** Scrcpy v3.3.2 compilado para Windows x64 - mirror de pantalla Android via USB/WiFi
- **Tech Stack:** C, SDL2, Java

## Estructura

```
scrcpy-win64-v3.3.2/
├── scrcpy.exe              # Ejecutable principal
├── scrcpy-server           # Servidor Android
├── adb.exe                  # ADB (Android Debug Bridge)
├── *.dll                    # Librerías SDL2
├── scrcpy-usb.bat          # Iniciar via USB
├── scrcpy-wifi.bat         # Iniciar via WiFi
└── README.md
```

## Uso

```bash
# Via USB
.\scrcpy-usb.bat

# Via WiFi
.\scrcpy-wifi.bat
```

## Requisitos

- Android SDK con ADB
- Driver USB para el dispositivo Android
- Habilitar depuración USB en el dispositivo

## Estado

- ✅ Listo para uso
- 📦 Binario standalone

*Última actualización: 2026-03-19*
