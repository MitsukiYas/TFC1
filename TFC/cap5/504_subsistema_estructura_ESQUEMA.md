# 504 — Diseño de la estructura de soporte (esquema de trabajo)

> Borrador de estructura del futuro `504_subsistema_estructura.tex`. No es texto final.
> Cálculos: `Calculos&Simulaciones/SubsistemaEstructura/memoria_01_bastidor.m` (primera pasada).
> Convenciones: solo `\citep`, sin números de tablas o ecuaciones de las fuentes; sin el término «CAD»; sin protección IK por ahora.

---

## 5.4.1 Descripción general del subsistema

- Función: soportar y unir los subsistemas de elevación (503, con orientación encima), tracción y dirección (505), los gabinetes y la batería, y transmitir sus cargas a las cuatro ruedas.
- Componentes:
  1. Bastidor de perfil V-slot 2020 (6063-T5) con forma de caja de **500 × 400 × 260 mm** (largo × ancho × alto, envolvente exterior, dato del ensamble).
  2. Dos largueros superiores de elevación, bajo los planos medios de las placas de la base (y = 200 ± 119.45 mm).
  3. Dos travesaños inferiores que soportan la batería.
  4. Uniones: escuadras / placas en L con tornillos M5 y tuercas en T.
  5. Cubierta: sombra y protección mecánica de los gabinetes (el IP65 lo dan los gabinetes; ver 5.4.5).
- Figura: vista isométrica del bastidor (`SOPORTE-VIGAS-ISO.png`, actualizar) y vista explosionada con los gabinetes.
- Interfaces que esta sección cierra (nota [1] de `cap5.tex`):
  - base de elevación y motorreductor NMRVS40 → largueros superiores (pendiente de la 503: «fijación de la base al chasis»);
  - gabinetes de potencia y control → largueros laterales; gabinete de batería → travesaños inferiores;
  - ejes de las ruedas → largueros inferiores. Los motorreductores traseros 42PG-775-67 quedan fuera del bastidor (dato del usuario); sus soportes se tratan en 505.

## 5.4.2 Planteamiento inicial y parámetros de diseño

### Requerimientos de la Tabla de requerimientos (205) que afectan a la estructura
| Req. | Uso en la estructura |
|---|---|
| 1 Geometría (600×600×500 mm, < 20 kg) | Solo referencia (indicación del usuario). Se informa el cumplimiento o el exceso. |
| 4 Pendiente 16° | Caso de carga de pendiente. |
| 3 Velocidad 1 m/s / arranque 0.3 m/s² (505) | Caso de carga de arranque. |
| 6 IP65, 10–45 °C | Lo cumplen los gabinetes; la estructura los soporta y les da sombra (606 supone gabinetes protegidos de la radiación directa). |
| 2 Altura ≥ 1300 mm | La altura del bastidor fija $z_p$ de la 503 → recalcular las alturas de 904 y 1313.6 mm. |

