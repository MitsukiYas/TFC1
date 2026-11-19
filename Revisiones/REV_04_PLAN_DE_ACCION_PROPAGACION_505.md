# REV 04 — Plan de Acción y Guía de Propagación a LaTeX (Capítulo 505)

> **Fecha de revisión:** 19 de noviembre de 2026  
> **Objetivo:** Proporcionar una hoja de ruta estructurada y una guía línea por línea para la actualización definitiva de `TFC/cap5/505_subsistema_traccion_direccion.tex`, una vez resueltas las decisiones de diseño pendientes.

---

## 1. Decisiones Previas Requeridas antes de Redactar en LaTeX

Antes de modificar el archivo `.tex`, el equipo de diseño debe fijar formalmente las siguientes definiciones:

1. **Resolución de la Interferencia Geométrica de la Dirección:**
   - *Decisión recomendada:* Establecer que el eje delantero utilice **neumáticos de $\varnothing 200 \times 30\text{ mm}$** (huella angosta de 30 mm, comercialmente común en ruedas de carretilla ligera / robótica de aluminio) y rediseñar la mangueta K1 para desplazar el montante longitudinalmente fuera del barrido del neumático, manteniendo la rueda trasera en $50\text{ mm}$.
   - *Alternativa:* Si se insiste en la rueda genérica única de 50 mm, se debe rediseñar la geometría del soporte F2 y la mangueta K1 con un brazo en cuello de cisne que abrace el neumático por detrás o adoptar un aro con offset interior (*hub-center*).
2. **Revisión del Par Continuo del Servomotor:**
   - Declarar explícitamente en el texto de la tesis que el factor de seguridad de 1.48 está calculado sobre el **par de bloqueo transitorio**, o bien evaluar un servomotor de mayor torque (ej. 35 a 45 kg·cm con engranajes de acero, como modelos 35 kg Brushless o servos industriales de 24 V).
3. **Confirmación del Centro de Gravedad de Elevación:**
   - Obtener del Capítulo 503 la altura real del centro de gravedad del mástil y brazo articulado en $\theta = 15^\circ$ para cerrar el valor definitivo de $h_{cm}$ (reemplazando el rango $288 - 390\text{ mm}$).
4. **Ficha Técnica del Encoder del Motorreductor 42PG-775-67:**
   - Determinar los pulsos por vuelta (ppr) en el eje del motor para fijar la resolución final de odometría en rueda ($ppr_{rueda} = ppr_{motor} \times 67$).

---

## 2. Mapeo Línea por Línea de Modificaciones en `505_subsistema_traccion_direccion.tex`

