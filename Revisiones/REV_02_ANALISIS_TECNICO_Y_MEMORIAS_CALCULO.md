# REV 02 — Análisis Técnico y Verificación de Memorias de Cálculo

> **Fecha de revisión:** 19 de noviembre de 2026  
> **Archivos auditados:** `memoria_05_masas_cg.m`, `memoria_06_acople_motor.m`, `memoria_08_soporte_pivote_poste.m`, `memoria_09_soporte_pivote.m`, `memoria_10_pivote_delantero.m`, `memoria_11_traccion_trasera.m`, `memoria_12_ruedas_brida.m`, `memoria_13_servo_y_buje_delantero.m`, `propagacion_505.py`, `opciones_direccion.py`.

---

## 1. Dinámica Longitudinal y Terramecánica de Tracción

### 1.1. Ecuaciones Fundamentales de Carga y Resistencia
El robot de masa $m = 25.0\text{ kg}$ ($W = 245.25\text{ N}$) se desplaza sobre terreno agrícola compactado con coeficiente de resistencia a la rodadura $f_r = 0.05$ y coeficiente de fricción estática / adherencia neumático-suelo $\mu_s = 0.60$. En una pendiente máxima de ascenso $\beta = 16^\circ$ ($0.279\text{ rad}$):

1. **Resistencia a la rodadura:**
   $$F_{rr} = f_r \cdot m \cdot g \cdot \cos\beta = 0.05 \cdot 25.0 \cdot 9.81 \cdot \cos(16^\circ) = 11.79\text{ N}$$
2. **Componente gravitatoria paralela:**
   $$F_g = m \cdot g \cdot \sin\beta = 25.0 \cdot 9.81 \cdot \sin(16^\circ) = 67.60\text{ N}$$
3. **Fuerza inercial de aceleración ($a = 0.30\text{ m/s}^2$):**
   $$F_{in} = m \cdot a = 25.0 \cdot 0.30 = 7.50\text{ N}$$
4. **Fuerza de tracción total requerida en las ruedas motrices:**
   - Régimen continuo (velocidad constante $v = 1.0\text{ m/s}$):
     $$F_{trac,cont} = F_g + F_{rr} = 67.60 + 11.79 = 79.39\text{ N}$$
   - Régimen transitorio de arranque ($a = 0.30\text{ m/s}^2$):
     $$F_{trac,arr} = F_g + F_{rr} + F_{in} = 79.39 + 7.50 = 86.89\text{ N}$$

### 1.2. Transferencia Longitudinal de Carga y Límite de Adherencia
Con la distancia entre ejes real $L = 0.440\text{ m}$ y la posición del centro de gravedad $L_{cm} = 0.173\text{ m}$ (desde el eje trasero, derivado de `memoria_05_masas_cg.m`), la carga normal sobre el eje frontal al ascender acelerando es:
$$N_f = \frac{W \cos\beta \cdot L_{cm} - W \sin\beta \cdot h_{cm} - m \cdot a \cdot h_{cm}}{L}$$

Dado que la altura del centro de gravedad $h_{cm}$ oscila entre $0.288\text{ m}$ y $0.390\text{ m}$ (según la posición vertical del centro de masa de la elevación en 503):

| Caso de elevación | $h_{cm}$ | $N_f$ (ascenso) | $N_r$ (ascenso) | $\%N_r$ | Límite adherencia $\mu_s N_r$ | Margen vs $F_{trac,arr} = 86.89\text{ N}$ |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| $H_{el} = 100\text{ mm}$ | 288 mm | 43.46 N | 192.29 N | 81.6% | 115.37 N | **1.33 (+33%)** |
| $H_{el} = 200\text{ mm}$ | 339 mm | 34.82 N | 200.93 N | 85.2% | 120.56 N | **1.39 (+39%)** |
| $H_{el} = 300\text{ mm}$ | 390 mm | 26.17 N | 209.58 N | 88.9% | 125.75 N | **1.45 (+45%)** |

