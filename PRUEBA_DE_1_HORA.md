# Key de prueba de una hora (solo LocalScript)

La key `TGX-TRIAL-1H-2EE5A350D9774CA673C2586B` está dentro de `TwinGGXPT.lua`. Al introducirla, el contador empieza localmente y el menú se cierra al completar una hora.

Esta modalidad no requiere un Script en `ServerScriptService`, pero una lógica que corre solo en el cliente no puede guardar de forma fiable el canje por `UserId` entre salidas y reingresos. El bloqueo solo vive durante la ejecución actual del LocalScript: al reiniciar el script o volver a entrar, la key podrá activarse otra vez. Además, como la key está en el archivo público, cualquiera puede leerla. No se debe tratar como protección contra manipulación del cliente.

Mantén `TwinGGXPT.lua` como LocalScript en la ubicación equivalente a `StarterPlayer > StarterPlayerScripts` de tu entorno compatible. Las keys permanentes Free y VIP siguen disponibles y no tienen vencimiento.
