function [KE, PE, KO, PO] = parametros_control()
%PARAMETROS_CONTROL  Parámetros de los lazos de control de elevación y orientación.
%   [KE, PE, KO, PO] = parametros_control() devuelve, para cada subsistema, la
%   estructura del controlador (K*) y la de la planta y el sensor (P*).
%   Los datos de la mecánica se leen de las memorias de cálculo de 502 y 503.
%   Unidades: grados, segundos, mm (alturas) y N·m (momentos), salvo indicación.
%
%   Supuestos aprobados por el usuario (2026-11-18):
%     - período de muestreo del lazo de 20 ms (50 tramas/s de la Sección 605);
%     - velocidad de descenso del brazo durante una parada: caso supuesto;
%     - umbral de detección de atascos: se elige con la simulación;
%     - ráfaga: escalón de momento con los límites de velocidad de 502.
%   Otros supuestos de este archivo se marcan con SUPOSICIÓN.

aqui = fileparts(mfilename('fullpath'));
dirE = fullfile(aqui, '..', 'SubsistemaElevacion');
dirO = fullfile(aqui, '..', 'SubsistemaOrientacion');

%% ------------------------------------------------------------------
%  Sensor MPU-6050 y filtro (comunes)
%  ------------------------------------------------------------------
Ts   = 0.020;     % s, período del lazo (aprobado)
% Densidad espectral de ruido del acelerómetro: 400 ug/sqrt(Hz) (hoja de datos
% del MPU-6050, invensense_mpu6050; dato por confirmar en la hoja de datos).
dens_ruido = 400e-6;            % g/sqrt(Hz)
% SUPOSICIÓN: filtro digital interno del MPU-6050 (DLPF) en 10 Hz de ancho de banda.
bw_dlpf = 10;                   % Hz
sigma_g = dens_ruido*sqrt(pi/2*bw_dlpf);       % g rms (ancho de banda equivalente de ruido de un polo)
sigma_ang = rad2deg(sigma_g);                  % grados rms (inclinómetro: 1 g ~ 1 rad para ángulos pequeños)
% SUPOSICIÓN: filtro de primer orden en el firmware con tau = 0.2 s y espera de
% asentamiento de 5*tau antes de cada lectura de control.
tau_f = 0.20;                   % s
a_f   = Ts/(tau_f + Ts);        % coeficiente del filtro exponencial
T_asent = 5*tau_f;              % s

%% ------------------------------------------------------------------
%  ELEVACIÓN (503)
%  ------------------------------------------------------------------
P = []; run(fullfile(dirE, 'parametros_elevacion.m'));   % define P y g
C = load(fullfile(dirE, 'cargas_elevacion.mat'));
L = P.L/1000;
H0 = P.H15_0 - P.L0*sind(15) + (P.A - P.A0);          % mm, H(theta = 0) (memoria 01)
th_tab = linspace(P.th_min - 5, C.th_max + 5, 81);
M_g = (C.W_acop*L + 2*C.W_brazo*L/2).*cosd(th_tab);  % N·m, terreno plano (memoria 02)
M_s = P.res.n*(P.res.M_alto + P.res.k*deg2rad(C.th_max - th_tab));   % N·m, resortes

KE.Ts        = Ts;
KE.a         = a_f;
KE.T_asent   = T_asent;
KE.banda     = 0.1;                 % grados, banda muerta (503, memoria 10)
% SUPOSICIÓN: el lazo vuelve a corregir si el error supera el doble de la banda muerta.
KE.banda_re  = 2*KE.banda;
KE.Kp        = 1.0;                 % corrección proporcional: ordena todo el error medido
KE.wmax      = rad2deg(C.w_max);    % grados/s (perfil trapezoidal, 503)
KE.alfa      = rad2deg(C.alfa);     % grados/s^2
KE.res       = 1.8/8/50;            % grados por pulso en el brazo (1/8 de paso, 50:1)
KE.dir_final = +1;                  % ajuste final siempre hacia arriba (503)
KE.juego     = 34/60;               % grados, juego del reductor: 18' a 34' (motovario_vsf), se toma 34'
KE.a_off     = KE.juego + KE.banda; % grados, se pasa por debajo de la consigna antes del ajuste final
KE.umbral    = 0.5;                 % grados, umbral de atasco (decisión del usuario, 2026-11-18; ver E3 en resultados_control.txt)
KE.lim_min   = P.th_min;            % grados, límites por software (503)
KE.lim_max   = C.th_max;

