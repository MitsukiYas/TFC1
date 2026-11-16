%% MEMORIA 03 - Limitador LTC4364-2 de la linea protegida
% Revision de los divisores UV/OV y FB, limite de corriente, condensador de compuerta (C_HG),
% condensador del temporizador (C_TMR) y requisitos de los dos MOSFET de canal N:
%   M1: paso, controlado por HGATE (limita tension y corriente).
%   M2: diodo ideal, controlado por DGATE.
% (TFC/cap6/606, PENDIENTE del LTC4364-2.)
%
% Fuentes: hoja de datos LTC4364-1/LTC4364-2, Analog Devices, Rev. B: caracteristicas
% electricas, Applications Information (Fault Timer, Cool Down Period, MOSFET Selection,
% Short-Circuit Stress, Limiting Inrush Current, Output Bypassing, Design Example).
% Hoja de datos FDMS86150, Fairchild/ON Semiconductor, Rev. 1.5 (marzo de 2015): M1 y M2.
% Datos del circuito: los valores ya escritos en 606.
clear; clc;
run('parametros_electrico.m');
load('demanda_electrico.mat', 'D');
load('entrada_electrico.mat', 'R'); R02 = R; clear R;
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 03: LIMITADOR LTC4364-2 ===\n\n');

%% 0. Datos de la hoja de datos (LTC4364, Rev. B)
L.V_ref   = [1.22 1.25 1.28];  % V, umbrales UV, OV y tension de regulacion de FB (min, tip, max)
L.V_uvh   = [0.025 0.050 0.080]; % V, histeresis de UV
L.dVsns   = [43 50 57]*1e-3;   % V, umbral de sobrecorriente con OUT >= 2.5 V, -40 a 125 C
L.dVsns_0 = [18 25 32]*1e-3;   % V, umbral con OUT entre 0 y 1.5 V
L.I_hg_up = [10 20 30]*1e-6;   % A, corriente de carga de HGATE
L.V_tmr_f = 1.25;  L.V_tmr_g = 1.35;   % V, umbrales de aviso (FLT) y de apagado del temporizador
L.I_warn  = 5e-6;              % A, corriente del temporizador tras el aviso en sobretension
L.I_cool  = 2e-6;              % A, carga y descarga durante el enfriamiento
L.V_cc_op = 80;                % V, tension de operacion maxima de VCC
L.V_abs   = 100;               % V, maximo absoluto de VCC, SOURCE, SENSE, OUT
L.dV_hg   = [10 12 16];        % V, tension de compuerta de HGATE y DGATE con VCC >= 8 V
L.C_out_min = 22e-6;           % F, electrolitico minimo a la salida
L.C_HG_rec  = 6.8e-9;          % F, condensador de compuerta recomendado para compensar el lazo
% Corrientes del temporizador (formulas tipicas de la hoja de datos):
I_tmr_ov = @(dV) 2e-6  + 0.644e-6*(dV - 0.5);   % A, sobretension, dV = VCC - VOUT
I_tmr_oc = @(dV) 10e-6 + 3.36e-6*(dV - 0.5);    % A, sobrecorriente
% La tabla de caracteristicas da, con VCC - OUT = 75 V, 210 a 310 uA (tipica 260 uA) en
% sobrecorriente y 40 a 60 uA (tipica 50 uA) en sobretension. Para el tiempo mas largo se
% escala la formula tipica por la relacion minimo/tipico.
k_oc = 210/260;  k_ov = 40/50;

%% 1. Datos del circuito (606)
Rd.R1 = 261e3; Rd.R2 = 6.65e3; Rd.R3 = 10e3;  % divisor UV/OV: UV entre R1 y R2, OV entre R2 y R3
Rd.Rf1 = 130e3; Rd.Rf2 = 5e3;                 % divisor de FB
% Decision del usuario (2026-11-15): se sube R_SNS de 5 mohm a 20 mohm para reducir el
% esfuerzo de M1 en sobrecarga (el limite de 10 A era unas 7 veces la demanda).
R_sns = 20e-3;                                % ohm
C_pi  = 2*470e-6;                             % F, electroliticos del filtro pi (salida del LTC4364)
I_carga = D.I_prot_max;                       % A, demanda maxima de la linea protegida (memoria 01)
V_in_nom = E.bat.V_max;                       % V, mayor tension de entrada sostenida
% Mayor tension de entrada transitoria: la barra de actuadores, que comparte el nodo con la
% entrada del limitador, queda limitada por los TVS SMBJ30A de los controladores.
V_in_pk = E.tvs.V_C;                          % V
fprintf('0. Carga maxima de la linea protegida (memoria 01): %.2f A\n', I_carga);
fprintf('   Entrada sostenida maxima %.1f V; transitoria maxima %.1f V (TVS de la barra)\n\n', V_in_nom, V_in_pk);

