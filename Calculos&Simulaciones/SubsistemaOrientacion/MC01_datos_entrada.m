function P = MC01_datos_entrada()
% MC01_DATOS_ENTRADA  Datos de entrada del subsistema de orientacion.
%
% Unidades SI (m, kg, s, N, rad), salvo que el comentario indique otra.
% Entre corchetes va la fuente de cada dato:
%   [Tabla]   Tabla de datos de entrada del subsistema (capitulo de tesis)
%   [CAD]     Medido en el modelo CAD MECANISMO_ORIENTACION.step
%   [Shigley] Budynas y Nisbett, Diseno en ingenieria mecanica de Shigley, 9a ed.
%   [KHK]     KHK Gear Technical Reference (2012) / catalogo KHK
%   [NTE]     NTE E.020 Cargas (2006)
%   [IEC]     IEC 61724-1:2021
%   [MPU]     InvenSense PS-MPU-6000A-00 rev. 3.4
%   [Motor]   StepperOnline 17HS16-2004S1 (pagina, hoja de datos y curva)
%   [Rod]     Ficha del rodamiento MR2010A (Miniature Bearings Australia)
%   [PEM]     PennEngineering, SI inserts for plastics
%   [SAE660]  Metals4U, SAE 660 bronze
%   [Majes]   GTS Majes S.A.C. (2020), anexos de la DIA, parte 4
%   [AGMA]    ANSI/AGMA 6022-D19, Design manual for cylindrical wormgearing

mc_encabezado(1, 'Datos de entrada', ...
    'Reunir en un solo lugar todos los datos, con su fuente.', {});

P.g = 9.81;                               % m/s^2

% ------------------------------------------------------------------
% Carga y plataforma
% ------------------------------------------------------------------
P.m_carga  = 0.50;     % kg  masa de diseno del sensor [Tabla]
P.m_ms80   = 0.35;     % kg  masa del EKO MS-80, solo para comparacion [Tabla]
P.d_cm     = 0.025;    % m   excentricidad horizontal de diseno [Tabla]
P.z_s      = 0.0543;   % m   altura del CM del sensor sobre el eje [CAD]
P.k2_s     = 3761e-6;  % m^2 radio de giro al cuadrado del sensor respecto al eje
                       %     (densidad uniforme, CM en el centro geometrico) [CAD]
P.m_plat   = 0.25;     % kg  masa de diseno de la plataforma [Tabla]
P.L_plat   = 0.090;    % m   lado de la placa en el plano de giro [Tabla]

% Placa de aluminio y su tornillería [CAD]. Los soportes y la chapa del
% sensor inercial son de ABS impreso y no se cuentan: se desconoce su relleno.
P.V_placa    = 22.26e-6;   % m^3
P.rho_al     = 2700;       % kg/m^3
P.z_placa    = 0.01650;    % m   CM de la placa sobre el eje
P.Jv_placa   = 2.153e-8;   % m^5 integral de r^2 dV respecto al eje
P.V_torn     = 0.77e-6;    % m^3 tornillería de la placa
P.rho_torn   = 7900;       % kg/m^3
P.z_torn     = 0.01561;    % m
P.Jv_torn    = 2.953e-10;  % m^5

% Corona y eje [CAD]
P.V_corona   = 5.89e-6;    % m^3 (modelo con ancho de cara de 8 mm)
P.rho_bronce = 8930;       % kg/m^3
P.Jv_corona  = 6.591e-10;  % m^5
P.Jv_eje     = 1.718e-10;  % m^5
P.rho_acero  = 7850;       % kg/m^3
P.m_imu      = 0.003;      % kg  tarjeta del sensor inercial

% ------------------------------------------------------------------
% Movimiento y tolerancias
% ------------------------------------------------------------------
P.th_min   = -30*pi/180;   % rad [Tabla]
P.th_max   =  30*pi/180;   % rad [Tabla]
P.t_b      = 5.0;          % s   tiempo de barrido [Tabla]
P.f_a      = 0.25;         % -   fraccion de aceleracion [Tabla]
P.eps_adm  = 0.5;          % grados, tolerancia de inclinacion Clase A [IEC]
P.az_adm   = 1.0;          % grados, tolerancia de azimut Clase A [IEC]
P.margen_pitch = 2;        % margen sobre la exactitud del IMU (criterio propio)
P.beta_tabla   = [5 10 12 18 30];   % grados, inclinaciones evaluadas en MC-02

