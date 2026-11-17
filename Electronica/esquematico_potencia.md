# Esquemático de la placa de potencia — definición

Actualizado: 2026-11-16. Fuente: `TFC/cap6/603` y `606` (valores) y las hojas de datos citadas allí (nombres de terminales).
Los designadores y los nombres de red son una propuesta. Lo marcado **[fuera del texto]** no está en el `.tex`: viene de la hoja de datos indicada o es una propuesta por confirmar.

## 1. Hojas jerárquicas

Una hoja raíz y siete hojas hijas.

| Nº | Hoja | Contenido |
|---|---|---|
| 0 | Raíz | Las siete hojas como bloques, las redes entre ellas y el conector de señales hacia la placa de control |
| 1 | Entrada y carga | Conector de batería, fusible, protección de polaridad, derivación y monitor LTC2944, conector del cargador, diodo de bloqueo, regulador de la bobina del relé |
| 2 | Parada de emergencia y relé | TVS y condensador del nodo de entrada, MOSFET de parada, diodo de libre circulación, conector del pulsador, relé de recarga |
| 3 | Barra de actuadores | Arranque suave (LTC4364-2) y los cuatro bornes de la barra |
| 4 | Convertidor de servomotores | TPS54560 de 6.5 V y los dos conectores de los servomotores |
| 5 | Línea protegida | Limitador LTC4364-2 y filtro π |
| 6 | Convertidor de 5 V | TPS54540 y el conector de 5 V hacia la placa de control |
| 7 | Fuente meteorológica | Interruptor de la barra, LMR33630, LM1085 ajustable, seguimiento con el 2N3906, conmutador de tensión y tres borneras |

Numeración de designadores: la centena indica la hoja (por ejemplo, `Q201` está en la hoja 2).

## 2. Redes entre hojas

| Red | Qué es | Sale de | Entra en |
|---|---|---|---|
| `GND` | Tierra | todas | todas |
| `N_IN` | Nodo de entrada (después de la derivación; punto del cargador) | 1 | 2 |
| `CHG+` | Positivo del conector del cargador (antes del diodo de bloqueo) | 1 | — |
| `+12V_REL` | Alimentación de la bobina del relé | 1 | 2 |
| `N_SW` | Salida del MOSFET de parada | 2 | 2 (relé), 5 |
| `N_REL` | Salida del contacto del relé | 2 | 3 |
| `V_BARRA` | Barra de actuadores (21.0 a 29.4 V) | 3 | 4 |
| `V_SERVO` | 6.5 V de los servomotores | 4 | — |
| `V_PROT` | Línea protegida, salida del filtro π (20.84 a 29.4 V) | 5 | 6, 7 |
| `ENOUT_5V` | Salida ENOUT del limitador hacia EN del TPS54540 | 5 | 6 |
| `+5V` | 5.0 V | 6 | raíz (conector a la placa de control) |
| `SDA`, `SCL`, `ALCC` | Bus I²C y alerta del LTC2944 | 1 | raíz (conector de señales) |
| `PWM_M3`, `PWM_M4` | Señal de los servomotores | raíz (conector de señales) | 4 |

## 3. Hoja 0 — Raíz

| Ref. | Elemento | Terminal → red |
|---|---|---|
| J001 | Conector de señales, 6 vías, hacia la placa de control | 1 → `SDA`; 2 → `SCL`; 3 → `ALCC`; 4 → `PWM_M3`; 5 → `PWM_M4`; 6 → `GND` |

Las resistencias pull-up de `SDA`, `SCL` (6.8 kΩ) y `ALCC` (10 kΩ) a 5.0 V están en la placa de control (602, 605).

## 4. Hoja 1 — Entrada y carga

Redes locales: `BAT+` (borne), `BAT_F` (después del fusible), `BAT_P` (después de la protección de polaridad).