> **Conclusión técnica:** El retraso longitudinal del centro de gravedad ($L_{cm} = 173\text{ mm}$ frente a los 225 mm supuestos originalmente) beneficia notablemente la capacidad de tracción, elevando el margen de adherencia desde un frágil $2\%$ hasta un holgado $33\% - 45\%$. No obstante, el eje delantero pierde entre el $82\%$ y el $89\%$ de su carga estática, dejando cada rueda directriz con apenas $13.1\text{ N}$ a $21.7\text{ N}$ de contacto, lo cual compromete la autoridad de viraje en pendientes pronunciadas.

---

## 2. Dimensionamiento del Tren de Tracción Posterior

### 2.1. Selección y Régimen Operativo del Motorreductor
Con radio de rodadura $r = 0.10\text{ m}$ y tracción repartida simétricamente entre dos motorreductores ($i_t = 1.0$, $\eta_t = 1.0$ en el eje de salida del reductor), con un factor de servicio / seguridad $S = 1.30$:
- **Torque continuo requerido por motor:**
  $$T_{m,cont} = \frac{F_{trac,cont} \cdot r}{2} = \frac{79.39 \cdot 0.10}{2} = 3.97\text{ N}\cdot\text{m}$$
- **Torque de arranque con factor de seguridad:**
  $$T_{m,arr} = \frac{F_{trac,arr} \cdot r \cdot S}{2} = \frac{86.89 \cdot 0.10 \cdot 1.30}{2} = 5.65\text{ N}\cdot\text{m}$$
- **Velocidad angular a $v = 1.0\text{ m/s}$:**
  $$\omega = \frac{v}{r} = \frac{1.0}{0.10} = 10.0\text{ rad/s} \approx 95.5\text{ rpm}$$

El motorreductor planetario **E-S Motor 42PG-775-67** (24 V) ofrece:
- Velocidad en vacío: $120\text{ rpm}$ ($I_0 < 0.7\text{ A}$).
- Régimen nominal: $105\text{ rpm}$ a $4.90\text{ N}\cdot\text{m}$ ($50\text{ kg}\cdot\text{cm}$) con $I_{nom} < 6.0\text{ A}$.
- Velocidad a $3.97\text{ N}\cdot\text{m}$: $\approx 108\text{ rpm}$ con corriente de $\approx 5.0\text{ A}$.
- Torque en el límite de corriente de firmware ($8.0\text{ A}$): $\approx 6.75\text{ N}\cdot\text{m}$.
- Compatibilidad eléctrica: El controlador Pololu H2 36v11 CS admite $11\text{ A}$ continuos por canal, operando con un margen térmico superior al $55\%$.

### 2.2. Verificación Estructural del Semieje Posterior T2 (`memoria_11_traccion_trasera.m`)
- **Carga de diseño:** Caso dinámico LC2 con factor de impacto vertical $k_d = 2.0 \implies R = 110.6\text{ N}$ por rueda. Torque aplicado: $T = 6.75\text{ N}\cdot\text{m}$ (torque máximo en el límite de corriente).
- **Geometría de apoyo:**
  - Separación entre rodamientos en T1: $a = 40\text{ mm}$ ($y_i = -22\text{ mm}$, $y_o = -62\text{ mm}$).
  - Voladizo de la rueda desde rodamiento exterior: $b = 38\text{ mm}$ ($y_w = -100\text{ mm}$).
- **Reacciones en los rodamientos 6001-2RS:**
  $$R_o = R \frac{a + b}{a} = 110.6 \frac{40 + 38}{40} = 215.7\text{ N}$$
  $$R_i = R \frac{b}{a} = 110.6 \frac{38}{40} = 105.1\text{ N}$$
  Capacidad estática de catálogo SKF 6001: $C_0 = 2360\text{ N}$.
  $$s_0 = \frac{C_0}{R_o} = \frac{2360}{215.7} = \mathbf{10.9} \quad (\text{Ampliamente seguro})$$
