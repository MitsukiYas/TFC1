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
| MOSFET de canal P de la parada de emergencia | Resuelto: SUP40P10-43 sin disipador (la demanda máxima es transitoria; 1.3 W con la corriente media) | 603 |
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

- `Electronica/control.circuit.tsx`: falta la hoja de comunicaciones y ordenar la disposición.
- `Electronica/potencia.circuit.tsx`: sin empezar; depende de las secciones 1 y 2.
