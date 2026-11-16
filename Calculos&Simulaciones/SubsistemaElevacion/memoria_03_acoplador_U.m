%% MEMORIA 03 - Acoplador en U (5052-H32, t = 3 mm) y pasadores
% Verifica distancias a bordes y dobleces, aplastamiento de los pasadores en
% las alas, flexión del alma, tornillos de la 2040 y flexión de los pasadores.
% Requiere cargas_elevacion.mat (memoria 02).
clear; clc;
run('parametros_elevacion.m');
load('cargas_elevacion.mat');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c))+1};
fprintf('=== MEMORIA 03: ACOPLADOR EN U ===\n\n');

U = P.U; Al = P.Al5052; D8 = P.nodo.d_pasador; D5 = P.M5.d;

%% 1. Distancias a bordes y separaciones (ADM 5.1.1 y 5.2.6)
s_M5   = 12.5;                         % mm, separación de los M5 en la ranura (2 por ranura)
e_M5   = (U.Lx - s_M5)/2;              % mm, borde del alma en dirección de avance
e_pas_lat = U.Lx/2;                    % mm, borde lateral del ala en el pasador
e_pas_inf = U.z_bajo_inf;              % mm, borde inferior bajo el pasador inferior
fprintf('1. Bordes y separaciones (mín. 1.5D; sin reducción >= 2D; separación >= 2.5D)\n');
fprintf('   M5 en el alma: separación %.1f mm (>= %.1f) -> %s\n', s_M5, 2.5*D5, ok(s_M5 >= 2.5*D5));
fprintf('   M5 en el alma: borde %.2f mm (>= 2D = %.1f) -> %s\n', e_M5, 2*D5, ok(e_M5 >= 2*D5));
fprintf('   Pasador: borde lateral %.1f mm (>= 2D = %.1f) -> %s\n', e_pas_lat, 2*D8, ok(e_pas_lat >= 2*D8));
fprintf('   Pasador: borde inferior %.1f mm (>= 2D = %.1f) -> %s\n', e_pas_inf, 2*D8, ok(e_pas_inf >= 2*D8));
% Agujero a la línea de doblez (>= t + R)
d_agujero_doblez = (U.z_piv_sup - D8/2) - (U.t + U.R);
fprintf('   Agujero pasador - doblez: %.1f mm (>= t+R = %.1f) -> %s\n\n', d_agujero_doblez, U.t + U.R, ok(d_agujero_doblez >= U.t + U.R));

%% 2. Aplastamiento del pasador en el ala (ADM 3.4.6)
% SUPOSICIÓN: con la opción A el agujero del ala apoya sobre la rosca M8 del pasador; se usa el área nominal D·t
% SUPOSICIÓN: (el contacto real es sobre las crestas) y no se cuenta con la fricción del apriete perilla-tuerca.
F_ap_pas = 2*Al.Ftu/(1.5*P.nu);                  % MPa
k_borde  = min(1, min(e_pas_lat, e_pas_inf)/(2*D8));
Cap_pas  = k_borde*F_ap_pas*D8*U.t;              % N por ala
fprintf('2. Aplastamiento del pasador en el ala\n');
fprintf('   Esfuerzo admisible 2Ftu/(1.5nu)    = %.1f MPa\n', F_ap_pas);
fprintf('   Capacidad por ala                  = %.0f N\n', Cap_pas);
fprintf('   Carga radial (mayor nodo del acoplador) = %.1f N -> FS = %.1f %s\n\n', R_acop, Cap_pas/R_acop, ok(Cap_pas >= R_acop));

