%% MEMORIA 05 - Convertidor TPS54540 de 5.0 V
% Limites de frecuencia, bobina, condensadores de salida (rizado de 1 %) y de entrada,
% condensador de arranque (BOOT), red de compensacion, diodo y disipacion, siguiendo el
% procedimiento de diseno de la hoja de datos (TFC/cap6/606, PENDIENTE del TPS54540).
%
% Fuente: hoja de datos TPS54540, Texas Instruments, SLVSBX7B (marzo de 2017): caracteristicas
% electricas y Detailed Design Procedure. Datos del circuito: 606 y memoria 01.
clear; clc;
run('parametros_electrico.m');
load('demanda_electrico.mat', 'D');
load('limitador_electrico.mat', 'R'); R03 = R; clear R;
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 05: CONVERTIDOR TPS54540 DE 5.0 V ===\n\n');

%% 0. Datos
T.Vref = 0.8; T.gmea = 350e-6; T.gmps = 17;   % V, A/V (error), A/V (potencia)
T.Rds = [92e-3 190e-3];                       % ohm, MOSFET del lado alto (tipico, maximo)
T.Ilim = [6.3 7.5 8.8];                       % A, limite de corriente
T.ton_min = 135e-9;                           % s, tiempo minimo de conduccion tipico
T.Qg = 3e-9; T.Iq = 146e-6;                   % C, A
T.R_JA = 42.0;                                % C/W, placa normalizada
T.C_in_eff_min = 3e-6;                        % F, ceramico de entrada efectivo minimo
T.C_boot = 0.1e-6;                            % F
V_out = 5.0; f_sw = 500e3; f_sw_rng = [450e3 550e3];
V_in_min = R03.V_uv(2);                       % V, corte del LTC4364
V_in_max = R03.V_fb(3);                       % V, limitacion maxima del LTC4364
I_dis = 5.0;                                  % A, corriente de diseno de 606 (maxima del TPS54540)
I_real = D.I_5V_max;                          % A, demanda maxima de la linea (memoria 01)
L_o = 6.8e-6; I_sat_L = 8.5;                  % H, A (606)
% Diodo PDS760 (Diodes Inc., DS30477 Rev. 14-2; decision del usuario, 2026-11-15): 60 V, 7 A medios;
% caida a 3.5 A de 0.48 V tipica y 0.54 V maxima a 25 C (0.47 V maxima a 125 C); fuga maxima de
% 20 mA a 60 V y 125 C; resistencia termica union-ambiente de 45, 70 u 85 C/W segun el cobre.
D7.V_R = 60; D7.I_o = 7; D7.R_JA = [45 70 85];
V_d = 0.48;            % V, tipica (para las ecuaciones de frecuencia, como en el ejemplo)
V_d_max = 0.54;        % V, maxima a 3.5 A y 25 C (para la disipacion)
I_R_max = 20e-3;       % A, fuga maxima a 60 V y 125 C (cota)
% SUPOSICION: capacidad del diodo de 200 pF, leida de la Fig. 4 entre 20 y 30 V.
C_j = 200e-12;
% SUPOSICION: resistencia de la bobina de 20 mohm, hasta elegirla.
R_dc = 20e-3;
fprintf('0. Entrada de %.2f a %.2f V; salida %.1f V; corriente de diseno %.1f A (demanda maxima %.2f A)\n\n', V_in_min, V_in_max, V_out, I_dis, I_real);

%% 1. Limites de la frecuencia de conmutacion
f_skip  = 1/T.ton_min*(I_dis*R_dc + V_out + V_d)/(V_in_max - I_dis*T.Rds(1) + V_d);
f_shift = 8/T.ton_min*(T.Ilim(1)*R_dc + 0.1 + V_d)/(V_in_max - T.Ilim(1)*T.Rds(1) + V_d);
fprintf('1. Frecuencia maxima sin saltos de pulso: %.0f kHz; para la proteccion por cortocircuito: %.0f kHz\n', f_skip/1e3, f_shift/1e3);
fprintf('   %.0f kHz (maximo %.0f kHz) por debajo de ambas: %s\n\n', f_sw/1e3, f_sw_rng(2)/1e3, ok(f_sw_rng(2) < min(f_skip, f_shift)));

