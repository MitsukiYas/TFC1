# REV 03 — Incoherencias, Fallas de Criterio y Observaciones Críticas

> **Fecha de revisión:** 19 de noviembre de 2026  
> **Propósito:** Registro exhaustivo de incoherencias, discrepancias inter-documentales, fallas de criterio de ingeniería mecánica y riesgos de operación detectados entre el texto de la tesis (`TFC/cap5/505_subsistema_traccion_direccion.tex`), el esquema de propagación (`505_PROPAGACION_ESQUEMA.md`) y las memorias/planos de `Calculos&Simulaciones/SubsistemaEstructura`.

---

## 1. Fallas Críticas de Geometría e Interferencia Física

### 1.1. [CRÍTICO] Colisión Severa de la Rueda Delantera con Mangueta K1 y Soporte F2 al Virar
- **Descripción del problema:**  
  En las decisiones del 2026-11-18 y 2026-11-19 (Secciones 10 y 11 de `505_PROPAGACION_ESQUEMA.md`, `memoria_12`, `memoria_13` y `generar_pivote.py`), se adoptó una **rueda genérica única de $\varnothing 200\text{ mm}$ de diámetro y $50\text{ mm}$ de ancho** para las cuatro ruedas, buscando mantener la distancia del eje del pivote al plano medio de la rueda en $d = 27\text{ mm}$ ($y_{piv} = -73\text{ mm}$, $y_{rueda} = -100\text{ mm}$).
- **Interferencia estática:**  
  Con el centro del neumático en $y = -100\text{ mm}$ y un ancho de $50\text{ mm}$, la cara interior del neumático se ubica en $y = -75\text{ mm}$. Dado que la mangueta K1 tiene su montante vertical ubicado entre $y = -73\text{ mm}$ y $y = -63\text{ mm}$ (desde $z = 31$ hasta $z = 200\text{ mm}$), la holgura radial-lateral en reposo es de apenas:
  $$\Delta y_{estatico} = |-75 - (-73)| = \mathbf{2.0\text{ mm}}$$
- **Interferencia cinemática durante el viraje:**  
  Al orientar la rueda delantera un ángulo de viraje $\delta$ alrededor del eje del pivote inclinado ($\text{KPI} = 15.1^\circ$), los puntos extremos del neumático ($\varnothing 200\text{ mm}$, radio $R = 100\text{ mm}$) barren un arco hacia el interior del vehículo ($+y$).  
  La posición transversal del borde interior del neumático en función del ángulo de viraje es:
  $$y_{borde}(\delta) \approx y_{piv} + R \cdot \sin\delta - \Delta y_0 \cdot \cos\delta$$
  Evaluando numéricamente:
  - Para $\delta = 0^\circ$: $y = -75.0\text{ mm}$ (holgura de 2.0 mm con la mangueta en $y = -73\text{ mm}$).
  - Para $\delta = 5^\circ$: $y = -66.3\text{ mm}$ $\implies$ **COLISIÓN DIRECTA contra el montante de K1 (que está en $y = -73$ a $-63\text{ mm}$). El neumático golpea la mangueta antes de alcanzar 5° de giro.**
  - Para $\delta = 10^\circ$: $y = -57.6\text{ mm}$.
  - Para $\delta = 15^\circ$: $y = -49.1\text{ mm}$ $\implies$ **COLISIÓN contra el soporte F2 (cuyo brazo inferior llega hasta $y = -51\text{ mm}$).**
  - Para $\delta = 35^\circ$ (giro máximo Ackermann): $y = \mathbf{-17.3\text{ mm}}$ $\implies$ **El neumático penetra más de 33 mm dentro del soporte F2 y queda a escasos 17 mm del perfil del chasis E1/E2 ($y = 0$).**
- **Impacto técnico:**  
  El diseño actual presentado en `CUBO_DELANTERO_DETALLE.png` y `K1_mangueta.png` es **físicamente imposible de construir y operar con ruedas de 50 mm de ancho**. Sólo permitiría girar $\pm 3^\circ$.
