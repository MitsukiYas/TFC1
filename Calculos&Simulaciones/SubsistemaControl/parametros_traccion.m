function [KT, PT] = parametros_traccion()
%PARAMETROS_TRACCION  Parámetros del control de tracción y dirección.
%   KT: firmware del Arduino (PI de cada rueda posterior y mando de los servos).
%   PT: vehículo, motorreductores, servomotores, neumáticos y escenario.
%   Geometría y componentes según el estado del 2026-11-19: 505 con los cambios
%   de 504 (505_PROPAGACION_ESQUEMA.md, puntos 7 a 11). Unidades SI salvo indicación.
%   Los supuestos se marcan con SUPOSICIÓN.

%% ---------------- Vehículo ----------------
PT.m    = 25.0;            % kg, masa de diseño (505)
PT.g    = 9.81;
PT.r    = 0.10;            % m, rueda de 200 mm (505, rueda genérica de 504)
PT.fr   = 0.05;            % rodadura (505)
PT.mu   = 0.60;            % adherencia (505)
PT.L    = 0.440;           % m, distancia entre ejes (504)
PT.b    = 0.546;           % m, distancia entre pivotes delanteros (Ackermann, punto 7)
PT.t    = 0.600;           % m, vía trasera (diferencial electrónico, punto 6)
PT.Lcm  = 0.173;           % m, CG desde el eje posterior (memoria_05_masas_cg, sin ruedas)
% SUPOSICIÓN: h_cm = 339 mm, valor medio del rango de 288 a 390 mm de la propagación
% (depende del CG vertical de la elevación, aún no calculado).
PT.hcm  = 0.339;
PT.d_i_max = 35;           % grados, giro máximo de la rueda interior (505)
PT.Rmin = PT.L/tand(PT.d_i_max) + PT.b/2;   % m, radio mínimo al centro del eje posterior
PT.pend = 16;              % grados (requerimiento 4)
PT.a_ref = 0.30;           % m/s^2 (505)
PT.v_nom = 1.0;            % m/s (requerimiento 3)
% SUPOSICIÓN: inercia de ruedas, semiejes y rotores despreciada (505: "por redefinir").
PT.J_rueda = 0;
% SUPOSICIÓN: neumático trasero con fuerza longitudinal proporcional al deslizamiento
% hasta mu·N en un deslizamiento de 0.15; v mínima de 0.1 m/s para definirlo.
PT.s_pico = 0.15;
PT.v_min  = 0.10;

%% ---------------- Motorreductor 42PG-775-67 (505, motor_42pg775) ----------------
V = 24;
w0 = 120*2*pi/60;  I0 = 0.7;
wn = 105*2*pi/60;  In = 6.0;  Tn = 4.90;
PT.I0 = I0;
PT.kt = Tn/(In - I0);
x = [I0 w0; In wn] \ [V; V];
PT.R = x(1);  PT.ke = x(2);
PT.I_bloqueo_fab = 24.5;
PT.i_red = 67;             % reducción planetaria
% SUPOSICIÓN: inductancia despreciada (no publicada).

%% ---------------- Encoder de fábrica del motor (504, punto 9) ----------------
% SUPOSICIÓN: 7 pulsos por vuelta del eje del motor; la hoja de datos del encoder
% está pendiente. Con decodificación 2x de un canal (602) y la reducción de 67:1:
PT.ppr = 7;
PT.cuentas = 2*PT.ppr*PT.i_red;   % cuentas por vuelta de la rueda

%% ---------------- Servomotores RDS3225 (505, 603) ----------------
% Velocidad sin carga de 0.13 s/60° (dsservo_rds3225). Con torque y velocidad lineales
% hasta el bloqueo de 2.35 N·m a 6.5 V (505) y el torque de pivoteo en plano de
% 1.10 N·m (punto 7), la velocidad bajo carga es:
PT.w_servo0 = 60/0.13;                       % grados/s
PT.T_servo  = 1.10;  PT.T_bloq_servo = 2.35;  % N·m
PT.w_servo  = PT.w_servo0*(1 - PT.T_servo/PT.T_bloq_servo);   % grados/s
% SUPOSICIÓN: relación lineal entre torque y velocidad del servo; la posición la
% sigue sin error en régimen (lazo interno del servo).

%% ---------------- Controlador de puente H (603) ----------------
PT.I_lim = 8.0;  PT.d_max_abs = 0.99;

%% ---------------- Firmware ----------------
KT.Ts = 0.020;              % s, SUPOSICIÓN: mismo período de 20 ms que los otros lazos
KT.cuentas = PT.cuentas;
KT.I_lim = PT.I_lim;  KT.d_max_abs = PT.d_max_abs;  KT.V_mot = V;
V_dis = 7*3.6;              % V, SUPOSICIÓN: 3.6 V nominales por celda
J_eq  = (PT.m/2)*PT.r^2 + PT.J_rueda;
KT.tau_m = J_eq*PT.R/(PT.kt*PT.ke);
K = V_dis/PT.ke;
KT.tau_cl = 0.20;           % s, SUPOSICIÓN (criterio de diseño): 10 períodos
KT.Kp = KT.tau_m/(KT.tau_cl*K);
KT.Ti = KT.tau_m;  KT.Ki = KT.Kp/KT.Ti;  KT.V_dis = V_dis;
KT.Kc = 0.02;               % por amperio sobre el límite, SUPOSICIÓN
% Mando de la dirección: con w_servo > 0 el firmware limita la velocidad de cada consigna
% de rueda a la velocidad estimada del servo, para que el diferencial use el ángulo que
% el servo alcanza. La simulación (S4) muestra que esto aumenta el pico de corriente al
% entrar en el viraje (el diferencial pierde la anticipación frente al retardo del PI),
% así que el diseño usa la curvatura pedida directamente (w_servo = 0).
KT.w_servo = 0;             % grados/s; 0: sin limitación
KT.L = PT.L; KT.b = PT.b; KT.t = PT.t; KT.r = PT.r;
% Límite de velocidad en curva: la rueda exterior no puede pedir más que la velocidad
% del motor con la tensión disponible y la carga de rodadura en plano (505: ~118 rpm a 24 V).
KT.R = PT.R; KT.ke = PT.ke;
KT.I_plano = PT.I0 + (PT.fr*PT.m*PT.g*PT.r/2)/PT.kt;   % A por motor en plano
KT.limitar_curva = 1;
KT.kappa_max = 1/PT.Rmin;

%% ---------------- Escenario por omisión ----------------
PT.V_bat  = 29.4;
PT.t_arr  = 0.5;
PT.pend_t = [1e6 0];  PT.pend0 = 0;
PT.giro   = [1e6 1e6 0];    % [inicio, fin, curvatura 1/m] (positiva: izquierda)
PT.giro2  = [1e6 1e6 0];    % segundo tramo (maniobra en S)
PT.diferencial = 1;
PT.t_fin  = 10;
end
