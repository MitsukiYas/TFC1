# Pendientes del capítulo 6 (sistema electrónico)

Actualizado: 2026-11-15. Cada punto tiene un comentario `% PENDIENTE` en el `.tex` indicado.
Las memorias de cálculo van en `Calculos&Simulaciones/SubsistemaElectrico/` (`memoria_NN_*.m`).

## 1. Valores por calcular (memorias MATLAB)

| Memoria | Qué falta | Archivo .tex |
|---|---|---|
| 03 limitador | Hecha y redactada en 606 (R_SNS 20 mΩ, C_HG 47 nF + 100 Ω y diodo con C_L ≈ 1014 µF, C_TMR 470 nF, FDMS86150; TPS54540 habilitado por ENOUT; unión a 91 °C en el arranque) | 606 |
| 04 filtro π | Hecha y redactada en 606 (cerámicos de 22 µF X7R 50 V por nodo, criterio de Middlebrook) | 606 |
| 05 buck 5 V | Hecha y redactada en 606 (escalón de carga del ejemplo de la hoja de datos; EN con ENOUT y divisor de 560 kΩ y 39 kΩ; diodo PDS760, 1.75 W, requiere cátodo de 9.4 × 7.2 mm en cobre de 2 oz) | 606 |
| 06 buck servos | Hecha y redactada en 606 (entrada 4 × 2.2 µF 100 V, BOOT 0.1 µF, compensación 20 kΩ, 56 nF, 1 nF; salida SAMXON GT supuesta). Aceptados por el usuario: sobretensión al liberar ambos servos y diodo PDS760 a 149 °C en bloqueo continuo | 606 |
| 07 LM1084-3.3 | Hecha y redactada en 606 (entrada 10 µF, salida 10 µF de tantalio, 0.34 W, margen de entrada de 1.50 V; diodo Schottky entre salida y entrada mantenido, aunque la hoja de datos solo lo pide con ≥ 1000 µF) | 606 |
| 08 fuente meteo | Hecha y redactada en 606 (LM1085 con 120 Ω: 3.34 / 5.02 / 12.04 V y sus rangos; seguimiento 1.71–2.13 V con el 2N3906; LMR33630ADDA con 18 µH y 4 × 22 µF 25 V; sin modelos de instrumentos, solo rangos y extremos) | 606 |
| 09 pull-ups | Hecha y redactada en 602 y 605: bus en modo estándar a 100 kHz (UM10204, hojas de datos del BNO055, MPU-6050 y LTC2944); 6.8 kΩ en el tramo de 5.0 V y 4.7 kΩ en el de 3.3 V; ALCC 10 kΩ; capacidad de cable supuesta de 100 pF/m (cumple con 150 pF/m) | 602, 605 |

Criterios acordados: el procedimiento de diseño de cada hoja de datos; rizado de salida de 1 %.

Hechas: 01 demanda (redactada en 603 y 606, 2026-11-15), 02 entrada (redactada en 603), 03 limitador, 04 filtro π, 05 buck 5 V, 06 buck servos, 07 LM1084-3.3, 08 fuente meteorológica y 09 pull-ups, redactadas. Los instrumentos meteorológicos no se nombran por modelo (decisión del usuario): `ott_ventus` y `omega_hx94b` ya no se citan en el capítulo 6.

## 2. Componentes por seleccionar (requisitos ya definidos)

