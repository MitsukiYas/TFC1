# Esquemático de la placa de potencia — definición

Actualizado: 2026-11-17, con la numeración del proyecto `Electronica/TFCEnergyBoard` (una hoja raíz y tres hojas hijas). Fuente: `TFC/cap6/603` y `606` (valores) y las hojas de datos citadas allí (nombres de terminales).
Lo marcado **[fuera del texto]** no está en el `.tex`: viene de la hoja de datos indicada o es una propuesta por confirmar.

## 1. Hojas jerárquicas

| Hoja | Archivo | Página | Contenido |
|---|---|---|---|
| Raíz | `TFCEnergyBoard.kicad_sch` | 1 | Las tres hojas como bloques, las redes entre ellas y el conector de señales J01 hacia la placa de control |
| Módulo entrada | `modulo_entrada.kicad_sch` | 2 | Conector de batería, fusible, protección de polaridad, derivación y monitor LTC2944, cargador (diodo de bloqueo y regulador de la bobina), TVS y condensador del nodo de entrada, MOSFET de parada, diodo de libre circulación, lazo de parada y relé de recarga |
| Módulo energía actuadores | `modulo_energia_actuadores.kicad_sch` | 3 | Arranque suave de la barra (LTC4364-2), los cuatro bornes de la barra, convertidor TPS54560 de 6.5 V y los dos conectores de los servomotores |
| Módulo energía sensores | `modulo_energia_sensores.kicad_sch` | 4 | Limitador LTC4364-2, filtro π, convertidor TPS54540 de 5 V con su conector y la fuente meteorológica (interruptor, LMR33630, LM1085 ajustable, 2N3906, conmutador y tres borneras) |

Numeración de designadores: la centena indica la hoja (1 entrada, 2 actuadores, 3 sensores); el conector de la raíz es J01.

Los archivos `modulo_seguridad.kicad_sch`, `modulo_actuadores.kicad_sch` y `untitled.kicad_sch` no pertenecen a la jerarquía.

## 1b. Símbolos de KiCad

Los nombres son `biblioteca:símbolo` de las bibliotecas de KiCad 10.0, salvo el LTC2944.

- **Con símbolo propio:** LTC4364 (`Power_Management:LTC4364IS`, encapsulado SO-16), TPS54560BDDA, LMR33630ADDA, LM1085-12, LM1085-ADJ, 2N3906.
- **Con el símbolo de otra pieza del mismo patillaje:** el TPS54540 usa `Regulator_Switching:TPS54560BDDA` (los mismos ocho terminales y la misma base térmica). El SMBJ30A usa `Diode:SMAJ30A`, el mismo TVS unidireccional en encapsulado SMA: la huella debe cambiarse a `Diode_SMD:D_SMB`.
- **Genéricos:** los MOSFET (DMP4015SPS, SUP40P10-43, PSMN4R8-100BSE, FDMS86150) usan `Device:Q_PMOS` o `Device:Q_NMOS`, con los números de terminal del encapsulado por asignar; el PDS760, `Device:D_Schottky`; el STPS20H100C, `Device:D_Schottky_Dual_CommonCathode_AKA_Parallel`; el 1N4001, `Device:D`; el relé T9GS2L14-12, `Relay:Relay_SPST-NC` (bobina A1/A2, contacto 11/12).
- **Símbolo propio del proyecto:** el LTC2944 está en la biblioteca `TESIS` (no existe en las de KiCad; `Battery_Management:LTC2942` tiene otro patillaje). Terminales: SENSE+ 1; GND 2, 3 y 7; SCL 4; SDA 5; ALCC 6; SENSE− 8. El símbolo no tiene la base expuesta (9); la hoja de datos indica que puede quedar abierta o unida a GND.
- **Resistencias de derivación:** `Device:R_Shunt`, con conexión Kelvin, como piden las hojas de datos del LTC4364 y del LTC2944. Terminales 1 y 4: corriente; terminales 2 y 3: medición (el 2 del lado del 1, el 3 del lado del 4).
- **Condensadores:** `Device:C_Polarized` para los electrolíticos y los de tantalio; `Device:C` para los cerámicos.
- **Símbolos de alimentación:** `power:GND` y `power:+5V`; las demás redes van con etiquetas locales o jerárquicas.

## 2. Redes entre hojas

| Red | Qué es | Sale de | Entra en |
|---|---|---|---|
| `GND` | Tierra (símbolo global) | todas | todas |
| `N_SW` | Salida del MOSFET de parada | Entrada | Sensores (limitador) |
| `N_REL` | Salida del contacto del relé | Entrada | Actuadores (arranque suave) |
| `SDA`, `SCL`, `ALCC` | Bus I²C y alerta del LTC2944 | Entrada | Raíz (J01) |
| `PWM_M3`, `PWM_M4` | Señal de los servomotores | Raíz (J01) | Actuadores |

## 3. Raíz

| Ref. | Símbolo de KiCad | Elemento | Terminal → red |
|---|---|---|---|
| J01 | `Connector_Generic:Conn_01x06` | Conector de señales, 6 vías, hacia la placa de control | 1 → `GND`; 2 → `PWM_M4`; 3 → `PWM_M3`; 4 → `SCL`; 5 → `SDA`; 6 → `ALCC` |

