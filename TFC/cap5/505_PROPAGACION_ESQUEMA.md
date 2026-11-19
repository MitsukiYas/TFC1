# 505 — Cambios que se propagan desde la estructura (504)

> No se editó `505_subsistema_traccion_direccion.tex` (indicación: por ahora solo `.md`). Esto es la lista de lo que hay que cambiar cuando se escriba.
> Cálculo: `Calculos&Simulaciones/SubsistemaEstructura/propagacion_505.py` (mismas ecuaciones del `.tex`; reproduce los valores actuales: R = 0.83 m, N_f = 87.83 N, τ_piv = 1.165 y 1.377 N·m, T_servo = 1.80 y 2.11 N·m).

## 1. Datos de entrada nuevos (de 504)

| Parámetro | Antes (505) | Ahora | Origen |
|---|---|---|---|
| Vía $b$ (entre pivotes) | 380 mm | **600 mm** (centro a centro de rueda; el pivote queda ≈ 52 mm por dentro, ver 3) | decisión s = 100 mm |
| Distancia entre ejes $L$ | 450 mm | **440 mm** | eje trasero en x = 50, delantero en x = 490 |
| $L_{cm}$ desde el eje trasero | 225 mm | **173 mm** (sin ruedas) | `memoria_05_masas_cg.m` |
| $h_{cm}$ | 180 mm | **288 a 390 mm** (ver 2) | 503 + 504, con suposición |
| Radio de frotamiento $e$ | 15 mm | **≈ 40 mm** | media huella (27.5) + 12 mm de holgura |
| Despeje al suelo | -- | ≈ 59 mm | eje de ruedas a 41 mm sobre la cara inferior |
| Masa de diseño | 25 kg | 25 kg (se mantiene) | 21.4 kg sin ruedas; quedan 3.6 kg para 4 ruedas completas, semiejes, rodamientos, encoders, cubierta y cableado |

## 2. Altura del centro de gravedad: depende de una suposición

El CG vertical de la elevación (10.87 kg) no está calculado en 503. Con el resto (10.6 kg, CG a 155 mm del suelo) y tres alturas supuestas del CG de la elevación sobre la cara superior del bastidor:

| Altura supuesta del CG de la elevación | $h_{cm}$ |
|---|---|
| 100 mm | 288 mm |
| 200 mm | 339 mm |
| 300 mm | 390 mm |

**Falta:** el CG vertical de la elevación en θ = 15° (la memoria de masa de 503 solo da la masa). Hasta tenerlo, los valores de abajo se dan como rango.

## 3. Resultados recalculados

Con $b$ = 600 mm, $L$ = 440 mm, $L_{cm}$ = 173 mm, $e$ = 40 mm, $m$ = 25 kg, $r_c$ = 25 mm, μ = 0.60, $S$ = 1.30, $\eta_s$ = 0.90, $J_{mang}$ y $T_{s,s}$ sin cambio.

| Resultado | Antes | Ahora ($h_{cm}$ = 288 / 339 / 390 mm) |
|---|---|---|
| Radio mínimo de giro $R$ | 0.83 m | **0.89 m** (corregido: $b$ es la distancia entre pivotes, 520 mm, no la vía de ruedas) |
| Rueda exterior $\delta_o$ (con $\delta_{i,max}$ = 35°) | 23.8° | **21.0°** (con $b$ = 520 mm) |
| Ángulo virtual $\delta$ | 28.4° | **25.4°** |
| Relación de velocidades de las ruedas traseras ($b/2R$) | 0.228 | **0.323** (exterior 1.32, interior 0.68) |
| Vuelco lateral estático | 46.5° | 46.1° / 41.5° / 37.6° (frente a 16°) |
| $N_f$ subiendo 16°, $a$ = 0.3 m/s² | 87.83 N | 43.5 / 34.8 / 26.2 N |
| $N_r$ subiendo | 147.91 N | 192.3 / 200.9 / 209.6 N |
| Adherencia $\mu N_r$ frente a $F_{trac}$ = 86.89 N | 88.7 N (casi sin margen) | 115 / 121 / 126 N (margen 1.33 a 1.45) |
| Carga por rueda delantera, plano | 61.31 N | 48.2 N ($N_f$ = 96.4 N: $L_{cm}/L$ = 0.393) |
| Carga por rueda delantera, bajando 16° (crítica) | 72.46 N | 68.5 / 72.4 / 76.3 N |
| $\tau_{piv}$ plano / pendiente | 1.165 / 1.377 N·m | 1.639 / 2.33 a 2.59 N·m |
| **$T_{servo}$ plano / pendiente** | **1.80 / 2.11 N·m** | **2.49 / 3.48 a 3.87 N·m** |
| Par de bloqueo del RDS3225 a 6.5 V | 2.35 N·m | 2.35 N·m |

