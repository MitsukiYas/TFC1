%% MEMORIA 01 - Geometría del paralelogramo y del acoplador
% Subsistema de elevación. Calcula el rango angular, las alturas alcanzadas,
% el voladizo frontal, las holguras y el ancho interior del acoplador.
clear; clc;
run('parametros_elevacion.m');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c))+1};

fprintf('=== MEMORIA 01: GEOMETRÍA ===\n\n');

%% 1. Calibración del modelo de altura con el CAD
% H(theta) = H_base + (A - A0) + L*sin(theta)
H_base = P.H15_0 - P.L0*sind(15);
H_chk  = H_base + P.L0*sind(65);
fprintf('1. Calibración\n');
fprintf('   H_base (theta = 0, A = A0)         = %8.1f mm\n', H_base);
fprintf('   Verificación H(65°) modelo / CAD   = %8.1f / %.1f mm\n', H_chk, P.H65_0);
fprintf('\n');

%% 2. Rango angular y alturas con L y A de diseño
th_choque = P.th_choque;              % medido en el CAD
th_max    = P.th_max;
e_choque  = P.A*cosd(th_choque);      % separación perpendicular entre brazos en el choque
H = @(th) H_base + (P.A - P.A0) + P.L*sind(th);
fprintf('2. Rango con L = %d mm, A = %d mm\n', P.L, P.A);
fprintf('   Ángulo de choque                   = %8.2f°\n', th_choque);
fprintf('   Separación en el choque A·cos      = %8.1f mm\n', e_choque);
fprintf('   Ángulo máximo de operación         = %8.2f° (holgura %.2f°)\n', th_max, P.holgura);
fprintf('   Altura de cúpula mínima (%2d°)      = %8.1f mm\n', P.th_min, H(P.th_min));
fprintf('   Altura de cúpula máxima            = %8.1f mm  (req. %d mm) -> %s\n', ...
        H(th_max), P.H_req, ok(H(th_max) >= P.H_req));
fprintf('   Recorrido vertical                 = %8.1f mm\n', H(th_max) - H(P.th_min));
vol = P.L*cosd(P.th_min) + P.x_bloque - P.x_pivote_frente;
fprintf('   Voladizo frontal del bloque (%2d°)  = %8.1f mm\n', P.th_min, vol);
fprintf('   Largo de corte de cada tubo        = %8.1f mm\n\n', P.L + 2*P.voladizo_brazo);

%% 3. Holgura entre el extremo del tubo y el alma de la U
% Esquina superior del tubo que sobresale del pivote superior del acoplador:
% z(th) = v*sin(th) + (h/2)*cos(th), máximo = sqrt(v^2 + (h/2)^2)
v = P.voladizo_brazo; hh = P.tubo_h/2;
z_max = sqrt(v^2 + hh^2);
holg_alma = P.U.z_piv_sup - P.U.t - z_max;
fprintf('3. Holgura extremo de tubo - cara inferior del alma\n');
fprintf('   Altura máx. de la esquina del tubo = %8.1f mm (en theta = %.1f°)\n', z_max, atand(v/hh));
fprintf('   Holgura mínima                     = %8.1f mm -> %s\n\n', holg_alma, ok(holg_alma > 0));

%% 4. Holgura cartela superior - brazo superior en theta máximo
gap_brazos = P.A*cosd(th_max) - P.tubo_h;
% SUPOSICIÓN: arandela de 1.0 mm y cabeza cilíndrica M5 de 5 mm (ISO 4762), valores nominales tomados de memoria.
apil_cartela = P.cart.t + 1.0 + 5.0;   % placa + arandela DIN 125 A 5.3 + cabeza M5 (ISO 4762, k = 5)
fprintf('4. Holgura entre brazos en theta máx.\n');
fprintf('   Luz entre tubos superior e inferior = %7.1f mm\n', gap_brazos);
fprintf('   Altura sobre el tubo (cartela+arandela+cabeza) = %.1f mm\n', apil_cartela);
fprintf('   Holgura restante                   = %8.1f mm -> %s\n\n', gap_brazos - apil_cartela, ok(gap_brazos - apil_cartela > 0));

%% 5. Ancho interior del acoplador
n = P.nodo;
w_apil = 2*(n.t_arandela + n.t_tuerca + P.tubo_b + n.t_KFL) + n.g;
x_viga_ext = P.viga_ancho/2 + P.blk.y_cm;           % borde de la viga más alejado del centro
x_agujero  = P.blk.y_cm + 10 + P.M5.agujero/2;      % borde del agujero M5 más alejado (ranuras a +/-10 mm del eje de la viga)
w_viga   = 2*(x_viga_ext + P.U.R);                  % viga sobre la parte plana del alma
% SUPOSICIÓN: distancia mínima agujero-doblez = t + R desde el inicio del doblez (regla práctica de plegado, sin norma citada).
w_agujero = 2*(x_agujero + P.U.t + P.U.R + P.U.R);  % agujero a >= t+R del inicio del doblez
w_c = P.U.w - 2*(n.t_arandela + n.t_tuerca + P.tubo_b/2);
fprintf('5. Ancho interior del acoplador\n');
fprintf('   Mínimo por apoyo de la 2040        = %8.1f mm\n', w_viga);
fprintf('   Mínimo por distancia agujero-doblez= %8.1f mm\n', w_agujero);
fprintf('   Mínimo por apilamiento del nodo    = %8.1f mm (g = %.1f mm: 2 resortes + holguras)\n', w_apil, n.g);
fprintf('   Ancho adoptado w                   = %8.1f mm -> %s\n', P.U.w, ok(P.U.w >= max([w_viga w_agujero w_apil])));
fprintf('   Distancia entre planos medios w_c  = %8.1f mm\n', w_c);
fprintf('   Largo del travesaño                = %8.1f mm\n\n', P.U.w - 2*(n.t_arandela + n.t_tuerca + P.tubo_b) - 2*P.trav.holgura);

%% 5b. Resorte respecto al plano de la base
fprintf('5b. Resorte: radio exterior + 3 mm = %.1f mm (distancia mínima esperada al plano del motor: %d mm) -> %s\n\n', ...
        P.res.OD/2 + 3, P.res.dist_base_min, ok(P.res.OD/2 + 3 <= P.res.dist_base_min));

%% 6. Dimensiones de la pieza en U
L_ala = P.U.z_piv_sup + P.A + P.U.z_bajo_inf;
fprintf('6. Pieza en U\n');
fprintf('   Radio interior mínimo (N = %d)      = %8.1f mm\n', P.Al5052.N_doblado, P.U.R);
fprintf('   Largo del ala (desde cara sup. alma)= %7.1f mm\n', L_ala);
fprintf('   Alma: %d x %.0f mm (interior), alas: %.0f mm de ancho, t = %.0f mm\n', P.U.w, P.U.Lx, P.U.Lx, P.U.t);
% SUPOSICIÓN: masa calculada como chapa plana desarrollada, sin descontar agujeros ni corregir por los radios de doblado.
m_U = ((P.U.w + 2*P.U.t)*P.U.Lx + 2*(L_ala - P.U.t)*P.U.Lx)*P.U.t*1e-9*P.Al5052.rho;
fprintf('   Masa aproximada (sin agujeros)     = %8.3f kg\n', m_U);