| Rango de Líneas | Sección / Elemento | Contenido Actual en el `.tex` | Modificación Requerida |
|:---:|---|---|---|
| **10–29** | Figura 5.1 | Vistas caducas con eje vivo y correa. | Reemplazar figuras por `TRACCION_CONJUNTO.png` y `PIVOTE_CONJUNTO.png` (o vistas 3D actualizadas del ensamble en `ENSAMBLE_ISO.png`). |
| **34** | Nota de masas | PENDIENTE sobre masas sin definir de motores, baterías y gabinetes. | Reemplazar por desglose real de `memoria_05`: motores 42PG con encoder (0.9 kg c/u = 1.8 kg), servos RDS3225 (60 g c/u = 0.12 kg), bastidor V-slot (3.32 kg), batería 7S3P con gabinete Cubo D (2.16 kg), gabinetes de potencia y control Cubo S (1.5 kg c/u = 3.0 kg). Total sin ruedas: 21.6 kg. |
| **36–39** | Parámetros globales | Vía $b = 380\text{ mm}$, entre ejes $L = 450\text{ mm}$, $h_{cm} = 180\text{ mm}$, $L_{cm} = 225\text{ mm}$, $R_{min} = 0.83\text{ m}$, $\delta_o = 23.8^\circ$. | Actualizar a: Vía entre ruedas $b_w = 600\text{ mm}$, vía entre pivotes $b_{piv} = 546\text{ mm}$, entre ejes $L = 440\text{ mm}$, $L_{cm} = 173\text{ mm}$, $h_{cm} \approx 339\text{ mm}$, $R_{min} = 0.90\text{ m}$, $\delta_o = 20.5^\circ$, ángulo virtual $\delta = 26.0^\circ$. |
| **40–95** | Tabla 5.1 | Tabla de parámetros y restricciones Ackermann. | **Actualizar toda la tabla** con los valores recalculados (ver Tabla propuesta en Sección 3 de este informe). |
| **100** | Suposición 1 | `[COMENTARIO: TENER EN CUENTA LO QUE PASARÍA SI NO SE TOMA ESTA SUPOSICIÓN...]` | Eliminar el comentario y añadir la discusión técnica: Se asume bastidor rígido con rigidez torsional de $\approx 150\text{ N}\cdot\text{m}/^\circ$. Explicar que irregularidades de $\ge 0.75\text{ mm}$ descargan una rueda y que en LC4 (obstáculo de 20 mm) la rueda descargada llega a 3.8 N, transfiriendo la tracción a la rueda opuesta. |
| **112–115** | Ecuación Ackermann | $\cot\delta_o - \cot\delta_i = \frac{b}{L}$ | Precisar que $b$ es la **distancia transversal entre pivotes de dirección ($b_{piv} = 546\text{ mm}$)** y no el ancho de vía de las ruedas ($600\text{ mm}$). |
| **142–145** | Diferencial electrónico | $\omega_{r,i} = \frac{v}{r}[1 - \frac{b}{2R}]$ | Aclarar que en esta ecuación se utiliza el **ancho de vía de las ruedas traseras ($b_w = 600\text{ mm}$)**. Con $R_{min} = 0.90\text{ m}$, la relación es $b_w / (2R) = 0.333$ (rueda exterior gira a $1.333 \times \omega_{media}$, rueda interior a $0.667 \times \omega_{media}$). |
| **194–197** | Reacciones normales | $N_f = 87.83\text{ N}$, $N_r = 147.91\text{ N}$ | Actualizar fórmulas con $L_{cm} = 173\text{ mm}$ y $L = 440\text{ mm}$. Cargas en subida: $N_f \approx 34.8\text{ N}$ y $N_r \approx 200.9\text{ N}$ (para $h_{cm} = 339\text{ mm}$). |
| **208–210** | Adherencia en rampa | $F_{trac} \le \mu_s N_r$ (margen de 2%) | Actualizar el margen: con $N_r = 200.9\text{ N}$, $\mu_s N_r = 120.6\text{ N}$, lo que otorga un margen de seguridad de adherencia del **$39\%$** frente a los $86.89\text{ N}$ de arranque. |
| **212–215** | Par de pivoteo | $\tau_{piv} = \frac{2}{3}\mu_s N_w r_c + \mu_s N_w e$ | Incluir el efecto del ángulo de inclinación del pivote ($\text{KPI} = 15.1^\circ$), señalando que $e \approx 0.0\text{ mm}$ en el suelo, y el término adicional por levantamiento estático de la masa. |
| **248–251** | Cargas y esfuerzos espiga | Carga plana 61.31 N, rampa 72.46 N; espiga $\varnothing 10\text{ mm}$, $M = 3.26\text{ N}\cdot\text{m}$. | Actualizar: Carga en plano $N_w = 48.2\text{ N}$, bajando $N_w = 72.4\text{ N}$. Si se adopta la espiga fija K5 de $\varnothing 8\text{ mm}$ ($M = 2.12\text{ N}\cdot\text{m}$, $\sigma = 42.2\text{ MPa}$, $FS = 7.3$). |
| **256–301** | Selección motorreductor | Datos del 42PG-775-67. | Mantener la selección del E-S Motor 42PG-775-67, agregando la masa confirmada (0.9 kg con encoder) y su longitud total (147.5 mm). |
| **302–306** | Semieje y chumacera | PENDIENTE sobre material y soporte de semieje. | Redactar el diseño final: Semieje T2 en AISI 1045 $\varnothing 12\text{ h6}$ apoyado sobre dos rodamientos 6001-2RS en chumacera doble mecanizada en U (T1) en 6061-T6, fijada al perfil E5 con dos tornillos M5. |
| **311–314** | Sensor de odometría | Encoder Omron E6B2-CWZ6C exterior. | **Reemplazar completamente:** Explicar que se prescinde del sensor Omron exterior y se aprovecha el encoder magnético/óptico integrado en el motorreductor 42PG, calculando la frecuencia de pulsos a la salida del reductor 67:1. |
| **317–356** | Selección del servo | RDS3225 con $T_{req} = 2.11\text{ N}\cdot\text{m}$ ($FS = 1.11$). | Actualizar el cálculo: Con KPI 15.1° ($e \approx 0$), el torque baja a $1.10\text{ N}\cdot\text{m}$ (plano) y $1.59\text{ N}\cdot\text{m}$ (bajada). El factor frente al bloqueo de $2.35\text{ N}\cdot\text{m}$ pasa a $FS = 1.48$. Detallar el montaje en placa K7 y separadores hexagonales (descartando el soporte en U del fabricante). |
| **361–370** | Mangueta y bujes | Horquilla en C de placa de 6 mm; pasador $\varnothing 8\text{ mm}$ a cortante doble. | Actualizar: Mangueta K1 mecanizada en bloque de 20 mm; pasador inferior K2 y eje superior K3 con bujes SAE 660 ($8 \times 12 \times 8\text{ mm}$) a $2.22\text{ MPa}$; arandelas axiales de empuje de bronce a $0.52\text{ MPa}$. |