### Tabla de parámetros (formato: Parámetro | Símbolo | Valor | Fuente)
| Parámetro | Valor | Fuente / estado |
|---|---|---|
| Envolvente del chasis | 500 × 400 × 260 mm | Ensamble (usuario) |
| Distancia entre ejes / vía | 450 / 380 mm | 505 |
| Posición de los ejes | centrados en el largo (25 y 475 mm) | **SUPOSICIÓN** |
| Pivote actuado de elevación | 54 mm de la cara trasera | 503 (`parametros_elevacion`) |
| Separación de las placas de la base | 238.9 mm | 503 |
| Masa de elevación + orientación | 10.87 kg (4.33 kg móviles) | 503, memoria 12 |
| Gabinetes potencia y control | Ensto Cubo S 175×250×100, lados largos, tapa afuera | cap. 6 |
| Gabinete de batería | Ensto Cubo D 120×200×86, centrado en el piso | cap. 6 |
| Masa de cada gabinete con contenido | 1.5 kg | **SUPOSICIÓN** — falta la masa del catálogo Ensto |
| Batería | 1.56 kg + 0.6 kg del gabinete | 606 + **SUPOSICIÓN** |
| Motorreductor 42PG-775-67 (×2, eje trasero, fuera del bastidor) | 0.8 kg c/u; reductor 53.5 mm + motor 66.5 mm + 22 mm de eje = 142 mm; cuerpo Ø42; brida Ø26 con 4×M4 en Ø35; eje Ø8 | Hoja de datos E-S Motor (plano); la masa figura en la página web de donde se descargó el PDF, citar como parte del PDF (dato del usuario) |
| Tuerca en T M5 | 684 N última; admisible 351 N ($n_u = 1.95$) | Valor adoptado por indicación del usuario, el mismo de 503 (Ooznest) |
| Placa en L 4 agujeros | 2 mm de espesor, 60×60 mm, Ø5.5 a 20 mm, 40 g | Probots, confirmado por el usuario |
| Perfil 2020: $I_x = I_y$ | 6988 mm⁴ | Naylamp (catálogo V-slot) |
| Perfil 2020: área, $J$, masa lineal | 160 mm², 1000 mm⁴, 0.49 kg/m | **SUPOSICIÓN** — Naylamp no los publica |
| 6063-T5: $F_{ty}$, $E$, $G$ | 110 MPa, 69.6 GPa, 26.2 GPa | Aluminum Design Manual |
| Admisible ($n_y = 1.65$) | 66.7 MPa | mismo criterio que 503 |
| Factor dinámico vertical $k_d$ | 2.0 | **SUPOSICIÓN** (fuente 5, indicada por el usuario) |
| Obstáculo bajo una rueda | 20 mm | **SUPOSICIÓN** (fuente 5) |

### Suposiciones del modelo (lista numerada, como en 505)
1. Uniones rígidas (las escuadras reales son semirrígidas → el modelo sobreestima la rigidez).
2. Ruedas y neumáticos rígidos, sin suspensión.
3. Las cargas de los gabinetes llegan a los largueros como cargas puntuales en 4 puntos.
4. La elevación se representa por su peso y el momento de la parte móvil, aplicados como un par vertical sobre los largueros de elevación (entre x = 54 y 110 mm).

## 5.4.3 Planteamiento estático

- Modelo: pórtico espacial, método de rigidez directa con vigas 3D de 12 GDL (Shigley: deflexión y rigidez; problemas estáticamente indeterminados). Malla: 54 nodos y 62 elementos.
- Apoyos: z en las 4 ruedas, x en las traseras (tracción) e y en las delanteras.
- Casos de carga:
  - **LC1** estático, θ = 15° (la parte móvil está más adelantada → mayor momento);
  - **LC2** LC1 × $k_d$ (marcha sobre irregularidades);
  - **LC3** pendiente de 16° + arranque a 0.3 m/s²;
  - **LC4** una rueda delantera sobre un obstáculo (ruedas rígidas → la diagonal opuesta se descarga y el robot queda sobre 3 ruedas).
- Pendiente para la próxima versión: viento lateral con θ máx. (±127.6 N en la base, 503) y la combinación pendiente + viento.
- Figuras a preparar: esquema del pórtico con nodos, cargas y apoyos; DCL de cada caso.

### Resultados de la primera pasada (`memoria_01_bastidor.m`)
| Caso | σ máx [MPa] | FS (vs 66.7) | Flecha máx [mm] | Pitch en la base [°] | Rz RI / RD / FI / FD [N] |
|---|---|---|---|---|---|
| LC1 | 12.6 | 5.3 | 0.31 | 0.127 | 48.6 / 48.6 / 44.8 / 44.8 |
| LC2 | 25.2 | 2.6 | 0.62 | 0.254 | 97.2 / 97.2 / 89.5 / 89.5 |
| LC3 | 7.1 | 9.4 | 0.17 | 0.058 | 68.7 / 68.7 / 21.0 / 21.0 |
| LC4 | 12.9 | 5.2 | 0.77 | 0.080 | 3.8 / 93.4 / 89.5 / 0 |