- **Esfuerzos en el semieje $\varnothing 12\text{ mm}$ (AISI 1045, $S_y = 310\text{ MPa}$):**
  - Momento flector en rodamiento exterior: $M = R \cdot b = 110.6 \cdot 0.038 = 4.20\text{ N}\cdot\text{m}$.
  - Esfuerzo de flexión: $\sigma_b = \frac{32 M}{\pi d^3} = \frac{32 \cdot 4.20 \cdot 10^3}{\pi \cdot 12^3} = 24.77\text{ MPa}$.
  - Esfuerzo de torsión: $\tau = \frac{16 T}{\pi d^3} = \frac{16 \cdot 6.75 \cdot 10^3}{\pi \cdot 12^3} = 19.90\text{ MPa}$.
  - Esfuerzo equivalente de von Mises:
    $$\sigma_{vm} = \sqrt{\sigma_b^2 + 3\tau^2} = \sqrt{24.77^2 + 3(19.90)^2} = 42.43\text{ MPa}$$
  - Factor de seguridad estático:
    $$FS_{est} = \frac{S_y}{\sigma_{vm}} = \frac{310}{42.43} = \mathbf{7.3}$$

### 2.3. Elementos de Unión del Tren Trasero
1. **Chaveta de arrastre DIN 6885 A ($4 \times 4 \times 16\text{ mm}$):**
   - Fuerza tangencial en radio de 6 mm: $F_t = \frac{T}{r_e} = \frac{6.75}{0.006} = 1125\text{ N}$.
   - Esfuerzo cortante en chaveta de acero: $\tau_k = \frac{1125}{4 \times 16} = 17.6\text{ MPa}$ ($FS > 10$).
   - Aplastamiento sobre el cubo de aluminio 6061-T6: $p_k = \frac{1125}{2 \times 16} = 35.16\text{ MPa}$.
     Límite admisible del aluminio ($S_{y} / 1.65 = 240 / 1.65 = 145.5\text{ MPa}$): $FS = 4.1$.
2. **Anclaje del soporte T1 al perfil E5 (Tornillo exterior M5):**
   - Momento de vuelco respecto al tornillo interior ($y = -12\text{ mm}$):
     $$F_{b,ext} = \frac{R_o |y_o - y_i| - R_i |y_i - y_i|}{\Delta y_b} = \frac{215.7 \cdot 50 - 105.1 \cdot 10}{40} = 243.3\text{ N}$$
   - Capacidad admisible de la tuerca en T M5 en ranura V-slot: $F_{adm} = \frac{684}{1.95} = 350.8\text{ N}$.
   - Factor de seguridad: $FS = \frac{350.8}{243.3} = \mathbf{1.44}$ (El punto más exigido del conjunto).

---

## 3. Cinemática y Terramecánica de Dirección Frontal

### 3.1. Cinemática Ackermann Corregida
Con los parámetros reales de la estructura:
- Distancia entre ejes: $L = 440\text{ mm} = 0.440\text{ m}$.
- Distancia transversal entre pivotes: $b_{piv} = 546\text{ mm} = 0.546\text{ m}$ (pivotes a $y = -73\text{ mm}$ y $y = 473\text{ mm}$).
- Vía entre centros de rueda traseras: $b_w = 600\text{ mm} = 0.600\text{ m}$.
- Ángulo máximo de la rueda interior: $\delta_{i,max} = 35.0^\circ$ ($0.6109\text{ rad}$).

Calculando con la geometría exacta:
1. **Radio mínimo de giro al centro del eje posterior:**
   $$R_{min} = \frac{L}{\tan\delta_{i,max}} + \frac{b_{piv}}{2} = \frac{0.440}{\tan(35^\circ)} + \frac{0.546}{2} = 0.6284 + 0.2730 = \mathbf{0.901\text{ m}}$$
2. **Ángulo de viraje de la rueda exterior:**
   $$\delta_o = \arctan\left[ \frac{L}{R_{min} + \frac{b_{piv}}{2}} \right] = \arctan\left[ \frac{0.440}{0.9014 + 0.2730} \right] = \arctan(0.3746) = \mathbf{20.54^\circ}$$
3. **Ángulo medio virtual de dirección:**
   $$\delta = \arctan\left( \frac{L}{R_{min}} \right) = \arctan\left( \frac{0.440}{0.9014} \right) = \mathbf{26.02^\circ}$$
