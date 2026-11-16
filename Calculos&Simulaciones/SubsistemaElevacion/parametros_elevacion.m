%% PARAMETROS_ELEVACION  Datos de entrada comunes a las memorias de cálculo
% del subsistema de elevación. Lo ejecutan las demás memorias con
% run('parametros_elevacion.m'). Unidades: mm, N, MPa, kg, grados (salvo indicación).
%
% Las entradas marcadas "COMPLETAR" deben reemplazarse con datos del CAD o
% de catálogo. Mientras valgan NaN, las verificaciones que dependen de ellas
% se reportan como PENDIENTES.

g = 9.81;                                   % m/s^2

%% ---------------- Geometría del paralelogramo ----------------
P.L        = 600;      % mm, distancia entre pivotes de cada brazo
P.A        = 150;      % mm, separación entre pivotes del acoplador y de la base
P.A0       = 90;       % mm, separación de la geometría medida en CAD (referencia)
P.L0       = 400;      % mm, L de la geometría medida en CAD (referencia)
P.H15_0    = 792.238;  % mm, altura de cúpula medida en CAD con L0, A0, theta = 15°
P.H65_0    = 1051.233; % mm, altura de cúpula medida en CAD con L0, A0, theta = 65°
P.th_choque = acosd(31.75/P.A);   % grados, primer contacto entre los tubos superior e inferior: A·cos(theta) = alto del tubo (77.78°, confirmado en el ensamble por el usuario)
P.th_max    = 70.31;   % grados, ángulo máximo de operación (se mantiene; cumple 1300 mm con más holgura)
P.holgura   = P.th_choque - P.th_max;   % grados, holgura antes del choque (7.47°)
P.th_min   = 15;       % grados, posición baja
P.H_req    = 1300;     % mm, Tabla de requerimientos
P.voladizo_brazo = 25; % mm, tubo más allá de cada pivote
P.x_pivote_frente = 500 - 54;  % mm, pivote actuado a cara frontal del chasis
% Viga 2040 en el CAD actual (usuario): 94 mm detrás y 87 mm delante de la línea de pivotes del acoplador.
% SUPOSICIÓN: el CM del bloque queda sobre la línea de pivotes (+/-5 mm); verificar con el CM del CAD.
P.x_bloque = 87 + 20;          % mm, línea de pivotes del acoplador a extremo frontal del bloque

%% ---------------- Brazos y travesaño (tubo rectangular 6061-T6 extruido) ----------------
P.tubo_h   = 31.75;    % mm, alto (en el plano del mecanismo)
P.tubo_b   = 25.40;    % mm, ancho (lateral)
P.tubo_t   = 2.0;      % mm, espesor de pared
P.tubo_mlin = 0.574;   % kg/m, masa lineal
% ADM 2005, Tabla 3.3-1M, 6061-T6 extrusiones
P.Al6061.Ftu = 260; P.Al6061.Fty = 240; P.Al6061.Fsu = 165; P.Al6061.E = 69600;

%% ---------------- Pieza en U (5052-H32, t = 3 mm) ----------------
% ASTM B209M-21a, Tabla 3 (espesor > 1.20 hasta 3.20 mm) / ADM Tabla 3.3-1M
P.Al5052.Ftu = 215; P.Al5052.Fty = 160; P.Al5052.N_doblado = 2; P.Al5052.rho = 2680; % kg/m^3
P.Al5052.Fcy = 145; P.Al5052.E = 70300;   % MPa, ADM Tabla 3.3-1M
P.Al6061.Fcy = 240;                        % MPa, ADM Tabla 3.3-1M (extrusiones)
P.U.t      = 3.0;      % mm
P.U.w      = NaN;      % mm, ancho interior entre alas (se calcula abajo, tras el nodo)
P.U.Lx     = 34;       % mm, largo del alma (dirección de avance) = ancho de las alas
P.U.z_piv_sup = 43;    % mm, de cara superior del alma al pivote superior (incluye t)
P.U.z_bajo_inf = 20;   % mm, material bajo el pivote inferior
P.U.R      = P.Al5052.N_doblado*P.U.t/2;   % mm, radio interior mínimo (B209M 12.1)