Las resistencias pull-up de `SDA`, `SCL` (6.8 kΩ) y `ALCC` (10 kΩ) a 5.0 V están en la placa de control (602, 605). El conector de la placa de control debe usar el mismo orden.

## 4. Módulo entrada

Redes locales con etiqueta: `BAT+` (borne), `BAT_F` (después del fusible), `BAT_P` (después de la protección de polaridad), `G_POL`, `N_IN` (nodo de entrada, punto del cargador), `CHG+` (positivo del cargador, antes del diodo de bloqueo), `+12V_REL`. Sin etiqueta: compuerta de Q103 (`G_PAR` en este documento) y el borne 1 del lazo (`LAZO`).

| Ref. | Símbolo de KiCad | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|---|
| J101 | `Connector:Screw_Terminal_01x02` | Conector de batería, 2 vías | 19.6 A, AWG 12 | 1 → `BAT+`; 2 → `GND` |
| F101 | `Device:Fuse` | Fusible principal | 20 A, lento | 1 → `BAT+`; 2 → `BAT_F` |
| Q101, Q102 | `Device:Q_PMOS` | MOSFET P de polaridad, en paralelo | DMP4015SPS | D → `BAT_F`; S → `BAT_P`; G → `G_POL` |
| R101 | `Device:R` | Resistencia de compuerta | 10 kΩ | `G_POL` — `GND` |
| D101 | `Device:D_Zener` | Zener de compuerta | 15 V | cátodo → `BAT_P`; ánodo → `G_POL` |
| R102 | `Device:R_Shunt` | Derivación | 2 mΩ, ≥ 2 W, conexión Kelvin | 1 → `BAT_P`; 2 → SENSE− de U101; 3 → SENSE+ de U101; 4 → `N_IN` |
| U101 | `TESIS:LTC2944` | Monitor de batería | LTC2944 (grado industrial) | SENSE− (8) → R102.2 (lado de la batería); SENSE+ (1) → R102.3 (lado de cargas y cargador); GND (2, 3, 7) → `GND`; SDA (5) → `SDA`; SCL (4) → `SCL`; ALCC (6) → `ALCC` |
| C101 | `Device:C` | Desacoplo de SENSE+ **[fuera del texto: hoja de datos del LTC2944]** | 1 µF | `N_IN` — `GND`, junto a U101 |
| J102 | `Connector:Screw_Terminal_01x02` | Conector del cargador, 2 vías | 9 A | 1 → `CHG+`; 2 → `GND` |
| D102 | `Device:D_Schottky_Dual_CommonCathode_AKA_Parallel` | Diodo de bloqueo, doble de cátodo común, con disipador (≤ 22 °C/W) | STPS20H100C | 1 y 3 (ánodos) → `CHG+`; 2 (cátodo) → `N_IN` |
| U102 | `Regulator_Linear:LM1085-12` | Regulador de la bobina del relé | LM1085-12 | IN → `CHG+`; OUT → `+12V_REL`; GND → `GND` |
| C102 | `Device:C_Polarized` | Condensador de entrada de U102 | 10 µF, 50 V | `CHG+` — `GND` |
| C103 | `Device:C_Polarized` | Condensador de salida de U102 | 10 µF, 16 V, tantalio | `+12V_REL` — `GND` |
| D104 | `Diode:SMAJ30A` | TVS del nodo de entrada | SMBJ30A (huella `D_SMB`) | cátodo → `N_IN`; ánodo → `GND` |
| C104 | `Device:C` | Condensador del nodo de entrada | 2.2 µF, 100 V, X7R | `N_IN` — `GND` |
| Q103 | `Device:Q_PMOS` | MOSFET P de parada, con disipador Aavid 529802B02500G y almohadilla Hi-Flow | SUP40P10-43 | S → `N_IN`; D → `N_SW`; G → `G_PAR` |
| R104 | `Device:R` | Resistencia compuerta–fuente | 10 kΩ | `N_IN` — `G_PAR` |
| D103 | `Device:D_Zener` | Zener de compuerta | 15 V | cátodo → `N_IN`; ánodo → `G_PAR` |
| R103 | `Device:R` | Resistencia hacia el lazo de parada | 10 kΩ | `G_PAR` — `LAZO` |
| J103 | `Connector:Screw_Terminal_01x02` | Conector del lazo de parada, 2 vías (contacto normalmente cerrado del pulsador en serie con el interruptor principal) | 1.5 mA | 1 → `LAZO`; 2 → `GND` |
| D105 | `Device:D_Schottky` | Diodo de libre circulación | PDS760 | cátodo → `N_SW`; ánodo → `GND` |
| K101 | `Relay:Relay_SPST-NC` | Relé de recarga, contacto normalmente cerrado | T9GS2L14-12 | A1 (bobina+) → `+12V_REL`; A2 (bobina−) → `GND`; 12 → `N_SW`; 11 → `N_REL` |
| D106 | `Device:D` | Diodo de la bobina | 1N4001 | cátodo → `+12V_REL`; ánodo → `GND` |
| D107 | `Device:LED` | Indicador de sistema encendido (interruptor principal cerrado y parada sin pulsar) | LED verde | ánodo → R105; cátodo → `GND` |
| R105 | `Device:R` | Resistencia de D107 | 12 kΩ | `N_SW` — ánodo de D107 |
| D108 | `Device:LED` | Indicador de carga (cargador conectado y bobina del relé alimentada) | LED amarillo | ánodo → R106; cátodo → `GND` |
| R106 | `Device:R` | Resistencia de D108 | 4.7 kΩ | `+12V_REL` — ánodo de D108 |