4. **Relación de velocidades en el diferencial electrónico trasero:**
   $$\frac{\omega_{r,o}}{\omega} = 1 + \frac{b_w}{2 R_{min}} = 1 + \frac{0.600}{2 \cdot 0.9014} = 1 + 0.3328 = \mathbf{1.333} \quad (+33.3\%)$$
   $$\frac{\omega_{r,i}}{\omega} = 1 - \frac{b_w}{2 R_{min}} = 1 - 0.3328 = \mathbf{0.667} \quad (-33.3\%)$$

### 3.2. Torque de Resistencia al Viraje (*Scrub Torque*) con KPI
En reposo sobre terreno blando/compactado, la resistencia al giro de la rueda delantera depende del radio de la huella de contacto ($r_c = 0.025\text{ m}$), del radio de frotamiento en el suelo ($e$), y del efecto de levantamiento por inclinación del pivote (KPI):

$$\tau_{piv} = \frac{2}{3} \mu_s N_w r_c + \mu_s N_w e + N_w d \sin(\text{KPI}) \sin\delta_{max}$$

Donde:
- $\mu_s = 0.60$.
- Inclinación del pivote: $\text{KPI} = 15.1^\circ$.
- Distancia del pivote al plano medio de la rueda a nivel del eje ($z = 41\text{ mm}$): $d = 27\text{ mm} = 0.027\text{ m}$.
- Proyección del pivote al suelo ($z = -59\text{ mm}$, desnivel $\Delta z = 100\text{ mm}$):
  $$y_{piv,suelo} = -73.02 - 100 \cdot \tan(15.1^\circ) = -73.02 - 26.98 = -100.0\text{ mm}$$
  Dado que el plano de la rueda se encuentra en $y_w = -100.0\text{ mm}$, **el radio de frotamiento en el suelo se anula:** $e = 0.0\text{ mm}$.

Para el caso crítico de descenso en pendiente de $16^\circ$ con transferencia de peso hacia adelante ($N_w = 72.4\text{ N}$ por rueda):
1. Fricción por rotación de la huella sobre sí misma:
   $$\tau_{rot} = \frac{2}{3} \cdot 0.60 \cdot 72.4 \cdot 0.025 = 0.724\text{ N}\cdot\text{m}$$
2. Arrastre por radio de frotamiento:
   $$\tau_{scrub} = 0.60 \cdot 72.4 \cdot 0.0 = 0.0\text{ N}\cdot\text{m}$$
3. Término de par por levantamiento estático aproximado:
   $$\tau_{lift} = 72.4 \cdot 0.027 \cdot \sin(15.1^\circ) \cdot \sin(35^\circ) = 72.4 \cdot 0.027 \cdot 0.2605 \cdot 0.5736 = 0.292\text{ N}\cdot\text{m}$$
4. Torque total de pivoteo:
   $$\tau_{piv} = 0.724 + 0.292 = 1.016\text{ N}\cdot\text{m}$$
5. **Torque demandado al servomotor:**
   Incluyendo la inercia de la mangueta ($J_{mang} = 1.2 \times 10^{-3}\text{ kg}\cdot\text{m}^2$), aceleración angular ($\ddot{\delta} = 10.5\text{ rad/s}^2$), fricción estática del pivote ($T_{s,s} = 0.10\text{ N}\cdot\text{m}$), eficiencia ($\eta_s = 0.90$) y factor de seguridad ($S = 1.30$):
   $$T_{servo} = \frac{(\tau_{piv} + J_{mang}\ddot{\delta}) \cdot S}{\eta_s} + T_{s,s} = \frac{(1.016 + 0.0126) \cdot 1.30}{0.90} + 0.10 = \mathbf{1.587\text{ N}\cdot\text{m}}$$
   En terreno plano ($N_w = 48.2\text{ N}$): $T_{servo} = \mathbf{1.096\text{ N}\cdot\text{m}}$.

Frente al par de bloqueo del Dsservo RDS3225 alimentado a 6.5 V ($T_{bloq} = 2.35\text{ N}\cdot\text{m}$):
$$FS_{servo} = \frac{2.35}{1.587} = \mathbf{1.48} \quad (\text{Cumple nominalmente})$$

---

## 4. Resistencia Mecánica del Conjunto del Pivote Delantero