---

## 3. Propuesta de Tabla de Parámetros Actualizada para LaTeX (Tabla 5.1)

A continuación se transcribe la tabla lista para reemplazar en la Sección 5.2 de `505_subsistema_traccion_direccion.tex`:

```latex
\begin{center}
    \footnotesize
    \begin{xltabular}{\textwidth}{|p{3.5cm}|>{\centering\arraybackslash}p{2.5cm}|>{\centering\arraybackslash}p{2.5cm}|>{\centering\arraybackslash}X|}
        \caption{Parámetros, variables y restricciones actualizados del subsistema de tracción y dirección Ackermann\label{tab:parametros_diseno_ackermann}} \\
        \hline
        \rowcolor[HTML]{D9E1F2}
        Parámetro o Variable & Símbolo & Valor o Límite & Descripción \\ \hline
        \endfirsthead

        \multicolumn{4}{c}%
        {\tablename\ \thetable{} -- Continuación de la página anterior} \\
        \hline
        \rowcolor[HTML]{D9E1F2}
        Parámetro o Variable & Símbolo & Valor o Límite & Descripción \\ \hline
        \endhead

        \hline
        \endfoot

        \hline
        \endlastfoot

        Masa de diseño del robot & $m$ & $25.00\text{ kg}$ & Masa total de diseño del vehículo completo. \\ \hline
        Aceleración de la gravedad & $g$ & $9.81\text{ m/s}^2$ & Aceleración gravitacional local. \\ \hline
        Peso total del robot & $W$ & $245.25\text{ N}$ & Fuerza gravitacional total. \\ \hline
        Radio efectivo de rueda & $r$ & $0.10\text{ m}$ & Radio exterior de los neumáticos ($\varnothing 200\text{ mm}$). \\ \hline
        Ancho de vía entre ruedas & $b_w$ & $600\text{ mm}$ & Distancia transversal entre los planos medios de las ruedas posteriores y anteriores. \\ \hline
        Distancia entre pivotes de dirección & $b_{\text{piv}}$ & $546\text{ mm}$ & Distancia transversal entre los ejes de pivote del eje frontal ($y = -73\text{ mm}$ y $473\text{ mm}$). \\ \hline
        Distancia entre ejes & $L$ & $440\text{ mm}$ & Distancia longitudinal entre el eje frontal orientable ($x = 490\text{ mm}$) y el eje posterior ($x = 50\text{ mm}$). \\ \hline
        Altura del centro de masa & $h_{cm}$ & $339\text{ mm}$ & Elevación estimada del centro de gravedad respecto al suelo (rango $288$ a $390\text{ mm}$). \\ \hline
        Posición longitudinal del CG & $L_{cm}$ & $173\text{ mm}$ & Ubicación del centro de gravedad medida desde el eje posterior ($39.3\%$ de $L$). \\ \hline
        Ángulo de inclinación del pivote & $\text{KPI}$ & $15.1^\circ$ & Inclinación transversal del eje del pivote hacia el interior del chasis. \\ \hline
        Radio de frotamiento en el suelo & $e$ & $0.0\text{ mm}$ & Distancia en el suelo entre la huella del neumático y la proyección del pivote. \\ \hline
        Radio de la huella de contacto & $r_c$ & $25\text{ mm}$ & Radio equivalente de contacto neumático-suelo. \\ \hline
        Velocidad lineal del robot & $v$ & $1.0\text{ m/s}$ & Velocidad nominal de traslación. \\ \hline
        Aceleración lineal en pendiente & $a$ & $0.30\text{ m/s}^2$ & Aceleración de arranque en pendiente máxima. \\ \hline
        Ángulo de rueda interior & $\delta_i$ & $35.0^\circ$ & Ángulo máximo de viraje de la mangueta interior. \\ \hline
        Ángulo de rueda exterior & $\delta_o$ & $20.5^\circ$ & Ángulo de viraje geométrico de la rueda exterior. \\ \hline
        Ángulo virtual medio & $\delta$ & $26.0^\circ$ & Ángulo de viraje equivalente en el centro del eje frontal. \\ \hline
        Radio de giro mínimo al eje posterior & $R_{\min}$ & $0.90\text{ m}$ & Distancia desde el centro del eje posterior al CIR. \\ \hline
        Pendiente máxima del terreno & $\beta$ & $16.0^\circ$ & Inclinación máxima de trabajo en el campo. \\ \hline
        Coeficiente de rodadura & $f_r$ & $0.05$ & Resistencia a la rodadura en suelo compactado. \\ \hline
        Coeficiente de adherencia estática & $\mu_s$ & $0.60$ & Adherencia caucho-suelo. \\ \hline
        Reacciones normales en arranque & $N_f, N_r$ & $N_f = 34.8\text{ N}$, $N_r = 200.9\text{ N}$ & Cargas normales en ascenso acelerado a $16^\circ$ ($h_{cm} = 339\text{ mm}$). \\ \hline
        Fuerza de tracción total & $F_{\text{trac}}$ & $79.39\text{ N}$ cont. a $86.89\text{ N}$ arr. & Empuje total demandado al eje posterior en $16^\circ$. \\ \hline
        Torque de pivoteo por mangueta & $\tau_{\text{piv}}$ & $0.69\text{ N}\cdot\text{m}$ plano a $1.02\text{ N}\cdot\text{m}$ pend. & Momento de resistencia al viraje estático por rueda delantera. \\ \hline
        Torque por servomotor de dirección & $T_{\text{servo}}$ & $1.10\text{ N}\cdot\text{m}$ plano a $1.59\text{ N}\cdot\text{m}$ pend. & Torque demandado a cada actuador RDS3225 ($FS = 1.48$ frente a bloqueo de $2.35\text{ N}\cdot\text{m}$). \\ \hline
        Torque por motorreductor de tracción & $T_{\text{motor},t}$ & $3.97\text{ N}\cdot\text{m}$ cont. a $5.65\text{ N}\cdot\text{m}$ arr. & Torque requerido en el eje de cada uno de los dos motores 42PG-775-67 ($S = 1.30$). \\ \hline
    \end{xltabular}
\end{center}
```