% ------------------------------------------------------------------
% Transmision tornillo sin fin - corona
% ------------------------------------------------------------------
P.m_mod    = 1.0e-3;       % m   modulo axial [Tabla]
P.Z1       = 1;            % entradas del sin fin [Tabla]
P.Z2       = 30;           % dientes de la corona [Tabla]
P.d_ext    = 14.5e-3;      % m   diametro exterior del sin fin [Tabla]
P.phi_n    = 20*pi/180;    % rad angulo de presion normal [Tabla][KHK]
P.mu_s     = 0.15;         % friccion estatica acero-bronce [Tabla]
P.j_t      = 0.28e-3;      % m   juego circunferencial [Tabla][KHK]
P.a_CAD    = 21.25e-3;     % m   distancia entre centros [CAD]
P.r_tip_w_CAD = 7.25e-3;   % m   radio exterior del sin fin, d_ext/2 = 14.5/2 [Tabla][CAD]
P.r_tip_g_CAD = 16.0e-3;   % m   radio exterior (garganta) de la corona [CAD]
P.F_e      = 10e-3;        % m   ancho de cara de la corona (valor de diseno)
P.y_lewis  = 0.125;        % factor de forma para phi_n = 20 grados [Shigley Ec. 15-53]
P.Sy_bronce_cent = 95e6;   % Pa  SAE 660 fundido por centrifugacion [SAE660]
P.Sy_bronce_cont = 140e6;  % Pa  SAE 660 colada continua [SAE660]
P.mu_tabla = [0.050 0.075 0.087 0.100 0.150 0.200];  % valores de mu para la sensibilidad (MC-13)

% ------------------------------------------------------------------
% Viento [NTE] y friccion de rodamientos
% ------------------------------------------------------------------
P.V_viento = 75;           % km/h velocidad de diseno minima [NTE 12.3]
P.C_forma  = 1.5;          % factor de forma [NTE Tabla 5.4]
P.V_op     = 33;           % km/h rafaga maxima de operacion para |theta| >= 12 gr (condicion de operacion, MC-15)
P.f_r      = 1.2;          % factor para estructuras Tipo 2 [NTE 12.2]
P.A_exp    = 0.012;        % m^2 envolvente del area expuesta [Tabla]
P.h_cp     = 0.060;        % m   envolvente del brazo del centro de presion [Tabla]
P.kgf      = 9.80665;      % N/kgf
P.T_rod    = 0.0201;       % N m friccion de rodamientos adoptada (MC-04; conservadora con escudos ZZ)
P.mu_rod   = 0.0015;       % coeficiente de friccion de rodamiento rigido de bolas (SKF simplificado)
P.M_sello  = 0.01;         % N m par de sellos de contacto por rodamiento (valor estimado)
P.n_rod    = 2;            % rodamientos del eje basculante

% ------------------------------------------------------------------
% Actuador [Tabla][Motor]
% ------------------------------------------------------------------
P.S        = 1.30;         % factor de seguridad de torque
P.paso     = 1.8;          % grados por paso
P.micro    = 16;           % micropasos
P.I_set    = 1.40;         % A de pico, corriente configurada
P.I_nom    = 2.0;          % A, corriente nominal
P.T_ret_nom = 0.45;        % N m torque de retencion nominal
P.J_rotor  = 54e-7;        % kg m^2 (54 g cm^2, hoja de datos 2020)
P.L_sinfin = 31.5e-3;      % m   longitud del sin fin [CAD]
P.J_acople = 1.0e-6;       % kg m^2 inercia del acoplamiento (valor estimado)
P.T_po_min = 0.29;         % N m pull-out minimo entre 0 y 90 rpm, que ocurre a 60 rpm
P.I_curva  = 2.05;         % A de pico en el ensayo de la curva (DM542T, 24 V)
P.Fa_motor_max = 10;       % N carga axial dinamica maxima en el eje del motor
P.Fr_motor_max = 21;       % N carga radial dinamica maxima a 20 mm

% ------------------------------------------------------------------
% Eje basculante [CAD][Shigley]
% ------------------------------------------------------------------
P.d_eje    = 0.010;        % m
P.L_rod    = 0.111;        % m   separacion entre rodamientos [CAD]
P.x_sop    = 0.013;        % m   soporte de la plataforma desde cada rodamiento [CAD]
P.a_cor    = 0.0355;       % m   plano medio de la corona fuera del rodamiento derecho [CAD]
P.a_imu    = 0.0546;       % m   chapa del sensor inercial fuera del rodamiento derecho [CAD]
P.L_tor    = 0.0485;       % m   tramo corona - soporte derecho [CAD]
P.r_corona = 0.015;        % m   radio de paso de la corona
P.Kt       = 2.0;          % concentracion de esfuerzos por planos de prisioneros [Tabla]
P.Sy_eje   = 310e6;        % Pa  AISI 1045 [ASM, valor de la tesis]
P.Sy_HR    = 340e6;        % Pa  AISI 1045 HR [Shigley Tabla A-20]
P.Sy_CD    = 530e6;        % Pa  AISI 1045 CD [Shigley Tabla A-20]
P.Sut_HR   = 620e6;        % Pa  AISI 1045 HR, menor Sut de la Tabla A-20 (conservador)
P.ka_a     = 2.00;         % ksi superficie maquinada [Shigley Ec. 6-18, Tabla 6-2]
P.ka_b     = -0.217;       %     superficie maquinada, conservador (rectificada daria 0.897)
P.ke_99    = 0.814;        % confiabilidad 99% [Shigley Tabla 6-4]
P.Kf_fat   = 2.0;          % Kf = Kt en flexion y torsion, sin reducir por sensibilidad a la muesca (conservador)
P.t_ciclo  = 5*60;         % s   un barrido de ida y vuelta cada 5 minutos (dato del autor)
P.n_d      = 3.0;          % factor de seguridad de diseno
P.E        = 207e9;        % Pa  [Shigley Tabla A-5]
P.G        = 79.3e9;       % Pa  [Shigley Tabla A-5]
P.y_adm    = 0.003*0.0254; % m   flecha admisible, engranes con 20 < P < 50 dientes/in [Shigley Tabla 7-2]
P.pend_rod_adm = 0.001;    % rad rodamiento de bolas de ranura profunda, minimo del rango [Shigley Tabla 7-2]
P.pend_eng_adm = 0.0005;   % rad engrane recto sin abombar [Shigley Tabla 7-2]
P.ang_caja_adm = 5/60*pi/180; % rad angularidad admisible de la caja, 90 gr +/- 5' [AGMA 6022-D19, 7.3]
P.k_flecha_sinfin = 0.025;    % flecha admisible del sin fin = 0.025 p_x (mm) [AGMA 6022-D19, 15.5.2]
P.E_agma = 206850e6;          % Pa, acero [AGMA 6022-D19, 15.5.1]

