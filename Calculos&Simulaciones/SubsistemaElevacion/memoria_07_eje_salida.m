%% MEMORIA 07 - Eje escalonado de salida del reductor (opción A)
% Eje corto que conecta el eje hueco Ø18 del reductor NMRVS40-G50-D14 con la
% brida comercial de Ø14 atornillada a la cara lateral del brazo accionado.
%
%   [brazo]|brida Ø14 (25 mm)| collarín Ø22 |== Ø18 dentro del eje hueco (78 mm) ==| anillo DIN 471
%
% Fuentes:
%   - Plano StepperOnline NMRVS40-G50-D14: eje hueco Ø18, largo 78 mm,
%     chavetero 6 mm, d + t2 = 20.8 mm; par máximo permisible 38 N·m (ficha).
%   - Medición CAD del usuario: extremo del eje hueco Ø31 mm; chavetero de salida 6.00 mm, 3.315 mm desde el
%     borde del agujero (=> t2 = 2.8 mm, ver sección 1).
%   - Plano de la brida (usuario): agujero Ø14, chavetero 5 mm, cubo Ø24,
%     largo total 25 mm, ala Ø36, 4 agujeros Ø3 en círculo de Ø30.
%   - Shigley (ed. en español): Ec. (6-10) S'e, Ec. (6-18) y Tabla 6-2 ka,
%     Ec. (6-19) kb, Tabla 7-1 Kt/Kts, Ec. (7-6) y (7-7) ED-Goodman,
%     Ec. (7-15) y (7-16) fluencia, Ejemplo 7-6 (corte y aplastamiento de cuñas),
%     Ec. (5-21) Ssy = 0.577 Sy.
%   - Ficha técnica AISI 4140 bonificado (Europer): Ø > 16 <= 40 mm,
%     Rp0.2 >= 750 MPa, Rm 1000-1200 MPa (valores informativos; solo la dureza
%     260-300 HB es garantizada).
%   - Ficha técnica SAE 1045 (Europer): Rm 640 MPa, Rp0.2 340 MPa (chavetas).
%   - ISO 3506-1 (A2-70), ADM 2005 3.4.5 y 5.1.1 (tornillos de la brida y pared del tubo).
% Requiere cargas_elevacion.mat (memorias 02 y 05).
clear; clc;
run('parametros_elevacion.m');
load('cargas_elevacion.mat');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 07: EJE ESCALONADO DE SALIDA DEL REDUCTOR ===\n\n');

%% 0. Datos PENDIENTES DE CONFIRMAR (valores provisionales, marcados con [P])
r_fil_c  = 0.5;    % mm, radio de filete a cada lado del collarín
% SUPOSICIÓN: cara plana de 1 mm y filetes de 0.5 mm como mínimo geométrico del collarín (valores propios).
c_plano  = 1.0;    % mm, cara plana mínima del collarín (apoyo sobre el cubo del reductor)
c_coll   = 2*r_fil_c + c_plano;   % mm, ancho mínimo del collarín (ver sección 7)
% Juego axial de 2 mm entre collarín y brida (medido en el ensamble por el usuario).
g_ax     = 2.0;    % mm, juego axial entre collarín y cubo de la brida (la brida desliza sobre el Ø14)
t_ala_br = 3;      % mm, espesor del ala de la brida (usuario)
h_br_med = 3.46;   % mm, chavetero 5 mm de la brida medido desde la arista (usuario)
t2_5     = h_br_med - (7 - sqrt(7^2 - 2.5^2));   % mm, profundidad en el cubo desde la generatriz
t1_5     = 2.2;    % mm, profundidad del chavetero 5 mm en el eje, adaptada a la brida (5 - t2_5 + 0.2 de juego)
% SUPOSICIÓN: la brida comercial de AISI 303 está en condición recocida (Sy = 225 MPa); el proveedor no informa la condición.
Sy_303   = P.sep.Sy;   % MPa, AISI 303 (brida)
t1_6     = 3.5;    % mm, profundidad del chavetero 6 mm en el eje (DIN 6885-1, extracto: t4 = 3.5 para d 17-22)
% DIN 6885-1 (extracto): d = 14 -> b = 5, cubo t2 = 2.3, eje t4 = 3.0. La brida medida tiene t2 = 3.0
% (no estándar), por eso el chavetero del eje se reduce a 2.2 mm. Ancho: eje N9 / cubo JS9 (ajuste normal).
% DIN 471 (catálogo): d1 = 18 -> s = 1.2, ranura d2 = 17, m = 1.3, n_min = 1.5.
% SUPOSICIÓN: juego axial de 0.2 mm entre el anillo DIN 471 y el extremo del eje hueco (valor propio).
m471 = 1.3; n471 = 1.5; j471 = 0.2;   % mm, ancho de ranura, borde mínimo, juego axial anillo-cubo
r_fil    = 0.5;    % mm, radio de los filetes del collarín (propuesto; exige chaflán >= 0.5 en los agujeros)
% SUPOSICIÓN: largos de chaveta de 20 y 40 mm elegidos sin la tabla de largos normalizados de DIN 6885-1.
l_ch14   = 20;     % mm, chaveta A 5x5x20 (extremos redondeados)
l_ch18   = 40;     % mm, chaveta A 6x6x40 (extremos redondeados)