Sentido de la medición de U101: la derivación queda entre la batería y el nodo `N_IN`, al que llegan el cargador y todas las cargas, de modo que toda la corriente de la batería pasa por ella en los dos sentidos. Con SENSE− del lado de la batería, la corriente se mide positiva en la carga y negativa en la descarga (hoja de datos del LTC2944).

Orientación de Q101 y Q102: con la batería bien conectada conduce el diodo interno (de drenador a fuente) y la compuerta, llevada a tierra, forma el canal; con la batería invertida no conducen.

## 5. Módulo energía actuadores

Redes locales con etiqueta: `HG3`, `CHG3`, `SRC3` (fuente de Q201, terminal 1 de la derivación), `SNS3` (medición, terminal 2), `TMR3`, `FLT3`, `V_BARRA` (21.0 a 29.4 V), `SW4`, `BOOT4`, `COMP4`, `RT4`, `V_SERVO`. Sin etiqueta: terminal 3 de R201 con OUT de U201 (`OUT3` en este documento), realimentación de U202 (`FB4`), nodo de la compensación (`CC4`), UV unido a SHDN.

| Ref. | Símbolo de KiCad | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|---|
| U201 | `Power_Management:LTC4364IS` | Controlador de arranque suave | LTC4364-2 | VCC (8) → `N_REL`; HGATE (6) → `HG3`; SOURCE (5) → `SRC3`; SENSE (2) → `SNS3`; OUT (1) → `OUT3`; TMR (15) → `TMR3`; FB (16) → `GND`; OV (11) → `GND`; UV (10) → unido a SHDN (9), sin otra conexión; FLT (13) → `FLT3`; DGATE (4), ENOUT (14), NC (3, 7) → sin conectar; GND (12) → `GND` |
| Q201 | `Device:Q_NMOS` | MOSFET N de paso | PSMN4R8-100BSE | D → `N_REL`; S → `SRC3`; G → `HG3` |
| R201 | `Device:R_Shunt` | Detección de corriente | 2 mΩ, conexión Kelvin | 1 → `SRC3`; 2 → `SNS3`; 3 → `OUT3`; 4 → `V_BARRA` |
| D201 | `Device:D_Zener` | Zener de compuerta | 15 V | cátodo → `HG3`; ánodo → `SRC3` |
| R202 | `Device:R` | Serie de C_HG | 100 Ω | `HG3` — `CHG3` |
| D202 | `Device:D` | Diodo en paralelo con R202 | (modelo sin definir) | cátodo → `CHG3`; ánodo → `HG3` (como la aplicación de referencia de la hoja de datos) |
| C201 | `Device:C` | C_HG | 68 nF | `CHG3` — `GND` |
| C202 | `Device:C` | C_TMR | 47 nF | `TMR3` — `GND` |
| J201 | `Connector:Screw_Terminal_01x02` | Borne de la barra: DM542 de orientación (M1) | 2 vías | 1 → `V_BARRA`; 2 → `GND` |
| J202 | `Connector:Screw_Terminal_01x02` | Borne de la barra: DM542 de elevación (M2) | 2 vías | 1 → `V_BARRA`; 2 → `GND` |
| J203 | `Connector:Screw_Terminal_01x02` | Borne de la barra: tracción izquierda (M5) | 2 vías | 1 → `V_BARRA`; 2 → `GND` |
| J204 | `Connector:Screw_Terminal_01x02` | Borne de la barra: tracción derecha (M6) | 2 vías | 1 → `V_BARRA`; 2 → `GND` |
| U202 | `Regulator_Switching:TPS54560BDDA` | Convertidor reductor | TPS54560 | BOOT (1) → `BOOT4`; VIN (2) → `V_BARRA`; EN (3) → sin conectar **[fuera del texto: la hoja de datos indica que sin conectar queda habilitado]**; RT/CLK (4) → `RT4`; FB (5) → `FB4`; COMP (6) → `COMP4`; GND (7) y base térmica (9) → `GND`; SW (8) → `SW4` |
| C206–C209 | `Device:C` | Entrada | 4 × 2.2 µF, 100 V, X7R | `V_BARRA` — `GND` |
| C205 | `Device:C` | BOOT | 0.1 µF, ≥ 10 V, X5R | `SW4` — `BOOT4` |
| D203 | `Device:D_Schottky` | Diodo Schottky | PDS760 (cátodo con 9.4 × 7.2 mm de cobre de 2 oz) | cátodo → `SW4`; ánodo → `GND` |
| L201 | `Device:L` | Bobina | 6.8 µH, saturación 8.5 A, blindada | `SW4` — `V_SERVO` |
| C210, C211 | `Device:C_Polarized` | Salida | 2 × 470 µF, 50 V, SAMXON GT | `V_SERVO` — `GND` |
| C212 | `Device:C` | Salida, alta frecuencia | 100 nF | `V_SERVO` — `GND` |
| R205 | `Device:R` | Realimentación superior | 14.3 kΩ, 1 % | `V_SERVO` — `FB4` |
| R206 | `Device:R` | Realimentación inferior | 2 kΩ, 1 % | `FB4` — `GND` |
| R204 | `Device:R` | RT | 200 kΩ | `RT4` — `GND` |
| R203 | `Device:R` | Compensación | 20 kΩ | `COMP4` — `CC4` |
| C204 | `Device:C` | Compensación, serie | 56 nF | `CC4` — `GND` |
| C203 | `Device:C` | Compensación, paralelo | 1 nF | `COMP4` — `GND` |
| J205 | `Connector_Generic:Conn_01x03` | Servomotor M3, 3 vías | 2.3 A en bloqueo | 1 → `PWM_M3`; 2 → `V_SERVO`; 3 → `GND` |
| J206 | `Connector_Generic:Conn_01x03` | Servomotor M4, 3 vías | 2.3 A en bloqueo | 1 → `PWM_M4`; 2 → `V_SERVO`; 3 → `GND` |
| D204 | `Device:LED` | Indicador de barra alimentada | LED verde | ánodo → R207; cátodo → `GND` |
| R207 | `Device:R` | Resistencia de D204 | 12 kΩ | `V_BARRA` — ánodo de D204 |
| D205 | `Device:LED` | Indicador de falla de la barra (FLT de U201: sobrecorriente o cortocircuito) | LED rojo | ánodo → R208; cátodo → `FLT3` |
| R208 | `Device:R` | Resistencia de D205 | 15 kΩ | `N_REL` — ánodo de D205 |
| D206 | `Device:LED` | Indicador del convertidor de servomotores | LED verde | ánodo → R209; cátodo → `GND` |
| R209 | `Device:R` | Resistencia de D206 | 2.2 kΩ | `V_SERVO` — ánodo de D206 |

