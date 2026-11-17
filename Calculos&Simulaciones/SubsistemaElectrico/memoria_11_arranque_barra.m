%% MEMORIA 11 - Etapa de arranque suave de la barra de actuadores (LTC4364-2) y M1 de la linea protegida
% Opcion A aprobada por el usuario (2026-11-16): la parada de emergencia (MOSFET de canal P) y el
% rele de recarga quedan como estan en 603 y 606; entre el rele y la barra de actuadores se anade
% un LTC4364-2 con un MOSFET de paso de canal N (M1), que carga los condensadores de la barra con
% una rampa y limita la corriente. Sin el MOSFET de diodo ideal (M2), para que la energia que
% devuelven los motores pueda volver a la bateria.
% M1: PSMN4R8-100BSE (Nexperia), elegido por el usuario. La parte 6 comprueba el mismo MOSFET como
% M1 de la linea protegida (memoria 03), con el SOA a la tension real en lugar de la curva termica.
%
% Fuentes: hoja de datos LTC4364-1/LTC4364-2 (Rev. B): caracteristicas electricas, Pin Functions
% (DGATE: "leave open if unused"; FB: "connect to GND to disable the overvoltage clamp"; OV:
% "connect to GND if unused"; UV: "if unused, connect to the SHDN pin"), Limiting Inrush Current,
% Fault Timer (se recomienda duplicar el esfuerzo calculado). TI SLVA673A, Robust Hot Swap Design:
% pulso cuadrado equivalente, interpolacion del SOA en el tiempo con una ley de potencia y
% correccion por la temperatura de la caja. PSMN4R8-100BSE, hoja de datos del 12 de abril de 2013.
clear; clc;
run('parametros_electrico.m');
load('demanda_electrico.mat', 'D');
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 11: ARRANQUE SUAVE DE LA BARRA DE ACTUADORES ===\n\n');

%% 0. Datos
L.dVsns   = [43 50 57]*1e-3;     % V, umbral de sobrecorriente con OUT >= 2.5 V
L.dVsns_0 = [18 25 32]*1e-3;     % V, umbral con OUT < 1.5 V
L.I_hg_up = [10 20 30]*1e-6;     % A, corriente de carga de HGATE
L.V_tmr_g = 1.35;                % V, umbral de apagado del temporizador
I_tmr_oc = @(dV) 10e-6 + 3.36e-6*(dV - 0.5);   % A, temporizador en sobrecorriente (tipica)
k_oc = [210 260 310]/260;        % minimo, tipico y maximo respecto de la formula tipica (tabla)
% Barra (603): 470 uF +-20 % en cada uno de los dos DM542 y los dos controladores de traccion,
% mas la entrada del TPS54560 (4 x 2.2 uF).
C_L = [4*470e-6*0.8, 4*470e-6, 4*470e-6*1.2] + 4*2.2e-6;
V_in = E.bat.V_max;              % V
I_bar = D.I_bar_severo_min;      % A, mayor demanda de la barra (memoria 01, bateria en el minimo)
T_A = E.T_int;
fprintf('0. Barra: C_L = %.0f uF (%.0f a %.0f uF); demanda maxima %.1f A; entrada %.1f V\n\n', C_L(2)*1e6, C_L(1)*1e6, C_L(3)*1e6, I_bar, V_in);