%% 1. Comprobación del chavetero de salida medido
d18 = 18; b6 = 6;
y_borde = sqrt((d18/2)^2 - (b6/2)^2);     % mm, altura del borde del agujero en la arista del chavetero
t2_med  = 3.315 - (d18/2 - y_borde);      % mm, profundidad del chavetero en el cubo desde la generatriz
fprintf('1. Chavetero del eje hueco\n');
fprintf('   3.315 mm medidos desde la arista -> t2 = %.2f mm; d + t2 = %.2f mm (plano: 20.8 mm)\n', t2_med, d18 + t2_med);
fprintf('   -> Chaveta 6x6 (h = 6 mm) para Ø18; altura de contacto en el cubo h - t1 = %.1f mm\n\n', 6 - t1_6);

%% 2. Cargas
S      = 1.30;                       % mismo factor de par que la memoria 06
T_op   = S*Tmax;                     % N·m, par de operación con S
% SUPOSICIÓN: la sobrecarga de diseño es el par máximo permisible del reductor (criterio propio: la unión no es más débil que el reductor).
T_red  = 38;                         % N·m, par máximo permisible del reductor (sobrecarga de diseño)
% SUPOSICIÓN: toda la reacción radial de la base pasa por el eje y actúa en la cara de la brida apoyada en el tubo (conservador).
R_rad  = R_base;                     % N, radial por lado en la base (caso conservador: todo pasa por el eje)
% Par que el motor puede imponer si el brazo se traba (retención a 3 A x i x eta_d de referencia)
% SUPOSICIÓN: par de traba con retención proporcional a la corriente y eficiencias de referencia Motovario.
T_ret = 4.8*3.0/6.0; i_red = 50; eta_d = 0.63;
T_tranca = T_ret*i_red*eta_d;
% Brazos de palanca de la fuerza radial (aplicada en la cara de la brida apoyada en el tubo)
L_br   = 25;                                   % mm, largo total de la brida
% Medición en el ensamble (usuario): el extremo del eje hueco queda a 3.0 mm de la cara de los agujeros M6, a ras de la
% cara del centrador Ø60h8 (altura 3.0 mm), y a 29.0 mm de la cara de la brida apoyada en el tubo.
% La sección crítica Ø18 está en la entrada del eje hueco.
a18    = 29.0;                                 % mm, de la cara de la brida apoyada en el tubo a la entrada del eje hueco (medido)
a14    = a18 - c_coll;                         % mm, de esa cara al hombro Ø14/Ø22 (el collarín apoya en el eje hueco)
M14 = R_rad*a14/1000;  M18 = R_rad*a18/1000;   % N·m
fprintf('2. Cargas\n');
fprintf('   T_out = %.2f N·m -> T_op = S·T_out = %.2f N·m\n', Tmax, T_op);
fprintf('   Sobrecarga de diseño = par permisible del reductor = %.1f N·m\n', T_red);
fprintf('   Radial (reacción de la base por lado) = %.1f N\n', R_rad);
fprintf('   Momento en el hombro Ø14: %.2f N·m (a = %.1f mm); en la entrada Ø18: %.2f N·m (a = %.1f mm)\n', M14, a14, M18, a18);
fprintf('   Par de traba del motor (%.1f N·m x %d x %.2f) = %.1f N·m > %.0f N·m del reductor\n', T_ret, i_red, eta_d, T_tranca, T_red);
T_tranca_s = T_ret*i_red*0.36;
fprintf('   (con eficiencia estática 0.36: %.1f N·m). Protección adoptada: límites por software con la IMU del brazo\n', T_tranca_s);
fprintf('   y detección de atasco por comparación entre pasos comandados y ángulo medido.\n\n');