Los condensadores de 470 µF y los TVS SMBJ30A de cada driver van en los bornes de cada driver, fuera de la placa (603).

Por qué U201 no usa UV, OV ni FB, a diferencia de U301 (redactado en 606): las cargas de la barra admiten los 48.4 V de los TVS (50 V los DM542, 60 V los controladores de tracción y el TPS54560) y las sobretensiones vienen de los motores, del lado de la salida; el corte por baja tensión lo hace el firmware con la alerta del LTC2944, y un umbral aquí actuaría con la caída de unos 2 V de los picos de corriente. UV va unido a SHDN porque así lo indica la hoja de datos del LTC4364 cuando UV no se usa; SHDN tiene una fuente de corriente interna que enciende el integrado, por lo que el aviso de entrada sin excitar de la comprobación eléctrica está excluido.

## 6. Módulo energía sensores

Redes locales con etiqueta: `HG5`, `CHG5`, `TMR5`, `FLT5`, `ENOUT_5V`, `LIM_OUT` (salida del limitador, antes de la bobina), `V_PROT` (línea protegida, 20.84 a 29.4 V), `BOOT6`, `SW6`, `RT6`, `FB6`, `+5V`, `VIN7`, `VCC7`, `PG7`, `FB7`, `V_PRE`, `V_LIN`, `MET_ADJ`, `V_MET`. Sin etiqueta: fuentes comunes de Q301 y Q302 (`SRC5` en este documento), compuerta de Q302 (`DG5`), drenador de Q302 y terminal 1 de R304 (`SNS5`), terminal 2 de R304 con SENSE de U301, terminal 3 de R304 con OUT de U301, `UV5`, `OV5`, `FB5`, `CC6`, `SW7`, `BOOT7`, emisor y base de Q303.

