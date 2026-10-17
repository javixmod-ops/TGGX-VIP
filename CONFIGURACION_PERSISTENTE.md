# Guardado automático de configuración

La interfaz guarda automáticamente sus opciones en un DataStore asociado al `UserId` del jugador y las restaura cuando vuelve a entrar. El guardado se ejecuta en segundo plano; la apariencia y los controles del menú no cambian.

## Instalación en Roblox Studio

1. Mantén `TwinGGXPT.lua` en la ubicación donde ya ejecutas el `LocalScript`.
2. Crea un `Script` dentro de `ServerScriptService` y copia allí el contenido de `ServerScriptService/TwinGGXPT_ConfigServer.server.lua`.
3. En la experiencia publicada, habilita **Game Settings → Security → Enable Studio Access to API Services** para probar DataStores desde Studio. En Studio, usa una copia de prueba para no sobrescribir datos de producción.
4. Publica la experiencia. `DataStoreService` solo puede ser consultado desde el servidor y requiere que la API esté habilitada.

El servidor valida los campos recibidos y guarda por jugador; no se guarda el objetivo seleccionado ni el contenido de la música, solo sus datos de configuración.