%% 3. Material del eje: AISI 4140 bonificado (Ø barra > 16 <= 40)
% SUPOSICIÓN: propiedades informativas de la ficha (solo la dureza es garantizada); Sut = mínimo del rango 1000-1200 MPa.
Sy = 750; Sut = 1000;
Se_p = 0.5*Sut;                               % Shigley Ec. (6-10)
ka   = 3.04*Sut^(-0.217);                     % Ec. (6-18), Tabla 6-2, maquinado
fprintf('3. Material: AISI 4140 bonificado, Sy = %d MPa, Sut = %d MPa\n', Sy, Sut);
fprintf('   S''e = %.0f MPa, ka = %.3f\n\n', Se_p, ka);

%% 4. Secciones críticas: ED-Goodman (fatiga) y Von Mises máximo (fluencia)
% Kf = Kt (q = 1, conservador). Tabla 7-1: filete agudo (r/d = 0.02) Kt 2.7 / Kts 2.2;
% cuñero fresado Kt 2.14 / Kts 3.0. Se combinan los peores valores en la misma sección.
% Flexión: completamente invertida (Ma = M, Mm = 0). Torsión: repetida 0 -> T (Ta = Tm = T/2).
% SUPOSICIÓN: q = 1 y los peores Kt de flexión y torsión en la misma sección (conservador). Flexión tomada como
% SUPOSICIÓN: completamente invertida aunque el eje solo oscila ~55°, y torsión repetida de 0 a T (conservador).
Kf = 2.7; Kfs = 3.0;
sec = struct('nom', {'Ø14 (hombro + cuñero)', 'Ø18 (entrada eje hueco)'}, 'd', {14, 18}, 'M', {M14, M18});
fprintf('4. Eje (Kf = %.2f, Kfs = %.2f; r/d real = %.3f >= 0.02 de la Tabla 7-1)\n', Kf, Kfs, r_fil/14);
fprintf('%-26s %6s %8s %10s %10s %10s\n', 'Sección', 'kb', 'Se', 'n fatiga', 'ny (T_op)', 'ny (38)');
n_min = inf;
for k = 1:2
  d  = sec(k).d; M = sec(k).M*1000;           % N·mm
  kb = 1.24*d^(-0.107);                       % Ec. (6-19)
  Se = ka*kb*Se_p;
  Ta = T_op*1000/2; Tm = Ta;
  A = sqrt(4*(Kf*M)^2 + 3*(Kfs*Ta)^2);         % Ec. (7-6)
  B = sqrt(3*(Kfs*Tm)^2);
  n_f = 1/(16/(pi*d^3)*(A/Se + B/Sut));       % Ec. (7-7)
  sv  = @(T) sqrt((32*Kf*M/(pi*d^3))^2 + 3*(16*Kfs*T*1000/(pi*d^3))^2);   % Ec. (7-15)
  ny_op = Sy/sv(T_op); ny_38 = Sy/sv(T_red); % Ec. (7-16)
  fprintf('%-26s %6.3f %8.1f %10.2f %10.2f %10.2f\n', sec(k).nom, kb, Se, n_f, ny_op, ny_38);
  n_min = min([n_min n_f ny_op ny_38]);