%% ---------------- Nodo (pasador, arandela, tuerca, KFL08) ----------------
P.nodo.d_pasador = 8;      % mm, pasador rectificado h6
% SUPOSICIÓN: espesor nominal de la arandela DIN 125 A 8.4 tomado de memoria (no localizado en el catálogo adjunto).
P.nodo.t_arandela = 1.6;   % mm, DIN 125 A 8.4
P.nodo.t_tuerca  = 5;      % mm
P.nodo.t_KFL     = 13;     % mm, KFL08 (alto total)
% SUPOSICIÓN: holgura de montaje de 3 mm entre chumaceras y resortes y entre resortes (valor propio, sin fuente).
P.nodo.holg_res  = 3;      % mm, holgura entre KFL08, resortes y entre sí (montaje)
% Resorte compensador: Lee Spring LTL135T 03 S (inoxidable 302), uno por lado en el pivote actuado
P.res.n        = 2;                       % resortes (uno por lado)
P.res.M_nom    = 40*0.933*0.112985;       % N·m, 40 in·lb (alambre musical) x 0.933 (302) [Lee Spring]
P.res.defl_nom = 270;                     % grados, deflexión a par nominal
P.res.M_alto   = 2.5;                     % N·m por resorte en la posición alta (theta máx.)
P.res.OD = 33.05; P.res.mandril = 23.81; P.res.L_cuerpo = 54.0; P.res.d = 3.43; P.res.espiras = 14.75;  % mm
% SUPOSICIÓN: resorte lineal: k = par nominal / deflexión nominal del catálogo; sin fricción ni histéresis entre espiras.
P.res.k = P.res.M_nom/deg2rad(P.res.defl_nom);   % N·m/rad por resorte
% Criterio de resistencia del resorte (decisión del usuario): par máximo del catálogo, 40 in·lb x 0.933 a 270°
% (Lee Spring, p. 298, "design torque load ... to avoid loading overstress"). Shigley Ec. 10-44/10-57 da n = 0.98
% en la posición baja; se informa, pero no gobierna.
P.res.A_pata  = 101.60;   % mm, largo de pata "A" desde el eje del cuerpo (Lee Spring, p. 298)
P.res.tol_libre = 15;     % grados, tolerancia de la posición libre, 11 a 20 espiras (Lee Spring, p. 286)
P.res.Rm = (P.res.OD - P.res.d)/2;   % mm, radio medio de la espira
% Disposición (opción 1, aceptada por el usuario): ambos resortes se cargan en el sentido que los enrolla
% (Shigley 11.ª ed., p. 519; Lee Spring, p. 285). Patas fijas hacia afuera (junto a las KFL08):
% lado libre LTL135T 03 S, lado motor LTR135T 03 S.
% Pata móvil: sale tangente por arriba de la espira (v = +Rm en ejes del brazo) y apoya sobre la varilla transversal.
% Ala de la cartela desde u = 35 mm (STEP del usuario) -> centro de la varilla en u <= 31; se adopta 28.
P.res.l_m = 28;           % mm, contacto de la pata móvil a lo largo del brazo, desde el pivote
% Pata fija: punto de tangencia en psi (ejes x-z con origen en el pivote), dirección psi + 90°.
P.res.l_f = 34;           % mm, contacto de la pata fija medido desde el punto de tangencia
% Posición axial de las patas (y lateral desde el centro del casquillo, + lado motor), del apilamiento del nodo
% SUPOSICIÓN: posiciones axiales de las patas tomadas de la vista 10 (resortes contra los extremos del casquillo).
P.res.y_pata_fija = 57; P.res.y_pata_movil = 3.7;   % mm (|y|)
P.res.dist_base_min = 20;                 % mm, distancia mínima esperada del pivote al plano del motor
% Holgura entre KFL08: dos resortes (largo de cuerpo a deflexión máx.) y tres holguras
P.res.barrido = P.th_max - P.th_min;   % grados, barrido del brazo
P.res.defl_alto = rad2deg(P.res.M_alto/P.res.k);         % grados, deflexión en la posición alta
P.res.defl_bajo = P.res.defl_alto + P.res.barrido;       % grados, deflexión en la posición baja
P.res.psi = mod(P.th_max + P.res.defl_alto, 360);        % grados, tangencia de la pata fija (enrollando)
P.res.e_psi = [cosd(P.res.psi) sind(P.res.psi)];          % radial en la tangencia
P.res.t_psi = [-sind(P.res.psi) cosd(P.res.psi)];         % dirección de la pata fija
% Varilla de anclaje Ø8 AISI 4140 entre las placas base (opción a), extremos Ø6 h6 en agujeros H7
% (ajuste de holgura de ubicación, Shigley Tabla 7-9; IT de la Tabla A-11); los escalones la fijan axialmente.
P.anc.d = 8; P.anc.d_ext = 6;
P.anc.c = P.res.Rm*P.res.e_psi + P.res.l_f*P.res.t_psi + (P.res.d/2 + P.anc.d/2)*P.res.e_psi;   % mm, centro (x, z)
P.anc.y_placa = [-110.5 128.4];   % mm, planos medios de las placas libre y motor (STEP: z = -39.4 y 199.5)
P.anc.t_placa = 5;                % mm (STEP)
% Varilla transversal Ø8 AISI 4140 (pata móvil): centro en ejes del brazo (u, v)
P.trv.d = 8;
P.trv.uv = [P.res.l_m, P.res.Rm + P.res.d/2 + P.trv.d/2];
% Soporte (decisión del usuario): pieza en L de 6061-T6 por brazo, atornillada a la cara superior del tubo con la
% unión de las cartelas (M5 A2-70 pasante + separador AISI 303 de 27.75 mm dentro del tubo). Su ala lateral baja
% por dentro del tubo (|y| 64.5 a 74.5), entre el tubo y la KFL08, y lleva un agujero ciego Ø6 H7 donde entra el
% extremo Ø6 h6 de la varilla; los escalones Ø8/Ø6 fijan la varilla axialmente entre las dos piezas.
P.sopL.u = [19 34];          % mm, sobre la cara del tubo (el ala de la cartela empieza en u = 35)
P.sopL.u_ala = [19 37];      % mm, ala lateral (agujero en u = 28: 9 mm = 1.5D a cada lado)
P.sopL.y_ala = [64.5 74.5];  % mm (|y|), ala lateral; cara interior del tubo en |y| = 74.5 (STEP)
P.sopL.prof = 8;             % mm, agujero ciego Ø6 desde la cara interior del ala
P.sopL.v_sup = P.trv.uv(2) + 1.5*6;   % mm, borde superior (1.5D sobre el agujero Ø6)
P.sopL.v_inf = P.trv.uv(2) - 1.5*6;   % mm, borde inferior del ala lateral
P.sopL.u_perno = 26.5;       % mm, M5 vertical centrado en u = 19 a 34 (7.5 = 1.5D a cada borde)
P.trv.y_apoyo = [-1 1]*(P.sopL.y_ala(1) + P.sopL.prof/2);   % mm, centro del apoyo en los agujeros ciegos
% Shigley Tabla A-11 (mm): IT6 e IT7 para 3-6 y 6-10 mm
P.IT = struct('d', [6 8], 'IT6', [0.008 0.009], 'IT7', [0.012 0.015]);
% Shigley 11.ª ed., Tabla A-5: E = 207 GPa para acero al carbono y acero al níquel.
% SUPOSICIÓN: el AISI 4140 (acero aleado Cr-Mo) se asimila a esos aceros de la Tabla A-5 (E = 207 GPa).
P.E_acero = 207e3;        % MPa
% El cuerpo se alarga ~ un diámetro de alambre por vuelta de deflexión
% SUPOSICIÓN: el cuerpo del resorte se alarga un diámetro de alambre por vuelta de deflexión (regla geométrica,
% SUPOSICIÓN: sin fuente; el usuario la acepta como suposición, 2026-11-13).
P.nodo.g = 2*(P.res.L_cuerpo + P.res.d*P.res.defl_bajo/360) + 3*P.nodo.holg_res;   % mm
% SUPOSICIÓN: Sy de la ficha del proveedor, que lo declara informativo (solo garantiza la dureza).
P.nodo.Sy_pasador = 900;  % MPa, AISI 4140 bonificado, Ø <= 16 mm (ficha técnica, valor informativo; solo la dureza es garantizada)
P.KFL.C0 = 1600; P.KFL.C = 4200;  % N, Mädler 62660800 (rodamiento; carcasa de zinc sin clasificar)