% PSMN4R8-100BSE
N.V_DS = 100; N.V_GS = 20; N.Vth = [2 4]; N.TJ = 175;
N.Rds = [4.8e-3 8.7e-3];         % ohm, maximo con V_GS = 10 V a 25 C y a 100 C
N.Rja = 50;                      % K/W, tipico, huella minima en placa
N.Rjmb = 0.37;                   % K/W, maximo
% SOA (Fig. 4, T_mb = 25 C, pulso unico). LECTURA DE GRAFICA con V_DS = 30 V, revisada por el
% usuario el 2026-11-16 (100 us, 1 ms, 10 ms, 100 ms y corriente continua).
% Comprobacion: a 60 V el usuario lee 27, 5 y 2.2 A (1, 10 y 100 ms); TI SLVA673A da 30, 6 y 2 A.
N.t = [1e-4 1e-3 1e-2 1e-1];  N.I30 = [200 70 27 9];  N.I30_dc = 3.7;   % s, A, A
soa30 = @(t) max(10.^interp1(log10(N.t), log10(N.I30), log10(t), 'linear', 'extrap'), N.I30_dc);
der = @(Tmb) (N.TJ - Tmb)/(N.TJ - 25);                     % correccion por temperatura (TI)
E6 = [1 1.5 2.2 3.3 4.7 6.8]; serie = reshape(E6' * 10.^(-10:-6), 1, []);

%% 1. Resistencia de deteccion
R_op = [1 1.5 2 2.5 3 4 5]*1e-3;
R_sns = max(R_op(R_op <= L.dVsns(1)/I_bar));
I_lim = L.dVsns/R_sns; I_lim_0 = L.dVsns_0/R_sns;
fprintf('1. R_SNS = %.1f mohm: limite %.1f A (%.1f a %.1f A); con la salida en cortocircuito %.1f A (%.1f a %.1f A)\n', R_sns*1e3, I_lim(2), I_lim(1), I_lim(3), I_lim_0(2), I_lim_0(1), I_lim_0(3));
fprintf('   Limite minimo sobre la demanda maxima: %s; perdida %.2f W con %.1f A\n\n', ok(I_lim(1) > I_bar), I_bar^2*R_sns, I_bar);

%% 2. Conduccion de M1 y temperatura de su base
I_pend = (215.4 + 0.69 + 1.85 + 0.07)/(21.7*(1-0.013));   % A, barra en la pendiente (memoria 01), a 21.42 V
P_pend = I_pend^2*N.Rds(2); T_pend = T_A + P_pend*N.Rja;
fprintf('2. Conduccion del PSMN4R8-100BSE (%.1f mohm a 100 C; %.0f K/W con la huella minima)\n', N.Rds(2)*1e3, N.Rja);
fprintf('   Pendiente, %.1f A: %.2f W, %.0f C; demanda maxima (transitoria), %.1f A: %.2f W\n\n', I_pend, P_pend, T_pend, I_bar, I_bar^2*N.Rds(2));

%% 3. Rampa de arranque: I = I_HGATE(UP) * C_L / C_HG (hoja de datos del LTC4364)
I_obj = 1.0;   % A, corriente de arranque maxima (propuesta de Claude aprobada por el usuario)
C_HG = min(serie(serie >= L.I_hg_up(3)*C_L(3)/I_obj));
I_inr = [L.I_hg_up(1)*C_L(1), L.I_hg_up(2)*C_L(2), L.I_hg_up(3)*C_L(3)]/C_HG;
t_arr = C_L.*V_in./I_inr;
fprintf('3. C_HG = %.0f nF: arranque de %.2f a %.2f A (tipico %.2f A), en %.0f a %.0f ms; %.2f J en M1\n', C_HG*1e9, I_inr(1), I_inr(3), I_inr(2), min(t_arr)*1e3, max(t_arr)*1e3, 0.5*C_L(3)*V_in^2);
fprintf('   SOA (pulso cuadrado equivalente V_in, I, t/2), con la base a %.0f C (rearme tras la pendiente):\n', T_pend);
for k = [1 3]
    t_eq = t_arr(k)/2; I_adm = soa30(t_eq)*der(T_pend);
    fprintf('      %.2f A durante %.0f ms: admite %.1f A: %s\n', I_inr(k), t_eq*1e3, I_adm, ok(I_inr(k) < I_adm));
end
fprintf('   No incluye el consumo de los drivers y del TPS54560 durante la rampa (sin dato).\n\n');

%% 4. Fallas de la barra y condensador del temporizador
% M1 limita la corriente hasta que el temporizador lo apaga: t = C_TMR * 1.35 V / I_TMR.
% Criterio (el de memoria 03): el mayor C_TMR normalizado con el que M1 queda dentro del SOA con
% la duracion duplicada, la corriente minima del temporizador y la base a la temperatura de la pendiente.
casos = {'Sobrecarga (OUT = 2.5 V)', V_in - 2.5, I_lim(3); 'Cortocircuito (OUT = 0)', V_in, I_lim_0(3)};
t_F = zeros(1, 2); C_max = zeros(1, 2);
fprintf('4. Fallas (base de M1 a %.0f C; duracion duplicada)\n', T_pend);
for k = 1:2
    t_F(k) = L.V_tmr_g/(k_oc(1)*I_tmr_oc(casos{k,2}));          % s por faradio, el mas largo
    cumple = arrayfun(@(C) soa30(2*C*t_F(k))*der(T_pend) >= casos{k,3}, serie);
    C_max(k) = max(serie(cumple));
    fprintf('   %-26s %.1f V x %.1f A = %.0f W: C_TMR <= %.0f nF\n', casos{k,1}, casos{k,2}, casos{k,3}, casos{k,2}*casos{k,3}, C_max(k)*1e9);
end
C_TMR = min(C_max);
t_cool = 63*C_TMR*1.2/2e-6;
fprintf('   Se adopta C_TMR = %.0f nF:\n', C_TMR*1e9);
for k = 1:2
    t_f = C_TMR*L.V_tmr_g./(k_oc([3 1])*I_tmr_oc(casos{k,2}));
    fprintf('      %-26s dura de %.2f a %.2f ms; con el doble, el SOA admite %.0f A frente a %.1f A\n', casos{k,1}, t_f(1)*1e3, t_f(2)*1e3, soa30(2*t_f(2))*der(T_pend), casos{k,3});
end
fprintf('   Enfriamiento antes del reintento: %.2f s\n\n', t_cool);

%% 5. Otras comprobaciones de M1 en la barra
fprintf('5. PSMN4R8-100BSE en la barra: %d V >= %.1f V (limitacion del TVS de entrada, 603): %s; compuerta +-%d V con Zener de 15 V: %s\n\n', N.V_DS, 55.5, ok(N.V_DS >= 55.5), N.V_GS, ok(N.V_GS >= 16));

%% 6. El mismo MOSFET como M1 de la linea protegida (casos de memoria 03, comprobados por SOA)
load('limitador_electrico.mat', 'R'); R03 = R; clear R;
T_mb3 = T_A + R03.I_carga^2*N.Rds(2)*N.Rja;
fprintf('6. PSMN4R8-100BSE como M1 de la linea protegida (R_SNS 20 mohm, C_TMR %.0f nF; base a %.0f C)\n', R03.C_TMR*1e9, T_mb3);
nom3 = {'Sobretension', 'Cortocircuito (OUT = 0)', 'Sobrecarga (OUT = 2.5 V)'};
V3 =[E.tvs.V_C - R03.V_fb(1), V_in, V_in - 2.5];
I3 = R03.P_falla./V3;
for k = 1:3
    % Con V_DS menor que 30 V se usa igualmente la corriente admisible a 30 V (conservador).
    I_adm = soa30(2*R03.t_falla(k))*der(T_mb3);
    fprintf('   %-26s %.1f V x %.2f A durante %.1f ms: con el doble, admite %.1f A: %s\n', nom3{k}, V3(k), I3(k), R03.t_falla(k)*1e3, I_adm, ok(I3(k) < I_adm));
end
% Arranque de la linea protegida: mayor corriente por M1 (carga de condensadores mas el LMR33630)
for k = [1 3]
    I_k = R03.I_inrush(k) + R03.P_met_arranque/3.8; t_eq = R03.T_arr(k)/2;
    fprintf('   Arranque: %.2f A durante %.0f ms equivalentes: admite %.1f A: %s\n', I_k, t_eq*1e3, soa30(t_eq)*der(T_mb3), ok(I_k < soa30(t_eq)*der(T_mb3)));
end
fprintf('   Conduccion con %.2f A: %.0f mW\n', R03.I_carga, R03.I_carga^2*N.Rds(2)*1e3);

R = struct('R_sns', R_sns, 'I_lim', I_lim, 'I_lim_0', I_lim_0, 'C_HG', C_HG, 'I_inr', I_inr, 't_arr', t_arr, ...
    'C_L', C_L, 'C_TMR', C_TMR, 't_cool', t_cool, 'P_pend', P_pend, 'T_pend', T_pend);
save('arranque_barra_electrico.mat', 'R');