- Elemento crítico (LC1–LC4): el larguero de elevación entre x = 110 y 250 mm, justo delante de la base.
- Rigidez torsional del bastidor: ≈ 150 N·m/°. Basta **0.75 mm** de desnivel para descargar una rueda. Con $J$ tres veces menor, los resultados cambian menos de un 6 %.
- **Decisión (usuario):** no se agrega eje basculante ni suspensión; se acepta que en terreno irregular el robot se apoye en 3 ruedas. La estructura se verifica con el caso LC4 (rueda levantada, bastidor rígido). Se declara como limitación; para 505, una rueda motriz puede quedar con ≈ 4 N y perder tracción en ese instante (el comentario de 505 sobre la suposición de cuerpo rígido: válida para la estructura, no para la tracción).
- Uniones (ver 5.4.4): en las 8 esquinas, el mayor momento es 4.6 N·m (LC4) y el mayor cortante 62 N (LC2). El máximo de la malla (17.6 N·m, LC2; 295 N) está en el nudo donde se aplica la carga de la base de elevación, no en una esquina.
- Pitch: el giro estático de 0.13° en la base es un desfase constante, que se puede calibrar. Compararlo con el criterio de pitch de la 502 (≥ 0.2° medible) solo si el usuario lo acepta como criterio.

## 5.4.3b Distribución de componentes y acoples a las vigas

Figura: `Recursos/Imagenes/ImagenesDisenoMecanico/ESTRUCTURA_DISTRIBUCION.png` (planta y lateral, medidas en mm). Origen: cara trasera, lado izquierdo, cara inferior del bastidor.

### Posiciones (envolventes de las fichas; sin modelo 3D)
| Componente | Volumen | Posición (x · y · z) | Acople a las vigas |
|---|---|---|---|
| Gabinete de potencia, Cubo S | 250 × 100 × 175 | x 90–340 · y 20–120 · z 20–195 | Tapa hacia afuera; cuatro tornillos M5 con tuercas en T al larguero inferior y al superior del lado izquierdo (dos y dos). |
| Gabinete de control, Cubo S | 250 × 100 × 175 | x 90–340 · y 280–380 · z 20–195 | Igual, en el lado derecho. |
| Batería en Cubo D | 200 × 120 × 86 | x 150–350 · y 140–260 · z 20–106 | Apoyado sobre los dos travesaños inferiores (x = 150 y 350), con cuatro tornillos M5; apoyo en cuatro puntos. |
| Motorreductor 42PG-775-67 (×2) | Ø42 × 120 (+22 de eje) | Eje en x = 50, z ≈ 41 · y: 20–140 (izq.) y 260–380 (der.) | Brida (centrador Ø26, 4 × M4 en Ø35) a una placa de 4 mm de 6061-T6 atornillada con tuercas en T al travesaño del eje trasero y al larguero inferior; el cuerpo se apoya sobre el travesaño. |
| Servomotor RDS3225 (×2), 40 × 20 × 40.5 (con soporte en U 64 × 55.6) | | En los extremos del travesaño delantero, y = −60 y 460 | Soporte en U atornillado a una placa sobre el extremo del travesaño; el pivote (505) queda vertical. |
| Base de la elevación | 503 | Postes y placas sobre los largueros de elevación, y = 80.5 y 319.5 | Ver 503 (escuadras de tope y tuercas en T). |

No hay interferencia entre los gabinetes (y 20–120 y 280–380), la batería (y 140–260) y los motores, que quedan detrás de los gabinetes (x < 90). Libre: x 350–480 entre el gabinete y la cara delantera.

