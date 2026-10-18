# Key de prueba de una hora

El LocalScript compara la key de prueba antes de abrir el menú. Si coincide, solicita la confirmación al servidor; el servidor vuelve a validarla y guarda el canje por `UserId` en el DataStore `TwinGGXPT_TrialRedemptions_v1`.

La primera activación inicia una hora. Si el mismo usuario vuelve a entrar mientras sigue activa, la key recupera el vencimiento original y muestra solo el tiempo restante; no reinicia ni extiende la prueba. Cuando vence, ese `UserId` ya no puede volver a canjearla. Los registros sobreviven a la salida del jugador y al reinicio del servidor mientras el runtime conserve su almacenamiento persistente.

## Instalación en el runtime compatible

1. Mantén `TwinGGXPT.lua` como LocalScript en la ubicación de scripts de cliente equivalente a `StarterPlayer > StarterPlayerScripts`.
2. Coloca `ServerScriptService/TwinGGXPT_TrialAccess.server.lua` como Script en el servicio de scripts de servidor equivalente a `ServerScriptService`.
3. El servidor crea `TwinGGXPT_TrialAccess` en `ReplicatedStorage`. La key del LocalScript y la del Script de servidor deben coincidir exactamente.
4. Habilita el servicio persistente de datos del runtime y comprueba su salida de servidor. Los errores de DataStore aparecen con el prefijo `[TwinGGXPT Trial]`.

Un LocalScript solo no puede hacer cumplir un uso por `UserId` entre reingresos: el cliente se puede reiniciar o modificar. Si el runtime no ofrece Scripts de servidor, RemoteFunctions y almacenamiento persistente compatible, no se puede garantizar ese límite con código local. La key está en el repositorio público, así que cualquiera puede verla y canjearla una vez por su propio `UserId`.

Las keys permanentes Free y VIP siguen disponibles y no tienen vencimiento.