% Ancho interior del acoplador definido por el apilamiento del nodo con los resortes
P.U.w = ceil(2*(P.nodo.t_arandela + P.nodo.t_tuerca + P.tubo_b + P.nodo.t_KFL) + P.nodo.g);

%% ---------------- Subsistema de orientación (bloque sobre el alma) ----------------
P.blk.m       = 1.89;   % kg, masa total (CAD)
P.blk.z_cm    = 62.6;   % mm, CM sobre la cara inferior de la 2040 (= cara superior del alma)
P.blk.y_cm    = 10.3;   % mm, desfase lateral del CM respecto a la viga (se compensa desplazando la viga)
P.blk.z_eje   = 43;     % mm, eje basculante sobre la cara inferior de la 2040
P.blk.h_cp    = 60;     % mm, centro de presión sobre el eje basculante (sección de orientación)
P.blk.F_viento = 5.96;  % N, viento lateral sobre el bloque (sección de orientación, A = 0.012 m^2)
P.blk.A_frontal = 0.008; % m^2, área frontal del bloque (dirección de avance, CAD)
P.blk.z_cp_frontal = 68; % mm, centroide del área frontal sobre la cara inferior de la 2040 (CAD)
P.viga_ancho  = 40;     % mm, 2040
P.viga_x_atras = 95;    % mm, voladizo trasero de la 2040 respecto a la línea de pivotes
P.viga_x_adel  = 86+20; % mm, voladizo delantero (incluye caja del sin fin)
P.blk.H_cupula_sobre_viga = 136;  % mm, centro de la esfera sobre la cara inferior de la 2040
% Pata móvil de cada resorte apoyada sobre la varilla transversal, perpendicular al brazo
P.res.r_pata = P.res.l_m;     % mm (brazo de palanca sobre el brazo inferior)