| Ref. | Símbolo de KiCad | Elemento | Valor / modelo | Terminal → red |
|---|---|---|---|---|
| U301 | `Power_Management:LTC4364IS` | Limitador | LTC4364-2 | VCC (8) → `N_SW`; HGATE (6) → `HG5`; SOURCE (5) → `SRC5`; DGATE (4) → `DG5`; SENSE (2) → R304.2; OUT (1) → R304.3; UV (10) → `UV5`; OV (11) → `OV5`; FB (16) → `FB5`; TMR (15) → `TMR5`; ENOUT (14) → `ENOUT_5V`; FLT (13) → `FLT5`; SHDN (9), NC (3, 7) → sin conectar; GND (12) → `GND` |
| Q301 | `Device:Q_NMOS` | MOSFET N de paso (M1) | PSMN4R8-100BSE | D → `N_SW`; S → `SRC5`; G → `HG5` |
| Q302 | `Device:Q_NMOS` | MOSFET N de diodo ideal (M2) | FDMS86150 | S → `SRC5`; D → `SNS5`; G → `DG5` |
| R304 | `Device:R_Shunt` | Detección de corriente | 20 mΩ, conexión Kelvin | 1 → `SNS5`; 2 → SENSE de U301; 3 → OUT de U301; 4 → `LIM_OUT` |
| D301 | `Device:D_Zener` | Zener de compuerta de Q301 | 15 V | cátodo → `HG5`; ánodo → `SRC5` |
| D302 | `Device:D_Zener` | Zener de compuerta de Q302 | 15 V | cátodo → `DG5`; ánodo → `SRC5` |
| R307 | `Device:R` | Serie de C_HG | 100 Ω | `CHG5` — `HG5` |
| D303 | `Device:D` | Diodo en paralelo con R307 | (modelo sin definir) | cátodo → `CHG5`; ánodo → `HG5` |
| C301 | `Device:C` | C_HG | 47 nF | `CHG5` — `GND` |
| C302 | `Device:C` | C_TMR | 470 nF | `TMR5` — `GND` |
| R301 | `Device:R` | Divisor UV/OV, superior | 261 kΩ | `N_SW` — `UV5` |
| R302 | `Device:R` | Divisor UV/OV, medio | 6.65 kΩ | `UV5` — `OV5` |
| R303 | `Device:R` | Divisor UV/OV, inferior | 10 kΩ | `OV5` — `GND` |
| R305 | `Device:R` | Divisor de FB, superior | 130 kΩ | `LIM_OUT` — `FB5` |
| R306 | `Device:R` | Divisor de FB, inferior | 5 kΩ | `FB5` — `GND` |
| C304 | `Device:C_Polarized` | Filtro π, primer electrolítico | 470 µF, 50 V, SAMXON GT | `LIM_OUT` — `GND` |
| C303 | `Device:C` | Filtro π, primer cerámico | 22 µF, 50 V, X7R | `LIM_OUT` — `GND` |
| L301 | `Device:L` | Filtro π, bobina | 4.7 µH, toroidal, saturación > 2.85 A | `LIM_OUT` — `V_PROT` |
| C306 | `Device:C_Polarized` | Filtro π, segundo electrolítico | 470 µF, 50 V, SAMXON GT | `V_PROT` — `GND` |
| C305 | `Device:C` | Filtro π, segundo cerámico | 22 µF, 50 V, X7R | `V_PROT` — `GND` |
| U302 | `Regulator_Switching:TPS54560BDDA` | Convertidor reductor | TPS54540 | BOOT (1) → `BOOT6`; VIN (2) → `V_PROT`; EN (3) → `ENOUT_5V`; RT/CLK (4) → `RT6`; FB (5) → `FB6`; COMP (6) → `COMP6`; GND (7) y base térmica (9) → `GND`; SW (8) → `SW6` |
| C307, C308 | `Device:C` | Entrada | 2 × 4.7 µF, 50 V, X7R | `V_PROT` — `GND` |
| R309 | `Device:R` | Divisor de EN, superior | 560 kΩ | `V_PROT` — `ENOUT_5V` |
| R308 | `Device:R` | Divisor de EN, inferior | 39 kΩ | `ENOUT_5V` — `GND` |
| C311 | `Device:C` | BOOT | 0.1 µF, ≥ 10 V, X5R | `SW6` — `BOOT6` |
| D304 | `Device:D_Schottky` | Diodo Schottky | PDS760 (cátodo con 9.4 × 7.2 mm de cobre de 2 oz) | cátodo → `SW6`; ánodo → `GND` |
| L302 | `Device:L` | Bobina | 6.8 µH, saturación 8.5 A, blindada | `SW6` — `+5V` |
| C312, C313 | `Device:C` | Salida | 2 × 47 µF, ≥ 10 V, X7R | `+5V` — `GND` |
| R312 | `Device:R` | Realimentación superior | 10.5 kΩ, 1 % | `+5V` — `FB6` |
| R313 | `Device:R` | Realimentación inferior | 2 kΩ, 1 % | `FB6` — `GND` |
| R311 | `Device:R` | RT | 200 kΩ | `GND` — `RT6` |
| R310 | `Device:R` | Compensación | 18 kΩ | `COMP6` — `CC6` |
| C310 | `Device:C` | Compensación, serie | 3.3 nF | `CC6` — `GND` |
| C309 | `Device:C` | Compensación, paralelo | 33 pF | `COMP6` — `GND` |
| J301 | `Connector:Screw_Terminal_01x02` | Salida de 5 V hacia la placa de control, 2 vías | 3.44 A, AWG 18 o mayor | 1 → `+5V`; 2 → `GND` |
| SW301 | `Switch:SW_DPDT_x2` | Interruptor de la barra meteorológica, dos polos y dos posiciones | (modelo sin definir) | Polo A: 2 (común) → `V_PROT`; 1 → `V_MET`; 3 → `VIN7`. Polo B: 5 (común) → `V_LIN`; 4 → sin conectar; 6 → `V_MET` |
| U303 | `Regulator_Switching:LMR33630ADDA` | Prerregulador | LMR33630ADDA | PGND (1) → `GND`; VIN (2) y EN (3) → `VIN7`; PG (4) → `PG7`; FB (5) → `FB7`; VCC (6) → `VCC7`; BOOT (7) → `BOOT7`; SW (8) → `SW7`; base térmica (9) → `GND` |
| C314, C315 | `Device:C` | Entrada | 2 × 10 µF, 50 V, X7R | `VIN7` — `GND` |
| C316 | `Device:C` | Entrada, junto al integrado | 220 nF, 50 V, X7R | `VIN7` — `GND` |
| C318 | `Device:C` | BOOT | 100 nF | `SW7` — `BOOT7` |
| C317 | `Device:C` | VCC | 1 µF, 16 V | `VCC7` — `GND` |
| R314 | `Device:R` | PG | 100 kΩ | `PG7` — `VCC7` |
| L303 | `Device:L` | Bobina | 18 µH, saturación > 4.1 A (preferible > 5.05 A) | `SW7` — `V_PRE` |
| C319–C322 | `Device:C` | Salida del prerregulador | 4 × 22 µF, 25 V, X7R | `V_PRE` — `GND` |
| Q303 | `Transistor_BJT:2N3906` | Transistor de seguimiento | 2N3906 | E (1) → R315; B (2) → R318; C (3) → `FB7` |
| R315 | `Device:R` | Emisor | 12 kΩ, 1 % | `V_PRE` — emisor de Q303 |
| R318 | `Device:R` | Base | 10 kΩ, 1 % | `V_LIN` — base de Q303 |
| R316 | `Device:R` | Colector / FB | 10 kΩ, 1 % | `FB7` — `GND` |
| U304 | `Regulator_Linear:LM1085-ADJ` | Regulador lineal | LM1085 ajustable | ADJ (1) → `MET_ADJ`; OUT (2) → `V_LIN`; IN (3) → `V_PRE` |
| C323 | `Device:C` | Entrada de U304 | 10 µF | `V_PRE` — `GND` |
| C324 | `Device:C_Polarized` | Salida de U304 | 10 µF, tantalio | `V_LIN` — `GND` |
| R317 | `Device:R` | Ajuste, superior | 120 Ω, 1 % | `V_LIN` — `MET_ADJ` |
| SW302 | `Switch:SW_SP3T` | Conmutador rotativo, tres posiciones | (modelo sin definir) | 3 (común) → `MET_ADJ`; 1 → R322; 2 → R321; 4 → R319 |
| R322 | `Device:R` | Ajuste, 3.3 V | 200 Ω, 1 % | SW302.1 — `GND` |
| R321 | `Device:R` | Ajuste, 5.0 V | 360 Ω, 1 % | SW302.2 — `GND` |
| R319 + R320 | `Device:R` | Ajuste, 12.0 V | 1 kΩ + 30 Ω en serie, 1 % | SW302.4 — R319 — R320 — `GND` |
| J302 | `Connector:Screw_Terminal_01x02` | Bornera del piranómetro, 2 vías | 0.1 A | 1 → `V_MET`; 2 → `GND` |
| J303 | `Connector:Screw_Terminal_01x02` | Bornera del anemómetro, 2 vías | 0.1 A | 1 → `V_MET`; 2 → `GND` |
| J304 | `Connector:Screw_Terminal_01x02` | Bornera de la sonda de temperatura y humedad, 2 vías | 0.1 A | 1 → `V_MET`; 2 → `GND` |
| D305 | `Device:LED` | Indicador de 5 V | LED verde | ánodo → R323; cátodo → `GND` |
| R323 | `Device:R` | Resistencia de D305 | 1.5 kΩ | `+5V` — ánodo de D305 |
| D306 | `Device:LED` | Indicador de falla de la línea de control (FLT de U301: sobrecorriente o sobretensión) | LED rojo | ánodo → R324; cátodo → `FLT5` |
| R324 | `Device:R` | Resistencia de D306 | 15 kΩ | `N_SW` — ánodo de D306 |