| Componente | Requisito | Archivo .tex |
|---|---|---|
| MOSFET de canal P de la parada de emergencia | Resuelto: SUP40P10-43 con disipador Aavid 529802B02500G y almohadilla Hi-Flow (unión a unos 115 °C con la pendiente sostenida a 21.42 V; memoria 10, punto 3b) | 603 |
| Condensador del nodo de entrada | Resuelto: cerámico X7R de 2.2 µF y 100 V (≈1.1 µF efectivos) | 603 |
| Diodo de libre circulación de la salida de la parada | Resuelto: PDS760 (60 V, 275 A de pico no repetitivo) | 603 |
| Diodo de bloqueo del cargador | Resuelto: STPS20H100C con los dos diodos en paralelo y disipador (≤ 22 °C/W); se acepta la carga ~64 mV por celda incompleta | 606 |
| Diodo de la bobina del relé | Resuelto: 1N4001; condensadores del LM1085-12 redactados; el caso de 29.4 V en el conector queda como advertencia en el texto | 606 |
| Diodos Schottky del TPS54540 y del TPS54560 | Resuelto: PDS760 (60 V, 7 A) en ambos | 606 |
| Placa de conexión del SAM-M8Q | Resuelto: SparkFun GPS-15210 (3.3 V, UART a 9600 baudios, batería de respaldo; I²C sin usar) | 604 |

## 3. Decisiones de diseño

- Sección 607 (integración y distribución): se redacta cuando se terminen de definir las placas (PCB). (607)

Resueltas el 2026-11-15: batería invertida con cargador (fuera del diseño, 606); condensadores y TVS en los bornes de cada controlador (603); Raspberry Pi por las terminales 2 y 4, UART3 para LoRa y UART5 para GNSS, Tabla `tab:pines_rpi` (605); RS-485: piranómetro en un bus, viento y sonda en el otro, conectores y terminación fuera de alcance (605); microSD: riesgo aceptado (603); interruptor DPDT de la barra meteorológica redactado y 20.84 V como mínimo de la línea protegida (606).

## 4. Datos por confirmar

- Resuelto: las pull-up de la placa SEN0374 y del traslador no se consideran (decisión del usuario).

Resueltos el 2026-11-15: cables (batería y cargas 300 mm, AWG 12; MPU-6050 de orientación 1 m, de elevación 300 mm; BNO055 300 mm; encoders 150 a 200 mm); GY-521 a 5.0 V; BNO055 en placa SEN0374 a 5 V; FLT llevada a VCC por el controlador; luz del pulsador no se conecta.

## 5. Bibliografía

- Fuente para la fórmula de inductancia de una línea de dos conductores (603).
- `referencias_nuevas_cap6.bib` no se carga: `packages.tex` solo incluye `TFC/biblio.bib`, por lo que las citas del capítulo 6 no se resuelven al compilar.
- Datos incompletos en `referencias_nuevas_cap6.bib` (marcados `PENDIENTE` en el campo `note`): `dfrobot_sen0374` (año), `aavid_heatsinks` (año y URL), `dsservo_rds3225` (año y URL), `raspberrytips_power` (URL exacta), `samxon_gt` (año), `gy521_mpu6050` (confirmar que el dato de 9 mA proviene de la página de ElectroPeak).
- `adafruit_bno055` ya no se cita (se reemplazó por `dfrobot_sen0374`); puede borrarse.

## 6. Figuras

- Las figuras de `Recursos/Imagenes/ImagenesDisenoElectronico` son anteriores al texto actual (BTS7960, encoder a 24 V, LM1084-5.0, modelo de motor antiguo). Regenerarlas desde el esquemático nuevo cuando esté cerrado. (601, 606)
- Varias figuras del capítulo tienen el título vacío (`\caption[.]{}`, `\textit{.}`): 602 (IMUs, encoder, termistor), 603 (motores, tracción y servos), 604 (LoRa y GNSS), 606 (entrada, filtro π, convertidores).

## 7. Esquemático (KiCad)

- El usuario borró el contenido de `Electronica/` (2026-11-16); el esquemático se rehace al definir las placas.
- 2026-11-17: el usuario dibujó la placa de potencia en `Electronica/TFCEnergyBoard` (raíz y tres hojas). `Electronica/esquematico_potencia.md` pasó a esa numeración y al orden de J01 del esquemático; sus correcciones pendientes están en su punto 7.1. Propuestos (sin decidir): LED indicadores, agujeros de montaje y contornos de disipador.