### Hallazgos que cambian otras secciones
1. **La vía de 380 mm de la 505 no cabe.** El bastidor mide 400 mm de ancho y las ruedas (huella de 55 mm) quedan fuera de él. Con el plano de cada rueda a 100 mm de la cara lateral (**decidido**: s = 100 mm, para que quepan el acople y los dos rodamientos del semieje), la vía pasa a 600 mm y el ancho total a 655 mm. Hay que recalcular en 505 el ángulo de Ackermann y el radio de giro (dependen de la vía) y el vuelco (la vía crece, mejora).
2. **Distancia entre ejes de 440 mm, no de 450 mm.** El eje trasero en x = 50 mm (el motor libra el poste de la esquina) y el delantero en el poste delantero (x = 490 mm).
3. **Los ejes son travesaños de 2020 que sobresalen de cada lado hasta la cara interior de la rueda** (en el modelo, s = 100 mm: largo de 600 mm; uno atrás y el delantero ya existente). Si la rueda se apoyara en los largueros laterales, la carga excéntrica los torcería: con el área torsional supuesta, FS = 0.81 en el caso dinámico. Con los travesaños en voladizo y s = 100 mm, FS ≥ 1.7 (caso dinámico; la fuerza se aplica en el plano de la rueda, lo que es conservador). Es la única pieza que agrego respecto al bastidor original.
4. **Despeje al suelo.** El eje de las ruedas (Ø200) queda a 41 mm sobre la cara inferior del bastidor, por lo que el bastidor queda a unos 59 mm del suelo . Esto fija $z_p$ de la 503.
5. **Centro de gravedad y reparto de masa (sin ruedas): 21.4 kg** (`memoria_05_masas_cg.m`). El CG longitudinal queda a 223 mm de la cara trasera, es decir, a 173 mm del eje trasero (la 505 supone 225 mm desde el eje trasero con 450 mm de distancia entre ejes), con 61 % de la carga en el eje trasero. Las ruedas completas (neumático, rin, cubo) no tienen masa definida y no están incluidas.

### Resultados de la segunda pasada (`memoria_04_distribucion.m`, s = 100 mm)
| Caso | σ máx [MPa] | FS (vs 66.7) | Flecha máx [mm] | Pitch en la base [°] |
|---|---|---|---|---|
| LC1 estático | 19.8 | 3.4 | 0.48 | 0.104 |
| LC2 dinámico | 39.5 | 1.7 | 0.95 | 0.208 |
| LC3 pendiente + arranque | 27.2 | 2.5 | 0.43 | 0.017 |
| LC4 rueda delantera sobre obstáculo | 28.6 | 2.3 | 1.78 | −0.012 |

Masa del bastidor con los dos travesaños de eje: 3.40 kg. El elemento crítico es el larguero lateral inferior entre la esquina y el travesaño del eje trasero (recibe como torsión parte del momento del voladizo); con s = 60 mm el FS mínimo era 2.5.

## 5.4.4 Dimensionamiento de componentes

1. **Largueros de elevación**: flexión y flecha (tabla Parámetro | Valor calculado | Valor asignado).
2. **Postes**: compresión y pandeo (Shigley, columnas). Esfuerzo bajo; verificar por completitud.
3. **Uniones de esquina**: momento y cortante del modelo en cada nudo → fuerza por tornillo M5 y por tuerca en T.
   - Placa en L de 4 agujeros, 6063-T5, 60 × 60 × 2 mm, agujeros de Ø5.5 a 20 mm (Probots).
   - Alternativas de Naylamp: bracket L universal (3 mm, M5×8) y placa de unión en L de 5 agujeros (6105-T5, 60 × 60 × 4 mm, M5×10).
   - Resultado de `memoria_02_uniones.m` (supone dos tuercas por rama a 20 mm y el momento de la placa repartido en dos ramas, ambas suposiciones): en las esquinas, 115 N por tuerca en el caso crítico (LC4) frente a 351 N admisibles, FS = 3.0. Basta una placa L de 4 agujeros por esquina.
   - Tuerca de inserción M5 (Ooznest DIN-20-M5, acero niquelado). **La página guardada no muestra la capacidad de 684 N que usa la 503**: falta la pestaña de especificaciones o el dibujo.
   - Tornillos ISO 4762 / A2-70: tracción y cortante (Shigley, uniones atornilladas).