| Ref. | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|
| J101 | Conector de batería, 2 vías | 19.6 A, AWG 12 | 1 → `BAT+`; 2 → `GND` |
| F101 | Fusible principal | 20 A, lento | 1 → `BAT+`; 2 → `BAT_F` |
| Q101, Q102 | MOSFET P de polaridad, en paralelo | DMP4015SPS | D → `BAT_F`; S → `BAT_P`; G → `G_POL` |
| R101 | Resistencia de compuerta | 10 kΩ | `G_POL` — `GND` |
| D101 | Zener de compuerta | 15 V | cátodo → `BAT_P`; ánodo → `G_POL` |
| R102 | Derivación | 2 mΩ, ≥ 2 W, conexión Kelvin | 1 → `BAT_P`; 2 → `N_IN` |
| U101 | Monitor de batería | LTC2944 (grado industrial) | SENSE− → `BAT_P` (lado de la batería); SENSE+ → `N_IN` (lado de cargas y cargador); GND → `GND`; SDA → `SDA`; SCL → `SCL`; ALCC → `ALCC` |
| C101 | Desacoplo de SENSE+ **[fuera del texto: hoja de datos del LTC2944]** | 1 µF | `N_IN` — `GND`, junto a U101 |
| J102 | Conector del cargador, 2 vías | 9 A | 1 → `CHG+`; 2 → `GND` |
| D102 | Diodo de bloqueo, doble de cátodo común, con disipador (≤ 22 °C/W) | STPS20H100C | A1 → `CHG+`; A2 → `CHG+`; K → `N_IN` |
| U102 | Regulador de la bobina del relé | LM1085-12 | IN → `CHG+`; OUT → `+12V_REL`; GND → `GND` |
| C102 | Condensador de entrada de U102 | 10 µF, 50 V | `CHG+` — `GND` |
| C103 | Condensador de salida de U102 | 10 µF, 16 V, tantalio | `+12V_REL` — `GND` |

Sentido de la medición de U101: la derivación queda entre la batería y el nodo `N_IN`, al que llegan el cargador y todas las cargas, de modo que toda la corriente de la batería pasa por ella en los dos sentidos. Con SENSE− del lado de la batería, la corriente se mide positiva en la carga y negativa en la descarga (hoja de datos del LTC2944).

Orientación de Q101 y Q102: con la batería bien conectada conduce el diodo interno (de drenador a fuente) y la compuerta, llevada a tierra, forma el canal; con la batería invertida no conducen.

## 5. Hoja 2 — Parada de emergencia y relé

| Ref. | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|
| D201 | TVS del nodo de entrada | SMBJ30A | cátodo → `N_IN`; ánodo → `GND` |
| C201 | Condensador del nodo de entrada | 2.2 µF, 100 V, X7R | `N_IN` — `GND` |
| Q201 | MOSFET P de parada, con disipador Aavid 529802B02500G y almohadilla Hi-Flow | SUP40P10-43 | S → `N_IN`; D → `N_SW`; G → `G_PAR` |
| R201 | Resistencia compuerta–fuente | 10 kΩ | `G_PAR` — `N_IN` |
| D202 | Zener de compuerta | 15 V | cátodo → `N_IN`; ánodo → `G_PAR` |
| R202 | Resistencia hacia el lazo de parada | 10 kΩ | `G_PAR` — `LAZO` |
| J201 | Conector del lazo de parada, 2 vías (contacto normalmente cerrado del pulsador en serie con el interruptor principal) | 1.5 mA | 1 → `LAZO`; 2 → `GND` |
| D203 | Diodo de libre circulación | PDS760 | cátodo → `N_SW`; ánodo → `GND` |
| K201 | Relé de recarga, contacto normalmente cerrado | T9GS2L14-12 | bobina+ → `+12V_REL`; bobina− → `GND`; común → `N_SW`; NC → `N_REL` |
| D204 | Diodo de la bobina | 1N4001 | cátodo → `+12V_REL`; ánodo → `GND` |

## 6. Hoja 3 — Barra de actuadores

Redes locales: `SRC3` (fuente de Q301 y lado de entrada de la derivación), `HG3` (compuerta), `TMR3`.