El LM1084-3.3 y su diodo Schottky van en la placa de control (decisión del 2026-11-16).

## 7. Huellas

Nombres `biblioteca:huella` comprobados en las bibliotecas de KiCad 10.0. Estado: **D** = fijado por el texto o la hoja de datos; **P** = propuesta (pieza sin modelo o cambio de encapsulado), por confirmar al elegir la pieza; **C** = no existe en las bibliotecas, hay que crearla en `TESIS`.

### 7a. Antes de asignar: números de terminal de los MOSFET

`Device:Q_NMOS` y `Device:Q_PMOS` tienen los terminales numerados con letras (`G`, `S`, `D`) y las huellas con números, así que no se conectan. Copiar cada MOSFET a la biblioteca `TESIS` con los números de su hoja de datos:

| Pieza | Encapsulado | Terminales (hoja de datos) | Huella |
|---|---|---|---|
| PSMN4R8-100BSE (Q201, Q301) | D2PAK (SOT404) | G = 1; D = 2 (base de montaje); S = 3 | `Package_TO_SOT_SMD:TO-263-3_TabPin2` (D) |
| SUP40P10-43 (Q103) | TO-220AB | G = 1; D = 2; S = 3 | `Package_TO_SOT_THT:TO-220-3_Vertical` (D, va con el disipador Aavid) |
| DMP4015SPS (Q101, Q102) | PowerDI5060-8 | S = 1, 2, 3; G = 4; D = 5–8 y base | `Package_DFN_QFN:PQFN-8-EP_6x5mm_P1.27mm_Generic` (P: genérica de 5 × 6 mm; comparar las almohadillas con el patrón recomendado de la hoja de datos) |
| FDMS86150 (Q302) | Power 56 (PQFN de 5 × 6 mm) | S = 1, 2, 3; G = 4; D = 5–8 y base | `Package_DFN_QFN:PQFN-8-EP_6x5mm_P1.27mm_Generic` (P: igual que el anterior) |

En la huella genérica las almohadillas 1, 2 y 3 son fuentes, la 4 la compuerta y la 5 el drenador con la base; en el símbolo, los terminales 2 y 3 pueden agregarse como terminales ocultos apilados sobre S. Comprobar en las hojas de datos del DMP4015SPS y del FDMS86150 el orden de terminales de la vista superior antes de dibujar.

### 7b. Lista por componente

