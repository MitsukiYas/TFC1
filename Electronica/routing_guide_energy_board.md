# Energy board (TFCEnergyBoard): layout and routing guide

Written 2026-11-18 for KiCad 10.0. Every number comes from one of three places:

- **The thesis:** `TFC/cap6/603`, `606` and the calculation scripts in `Calculos&Simulaciones/SubsistemaElectrico/`, called "memo NN" below.
- **The datasheets in `Referencias/Datasheets_Manuales`:** named in each row.
- **KiCad's own calculator,** which uses the IPC-2221 formulas.

Anything that is not from those sources is marked **[assumption]** or **[decision]**.

---

## 0. The short answer

| Question | Answer |
|---|---|
| How many layers? | **4 layers** (section 1). |
| Copper thickness? | **2 oz (70 µm) on the two outer layers**; inner layers can be 1 oz. |
| Impedance? | **No.** Only track width, clearances and copper area for heat (section 6). |
| What matters most? | 1) Wide copper (zones) on the 20 A path and its ground return. 2) Small switching loops on the three buck converters. 3) Kelvin traces on the three shunts. 4) Copper areas the thermal calculations already assumed. |

---

## 1. Layer count and stackup

**Why 4 layers and not 2:**

1. **The thermal numbers assume it.** The thermal resistances used in memos 05, 06 and 08 for the converters (TPS54540, TPS54560: 42 °C/W; LMR33630: 42.9 °C/W) come from a standard JEDEC board. The LMR33630 datasheet states it is a "4-layer JEDEC board". On a 2-layer board those resistances are higher, and the temperatures in 606 would no longer hold.
2. **The LMR33630 datasheet asks for it:** "Use at least one ground plane in one of the middle layers. This plane acts as a noise shield and also as a heat dissipation path."
3. **The TPS54540 and TPS54560 datasheets ask for it:** connect the PowerPAD "to internal PCB ground planes using multiple vias directly under the IC."
4. **Current:** the battery current (19.6 A worst case, 25 A fuse) and its ground return need wide copper. A solid inner ground plane carries the return without using up the outer layers.

**Why 2 oz outer copper:**

- **Datasheet conditions:**
  - The PDS760 figure of 45 °C/W used in memos 05 and 06 is measured on "2 oz copper, cathode pad 9.4 × 7.2 mm".
  - The DMP4015SPS figure of 49 °C/W used in memo 10 is "FR-4, 2 oz copper, with thermal vias to bottom layer 1 inch square copper plate".
  - The LMR33630 datasheet: "Make the top and bottom PCB layers with two-ounce copper; and no less than one ounce."
- **Track widths:** they halve compared with 1 oz (section 3).

**Recommended stackup [decision]:**

| Layer | KiCad name | Copper | Use |
|---|---|---|---|
| 1 | F.Cu | 2 oz | All components; power zones; short signal traces |
| 2 | In1.Cu | 1 oz | **Solid GND plane**, no traces, no cuts |
| 3 | In2.Cu | 1 oz | Power zones (`V_BARRA`, `N_IN`/`N_SW` path) and a few signal traces if needed |
| 4 | B.Cu | 2 oz | Copy of the high-current zones (in parallel with F.Cu), thermal copper for DMP4015SPS and LM1085, GND zone everywhere else |

**Before you finish the layout:** ask your PCB manufacturer whether they offer 4 layers with 2 oz outer copper, and note their minimum track width, minimum spacing, minimum via drill and via plating thickness. You need those numbers in section 8.2.

---

## 2. Currents of each net (from 603, 606 and memos 01, 03, 05, 06, 08, 11)

| Nets | Maximum current | Note |
|---|---|---|
| `BAT+`, `BAT_F`, `BAT_P`, `N_IN`, `N_SW`, and the **GND return** from J101 | 19.6 A (worst case), 11.3 A sustained; fuse 25 A | 606, memo 01 and memo 10 |
| `N_REL`, `SRC3`, `V_BARRA` (bar) | 18.4 A; up to 28.5 A for ≤ 0.8 ms (bar current limit) | memo 11 |
| J203, J204 (traction drivers) | about 8 A each (motor current limit) | 603 |
| J202 (elevation DM542), J201 (orientation DM542) | 0.55 A and 0.15 A | 603 |
| `CHG+`, D102 | 9 A (maximum charge current) | 606 |
| `SW4`, `V_SERVO`, L201, J205, J206 | 5 A design, 5.75 A peak in the inductor | memo 06 |
| `SW6`, `+5V`, L302, J301 | 3.44 A maximum (5 A design), 5.63 A peak in the inductor | memo 05 |
| `LIM_OUT`, `V_PROT` (control line) | 1.22 A; limited to 2.85 A | memo 03 |
| `VIN7`, `V_PRE`, `V_LIN`, `V_MET` (meteorological supply) | about 0.31 A | 606 |
| `+12V_REL` | 75 mA | 606 |
| All other nets (I²C, PWM, ALCC, feedback, gate, timer, LED) | milliamps | — |