% Herrajes montados en los dos pasadores del acoplador (masas del CAD, g)
% Pasador único por nodo: Ø8 x 242 mm de acero (memoria de geometría del nodo)
P.nodo.L_pasador = 242;   % mm = 218 entre caras exteriores de las alas + 2 x 12 de rosca en la perilla
P.rho_acero = 7850;       % kg/m^3
% SUPOSICIÓN: masa del pasador como cilindro lleno de Ø8 x 242 mm, sin descontar la rosca ni los planos.
m_pasador = pi/4*P.nodo.d_pasador^2*P.nodo.L_pasador*1e-9*P.rho_acero*1000;   % g
% KFL08: 26.4 g (Naylamp). SUPOSICIÓN: masas de pernos, tuercas, perillas y arandelas del CAD anterior.
herr = [2*m_pasador, ...   % pasadores Ø8 (uno por nodo del acoplador)
        4*26.4, ...        % KFL08 (Naylamp)
        8*3.425, ...       % pernos de las KFL08 (2 por KFL)
        12*1.293, ...      % tuercas (4 axiales de los pasadores + 8 de los pernos de las KFL08)
        4*4.367, ...       % perillas
        4*0.35];           % arandelas DIN 125 A 8.4
P.m_herrajes_acoplador = sum(herr)/1000;   % kg

%% ---------------- Perfil de movimiento ----------------
P.t_b = 10;            % s, tiempo del barrido completo
P.f_a = 0.25;          % fracción de t_b en aceleración (igual en desaceleración)
P.H_ajuste = [1000 1300];  % mm, ajuste típico de altura del plano óptico
% SUPOSICIÓN: la fricción de cada KFL08 se acota con el valor adoptado en la sección de orientación para los rodamientos del eje basculante, estimado con sellos de contacto (no hay dato de la KFL08).
P.T_rod_1 = 0.0201;    % N·m, fricción por rodamiento (cota conservadora: valor de la sección de orientación asignado a cada chumacera)
P.n_rod = 8;           % rodamientos KFL08 en el mecanismo