%% 3. Flexión del alma
% Viga simplemente apoyada entre alas (luz = w + t), carga del bloque al centro,
% más el momento de alabeo del viento lateral sobre el bloque repartido en dos.
% SUPOSICIÓN: alma como viga simplemente apoyada entre las alas con el peso del bloque concentrado al centro
% SUPOSICIÓN: (conservador: la carga real entra repartida por los 4 tornillos y los dobleces dan empotramiento parcial).
luz  = U.w + U.t;                                % mm
W_blk = P.blk.m*g;
M_roll_blk = P.blk.F_viento*(P.blk.z_eje + P.blk.h_cp);   % N·mm, respecto a la cara del alma
M_alma = W_blk*luz/4 + M_roll_blk/2;             % N·mm
S_alma = U.Lx*U.t^2/6;                           % mm^3
sig_alma = M_alma/S_alma;
F_t_adm = min(Al.Fty/P.ny, Al.Ftu/(P.kt*P.nu));  % ADM 3.4.1 / 3.4.2
fprintf('3. Flexión del alma\n');
fprintf('   Momento = %.1f N·mm, S = %.1f mm^3, sigma = %.1f MPa\n', M_alma, S_alma, sig_alma);
fprintf('   Admisible min(Fty/ny, Ftu/(kt nu)) = %.1f MPa -> FS = %.1f %s\n\n', F_t_adm, F_t_adm/sig_alma, ok(sig_alma <= F_t_adm));

%% 4. Tornillos M5 entre la 2040 y el alma (4 tornillos: 2 filas a +/-10 mm, s = 12.5 mm)
z_cp  = P.blk.z_eje + P.blk.h_cp;                               % mm sobre el alma
M_long = F_long*P.blk.z_cp_frontal + W_blk*sind(P.pendiente)*P.blk.z_cm;   % N·mm, cabeceo
M_lat  = P.blk.F_viento*z_cp;                                   % N·mm, alabeo
% SUPOSICIÓN: tracción por tornillo como suma directa de los efectos de cabeceo y alabeo, con brazos 2·s y 2·20 mm,
% SUPOSICIÓN: sin efecto de palanca (prying) ni precarga.
T_torn = M_long/(2*s_M5) + M_lat/(2*20);                        % N, suma conservadora
V_torn = hypot(F_long, P.blk.F_viento)/4;                       % N
sig_t  = T_torn/P.M5.As;
tau_v  = V_torn/P.M5.As;
sig_vm = sqrt(sig_t^2 + 3*tau_v^2);
adm_t  = P.A270.Rp02/P.ny;
fprintf('4. Tornillos de la 2040\n');
fprintf('   Tracción por tornillo = %.1f N, corte = %.1f N\n', T_torn, V_torn);
fprintf('   Esfuerzo equivalente = %.1f MPa, admisible Rp0.2/ny = %.1f MPa -> %s\n', sig_vm, adm_t, ok(sig_vm <= adm_t));
fprintf('   Tuerca T: extracción %.0f N -> FS = %.1f %s\n\n', P.tuercaT.F_extr, P.tuercaT.F_extr/T_torn, ok(P.tuercaT.F_extr >= T_torn));

