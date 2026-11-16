%% MEMORIA 04 - Cartelas, tornillos pasantes, separadores y travesaño
% Marco inferior: 4 cartelas en T (5052-H32, 3 mm), 2 arriba y 2 abajo del
% travesaño, unidas con tornillos M5 A2-70 pasantes y separadores interiores.
% Requiere cargas_elevacion.mat (memoria 02).
clear; clc;
run('parametros_elevacion.m');
load('cargas_elevacion.mat');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c))+1};
fprintf('=== MEMORIA 04: CARTELAS Y TRAVESAÑO ===\n\n');

C = P.cart; Al = P.Al5052; Tb = P.Al6061; D = P.M5.d;

%% 1. Fuerza por cartela (par en el plano de las placas)
% SUPOSICIÓN: la torsión del travesaño pasa a los brazos solo como un par de fuerzas en el plano de las cartelas superior e inferior.
h_c = P.tubo_h + C.t;                     % mm, distancia entre planos medios de las cartelas
F   = T_t*1000/h_c;                       % N
fprintf('1. Torsión de diseño T_t = %.2f N·m\n', T_t);
fprintf('   Brazo del par h = %.2f mm -> fuerza por cartela F = %.1f N\n\n', h_c, F);

%% 2. Fuerzas en los tornillos (método elástico, placa rígida)
% Shigley Ec. (8-57): con miembros rígidos y tornillos iguales, la carga de momento
% de cada tornillo es proporcional a su distancia al centroide del grupo. La
% rigidez a rotación de cada unión (placa-brazo, placa-travesaño) es entonces
% proporcional a sum(r^2), y el momento F·e de la placa se reparte en esa proporción.
% SUPOSICIÓN: placa rígida y tornillos de igual rigidez (método elástico); el momento se reparte entre los dos grupos por sum(r^2).
e   = C.y_torn_trav;                      % mm, excentricidad entre grupos (eje del brazo a fila del travesaño)
M_p = F*e;                                % N·mm, momento en el plano
s_a = diff(C.u_torn_brazo);               % mm
s_t = 2*C.du_torn_trav;                   % mm
J_a = 2*(s_a/2)^2; J_t = 2*(s_t/2)^2;     % mm^2 (momento polar de cada grupo, por unidad de área)
f_a = J_a/(J_a + J_t);
M_a = f_a*M_p; M_t = (1 - f_a)*M_p;
F_ba = hypot(F/2, M_a/s_a);               % N, tornillo más cargado del grupo del brazo
F_bt = hypot(F/2, M_t/s_t);               % N, tornillo más cargado del grupo del travesaño
F_b  = max(F_ba, F_bt);
fprintf('2. Tornillos (reparto del momento por rigidez: brazo %.0f %%, travesaño %.0f %%)\n', 100*f_a, 100*(1 - f_a));
fprintf('   Momento en el plano F·e = %.0f N·mm\n', M_p);
fprintf('   Tornillo del brazo     = %.1f N\n', F_ba);
fprintf('   Tornillo del travesaño = %.1f N\n', F_bt);
fprintf('   (Si el grupo del travesaño tomara todo el momento: %.1f N)\n\n', hypot(F/2, M_p/s_t));

%% 3. Corte del tornillo M5 A2-70 (ISO 3506-1 + energía de distorsión + ADM ny)
% SUPOSICIÓN: un plano de corte por tornillo, con la rosca en el plano de corte (área As); la unión no cuenta con la fricción.
tau_adm = P.f_ssy*P.A270.Rp02/P.ny;
Cap_v   = tau_adm*P.M5.As;
fprintf('3. Corte del tornillo\n');
fprintf('   As = %.2f mm^2, tau_adm = 0.577 Rp0.2/ny = %.1f MPa\n', P.M5.As, tau_adm);
fprintf('   Capacidad por plano = %.0f N -> FS = %.2f %s\n\n', Cap_v, Cap_v/F_b, ok(Cap_v >= F_b));

%% 4. Bordes y separaciones (ADM 5.1.1 y 5.2.6)
e_ala_u  = min(C.u_torn_brazo(1) - C.ala_u(1), C.ala_u(2) - C.u_torn_brazo(2));
e_ala_y  = C.ala_b/2;
e_tallo_u = C.tallo_b/2 - C.du_torn_trav;
e_tallo_y = C.tallo_y(2) - C.y_torn_trav;
e_min = min([e_ala_u e_ala_y e_tallo_u e_tallo_y]);
fprintf('4. Bordes y separaciones\n');
fprintf('   Bordes: ala %.1f/%.1f mm, tallo %.2f/%.1f mm -> mín. %.2f (>= 2D = %.0f) %s\n', ...
        e_ala_u, e_ala_y, e_tallo_u, e_tallo_y, e_min, 2*D, ok(e_min >= 2*D));
