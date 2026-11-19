%% MEMORIA 11 - CONJUNTO DE TRACCIÓN TRASERA (motor, acople, semieje, soporte de rodamientos y cubo)
% Cadena: motorreductor 42PG-775-67 (en F1) -> acople flexible Ø20 (8 a 12 mm) -> semieje T2 Ø12
%         -> dos rodamientos 6001-2RS en el soporte en U T1 (sobre el travesaño E5) -> cubo T3 con chaveta -> rueda.
% Coordenadas (lado izquierdo): y negativo hacia afuera. Rodamientos en y = -22 y -62; rueda en y = -100.
clear; clc;
R  = 110.6;            % N, carga vertical por rueda trasera, caso dinámico (memoria_08)
T  = 6.75;             % N·m, par en el límite de corriente (505)
yi = -22; yo = -62; yw = -100;
a  = yi - yo; b = yo - yw;            % mm: separación entre rodamientos (40) y voladizo de la rueda (38)
% 1. Reacciones en los rodamientos (la rueda empuja el semieje hacia arriba)
Ro = R*(a + b)/a; Ri = R*b/a;
fprintf('Rodamiento exterior: %.0f N; interior: %.0f N (sentido opuesto)\n', Ro, Ri);
% 2. Semieje Ø12, AISI 1045: flexión en el rodamiento exterior y torsión
d = 12; Sy = 310;                     % MPa (Shigley, laminado en caliente)
M = R*b/1e3;                          % N·m
s = 32*M*1e3/(pi*d^3); t = 16*T*1e3/(pi*d^3);
vm = sqrt(s^2 + 3*t^2);
fprintf('Semieje: flexión %.1f MPa, torsión %.1f MPa, von Mises %.1f MPa, FS = %.1f (estático)\n', s, t, vm, Sy/vm);
% 3. Rodamientos 6001-2RS: capacidad estática
C0 = 2360;                            % N, SUPOSICIÓN: valor de catálogo SKF a verificar
fprintf('Rodamiento exterior: %.0f N frente a C0 = %.0f N, s0 = %.1f\n', Ro, C0, C0/Ro);
% 4. Chaveta 4 x 4 x 16 (DIN 6885) en el cubo
F = T/(d/2/1e3); tau_k = F/(4*16); p_k = F/(2*16);
fprintf('Chaveta: fuerza %.0f N, corte %.1f MPa, aplastamiento en el cubo %.1f MPa (6061-T6: %.0f MPa admisible)\n', F, tau_k, p_k, 240/1.65);
% 5. Fijación de T1 al travesaño E5: dos M5 en la ranura superior (y = -12 y -52).
%    La rueda levanta el lado exterior; se toman momentos respecto al tornillo interior.
yb_i = -12; yb_o = -52;   % el exterior queda entre las paredes (la pared exterior ocupa y = -58 a -66)
Fb = (Ro*abs(yo - yb_i) - Ri*abs(yi - yb_i))/abs(yb_o - yb_i);
Fn = 684/1.95;
fprintf('Tornillo exterior de T1: %.0f N frente a %.0f N, FS = %.2f\n', Fb, Fn, Fn/Fb);
% 6. Paredes de T1 (8 mm, 6061-T6): flexión de la pared exterior como voladizo de 41 mm
sw = Ro*41/(40*8^2/6);
fprintf('Pared exterior de T1: %.1f MPa, FS = %.0f\n', sw, (240/1.65)/sw);
