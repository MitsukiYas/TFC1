%% MEMORIA 09 - SOPORTE DEL PIVOTE DELANTERO EN EL POSTE (F2)
% Pieza mecanizada de 6061-T6 fijada a la cara exterior del poste delantero (x = 480 a 500 mm):
%   alma de 6 mm (y = -6 a 0, z = -6 a 220), labio inferior bajo el larguero inferior (y = 0 a 20, z = -6 a 0),
%   brazo inferior (z = 154 a 166) con el pasador fijo Ø8 H7 y brazo superior (z = 204 a 216) con el buje Ø12 H7
%   y la base del servo, ambos de 28 x 12 mm.
% Eje del pivote: corta el suelo (z = -59) en el centro de la huella (y = -100), inclinado 15° hacia el bastidor.
% Tornillos M5 con tuerca en T en la ranura exterior del poste (z = 60, 110, 180) y del larguero inferior (z = 10).
clear; clc;
R    = 78.6;          % N, reacción vertical por rueda delantera, caso dinámico (memoria_08)
Ts   = 2.35;          % N·m, par de bloqueo del servo a 6.5 V
kpi  = 15.1; zg = -59; yw = -100;
yax  = @(z) yw + (z - zg)*tand(kpi);
z_lo = 160; z_hi = 210;
fprintf('Pivote: y = %.1f mm en el brazo inferior y %.1f mm en el superior\n', yax(z_lo), yax(z_hi));
Fadm = 240/1.65;      % MPa, 6061-T6 con n_y = 1.65 (mismo criterio que 503)
b = 28; t = 12;       % mm, sección de los brazos
% Brazo inferior: carga vertical en el pasador
L_lo = -yax(z_lo) - 6;                         % mm, desde el alma hasta el pasador
s_lo = R*L_lo/(b*t^2/6);
% Par de fuerzas horizontales entre brazos por el momento de R respecto al eje
Fh = R*(yax(z_lo) - yw)/(z_hi - z_lo);         % N
% Brazo superior: par del servo como flexión en el plano del brazo
L_hi = -yax(z_hi) - 6;
s_hi = Ts*1e3/(t*b^2/6) + Fh/(b*t);
fprintf('Brazo inferior: %.1f MPa (FS %.0f). Brazo superior: %.1f MPa (FS %.0f). Fuerza horizontal entre brazos: %.0f N\n', ...
        s_lo, Fadm/s_lo, s_hi, Fadm/s_hi, Fh);
% Alma: momento de la rueda respecto al plano del alma (y = 0) -> tracción en las tuercas,
% con pivote en el labio inferior (z = 0)
M  = R*(-yw)/1e3;                              % N·m
zb = [10 60 110 180];                          % mm
Fm = M*1e3*zb/sum(zb.^2);                      % N por tuerca
% Par del servo: el alma (28 mm) apoya en un borde del poste (20 mm) y las tuercas están en el centro: brazo 10 mm
Ft = Ts*1e3/10/numel(zb);
Fmax = max(Fm) + Ft; Fnut = 684/1.95;
fprintf('Tuercas en T: %.0f N por el momento + %.0f N por el par del servo = %.0f N frente a %.0f N, FS %.1f\n', ...
        max(Fm), Ft, Fmax, Fnut, Fnut/Fmax);
% Labio inferior: apoyo hacia arriba contra la cara inferior del larguero
s_lab = R*10/(b*6^2/6);
fprintf('Labio inferior: presión %.2f MPa, flexión %.1f MPa (FS %.0f)\n', R/(b*20), s_lab, Fadm/s_lab);