end
fprintf('   Criterio: n >= 1.5 en todas -> %s (mín. %.2f)\n', ok(n_min >= 1.5), n_min);
% Referencia: el mismo eje en SAE 1045 (Sy 340, Sut 640)
d = 14; M = M14*1000;
sv38 = sqrt((32*Kf*M/(pi*d^3))^2 + 3*(16*Kfs*T_red*1000/(pi*d^3))^2);
fprintf('   (En SAE 1045 la sección Ø14 daría ny(38) = %.2f: por eso se usa 4140)\n\n', 340/sv38);

%% 5. Chavetas (Shigley Ej. 7-6: corte F/(b l), aplastamiento sobre la altura de contacto)
% SUPOSICIÓN: chavetas comerciales de acero SAE 1045 (Sy = 340 MPa); el material real depende del proveedor.
% SUPOSICIÓN: Altura de contacto = h - t1, sin descontar chaflanes.
Sy_ch = 340; Ssy_ch = P.f_ssy*Sy_ch;          % SAE 1045 (acero de chavetas comercial)
ch = struct('nom', {'A 5x5x20 en Ø14', 'A 6x6x40 en Ø18'}, 'd', {14, 18}, 'b', {5, 6}, 'h', {5, 6}, ...
            't1', {t1_5, t1_6}, 'l', {l_ch14, l_ch18});
fprintf('5. Chavetas (acero SAE 1045, Ssy = %.0f MPa; l_ef = l - b por extremos redondeados)\n', Ssy_ch);
for k = 1:2
  l_ef = ch(k).l - ch(k).b;
  for T = [T_op T_red]
    F   = 2*T*1000/ch(k).d;                    % N
    tau = F/(ch(k).b*l_ef);
    sc  = F/((ch(k).h - ch(k).t1)*l_ef);       % cubo (altura de contacto menor)
    fprintf('   %-18s T = %5.1f N·m: F = %5.0f N, corte %5.1f MPa (n = %.2f), aplast. cubo %5.1f MPa (n chaveta = %.2f)\n', ...
            ch(k).nom, T, F, tau, Ssy_ch/tau, sc, Sy_ch/sc);
  end
end
F14 = 2*T_red*1000/14; sc14 = F14/((5 - t1_5)*(l_ch14 - 5));
fprintf('   Brida AISI 303 (Sy = %.0f MPa): chavetero t2 = %.2f mm (d + t2 = %.2f), eje t1 = %.1f mm\n', Sy_303, t2_5, 14 + t2_5, t1_5);
fprintf('   Aplastamiento en el cubo de la brida a %.0f N·m: %.1f MPa -> n = %.2f %s (>= 1.5)\n', T_red, sc14, Sy_303/sc14, ok(Sy_303/sc14 >= 1.5));
sc14_eje = F14/(t1_5*(l_ch14 - 5));
fprintf('   Aplastamiento en el eje (4140) a %.0f N·m: %.1f MPa -> n = %.2f\n', T_red, sc14_eje, Sy/sc14_eje);
% Torsión del cubo de la brida (Ø24 x Ø14), sin descontar el chavetero en el cálculo y con Kts = 3.0
Do = 24; Di = 14;
tau_cubo = 3.0*16*T_red*1000*Do/(pi*(Do^4 - Di^4));
fprintf('   Torsión del cubo de la brida (Kts = 3.0): %.1f MPa -> n = %.2f (Ssy = 0.577 Sy)\n\n', tau_cubo, P.f_ssy*Sy_303/tau_cubo);

