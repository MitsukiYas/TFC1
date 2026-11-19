%% MEMORIA 13 - MONTAJE DEL SERVO Y BUJE COMPACTO DE LA RUEDA DELANTERA
% (a) Rueda delantera: espiga FIJA Ø8 en la mangueta y cubo-brida que gira sobre dos rodamientos 688-2RS
%     (8 x 16 x 5) alojados dentro del centrador Ø25 de la brida. Reemplaza las dos KFL08 y el eje giratorio.
% (b) Servo: cuerpo fijo a una placa (K7) sobre dos separadores desde el brazo superior de F2;
%     el horn mueve el acople K4 sobre el eje K3. El soporte en U del fabricante gira con la salida y no se usa.
clear; clc;
R = 78.6;                         % N, carga vertical por rueda delantera, caso dinámico (memoria_08)
% ---------- (a) cubo con dos 688 ----------
% Lado izquierdo: cara exterior de la mangueta y = -73; brida en y = -89 a -95; centrador y = -95 a -105.
% Rodamientos: y = -90 a -95 (centro -92.5) y y = -100 a -105 (centro -102.5); rueda en y = -100.
y1 = -92.5; y2 = -102.5; yw = -100;
R2 = R*(y1 - yw)/(y1 - y2); R1 = R - R2;
fprintf('688 interior: %.0f N, exterior: %.0f N\n', R1, R2);
% Capacidad estática necesaria con s0 = 2 (sin dato de catálogo: se deja como requisito)
fprintf('C0 mínima del 688 para s0 = 2: %.0f N\n', 2*max(R1, R2));
% Espiga fija Ø8 (AISI 1045): voladizo desde la cara de la mangueta (-73) hasta la rueda (-100)
M = R*27/1e3; s = 32*M*1e3/(pi*8^3);
fprintf('Espiga fija Ø8: M = %.2f N·m, %.1f MPa, FS = %.1f (carga estática, no gira)\n', M, s, 310/s);
% Asiento de la espiga en la mangueta (20 mm): presión máxima del par
p = 6*M*1e3/(8*20^2) + R/(8*20);
fprintf('Asiento de la espiga en la mangueta: %.1f MPa (6061-T6, admisible 145 MPa)\n', p);
% Pared del centrador alrededor del 688: (25 - 16)/2 = 4.5 mm
fprintf('Pared del centrador alrededor del rodamiento: %.1f mm\n', (25 - 16)/2);
% ---------- (b) servo ----------
T = 2.35;                         % N·m, bloqueo a 6.5 V
r_h = 0.007;                      % m, SUPOSICIÓN: radio de los agujeros del horn (plantilla no publicada)
fprintf('Tornillos M3 horn-K4 (4): %.0f N cada uno\n', T/r_h/4);
% Placa del servo K7 sobre dos separadores M4 de F2: el par de reacción del servo como par de fuerzas
d_sep = 0.034;                    % m, separación entre separadores (a cada lado del eje, ver plano)
Fsep = T/d_sep;
fprintf('Separadores: %.0f N de cortante cada uno por el par de reacción\n', Fsep);