%% 5. Flexión del pasador (viga entre alas con cargas en las KFL08)
% Distancia de la cara interior del ala al plano medio del rodamiento:
% SUPOSICIÓN: el nodo de la base usa el mismo brazo de palanca que el del acoplador; la base aún no está diseñada.
a = P.nodo.t_arandela + P.nodo.t_tuerca + P.tubo_b + P.nodo.t_KFL/2;   % mm
Wz = pi*D8^3/32;
% Opción A (decisión del usuario): el agujero del ala apoya sobre la rosca M8. La sección junto al ala es
% la roscada; se verifica con el diámetro equivalente al área resistente (ISO 3506-1 Anexo A, paso 1.25).
d_s8 = D8 - 0.9382*1.25;                 % mm
Wz_r = pi*d_s8^3/32;
adm_pas = P.nodo.Sy_pasador/1.5;   % criterio del texto para elementos de acero: FS >= 1.5
fprintf('5. Flexión de los pasadores (AISI 4140, Sy = %.0f MPa, criterio FS >= 1.5: adm. Sy/1.5 = %.1f MPa)\n', P.nodo.Sy_pasador, adm_pas);
fprintf('   Brazo de palanca ala-rodamiento a = %.1f mm; sección roscada d_s = %.2f mm\n', a, d_s8);
% SUPOSICIÓN: el momento R·a (máximo en el tramo rectificado entre chumaceras) se aplica también en la sección
% roscada junto al ala, como cota para un ala que empotra el pasador. Verificación estática, sin concentración
% de esfuerzos de la rosca (carga casi constante, material dúctil).
% El pivote actuado de la base es un voladizo guiado y se verifica en la memoria 08 (no aquí).
% Pivote superior de la base: lado libre con tuerca y arandela (mismo brazo a, sección roscada); lado accionado con el
% separador de 25.8 mm (decisión del usuario): de la cara interior de la placa motor (y = 125.9) al plano medio de la
% KFL08 (y = 68.0) hay 57.9 mm (STEP), sobre sección Ø8 llena (la rosca empieza dentro de la placa).
a_sep = 125.9 - (74.5 - P.nodo.t_KFL/2);   % mm
casos = {R_acop, a, Wz_r, 'acoplador (rosca)'; R_base_sup, a, Wz_r, 'base sup. libre (rosca)'; R_base_sup, a_sep, Wz, 'base sup. accionado (Ø8)'};
for k = 1:3
  [R, aa, W, nom] = casos{k, :};
  M_pas = R*aa; sg = M_pas/W;
  fprintf('   %-26s R = %5.1f N, a = %4.1f mm: M = %5.0f N·mm, %6.1f MPa (FS = %.2f) -> %s\n', nom, R, aa, M_pas, sg, P.nodo.Sy_pasador/sg, ok(sg <= adm_pas));
end

%% 6. Fijación de las KFL08 a los brazos (2 tornillos M4 A2-70 pasantes por la pared interior del tubo)
% Fuente: Naylamp, KFL08: 48 x 27 x 13 mm, agujeros Ø5 a 36.5 mm, tornillos M4.
% Tornillos M4 A2-70 (decisión del usuario, 2026-11-13: agujeros Ø5 de catálogo de la KFL08, sin agrandar),
% ISO 3506-1: Rp0.2 = 450 MPa. Tuerca dentro del tubo, alineados con el eje del brazo y centrados en el pivote.
% (El STEP muestra M5X10 + NUT M5: corregir en el CAD a M4.)
Re68 = P.A270.Rp02;
% SUPOSICIÓN: la carga radial actúa a 6.5 mm de la cara del tubo (mitad del alto de la KFL08) y la placa
% bascula sobre el borde del ala, a 48/2 mm del pivote.
d4 = 4; p4 = 0.7; As4 = pi/4*(d4 - 0.9382*p4)^2;   % M4
s_KFL = 36.5; e_ext = P.voladizo_brazo - s_KFL/2;          % mm, tornillo exterior al extremo del tubo
R = max([R_acop, R_base, R_base_sup]);
V1 = R/2;                                                   % N, corte por tornillo
T1 = R*6.5/(48/2 + s_KFL/2);                                % N, tracción por basculamiento (tornillo más alejado del borde)
Cap_v4 = P.f_ssy*Re68/P.ny*As4;
k_e = min(1, e_ext/(2*d4));
Cap_ap4 = k_e*2*P.Al6061.Ftu/P.nu*d4*P.tubo_t;
fprintf('\n6. Fijación de las KFL08 (2 x M4 A2-70, carga radial %.1f N)\n', R);
fprintf('   Corte por tornillo %.1f N (cap. %.0f N) -> FS = %.1f %s\n', V1, Cap_v4, Cap_v4/V1, ok(Cap_v4 >= V1));
fprintf('   Tracción por basculamiento %.1f N (cap. Rp0.2/ny·As = %.0f N) -> %s\n', T1, Re68/P.ny*As4, ok(Re68/P.ny*As4 >= T1));
fprintf('   Borde al extremo del tubo %.2f mm = %.2fD (>= 1.5D %s); aplastamiento pared (cap. %.0f N) -> FS = %.1f %s\n', ...
        e_ext, e_ext/d4, ok(e_ext >= 1.5*d4), Cap_ap4, Cap_ap4/V1, ok(Cap_ap4 >= V1));
