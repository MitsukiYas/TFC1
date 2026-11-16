%% MEMORIA 10 - MOSFET de la parada de emergencia y diodo de bloqueo del cargador
% Comprobacion de las piezas elegidas por el usuario (2026-11-15):
%  - SUP40P10-43 (Vishay, documento 65458 Rev. A): MOSFET de canal P de la parada (603).
%  - STPS20H100C (ST, DS1216 Rev. 10): diodo Schottky doble de catodo comun, bloqueo del cargador (606).
clear; clc;
run('parametros_electrico.m');
load('demanda_electrico.mat', 'D');
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 10: MOSFET DE LA PARADA Y DIODO DEL CARGADOR ===\n\n');

%% 1. SUP40P10-43
M.Vds = 100; M.Vgs = 20; M.Id = [36 16]; M.Idm = 40;        % V, V, A (Tc = 25 y 125 C), A
M.Rds = [0.043 0.078 0.088]; M.Rds45 = 0.048;               % ohm, -10 V a 25/125/150 C; -4.5 V a 25 C
M.Rjc = 1.0; M.Rja = 62;                                    % C/W
M.Ciss = 4600e-12; M.Qgd = 26e-9; M.Vth = [1 3];            % F, C, V
V_gs = 8.75;                                                % V, excitacion de la compuerta (603)
fprintf('1. SUP40P10-43: %d V >= 55.5 V: %s; +-%d V >= %.2f V de compuerta: %s\n', M.Vds, ok(M.Vds >= 55.5), M.Vgs, V_gs, ok(M.Vgs >= V_gs));
fprintf('   Corriente continua %d A (Tc 25 C) y %d A (Tc 125 C); pulsada %d A\n', M.Id(1), M.Id(2), M.Idm);
fprintf('   R_DS(on) con %.2f V: entre los maximos de -4.5 V (%.0f mohm) y -10 V (%.0f mohm) a 25 C; %.0f mohm a 125 C\n', V_gs, M.Rds45*1e3, M.Rds(1)*1e3, M.Rds(2)*1e3);
I_med = D.I_bat_prom; I_max = D.I_bat_severo_min;
for I = [I_med I_max]
    P = I^2*M.Rds(2);
    fprintf('   Con %.1f A: %.1f W (R a 125 C); sin disipador, union %.0f C\n', I, P, E.T_int + P*M.Rja);
end
P_max = I_max^2*M.Rds(2);
R_ca_max = (150 - E.T_int)/P_max - M.Rjc;
fprintf('   Para la demanda maxima continua, resistencia caja-ambiente <= %.2f C/W (disipador)\n', R_ca_max);
% Apagado a traves de 10 kohm (603): descarga de la compuerta hasta la meseta de Miller, meseta y
% caida por debajo del umbral. SUPOSICION: meseta de 3.2 V con 20 A (curva de transferencia).
Rg = 10e3; V_pl = 3.2; I0 = E.I_fusible; V_bus = E.bat.V_max;
t_d = Rg*M.Ciss*log(V_gs/V_pl);
t_m = M.Qgd/(V_pl/Rg);
t_f = Rg*M.Ciss*log(V_pl/M.Vth(1));
E_off = 0.5*V_bus*I0*t_m;
fprintf('   Apagado: retardo %.0f us, meseta %.0f us, caida %.0f us; total %.0f us (<< 0.1 s)\n', t_d*1e6, t_m*1e6, t_f*1e6, (t_d+t_m+t_f)*1e6);
fprintf('   Energia durante la meseta con %.0f A y %.1f V: %.0f mJ; potencia media %.0f W\n', I0, V_bus, E_off*1e3, E_off/t_m);
% Impedancia termica transitoria union-caja de pulso unico a 100 us: unos 0.07 veces R_jc (grafica)
Z_100us = 0.07*M.Rjc;
fprintf('   Elevacion durante la meseta: %.0f C con Z_jc(100 us) = %.2f C/W (lectura de grafica)\n\n', E_off/t_m*Z_100us, Z_100us);

%% 2. STPS20H100C
S.Vrrm = 100; S.Iav = [10 20]; S.Ifsm = 250;          % V, A (por diodo, dispositivo), A
S.Rjc = [1.6 0.9];                                    % C/W, por diodo y total (TO-220AB / D2PAK)
P_d = @(Iav, Irms) 0.55*Iav + 0.009*Irms.^2;          % W por diodo (hoja de datos)
I_ch = [E.bat.I_carga_std E.bat.I_carga_max];
fprintf('2. STPS20H100C: %d V >= 55.5 V: %s; %d A por diodo >= %.0f A: %s\n', S.Vrrm, ok(S.Vrrm >= 55.5), S.Iav(1), I_ch(2), ok(S.Iav(1) >= I_ch(2)));
for I = I_ch
    P1 = P_d(I, I); P2 = 2*P_d(I/2, I/2);
    fprintf('   Con %.1f A: un diodo %.2f W; los dos en paralelo %.2f W\n', I, P1, P2);
end
P_9 = 2*P_d(I_ch(2)/2, I_ch(2)/2);
R_ca_d = (175 - E.T_int)/P_9 - S.Rjc(2);
fprintf('   Con 9 A y los dos diodos: resistencia caja-ambiente <= %.1f C/W para 175 C\n', R_ca_d);
% Caida al final de la carga (corriente baja): unos 0.45 V a 0.1 A y 25 C (maximo, Fig. 8)
Vf_fin = 0.45;
fprintf('   Al final de la carga, la bateria queda unos %.2f V (%.0f mV por celda) por debajo de la tension del cargador\n', Vf_fin, Vf_fin/7*1e3);

R = struct('P_mos_med', I_med^2*M.Rds(2), 'P_mos_max', P_max, 'R_ca_mos', R_ca_max, 't_off', t_d+t_m+t_f, ...
    'E_off', E_off, 'P_diodo', P_9, 'R_ca_diodo', R_ca_d, 'Vf_fin', Vf_fin);
save('componentes_electrico.mat', 'R');