4. **Travesaños de la batería** y **soportes de los gabinetes** (flexión local).
5. **Fijación de la base de elevación al chasis** (pendiente de la 503).
6. **Presupuesto de masa del robot completo** y **centro de gravedad** → valores de $h_{cm}$ y $L_{cm}$ para la 505.
   - Bastidor: 6.12 m de perfil ≈ 3.0 kg (con la masa lineal supuesta) + uniones.
   - Suma parcial: 10.87 + 3.0 + 3.0 + 2.16 ≈ 19 kg **sin** ruedas, motores, servos ni cubierta → supera los 20 kg del Req. 1 (solo referencia). La 505 usa 25 kg.

## 5.4.4b Acople de los motorreductores traseros (`memoria_06_acople_motor.m`)

**Soporte (uno por motor):** pieza en L mecanizada de 6061-T6, de 4 mm.
- *Ala vertical* (x 20–86, z 20–70, y 20–24): lleva el agujero de Ø26 H7 para el centrador de la brida (Ø26 −0.05, plano del fabricante) y los cuatro agujeros de Ø4.5 de los M4 (4 × M4 en Ø35, 5 mm de profundidad de rosca en el reductor).
- *Ala horizontal* (y 0–24): apoya sobre la cara superior del larguero trasero, del travesaño del eje y del larguero delantero, con tres M5 y tuercas en T en la ranura superior (y = 10; x = 30, 50 y 70).
- El ala vertical termina en x = 86 para dejar 4 mm de holgura al gabinete (empieza en x = 90).
- El motor (Ø42) apoya además sobre el travesaño (el eje queda a 41 mm, ver 5.4.3b).

**Cargas:** par de reacción de 6.75 N·m (límite de corriente, 505), peso del motor de 0.8 kg × $k_d$ = 2 a 60 mm de la brida.

| Verificación | Carga | Capacidad | FS |
|---|---|---|---|
| Tornillos M4 de la brida, cortante | 96.4 N por tornillo (11.0 MPa) | $0.577 S_y$ con A2-70 (450 MPa) | 23.6 |
| Aplastamiento del agujero de la placa | 5.4 MPa | 145 MPa ($F_{ty}/1.65$) | 27 |
| Tuerca en T más cargada | 128 N (96 N por el par y 31 N por el peso) | 351 N (684 N / 1.95) | 2.7 |

**Suposiciones de esta verificación:** ala horizontal rígida; el borde del ala es el pivote del par; el peso se reparte por igual entre las tres tuercas con 10 mm de brazo; tornillería M4 de acero inoxidable A2-70, y el área de esfuerzo del M4 de Shigley (8.78 mm²).

**Pendiente:** el cortante de las tuercas en T no interviene porque el par se resuelve con fuerzas verticales de las tuercas y apoyo del ala (como en 503); el material del reductor no está publicado, por lo que no se verifica la rosca M4 de 5 mm de profundidad.

## 5.4.4c Soporte de los servomotores de dirección (`memoria_07_soporte_servo.m`)

**Soporte (uno por servo):** silla en U de 6061-T6 de 4 mm que abraza el extremo del travesaño delantero, con una cuña de 15° para que el servo quede coaxial con el pivote inclinado (decisión de 505: neumático delantero de 30 mm + KPI 15°; pivote en y = −73 mm). Placa superior para la base del servo (40 × 20 mm, soporte en U del fabricante de 64 × 55.6 mm) y dos labios laterales apoyados en las caras del perfil; dos M5 con tuercas en T en la ranura superior (y = −65 y −45 mm, con el extremo del travesaño en y = −70).

