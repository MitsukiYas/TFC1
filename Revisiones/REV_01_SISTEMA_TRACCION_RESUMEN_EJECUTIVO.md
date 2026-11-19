# REV 01 — Resumen Ejecutivo del Subsistema de Tracción y Dirección (Capítulo 505)

> **Fecha de revisión:** 19 de noviembre de 2026  
> **Alcance:** Revisión integral del capítulo `TFC/cap5/505_subsistema_traccion_direccion.tex`, el esquema de propagación `505_PROPAGACION_ESQUEMA.md`, memorias de cálculo en `Calculos&Simulaciones/SubsistemaEstructura` e infografías/planos en `Calculos&Simulaciones/SubsistemaEstructura/Planos`.  
> **Estado general del diseño:** En proceso de transición profunda desde el borrador inicial (eje vivo / transmisión por correa / vía 380 mm) hacia la arquitectura desacoplada integrada con la estructura (dos motorreductores 42PG-775-67 independientes, semiejes sobre soportes mecanizados T1, manguetas K1 con pivote inclinado KPI 15.1° y servomotores RDS3225).

---

## 1. Arquitectura y Principio de Funcionamiento

El subsistema de locomoción del robot móvil agrícola está concebido bajo una configuración híbrida **4×2**:
- **Tracción trasera independiente (Rear-Wheel Drive):** Dos motorreductores DC planetarios **E-S Motor 42PG-775-67** (24 V, reducción 67:1, corriente nominal < 6 A) montados fuera del bastidor sobre soportes en L (F1). La potencia se transmite a cada rueda posterior a través de un acople flexible de mandíbulas ($\varnothing 20 \times 30\text{ mm}$), un semieje flotante de acero AISI 1045 ($\varnothing 12\text{ mm}$) soportado por dos rodamientos rígidos de bolas **6001-2RS** dentro de una chumacera en U mecanizada en aluminio 6061-T6 (T1), y una brida de arrastre mecanizada (T3) con chaveta DIN 6885 A $4 \times 4 \times 16\text{ mm}$, atornillada al núcleo de la rueda mediante 4 tornillos M4.
- **Dirección delantera independiente tipo Ackermann:** Dos servomotores digitales **Dsservo RDS3225** alimentados a 6.5 V mediante una línea regulada dedicada. Cada servomotor orienta su propia mangueta (K1) de forma independiente mediante un acople directo desfasado (horn metálico, acople K4 y eje ranurado K3 con pasadores elásticos ISO 8752 $\varnothing 3\text{ mm}$). La mangueta gira sobre un eje de pivote inclinado con ángulo de inclinación del pivote (**KPI = 15.1°**), apoyada sobre dos bujes de bronce SAE 660 ($8 \times 12 \times 8\text{ mm}$) y arandelas de empuje axial de bronce.
- **Diferencial electrónico:** Dado que cada rueda trasera tiene su propio motorreductor, las curvas se gestionan por software en el microcontrolador (imponiendo la velocidad diferenciada $\omega_{r,i}$ y $\omega_{r,o}$ en función del ángulo virtual de viraje $\delta$). La odometría se adquiere mediante encoders rotativos integrados de fábrica en la cola del motorreductor 42PG-775-67 (reemplazando el encoder exterior Omron E6B2-CWZ6C contemplado originalmente).

---

## 2. Comparativa Evolutiva de Parámetros de Diseño

La siguiente tabla resume la evolución crítica de los parámetros del sistema entre el texto actual de `505_subsistema_traccion_direccion.tex` y los resultados derivados del diseño estructural en `504` y sus memorias asociadas:

| Parámetro / Variable | Símbolo | Valor en 505 actual (.tex) | Valor actualizado (504 / Memorias) | Causa del cambio / Justificación |
|---|:---:|:---:|:---:|---|
| **Ancho de vía (ruedas)** | $b_w$ | 380 mm | **600 mm** | El bastidor mide 400 mm de ancho exterior. Las ruedas quedan por fuera ($s = 100\text{ mm}$ a cada lado). |
| **Distancia transversal entre pivotes** | $b_{piv}$ | 380 mm (confundida con vía) | **546 mm** | Los pivotes delanteros se ubican en $y = -73\text{ mm}$ y $y = 473\text{ mm}$ (a 27 mm del plano de rueda). |
| **Distancia entre ejes** | $L$ | 450 mm | **440 mm** | Eje trasero fijado en $x = 50\text{ mm}$; eje delantero en poste frontal ($x = 490\text{ mm}$). |
| **Posición longitudinal del CG** | $L_{cm}$ | 225 mm (al centro) | **173 mm** (desde eje trasero) | Concentración de masa hacia atrás (elevación + orientación en $x = 54\text{ mm}$, batería en $x = 250\text{ mm}$). |
| **Altura del centro de gravedad** | $h_{cm}$ | 180 mm (supuesto) | **288 a 390 mm** (rango) | Depende de la altura del CG del mástil/brazo de elevación (pendiente de 503). |
| **Radio de frotamiento en suelo** | $e$ | 15 mm | **≈ 0.0 mm** | Logrado mediante la inclinación del pivote $\text{KPI} = 15.1^\circ$ hacia el bastidor. |
| **Despeje al suelo (ground clearance)** | $h_{clear}$ | No especificado | **≈ 59 mm** | Eje de rueda $\varnothing 200$ a $z = 41\text{ mm}$; cara inferior del bastidor en $z = 0$. |
| **Radio mínimo de giro** | $R_{min}$ | 0.83 m | **0.90 m** | Corregido con $L = 440\text{ mm}$, $\delta_{i,max} = 35^\circ$ y $b_{piv} = 546\text{ mm}$. |
| **Ángulo de rueda exterior** | $\delta_o$ | 23.8° | **20.5°** | Geometría Ackermann con vía de pivotes real. |
| **Ángulo medio virtual** | $\delta$ | 28.4° | **26.0°** | $\delta = \arctan(L / R_{min})$. |
| **Relación de velocidad traseras** | $\Delta \omega / \omega$ | $\pm 22.8\%$ | **$\pm 33.3\%$** | Con vía trasera de 600 mm y $R_{min} = 0.90\text{ m}$ ($\pm b_w / 2R$). |
| **Ángulo de vuelco lateral estático** | $\alpha_{vuelco}$ | 46.5° | **37.6° a 46.1°** | Vía de 600 mm compensa el incremento de $h_{cm}$ (frente a pendiente máxima de 16°). |
| **Carga estática eje trasero / delantero** | $\%N_r / \%N_f$ | 50% / 50% | **60.7% / 39.3%** | Asimetría longitudinal estática ($L_{cm} = 173\text{ mm}$ frente a $L = 440\text{ mm}$). |
| **Carga normal subiendo 16° ($a = 0.3$)** | $N_f / N_r$ | 87.8 N / 147.9 N | **26 a 43 N / 192 a 210 N** | Eje trasero asume entre el 82% y 89% del peso total. Eje delantero muy descargado. |
| **Adherencia motriz $\mu N_r$ en subida** | $F_{adh}$ | 88.7 N (margen 2%) | **115 a 126 N (margen 33–45%)** | Mayor carga sobre ruedas tractoras incrementa sustancialmente el agarre. |
| **Torque requerido por servomotor** | $T_{servo}$ | 1.80 (plano) / 2.11 (bajada) | **1.10 (plano) / 1.59 (bajada)** | Con KPI 15.1° ($e \approx 0$). Margen frente a bloqueo (2.35 N·m) sube a FS = 1.48. |
| **Sensor de odometría** | Enc. | Omron E6B2 externo (1000 ppr) | **Encoder integrado 42PG** | Elimina soportes exteriores, semiejes largos y acoples helicoidales. |

---

## 3. Síntesis de Componentes del Sistema Mecánico

### 3.1. Tren de Tracción Posterior (Por lado — 2 conjuntos en total)
1. **Actuador:** Motorreductor DC **E-S Motor 42PG-775-67** (reducción planetaria 67:1, eje en D $\varnothing 8\text{ mm}$, masa 0.9 kg con encoder). Montado en soporte en L (F1, 6061-T6, 4 mm) fijado con tornillos M5 y tuercas en T al perfil E1 y al travesaño E5.
2. **Acople elástico:** Acople de mandíbulas de aluminio $\varnothing 20 \times 30\text{ mm}$ con araña elastomérica (barrenos $\varnothing 8\text{ mm}$ con plano y $\varnothing 12\text{ mm}$).
3. **Chumacera doble T1:** Bloque en U mecanizado en aluminio 6061-T6 (base $64 \times 40 \times 4\text{ mm}$, dos paredes de 8 mm con alojamientos $\varnothing 28\text{ H7}$, distancia entre rodamientos $40\text{ mm}$). Fijado a la ranura superior del perfil V-slot E5 mediante dos tornillos M5 con tuercas en T.
4. **Rodamientos:** Dos rodamientos rígidos de bolas **6001-2RS** ($12 \times 28 \times 8\text{ mm}$) por semieje, retenidos axialmente mediante anillos de seguridad DIN 472 ($\varnothing 28$) y DIN 471 ($\varnothing 12$).
5. **Semieje T2:** Eje escalonado de acero AISI 1045 rectificado ($\varnothing 12\text{ h6} \times 112\text{ mm}$), chavetero DIN 6885 A para chaveta $4 \times 4 \times 16\text{ mm}$, y rosca terminal M12 $\times$ 1.25 para tuerca autoblocante.
6. **Brida de arrastre T3:** Brida de aluminio 6061-T6 (plato $\varnothing 56 \times 6\text{ mm}$, centrador $\varnothing 25\text{ g6} \times 10\text{ mm}$, barreno $\varnothing 12\text{ H7}$ con chavetero $4 \times 1.8\text{ mm}$, 4 taladros $\varnothing 4.5\text{ mm}$ en PCD 40 mm).