---

## 3. Track widths (not impedance)

KiCad's **Calculator Tools → Track Width** tab uses the IPC-2221 formula. These are the values it gives for **outer layers, 2 oz, 10 °C temperature rise**. **[decision]** I chose 10 °C because the enclosure is already at 50 °C (606).

| Current | Width, 2 oz outer, ΔT 10 °C | Width, 2 oz outer, ΔT 20 °C |
|---|---|---|
| 20 A | 9.4 mm | 6.1 mm |
| 12 A | 4.6 mm | 3.0 mm |
| 10 A | 3.6 mm | 2.4 mm |
| 9 A | 3.1 mm | 2.0 mm |
| 8 A | 2.6 mm | 1.7 mm |
| 6 A | 1.8 mm | 1.2 mm |
| 5 A | 1.4 mm | 0.9 mm |
| 3.5 A | 0.85 mm | 0.56 mm |
| 1.5 A | 0.26 mm | 0.17 mm |
| ≤ 0.5 A | the manufacturer's minimum is enough; use 0.25 mm | — |

**How to use this:**

- **≥ 8 A** (battery path, bar, traction terminals, charger): do not draw tracks. Draw **filled zones** (copper areas) at least as wide as the table, on **F.Cu and B.Cu in parallel**, joined by many vias (next point).
- **Vias between layers:** with KiCad's **Via Size** tab, a 0.3 mm drill via with 25 µm plating carries about 1 A with the conservative (internal-layer) formula. **[assumption]** 25 µm plating is a common value; put your manufacturer's value in the calculator.
  - So for the 20 A path, use **at least 20 vias** at every place where the current changes layer.
  - Put them in a grid next to the pads, not one big via.
- **3–6 A** (converter outputs, inductors): tracks or small zones of 1.5–2 mm.
- **≤ 1.5 A:** 0.3–0.5 mm tracks.
- **Signals:** 0.25 mm.

**Also from the LTC4364 datasheet (Layout Considerations):**

- **Width:** "The minimum trace width for 1 oz copper foil is 0.02 inch per amp" (0.5 mm/A at 1 oz). The 2 oz table above is wider than this at high currents, so it also meets this rule.
- **SOURCE pin:** "Limit the resistance from the SOURCE pin to the sources of the MOSFETs to below 10 Ω" (easy: a normal short trace).

---

## 4. Placement: where each part goes and next to what

### 4.1 General layout of the board [decision: you choose the exact positions]

Follow the current, from the battery to the loads, so the 20 A path is short and does not cross the sensitive parts:

```
 [J101 battery]─F101─Q101/Q102─R102─(N_IN)─Q103+HS101─(N_SW)─K101─Q201─R201─(V_BARRA)─[J201..J204 bar terminals]
                                  │U101          │                │                  └─U202 servo buck─[J205/J206]
 [J102 charger]─D102+HS102────────┘              │                └ D105
                 U102 (12 V relay coil)          └─U301 limiter─π filter─(V_PROT)─U302 5 V buck─[J301 5 V]
                                                                                 └─U303/U304 meteo supply─[J302..J304]
 [J01 signals to control board]: between U101 (I²C, ALCC) and J205/J206 (PWM)
```

- **One side of the board for power:**
  - **[decision]** Put all connectors that carry big currents (J101, J102, J201–J204) on one edge, so the thick cables do not cross the board.
  - **[decision]** Put the two heatsinks (Q103, D102) near an edge.
- **All parts on F.Cu (top).** The LM1085 datasheet asks: "Place all circuit components on the same side of the circuit board". It also makes assembly easier.
- **Electrolytic capacitors away from the heatsinks and the PDS760 diodes:** C210, C211, C304 and C306. The SAMXON GT life is rated at 105 °C, so a cooler capacitor lasts longer.