La fuerza de tracción ($F_{trac}$ = 79.39 N continua, 86.89 N en el arranque) y el torque de los motorreductores no cambian: dependen de la masa y la pendiente, no de la geometría.

### Lo que esto cambia en el diseño
1. **El servomotor RDS3225 ya no alcanza.** Con $e$ ≈ 40 mm, hasta en terreno plano pide 2.49 N·m (> 2.35 N·m de bloqueo) y en la pendiente de 3.5 a 3.9 N·m. La causa es $e$: pasó de 15 a 40 mm porque el pivote tiene que quedar por dentro de la rueda (huella de 55 mm).
   Opciones, de menor a mayor cambio (decide el usuario): (a) pivote en el borde interior de la rueda, $e$ ≈ 27.5 mm (con $e$ = 27.5, $T_{servo}$ en pendiente ≈ 2.9 N·m, sigue sin alcanzar); (b) neumático delantero más angosto; (c) un servo de mayor torque (hay que volver a comparar, con la tensión de 6.5 V del convertidor y su corriente de 5 A); (d) una reducción 1:1.5 entre servo y pivote (rompe el acople directo de 505).
2. **El eje delantero está poco cargado al subir.** $N_f$ cae a 26–43 N por rueda (13 a 22 N): con 16° y 0.3 m/s² el eje trasero toma el 82 al 89 % de la carga. El vuelco hacia atrás ocurre a ≈ 24° (con $h_{cm}$ = 390 mm) o más, por encima de los 16°, pero el margen baja. La tracción mejora (más carga en las ruedas motrices).
3. **El radio de giro sube de 0.83 a 0.93 m** y la rueda exterior gira menos (19.7°): hay que revisar la tabla de parámetros, el cálculo de velocidades (505 usa 1.228 y 0.772) y el requisito del Req. 8 si se evaluó con 0.83 m.
4. **Con la vía de 600 mm el vuelco lateral no preocupa** (≥ 37°).

## 4. Edición pendiente en `505_subsistema_traccion_direccion.tex`

| Línea | Cambio |
|---|---|
| 34 | Desglose de masas: motorreductor 0.8 kg c/u (hoja del fabricante, web de E-S Motor); servos 60 g; bastidor 3.40 kg; batería 2.16 kg con gabinete; ver 504. |
| 36–37 | Vía 600 mm, distancia entre ejes 440 mm, CG: $L_{cm}$ = 173 mm y $h_{cm}$ (con la suposición declarada); ángulo de vuelco nuevo. Quitar el PENDIENTE de $h_{cm}$ solo cuando esté el CG vertical de la elevación. |
| 38 | $\delta_o$ = 19.7°, $R_{min}$ = 0.93 m. |
| 66–69, 75–77, 81, 83, 88 | Parámetros de la tabla: $b$, $L$, $L_{cm}$, $h_{cm}$, $\delta_o$, $\delta$, $R$, $N_f$ y $N_r$, $\tau_{piv}$, $T_{servo}$, y $e$ (línea del radio de frotamiento: 15 → ≈ 40 mm). |
| 100 (suposición 1, [COMENTARIO]) | Cuerpo rígido: sustituir el comentario por la respuesta de 504: el bastidor tiene una rigidez torsional alta (~150 N·m/°; 0.75 mm de desnivel descarga una rueda) y se acepta el apoyo en 3 ruedas; con una rueda sin contacto la tracción queda con 4 N en la rueda trasera menos cargada. |
| 239–248 | Fuerza de tracción sin cambio; las cargas por rueda (61.31 → 48.2 N plano; 72.46 → 68 a 76 N bajando). |
| 244 | Razones de velocidad de ruedas traseras con $R$ = 0.93 m: 1.32 y 0.68. |
| 315–357 | Selección del servo: el RDS3225 no cumple. Replantear (ver arriba) antes de redactar. |
| 361–370 | Acople del servo y del pivote: ver 504, silla en U sobre el extremo del travesaño; el pivote 12 mm por dentro de la cara interior de la rueda. |
| Semieje trasero, 302–309 | Hay ≈ 70 mm entre el motor y la rueda para el acople y los dos rodamientos (504). Cargas: 110.6 N con $k_d$ = 2 por rueda trasera. |