fprintf('   Separaciones: %.1f y %.1f mm (>= 2.5D = %.1f) -> %s\n\n', s_a, s_t, 2.5*D, ok(min(s_a, s_t) >= 2.5*D));
k_b = min(1, e_min/(2*D));

%% 5. Aplastamiento (ADM 3.4.5)
Cap_pl  = k_b*2*Al.Ftu/P.nu*D*C.t;        % cartela
e_trav  = C.y_torn_trav - (P.tubo_b/2 + P.trav.holgura);   % mm, tornillo al extremo del travesaño
k_trav  = min(1, e_trav/(2*D));           % ADM 5.1.1: reducción si el borde es < 2D
Cap_tub = k_trav*2*Tb.Ftu/P.nu*D*P.tubo_t;   % pared del tubo (gobierna el extremo del travesaño)
fprintf('5. Aplastamiento\n');
fprintf('   Cartela 5052-H32: capacidad %.0f N -> FS = %.2f %s\n', Cap_pl, Cap_pl/F_b, ok(Cap_pl >= F_b));
fprintf('   Pared 6061-T6:    capacidad %.0f N -> FS = %.2f %s\n', Cap_tub, Cap_tub/F_b, ok(Cap_tub >= F_b));
fprintf('   (borde al extremo del travesaño %.1f mm = %.2fD: >= 1.5D %s, factor %.2f)\n\n', e_trav, e_trav/D, ok(e_trav >= 1.5*D), k_trav);

%% 6. Cuello de la T (unión ala-tallo, en y = 12.7 mm)
M_cuello = F*(C.y_torn_trav - C.tallo_y(1)) + M_t;   % N·mm
S_cuello = C.t*C.tallo_b^2/6;
sig_c = M_cuello/S_cuello;
tau_c = F/(C.t*C.tallo_b);
F_b_adm = min(1.3*Al.Fty/P.ny, 1.42*Al.Ftu/(P.kt*P.nu));   % ADM 3.4.4
F_s_adm = Al.Fty/(sqrt(3)*P.ny);                          % ADM 3.4.20-1
fprintf('6. Cuello de la T\n');
fprintf('   sigma = %.1f MPa (adm. ADM 3.4.4 = %.1f) -> %s\n', sig_c, F_b_adm, ok(sig_c <= F_b_adm));
fprintf('   tau   = %.1f MPa (adm. ADM 3.4.20 = %.1f) -> %s\n', tau_c, F_s_adm, ok(tau_c <= F_s_adm));
% Esbeltez del cuello (ADM 3.4.17, borde comprimido libre, b = ancho del tallo; constantes Tabla 3.3-3, temple -H)
Fcy = Al.Fcy; E = Al.E;
Bbr = 1.3*Fcy*(1 + Fcy^(1/3)/13.3); Dbr = Bbr/20*sqrt(6*Bbr/E); Cbr = 2*Bbr/(3*Dbr);
bt = C.tallo_b/C.t; S1 = (Bbr - 1.3*Fcy)/(3.5*Dbr); S2 = Cbr/3.5;
if bt <= S1, Fc = 1.3*Fcy/P.ny; elseif bt < S2, Fc = (Bbr - 3.5*Dbr*bt)/P.ny; else, Fc = pi^2*E/(P.ny*(3.5*bt)^2); end
fprintf('   Compresión por flexión (ADM 3.4.17): b/t = %.2f, S1 = %.2f, S2 = %.1f -> Fc = %.1f MPa -> %s\n', bt, S1, S2, Fc, ok(sig_c <= Fc));
% Corte (ADM 3.4.20, h = ancho del tallo)
Bs = Al.Fty/sqrt(3)*(1 + (Al.Fty/sqrt(3))^(1/3)/11.8); Ds = Bs/20*sqrt(6*Bs/E); Cs = 2*Bs/(3*Ds);
S1s = (Bs - Al.Fty/sqrt(3))/(1.25*Ds);
fprintf('   Corte (ADM 3.4.20): h/t = %.2f, S1 = %.2f -> %s\n', bt, S1s, ok(bt <= S1s));
if bt > S1s, fprintf('   (h/t > S1: usar Eq. 3.4.20-2)\n'); end
fprintf('\n');
F_b_adm = min(F_b_adm, Fc);