### 4.2 Input sheet (`modulo_entrada`)

| Part | Place it | Why |
|---|---|---|
| J101, F101 | Board edge, first in the chain | Shortest 20 A path |
| Q101, Q102 (DMP4015SPS) | Side by side right after F101 | 1 in² (645 mm²) of 2 oz copper **each** on the drain (`BAT_F`), with thermal vias to a B.Cu copper plate (memo 10, datasheet note 6) |
| R101, D101 | Next to Q101/Q102 gate pins | Short gate network |
| R102 (WSL3637) | Right after Q101/Q102 | Kelvin shunt |
| U101 (LTC2944) | **Next to R102**, sense traces as short as possible | LTC2944 datasheet: "locating the LTC2944 close to the resistor with short sense traces" |
| C101 (1 µF) | Right at U101, between SENSE+ and GND | LTC2944 datasheet: "Put the bypass capacitor close to SENSE+ and GND" |
| D104 (SMBJ30A), C104 (2.2 µF) | At the `N_IN` node, next to Q103's source | They clamp and absorb the cable energy at that node (603, memo 02) |
| Q103 + HS101 | After the `N_IN` node, board edge | Heatsink. Align the TO-220 by hand, centred between the two heatsink pins |
| R103, R104, D103 | Next to Q103's gate | Gate network of the stop |
| J103 (stop loop) | Near Q103 | Short wires to the button |
| D105 (PDS760, freewheel) | Next to Q103's drain (`N_SW`), anode to GND with vias | 603 |
| J102, D102 + HS102 | Board edge | 9 A path; heatsink |
| U102 (LM1085-12, TO-263), C102, C103, D106, K101 | Near J102 and K101 | C102 at U102's input pin, C103 at its output pin (LM1085 datasheet: components "as near as practical" to the regulator pins). Thermal copper on the tab (section 5) |
| K101 (relay) | Between `N_SW` and `N_REL` | Its contact pins carry the bar current: zones, not tracks |
| D107/R105, D108/R106 (LEDs) | Board edge, visible | — |

### 4.3 Actuator sheet (`modulo_energia_actuadores`)

| Part | Place it | Why |
|---|---|---|
| Q201 (PSMN4R8, D2PAK) | Right after K101 | Bar path. Its 50 K/W uses the minimum footprint (memo 11), so more copper only helps |
| R201 (WSK2512) | Right after Q201 | Kelvin shunt |
| U201 (LTC4364) | Next to Q201 and R201 | Short Kelvin traces; short gate trace |
| D201 (15 V Zener) | Directly between Q201's gate and source pins | Gate protection |
| R202, D202, C201 | Next to U201's HGATE pin | — |
| C202 (C_TMR) | Next to U201's TMR pin | — |
| J201–J204 | Board edge, together | 18.4 A total; traction terminals about 8 A each |
| U202 (TPS54560) and its parts | Together as a block; follow 4.6 | — |
| J205, J206 (servos) | Near L201/C210, edge | 5 A |
| D204–D206, R207–R209 | Edge, visible | — |

### 4.4 Sensor sheet: control line (`modulo_energia_sensores`)

| Part | Place it | Why |
|---|---|---|
| Q301 (PSMN4R8), Q302 (FDMS86150) | Next to each other, sources (`SRC5`) joined by a short wide trace | — |
| R304 (WSK2512, 20 mΩ) | Right after Q302 | Kelvin |
| U301 (LTC4364) | Next to Q301, Q302 and R304 | — |
| R301, R302, R303 (UV/OV divider), R305, R306 (FB divider) | **Right at U301's UV, OV and FB pins** | LTC4364 datasheet: "locating resistive dividers close to the pins with short VCC and GND traces" |
| D301, D302 (Zeners) | Between gate and source of Q301 and Q302 | — |
| R307, D303, C301, C302 | At U301's HGATE and TMR pins | — |
| C303, C304 → L301 → C305, C306 (π filter) | In a line after R304 | L301 is the through-hole toroid |

### 4.5 Sensor sheet: 5 V and meteorological supply