%% 2. Divisores UV/OV y FB
Rt = Rd.R1 + Rd.R2 + Rd.R3;
V_uv  = L.V_ref*Rt/(Rd.R2 + Rd.R3);
V_ov  = L.V_ref*Rt/Rd.R3;
V_uvr = (L.V_ref(2) + L.V_uvh)*Rt/(Rd.R2 + Rd.R3);
V_fb  = L.V_ref*(Rd.Rf1 + Rd.Rf2)/Rd.Rf2;
fprintf('2. Divisores\n');
fprintf('   UV: corte a %.2f V (%.2f a %.2f V); reconexion a %.2f V (%.2f a %.2f V)\n', V_uv(2), V_uv(1), V_uv(3), V_uvr(2), V_uvr(1), V_uvr(3));
fprintf('   OV: %.2f V (%.2f a %.2f V)\n', V_ov(2), V_ov(1), V_ov(3));
fprintf('   FB: regulacion a %.2f V (%.2f a %.2f V)\n', V_fb(2), V_fb(1), V_fb(3));
fprintf('   Corriente del divisor UV/OV a %.1f V: %.0f uA; del divisor FB a %.2f V: %.0f uA\n', V_in_nom, V_in_nom/Rt*1e6, V_fb(2), V_fb(2)/(Rd.Rf1+Rd.Rf2)*1e6);
c = V_uv(3) < 21.5;
fprintf('   Alerta del LTC2944 (21.5 V) por encima del corte maximo (%.2f V): %s\n', V_uv(3), ok(c));
c = V_ov(1) > V_in_nom;
fprintf('   OV minimo (%.2f V) por encima de la bateria cargada (%.1f V): %s\n', V_ov(1), V_in_nom, ok(c));
c = V_fb(1) > V_in_nom;
fprintf('   Regulacion minima de FB (%.2f V) por encima de la bateria cargada: %s\n', V_fb(1), ok(c));
c = V_fb(3) < min(E.lim.V_TPS54540, 36);
fprintf('   Regulacion maxima de FB (%.2f V) por debajo de 36 V (LMR33630) y 42 V (TPS54540): %s\n', V_fb(3), ok(c));
fprintf('   Nota: el rango de OV (%.2f a %.2f V) se solapa con el de FB; OV solo impide el arranque\n', V_ov(1), V_ov(3));
fprintf('   y el reintento, no apaga el limitador en marcha, por lo que el solape no causa cortes.\n\n');

%% 3. VCC y salida
fprintf('3. Alimentacion del integrado y salida\n');
c = V_in_pk < L.V_cc_op;
fprintf('   Entrada transitoria %.1f V < %.0f V de operacion de VCC: %s (no se requiere Zener en VCC)\n', V_in_pk, L.V_cc_op, ok(c));
c = C_pi/2 >= L.C_out_min;
fprintf('   Electrolitico a la salida (primer condensador del filtro pi, %.0f uF) >= %.0f uF: %s\n', C_pi/2*1e6, L.C_out_min*1e6, ok(c));
fprintf('   Ceramicos admisibles a la salida: hasta %.0f uF (un decimo del electrolitico)\n\n', C_pi/2/10*1e6);

%% 4. Limite de corriente
I_lim   = L.dVsns/R_sns;
I_lim_0 = L.dVsns_0/R_sns;
fprintf('4. Limite de corriente con R_SNS = %.0f mohm\n', R_sns*1e3);
fprintf('   OUT >= 2.5 V: %.2f A (%.2f a %.2f A); OUT < 1.5 V: %.2f A (%.2f a %.2f A)\n', I_lim(2), I_lim(1), I_lim(3), I_lim_0(2), I_lim_0(1), I_lim_0(3));
c = I_lim(1) > I_carga;
fprintf('   Limite minimo por encima de la carga maxima (%.2f A): %s (relacion %.2f)\n', I_carga, ok(c), I_lim(1)/I_carga);
fprintf('   Perdida en R_SNS: %.0f mW a plena carga; %.2f W en el limite maximo\n\n', I_carga^2*R_sns*1e3, I_lim(3)^2*R_sns);