| Ref. | Pieza | Huella | Estado |
|---|---|---|---|
| U101 | LTC2944 (DFN de 8 terminales, 3 × 3 mm, paso 0.50 mm, base 1.65 × 2.38 mm) | `Package_DFN_QFN:DFN-8-1EP_3x3mm_P0.5mm_EP1.65x2.38mm` | D |
| U201, U301 | LTC4364IS | `Package_SO:SOIC-16_3.9x9.9mm_P1.27mm` | D (ya asignada) |
| U202, U302 | TPS54560 / TPS54540 | `Package_SO:Texas_R-PDSO-G8_EP2.95x4.9mm_Mask2.4x3.1mm_ThermalVias` | D (ya asignada) |
| U303 | LMR33630ADDA | `Package_SO:Texas_HSOP-8-1EP_3.9x4.9mm_P1.27mm_ThermalVias` | D (ya asignada) |
| U102, U304 | LM1085-12, LM1085-ADJ | `Package_TO_SOT_SMD:TO-263-3_TabPin2` (1 ADJ/GND, 2 OUT en la aleta, 3 IN) | D (usuario, 2026-11-17: SMD). Pendiente en 606: el texto usa TO-220 (22.8 °C/W); en TO-263 la hoja de datos da 40.6 °C/W y U102 sube unos 53 °C con 1.3 W en lugar de 30 °C |
| Q101–Q103, Q201, Q301, Q302 | MOSFET | ver 7a | — |
| Q303 | 2N3906 → MMBT3906 (SMD, usuario, 2026-11-17) | `Package_TO_SOT_SMD:SOT-23` | Pendiente: cambiar antes el símbolo a `Transistor_BJT:MMBT3906` (terminales B, E, C); con el símbolo del 2N3906 (E, B, C) la huella SOT-23 intercambia emisor y base. Pendiente en 606: nombrar el MMBT3906 y su hoja de datos |
| D101, D103, D201, D301, D302 | Zener de 15 V (sin modelo) | `Diode_SMD:D_SOD-123` | P |
| D102 | STPS20H100C | `Package_TO_SOT_THT:TO-220-3_Vertical` con disipador | P: el texto pide un disipador de ≤ 22 °C/W; la versión D2PAK existe pero requeriría calcular el área de cobre |
| D104 | SMBJ30A | `Diode_SMD:D_SMB` | D |
| D105, D203, D304 | PDS760 | `Diode_SMD:D_PowerDI-5` | D |
| D106 | 1N4001 → diodo SMD de 1 A y ≥ 50 V (usuario, 2026-11-17) | `Diode_SMD:D_SMA` | D. Pendiente: elegir el modelo y cambiar 606, que nombra el 1N4001 |
| D202, D303 | Diodo de señal (sin modelo) | `Diode_SMD:D_SOD-123` | P |
| D107, D108, D204–D206, D305, D306 | LED | `LED_SMD:LED_0805_2012Metric` | P |
| R102, R201 | Derivación de 2 mΩ | `Resistor_SMD:R_Shunt_Vishay_WSK2512_6332Metric_T1.19mm` o la huella Kelvin del modelo elegido | P: R102 debe disipar ≥ 2 W; comprobar la potencia del modelo antes de usar una 2512 |
| R304 | Derivación de 20 mΩ | `Resistor_SMD:R_Shunt_Vishay_WSK2512_6332Metric_T1.19mm` | P |
| R101, R103, R104 | 10 kΩ a 29.4 V (86 mW) | `Resistor_SMD:R_1206_3216Metric` | P |
| Demás resistencias (incluidas las de los LED, ≤ 63 mW) | | `Resistor_SMD:R_0805_2012Metric` | P |
| C104, C206–C209 | 2.2 µF, 100 V, X7R | `Capacitor_SMD:C_1210_3225Metric` | P |
| C303, C305 | 22 µF, 50 V, X7R | `Capacitor_SMD:C_1210_3225Metric` (o `C_2220_5750Metric` según el modelo) | P |
| C307, C308, C314, C315 | 4.7 µF y 10 µF, 50 V, X7R | `Capacitor_SMD:C_1210_3225Metric` | P |
| C312, C313, C319–C322 | 47 µF ≥ 10 V y 22 µF 25 V, X7R | `Capacitor_SMD:C_1210_3225Metric` | P |
| C323 | 10 µF (entrada del LM1085) | `Capacitor_SMD:C_1206_3216Metric` | P |
| C103, C324 | 10 µF, 16 V, tantalio | `Capacitor_Tantalum_SMD:CP_EIA-3528-21_Kemet-B` | P |
| C102 | 10 µF, 50 V, polarizado | `Capacitor_SMD:CP_Elec_6.3x7.7` | P |
| C210, C211, C304, C306 | 470 µF, 50 V, SAMXON GT (radial) | `Capacitor_THT:CP_Radial_D10.0mm_P5.00mm` o `CP_Radial_D12.5mm_P5.00mm` | P: según el diámetro de la hoja de datos del SAMXON GT; el texto fija esta serie radial |
| C201, C202, C301, C302 | C_HG y C_TMR | `Capacitor_SMD:C_0805_2012Metric` (470 nF: `C_1206_3216Metric`) | P: la hoja de datos del LTC4364 pide C_TMR con bajos coeficientes de tensión y temperatura |
| Demás cerámicos (≤ 1 µF) | | `Capacitor_SMD:C_0805_2012Metric` | P |
| L201, L302 | 6.8 µH, saturación 8.5 A, blindada | según el modelo (por ejemplo `Inductor_SMD:L_Coilcraft_XAL1010-XXX` o `L_Vishay_IHLP-4040`) | P: elegir la bobina primero |
| L303 | 18 µH, saturación > 4.1 A | según el modelo | P |
| L301 | 4.7 µH, toroidal | THT, según el modelo | P: el texto dice toroidal |
| F101 | 20 A, lento | `Fuse:FuseHolder_Blade_ATO_Littelfuse_FLR_178.6165` (portafusible de cuchilla, THT) | P: falta elegir el fusible |
| K101 | T9GS2L14-12 | THT | C: crear desde el patrón de circuito impreso de la hoja de datos del T9G, con las almohadillas A1, A2, 11 y 12 como en el símbolo; `Relay_THT:Relay_SPST_PotterBrumfield_T9AP1D52_12V30A` es otra serie |
| J101 | Batería, 19.6 A, AWG 12 | bornera de paso 7.5 mm o mayor, por ejemplo `TerminalBlock_RND:TerminalBlock_RND_205-00067_1x02_P7.50mm_Horizontal` | P: elegir una bornera de ≥ 20 A para AWG 12 |
| J102, J201–J204, J301 | Cargador (9 A), barra, 5 V (3.44 A) | `TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-3-2-5.08_1x02_P5.08mm_Horizontal` | P: comprobar la corriente de cada bornera |
| J103, J302–J304 | Lazo de parada e instrumentos (≤ 0.1 A) | `TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-2-5.08_1x02_P5.08mm_Horizontal` | P |
| J205, J206 | Servomotores (2.3 A en bloqueo) | `Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical` | P: comprobar la corriente del conector elegido |
| J01 | Señales hacia la placa de control | `Connector_JST:JST_XH_B6B-XH-A_1x06_P2.50mm_Vertical` | P: polarizado, no se conecta al revés |
| SW301 | DPDT | en la placa: `Button_Switch_THT:SW_CK_JS202011CQN_DPDT_Straight`; en el panel: bornera de 6 vías | P: depende del punto abierto 8 |
| SW302 | Rotativo de tres posiciones | sin huella en las bibliotecas; en el panel: bornera de 4 vías | P/C |
| HS101 | Disipador Aavid 529802B02500G de Q103 | sin huella en las bibliotecas | C: crear desde el plano del catálogo de Aavid |
| HS102 | Disipador de D102 (sin modelo) | según el modelo | P |
| H1–H4 | Agujeros de montaje | `MountingHole:MountingHole_3.2mm_M3` (o `MountingHole_3.2mm_M3_Pad_Via` si se unen a GND) | P: tornillo M3 supuesto; definir con el gabinete |