%% ---------------- Cargas de servicio ----------------
P.pendiente = 16;      % grados, pendiente longitudinal máxima del camino
% NTE E.020, Art. 12: V = 75 km/h (mínimo normativo, sin reducción por altura),
% C = 1.5 (elementos con una dimensión corta en la dirección del viento), Tipo 2 (x1.2)
% SUPOSICIÓN: mismos V, C = 1.5 y factor 1.2 que en la sección de orientación, aplicados también a los brazos y al acoplador.
P.viento.V  = 75; P.viento.C = 1.5; P.viento.fr = 1.2;
P.viento.P_kgf = P.viento.fr*0.005*P.viento.C*P.viento.V^2;  % kgf/m^2
P.viento.P  = P.viento.P_kgf*9.80665;                         % Pa

%% ---------------- Tornillería ----------------
% ISO 3506-1:2009, Tabla 2, A2-70
P.A270.Rm = 700; P.A270.Rp02 = 450;
P.M5.d = 5; P.M5.p = 0.8; P.M5.agujero = 5.5;   % ISO 273 serie media
P.M5.As = pi/4*(P.M5.d - 0.9382*P.M5.p)^2;      % ISO 3506-1 Anexo A
% SUPOSICIÓN: K = 0.20 (Shigley, condición del perno no indicada); el inoxidable sobre inoxidable sin lubricar puede diferir.
P.M5.K  = 0.20;      % factor de par, Shigley Ec. (8-27) y Tabla 8-15 (condición del perno no indicada)
P.M5.frac_precarga = 0.55;  % Fi = 0.55 * As * Rp0.2: limitada por el separador de AISI 303 (la unión no cuenta con la fricción)
% SUPOSICIÓN: se adopta el menor valor disponible para tuercas en T deslizantes M5 de perfil serie 20:
% 684 N (Ooznest, "Pull Out Loading Rating"); el valor anterior de 1022 N provenía de otro catálogo.
P.tuercaT.F_extr = 684;    % N, resistencia a la extracción de la tuerca T
% SUPOSICIÓN: dimensiones nominales de la arandela DIN 125 A 5.3 tomadas de memoria (no localizadas en el catálogo adjunto).
P.arandela5.dext = 10; P.arandela5.dint = 5.3;  % DIN 125 A 5.3

%% ---------------- Factores de seguridad y criterios ----------------
% ADM 2005, Tabla 3.4-1, estructuras tipo edificación
% SUPOSICIÓN: se aplican a un mecanismo los factores del ADM para estructuras tipo edificación (criterio adoptado).
P.nu = 1.95; P.ny = 1.65; P.na = 1.20;
P.kt = 1.0;            % ADM Tabla 3.4-2 (5052 y 6061, sin soldadura)
P.f_ssy = 0.577;       % Shigley, Ec. (5-21), energía de distorsión: Ssy = 0.577 Sy

%% ---------------- Separador (casquillo inoxidable Ø8 x Ø5.4) ----------------
P.sep.dext = 8; P.sep.dint = 5.4;
% SUPOSICIÓN: condición recocida del AISI 303 (valor aproximado de la hoja técnica).
P.sep.Sy = 225;        % MPa, AISI 303 recocido (hoja técnica Serviacero, valor aproximado)

%% ---------------- Cartelas (5052-H32, t = 3 mm) ----------------
P.cart.t   = 3;
P.cart.u_trav = 65;         % mm, centro del travesaño desde el pivote base (a lo largo del brazo)
P.cart.ala_u  = [35 95];    % mm, extensión del ala sobre el brazo
P.cart.ala_b  = 25.4;       % mm, ancho del ala (= ancho del tubo)
P.cart.u_torn_brazo = [45 85];   % mm, tornillos sobre el eje del brazo
P.cart.tallo_b = 32.5;      % mm, ancho del tallo (dirección u)
P.cart.tallo_y = [12.7 32.7]; % mm, extensión del tallo desde el eje del brazo
P.cart.y_torn_trav = 22.7;  % mm, fila de tornillos del travesaño (desde el eje del brazo)
P.cart.du_torn_trav = 6.25; % mm, tornillos del travesaño en u = 65 +/- 6.25
P.trav.holgura = 0.5;       % mm por lado entre travesaño y brazo
