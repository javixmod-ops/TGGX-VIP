# Key de prueba de una hora

La key temporal se valida en el servidor y se registra por `UserId` en el DataStore `TwinGGXPT_TrialRedemptions_v1`. Una persona conserva el tiempo restante si vuelve a entrar durante esa misma hora; al vencer, no puede canjear de nuevo la prueba. Cada jugador tiene su propio registro.

La key está escrita en `ServerScriptService/TwinGGXPT_TrialAccess.server.lua`. El repositorio es público, así que cualquiera puede verla y canjearla una vez por su propio `UserId`. El temporizador de una hora empieza en el primer canje válido.

## Instalación en Roblox Studio

1. Coloca `TwinGGXPT_TrialAccess.server.lua` como un `Script` dentro de `ServerScriptService`.
2. Mantén `TwinGGXPT.lua` en `StarterPlayer > StarterPlayerScripts` como `LocalScript`.
3. Publica la experiencia. Para probar DataStores desde Studio, habilita **Game Settings → Security → Enable Studio Access to API Services**.
4. Al probar, abre `View → Output`, selecciona `Server` y revisa los mensajes `[TwinGGXPT Trial]` si DataStore falla.

No hace falta crear un `StringValue` en `ServerStorage`: la key ya está en el Script de servidor. La validación requiere que ese Script corra en una experiencia que puedas editar; un `LocalScript` por sí solo o ejecutado en una experiencia ajena no puede crear la función remota ni escribir el DataStore del servidor.

El contador aparece en la página `MISC` mientras el acceso de prueba está activo. Al llegar a cero, el menú se cierra, se desactivan sus opciones temporales y vuelve a aparecer la pantalla de acceso. Las keys Free y VIP existentes no tienen vencimiento.