- **Alternativas de solución viables:**
  1. *Opción A (Recomendada):* Retornar a la decisión original de la Sección 7: **Neumático delantero estrecho de $30\text{ mm}$ de ancho** (ancho de huella 30 mm, semiancho 15 mm). Al centrar la rueda en $y = -100\text{ mm}$, la cara interior queda en $y = -85\text{ mm}$, otorgando $12\text{ mm}$ de holgura estática. Para permitir el giro de $35^\circ$, la mangueta debe retrasarse longitudinalmente ($x < 480\text{ mm}$) fuera del radio del neumático, o adoptarse un aro/rin con bombeo negativo (offset) donde el pivote quede embutido dentro del rin (*hub-center steering*).
  2. *Opción B:* Incrementar la distancia del pivote al plano de rueda ($d \ge 50\text{ mm}$) y aumentar el desplazamiento del poste o el ancho de vía delantera, pero esto incrementa el radio de frotamiento y obliga a cambiar el servomotor RDS3225 por un actuador de mayor torque (> 3.5 N·m).

---

## 2. Fallas de Criterio de Selección y Cálculo Mecánico

### 2.1. [FALLA DE CRITERIO] Sobrecarga Crítica en Rodamientos 688-2RS ante Momentos de Vuelco Lateral
- **Descripción:**  
  En `memoria_13_servo_y_buje_delantero.m`, se reemplazaron las chumaceras KFL08 por una espiga fija $\varnothing 8\text{ mm}$ y dos rodamientos miniatura **688-2RS** ($8 \times 16 \times 5\text{ mm}$) dentro del centrador $\varnothing 25\text{ mm}$ del cubo-brida K6.
- **Falla de cálculo:**  
  La memoria 13 calcula únicamente la reacción vertical estática ($R_1 = 19.6\text{ N}, R_2 = 59.0\text{ N}$) y compara contra la capacidad estática $C_0 \approx 470\text{ N}$, indicando un $s_0 = 8.0$. Sin embargo, la separación axial entre los centros de ambos rodamientos es de apenas **$10\text{ mm}$** ($y_1 = -92.5\text{ mm}$, $y_2 = -102.5\text{ mm}$).
- **Efecto de fuerzas laterales en curvas o pendiente:**  
  Cuando el robot opera en pendiente de $16^\circ$ o realiza una maniobra de viraje, la rueda delantera transmite una fuerza lateral de fricción $F_{lat} = \mu_s N_w \approx 0.60 \cdot 72.4\text{ N} = 43.44\text{ N}$.  
  Esta fuerza, actuando en el parche de contacto en el suelo ($r = 100\text{ mm}$ por debajo del eje), genera un momento volcador sobre el cubo de:
  $$M_{volcador} = F_{lat} \cdot r = 43.44\text{ N} \cdot 0.100\text{ m} = \mathbf{4.34\text{ N}\cdot\text{m}}$$
  Para equilibrar este momento con un brazo de palanca de solo $10\text{ mm}$ ($0.010\text{ m}$) entre rodamientos:
  $$\Delta R = \frac{M_{volcador}}{\Delta y_{rodamientos}} = \frac{4.34\text{ N}\cdot\text{m}}{0.010\text{ m}} = \mathbf{434.4\text{ N}}$$
- **Consecuencia:**  
  La carga radial sobre el rodamiento 688 exterior asciende a $R_{total} \approx 59.0 + 434.4 = \mathbf{493.4\text{ N}}$.  
  Dado que la capacidad estática de un rodamiento 688 de bolas de $\varnothing 2.38\text{ mm}$ es de $C_0 \approx 470\text{ N}$, el factor de seguridad estático cae a:
  $$s_0 = \frac{470}{493.4} = \mathbf{0.95} < 1.0$$
  El rodamiento sufrirá deformación permanente (brinelling) en las pistas de rodadura ante esfuerzos laterales moderados o impactos en baches agrícolas.

### 2.2. [FALLA CONCEPTUAL] Formulación Heurística del "Momento de Levantamiento" por KPI
- **Descripción:**  
  En `opciones_direccion.py`, `memoria_12` y el esquema 505, se utiliza la expresión:
  $$\tau_{lift} = N_w \cdot d \cdot \sin(\text{KPI}) \cdot \sin\delta$$
- **Incoherencia física:**  
  1. En una suspensión con inclinación de pivote transversal pura ($\text{KPI} = 15.1^\circ$) y ángulo de avance nulo ($\text{caster} = 0^\circ$), el mecanismo es perfectamente simétrico respecto al plano transversal. La elevación del chasis al virar un ángulo $\delta$ debe ser una **función par** (idéntica para $+\delta$ y $-\delta$, proporcional a $1 - \cos\delta$).
  2. Al derivar la energía potencial para obtener el par resistente, el término $\sin\delta$ surge naturalmente; no obstante, el brazo de palanca eficaz no es $d = 27\text{ mm}$ (la distancia entre pivote y centro de rueda en el muñón). Si la prolongación del pivote interseca el suelo exactamente en el centro de la huella ($e = 0.0\text{ mm}$), el punto de contacto ideal en el suelo no experimenta trayectoria cicloidal; el levantamiento neto depende exclusivamente del cambio de caída (camber) y del perfil transversal redondeado del neumático.
  3. Los propios autores declaran esta fórmula como una "suposición sin verificar en Gillespie ni Jazar". Mantenerla en la tesis sin una deducción analítica rigurosa o cita bibliográfica adecuada debilita el rigor teórico del capítulo.