**Cargas:** par de bloqueo de 2.35 N·m (6.5 V, tabla de 505) alrededor del eje vertical. Como los dos M5 están alineados con la ranura, el par no puede reaccionarse con ellos; lo toman los labios como par de fuerzas con 40 mm de brazo (suposición). La carga vertical de la rueda (39.6 N estática, 79.3 N con $k_d$ = 2, modelo 04) se transfiere por apoyo del casquillo del pivote contra el extremo del travesaño, sin tracción en las tuercas; eso depende del diseño de la mangueta en 505.

| Verificación | Carga | Capacidad | FS |
|---|---|---|---|
| Fuerza en cada labio | 58.8 N | -- | -- |
| Flexión en la raíz del labio (4 mm, 10 mm de largo de contacto) | 22.0 MPa | 145 MPa ($F_{ty}$/1.65) | 6.6 |
| Presión de contacto labio-perfil | 0.59 MPa | -- | -- |

**Suposiciones:** 40 mm de brazo entre labios, 10 mm de largo de contacto por labio y apoyo a 10 mm de altura.

### Inconsistencias de geometría que esto deja al descubierto (para 505)
1. **El travesaño no puede llegar al plano de la rueda.** Con s = 100 mm la huella de 55 mm ocupa y = −127.5 a −72.5; el extremo del travesaño debe quedar en y ≈ −70 (el modelo 04 aplica la fuerza en y = −100, por lo que el brazo de la rueda es 100 mm en lugar de ≈ 50 a 70 mm: conservador).
2. **El radio de frotamiento de 505 (15 mm) no es compatible con la rueda.** El pivote vertical debe quedar por dentro de la cara interior de la rueda (media huella de 27.5 mm + 12 mm de holgura): $e$ ≈ 40 mm. Aumenta el torque de pivoteo y el del servo (505).
3. **Espacio para el semieje trasero (resuelto con s = 100 mm).** Entre la cara exterior del bastidor y la cara interior de la rueda quedan 72.5 mm; el eje del motor termina en y = −2 mm, y quedan unos 70 mm para el acople y los dos rodamientos (acople ≈ 25 mm y dos rodamientos de 8 mm: dimensiones supuestas).

## 5.4.5 Selección de componentes

1. **Perfil estructural**: rehacer la tabla con datos citados (Naylamp para 2020/2040; para la opción de tubo, un proveedor de tubo cuadrado). Corregir la inconsistencia del tubo de 20×20×1.5 (la masa corresponde a 1.5 mm y la inercia a 2 mm).
2. **Uniones**: comparar el bracket L interno, la placa L externa de 4–5 agujeros y el conector de esquina de aluminio maquinado (Naylamp / Probots).
3. **Cubierta**: material (chapa de aluminio 5052-H32, ya usada en 503, frente a una impresa en 3D, ambas de la matriz morfológica del cap. 3). Función: sombra para los gabinetes (606) y protección mecánica. Sin clasificación IK por ahora.

## 5.4.6 Simulación y validación

- FEA del bastidor (estático) en LC2 y LC4, comparado con la memoria (Shigley, elemento finito: condiciones de borde y convergencia de malla).
- Sensibilidad a la rigidez de las uniones (rígidas frente a articuladas en un eje).

## 5.4.7 Resumen

- Tabla de verificaciones (solo con los criterios que establece el texto; «--» donde no haya criterio).
- Limitaciones: uniones rígidas, ruedas rígidas, $k_d$ y obstáculo supuestos, propiedades del perfil sin fuente.

---