%% 2. Bobina
K_ind = 0.3;
L_min = (V_in_max - V_out)/(I_dis*K_ind)*V_out/(V_in_max*f_sw);
I_rip = V_out*(V_in_max - V_out)/(V_in_max*L_o*f_sw);
I_L_rms = sqrt(I_dis^2 + I_rip^2/12);
I_L_pk = I_dis + I_rip/2;
fprintf('2. Bobina (K_IND = %.1f, entrada maxima): minima %.2f uH; se emplea %.1f uH (606)\n', K_ind, L_min*1e6, L_o*1e6);
fprintf('   Rizado %.2f A (K = %.2f); eficaz %.2f A; pico %.2f A\n', I_rip, I_rip/I_dis, I_L_rms, I_L_pk);
fprintf('   Saturacion %.1f A >= pico: %s; >= limite nominal del interruptor (%.1f A): %s; limite maximo %.1f A\n\n', I_sat_L, ok(I_sat_L >= I_L_pk), T.Ilim(2), ok(I_sat_L >= T.Ilim(2)), T.Ilim(3));

%% 3. Condensador de salida
% Criterio acordado: rizado de salida de 1 %.
dV_rip = 0.01*V_out;
C_rip = 1/(8*f_sw*(dV_rip/I_rip));
ESR_max = dV_rip/I_rip;
% Respuesta a un escalon de carga del 25 al 75 % de la corriente de diseno con una variacion de
% 4 %, la especificacion del ejemplo de la hoja de datos (decision del usuario, 2026-11-15).
dI = 0.5*I_dis; dV_tr = 0.04*V_out;
C_step = 2*dI/(f_sw*dV_tr);
I_OH = 0.75*I_dis; I_OL = 0.25*I_dis;
C_over = L_o*(I_OH^2 - I_OL^2)/((1.04*V_out)^2 - V_out^2);
C_req = max([C_rip C_step C_over]);
% SUPOSICION: ceramicos X5R/X7R con ESR de 2 mohm cada uno y 65 % de la capacidad nominal tras
% la tension continua, la temperatura y el envejecimiento (como el ejemplo: 130 uF de 200 uF).
k_der = 0.65; ESR_ce = 2e-3;
opc = [47 2*47 100 2*100 3*100]*1e-6;
C_nom = min(opc(opc*k_der >= C_req));
n_cap = round(C_nom/(47e-6*(mod(C_nom,100e-6) ~= 0) + 100e-6*(mod(C_nom,100e-6) == 0)));
C_eff = C_nom*k_der;
I_Cout = I_rip/sqrt(12);
fprintf('3. Condensador de salida\n');
fprintf('   Rizado de 1 %% (%.0f mV): C >= %.1f uF y ESR <= %.0f mohm\n', dV_rip*1e3, C_rip*1e6, ESR_max*1e3);
fprintf('   Escalon de %.2f A con 4 %%: C >= %.1f uF; sobretension al quitar la carga: C >= %.1f uF\n', dI, C_step*1e6, C_over*1e6);
fprintf('   Requerido %.1f uF efectivos; se adoptan %.0f uF nominales (%.0f uF efectivos), ceramicos de 10 V o mas\n', C_req*1e6, C_nom*1e6, C_eff*1e6);
dV_out = I_rip/(8*f_sw*C_eff) + I_rip*ESR_ce/2;
fprintf('   Rizado resultante: %.1f mV (%.2f %%); corriente eficaz %.2f A\n\n', dV_out*1e3, dV_out/V_out*100, I_Cout);