| Part | Place it | Why |
|---|---|---|
| U302 (TPS54540) and its parts | Block; follow 4.6 | — |
| R308, R309 (EN divider) | Near U302's EN pin | — |
| J301 (5 V to the control board) | Edge, near C312/C313 | 3.44 A |
| U303 (LMR33630) and its parts | Block; follow 4.6 | — |
| Q303, R315, R316, R318 | Near U303's FB pin | The feedback node (`FB7`) is sensitive |
| U304 (LM1085-ADJ), C323 (input), C324 (output) | C323 at the IN pin, C324 at the OUT pin | LM1085 datasheet |
| R317 | At U304's ADJ pin | — |
| R319–R322, SW302 pads | Near U304 | — |
| SW301 pads, J302–J304 | Edge | Wires to the panel and the instruments |

### 4.6 The three buck converters (U202, U302, U303): the most important placement rule

All three datasheets say the same. A buck converter has one **"hot loop"** where the current switches on and off very fast:

```
 input capacitor (+) → VIN pin → (IC switch) → SW pin → diode → GND → input capacitor (−)
```

On the TPS54540 and TPS54560 the diode is the PDS760; the LMR33630 has its own internal switch to ground. The smaller this loop is in area, the less noise and voltage spikes.

| Rule | TPS54540 (U302), TPS54560 (U202) | LMR33630 (U303) |
|---|---|---|
| Input ceramic capacitors | C307/C308 and C206–C209 touching VIN (pin 2) and GND (pin 7), X7R | C314–C316 touching VIN (pins 2, 3) and PGND (pin 1); the 220 nF C316 closest |
| Diode | D304 / D203 right next to the SW pin, anode next to the input capacitor's GND | (internal) |
| SW node | Short, small copper area: SW pin → diode cathode → inductor. **Exception:** the PDS760 cathode needs its 9.4 × 7.2 mm pad for heat (section 5), so make that pad exactly that size and keep the rest of SW small | SW pin → L303, short and wide but small |
| BOOT capacitor | C311 / C205 right between BOOT (pin 1) and SW (pin 8) | C318 between BOOT (7) and SW (8), short and wide |
| RT resistor | R311 / R204 right at RT/CLK (pin 4); "sensitive to noise" | — |
| COMP network | R310, C310, C309 / R203, C204, C203 right at COMP (pin 6) | — |
| Feedback divider | R312/R313 and R205/R206 right at FB (pin 5); the trace from the output to the top resistor may be longer but **away from SW** | Q303 network at FB (pin 5), same rule |
| VCC capacitor | — | C317 right at VCC (pin 6) |
| Thermal pad | The footprint already has thermal vias. Connect them to the In1.Cu GND plane, plus top GND copper around the IC "for operation at full rated load" | Footprint with thermal vias, to the GND plane; 2 oz outer copper |
| Output capacitors | C312/C313 and C210–C212 right after the inductor, GND side next to the input capacitor GND | C319–C322 after L303 |

---

## 5. Copper areas the calculations already assumed (do not make them smaller)

| Part | Required copper | Where the number comes from |
|---|---|---|
| Q101, Q102 (DMP4015SPS) | 1 in² (645 mm²) of 2 oz copper **each** on the drain pad (`BAT_F`), with thermal vias to a B.Cu plate | Datasheet note 6; memo 10 used 49 °C/W from it (74 °C and 86 °C in 606) |
| D203, D304 (PDS760) | Cathode pad 9.4 × 7.2 mm, 2 oz; anode 2.7 × 1.6 mm | Datasheet note 7 (45 °C/W); 606 already says so; memos 05 and 06 |
| U102, U304 (LM1085, TO-263) | Copper on the tab (OUT net) with vias to inner and bottom copper | LM1085 datasheet: "An array of plated vias can be placed on the pad area underneath the TAB". 606 uses 40.6 °C/W (standard board) |
| U202, U302, U303 | Thermal pad to the GND plane with the vias in the footprint, plus top GND copper | TPS and LMR33630 datasheets; 42 and 42.9 °C/W (standard board) |
| Q201, Q301 (PSMN4R8) | Minimum footprint is enough (50 K/W in memo 11); more copper only helps | Datasheet |
| Q302 (FDMS86150) | Minimum copper is enough (115 °C/W in memo 03) | Datasheet |
| Q103, D102 | On the Aavid heatsinks; no copper requirement | 603, 606 |

**How to check an area in KiCad:**

1. Select the zone.
2. Look at the bottom message panel, which shows the zone's area.

---

## 6. Impedance: not needed (and why)

You need controlled impedance only when a trace is long compared with how fast its signal edges are. On this board:

- **The fastest data signal is I²C at 100 kHz** (602, 605). The I²C specification (UM10204, cited in 602) allows rise times up to 1 µs in standard mode. In 1 µs a signal travels many metres of trace, and your traces are centimetres long.
- **PWM to the servos and ALCC are slow signals.**
- **The fast edges are on the converter SW nodes.** There the problem is loop area and copper size (section 4.6), not impedance.

So you only calculate **track width** (section 3), **clearance** (section 7) and **copper area for heat** (section 5).

---

## 7. Clearance (spacing between copper of different nets)

The highest voltage on the board is about 55.5 V, a short transient at `N_IN` clamped by the TVS (603, memo 02). Normal operation is up to 29.4 V, and the bar is clamped at 48.4 V.

**How to choose the value:**

1. Open **Calculator Tools → Electrical Spacing**.
2. Read the IPC-2221 table for **"external conductors, uncoated"** (outer layers) and **"internal conductors"** (inner layers), in the 31–50 V and 51–100 V rows.
3. Use that value as the clearance of the high-voltage net classes (section 8.3).
4. The rest of the board uses the manufacturer's minimum.

**[decision]** If you will coat the board (conformal coating), the table allows smaller values, but only with the coating.

---

## 8. Step by step in KiCad 10

### 8.1 Before starting

1. **Run the electrical rules check** in the schematic: **Inspect → Electrical Rules Checker**. Fix all errors.
2. **Check that every symbol has its footprint.** (Done: every symbol's pins match its footprint's pads.)
3. **Commit to git**, so you can always go back.

### 8.2 Board setup (layers, copper, rules)

1. Open the PCB editor (from the project window, **PCB Editor**).
2. Open **File → Board Setup...**.
3. **Board Stackup → Board Editor Layers:** set **Copper layers = 4**.
4. **Board Stackup → Physical Stackup:**
   - **Copper thickness:** F.Cu and B.Cu **0.07 mm** (2 oz); In1.Cu and In2.Cu **0.035 mm** (1 oz).
   - **Dielectric:** keep the manufacturer's values if they publish them.
5. **Design Rules → Constraints:** put the manufacturer's minimums (minimum track width, minimum clearance, minimum via diameter and drill, copper-to-edge clearance).
6. **Design Rules → Pre-defined Sizes:**
   - **Track widths:** 0.25, 0.4, 0.8, 1.5, 2.0 and 3.0 mm.
   - **Via:** 0.6 mm diameter / 0.3 mm drill (if the manufacturer allows it).

### 8.3 Net classes (so KiCad uses the right width and clearance automatically)

1. In **Board Setup → Design Rules → Net Classes**, add these classes:

| Class | Track width | Clearance | Via | Nets |
|---|---|---|---|---|
| `Bateria` | 3.0 mm (zones do the rest) | from section 7 (51–100 V row) | 0.6/0.3 mm | `BAT+`, `BAT_F`, `BAT_P`, `N_IN`, `N_SW`, `N_REL`, `SRC3`, `V_BARRA`, `CHG+` |
| `Potencia5A` | 1.5 mm | from section 7 (31–50 V row) | 0.6/0.3 mm | `SW4`, `V_SERVO`, `SW6`, `+5V`, `VIN7`, `V_PRE`, `V_PROT`, `LIM_OUT` |
| `Potencia1A` | 0.5 mm | manufacturer minimum | 0.6/0.3 mm | `V_LIN`, `V_MET`, `+12V_REL`, `SNS5` |
| `Default` | 0.25 mm | manufacturer minimum | 0.6/0.3 mm | everything else |

2. In the same page, use the **net class assignment table (pattern → class)** to assign nets by name. One row per net, or a pattern such as `/MÓDULO ENTRADA/BAT*`.
3. Leave GND in Default. It goes in zones, not tracks.

### 8.4 Bring the parts in and draw the outline

1. **Import the parts:** **Tools → Update PCB from Schematic** (F8) → **Update PCB**. All footprints appear in a pile.
2. **Separate them by sheet:**
   1. Right-click a part → **Select → Items in Same Hierarchical Sheet**.
   2. Use **Pack and Move Footprints** (P) to drop that sheet's parts together where you click.
   3. Repeat for each of the three sheets. Now you have the three groups of section 4.
3. **Draw the board outline:**
   1. Select the **Edge.Cuts** layer.
   2. **Place → Draw Rectangle**.
   3. **[decision]** The size depends on your enclosure. Start larger, place everything, then shrink it.
4. **Place the mounting holes** H1–H4 in the corners.

### 8.5 Place the parts

