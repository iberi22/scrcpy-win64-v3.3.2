# scrcpy - Mis scripts USB/Wi‑Fi

Breve colección de scripts para usar scrcpy (Windows) con ajustes que facilitan la conexión por USB o Wi‑Fi y mejoran la experiencia (60 FPS, baja latencia, pantalla encendida, posibilidad de esconder el teclado en pantalla andriod).

Repositorio oficial de scrcpy:
https://github.com/Genymobile/scrcpy

Archivos incluidos
- `scrcpy-usb.bat`
  - Conecta por USB (usa el `adb.exe` y `scrcpy.exe` del paquete para evitar conflictos con otras instalaciones).
  - Opciones principales: bitrate 4M, `--max-fps 60`, `--stay-awake` (mantiene la pantalla mientras el dispositivo está enchufado), `--screen-off-timeout=86400`.
  - Modo `--uhid`: intenta simular un teclado físico (`--keyboard=uhid`) para evitar que aparezca el teclado virtual al interactuar con inputs (requiere habilitar la opción de teclado físico en Android).
  - Modo `--virtual`: crea una pantalla secundaria con `--new-display` y usa `--display-ime-policy=hide` (útil si la opción UHID no funciona en tu ROM).
  - El script guarda y restaura la preferencia `show_ime_with_hard_keyboard` mediante ADB para minimizar cambios permanentes.

- `scrcpy-wifi.bat`
  - Conecta al dispositivo por TCP/IP: cambia `IP` y `PORT` en la cabecera si tu dispositivo usa un puerto distinto.
  - Ejecuta `adb connect IP:PORT` usando el `adb.exe` del paquete y luego lanza scrcpy con `--max-fps 60`.
  - Incluye mensajes de ayuda y pasos de solución si la conexión no se establece.

Uso rápido
- USB:
  - Conecta el teléfono por USB (Depuración USB activada).
  - Ejecuta:
    ```powershell
    .\scrcpy-usb.bat
    # o para intentar UHID
    .\scrcpy-usb.bat --uhid
    # o para probar pantalla virtual
    .\scrcpy-usb.bat --virtual
    ```

- Wi‑Fi:
  - Asegura que el teléfono y el PC estén en la misma red.
  - Ajusta `IP` y `PORT` en `scrcpy-wifi.bat` y ejecuta:
    ```powershell
    .\scrcpy-wifi.bat
    ```

Consejos y limitaciones
- Algunos fabricantes modifican el comportamiento del IME o no admiten UHID; si el teclado sigue apareciendo prueba la opción `--virtual` o cambia la app de teclado por una que no muestre IME cuando hay teclado físico.
- Para solucionar problemas, revisa `adb devices`, acepta la autorización en el teléfono si aparece "unauthorized", y asegura que no haya otro `adb` en PATH que interfiera.

Licencia
- Estos scripts son simples utilidades personales. Al subirlos públicamente, revisa la licencia del repositorio `scrcpy` y mantén el crédito al proyecto original.

---
