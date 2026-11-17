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


%% 3. Regimen de pendiente (criterio del usuario, 2026-11-16)
% La pendiente de 16 grados ocupa como maximo el 10 % del tiempo de operacion, con tramos de hasta
% 1 min seguidos. Corriente de la bateria por potencia, con la traccion del modelo de motor de
% memoria 01 (53.2 W en plano y 215.4 W en la pendiente) y el resto de cargas de 606.
P_resto = 0.69 + 1.85 + 0.07 + 15.4 + 7.6;      % W
P_pl = 53.2 + P_resto; P_pe = 215.4 + P_resto;  % W
V_al = 21.7*(1 - 0.013);                        % V, menor tension real de la alerta del LTC2944 (21.42 V)
fprintf('\n3. Regimen de pendiente (10 %% del tiempo, tramos de hasta 1 min)\n');
for V = [E.bat.V_nom V_al]
    I_pl = P_pl/V; I_pe = P_pe/V;
    Pm_pl = I_pl^2*M.Rds(2); Pm_pe = I_pe^2*M.Rds(2); Pm_med = 0.9*Pm_pl + 0.1*Pm_pe;
    fprintf('   A %.1f V: plano %.2f A (%.2f W), pendiente %.2f A (%.2f W); media %.2f W\n', V, I_pl, Pm_pl, I_pe, Pm_pe, Pm_med);
    fprintf('      SUP40P10-43 sin disipador: union media %.0f C; con la pendiente sostenida %.0f C\n', E.T_int + Pm_med*M.Rja, E.T_int + Pm_pe*M.Rja);
    fprintf('      Disipador para la pendiente sostenida (union 150 C): caja-ambiente <= %.1f C/W\n', (150 - E.T_int)/Pm_pe - M.Rjc);
end
% SUPOSICION: capacidad termica del TO-220 sin disipador de 1 a 4 J/K (la hoja de datos no la da).
I_pl = P_pl/E.bat.V_nom; I_pe = P_pe/E.bat.V_nom;
for Cth = [1 2 4]
    T60 = E.T_int + I_pl^2*M.Rds(2)*M.Rja + (I_pe^2 - I_pl^2)*M.Rds(2)*M.Rja*(1 - exp(-60/(M.Rja*Cth)));
    fprintf('   Sin disipador, C_th = %d J/K: tras 1 min de pendiente a %.1f V, union %.0f C\n', Cth, E.bat.V_nom, T60);
end
R_ca_pend = (150 - E.T_int)/((P_pe/V_al)^2*M.Rds(2)) - M.Rjc;

%% 3b. Disipador del SUP40P10-43 (aprobado por el usuario, 2026-11-16)
% Aavid 529802B02500G (catalogo Board Level Heatsinks): extruido de aletas radiales, base de
% 41.9 x 25.4 mm y 38.1 mm de alto. Curva de conveccion natural (elevacion de la superficie de
% montaje frente a la potencia), LECTURA DE GRAFICA, revisada por el usuario (2026-11-16):
H.P = [0 4 8 12 16 20]; H.dT = [0 21 41 57 64 75];       % W, C
H.Rcs = 1.15;                                            % C/W, almohadilla Hi-Flow en TO-220 (catalogo)
% Resistencia de conduccion maxima interpolada entre los valores de la hoja de datos (25, 125, 150 C)
Rds_T = @(Tj) interp1([25 125 150], M.Rds, Tj, 'linear', 'extrap');
V_al_min = 21.7*(1 - 0.013);                             % V, menor tension real de la alerta (memoria 03)
fprintf('\n3b. Disipador Aavid 529802B02500G con almohadilla Hi-Flow (pendiente sostenida)\n');
for V = [E.bat.V_nom V_al_min]
    I = P_pe/V; Tj = 100;
    for it = 1:50
        P = I^2*Rds_T(Tj);
        Tj = E.T_int + interp1(H.P, H.dT, P) + P*(M.Rjc + H.Rcs);
    end
    fprintf('   A %.2f V: %.2f A, R_DS %.1f mohm, %.2f W; elevacion del disipador %.0f C; union %.0f C (<= 125 C: %s)\n', ...
        V, I, Rds_T(Tj)*1e3, P, interp1(H.P, H.dT, P), Tj, ok(Tj <= 125));
end
Tj_disip = Tj; P_disip = P;

%% 4. MOSFET de proteccion de polaridad DMP4015SPS (Diodes DS35518 Rev. 13-2)
% Factor de la resistencia a 150 C (Fig. 5, lectura revisada por el usuario): 1.42 con V_GS = -10 V e
% I_D = -10 A; 1.45 con V_GS = -4.5 V e I_D = -5 A. La compuerta trabaja a -15 V (Zener): se usa 1.42.
Q.Vds = 40; Q.Vgs = 25; Q.Rds = 0.011; Q.k150 = 1.42;   % V, V, ohm (-10 V, 25 C, maximo), factor a 150 C
Q.Rja = [49 24 96.4]; Q.Tj = 150;                       % C/W: 1 in2 de cobre de 2 oz, idem t < 10 s, cobre minimo
fprintf('\n4. DMP4015SPS: %d V >= %.1f V: %s; compuerta +-%d V >= 15 V (Zener): %s\n', Q.Vds, E.bat.V_max, ok(Q.Vds >= E.bat.V_max), Q.Vgs, ok(Q.Vgs >= 15));
casosQ = {'plano', P_pl/E.bat.V_nom, 1; 'pendiente, 25.2 V', P_pe/E.bat.V_nom, 1; 'pendiente, 21.4 V', P_pe/V_al, 1; 'maxima (t < 10 s)', I_max, 2};
for n = [1 2]
    fprintf('   %d en paralelo:\n', n);
    for k = 1:size(casosQ, 1)
        P = (casosQ{k,2}/n)^2*Q.Rds*Q.k150;
        fprintf('      %-20s %.2f A: %.2f W cada uno, union %.0f C\n', casosQ{k,1}, casosQ{k,2}, P, E.T_int + P*Q.Rja(casosQ{k,3}));
    end
end

%% 5. Resistencia de derivacion de 2 mohm
R_sh = 2e-3;
fprintf('\n5. Derivacion de 2 mohm: %.2f W con %.1f A; %.2f W en la pendiente a %.1f V; %.3f W en plano\n', I_max^2*R_sh, I_max, (P_pe/V_al)^2*R_sh, V_al, (P_pl/E.bat.V_nom)^2*R_sh);

R = struct('P_mos_med', I_med^2*M.Rds(2), 'P_mos_max', P_max, 'R_ca_mos', R_ca_max, 't_off', t_d+t_m+t_f, ...
    'E_off', E_off, 'P_diodo', P_9, 'R_ca_diodo', R_ca_d, 'Vf_fin', Vf_fin, 'R_ca_mos_pend', R_ca_pend, ...
    'P_shunt_max', I_max^2*R_sh);
save('componentes_electrico.mat', 'R');