1. **Move:** M moves a part, R rotates it.
2. **Order:** place the big parts first (connectors, heatsinks, Q103, D102, the D2PAK MOSFETs, the inductors, the electrolytics, F101, K101). Then place the ICs, and then the small parts around each IC as in section 4.
3. **The ratsnest:** the thin lines show what connects to what. Fewer crossing lines means an easier route.
4. **Check heights:** open **View → 3D Viewer** (Alt+3) and check the heatsinks, capacitors and connectors do not collide.

### 8.6 Ground plane and power zones

1. **The inner GND plane:**
   1. **Place → Add Filled Zone** (Ctrl+Shift+Z).
   2. Click a corner of the board.
   3. In the dialog choose **layer In1.Cu**, **net GND** and **Pad connections: Solid**.
   4. Draw it over the whole board.
2. **GND on the outer layers:** add more GND zones on B.Cu, and on F.Cu where there is space, and give them the lowest priority (right-click the zone → **Zones → Move Zone to Bottom Priority**).
3. **High-current zones:** for each high-current net (`BAT_F`, `BAT_P`, `N_IN`, `N_SW`, `N_REL`, `V_BARRA`, `CHG+`), draw a zone on **F.Cu** and an identical one on **B.Cu**.
   - **Priority:** higher than the GND zone, so it cuts into it. Set it in the zone dialog, or with right-click → **Zones → Raise Zone Priority**.
   - **Pad connections:** Solid. Thermal reliefs would add resistance on a 20 A path.
4. **Fill:** **Edit → Fill All Zones** (B) after every change.
5. **Stitching vias:** add many vias between the F.Cu and B.Cu copies of each power zone (section 3: at least 20 for the 20 A path), and between the GND zones on all layers. Use **Place Vias** and give each via the zone's net.

### 8.7 Route the tracks

1. **Route:** **Route → Route Single Track** (X). Click a pad and follow the ratsnest. The width comes from the net class.
2. **Change layer:** while routing, press V to drop a via.
3. **Route in this order:**
   1. **Converter hot loops** (section 4.6). These are mostly short copper pieces between neighbouring pads.
   2. **Kelvin sense traces** (R102, R201, R304):
      - From pad 2 to the SENSE (or SENSE−) pin and from pad 3 to the OUT (or SENSE+) pin.
      - Use two thin traces (0.25 mm) **side by side**, on F.Cu.
      - Do not connect them to the big copper anywhere else.
      - Keep them away from SW nodes and inductors.
   3. **Gate traces:** HGATE → gate, short.
   4. **Feedback, RT and COMP:** short, away from SW.
   5. **Signals:** I²C, ALCC, PWM, LED.
4. **Highlight a net:** **Highlight Net** (\` key) shows the whole net, which is useful to check that a zone really connects all its pads.

### 8.8 Checks before ordering

1. **Design rules:** **Inspect → Design Rules Checker** → **Run DRC**. It must end with 0 errors. Also enable the **Schematic Parity** test there, so the board matches the schematic.
2. **Optional teardrops:** **Edit → Edit Teardrops...** adds teardrops to track ends.
3. **Visual checks** in the 3D viewer, and against sections 4 to 7 of this guide.
4. **Copper areas:** check section 5 with the zone areas.

---

## 9. Decisions you still have to make

1. Board size and shape (from the enclosure).
2. Which edge gets the power connectors and the heatsinks.
3. Manufacturer: their minimum track and space, via sizes and plating, and whether they offer 4 layers with 2 oz outer copper.
4. Allowed track temperature rise (10 °C used here).
5. Conformal coating or not (it changes the clearance table).
6. Whether the mounting holes connect to GND (use `MountingHole_3.2mm_M3_Pad_Via` and a GND symbol) or not.

## 10. Assumptions in this guide

- **Via plating:** 25 µm, used for the via current. Replace it with your manufacturer's value in **Calculator Tools → Via Size**.
- **Temperature rise:** 10 °C for track widths.
- **TPS54540/TPS54560 "standard board":** taken as the same 4-layer JEDEC board that the LMR33630 datasheet names explicitly. The TPS datasheets only say "standard board".
- **The stackup in section 1:** a proposal, not a requirement from any datasheet. The requirements are only "at least one ground plane in a middle layer" (LMR33630), "internal ground planes" (TPS) and "2 oz outer copper" (LMR33630, PDS760 and DMP4015SPS conditions).