% ------------------------------------------------------------------
% Rodamientos [Rod]
% ------------------------------------------------------------------
P.C0_rod   = 80.8*9.80665; % N  capacidad estatica C0 del MR2010A (80.8 kgf)

% ------------------------------------------------------------------
% Prisioneros e insertos [Shigley][PEM]
% ------------------------------------------------------------------
P.F_ret_n4   = 712;        % N  retencion del prisionero n.o 4 [Shigley Tabla 7-4]
P.T_asiento_n4 = 5*0.112985; % N m par de asiento del n.o 4, 5 lbf in [Shigley Tabla 7-4]
P.d_n4       = 0.112*0.0254; % m diametro nominal n.o 4
P.K_par      = 0.2;        % coeficiente de par, T = K F d [Shigley Ec. 8-27, Tabla 8-15]
P.n_pris     = 2;          % prisioneros por cubo [CAD]
P.d_M4       = 0.004;      % m
P.F_ext_ins  = 324;        % N  extraccion IPFC-M4 en ABS [PEM]
P.T_giro_ins = 2.35;       % N m par de giro IPFC-M4 en ABS [PEM]
P.FS_din_min = 4;          % FS minimo recomendado para cargas dinamicas [Shigley 7-7]
P.d_acople  = 0.005;      % m   eje del motor y extremo del sin fin [Motor][CAD]
P.F_ret_n0  = 50*4.44822; % N   prisionero n.o 0, el menor de la Tabla 7-4 [Shigley]

% ------------------------------------------------------------------
% Presupuesto de error (grados) [Tabla]
% ------------------------------------------------------------------
P.err_imu     = 0.100;     % exactitud del sensor inercial calibrado
P.err_montaje = 0.200;     % montaje del sensor y soportes
P.err_rod     = 0.050;     % holgura de rodamientos
P.mpu_escala  = 0.03;      % tolerancia tipica del factor de escala [MPU]
P.mpu_zerog   = 0.035;     % g, variacion tipica de la salida a cero g, 0-70 C [MPU]

% ------------------------------------------------------------------
% Condicion de operacion por viento
% ------------------------------------------------------------------
P.th_viento = [5 10 12 15 20 25 30];   % grados
P.Vmedia_max_majes = 2.7;              % m/s media diaria maxima 2016-2019 [Majes]
P.V_mapa_max = 130;                     % km/h mayor valor que se lee en el mapa eolico [NTE Anexo 2]

% Datos que se imprimen en el reporte
mc_seccion('Resumen de datos principales');
mc_dato('Masa de diseno del sensor', P.m_carga, 'kg');
mc_dato('Altura del CM del sensor sobre el eje (CAD)', P.z_s*1e3, 'mm');
mc_dato('Excentricidad horizontal de diseno', P.d_cm*1e3, 'mm');
mc_dato('Masa de diseno de la plataforma', P.m_plat, 'kg');
mc_dato('Barrido', (P.th_max-P.th_min)*180/pi, 'grados');
mc_dato('Tiempo de barrido', P.t_b, 's');
mc_dato('Relacion de reduccion', P.Z2/P.Z1, '-');
mc_dato('Velocidad de viento de diseno', P.V_viento, 'km/h');
mc_dato('Corriente configurada (pico)', P.I_set, 'A');
mc_dato('Separacion entre rodamientos (CAD)', P.L_rod*1e3, 'mm');
mc_nota('Masas de ABS impreso (soportes, chapa del IMU) no consideradas.');
mc_nota('Inercia y masa de la corona del CAD con 8 mm de ancho; el ancho definido es 10 mm.');
end