## Qué falta para cerrar el 504
**Datos que nadie ha definido todavía (suposición en el cálculo)**
1. Constante de torsión $J$, área y masa lineal del perfil 2020 (fuente de proveedor). Con $J$ tres veces mayor, la torsión deja de ser crítica incluso con la rueda apoyada en los largueros.
2. Masa de los gabinetes Ensto (1.5 kg supuestos) y de las ruedas completas.
3. **Decidido (usuario, 2026-11-18):** vía de 600 mm (s = 100 mm), distancia entre ejes de 440 mm y despeje de ≈59 mm. Falta propagarlo: 503 ($z_p$ y las alturas de 904 y 1313.6 mm) y 505 (Ackermann, radio de giro, vuelco, $h_{cm}$ y $L_{cm}$ = 173 mm desde el eje trasero).

**Verificaciones que no se han hecho**
4. Fijación de la base de elevación al chasis (pendiente de la 503): el nudo de carga llega a 17.6 N·m.
5. ~~Soportes de los motores~~ — hecho en 5.4.4b (FS mínimo 2.7 en la tuerca en T); falta solo la rosca M4 del reductor (material no publicado).
6. ~~Soporte del servomotor~~ — hecho en 5.4.4c; falta el diseño de la mangueta y el pivote en 505.
7. ~~Decidir s~~ — decidido s = 100 mm (ver 5.4.4c). Falta confirmar con el acople y los rodamientos que se elijan en 505.
8. Pandeo de los postes y verificación del larguero de elevación por separado (comparación con la memoria).
9. Validación por elementos finitos del bastidor (5.4.6).
10. Cubierta (sin IK): material y geometría; protección de los motores contra el polvo (pendiente de la 505).
11. Con todo lo anterior, el presupuesto final de masa del robot con ruedas y el CG vertical (la memoria 05 solo da el longitudinal).


## Armado para el modelo 3D (2026-11-18)

Planos, BOM y vistas en `Calculos&Simulaciones/SubsistemaEstructura/Planos/` (generados por `generar_ensamble.py` y `generar_piezas.py`).

- **Topología:** largueros exteriores E1 de 500 mm continuos (arriba y abajo), postes E2 de 220 mm entre ellos, travesaños E3 de 360 mm entre largueros, largueros de elevación E4 de 460 mm entre los travesaños superiores. Total de perfil: 7020 mm.
- **Travesaños de eje bajo los largueros (cambio):** E5 (540 mm) y E6 (520 mm) pasan por debajo de los largueros inferiores (z = −20 a 0) para ser continuos y trabajar a flexión; con el bastidor en un mismo nivel no podían cruzar los largueros sin cortarse. Despeje bajo E5 y E6: 39 mm. El modelo 04 los tiene en el plano de los largueros; el cambio no se ha recalculado.
- **Gabinetes:** cada Cubo S se atornilla por su fondo a la pared del soporte F3 (plantilla de Ensto pendiente); la base de F3 se atornilla al larguero inferior y apoya sin tornillos en el travesaño de batería, porque ahí quedaría bajo el gabinete.
- **Batería:** placa F4 de 4 mm con tornillos avellanados (ISO 10642) a los travesaños de batería, que quedan bajo el Cubo D.
- **F2 en el poste delantero (decisión del usuario, 2026-11-18).** Se elimina el travesaño delantero en voladizo (E6). Cada F2 es una pieza mecanizada de 6061-T6 en la cara exterior del poste delantero: alma de 6 mm con 4 M5 (tres al poste y uno al larguero inferior), labio bajo el larguero inferior que toma la carga vertical por apoyo, brazo inferior (z = 160) con el pasador fijo Ø8 y brazo superior (z = 210) con el buje Ø12 y la base del servo a 15°. Ambos brazos quedan sobre la rueda (borde superior del neumático en z = 141). Verificación en `memoria_09_soporte_pivote.m`: tuerca en T más cargada 88 N frente a 351 N (FS 4.0), brazos con FS ≥ 36, labio con FS 31. El bastidor con este apoyo (`memoria_08_soporte_pivote_poste.m`) mantiene el FS mínimo de 1.69 (lado trasero). Perfil total: 6500 mm.