%% 5. MOSFET FDMS86150 (M1 y M2)
F.V_DS = 100; F.V_GS = 20;        % V, maximos absolutos
F.Rds_25 = 4.85e-3;               % ohm, maximo a V_GS = 10 V y 25 C
F.Rds_125 = 9.1e-3;               % ohm, maximo a V_GS = 10 V y 125 C
F.Vth = [2 4];                    % V
F.TJ_max = 150;                   % C
F.R_JA = 115;                     % C/W, con la superficie de cobre minima (base de las Fig. 11 a 13)
% Respuesta termica transitoria de pulso unico (Fig. 13), Z(t) = r(t)*R_JA.
% SUPOSICION: valores de r(t) leidos de la grafica, aproximados; se interpolan en escala log-log.
F.t_r = [1e-3 1e-2 1e-1 1 10 100 1000];
F.r   = [0.0017 0.008 0.035 0.13 0.4 0.85 1.0];
Z = @(t) F.R_JA*10.^interp1(log10(F.t_r), log10(F.r), log10(max(t, 1e-4)), 'linear', 'extrap');
T_A = E.T_int;                    % C, temperatura interna de diseno de los gabinetes
dT_adm = F.TJ_max - T_A;
fprintf('5. FDMS86150: %.0f V, +-%.0f V de compuerta, R_DS(on) <= %.2f mohm (25 C) y %.1f mohm (125 C)\n', F.V_DS, F.V_GS, F.Rds_25*1e3, F.Rds_125*1e3);
fprintf('   Comprobacion de la lectura de la Fig. 13 con la Fig. 12 (25 C): %.0f W a 1 ms, %.0f W a 10 ms\n', (F.TJ_max-25)/Z(1e-3), (F.TJ_max-25)/Z(1e-2));
fprintf('   Con %.0f C de ambiente: %.0f W a 1 ms, %.0f W a 10 ms, %.0f W a 100 ms\n\n', T_A, dT_adm/Z(1e-3), dT_adm/Z(1e-2), dT_adm/Z(1e-1));
% Elevacion de temperatura al final de una potencia P(t) cualquiera, por superposicion de escalones.
dT_fun = @(t, P) sum(diff([0, P]) .* Z(t(end) - t + 1e-6));

