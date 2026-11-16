# Plan del proyecto electrónico (capítulo 6 → KiCad)

Fuente: `TFC/cap6/601` a `607`. Los circuitos se escriben en tscircuit y se exportan a KiCad con
`scripts\export-kicad.ps1 <placa>` (salida en `kicad\<placa>\`, se reemplaza en cada exportación).
Para retomar el trabajo en otra conversación, leer primero `CONTEXTO.md`.

Fuera de alcance: diseño y análisis 3D. Aún sin asignar: modelos concretos nuevos y huellas.

## Decisiones tomadas (2026-11-15)

- Dos placas: **potencia** (gabinete de potencia) y **control** (gabinete electrónico).
- El camino de 20 A de la batería va en la placa de potencia.
- GNSS SAM-M8Q como placa breakout conectada por conector.
- Interruptor principal de encendido: en serie con el contacto normalmente cerrado del pulsador de parada (redactado en 603).
- Orden de entrada: batería, fusible, MOSFET de polaridad, derivación + LTC2944, punto del cargador, parada de emergencia, barras.
- Cargador: diodo de bloqueo para 9 A y ≥ 55.5 V inversos; la bobina del relé se alimenta del lado del conector.
- Convertidor de servomotores: TPS54560 (el de 5 V sigue siendo TPS54540).
- Entrada de la parada de emergencia: TVS SMBJ30A + condensador ≥ 0.68 µF en el nodo de entrada; diodo de libre circulación a la salida (memoria_02, redactado en 603).
- Por ahora solo esquemáticos, con símbolos genéricos y sin huellas. Las placas se discuten cuando el esquemático esté cerrado.

## Estado

- `control.circuit.tsx`: hojas Microcontrolador, Sensores y Señales de actuadores dibujadas. Las 117 conexiones coinciden
  entre tscircuit y KiCad (`scripts\compare-netlist.ps1`). Falta la hoja Comunicaciones y ordenar la disposición
  (tscircuit acomoda las piezas solo; las etiquetas quedan sobre los cables).
- `potencia.circuit.tsx`: sin empezar; depende de los valores pendientes.

Supuestos del esquemático de control (también en `TFC/cap6/PENDIENTE.md`):
- Módulos MPU-6050 (GY-521) alimentados a 5.0 V (confirmado por el usuario 2026-11-15).
- Los condensadores de 47 µF y 100 nF de cada encoder se dibujan junto a su encoder.
- Pull-up (memoria 09): I²C a 100 kHz, 6.8 kΩ en el tramo de 5.0 V y 4.7 kΩ en el de 3.3 V; ALCC 10 kΩ a 5.0 V. FLT no la necesita.

## Placa de potencia — `potencia.circuit.tsx`

| Hoja | Contenido |
|---|---|
| Entrada | Conector de batería, fusible 20 A, MOSFET de polaridad, derivación 2 mΩ + LTC2944, conector del cargador + diodo de bloqueo STPS20H100C (ánodos en paralelo, con disipador), relé de recarga + LM1085-12 (entrada 10 µF 50 V, salida 10 µF de tantalio) + diodo 1N4001 en la bobina, MOSFET de parada de emergencia SUP40P10-43 + red de compuerta + TVS SMBJ30A y condensador de entrada (2.2 µF 100 V X7R) + diodo de libre circulación PDS760, conectores del pulsador y del interruptor principal |
| Barra de actuadores | Salida del relé, bornes hacia los dos DM542 y los dos controladores de tracción, convertidor TPS54560 de 6.5 V (diodo PDS760 con cátodo de al menos 9.4 × 7.2 mm en cobre de 2 oz; entrada 4 × 2.2 µF 100 V; salida 2 × 470 µF SAMXON GT + 100 nF; BOOT 0.1 µF; compensación 20 kΩ, 56 nF, 1 nF) |
| Línea protegida | LTC4364-2 (R_SNS 20 mΩ, C_HG 47 nF + 100 Ω y diodo, C_TMR 470 nF) con dos FDMS86150; filtro π (4.7 µH, 2 × 470 µF SAMXON GT, 22 µF X7R 50 V por nodo) |
| 5 V y 3.3 V | TPS54540 de 5.0 V (EN desde ENOUT del LTC4364 + divisor 560 kΩ / 39 kΩ; salida 2 × 47 µF; entrada 2 × 4.7 µF 50 V; BOOT 0.1 µF; compensación 18 kΩ, 3.3 nF, 33 pF; diodo PDS760 con cátodo de al menos 9.4 × 7.2 mm en cobre de 2 oz), LM1084-3.3 (entrada 10 µF, salida 10 µF de tantalio, Schottky entre salida y entrada) |
| Fuente meteorológica | LMR33630ADDA (400 kHz; entrada 2 × 10 µF 50 V X7R + 220 nF; bobina 18 µH; salida 4 × 22 µF 25 V; BOOT 100 nF; VCC 1 µF; PG 100 kΩ) + LM1085-ADJ (120 Ω; 200 / 360 / 1000 + 30 Ω; entrada 10 µF; salida 10 µF de tantalio) + 2N3906 (R22 12 kΩ, R24 10 kΩ, R23 10 kΩ), conmutador de tensión, interruptor de conexión directa, tres borneras |

## Placa de control — `control.circuit.tsx`

| Hoja | Contenido |
|---|---|
| Microcontrolador | Arduino Mega 2560 Pro (zócalo), asignación de terminales de la Tabla `tab:pines_mega` |
| Sensores | Bus I²C: BNO055 (placa DFRobot Fermion SEN0374, a 5 V), traslador de nivel, conectores de los dos MPU-6050 (GY-521); encoders (pull-up 1 kΩ, conectores); termistor NTC (divisor + 100 nF) |
| Señales de actuadores | Conectores PUL/DIR/ENA de los dos DM542; PWMA/PWMB, CS, FLT y SLP de los dos controladores de tracción; conectores de los servomotores (señal + 6.5 V) |
| Comunicaciones | Conector hacia la Raspberry Pi (Tabla `tab:pines_rpi`: 5 V por terminales 2 y 4, UART3 LoRa, UART5 GNSS, M0/M1/AUX en GPIO22/27/17), módulo LoRa E220 (desacoplo, resistencias serie, pull-up de AUX), conector de la placa SparkFun GPS-15210 (SAM-M8Q, 3.3 V, UART) |

Fuera de las placas (módulos con cableado propio): Raspberry Pi 4, drivers DM542 y controladores de tracción (cada uno con su condensador de 470 µF y TVS SMBJ30A en sus bornes, fuera de la placa de potencia),
conversores USB–RS-485, batería y pulsador de parada (su luz no se conecta).

## Entre placas

Alimentación 5.0 V, 3.3 V, 6.5 V y tierra; bus I²C y línea ALCC del LTC2944 hacia el microcontrolador.

## Pendientes

La lista completa y actualizada está en `TFC/cap6/PENDIENTE.md`.