### 2.3. [FALLA DE CRITERIO] Dimensionamiento del Servomotor RDS3225 sobre Torque de Bloqueo (*Stall*)
- **Descripción:**  
  Se valida la selección del servomotor Dsservo RDS3225 argumentando un factor de seguridad de $FS = 1.48$ ($2.35\text{ N}\cdot\text{m} / 1.59\text{ N}\cdot\text{m}$).
- **Falla de criterio:**  
  El valor de $2.35\text{ N}\cdot\text{m}$ ($23.9\text{ kg}\cdot\text{cm}$) corresponde al **par de bloqueo a rotor trabado** a 6.5 V, donde la corriente alcanza $2.3\text{ A}$ y la disipación térmica es máxima. En servomotores de modelismo / robótica con piñonería pequeña de latón/aluminio y motores con escobillas, el par de trabajo continuo seguro (*rated continuous torque*) no suele superar el **$25\% - 30\%$ del par de bloqueo** ($\approx 0.60 - 0.70\text{ N}\cdot\text{m}$).
- **Consecuencia:**  
  Exigirle continuamente $1.10\text{ N}\cdot\text{m}$ en terreno plano y $1.59\text{ N}\cdot\text{m}$ en maniobras en rampa provocará:
  1. Caídas de tensión en el convertidor de 6.5 V / 5 A (al demandar ambos servos $\approx 4.6\text{ A}$ simultáneamente).
  2. Sobrecalentamiento acelerado y falla catastrófica de los servomotores por fatiga térmica o fractura de los dientes del reductor interno.

---

## 3. Discrepancias e Inconsistencias Numéricas Inter-Documentales

La siguiente matriz documenta las contradicciones detectadas entre las distintas secciones de los documentos de trabajo:

| Parámetro | Valor en `505.tex` | Valor en `505_ESQUEMA` Sec. 3 | Valor en `505_ESQUEMA` Sec. 6/7 | Valor en `Planos / Memorias` | Incoherencia detectada |
|---|:---:|:---:|:---:|:---:|---|
| **Vía entre pivotes $b$** | 380 mm | 520 mm | 546 mm | 546 mm ($y = -73$ y $473$) | El texto .tex usa 380 mm; la Sec. 3 usó 520 mm; la Sec. 7 define 546 mm. |
| **Radio mínimo de giro $R_{min}$** | 0.83 m | 0.89 m | 0.90 m | 0.93 m (en Sec. 4 línea 65) | Tres valores distintos coexisten en el mismo documento de esquema. |
| **Ángulo rueda exterior $\delta_o$** | 23.8° | 21.0° | 20.5° | 19.7° (en Sec. 4 línea 65) | Confusión entre usar $b = 600\text{ mm}$ o la distancia real entre pivotes. |
| **Diferencial de velocidad trasero** | $\pm 22.8\%$ | $\pm 32.3\%$ | No calculado | $\pm 33.3\%$ ($b_w = 600, R = 0.90$) | La Sec. 3 reporta $0.323$ ($R = 0.93$), incompatible con $R = 0.90\text{ m}$. |
| **Posición longitudinal del CG $L_{cm}$** | 225 mm | 173 mm | 173 mm | 173 mm (`memoria_05`) | El .tex supone el CG al centro; la memoria demuestra que está a 39.3% del eje trasero. |
| **Carga estática eje delantero** | 61.31 N/rueda | 48.2 N/rueda | 48.2 N/rueda | 48.2 N/rueda | El .tex sobreestima la carga delantera en plano en un $27\%$. |
| **Carga en subida eje delantero $N_f$** | 87.83 N | 26 a 43 N | 26 a 43 N | 26 a 43 N | El .tex sobreestima la carga normal delantera en subida en más del doble. |
| **Masa total sin ruedas** | No definida | 21.4 kg | 21.4 kg | 21.60 kg (`memoria_05`) | Diferencia de 200 g entre el texto del esquema y la suma de la memoria 05. |