### 3.2. Mecanismo de Dirección Delantero (Por lado — 2 conjuntos en total)
1. **Soporte F2:** Pieza mecanizada en aluminio 6061-T6 atornillada a la cara exterior del poste delantero E2 (alma de 6 mm, labio inferior de apoyo bajo larguero, brazo inferior a $z = 160\text{ mm}$ y brazo superior ensanchado a 44 mm a $z = 210\text{ mm}$).
2. **Pivote vertical inclinado (KPI 15.1°):**
   - Pasador inferior fijo K2: Acero AISI 1045 $\varnothing 8\text{ h6} \times 29\text{ mm}$ con cabeza $\varnothing 12\text{ mm}$ y anillo DIN 471.
   - Eje superior giratorio K3: Acero AISI 1045 $\varnothing 8\text{ h6} \times 36\text{ mm}$ con dos perforaciones transversales $\varnothing 3\text{ mm}$.
   - Bujes de fricción: Dos bujes de bronce fundido SAE 660 ($8 \times 12 \times 8\text{ mm}$), uno en el brazo inferior de K1 y otro en el brazo superior de F2.
   - Arandelas de empuje: Arandelas axiales de bronce $8.2 \times 16 \times 2\text{ mm}$ para transmitir la carga vertical de la rueda hacia el brazo superior de F2.
3. **Mangueta K1:** Bloque mecanizado de aluminio 6061-T6 a partir de placa de 20 mm de espesor (montante principal de $20 \times 10\text{ mm}$, brazos superior e inferior perforados con ángulo de 15.1°).
4. **Transmisión de viraje:** Servomotor Dsservo RDS3225 invertido, fijado por su carcasa a una placa K7 (6061-T6, 3 mm) soportada por dos separadores hexagonales M4 $\times$ 12 mm sobre el brazo superior de F2. Horn de aluminio de 25T atornillado con 4 tornillos M3 a un acople K4 ($\varnothing 24 \times 10\text{ mm}$), que a su vez acciona el eje K3 y la mangueta mediante pasadores elásticos ISO 8752 $\varnothing 3 \times 20\text{ mm}$.
5. **Cubo de rueda delantera K6 y espiga K5:**
   - Espiga fija K5: Eje no giratorio de AISI 1045 $\varnothing 8\text{ mm}$ clavado a presión en la mangueta, con resalte separador $\varnothing 12 \times 16\text{ mm}$, asiento $\varnothing 8\text{ h6}$ y rosca terminal M8 autoblocante.
   - Cubo-brida K6: Plato de aluminio 6061-T6 que aloja internamente **dos rodamientos rígidos de bolas 688-2RS** ($8 \times 16 \times 5\text{ mm}$) separados por un resalte de 5 mm, con centrador exterior $\varnothing 25\text{ g6}$ y 4 taladros M4 en PCD 40 mm.

---

## 4. Conclusión del Estado Actual

El subsistema presenta una ingeniería de detalle sólida, con soluciones ingeniosas como el uso de la inclinación del pivote (KPI) para anular el radio de frotamiento y permitir que un servomotor comercial estándar (RDS3225) mantenga un factor de seguridad adecuado. No obstante, **la integración reciente de la rueda genérica de 50 mm de ancho en el eje delantero ha introducido interferencias geométricas críticas que imposibilitan el viraje**, sumado a inconsistencias numéricas y discrepancias entre el texto de la tesis en LaTeX y las memorias de cálculo. Dichos puntos se detallan rigurosamente en los siguientes informes de revisión.
