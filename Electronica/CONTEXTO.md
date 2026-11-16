# Contexto para retomar el trabajo (capítulo 6 → KiCad)

Última sesión: 2026-11-15. Este archivo resume dónde quedó el trabajo y cómo continuarlo.

## Objetivo

Convertir el sistema electrónico del capítulo 6 de la tesis (`TFC/cap6/601` a `607`) en un proyecto de KiCad,
escribiendo los circuitos en tscircuit (código TSX) y exportándolos. A la vez se completan en el `.tex` los valores
que faltan, calculándolos con memorias MATLAB.

## Reglas del usuario

- **Fuera de alcance:** diseño y análisis 3D, aunque el `.tex` los mencione.
- **Sin modelos concretos ni huellas** en el esquemático hasta que el usuario lo indique; símbolos genéricos.
- **Solo esquemáticos** por ahora; las dos placas (PCB) se discuten cuando el esquemático esté cerrado.
- **Carpeta `Referencias/`:** no abrirla sin permiso. Hay permiso para `Referencias/Datasheets_Manuales` solo para las
  memorias de cálculo del subsistema eléctrico. Las citas usan los valores ya escritos en el `.tex`.
- **Redacción** (ver `RECORDATORIO_PARA_CLAUDE.md` en la raíz): sin números de ecuaciones ni tablas de las fuentes;
  sin remisiones entre paréntesis sin `\ref`; no inventar criterios que el texto no establece.
- **Criterios de cálculo acordados:** el procedimiento de diseño de cada hoja de datos; rizado de salida de 1 %.
- **Longitudes de cable (confirmadas):** batería y cargas 300 mm (AWG 12); MPU-6050 de orientación 1 m, de elevación
  300 mm; BNO055 300 mm; encoders 150 a 200 mm.
- **Las figuras antiguas** del capítulo (`Recursos/Imagenes/ImagenesDisenoElectronico`) están desactualizadas;
  los valores se recalculan, no se copian de ellas.

## Archivos