## 5. Pendientes que siguen abiertos
- CG vertical de la elevación (503) para fijar $h_{cm}$.
- Masa de las ruedas completas, semiejes y chumaceras.
- Decisión del servo / de $e$ (arriba).

## 6. Opciones para que el RDS3225 alcance (`opciones_direccion.py`)

Torque requerido con $h_{cm}$ = 339 mm, frente a 2.35 N·m de bloqueo a 6.5 V. La vía no aparece en la ecuación del torque de pivoteo: reducirla no lo baja. Lo que manda es $e$ y la carga de la rueda.

| Opción | $e$ en el suelo | Plano [N·m] | Bajando 16° [N·m] | FS |
|---|---|---|---|---|
| A. Actual: pivote vertical, huella 55 mm | 40 mm | 2.49 | 3.67 | 0.64 |
| B. Vía menor (s = 60), mismo pivote | 40 mm | 2.49 | 3.67 | 0.64 |
| C. Neumático de 30 mm, pivote vertical | 27 mm | 1.94 | 2.86 | 0.82 |
| D. Pivote inclinado (KPI) 14°, huella 55 | 15 mm | 1.83 | 2.69 | 0.88 |
| E. KPI 21.8°, huella 55 | 0 | 1.41 | 2.05 | 1.14 |
| F. Pivote dentro del rin (hub-center), vertical | 15 mm | 1.44 | 2.10 | 1.12 |
| G. Neumático de 30 mm + KPI 15.1° | 0 | 1.10 | 1.59 | 1.48 |

Sin inclinación del pivote, $e$ debe ser ≤ 17 a 21 mm (según $h_{cm}$) para que alcance bajando y ≤ 37 mm en plano.

**Suposición:** el momento de levantamiento por la inclinación del pivote se aproxima como $N\,d\,\sin(\text{KPI})\,\sin\delta$ en el giro máximo (35°), con $d$ = 40 mm (27 mm con neumático de 30 mm) a la altura del eje. Hay que verificar la expresión con Gillespie o Jazar antes de usarla.

**Corrección a la sección 3:** el $b$ de Ackermann es la distancia entre pivotes. Con el pivote 40 mm por dentro del plano de la rueda, $b$ = 520 mm (no 600): $R_{min}$ = 0.89 m y $\delta_o$ = 21.0°. La vía de ruedas (600 mm) sigue aplicando al vuelco y al diferencial electrónico de las ruedas traseras.

## 7. Decisión (usuario, 2026-11-18): neumático delantero de 30 mm + pivote inclinado 15°

- Neumático delantero de Ø200 × 30 mm (el trasero sigue de 50 a 55 mm). Falta el modelo comercial y su ficha (capacidad de carga, radio de la huella).
- Pivote inclinado (KPI) 15.1° hacia el bastidor, a 27 mm del plano de la rueda a la altura del eje (15 mm de media huella + 12 mm de holgura): su prolongación corta el suelo en el centro de la huella, $e$ ≈ 0.
- Torque del servo: 1.10 N·m en plano y 1.59 N·m bajando 16°; FS = 1.48 frente a los 2.35 N·m de bloqueo del RDS3225 (incluye el momento de levantamiento aproximado; verificar la expresión con Gillespie o Jazar).
- El plano de la rueda delantera se mantiene a s = 100 mm (vía 600 mm igual a la trasera); el pivote queda en y = −73 mm, de modo que $b$ (entre pivotes) = 546 mm, $R_{min}$ = 0.90 m y $\delta_o$ = 20.5°.
- El servo va coaxial con el pivote, por lo que su base queda inclinada 15°: la silla en U de 504 lleva una cuña de 15°.
- $r_c$ = 25 mm de 505 era para la huella de 50 a 55 mm; con 30 mm hay que tomarlo de la ficha del neumático (el resultado de arriba lo mantiene en 25 mm, conservador si la huella real es menor).
- Efectos secundarios del KPI que 505 debe mencionar: cambio de caída de la rueda al girar y el momento de levantamiento, que tiende a recentrar la dirección.

## 8. Pivote delantero definido en 504 (2026-11-18)