Quedan de montaje pasante: las borneras, Q103 y D102 con sus disipadores, K101, F101, los electrolíticos de 470 µF y L301; y Q303 y D106 si no se cambian por sus versiones SMD.

## 8. Puntos abiertos

1. **Correcciones pendientes en el esquemático (netlist del 2026-11-17):** D104 conserva la huella `D_SMA` (el SMBJ30A es `D_SMB`); un símbolo de tierra (#PWR063) sigue siendo de la biblioteca `PCM_SparkFun-PowerSymbol`. Ya corregidos: cruce de `N_SW` y `N_REL` en la raíz, terminal 4 de R304, R102 con cuatro terminales y valor de D304.
2. **Terminales SHDN y FLT.** SHDN de U301 queda sin conectar (usuario, 2026-11-16), como admite la hoja de datos del LTC4364. Las dos FLT manejan ahora los LED rojos D205 y D306 (usuario, 2026-11-17): la hoja de datos indica que FLT es de drenador abierto, absorbe hasta 2 mA y soporta 80 V; con 15 kΩ la corriente máxima es de unos 1.8 mA a 29.4 V.
3. **Terminal EN de U202 (TPS54560).** Resuelto (usuario, 2026-11-16): queda sin conectar.
4. **Diodos D202 y D303** (en paralelo con las resistencias de 100 Ω): sin modelo.
5. **Condensador C101** (1 µF en SENSE+ del LTC2944): lo pide la hoja de datos y no está en el texto.
6. **Cantidad de condensadores de 100 nF** en la salida del convertidor de servomotores: el texto no la fija; se dibuja uno (C212).
7. **Modelos sin definir:** fusible y portafusible, conectores, bobinas (6.8 µH × 2, 18 µH, 4.7 µH), resistencias de derivación, interruptor SW301, conmutador SW302, diodos Zener de 15 V, disipador del diodo D102. Faltan las huellas de casi todos los componentes.
8. **SW301 y SW302:** en la placa o en el panel del gabinete con cable.
9. **LED indicadores (D107, D108, D204, D205, D206, D305, D306):** en el esquemático, no en el texto (606 o 607). Las resistencias suponen unos 2 V de tensión directa y unos 2 mA, valores típicos sin hoja de datos: recalcular al elegir los LED. Ninguno queda antes del interruptor principal, de modo que no descargan la batería guardada. No se sabe por la descripción del terminal cuánto tiempo sigue FLT en bajo durante el enfriamiento de 1.78 s: comprobar en el banco.