| Archivo | Para qué |
|---|---|
| `TFC/cap6/PENDIENTE.md` | **Lista maestra de pendientes.** Cada punto tiene un `% PENDIENTE` en el `.tex`. Mantenerla al día al cerrar puntos. |
| `TFC/cap6/60*.tex` | Texto del capítulo, con 33 comentarios `% PENDIENTE` |
| `TFC/cap6/referencias_nuevas_cap6.bib` | Citas del capítulo 6 (no se carga al compilar; ver PENDIENTE.md §5) |
| `Electronica/PLAN.md` | Reparto en dos placas y hojas, decisiones tomadas, estado del esquemático |
| `Electronica/control.circuit.tsx` | Esquemático de la placa de control (3 de 4 hojas) |
| `Electronica/scripts/export-kicad.ps1` | Exporta a KiCad y corrige el resultado (ver abajo) |
| `Electronica/scripts/compare-netlist.ps1` | Compara las conexiones de tscircuit con las del esquemático de KiCad |
| `Calculos&Simulaciones/SubsistemaElectrico/parametros_electrico.m` | Datos de entrada comunes de las memorias |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_01_demanda.m` | Demanda de corriente por línea, promedio y caso más severo (hecha) |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_02_entrada.m` | TVS de entrada y diodo de libre circulación (hecha) |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_10_componentes.m` | SUP40P10-43 (parada) y STPS20H100C (cargador): pérdidas, apagado, disipadores |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_09_pullups.m` | Pull-up del I²C (dos tramos, 100 kHz) y de ALCC; ocupación del bus |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_08_fuente_meteo.m` | LM1085-ADJ, seguimiento con el 2N3906, LMR33630, LM1085-12 del relé |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_07_lm1084.m` | LM1084-3.3: margen de entrada, condensadores, disipación, diodo |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_06_buck_servos.m` | TPS54560: bobina, salida electrolítica, entrada, compensación, diodo, escalón con el lazo |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_05_buck_5V.m` | TPS54540: bobina, condensadores, BOOT, compensación, disipación |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_04_filtro_pi.m` | Filtro π: resonancia, Q, atenuación, sensibilidad a la ESL, bobina |
| `Calculos&Simulaciones/SubsistemaElectrico/memoria_03_limitador.m` | LTC4364-2: divisores, límite, C_HG, C_TMR, esfuerzo de los MOSFET |

## Herramientas

- tscircuit CLI `tsci` 0.0.3191 (npm global) y Bun 1.4.4 (winget). En una consola nueva puede hacer falta recargar el PATH.
- KiCad 10.0.8; `kicad-cli` en `C:\Program Files\KiCad\10.0\bin\kicad-cli.exe` (no está en el PATH).
- Skill de tscircuit para Claude en `Electronica/.claude/skills/tscircuit`.
- MATLAB disponible por el servidor MCP `matlab`.

## Flujo del esquemático

```
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\export-kicad.ps1 control
```

El script exporta `control.circuit.tsx` a `kicad\control\`, convierte las etiquetas locales en globales, añade uniones
en los cruces en T, divide cables que pasan por pines, ejecuta el ERC, genera `control.pdf` y corre
`compare-netlist.ps1`. **El resultado solo es válido si la comparación da 0 diferencias.** Añadir `-ConPcb` cuando haya huellas.

Particularidades de tscircuit encontradas:
- Dentro de `<schematicsheet>` ignora `schX`/`schY` y acomoda las piezas solo.
- `schRotation` en componentes pasivos produjo símbolos cuyos pines no tocaban los cables en KiCad: no usarlo.
- No tiene clases de red; el `.kicad_pro` sale solo con la clase `Default`.
- El `Footprint` de los símbolos sale vacío: «Actualizar PCB desde el esquemático» de KiCad no sirve.
- La exportación es en un solo sentido: los cambios hechos en KiCad se pierden en la siguiente exportación.

## Memorias de cálculo (orden planificado)

| # | Memoria | Estado |
|---|---|---|
| 00 | `parametros_electrico.m` | hecha |
| 01 | demanda por línea | hecha, redactada en 603 y 606 |
| 02 | entrada: TVS y diodo de libre circulación | hecha, redactada en 603 |
| 03 | limitador LTC4364-2 | hecha, redactada en 606 (R_SNS 20 mΩ, C_HG 47 nF, C_TMR 470 nF, FDMS86150); lee el .mat de la 05 |
| 04 | filtro π | hecha, redactada en 606; faltan los cerámicos (propuesta 22 µF por nodo) |
| 05 | convertidor TPS54540 de 5.0 V | hecha, redactada en 606 |
| 06 | convertidor TPS54560 de 6.5 V | hecha, redactada en 606 |
| 07 | regulador LM1084-3.3 | hecha, redactada en 606 |
| 08 | fuente meteorológica (LMR33630, LM1085, 2N3906) | hecha, redactada en 606 |
| 09 | resistencias pull-up (I²C, ALCC) | hecha, redactada en 602 y 605 (I²C a 100 kHz) |

Estilo: como las memorias de `SubsistemaElevacion` (comentarios en español, `run('parametros_electrico.m')`,
`SUPOSICION:` donde el texto no fija un dato, resultados guardados en un `.mat`).

## Cambios hechos en el `.tex` en la última sesión (sin compilar)

- 606: MOSFET de polaridad antes del LTC2944; diodo de bloqueo del cargador (9 A, ≥ 55.5 V); TPS54560 para los
  servomotores; se movió a su propia línea un párrafo que estaba comentado por error («Esta línea alimenta…»).
- 603: MOSFET de parada después del punto del cargador; interruptor principal; transitorio de la parada con TVS
  SMBJ30A, condensador de entrada y diodo de libre circulación.
- 602, 604: placas GY-521 (MPU-6050) y breakout del GNSS.
- Bibliografía: `ti_tps54560`; URL de ElectroPeak en `gy521_mpu6050`.
- Sesión siguiente (2026-11-15): decisiones de §3 y datos de §4 de `PENDIENTE.md` aplicados en 602 a 607: BNO055 en
  placa DFRobot Fermion SEN0374 (`dfrobot_sen0374`), GY-521 a 5.0 V, longitudes de cable, FLT sin pull-up externa,
  luz del pulsador sin conectar, Tabla `tab:pines_rpi` (Raspberry Pi por terminales 2 y 4, UART3 LoRa, UART5 GNSS),
  RS-485, interruptor DPDT de la barra meteorológica (ver `TESIS_Electronica_MODENERGIA.pdf` en la raíz).

## Próximos pasos

1. Memorias 03 a 09, en orden; escribir cada resultado en el `.tex` y cerrar su punto en `PENDIENTE.md`.
2. Sección 607 cuando se definan las placas.
3. Con los valores, dibujar `potencia.circuit.tsx` y la hoja de comunicaciones de `control.circuit.tsx`; ordenar la disposición.
