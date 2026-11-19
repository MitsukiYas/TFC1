# BOM del pivote delantero (2 conjuntos: izquierdo y derecho)

Planos: `PIVOTE_CONJUNTO.png`, `SERVO_DETALLE.png`, `CUBO_DELANTERO_DETALLE.png`, `K1_mangueta.png`, `K2_K7_piezas.png`, `F2_soporte_pivote.png`. Verificación: `../memoria_10_pivote_delantero.m` y `../memoria_13_servo_y_buje_delantero.m`.

| Item | Descripción | Uso | Cantidad | Fuente | Tipo |
|---|---|---|---|---|---|
| K1 | Mangueta, 6061-T6 mecanizada de placa de 20 mm | Une el pivote con la espiga de la rueda y la orienta | 2 | Propia | Plano K1 |
| K2 | Pasador inferior del pivote, AISI 1045, Ø8 h6 × 29 con cabeza Ø12 × 3 | Fijo en el brazo inferior de F2; la mangueta gira sobre él | 2 | Propia | Plano K2 |
| K3 | Eje del servo, AISI 1045, Ø8 h6 × 36 | Encajado en la mangueta, gira en el buje del brazo superior de F2 y recibe el acople | 2 | Propia | Plano K3 |
| K4 | Acople servo-eje, 6061-T6, Ø24 × 10, agujero Ø8 H7, 4 × M3 al horn | Une el horn del servo con K3 | 2 | Propia | Plano K4 |
| K5 | Espiga fija de la rueda, AISI 1045, Ø8 × 60 con resalte Ø12 × 16 y rosca M8 | Fija en la mangueta; la rueda gira sobre ella | 2 | Propia | Plano K5 |
| K6 | Cubo-brida delantero, 6061-T6: disco Ø56 × 6, centrador Ø25 g6 × 10, agujero Ø16 H7 para dos 688 | Gira con la rueda (4 × M4 al núcleo) | 2 | Propia | Plano K6 |
| K7 | Placa del servo, 6061-T6 de 3 mm, 54 × 32 con agujero Ø26 | Sostiene el cuerpo del servo sobre dos separadores | 2 | Propia | Plano K7 |
| S8 | Separador hexagonal M4 hembra-hembra × 12 + 2 × M4 | Placa K7 sobre el brazo superior de F2 | 4 | Estándar | Estándar |
| S1 | Buje de bronce SAE 660, 8 × 12 × 8 | Uno en el brazo inferior de K1 y otro en el brazo superior de F2 | 4 | 505 | Estándar |
| S2 | Arandela de empuje de bronce 8.2 × 16 × 2 | Entre K1 y cada brazo de F2 (sobre refrentados perpendiculares al eje) | 4 | Pendiente de proveedor | Estándar |
| S3 | Anillo de retención DIN 471, eje Ø8 | Retiene K2 sobre la mangueta | 2 | DIN 471 | Estándar |
| S4 | Pasador elástico ISO 8752, Ø3 × 20 | K3 con K1 y K3 con K4 | 4 | ISO 8752 | Estándar |
| S5 | Rodamiento 688-2RS, 8 × 16 × 5 | Dos por rueda, dentro del cubo-brida K6 (C0 necesaria ≥ 118 N; capacidad de catálogo a verificar) | 4 | Estándar | Estándar |
| S6 | Tuerca M8 autoblocante con arandela Ø8, y 4 × M4 con tuerca para la rueda | Extremo de la espiga y unión rueda-cubo | 2 + 8 | Estándar | Estándar |
| S7 | Tornillo M3 del acople al horn | Según la plantilla del horn | 8 | Pendiente | Pendiente |
| R1 | Servo RDS3225 (cuerpo 40 × 20 × 40.5) con horn de aluminio | Actuador de dirección; su soporte en U no se usa | 2 | Dsservo | Comercial |
| R2 | Rueda genérica Ø200 × 50, núcleo de 10 mm, agujero Ø25, 4 × M4 en PCD 40 | Rueda delantera (referencia; capacidad supuesta suficiente) | 2 | Supuesta (usuario) | Comercial |

## Cómo se mueve

1. El servo está fijo por su carcasa a la placa K7, que se apoya en dos separadores sobre el brazo superior de F2; su horn gira hacia abajo.
2. El horn está atornillado al acople K4 (4 × M3).
3. K4 hace girar el eje K3 mediante un pasador elástico Ø3.
4. K3 hace girar la mangueta K1 mediante otro pasador elástico Ø3.
5. La mangueta gira alrededor del eje del pivote inclinado 15.1°, apoyada abajo en el pasador K2 (con un buje en K1) y arriba en el buje del brazo superior de F2, donde gira K3.
6. La espiga K5 está fija en la mangueta; la rueda gira sobre ella con el cubo-brida K6 (dos 688) y la mangueta la orienta.

La carga vertical de la rueda empuja la mangueta hacia arriba y pasa al brazo superior de F2 por la arandela de empuje. El servo solo transmite par; los bujes toman las cargas radiales.

## Cambios que esto introduce en otras piezas
- **F2:** el brazo superior lleva el buje 8 × 12 × 8 en su agujero Ø12 H7; las caras de los brazos que tocan la mangueta (superior del brazo inferior e inferior del brazo superior) llevan un refrentado Ø18 de 1 mm perpendicular al eje. La carga vertical entra por el brazo superior (no por el inferior, como suponía la memoria 09) y la fuerza horizontal en cada brazo es de 142 N (no 93 N); los brazos siguen con FS > 30.
- **505:** la espiga Ø10 con dos 6000 se reemplaza por un eje Ø8 en dos KFL08 con brida (rueda genérica); mangueta como pieza mecanizada de 20 mm (antes «horquilla en C de placa de 6 mm»); el servo gira el pivote a través de K4 y K3, no acoplado directamente al pasador.

## Pendientes
- Plantilla de agujeros del horn y de la carcasa del RDS3225, y posición de la salida (10 mm de un extremo, supuesta): no están en la hoja de datos; medir el servo.
- Comprobar con el rin real que el resalte de la espiga y el cubo-brida caben junto al núcleo (y = −73 a −95) y la holgura de 2 mm entre la mangueta y el neumático.
- Capacidad de la arandela de empuje y del buje SAE 660 (presión 2.2 MPa), y carga de corte de ISO 8752 Ø3 (6.32 kN, valor supuesto).


## Por qué no dos KFL08
Una chumacera KFL lleva un rodamiento con aro exterior esférico (autoalineante): no resiste momento, por eso un eje en voladizo necesitaba dos. La alternativa adoptada (espiga fija + dos 688 dentro del cubo-brida) elimina las dos chumaceras, sus tornillos y el eje giratorio, deja la carga casi centrada entre los rodamientos (20 y 59 N) y mantiene los 27 mm del pivote al plano de la rueda. La espiga no gira, así que trabaja a flexión estática (FS 7.3).