%% 6. Tornillos de la brida (4 x M3 en Ø30, girados 45° respecto al eje del brazo)
% SUPOSICIÓN: los 4 tornillos M3 reparten el par por igual, con la rosca en el plano de corte y sin contar la fricción;
% SUPOSICIÓN: la brida está centrada en la cara de 31.75 mm con los agujeros a 45°.
r_t = 15; n_t = 4; D3 = 3; p3 = 0.5;
As3 = pi/4*(D3 - 0.9382*p3)^2;                % ISO 3506-1 Anexo A
tau_adm = P.f_ssy*P.A270.Rp02/P.ny;
e_borde = P.tubo_h/2 - r_t*sind(45);          % mm, centro del agujero al borde de la cara del tubo
k_b = min(1, e_borde/(2*D3));
Cap_v  = tau_adm*As3;
Cap_ap = k_b*2*P.Al6061.Ftu/P.nu*D3*P.tubo_t; % ADM 3.4.5, solo la pared del lado de la brida
fprintf('6. Tornillos M3 A2-70 de la brida y pared del brazo (t = %.1f mm)\n', P.tubo_t);
fprintf('   Borde: %.2f mm = %.2f D (ADM 5.1.1: >= 1.5D %s; < 2D reduce el aplastamiento, k = %.2f)\n', ...
        e_borde, e_borde/D3, ok(e_borde >= 1.5*D3), k_b);
for T = [T_op T_red]
  F = T*1000/(n_t*r_t);
  fprintf('   T = %5.1f N·m: F = %4.0f N/tornillo; corte (cap. %3.0f N) n = %.2f %s; aplast. pared (cap. %4.0f N) n = %.2f %s\n', ...
          T, F, Cap_v, Cap_v/F, ok(Cap_v >= F), Cap_ap, Cap_ap/F, ok(Cap_ap >= F));
end
F38 = T_red*1000/(n_t*r_t);
fprintf('   Aplastamiento del ala de la brida (303, t = %.0f mm) a %.0f N·m: %.1f MPa -> n = %.2f\n', t_ala_br, T_red, F38/(D3*t_ala_br), Sy_303/(F38/(D3*t_ala_br)));
fprintf('   Tuercas M3 en la cara interna del brazo: solo trabaja la pared del lado de la brida.\n');
fprintf('   (Fuerza por tornillo con el par de traba %.1f N·m: %.0f N, supera la capacidad al corte)\n\n', T_tranca, T_tranca*1000/(n_t*r_t));

%% 7. Ancho mínimo del collarín
% Fuerza axial que debe tomar el hombro: viento lateral sobre el bloque + componente lateral del peso
% SUPOSICIÓN: fuerza axial = solo el viento lateral sobre el bloque; el resto del viento lateral lo toman los nodos, no el collarín.
F_ax = 5.96 + 0;    % N (pendiente lateral mínima según el usuario; viento lateral de la memoria 02)
A_ap = pi/4*(22^2 - 18.5^2);                  % mm^2, corona de apoyo (descontando chaflán del eje hueco)
fprintf('7. Collarín: ancho mínimo\n');
fprintf('   Resistencia: F_ax = %.1f N sobre %.0f mm^2 -> %.3f MPa (no gobierna)\n', F_ax, A_ap, F_ax/A_ap);
fprintf('   Geometría: 2 filetes r = %.1f + cara plana %.1f -> c = %.1f mm\n', r_fil_c, c_plano, c_coll);
fprintf('   Juego axial brida-collarín g = %.1f mm -> separación cubo reductor-brida = %.1f mm\n', g_ax, c_coll + g_ax);
fprintf('   Holgura del cubo de la brida (gira) a la cara del centrador (fija) = %.1f mm\n\n', c_coll + g_ax);

%% 8. Resumen de geometría propuesta
L_tot = (L_br - 1 + g_ax) + c_coll + 78 + j471 + m471 + n471;
fprintf('8. Geometría propuesta (largo total aprox. %.1f mm)\n', L_tot);
fprintf('   Ø14 h6 x %.0f mm (termina 1 mm antes de la cara del ala), chavetero 5 N9 x %.1f, largo 20 (fresado)\n', L_br - 1 + g_ax, t1_5);
fprintf('   Collarín Ø22 x %.1f mm, filetes r = %.1f a ambos lados (Ø22 < Ø31 del extremo del eje hueco)\n', c_coll, r_fil);
fprintf('   Ø18 h6 x %.1f mm; ranura DIN 471-18: Ø17 x %.1f a %.1f mm del cubo, %.1f mm al extremo; chavetero 6 N9 x %.1f, largo 40\n', 78 + j471 + m471 + n471, m471, j471, n471, t1_6);