### 4.1. Verificaciones del Mecanismo de Giro (`memoria_10_pivote_delantero.m`)
Con carga dinámica vertical $R = 78.6\text{ N}$ y par máximo $T = 2.35\text{ N}\cdot\text{m}$:
1. **Reacciones horizontales en los apoyos de la mangueta ($z_{inf} = 175\text{ mm}$, $z_{sup} = 210\text{ mm}$):**
   Momento volcador generado por la excentricidad del punto de contacto:
   $$M = R (z_{inf} - z_{suelo}) \tan(\text{KPI}) = 78.6 \cdot (0.175 - (-0.059)) \cdot \tan(15.1^\circ) = 4.96\text{ N}\cdot\text{m}$$
   Par de fuerzas horizontales en los brazos de F2:
   $$F_h = \frac{M}{z_{sup} - z_{inf}} = \frac{4.96}{0.210 - 0.175} = \mathbf{141.8\text{ N}}$$
2. **Presión de contacto en bujes de bronce SAE 660 ($8 \times 12 \times 8\text{ mm}$):**
   $$p = \frac{F_h}{d \cdot l} = \frac{141.8}{8 \cdot 8} = \mathbf{2.22\text{ MPa}} \quad (\ll 10\text{ MPa admisible})$$
3. **Flexión en pasador K2 y eje K3 ($\varnothing 8\text{ mm}$, AISI 1045, $S_y = 310\text{ MPa}$):**
   Brazo de palanca $a = 9\text{ mm}$ (4 mm holgura + 5 mm medio brazo):
   $$\sigma_b = \frac{32 F_h a}{\pi d^3} = \frac{32 \cdot 141.8 \cdot 0.009}{\pi \cdot 0.008^3} = 25.38\text{ MPa} \implies FS = \mathbf{12.2}$$
4. **Torsión en eje K3 con concentrador por taladro transversal $\varnothing 3\text{ mm}$ ($K_t = 2.0$):**
   $$\tau = \frac{16 T}{\pi d^3} = \frac{16 \cdot 2.35}{\pi \cdot 0.008^3} = 23.38\text{ MPa} \implies \tau_{max} = 2.0 \cdot 23.38 = 46.75\text{ MPa}$$
   $$FS = \frac{0.577 \cdot 310}{46.75} = \mathbf{3.83}$$
5. **Cortante en pasador elástico ISO 8752 $\varnothing 3 \times 20\text{ mm}$:**
   Fuerza de corte en radio de 4 mm: $F_p = \frac{2.35}{0.004} = 587.5\text{ N}$.
   Capacidad estática de corte doble según norma ISO 8752: $F_{adm} \approx 6320\text{ N} \implies FS = \mathbf{10.8}$.

### 4.2. Cubo Delantero y Rodamientos 688-2RS (`memoria_13_servo_y_buje_delantero.m`)
- **Espiga fija K5 ($\varnothing 8\text{ mm}$, AISI 1045):**
  Voladizo de $27\text{ mm}$ hasta el centro de rueda. Momento flector: $M = 78.6 \cdot 0.027 = 2.12\text{ N}\cdot\text{m}$.
  Esfuerzo de flexión pura: $\sigma_b = \frac{32 \cdot 2.12}{\pi \cdot 0.008^3} = 42.21\text{ MPa} \implies FS = \mathbf{7.34}$.
  Presión en el alojamiento en la mangueta K1 ($l = 20\text{ mm}$): $p = 4.5\text{ MPa}$ (admisible 145 MPa).
- **Rodamientos 688-2RS dentro del centrador $\varnothing 25\text{ mm}$:**
  Centros en $y_1 = -92.5\text{ mm}$ y $y_2 = -102.5\text{ mm}$ (separación entre aros $10\text{ mm}$).
  Rueda en $y_w = -100.0\text{ mm}$.
  Reacción vertical rodamiento interior: $R_1 = 19.6\text{ N}$.
  Reacción vertical rodamiento exterior: $R_2 = 59.0\text{ N}$.
  Capacidad estática $C_0 \approx 470\text{ N} \implies s_0 = \frac{470}{59} = \mathbf{8.0}$ (Bajo carga exclusivamente radial vertical).