| Ref. | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|
| U301 | Controlador de arranque suave | LTC4364-2 | VCC → `N_REL`; HGATE → `HG3`; SOURCE → `SRC3`; SENSE → `SRC3`; OUT → `V_BARRA`; TMR → `TMR3`; FB → `GND`; OV → `GND`; UV → unido a SHDN (ambos sin otra conexión); DGATE → sin conectar; FLT → sin conectar; ENOUT → sin conectar; GND → `GND` |
| Q301 | MOSFET N de paso | PSMN4R8-100BSE | D → `N_REL`; S → `SRC3`; G → `HG3` |
| R301 | Detección de corriente | 2 mΩ, conexión Kelvin | 1 → `SRC3`; 2 → `V_BARRA` |
| D301 | Zener de compuerta | 15 V | cátodo → `HG3`; ánodo → `SRC3` |
| R302 | Serie de C_HG | 100 Ω | `HG3` — `CHG3` |
| D302 | Diodo en paralelo con R302 | (modelo sin definir) | en paralelo con R302; sentido según la aplicación de referencia de la hoja de datos |
| C301 | C_HG | 68 nF | `CHG3` — `GND` |
| C302 | C_TMR | 47 nF | `TMR3` — `GND` |
| J301 | Borne de la barra: DM542 de orientación (M1) | 2 vías | 1 → `V_BARRA`; 2 → `GND` |
| J302 | Borne de la barra: DM542 de elevación (M2) | 2 vías | 1 → `V_BARRA`; 2 → `GND` |
| J303 | Borne de la barra: tracción izquierda (M5) | 2 vías | 1 → `V_BARRA`; 2 → `GND` |
| J304 | Borne de la barra: tracción derecha (M6) | 2 vías | 1 → `V_BARRA`; 2 → `GND` |

Los condensadores de 470 µF y los TVS SMBJ30A de cada driver van en los bornes de cada driver, fuera de la placa (603).

## 7. Hoja 4 — Convertidor de servomotores

Redes locales: `SW4`, `BOOT4`, `FB4`, `COMP4`, `RT4`.

| Ref. | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|
| U401 | Convertidor reductor | TPS54560 | VIN → `V_BARRA`; SW → `SW4`; BOOT → `BOOT4`; FB → `FB4`; COMP → `COMP4`; RT/CLK → `RT4`; EN → sin conectar **[fuera del texto: la hoja de datos indica que sin conectar queda habilitado]**; GND y base térmica → `GND` |
| C401–C404 | Entrada | 4 × 2.2 µF, 100 V, X7R | `V_BARRA` — `GND` |
| C405 | BOOT | 0.1 µF, ≥ 10 V, X5R | `BOOT4` — `SW4` |
| D401 | Diodo Schottky | PDS760 (cátodo con 9.4 × 7.2 mm de cobre de 2 oz) | cátodo → `SW4`; ánodo → `GND` |
| L401 | Bobina | 6.8 µH, saturación 8.5 A, blindada | `SW4` — `V_SERVO` |
| C406, C407 | Salida | 2 × 470 µF, 50 V, SAMXON GT | `V_SERVO` — `GND` |
| C408 | Salida, alta frecuencia | 100 nF (el texto dice «condensadores cerámicos de 100 nF», sin cantidad) | `V_SERVO` — `GND` |
| R401 | Realimentación superior | 14.3 kΩ, 1 % | `V_SERVO` — `FB4` |
| R402 | Realimentación inferior | 2 kΩ, 1 % | `FB4` — `GND` |
| R403 | RT | 200 kΩ | `RT4` — `GND` |
| R404 | Compensación | 20 kΩ | `COMP4` — `CC4` |
| C409 | Compensación, serie | 56 nF | `CC4` — `GND` |
| C410 | Compensación, paralelo | 1 nF | `COMP4` — `GND` |
| J401 | Servomotor M3, 3 vías | 2.3 A en bloqueo | 1 → `PWM_M3`; 2 → `V_SERVO`; 3 → `GND` |
| J402 | Servomotor M4, 3 vías | 2.3 A en bloqueo | 1 → `PWM_M4`; 2 → `V_SERVO`; 3 → `GND` |

## 8. Hoja 5 — Línea protegida

Redes locales: `SRC5` (fuentes comunes de Q501 y Q502), `HG5`, `DG5`, `SNS5`, `LIM_OUT` (salida del limitador, antes de la bobina), `UV5`, `OV5`, `FB5`, `TMR5`.

