%% MEMORIA 06 - ACOPLE DE CADA MOTORREDUCTOR TRASERO 42PG-775-67 AL BASTIDOR
% Soporte en L mecanizada de 6061-T6: ala vertical de 4 mm (y = 20 a 24 mm, x = 20 a 86 mm, z = 20 a 70 mm)
% que recibe la brida del motor, y ala horizontal de 4 mm sobre la cara superior de los perfiles
% (y = 0 a 24 mm), atornillada con tres M5 en y = 10 mm (ranura superior), en x = 30 (larguero trasero),
% 50 (travesaño del eje) y 70 mm (larguero delantero).
clear; clc;
T   = 6.75;          % N·m, par de reacción máximo (límite de corriente, 505)
m   = 0.8;           % kg, masa del motorreductor (página del fabricante)
kd  = 2.0;           % SUPOSICIÓN (fuente 5), factor dinámico vertical
g   = 9.81;
d_cb = 0.035; n_b = 4;               % brida: 4 x M4 en Ø35 (plano del fabricante)
% 1. Tornillos M4 de la brida (cortante por el par)
F_b  = T/(n_b*d_cb/2);                % N por tornillo
At4  = 8.78;                          % mm^2, área de esfuerzo M4 (rosca gruesa, Shigley)
Sy   = 450;                           % MPa, A2-70 (ISO 3506-1), SUPOSICIÓN: tornillería de acero inoxidable
tau  = F_b/At4; FS_b = 0.577*Sy/tau;
fprintf('M4 de la brida: %.1f N por tornillo, tau = %.1f MPa, FS = %.1f\n', F_b, tau, FS_b);
% aplastamiento en la placa (agujero Ø4.5, ISO 273 serie media)
sb = F_b/(4.5*4); fprintf('Aplastamiento en la placa: %.1f MPa frente a %.0f MPa (Fty/1.65, 6061-T6 Fty = 240 MPa)\n', sb, 240/1.65);
% 2. Tuercas en T: par de reacción por distancia al borde que hace de pivote
xb = [30 50 70];                      % mm
ext = [20 86];                        % mm, extremos del ala horizontal
Fnut_adm = 684/1.95;                  % N (684 N adoptado; n_u = 1.95, como 503)
Mx = m*g*kd*0.060;                    % N·m, peso por 60 mm de voladizo del motor respecto a la placa
Fx = Mx/(0.010)/numel(xb);            % N por tuerca, brazo de 10 mm (tuerca en y = 10, borde apoyado en y = 20)
Fmax = 0;
for pv = ext
    d = abs(xb - pv); k = T*1e3/sum(d.^2); F = k*d;
    fprintf('Pivote en x = %2d mm: fuerzas por tuerca [%s] N\n', pv, num2str(F,'%.0f '));
    Fmax = max(Fmax, max(F));
end
Ftot = Fmax + Fx;
fprintf('Peso x kd: %.2f N·m -> %.0f N por tuerca. Tuerca más cargada: %.0f N frente a %.0f N admisibles, FS = %.2f\n', Mx, Fx, Ftot, Fnut_adm, Fnut_adm/Ftot);