%% 4. Condensador de entrada
I_Cin = I_dis*sqrt(V_out/V_in_min*(V_in_min - V_out)/V_in_min);
I_Cin_real = I_real*sqrt(V_out/V_in_min*(V_in_min - V_out)/V_in_min);
% SUPOSICION: los X7R de 50 V conservan el 50 % de su capacidad con la tension de la linea.
k_in = 0.5; C_in_nom = 2*4.7e-6; C_in_eff = k_in*C_in_nom;
dV_in = I_dis*0.25/(C_in_eff*f_sw);
fprintf('4. Condensador de entrada: ceramico X5R/X7R, al menos %.0f uF efectivos, tension nominal > %.1f V\n', T.C_in_eff_min*1e6, V_in_max);
fprintf('   Corriente eficaz %.2f A con %.1f A (%.2f A con la demanda maxima), a %.2f V\n', I_Cin, I_dis, I_Cin_real, V_in_min);
fprintf('   Se adoptan 2 x 4.7 uF, 50 V, X7R: %.1f uF efectivos: %s; rizado de entrada %.0f mV con %.1f A\n\n', C_in_eff*1e6, ok(C_in_eff >= T.C_in_eff_min), dV_in*1e3, I_dis);

%% 5. Condensador de arranque (BOOT)
fprintf('5. BOOT: %.1f uF ceramico X5R o mejor, 10 V o mas (hoja de datos)\n\n', T.C_boot*1e6);