| Ref. | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|
| U501 | Limitador | LTC4364-2 | VCC → `N_SW`; HGATE → `HG5`; SOURCE → `SRC5`; DGATE → `DG5`; SENSE → `SNS5`; OUT → `LIM_OUT`; UV → `UV5`; OV → `OV5`; FB → `FB5`; TMR → `TMR5`; ENOUT → `ENOUT_5V`; FLT → sin conectar **[el texto no la usa]**; SHDN → sin conectar **[fuera del texto: la hoja de datos indica que sin conectar queda encendido]**; GND → `GND` |
| Q501 | MOSFET N de paso (M1) | PSMN4R8-100BSE | D → `N_SW`; S → `SRC5`; G → `HG5` |
| Q502 | MOSFET N de diodo ideal (M2) | FDMS86150 | S → `SRC5`; D → `SNS5`; G → `DG5` |
| R501 | Detección de corriente | 20 mΩ, conexión Kelvin | 1 → `SNS5`; 2 → `LIM_OUT` |
| D501 | Zener de compuerta de Q501 | 15 V | cátodo → `HG5`; ánodo → `SRC5` |
| D502 | Zener de compuerta de Q502 | 15 V | cátodo → `DG5`; ánodo → `SRC5` |
| R502 | Serie de C_HG | 100 Ω | `HG5` — `CHG5` |
| D503 | Diodo en paralelo con R502 | (modelo sin definir) | en paralelo con R502; sentido según la aplicación de referencia de la hoja de datos |
| C501 | C_HG | 47 nF | `CHG5` — `GND` |
| C502 | C_TMR | 470 nF | `TMR5` — `GND` |
| R503 | Divisor UV/OV, superior | 261 kΩ | `N_SW` — `UV5` |
| R504 | Divisor UV/OV, medio | 6.65 kΩ | `UV5` — `OV5` |
| R505 | Divisor UV/OV, inferior | 10 kΩ | `OV5` — `GND` |
| R506 | Divisor de FB, superior | 130 kΩ | `LIM_OUT` — `FB5` |
| R507 | Divisor de FB, inferior | 5 kΩ | `FB5` — `GND` |
| C503 | Filtro π, primer electrolítico | 470 µF, 50 V, SAMXON GT | `LIM_OUT` — `GND` |
| C504 | Filtro π, primer cerámico | 22 µF, 50 V, X7R | `LIM_OUT` — `GND` |
| L501 | Filtro π, bobina | 4.7 µH, toroidal, saturación > 2.85 A | `LIM_OUT` — `V_PROT` |
| C505 | Filtro π, segundo electrolítico | 470 µF, 50 V, SAMXON GT | `V_PROT` — `GND` |
| C506 | Filtro π, segundo cerámico | 22 µF, 50 V, X7R | `V_PROT` — `GND` |

## 9. Hoja 6 — Convertidor de 5 V

Redes locales: `SW6`, `BOOT6`, `FB6`, `COMP6`, `RT6`.

| Ref. | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|
| U601 | Convertidor reductor | TPS54540 | VIN → `V_PROT`; SW → `SW6`; BOOT → `BOOT6`; FB → `FB6`; COMP → `COMP6`; RT/CLK → `RT6`; EN → `ENOUT_5V`; GND y base térmica → `GND` |
| C601, C602 | Entrada | 2 × 4.7 µF, 50 V, X7R | `V_PROT` — `GND` |
| R601 | Divisor de EN, superior | 560 kΩ | `V_PROT` — `ENOUT_5V` |
| R602 | Divisor de EN, inferior | 39 kΩ | `ENOUT_5V` — `GND` |
| C603 | BOOT | 0.1 µF, ≥ 10 V, X5R | `BOOT6` — `SW6` |
| D601 | Diodo Schottky | PDS760 (cátodo con 9.4 × 7.2 mm de cobre de 2 oz) | cátodo → `SW6`; ánodo → `GND` |
| L601 | Bobina | 6.8 µH, saturación 8.5 A, blindada | `SW6` — `+5V` |
| C604, C605 | Salida | 2 × 47 µF, ≥ 10 V, X7R | `+5V` — `GND` |
| R603 | Realimentación superior | 10.5 kΩ, 1 % | `+5V` — `FB6` |
| R604 | Realimentación inferior | 2 kΩ, 1 % | `FB6` — `GND` |
| R605 | RT | 200 kΩ | `RT6` — `GND` |
| R606 | Compensación | 18 kΩ | `COMP6` — `CC6` |
| C606 | Compensación, serie | 3.3 nF | `CC6` — `GND` |
| C607 | Compensación, paralelo | 33 pF | `COMP6` — `GND` |
| J601 | Salida de 5 V hacia la placa de control, 2 vías | 3.44 A, AWG 18 o mayor | 1 → `+5V`; 2 → `GND` |

El LM1084-3.3 y su diodo Schottky van en la placa de control (decisión del 2026-11-16).

