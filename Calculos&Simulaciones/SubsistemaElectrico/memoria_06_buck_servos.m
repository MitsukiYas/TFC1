%% MEMORIA 06 - Convertidor TPS54560 de 6.5 V para los servomotores
% Limites de frecuencia, bobina, condensadores de salida (rizado de 1 %, escalon de carga y rango
% de los servomotores) y de entrada, BOOT, compensacion con salida electrolitica, diodo PDS760 y
% disipacion, siguiendo el procedimiento de la hoja de datos (TFC/cap6/606, PENDIENTE del TPS54560).
%
% Fuentes: hoja de datos TPS54560, Texas Instruments, SLVSBN0C (marzo de 2017); PDS760, Diodes Inc.,
% DS30477 Rev. 14-2; SAMXON GT; datos del circuito de 603 y 606 y memoria 01.
clear; clc;
run('parametros_electrico.m');
load('demanda_electrico.mat', 'D');
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 06: CONVERTIDOR TPS54560 DE 6.5 V (SERVOMOTORES) ===\n\n');

%% 0. Datos
T.Vref = [0.792 0.8 0.808]; T.gmea = 350e-6; T.gmps = 17;   % V, A/V, A/V
T.Rds = [92e-3 190e-3];                       % ohm, MOSFET del lado alto (tipico, maximo)
T.Ilim = [6.3 7.5 8.8];                       % A
T.ton_min = 135e-9;                           % s, tipico
T.Qg = 3e-9; T.Iq = 146e-6; T.R_JA = 42.0;    % C, A, C/W
T.C_in_eff_min = 3e-6;                        % F
T.C_boot = 0.1e-6;                            % F
V_out = 0.8*(1 + 14.3/2.0);                   % V, red de 14.3 kohm y 2 kohm (606)
V_out_rng = [6.34 6.70];                      % V, con las tolerancias (606)
V_serv = [4.8 6.8];                           % V, rango de operacion del RDS3225 (606)
f_sw = 500e3; f_sw_rng = [450e3 550e3];
V_in_min = E.bat.V_min;                       % V, barra de actuadores con la bateria agotada
V_in_nom = E.bat.V_max;                       % V, mayor tension sostenida (606 dimensiona con ella)
V_in_pk  = E.tvs.V_C;                         % V, limitacion de los TVS de la barra (transitoria)
I_dis = 5.0;                                  % A, corriente de diseno de 606
I_real = D.I_6V5_max;                         % A, ambos servomotores en bloqueo (memoria 01)
L_o = 6.8e-6; I_sat_L = 8.5;                  % H, A (606: el mismo inductor del convertidor de 5.0 V)
% SUPOSICION: los dos electroliticos de salida son SAMXON GT de 470 uF y 50 V, el modelo usado en el
% resto del diseno: impedancia maxima 0.043 ohm a 100 kHz, tolerancia +-20 %, rizado admisible 1.69 A
% a 105 C (x2.23 por debajo de 55 C).
C_el = 470e-6; ESR_el = 0.043; I_rip_el = 1.69*2.23;
C_o = 2*C_el; ESR_o = ESR_el/2;
% Diodo PDS760: 60 V, 7 A medios; caida maxima a 25 C de 0.54 V a 3.5 A y 0.62 V a 7 A
% (0.47 y 0.56 V a 125 C); fuga maxima 20 mA a 60 V y 125 C; 45, 70 u 85 C/W segun el cobre.
D7.V_R = 60; D7.I_o = 7; D7.R_JA = [45 70 85];
Vf25 = @(I) interp1([3.5 7], [0.54 0.62], I, 'linear', 'extrap');
Vf125 = @(I) interp1([3.5 7], [0.47 0.56], I, 'linear', 'extrap');
I_R_max = 20e-3;
% SUPOSICION: capacidad del diodo de 200 pF (Fig. 4 del PDS760, de 20 a 30 V) y resistencia de la
% bobina de 20 mohm.
C_j = 200e-12; R_dc = 20e-3;
fprintf('0. Salida %.2f V (%.2f a %.2f V); entrada %.1f a %.1f V (transitoria %.1f V)\n', V_out, V_out_rng(1), V_out_rng(2), V_in_min, V_in_nom, V_in_pk);
fprintf('   Corriente de diseno %.1f A; servomotores en bloqueo %.2f A\n\n', I_dis, I_real);