Ver `Calculos&Simulaciones/SubsistemaEstructura/Planos/BOM_pivote_delantero.md` y `memoria_10_pivote_delantero.m`. Para 505:
- Mangueta K1 mecanizada de 6061-T6 de 20 mm (reemplaza la «horquilla en C de placa de 6 mm»).
- Pivote: pasador fijo Ø8 abajo (K2) y eje del servo Ø8 arriba (K3), con bujes SAE 660 8 × 12 × 8; arandelas de empuje de bronce.
- El servo no se acopla directo al pasador: mueve la mangueta por el horn, el acople K4 y el eje K3, con pasadores elásticos ISO 8752 Ø3.
- Espiga K5 de 60 mm (antes 45 mm), asiento de 20 mm en la mangueta; rodamientos SKF 6000-2RSH sin cambio.
- Verificaciones: bujes 2.2 MPa; pasador y eje Ø8 a flexión FS 12; torsión de K3 con agujero FS 3.8; pasador elástico FS 10.8; montante de la mangueta FS 9.8.

## 9. Tracción trasera definida en 504 (2026-11-18)

Ver `Calculos&Simulaciones/SubsistemaEstructura/Planos/BOM_traccion_trasera.md` y `memoria_11_traccion_trasera.m`. Para 505:
- Semieje Ø12 de AISI 1045 sobre dos rodamientos 6001-2RS (antes «KFL001 con SKF 6001»), en un soporte en U (T1) atornillado al travesaño trasero E5.
- Acople flexible de mandíbulas Ø20 × 30 (8 a 12 mm) entre el motor y el semieje; cubo con chaveta 4 × 4 y tuerca M12 × 1.25.
- Carga radial de diseño: 216 N en el rodamiento exterior (110.6 N por rueda en el caso dinámico), en lugar de 73.96 N.
- **Encoder (decisión del usuario):** 42PG-775-67 con encoder de fábrica (mismos pines que el anterior); largo total 147.5 mm desde la punta del eje. Se elimina el Omron E6B2 y su acople. En 505 y en el cap. 6 (602) cambia la resolución: el encoder mide el eje del motor, antes del reductor de 67:1, así que las cuentas por vuelta de rueda y la frecuencia de pulsos dependen de su hoja de datos (pendiente).

## 10. Rueda genérica única (decisión del usuario, 2026-11-18)

Rueda supuesta: Ø200, 50 mm de ancho, núcleo de 10 mm, agujero Ø25, 4 × M4 a 90° (PCD 40), capacidad suficiente. Ver `memoria_12_ruedas_brida.m` y `Planos/BRIDAS_rueda.png`.
- **Delantera:** eje Ø8 en dos chumaceras KFL08 fijas a la mangueta, con brida de agujero Ø8 (prisioneros). Del pivote al plano de la rueda siguen siendo 27 mm (KFL08 13 + holgura 3 + brida 6 + medio núcleo 5), así que el servo mantiene FS 1.48. Reemplaza la espiga Ø10 y los dos 6000.
- **Trasera:** brida con chaveta 4 × 4 × 16 sobre el semieje Ø12 (reemplaza el cubo); semieje de 112 mm. Rodamientos, T1 y voladizo sin cambio.
- Pendiente: comprobar con el rin real el hueco junto al núcleo y la holgura de 2 mm entre la mangueta y el neumático.

## 11. Revisión del servo y del cubo delantero (2026-11-19)

Ver `memoria_13_servo_y_buje_delantero.m`, `Planos/SERVO_DETALLE.png` y `Planos/CUBO_DELANTERO_DETALLE.png`.
- **Servo:** el soporte en U de 64 × 55.6 × 20 de la hoja de datos gira con la salida (va al horn y al eje trasero libre); no sirve como base. El servo se fija por su carcasa a una placa K7 (54 × 32 × 3, agujero Ø26) sobre dos separadores M4 × 12 en el brazo superior de F2, que pasa a 44 mm de ancho. La posición de la salida (10 mm de un extremo) y las plantillas de la carcasa y del horn no están publicadas: se miden en el servo.
- **Cubo delantero:** se reemplazan las dos KFL08 (una sola no resiste momento por ser autoalineante) por una espiga fija Ø8 en la mangueta y un cubo-brida K6 con dos 688-2RS dentro del centrador Ø25. Cargas: 20 y 59 N; C0 necesaria ≥ 118 N. Se mantienen los 27 mm del pivote al plano de la rueda y el FS 1.48 del servo.
