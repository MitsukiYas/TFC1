%% MEMORIA 12 - RUEDA GENÉRICA CON BRIDA (delantera con dos KFL08, trasera con chaveta)
% Rueda supuesta (usuario): Ø200, 50 mm de ancho, núcleo de 10 mm, agujero Ø25, 4 x M4 a 90° (PCD 40 elegido);
% capacidad de carga supuesta suficiente. La rueda se atornilla a una brida apoyada en la cara del núcleo.
% Lado izquierdo: núcleo en y = -95 a -105 (centro de la rueda en y = -100).
clear; clc;
% ---------- Delantera ----------
% Pivote (KPI 15.1°) en la cara exterior de la mangueta a la altura del eje (y = -73).
% Apilamiento: KFL08 exterior 13 (y -73 a -86), holgura 3, brida 6 (-89 a -95), medio núcleo 5 -> d = 27 mm.
R = 78.6; mu = 0.6; rc = 0.025; S = 1.3; eta = 0.9; J = 1.2e-3; dd = 10.5; Ts0 = 0.10;
d = 0.027; kpi = 15.1; N = 72.4; Np = 48.2;
e = max(d - 0.100*tand(kpi), 0);
tau = @(N) 2/3*mu*N*rc + mu*N*e + N*d*sind(kpi)*sind(35);
Tdn = (tau(N) + J*dd)*S/eta + Ts0; Tfl = (tau(Np) + J*dd)*S/eta + Ts0;
fprintf('Delantera: d = %.0f mm, e = %.1f mm; servo plano %.2f N·m, bajando %.2f N·m, FS %.2f\n', d*1e3, e*1e3, Tfl, Tdn, 2.35/Tdn);
% Eje Ø8 en dos KFL08 (centros en y = -46.5 y -79.5; separación 33); rueda a 20.5 mm de la exterior
span = 33; ov = 20.5;
Ro = R*(span + ov)/span; Ri = R*ov/span;
M = R*ov/1e3; s = 32*M/(pi*0.008^3)/1e6;
fprintf('KFL08 exterior %.0f N, interior %.0f N (C0 = 1600 N, 503); eje Ø8: %.1f MPa, FS %.1f\n', Ro, Ri, s, 310/s);
% ---------- Trasera ----------
% Brida con chaveta: disco en y = -89 a -95, centrador en el núcleo; voladizo 38 mm desde el rodamiento exterior (sin cambio).
T = 6.75; PCD = 0.040;
fprintf('Trasera: M4 en PCD 40: %.0f N por tornillo; chaveta 4 x 4 x 16 en la brida (6061-T6): %.0f MPa\n', T/(PCD/2)/4, T/0.006/(2*16));
fprintf('Semieje, rodamientos y T1: sin cambio (memoria_11)\n');