## 8. Revisión del 2026-11-16 (abiertos)

- Corriente de conexión de la barra de actuadores: resuelto y redactado en 606 el 2026-11-16 (subsección `subsec:arranque_barra`): segundo LTC4364-2 con PSMN4R8-100BSE entre el relé y la barra, R_SNS 2 mΩ, C_HG 68 nF, C_TMR 47 nF; memoria 11. La parada (MOSFET P) y el relé no cambian. Lecturas del SOA revisadas por el usuario. Sin dato: consumo de los drivers y del TPS54560 durante la rampa (dicho en el texto). Entradas nuevas del `.bib`: `nexperia_psmn4r8`, `ti_slva673a`.
- Línea protegida: M1 pasa a PSMN4R8-100BSE, comprobado por SOA (memoria 11, parte 6) y redactado en 606 el 2026-11-16; M2 sigue siendo el FDMS86150; R_SNS, C_HG y C_TMR sin cambios.
- Disipador del MOSFET de la parada: resuelto y redactado en 603 el 2026-11-16 (Aavid 529802B02500G, aprobado por el usuario). El límite de 1 min en pendiente no se aplicó: el catálogo no da la capacidad térmica del disipador.
- Corriente de conexión de la barra de actuadores (≈ 1884 µF; sin limitar, unos 230 A con las resistencias con fuente). Decisión del usuario (2026-11-16): mantener el MOSFET de canal P con una red en la compuerta, para que la parada siga siendo pasiva. Datos ya leídos: SUP40P10-43 (40 A pulsados; SOA de unos 125 W para pulsos de 1 ms o más, a 25 °C de caja), celda 30Q (≤ 26 mΩ a 1 kHz), relé T9G (contacto NC: solo capacidades en alterna). Con dV/dt controlado, según TI SLVA673A: ≤ 3.4 A con la caja a 50 °C y ≤ 0.6 A con la caja a 132 °C. Faltan referencias para la red: Motorola AN1542 (condensador externo entre compuerta y drenador) y onsemi AND9093 (interruptor de carga de canal P); el usuario debe añadirlas a `Referencias`. Sigue abierto el cierre del relé sobre la barra descargada.
- 604 reescrito el 2026-11-16 con el manual del E220-900T30D: tasa en el aire de 2.4 kbps, −147 dBm, canal 65, margen de 69.97 dB. Suposición por confirmar: la estación base usa un transceptor del mismo modelo. El tiempo en el aire (70 ms) no incluye el preámbulo ni el encabezado, que el manual no da.
- 606: alerta del LTC2944 subida a 21.7 V (21.42 a 21.98 V con el 1.3 % de error; hecho el 2026-11-16, memoria 03 actualizada).
- Reparto en placas aprobado: LM1084-3.3 en la placa de control; conectores de los servomotores en la placa de potencia; enlace de 5.0 V entre placas con ≤ 70 mΩ de ida y vuelta.
- DM542: el usuario decidió (2026-11-16) mantener el manual de 2012 que cita el texto; el manual de 2019 (Rev. 3) añadido a Referencias no se usa y sus diferencias (0.4 s, pasos de corriente, NEMA 17 a 24) no se trasladan al texto.
- Placas: la etapa de arranque de la barra (LTC4364-2, PSMN4R8-100BSE en D2PAK, derivación de 2 mΩ) va en la placa de potencia, entre el relé y los bornes de la barra de actuadores.
- MOSFET de polaridad: resuelto el 2026-11-16 (decisión del usuario): dos DMP4015SPS en paralelo, redactado en 606 con su comprobación térmica (74 °C en la pendiente, 86 °C con 19.6 A; memoria 10, punto 4); entrada `diodes_dmp4015sps` añadida al .bib. La resistencia del lazo de conexión pasa a 122 mΩ (unos 240 A sin limitar).