## 10. Hoja 7 — Fuente meteorológica

Redes locales: `VIN7` (entrada del LMR33630), `SW7`, `BOOT7`, `VCC7`, `FB7`, `V_PRE` (salida del prerregulador), `V_LIN` (salida del LM1085), `ADJ7`, `V_MET` (barra meteorológica), `E7`, `B7`.

| Ref. | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|
| SW701 | Interruptor de la barra, dos polos y dos posiciones | (modelo sin definir) | Polo 1: común → `V_PROT`; posición 1 → `V_MET`; posición 2 → `VIN7`. Polo 2: común → `V_MET`; posición 1 → sin conectar; posición 2 → `V_LIN` |
| U701 | Prerregulador | LMR33630ADDA | VIN → `VIN7`; EN → `VIN7`; SW → `SW7`; BOOT → `BOOT7`; VCC → `VCC7`; PG → `PG7`; FB → `FB7`; PGND y base térmica (AGND) → `GND` |
| C701, C702 | Entrada | 2 × 10 µF, 50 V, X7R | `VIN7` — `GND` |
| C703 | Entrada, junto al integrado | 220 nF, 50 V, X7R | `VIN7` — `GND` |
| C704 | BOOT | 100 nF | `BOOT7` — `SW7` |
| C705 | VCC | 1 µF, 16 V | `VCC7` — `GND` |
| R701 | PG | 100 kΩ | `PG7` — `VCC7` |
| L701 | Bobina | 18 µH, saturación > 4.1 A (preferible > 5.05 A) | `SW7` — `V_PRE` |
| C706–C709 | Salida del prerregulador | 4 × 22 µF, 25 V, X7R | `V_PRE` — `GND` |
| Q701 | Transistor de seguimiento | 2N3906 | E → `E7`; B → `B7`; C → `FB7` |
| R702 | Emisor | 12 kΩ, 1 % | `V_PRE` — `E7` |
| R703 | Base | 10 kΩ, 1 % | `V_LIN` — `B7` |
| R704 | Colector / FB | 10 kΩ, 1 % | `FB7` — `GND` |
| U702 | Regulador lineal | LM1085 ajustable | IN → `V_PRE`; OUT → `V_LIN`; ADJ → `ADJ7` |
| C710 | Entrada de U702 | 10 µF | `V_PRE` — `GND` |
| C711 | Salida de U702 | 10 µF, tantalio | `V_LIN` — `GND` |
| R705 | Ajuste, superior | 120 Ω, 1 % | `V_LIN` — `ADJ7` |
| SW702 | Conmutador rotativo, tres posiciones | (modelo sin definir) | común → `ADJ7`; posición 1 → R706; posición 2 → R707; posición 3 → R708 |
| R706 | Ajuste, 3.3 V | 200 Ω, 1 % | posición 1 de SW702 — `GND` |
| R707 | Ajuste, 5.0 V | 360 Ω, 1 % | posición 2 de SW702 — `GND` |
| R708 + R709 | Ajuste, 12.0 V | 1 kΩ + 30 Ω en serie, 1 % | posición 3 de SW702 — `GND` |
| J701–J703 | Borneras de instrumentos, 2 vías | 0.1 A cada una | 1 → `V_MET`; 2 → `GND` |

## 11. Puntos abiertos

1. **Terminal SHDN de U501 y terminales FLT.** Resuelto (usuario, 2026-11-16): quedan sin conectar, como admite la hoja de datos del LTC4364.
2. **Terminal EN de U401 (TPS54560).** Resuelto (usuario, 2026-11-16): queda sin conectar.
3. **Diodos D302 y D503** (en paralelo con las resistencias de 100 Ω): sin modelo; su sentido debe copiarse de la aplicación de referencia de la hoja de datos al dibujar.
4. **Condensador C101** (1 µF en SENSE+ del LTC2944): lo pide la hoja de datos y no está en el texto.
5. **Cantidad de condensadores de 100 nF** en la salida del convertidor de servomotores: el texto no la fija; se dibuja uno.
6. **Modelos sin definir:** fusible y portafusible, conectores, bobinas (6.8 µH × 2, 18 µH, 4.7 µH), resistencias de derivación, interruptor SW701, conmutador SW702, diodos Zener de 15 V, disipador del diodo D102.
7. **SW701 y SW702:** en la placa o en el panel del gabinete con cable.