%% 6. Corriente de arranque y condensador de compuerta C_HG
% I_INRUSH = I_HGATE(UP) * C_L / C_HG (hoja de datos). Criterio: que el limite de corriente
% no actue en el arranque, con la corriente de HGATE maxima y los umbrales minimos:
%  - con la salida por debajo de 1.5 V (umbral reducido), donde ningun convertidor consume;
%  - con la salida por encima de 2.5 V, sumando la carga que toma el LMR33630 durante la rampa.
% Decision del usuario (2026-11-15): la salida ENOUT del LTC4364 habilita el TPS54540 (memoria 05),
% de modo que la linea de 5.0 V arranca cuando termina la carga de los condensadores. El LMR33630
% no se habilita con ENOUT: arranca al superar su entrada minima de 3.8 V y toma potencia
% constante (la mayor de la barra meteorologica, memoria 01), es decir, mas corriente con la
% entrada baja. En la conexion directa, la barra toma 0.30 A (memoria 01); se toma la mayor.
% C_L: electroliticos y ceramicos del filtro pi y condensadores de entrada de los convertidores
% (los del TPS54540 salen de la memoria 05, que debe correrse antes).
B05 = load('buck5V_electrico.mat'); B05 = B05.R;
C_ce_pi = 2*22e-6;      % F, ceramicos del filtro pi, 22 uF por nodo (decision del usuario, 2026-11-15)
% Entrada del LMR33630: su hoja de datos pide al menos 10 uF efectivos de ceramicos, con tension
% nominal mayor que la entrada maxima, mas 220 nF de 50 V X7R junto al integrado. Se adoptan
% 2 x 10 uF de 50 V X7R, que conservan unos 10 uF suponiendo la perdida de la mitad de su capacidad.
C_in_lmr = 2*10e-6 + 220e-9;
C_L = C_pi + C_ce_pi + B05.C_in_nom + C_in_lmr;
P_met = 0.300*(12.0 + 1.85)/0.90;   % W, barra meteorologica a 12 V con 0.3 A (memoria 01)
V_on_lmr = 3.8;                     % V, entrada minima del LMR33630
I_met_fun = @(V) (V >= V_on_lmr).*max(P_met./max(V, V_on_lmr), 0.300);
I_met_max = P_met/V_on_lmr;
E6 = [1 1.5 2.2 3.3 4.7 6.8];
serie = reshape(E6' * 10.^(-10:-6), 1, []);
C_HG_min = max(L.I_hg_up(3)*C_L/I_lim_0(1), L.I_hg_up(3)*C_L/(I_lim(1) - I_met_max));
C_HG = min(serie(serie >= C_HG_min));
I_inr = L.I_hg_up*C_L/C_HG;
fprintf('6. Arranque con C_L = %.0f uF (filtro %.0f + ceramicos %.0f + TPS54540 %.1f + LMR33630 %.0f)\n', C_L*1e6, C_pi*1e6, C_ce_pi*1e6, B05.C_in_nom*1e6, C_in_lmr*1e6);
fprintf('   TPS54540 habilitado por ENOUT; LMR33630 activo desde %.1f V con %.2f W (hasta %.2f A)\n', V_on_lmr, P_met, I_met_max);
fprintf('   C_HG minimo %.1f nF; se adopta %.0f nF (serie E6); arranque %.2f a %.2f A\n', C_HG_min*1e9, C_HG*1e9, I_inr(1), I_inr(3));
fprintf('   Por debajo del limite reducido (%.2f A): %s; con el LMR33630 (%.2f A) bajo %.2f A: %s\n', I_lim_0(1), ok(I_inr(3) < I_lim_0(1)), I_inr(3) + I_met_max, I_lim(1), ok(I_inr(3) + I_met_max < I_lim(1)));
% Esfuerzo termico de M1: la salida sube linealmente en T = C_L V / I_inr; M1 conduce la
% corriente de carga mas la del LMR33630, con la tension V_in - V_out.
E_arr = 0.5*C_L*V_in_nom^2;
TJ_arr = zeros(1, 3); T_arr = zeros(1, 3); P0_arr = zeros(1, 3);
for k = [1 3]
    T_arr(k) = C_L*V_in_nom/I_inr(k);
    t = linspace(0, T_arr(k), 400);
    Vo = V_in_nom*t/T_arr(k);
    P = (I_inr(k) + I_met_fun(Vo)).*(V_in_nom - Vo);
    dT = arrayfun(@(n) dT_fun(t(1:n), P(1:n)), 1:numel(t));
    TJ_arr(k) = T_A + max(dT); P0_arr(k) = max(P);
end
fprintf('   Energia de carga de los condensadores: %.0f mJ\n', E_arr*1e3);
for k = [3 1]
    fprintf('   I_HGATE(UP) = %.0f uA: %.1f ms, potencia maxima %.0f W, T_J maxima %.0f C: %s\n', L.I_hg_up(k)*1e6, T_arr(k)*1e3, P0_arr(k), TJ_arr(k), ok(TJ_arr(k) < F.TJ_max));
end
fprintf('   La hoja de datos sugiere una resistencia de 100 ohm en serie con C_HG, con un diodo en\n');
fprintf('   paralelo, para que el condensador no retrase el apagado ante una falla.\n\n');

%% 7. Condensador del temporizador C_TMR (criterio del usuario: el mayor que admite M1)
% Casos de falla (M1 conduce hasta que el temporizador lo apaga):
%  a) sobretension: entrada en la limitacion de los TVS, salida en el minimo de FB, demanda maxima;
%  b) cortocircuito franco (OUT = 0) con la bateria cargada, umbral reducido maximo;
%  c) sobrecarga con OUT = 2.5 V, umbral maximo.
% Tiempo de falla por faradio de C_TMR (corrientes minimas del temporizador: tiempo mas largo).
% Margen: la hoja de datos recomienda duplicar el P^2t de cortocircuito; a potencia constante
% equivale a duplicar la duracion. Condicion: T_A + P*Z(2 t) <= T_J,max.
nom = {'a) Sobretension', 'b) Cortocircuito (OUT = 0)', 'c) Sobrecarga (OUT = 2.5 V)'};
V_c = [V_in_pk - V_fb(1), V_in_nom, V_in_nom - 2.5];
I_c = [I_carga, I_lim_0(3), I_lim(3)];
t_por_F = [L.V_tmr_f/(k_ov*I_tmr_ov(V_c(1))) + 0.1/L.I_warn, ...
           L.V_tmr_g/(k_oc*I_tmr_oc(V_c(2))), L.V_tmr_g/(k_oc*I_tmr_oc(V_c(3)))];