---

## 4. Discrepancias entre `505.tex` y los Diseños Mecánicos Finales

El archivo LaTeX `505_subsistema_traccion_direccion.tex` se encuentra completamente desfasado respecto al diseño real:
1. **Sistema de Odometría:**  
   - En `505.tex` (Líneas 311–314): Se describe detalladamente el encoder óptico industrial **Omron E6B2-CWZ6C** de 1000 ppr acoplado al semieje mediante acople helicoidal y soporte de chapa.
   - En realidad: Se eliminó el Omron E6B2 y se adoptó el **encoder magnético/óptico integrado de fábrica en el motorreductor 42PG-775-67**. Esto invalida los cálculos de pulsos por vuelta (los pulsos ahora se multiplican por la reducción 67:1) y la frecuencia en Hertz.
2. **Soporte de Semieje Trasero:**  
   - En `505.tex` (Línea 305): Menciona "chumaceras KFL001 con rodamientos SKF 6001-2RSH".
   - En realidad: Se diseñó una chumacera doble en U monobloque mecanizada en 6061-T6 denominada **T1**, fijada al travesaño E5.
3. **Mangueta Delantera:**  
   - En `505.tex` (Línea 362): Describe una "horquilla en forma de C mecanizada en placa de aluminio 6061-T6 de 6.0 mm de espesor".
   - En realidad: El diseño actual es una pieza mecanizada maciza **K1** a partir de bloque de 20 mm de espesor.
4. **Espiga y Rodamientos Delanteros:**  
   - En `505.tex` (Línea 365): Describe una espiga de $\varnothing 10.0\text{ mm}$ con dos rodamientos SKF 6000-2RSH ($10 \times 26 \times 8\text{ mm}$).
   - En realidad: Se descartó y en `memoria_13` figura una espiga fija de $\varnothing 8.0\text{ mm}$ con rodamientos miniatura 688-2RS ($8 \times 16 \times 5\text{ mm}$).
5. **Acople del Servomotor:**  
   - En `505.tex` (Línea 358): Asume acople directo coaxial entre el eje de salida del servo y el pasador de pivote.
   - En realidad: Se diseñó un tren indirecto con horn de aluminio, pieza intermedia K4, eje superior ranurado K3 y dos pasadores elásticos ISO 8752 $\varnothing 3\text{ mm}$.

---

## 5. Falla de Criterio Operacional en Terreno Agrícola (Rigidez del Chasis)

- **Descripción:**  
  En `505.tex` (Línea 100), se introduce la suposición de que el bastidor es un cuerpo rígido indeformable, acompañada de la nota: `[COMENTARIO: TENER EN CUENTA LO QUE PASARÍA SI NO SE TOMA ESTA SUPOSICIÓN, QUÉ CAMBIARÍA? APRENDE QUÉ PASA PARA PODER RESPONDER.]`.
- **Análisis del problema real:**  
  El análisis por elementos finitos del pórtico 3D en `memoria_01_bastidor.m` arrojó una rigidez torsional del chasis de $\approx 150\text{ N}\cdot\text{m}/^\circ$. Debido a que el robot **carece completamente de suspensión y de eje basculante pasivo**, una irregularidad en el terreno de tan solo **$0.75\text{ mm}$** descarga por completo una rueda.
- **Consecuencia en la capacidad de ascenso:**  
  Al sortear un obstáculo de 20 mm (Caso LC4 en `memoria_04`), la rueda trasera izquierda queda con una fuerza normal de apenas **$3.8\text{ N}$** (pérdida total de tracción en ese neumático).  
  Para subir la pendiente de $16^\circ$ se requiere una fuerza de tracción total de $79.39\text{ N}$. La única rueda con contacto efectivo (trasera derecha, $N_r = 93.4\text{ N}$) tiene un límite físico de adherencia por fricción de:
  $$F_{adh,max} = \mu_s N_r = 0.60 \cdot 93.4\text{ N} = \mathbf{56.0\text{ N}} < 79.39\text{ N}$$
- **Veredicto:**  
  Bajo las condiciones actuales, en cualquier terreno que presente un bache o piedra superior a 1 mm, **el robot perderá tracción en una rueda motriz y patinará, siendo incapaz de subir la pendiente de 16°**, a menos que la velocidad permita superar el obstáculo por inercia o se agregue un eje delantero oscilante (rocker) que garantice el apoyo isostático de las 4 ruedas en todo momento.