%% 1. Limites de la frecuencia de conmutacion (con la entrada transitoria maxima)
f_skip  = 1/T.ton_min*(I_dis*R_dc + V_out + Vf25(I_dis))/(V_in_pk - I_dis*T.Rds(1) + Vf25(I_dis));
f_shift = 8/T.ton_min*(T.Ilim(1)*R_dc + 0.1 + Vf25(T.Ilim(1)))/(V_in_pk - T.Ilim(1)*T.Rds(1) + Vf25(T.Ilim(1)));
fprintf('1. Con %.1f V: sin saltos de pulso hasta %.0f kHz; proteccion por cortocircuito hasta %.0f kHz\n', V_in_pk, f_skip/1e3, f_shift/1e3);
fprintf('   %.0f kHz (maximo) por debajo de ambas: %s\n\n', f_sw_rng(2)/1e3, ok(f_sw_rng(2) < min(f_skip, f_shift)));

%% 2. Bobina
K_ind = 0.3;
L_min = (V_in_nom - V_out)/(I_dis*K_ind)*V_out/(V_in_nom*f_sw);
I_rip = V_out*(V_in_nom - V_out)/(V_in_nom*L_o*f_sw);
I_L_pk = I_dis + I_rip/2; I_L_pk_real = I_real + I_rip/2;
fprintf('2. Bobina: minima %.2f uH con %.1f V; %.1f uH: rizado %.2f A (K = %.2f); pico %.2f A (%.2f A con los servos)\n', L_min*1e6, V_in_nom, L_o*1e6, I_rip, I_rip/I_dis, I_L_pk, I_L_pk_real);
fprintf('   Saturacion %.1f A >= limite nominal del interruptor (%.1f A): %s\n\n', I_sat_L, T.Ilim(2), ok(I_sat_L >= T.Ilim(2)));

%% 3. Condensador de salida (2 x 470 uF electroliticos + 100 nF ceramicos, 606)
dV_rip = 0.01*V_out;
C_rip = 1/(8*f_sw*(dV_rip/I_rip)); ESR_rip = dV_rip/I_rip;
% Respuesta transitoria: especificacion del ejemplo de la hoja de datos (escalon del 25 al 75 % de
% la corriente maxima con 4 %), la misma adoptada para el TPS54540.
dI = 0.5*I_dis; dV_tr = 0.04*V_out;
C_step = 2*dI/(f_sw*dV_tr);
C_over = L_o*((0.75*I_dis)^2 - (0.25*I_dis)^2)/((1.04*V_out)^2 - V_out^2);
dV_step_ESR = dI*ESR_o;
C_min = C_o*(1 - 0.20);
fprintf('3. Salida: %.0f uF (%.0f uF con -20 %%), ESR %.1f mohm\n', C_o*1e6, C_min*1e6, ESR_o*1e3);
fprintf('   Rizado de 1 %% (%.0f mV): C >= %.1f uF y ESR <= %.1f mohm: %s\n', dV_rip*1e3, C_rip*1e6, ESR_rip*1e3, ok(C_min >= C_rip && ESR_o <= ESR_rip));
dV_out = I_rip*sqrt(ESR_o^2 + (1/(8*f_sw*C_min))^2);
fprintf('   Rizado resultante %.1f mV (%.2f %%)\n', dV_out*1e3, dV_out/V_out*100);
fprintf('   Escalon de %.1f A con 4 %% (%.0f mV): C >= %.1f uF; sobretension C >= %.1f uF; caida en la ESR %.0f mV: %s\n', dI, dV_tr*1e3, C_step*1e6, C_over*1e6, dV_step_ESR*1e3, ok(C_min >= max(C_step, C_over) && dV_step_ESR < dV_tr));
% Rango de los servomotores con el escalon completo (de 0 a ambos en bloqueo y viceversa)
dV_baja = I_real*ESR_o + 2*I_real/(f_sw*C_min);
Vf_sob = sqrt(V_out_rng(2)^2 + L_o*I_real^2/C_min);
dV_sube = max(I_real*ESR_o, Vf_sob - V_out_rng(2));
fprintf('   Escalon de 0 a %.1f A: minimo %.2f V (>= %.1f V: %s); al retirarlo, maximo %.3f V (<= %.1f V: %s)\n', I_real, V_out_rng(1) - dV_baja, V_serv(1), ok(V_out_rng(1) - dV_baja >= V_serv(1)), V_out_rng(2) + dV_sube, V_serv(2), ok(V_out_rng(2) + dV_sube <= V_serv(2)));
I_Cout = I_rip/sqrt(12);
fprintf('   Corriente eficaz %.2f A, por debajo de %.2f A admisibles por condensador a 50 C: %s\n\n', I_Cout, I_rip_el, ok(I_Cout/2 < I_rip_el));

