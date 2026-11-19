%% MEMORIA 10 - PIVOTE DE LA RUEDA DELANTERA (mangueta, pasador, eje del servo, acople y espiga)
% Cadena: servo RDS3225 -> horn de 25 dientes -> acople K4 (pasador elástico Ø3) -> eje superior K3 (Ø8)
%         -> mangueta K1 -> espiga K5 (Ø10) -> rodamientos 6000 -> rueda.
% La mangueta gira sobre dos bujes 8 x 12 x 8: uno en su brazo inferior, sobre el pasador fijo K2 de F2, y
% otro en el brazo superior de F2, donde gira el eje K3 encajado a presión en la mangueta.
% Eje del pivote: KPI 15.1°, corta el suelo en el centro de la huella (e = 0).
clear; clc;
R   = 78.6;               % N, carga vertical por rueda delantera, caso dinámico (memoria_08)
T   = 2.35;               % N·m, par de bloqueo del servo a 6.5 V (cota superior del par transmitido)
kpi = 15.1; zg = -59; yw = -100;
yax = @(z) yw + (z - zg)*tand(kpi);
z_li = 175; z_ls = 210;   % mm, apoyos de la mangueta: buje del brazo inferior de K1 (sobre K2) y buje del brazo superior de F2 (sobre K3)
% 1. Reacciones en los brazos: R pasa por el eje en el suelo; respecto a un punto del eje a la altura z,
%    su brazo horizontal es (z - zg)*tan(KPI). El par se reparte en dos fuerzas horizontales.
M   = R*(z_li - zg)*tand(kpi)/1e3;    % N·m, respecto al apoyo inferior
Fh  = M/((z_ls - z_li)/1e3);           % N en cada apoyo (par de fuerzas)
fprintf('Momento en el pivote: %.2f N·m -> fuerza horizontal en cada brazo: %.0f N\n', M, Fh);
% 2. Bujes 8 x 12 x 8 (presión proyectada)
p = Fh/(8*8); fprintf('Presión en los bujes: %.2f MPa\n', p);
% 3. Pasador K2 y eje K3, Ø8, AISI 1045: flexión con el brazo de palanca de la holgura + medio brazo de la mangueta
Sy = 310;                             % MPa, AISI 1045 laminado en caliente (Shigley)
a  = (4 + 5)/1e3;                     % m, holgura de 4 mm + medio brazo de 10 mm
s_b = 32*Fh*a/(pi*0.008^3)/1e6;
fprintf('Flexión en el pasador y el eje Ø8: %.1f MPa, FS = %.1f\n', s_b, Sy/s_b);
% 4. Torsión del eje K3 con el agujero Ø3 del pasador elástico (Kt = 2, SUPOSICIÓN conservadora)
tau = 16*T/(pi*0.008^3)/1e6; Kt = 2;
fprintf('Torsión en K3: %.1f MPa (x%.0f por el agujero = %.1f MPa), FS = %.1f\n', tau, Kt, Kt*tau, 0.577*Sy/(Kt*tau));
% 5. Pasador elástico Ø3 (ISO 8752) en cortante doble
F_p = T/0.004;                         % N, fuerza en el pasador a radio 4 mm
F_iso = 6320;                          % N, carga mínima de cortante doble de ISO 8752 Ø3 (SUPOSICIÓN: verificar en la norma)
fprintf('Pasador elástico Ø3: %.0f N frente a %.0f N, FS = %.1f\n', F_p, F_iso, F_iso/F_p);
% 6. Arandela de empuje en el brazo superior (la rueda empuja la mangueta hacia arriba)
A_ar = pi/4*(16^2 - 8.4^2);
fprintf('Empuje axial %.0f N sobre la arandela: %.2f MPa\n', R*cosd(kpi), R*cosd(kpi)/A_ar);
% 7. Mangueta K1: montante de 20 (x) x 10 (y) mm, 6061-T6
Fadm = 240/1.65;
Mk = R*((z_li - zg)*tand(kpi) + 0)/1e3;      % N·m, momento máximo en el montante (a la altura del brazo inferior)
s_k = Mk*1e3/(20*10^2/6);
fprintf('Montante de la mangueta: M = %.2f N·m, %.1f MPa, FS = %.1f\n', Mk, s_k, Fadm/s_k);
% 8. Espiga K5 Ø10 (verificada en 505: FS 9.3); asiento en la mangueta de 20 mm
M_e = R*0.028;                               % N·m, rueda a 28 mm del asiento (aprox.)
p_e = 6*M_e*1e3/(10*20^2);                   % MPa, presión máxima del par en el asiento (distribución lineal)
fprintf('Asiento de la espiga: presión máxima %.1f MPa\n', p_e);
fprintf('Par requerido al servo (505, opción G): 1.59 N·m bajando; bloqueo 2.35 N·m\n');
