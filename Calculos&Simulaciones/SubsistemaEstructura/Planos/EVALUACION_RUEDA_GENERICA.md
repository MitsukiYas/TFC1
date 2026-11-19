# Evaluación: rueda genérica única (2026-11-18)

**Rueda supuesta (indicación del usuario):** Ø200 exterior, 50 mm de ancho, agujero central Ø25, 4 agujeros M4 a 90° en un círculo que se elige (aquí PCD 40), capacidad de carga suficiente. La rueda no tiene rodamientos: se atornilla a una brida.

## Trasera: brida con chaveta (cumple)

Cadena: motor → acople → semieje T2 en los dos 6001 de T1 → **brida de arrastre** (chaveta) → 4 × M4 → rueda.

| Pieza | Dimensiones estimadas | Material |
|---|---|---|
| Brida de arrastre trasera (reemplaza T3) | Disco Ø56 × 6; centrador Ø25 g6 × 20 que entra en el agujero de la rueda; agujero Ø12 H7 con chavetero 4 × 1.8; 4 × Ø4.5 en PCD 40 a 90°; largo total 26 | 6061-T6 |
| Chaveta | 4 × 4 × 20 (DIN 6885 A) | Acero |
| Semieje T2 (acortado) | Ø12 h6 × 103: acople 15, holgura 2, 6001 8, entre rodamientos 32, 6001 8, holgura 3, brida 26, rosca M12 × 1.25 de 9 | AISI 1045 |
| Tuerca | M12 × 1.25 autoblocante; queda dentro del agujero Ø25 de la rueda (entre caras 19, entre aristas ≈ 22) | Acero |
| Tornillos de la rueda | 4 × M4 (largo según el espesor del cubo de la rueda) con tuerca | A2-70 |
| T1 | Sin cambio | 6061-T6 |

Posición (lado izquierdo): brida en y = −69 a −75 (3 mm de la pared exterior de T1), rueda de −75 a −125 con su centro en −100. El voladizo de la rueda respecto al rodamiento exterior sigue en 38 mm, así que la memoria 11 sigue valiendo.

| Verificación | Resultado |
|---|---|
| Tornillos M4 a cortante (par de 6.75 N·m en PCD 40) | 84 N por tornillo |
| Chaveta 4 × 4 × 20, aplastamiento en la brida de aluminio | 28 MPa frente a 145 MPa |
| Semieje, rodamientos y T1 | Igual que en la memoria 11 (FS mínimo 1.44 en el tornillo de T1) |

No se verifica el aplastamiento del M4 en el cubo plástico de la rueda (supuesto: la rueda cumple).

## Delantera: acople con chumacera (el servo no alcanza)

Una sola chumacera de brida (tipo KFL) es autoalineante: no puede sostener un eje en voladizo. Hacen falta **dos KFL08**, una a cada lado del alojamiento de la mangueta. Se usa la KFL08 porque ya está en el proyecto (503: alto 13 mm, C0 = 1.6 kN, 26.4 g).

| Pieza | Dimensiones estimadas | Material |
|---|---|---|
| Chumaceras | 2 × KFL08 (Ø8), una por cara del alojamiento de 20 mm de K1 | Comercial |
| Eje de la rueda delantera (reemplaza K5) | Ø8 h6 × ≈ 70: KFL interior 13, alojamiento 20, KFL exterior 13, holgura 1, brida 26, rosca M8 de 8; plano fresado para los prisioneros de las KFL | AISI 1045 |
| Brida delantera | Igual que la trasera pero con agujero Ø8 H7 y dos prisioneros M4 en lugar de chaveta (no transmite par) | 6061-T6 |
| Tornillos de la rueda | 4 × M4 | A2-70 |

| Verificación | Resultado |
|---|---|
| KFL08 exterior / interior | 170 N / 92 N frente a C0 = 1.6 kN |
| Eje Ø8 a flexión (estático) | 60 MPa, FS 5.1 |

**El problema es el radio de frotamiento.** Del eje del pivote (en la cara exterior de la mangueta, a la altura del eje de la rueda) al plano de la rueda hay 13 (KFL) + 1 + 6 (brida) + 25 (media rueda) = 45 mm, frente a 27 mm con la rueda de 30 mm.

| Rueda delantera | Radio de frotamiento | Torque bajando 16° | FS frente a 2.35 N·m (RDS3225) |
|---|---|---|---|
| 30 mm con rodamientos propios (decisión anterior) | 0 | 1.59 N·m | 1.48 |
| 50 mm + 2 KFL08, KPI 15.1° | 18 mm | 3.00 N·m | 0.78 |
| 50 mm + 2 KFL08, KPI 24.2° | 0 | 2.27 N·m | 1.03 |

Además, como la mangueta queda 18 mm más cerca del bastidor respecto al pivote, la rueda delantera tendría que alejarse otros 18 mm (s ≈ 118 mm, vía delantera ≈ 636 mm) para que la mangueta siga pasando por fuera del brazo inferior de F2.

## Opciones para la delantera
1. Rueda genérica y chumaceras, con un servo de al menos ≈ 3.0 N·m a 6.5 V (KPI 15.1°). Hay que volver a comparar servos con el límite de 5 A del convertidor de 6.5 V.
2. Rueda genérica y chumaceras con KPI 24°: el RDS3225 alcanza sin margen (FS 1.03) y el KPI es grande (más cambio de caída al girar).
3. Mantener adelante una rueda de 30 mm con rodamientos propios (la decisión anterior), y usar la rueda genérica solo atrás.
