# BOM de la tracción trasera (2 conjuntos: izquierdo y derecho)

Planos: `TRACCION_CONJUNTO.png`, `T1_soporte_rodamientos.png`, `T2_semieje.png`, `BRIDAS_rueda.png`, `F1_soporte_motor.png` (en el BOM de la estructura). Verificación: `../memoria_11_traccion_trasera.m`, `../memoria_12_ruedas_brida.m` y `../memoria_06_acople_motor.m`.

| Item | Descripción | Uso | Cantidad | Fuente | Tipo |
|---|---|---|---|---|---|
| T1 | Soporte de rodamientos en U, 6061-T6 mecanizado (base 64 × 40 × 4, dos paredes de 8 mm con Ø28 H7) | Sostiene el semieje sobre el travesaño E5 (x = 30 a 70, y = −2 a −66) | 2 | Propia | Plano T1 |
| T2 | Semieje, AISI 1045, Ø12 h6 × 112, rosca M12 × 1.25 | Une el acople con la brida; gira en dos rodamientos | 2 | Propia | Plano T2 |
| T3 | Brida trasera, 6061-T6: disco Ø56 × 6, centrador Ø25 g6 × 10, agujero Ø12 H7 con chavetero 4 × 1.8 | Une el semieje con el núcleo de la rueda (4 × M4); reemplaza el cubo | 2 | Propia | Plano BRIDAS_rueda |
| M1 | Motorreductor E-S Motor 42PG-775-67, 24 V, con encoder de fábrica; 147.5 mm desde la punta del eje; 0.9 kg | Tracción y odometría, uno por rueda | 2 | Hoja del fabricante (505); largo dado por el usuario | Comercial |
| A1 | Acople flexible de mandíbulas Ø20 × 30, agujeros 8 (con plano) y 12 mm | Eje del motor con el semieje | 2 | Pendiente de proveedor | Comercial |
| B1 | Rodamiento 6001-2RS, 12 × 28 × 8 | En las paredes de T1 | 4 | Catálogo SKF (C0 = 2.36 kN, a verificar) | Estándar |
| B2 | Anillo DIN 472 para agujero Ø28 | Retiene cada rodamiento en su pared | 4 | DIN 472 | Estándar |
| B3 | Anillo DIN 471 para eje Ø12 | Ubica el semieje en los rodamientos | 4 | DIN 471 | Estándar |
| B4 | Chaveta DIN 6885 A 4 × 4 × 16 | Semieje con la brida | 2 | DIN 6885 | Estándar |
| B5 | Tuerca M12 × 1.25 autoblocante y 4 × M4 con tuerca para la rueda | Retiene la brida (dentro del agujero Ø25 del núcleo) y une rueda-brida | 2 + 8 | Estándar | Estándar |
| B6 | Tornillo M5×10 + tuerca en T de inserción M5 | T1 a la ranura superior de E5 (y = −12 y −52) | 4 + 4 | Naylamp (ID 475 y 599) | Estándar |
| R1 | Rueda genérica Ø200 × 50, núcleo de 10 mm, agujero Ø25, 4 × M4 en PCD 40 | Referencia (capacidad supuesta suficiente) | 2 | Supuesta (usuario) | Comercial |

F1 (soporte del motor), sus tornillos M4 y M5 y las tuercas en T ya están en el BOM de la estructura.

## Cómo se mueve
1. El motorreductor está fijo a F1 por su brida (4 × M4); su eje de Ø8 con plano gira.
2. El acople flexible pasa el par al semieje T2 y absorbe la desalineación entre F1 y T1.
3. T2 gira en dos rodamientos 6001 montados en las paredes de T1, que está atornillado al travesaño E5.
4. La brida T3, unida a T2 por una chaveta, mueve la rueda por sus 4 × M4.

La carga de la rueda la toman los rodamientos, T1 y E5; el eje del motor solo recibe par.

## Verificación (caso dinámico, 110.6 N por rueda; par de 6.75 N·m)
| Elemento | Resultado | FS |
|---|---|---|
| Rodamiento exterior | 216 N frente a C0 = 2.36 kN | 10.9 |
| Semieje Ø12 (von Mises, estático) | 42.4 MPa | 7.3 |
| Chaveta 4 × 4 (aplastamiento en el cubo) | 35.2 MPa | 4.1 |
| Pared exterior de T1 | 20.7 MPa | 7 |
| Tornillo exterior de T1 (tuerca en T) | 243 N frente a 351 N | 1.44 |

El tornillo exterior de T1 es el punto más ajustado. La fatiga del semieje (eje rotativo) no está verificada.

## Pendientes
- **Encoder (resuelto, 2026-11-18):** el 42PG-775-67 con encoder de fábrica en el extremo del motor (mismos pines que el encoder anterior); se eliminan el Omron externo y su acople. Pendiente: hoja de datos del encoder (pulsos por vuelta) (la masa con encoder es 0.9 kg, dato del usuario).
- Proveedor del acople flexible y del rin con su interfaz con T3.
- Fatiga del semieje; capacidad del rodamiento 6001 según el catálogo.