%% 7. Sección neta del ala (ADM 3.4.1)
A_bruta = C.ala_b*C.t; A_neta = (C.ala_b - P.M5.agujero)*C.t;
s_bruta = (F/2)/A_bruta; s_neta = (F/2)/A_neta;
fprintf('7. Sección del ala\n');
fprintf('   Bruta %.1f MPa (adm. Fty/ny = %.1f), neta %.1f MPa (adm. Ftu/(kt nu) = %.1f) -> %s\n\n', ...
        s_bruta, Al.Fty/P.ny, s_neta, Al.Ftu/(P.kt*P.nu), ok(s_bruta <= Al.Fty/P.ny && s_neta <= Al.Ftu/(P.kt*P.nu)));

%% 8. Torsión del travesaño (tubo cerrado de pared delgada)
% SUPOSICIÓN: tubo cerrado de pared delgada sin descontar los agujeros de los tornillos.
A_m = (P.tubo_b - P.tubo_t)*(P.tubo_h - P.tubo_t);
tau_tr = T_t*1000/(2*A_m*P.tubo_t);
F_s_tub = Tb.Fty/(sqrt(3)*P.ny);
fprintf('8. Torsión del travesaño\n');
% Esbeltez de las paredes al corte (ADM 3.4.20; constantes Tabla 3.3-4, temple -T6)
Bs6 = Tb.Fty/sqrt(3)*(1 + (Tb.Fty/sqrt(3))^(1/3)/17.7); Ds6 = Bs6/10*sqrt(Bs6/Tb.E);
S1_6 = (Bs6 - Tb.Fty/sqrt(3))/(1.25*Ds6);
h_pared = max(P.tubo_h, P.tubo_b) - 2*P.tubo_t;
fprintf('   Esbeltez de la pared más ancha: h/t = %.2f, S1 = %.2f -> %s\n', h_pared/P.tubo_t, S1_6, ok(h_pared/P.tubo_t <= S1_6));
fprintf('   tau = T/(2 Am t) = %.1f MPa (adm. ADM 3.4.20 = %.1f) -> %s\n\n', tau_tr, F_s_tub, ok(tau_tr <= F_s_tub));

%% 9. Precarga, par de apriete, arandelas y separador
Fi = P.M5.frac_precarga*P.M5.As*P.A270.Rp02;
T_ap = P.M5.K*Fi*D/1000;
A_ar = pi/4*(P.arandela5.dext^2 - P.arandela5.dint^2);
s_ar = Fi/A_ar;
adm_ap_pl  = 2*Al.Ftu/(1.5*P.nu);         % ADM 3.4.6, apoyo plano
A_sep = pi/4*(P.sep.dext^2 - P.sep.dint^2);
s_sep = Fi/A_sep;
L_sep = P.tubo_h - 2*P.tubo_t;
fprintf('9. Precarga y montaje\n');
fprintf('   Precarga Fi = %.2f·As·Rp0.2 = %.0f N, par de apriete T = K·Fi·d = %.2f N·m\n', P.M5.frac_precarga, Fi, T_ap);
fprintf('   Presión bajo arandela DIN 125 A 5.3 = %.1f MPa (adm. %.1f) -> %s\n', s_ar, adm_ap_pl, ok(s_ar <= adm_ap_pl));
fprintf('   Separador Ø%.0f x Ø%.1f, largo %.2f mm: sigma = %.1f MPa\n', P.sep.dext, P.sep.dint, L_sep, s_sep);
n_acero = 1.5;   % factor mínimo de los elementos de acero (criterio del capítulo, Shigley)
fprintf('   Separador de AISI 303 (Sy = %.0f MPa): FS = %.2f (mínimo %.1f) %s\n', P.sep.Sy, P.sep.Sy/s_sep, n_acero, ok(P.sep.Sy/s_sep >= n_acero));
Fi_max = P.sep.Sy/n_acero*A_sep;
fprintf('   Precarga máxima admitida por el separador = %.0f N (%.2f·As·Rp0.2)\n', Fi_max, Fi_max/(P.M5.As*P.A270.Rp02));
fprintf('   Holgura entre separadores en el travesaño = %.1f mm\n', 2*C.du_torn_trav - P.sep.dext);

%% 10. Resumen
fprintf('\n=== RESUMEN ===\n');
fprintf('%-38s %8s\n', 'Verificación', 'FS');
fprintf('%-38s %8.2f\n', 'Corte tornillo M5', Cap_v/F_b);
fprintf('%-38s %8.2f\n', 'Aplastamiento cartela', Cap_pl/F_b);
fprintf('%-38s %8.2f\n', 'Aplastamiento pared tubo', Cap_tub/F_b);
fprintf('%-38s %8.2f\n', 'Flexión cuello de la T', F_b_adm/sig_c);
fprintf('%-38s %8.2f\n', 'Corte cuello de la T', F_s_adm/tau_c);
fprintf('%-38s %8.2f\n', 'Torsión travesaño', F_s_tub/tau_tr);