%% 6. Compensacion
f_p = I_dis/(2*pi*V_out*C_eff);
ESR_out = ESR_ce/n_cap;
f_z = 1/(2*pi*ESR_out*C_eff);
f_co1 = sqrt(f_p*f_z); f_co2 = sqrt(f_p*f_sw/2); f_co = sqrt(f_co1*f_co2);
R_c = 2*pi*f_co*C_eff/T.gmps*V_out/(T.Vref*T.gmea);
E24 = [1 1.1 1.2 1.3 1.5 1.6 1.8 2.0 2.2 2.4 2.7 3.0 3.3 3.6 3.9 4.3 4.7 5.1 5.6 6.2 6.8 7.5 8.2 9.1];
E24s = reshape(E24'*10.^(-13:6), 1, []);
cerca = @(x, s) s(find(abs(log(s/x)) == min(abs(log(s/x))), 1));
R_c_n = cerca(R_c, E24s);
C_c = 1/(2*pi*R_c_n*f_p);
E12 = [1 1.2 1.5 1.8 2.2 2.7 3.3 3.9 4.7 5.6 6.8 8.2];
E12s = reshape(E12'*10.^(-13:-3), 1, []);
C_c_n = cerca(C_c, E12s);
C_p = max(C_eff*ESR_out/R_c_n, 1/(R_c_n*f_sw*pi));
C_p_n = cerca(C_p, E12s);
fprintf('6. Compensacion (salida de %.0f uF efectivos, ESR %.1f mohm)\n', C_eff*1e6, ESR_out*1e3);
fprintf('   Polo del modulador %.2f kHz; cero de la ESR %.0f kHz\n', f_p/1e3, f_z/1e3);
fprintf('   Cruce: %.1f kHz y %.1f kHz -> media geometrica %.1f kHz\n', f_co1/1e3, f_co2/1e3, f_co/1e3);
fprintf('   R_COMP = %.1f kohm -> %.1f kohm; C_COMP = %.2f nF -> %.2f nF; C_POLO = %.1f pF -> %.0f pF\n\n', R_c/1e3, R_c_n/1e3, C_c*1e9, C_c_n*1e9, C_p*1e12, C_p_n*1e12);

%% 7. Diodo
% Disipacion (hoja de datos del TPS54540) mas la fuga durante la conduccion del interruptor.
P_D = @(Vin, I) (Vin - V_out)*I*V_d_max/Vin + C_j*f_sw*(Vin + V_d_max)^2/2 + Vin*I_R_max*V_out/Vin;
I_D_med = I_real*(1 - V_out/V_in_max);
fprintf('7. Diodo PDS760: %.0f V >= %.1f V (y >= 42 V, preferido): %s; %.0f A >= pico %.2f A: %s\n', D7.V_R, V_in_max, ok(D7.V_R >= max(V_in_max, 42)), D7.I_o, I_L_pk, ok(D7.I_o >= I_L_pk));
fprintf('   Corriente media %.2f A con %.2f A de salida y la entrada maxima\n', I_D_med, I_real);
fprintf('   Disipacion: %.2f W a %.2f V y %.2f W a %.2f V con %.2f A\n', P_D(V_in_max, I_real), V_in_max, P_D(V_in_min, I_real), V_in_min, I_real);
TJ_D = E.T_int + P_D(V_in_max, I_real)*D7.R_JA;
fprintf('   Union con %.0f C de ambiente: %.0f C (%.0f C/W), %.0f C (%.0f C/W), %.0f C (%.0f C/W); maxima 150 C\n\n', E.T_int, TJ_D(1), D7.R_JA(1), TJ_D(2), D7.R_JA(2), TJ_D(3), D7.R_JA(3));

%% 8. Disipacion del TPS54540 y tension minima de entrada
P_ic = @(Vin, I) I^2*T.Rds(1)*V_out/Vin + Vin*f_sw*I*(Vin*0.16e-9 + 3e-9) + Vin*T.Qg*f_sw + Vin*T.Iq;
fprintf('8. Disipacion del integrado con %.2f A: %.2f W a %.2f V; %.2f W a %.2f V\n', I_real, P_ic(V_in_min, I_real), V_in_min, P_ic(V_in_max, I_real), V_in_max);
TJ = E.T_int + P_ic(V_in_max, I_real)*T.R_JA;
fprintf('   Temperatura de la union con %.0f C/W y %.0f C de ambiente: %.0f C (maxima 150 C): %s\n', T.R_JA, E.T_int, TJ, ok(TJ < 150));
V_in_req = (V_out + V_d + R_dc*I_dis)/0.99 + 0.12*I_dis - V_d;
fprintf('   Entrada minima para regular con %.1f A: %.2f V, por debajo de %.2f V: %s\n\n', I_dis, V_in_req, V_in_min, ok(V_in_req < V_in_min));

%% 8b. Habilitacion: divisor en EN y salida ENOUT del LTC4364
% Decision del usuario (2026-11-15): la salida ENOUT del LTC4364 (drenador abierto) se conecta a EN,
% de modo que el convertidor arranca cuando el limitador termina de cargar los condensadores.
% EN admite como maximo 8.4 V y su corriente interna (1.2 uA) puede ser menor que la fuga de ENOUT
% (hasta 2.5 uA), por lo que se agrega el divisor de subtension de la hoja de datos desde la linea.
% Criterios: arranque y parada del TPS54540 por debajo del corte minimo del LTC4364, para que
% el arranque lo controle ENOUT; EN por debajo de 8.4 V con la entrada maxima; resistencia
% superior de al menos 100 kohm (recomendacion del LTC4364 para el pull-up de ENOUT); corriente del
% divisor mucho mayor que la fuga de ENOUT.
% SUPOSICION: arranque a 18 V y parada a 16 V.
EN.V_ena = [1.1 1.2 1.3]; EN.I1 = [0.58 1.2 1.8]*1e-6; EN.Ihys = [2.2 3.4 4.5]*1e-6;
EN.V_max = 8.4; I_fuga_ENOUT = 2.5e-6;
V_start = 18; V_stop = 16;
R_u1 = (V_start - V_stop)/EN.Ihys(2);
R_u2 = EN.V_ena(2)/((V_start - EN.V_ena(2))/R_u1 + EN.I1(2));
R_u1n = cerca(R_u1, E24s); R_u2n = cerca(R_u2, E24s);
% Umbrales con los valores normalizados y las tolerancias de EN
Vst = @(Ve, I1) Ve*(1 + R_u1n/R_u2n) - I1*R_u1n;
Vsp = @(Ve, I1, Ih) Ve*(1 + R_u1n/R_u2n) - (I1 + Ih)*R_u1n;
st = [Vst(EN.V_ena(1), EN.I1(3)), Vst(EN.V_ena(2), EN.I1(2)), Vst(EN.V_ena(3), EN.I1(1))];
sp = [Vsp(EN.V_ena(1), EN.I1(3), EN.Ihys(3)), Vsp(EN.V_ena(2), EN.I1(2), EN.Ihys(2)), Vsp(EN.V_ena(3), EN.I1(1), EN.Ihys(1))];
% Tension de EN con la entrada maxima (habilitado: circulan I1 + Ihys hacia afuera de EN)
V_EN_max = (V_in_max/R_u1n + EN.I1(3) + EN.Ihys(3))/(1/R_u1n + 1/R_u2n);
I_div = EN.V_ena(1)/R_u2n;
fprintf('8b. EN: divisor %.0f kohm (a la linea) y %.1f kohm (a tierra); ENOUT del LTC4364 a EN\n', R_u1n/1e3, R_u2n/1e3);
fprintf('   Arranque %.1f V (%.1f a %.1f V); parada %.1f V (%.1f a %.1f V)\n', st(2), st(1), st(3), sp(2), sp(1), sp(3));
fprintf('   Arranque maximo por debajo del corte minimo del LTC4364 (%.2f V): %s\n', R03.V_uv(1), ok(st(3) < R03.V_uv(1)));
fprintf('   EN con la entrada maxima: %.2f V <= %.1f V: %s\n', V_EN_max, EN.V_max, ok(V_EN_max <= EN.V_max));
fprintf('   Resistencia superior >= 100 kohm: %s; corriente del divisor en el umbral %.1f uA (%.0f veces la fuga de ENOUT)\n\n', ok(R_u1n >= 100e3), I_div*1e6, I_div/I_fuga_ENOUT);

%% 9. Resumen
fprintf('=== RESUMEN ===\n');
fprintf('Bobina %.1f uH: rizado %.2f A, pico %.2f A; saturacion %.1f A.\n', L_o*1e6, I_rip, I_L_pk, I_sat_L);
fprintf('Salida: %.0f uF nominales (%.0f efectivos), rizado %.1f mV.\n', C_nom*1e6, C_eff*1e6, dV_out*1e3);
fprintf('Entrada: 2 x 4.7 uF, 50 V, X7R. BOOT: 0.1 uF.\n');
fprintf('Compensacion: %.1f kohm, %.2f nF, %.0f pF; cruce %.1f kHz.\n', R_c_n/1e3, C_c_n*1e9, C_p_n*1e12, f_co/1e3);

R = struct('L', L_o, 'I_rip', I_rip, 'I_L_pk', I_L_pk, 'C_out_nom', C_nom, 'C_out_eff', C_eff, ...
    'dV_out', dV_out, 'C_in_nom', C_in_nom, 'C_in_eff', C_in_eff, 'I_Cin', I_Cin, 'C_boot', T.C_boot, ...
    'R_comp', R_c_n, 'C_comp', C_c_n, 'C_polo', C_p_n, 'f_co', f_co, 'f_p', f_p, ...
    'R_en1', R_u1n, 'R_en2', R_u2n, 'V_start', st, 'V_stop', sp, 'V_EN_max', V_EN_max, 'P_D', P_D(V_in_max, I_real), 'TJ_D', TJ_D, ...
    'P_ic', P_ic(V_in_max, I_real), 'TJ', TJ, 'V_R_diodo', V_in_max, 'f_skip', f_skip, 'f_shift', f_shift);
save('buck5V_electrico.mat', 'R');