PE.H0        = H0;                  % mm
PE.Lmm       = P.L;                 % mm
PE.res       = KE.res;
PE.b2        = KE.juego/2;          % grados, medio juego
PE.th_tab    = th_tab;
PE.M_tab     = -(M_g - M_s);        % N·m, momento externo en el sentido de theta positivo
PE.sigma     = sigma_ang;           % grados rms
PE.sesgo     = 0.1;                 % grados, SUPOSICIÓN: error residual del sensor calibrado igual al de 502
PE.cabeceo   = 0;                   % grados, cabeceo del chasis
PE.semilla   = 1;
PE.th0       = P.th_min;            % grados, ángulo inicial
% SUPOSICIÓN (aprobada como caso supuesto): descenso del brazo durante una parada.
PE.v_desc    = 0.10;                % grados/s
PE.t_parada  = [1e6 1e6];           % s, inicio y fin de la parada (desactivada)
PE.th_traba  = 1e3;                 % grados, ángulo en que se traba el brazo (desactivado)
PE.t_traba   = 1e6;                 % s
PE.H_ini     = 1000; PE.H_fin = 1300; PE.t_ref = 1;   % mm, mm, s (escalón de consigna)

%% ------------------------------------------------------------------
%  ORIENTACIÓN (502)
%  ------------------------------------------------------------------
S = load(fullfile(dirO, 'resultados_orientacion.mat'));
Po = S.P; Ro = S.R;
KO.Ts        = Ts;
KO.a         = a_f;
KO.T_asent   = T_asent;
% SUPOSICIÓN: 502 no define la banda muerta del lazo de inclinación; se usa la de 503.
KO.banda     = 0.1;
KO.banda_re  = 2*KO.banda;
KO.Kp        = 1.0;
KO.wmax      = rad2deg(Ro.w_max);   % grados/s (perfil de 502)
KO.alfa      = rad2deg(Ro.alfa);
KO.res       = 1.8/16/Ro.i;         % grados por pulso en el eje (1/16 de paso, 30:1)
KO.dir_final = 0;                   % 502 no exige un sentido de aproximación
KO.juego     = Po.j_t/(Ro.d_2/2)*180/pi;   % grados (1.07°, 502)
KO.a_off     = 0;
KO.umbral    = 1e3;                 % 502 no define detección de atascos: desactivada
KO.lim_min   = rad2deg(Po.th_min);
KO.lim_max   = rad2deg(Po.th_max);

PO.res       = KO.res;
PO.b2        = KO.juego/2;
PO.Kret      = Po.g*(Po.m_carga*Po.z_s + Ro.m_p_real*Ro.z_p);   % N·m, M_ret = Kret*sin(theta) (MC-15)
PO.Kv        = 0.005*Po.C_forma*Po.kgf*Po.A_exp*Po.h_cp;          % N·m/(km/h)^2 (MC-15)
PO.sigma     = sigma_ang;
PO.sesgo     = Po.err_imu;          % grados (0.1°, 502)
PO.semilla   = 2;
PO.th0       = 0;
PO.V_rafaga  = 0; PO.t_rafaga = [1e6 1e6];   % km/h; s, inicio y fin
PO.b_ini     = 0; PO.b_fin = 20; PO.t_ref = 1;  % grados, grados, s
PO.V_lim     = [21 33];             % km/h, límites de ráfaga de 502 (5-12° y >= 12°)
end
