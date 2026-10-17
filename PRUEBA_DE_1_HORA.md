# Key de prueba de una hora

La key temporal se valida en el servidor y se registra por `UserId` en el DataStore `TwinGGXPT_TrialRedemptions_v1`. Una persona conserva el tiempo restante si vuelve a entrar durante esa misma hora; al vencer, no puede canjear de nuevo la prueba. Cada jugador tiene su propio registro.

## Instalación en Roblox Studio

1. Coloca `TwinGGXPT_TrialAccess.server.lua` como un `Script` dentro de `ServerScriptService`.
2. Dentro de `ServerStorage`, crea un `StringValue` llamado `TwinGGXPT_TrialKey`.
3. En la propiedad `Value`, pega la key de prueba entregada al propietario. **No la copies a un archivo del repositorio**, que es público.
4. Habilita **Game Settings → Security → Enable Studio Access to API Services** para probar DataStores desde Studio y publica la experiencia.
5. Mantén `TwinGGXPT.lua` en la ubicación habitual del `LocalScript`.

El contador aparece en la página `MISC` mientras el acceso de prueba está activo. Al llegar a cero, el menú se cierra, se desactivan sus opciones temporales y vuelve a aparecer la pantalla de acceso. Las keys Free y VIP existentes no tienen vencimiento.