P_c = V_c.*I_c;
fprintf('7. Temporizador (T_A = %.0f C; duracion duplicada como margen)\n', T_A);
C_max = zeros(1, 3);
for k = 1:3
    lt = fzero(@(x) log(P_c(k)*Z(2*10^x)/dT_adm), [-6 3]);
    t_adm = 10^lt;
    C_max(k) = t_adm/t_por_F(k);
    fprintf('   %s: V_DS %.1f V, I %.2f A, P %.1f W; admite %.1f ms -> C_TMR <= %.0f nF\n', nom{k}, V_c(k), I_c(k), P_c(k), t_adm*1e3, C_max(k)*1e9);
end
C_TMR = max(serie(serie <= min(C_max)));
t_f = C_TMR*t_por_F;
t_warn = C_TMR*0.1/L.I_warn;
t_cool = 63*C_TMR*1.2/L.I_cool;
TJ_f = T_A + P_c.*Z(2*t_f);
fprintf('   Se adopta C_TMR = %.0f nF (serie E6)\n', C_TMR*1e9);
for k = 1:3
    fprintf('   %s: %.1f ms; T_J con la duracion duplicada %.0f C\n', nom{k}, t_f(k)*1e3, TJ_f(k));
end
fprintf('   Aviso previo %.1f ms; enfriamiento antes del reintento %.1f s; ciclo de reintento %.3f %%\n\n', t_warn*1e3, t_cool, t_f(3)/t_cool*100);

%% 8. Comprobaciones de M1 y M2
V_DS_M1 = V_in_pk;          % salida en cortocircuito con la entrada en su maximo
V_DS_M2 = V_fb(3);          % entrada en cortocircuito con la salida sostenida
fprintf('8. Comprobaciones del FDMS86150\n');
fprintf('   M1: V_DS %.1f V <= %.0f V: %s; M2: %.1f V <= %.0f V: %s\n', V_DS_M1, F.V_DS, ok(V_DS_M1 <= F.V_DS), V_DS_M2, F.V_DS, ok(V_DS_M2 <= F.V_DS));
fprintf('   Compuerta: excitacion de %.0f a %.0f V (Zener de 15 V) dentro de +-%.0f V: %s; umbral de %.0f a %.0f V (nivel estandar)\n', L.dV_hg(1), L.dV_hg(3), F.V_GS, ok(L.dV_hg(3) <= F.V_GS), F.Vth(1), F.Vth(2));
P_cond = I_carga^2*F.Rds_125;
fprintf('   Conduccion: %.1f mW por MOSFET con %.1f mohm; elevacion %.2f C con %.0f C/W\n\n', P_cond*1e3, F.Rds_125*1e3, P_cond*F.R_JA, F.R_JA);

%% 9. Resumen
fprintf('=== RESUMEN ===\n');
fprintf('Divisores: UV %.2f V, reconexion %.2f V, OV %.2f V, FB %.2f V; correctos.\n', V_uv(2), V_uvr(2), V_ov(2), V_fb(2));
fprintf('R_SNS = %.0f mohm: limite %.2f a %.2f A (carga %.2f A); %.2f a %.2f A con la salida en cortocircuito.\n', R_sns*1e3, I_lim(1), I_lim(3), I_carga, I_lim_0(1), I_lim_0(3));
fprintf('C_HG = %.0f nF: arranque de %.2f a %.2f A en %.0f a %.0f ms; T_J maxima %.0f C.\n', C_HG*1e9, I_inr(1), I_inr(3), T_arr(3)*1e3, T_arr(1)*1e3, max(TJ_arr));
fprintf('C_TMR = %.0f nF: sobrecarga %.1f ms, cortocircuito %.1f ms, sobretension %.1f ms; enfriamiento %.1f s.\n', C_TMR*1e9, t_f(3)*1e3, t_f(2)*1e3, t_f(1)*1e3, t_cool);
fprintf('M1 y M2: FDMS86150 (100 V); cumplen.\n');

R = struct();
R.V_uv = V_uv; R.V_uvr = V_uvr; R.V_ov = V_ov; R.V_fb = V_fb; R.R_sns = R_sns;
R.I_lim = I_lim; R.I_lim_0 = I_lim_0; R.C_HG = C_HG; R.I_inrush = I_inr; R.T_arr = T_arr; R.TJ_arr = TJ_arr; R.C_L = C_L; R.P_met_arranque = P_met;
R.C_TMR = C_TMR; R.C_TMR_max = C_max; R.t_falla = t_f; R.P_falla = P_c; R.TJ_falla = TJ_f;
R.t_warn = t_warn; R.t_cool = t_cool;
R.V_DS_M1 = V_DS_M1; R.V_DS_M2 = V_DS_M2; R.I_carga = I_carga;
save('limitador_electrico.mat', 'R');
