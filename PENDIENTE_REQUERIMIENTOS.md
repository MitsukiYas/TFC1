# PENDIENTE_REQUERIMIENTOS

## 1. Requerimiento 1 (Geometría): solo nota, sin cambio por ahora

Se mantiene como referencia. Cuando lo actualices, ten en cuenta lo que da hoy el subsistema de elevación:

| Medida | Valor actual | Límite del requerimiento |
|---|---|---|
| Altura del plano óptico en la posición baja (θ = 15°) | 904 mm | 500 mm |
| Altura máxima desplegado | 1313.6 mm | — |
| Largo en la posición baja (chasis de 500 mm + bloque sobresaliente de 240.6 mm) | ~741 mm | 600 mm |
| Masa del subsistema de elevación completo, con orientación, motorreductor y base, sin los largueros del chasis (memoria 12) | 10.87 kg | 20 kg en total |

Te sugiero que la nueva redacción distinga dos estados: **posición de transporte** (mecanismo abajo) y **posición desplegada**.

## 2. Propuestas opcionales (nuevos requerimientos)

Surgieron durante el diseño. Inclúyelas solo si quieres que queden como requisitos verificables.

| Tipo | Característica | Descripción técnica | Justificación |
|---|---|---|---|
| E | Seguridad | El mecanismo de elevación debe mantener su posición sin consumo de energía y no descender ante una interrupción de la alimentación. | Requerimientos 5 (autonomía) y 11 (parada de emergencia): un mecanismo que cae al cortar la energía es un riesgo, y sostenerlo con corriente consume batería. |
| D | Cinemática | El ajuste de altura en todo el rango debe completarse en un tiempo máximo de 10 s. | Tiempo de operación por punto de medición; definido en el perfil de movimiento. |
| E | Señales / Operación | La medición de irradiancia se realiza con el robot detenido y con una pendiente longitudinal menor a la admisible, verificada con el sensor inercial del eje basculante. | El subsistema de orientación no corrige el cabeceo; tolerancia de la IEC 61724-1. |

### Observaciones a resolver antes de incluirlas

- **Ninguna tiene método de verificación.** En la tabla `tab:lista_requerimientos` todas las filas tienen uno.
- **Seguridad (E):** cita el Req. 11, pero ese requerimiento solo cubre la interrupción de la tracción, no el mecanismo de elevación.
- **Cinemática (D):** «definido en el perfil de movimiento» justifica el requisito con el propio diseño. Falta una razón externa (por ejemplo, tiempo por punto de medición o la autonomía del Req. 5).
- **Señales / Operación (E):** «menor a la admisible» no tiene valor numérico (por ejemplo, «≤ X° según IEC 61724-1»), y la redacción es de procedimiento, no de requisito.