%% 4. Condensador de entrada
% Tension nominal mayor que la entrada maxima: la barra llega a 48.4 V con los TVS, por lo que se
% emplean ceramicos de 100 V. SUPOSICION: conservan el 50 % de su capacidad con la tension continua.
C_in_nom = 4*2.2e-6; C_in_eff = 0.5*C_in_nom;
I_Cin = I_dis*sqrt(V_out/V_in_min*(V_in_min - V_out)/V_in_min);
dV_in = I_dis*0.25/(C_in_eff*f_sw);
fprintf('4. Entrada: 4 x 2.2 uF, 100 V, X7R: %.1f uF efectivos >= %.0f uF: %s\n', C_in_eff*1e6, T.C_in_eff_min*1e6, ok(C_in_eff >= T.C_in_eff_min));
fprintf('   Corriente eficaz %.2f A con %.1f A a %.1f V; rizado de entrada %.0f mV\n\n', I_Cin, I_dis, V_in_min, dV_in*1e3);

%% 5. BOOT
fprintf('5. BOOT: %.1f uF ceramico X5R o mejor, 10 V o mas\n\n', T.C_boot*1e6);

%% 6. Compensacion (con la capacidad nominal)
f_p = I_dis/(2*pi*V_out*C_o);
f_z = 1/(2*pi*ESR_o*C_o);
f_co1 = sqrt(f_p*f_z); f_co2 = sqrt(f_p*f_sw/2); f_co = sqrt(f_co1*f_co2);
R_c = 2*pi*f_co*C_o/T.gmps*V_out/(T.Vref(2)*T.gmea);
E24 = [1 1.1 1.2 1.3 1.5 1.6 1.8 2.0 2.2 2.4 2.7 3.0 3.3 3.6 3.9 4.3 4.7 5.1 5.6 6.2 6.8 7.5 8.2 9.1];
E24s = reshape(E24'*10.^(-13:6), 1, []);
E12 = [1 1.2 1.5 1.8 2.2 2.7 3.3 3.9 4.7 5.6 6.8 8.2];
E12s = reshape(E12'*10.^(-13:-3), 1, []);
cerca = @(x, s) s(find(abs(log(s/x)) == min(abs(log(s/x))), 1));
R_c_n = cerca(R_c, E24s);
C_c = 1/(2*pi*R_c_n*f_p); C_c_n = cerca(C_c, E12s);
C_p = max(C_o*ESR_o/R_c_n, 1/(R_c_n*f_sw*pi)); C_p_n = cerca(C_p, E12s);
fprintf('6. Compensacion: polo del modulador %.0f Hz; cero de la ESR %.2f kHz (%.0f veces el polo)\n', f_p, f_z/1e3, f_z/f_p);
fprintf('   Cruce: %.2f y %.2f kHz -> %.2f kHz, entre el polo y el cero: %s\n', f_co1/1e3, f_co2/1e3, f_co/1e3, ok(f_co > f_p && f_co < f_z));
fprintf('   R_COMP %.1f -> %.1f kohm; C_COMP %.1f -> %.0f nF; C_POLO %.0f pF -> %.0f pF (C_o*ESR/R)\n\n', R_c/1e3, R_c_n/1e3, C_c*1e9, C_c_n*1e9, C_p*1e12, C_p_n*1e12);

%% 6b. Escalon completo con el ancho de banda del lazo
% Las ecuaciones de la hoja de datos suponen que el lazo responde en dos ciclos de conmutacion.
% Con el cruce de unos pocos kHz que permite la salida electrolitica, la variacion se estima con la
% aproximacion usual dV ~ dI/(2 pi f_c C) mas la caida en la ESR (estimacion, sin fuente citada).
dV_lazo = I_real/(2*pi*f_co*C_min) + I_real*ESR_o;
fprintf('6b. Escalon de 0 a %.1f A con el cruce de %.2f kHz: variacion de unos %.2f V\n', I_real, f_co/1e3, dV_lazo);
fprintf('   Minimo %.2f V (>= %.1f V: %s); maximo al retirar la carga %.2f V (<= %.1f V: %s)\n', V_out_rng(1) - dV_lazo, V_serv(1), ok(V_out_rng(1) - dV_lazo >= V_serv(1)), V_out_rng(2) + dV_lazo, V_serv(2), ok(V_out_rng(2) + dV_lazo <= V_serv(2)));
fprintf('   Con la salida nominal (%.2f V): maximo %.2f V\n\n', V_out, V_out + dV_lazo);

%% 7. Diodo PDS760
I_D_med = I_real*(1 - V_out/V_in_nom);
P_D = @(Vin, I, Vf) (Vin - V_out)*I*Vf/Vin + C_j*f_sw*(Vin + Vf)^2/2 + Vin*I_R_max*V_out/Vin;
P_D25 = P_D(V_in_nom, I_real, Vf25(I_real)); P_D125 = P_D(V_in_nom, I_real, Vf125(I_real));
TJ25 = E.T_int + P_D25*D7.R_JA; TJ125 = E.T_int + P_D125*D7.R_JA;
fprintf('7. Diodo PDS760: %.0f V >= %.1f V: %s; %.0f A >= pico %.2f A: %s\n', D7.V_R, V_in_pk, ok(D7.V_R >= V_in_pk), D7.I_o, I_L_pk, ok(D7.I_o >= I_L_pk));
fprintf('   Con los servos en bloqueo (%.2f A) y %.1f V: corriente media %.2f A\n', I_real, V_in_nom, I_D_med);
fprintf('   Disipacion %.2f W con la caida maxima a 25 C (%.3f V) y %.2f W a 125 C (%.3f V)\n', P_D25, Vf25(I_real), P_D125, Vf125(I_real));
fprintf('   Union con 45 C/W: %.0f C y %.0f C; con 70 C/W: %.0f C y %.0f C (maxima 150 C)\n', TJ25(1), TJ125(1), TJ25(2), TJ125(2));
fprintf('   Ese caso supone ambos servomotores en bloqueo de forma continua; en reposo toman %.0f mA.\n\n', D.I_6V5_rep*1e3);

%% 8. Disipacion del TPS54560 y tension minima
P_ic = @(Vin, I) I^2*T.Rds(1)*V_out/Vin + Vin*f_sw*I*(Vin*0.16e-9 + 3e-9) + Vin*T.Qg*f_sw + Vin*T.Iq;
P_ic_max = max(P_ic(V_in_min, I_real), P_ic(V_in_nom, I_real));
TJ_ic = E.T_int + P_ic_max*T.R_JA;
V_in_req = (V_out + Vf25(I_dis) + R_dc*I_dis)/0.99 + 0.12*I_dis - Vf25(I_dis);
fprintf('8. Integrado con %.2f A: %.2f W a %.1f V y %.2f W a %.1f V; union %.0f C: %s\n', I_real, P_ic(V_in_min, I_real), V_in_min, P_ic(V_in_nom, I_real), V_in_nom, TJ_ic, ok(TJ_ic < 150));
fprintf('   Entrada minima para regular con %.1f A: %.2f V, por debajo de %.1f V: %s\n\n', I_dis, V_in_req, V_in_min, ok(V_in_req < V_in_min));

%% 9. Resumen
fprintf('=== RESUMEN ===\n');
fprintf('Bobina %.1f uH: rizado %.2f A, pico %.2f A.\n', L_o*1e6, I_rip, I_L_pk);
fprintf('Salida 2 x 470 uF: rizado %.0f mV; servos entre %.2f y %.3f V con el escalon completo.\n', dV_out*1e3, V_out_rng(1) - dV_baja, V_out_rng(2) + dV_sube);
fprintf('Entrada 4 x 2.2 uF 100 V; BOOT 0.1 uF; compensacion %.1f kohm, %.0f nF, %.0f pF; cruce %.2f kHz.\n', R_c_n/1e3, C_c_n*1e9, C_p_n*1e12, f_co/1e3);
fprintf('PDS760: %.2f W en bloqueo continuo; union %.0f C con 45 C/W.\n', P_D25, TJ25(1));

R = struct('V_out', V_out, 'I_rip', I_rip, 'I_L_pk', I_L_pk, 'dV_out', dV_out, 'V_min_step', V_out_rng(1) - dV_baja, ...
    'V_max_step', V_out_rng(2) + dV_sube, 'C_in_nom', C_in_nom, 'R_comp', R_c_n, 'C_comp', C_c_n, 'C_polo', C_p_n, ...
    'f_co', f_co, 'f_p', f_p, 'f_z', f_z, 'dV_lazo', dV_lazo, 'P_D', [P_D25 P_D125], 'TJ_D', [TJ25; TJ125], 'P_ic', P_ic_max, 'TJ_ic', TJ_ic);
save('buckservos_electrico.mat', 'R');
