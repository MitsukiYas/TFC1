%% MEMORIA 08 - Fuente de la barra meteorologica: LMR33630 + LM1085-ADJ + 2N3906
% Tensiones del LM1085 con sus tolerancias, red de seguimiento con el 2N3906, diseno del LMR33630
% (bobina, salida, condensadores auxiliares), disipacion, y condensadores del LM1085-12 de la
% bobina del rele (TFC/cap6/606, PENDIENTES de la fuente meteorologica y del LM1085-12).
%
% Circuito (esquematico ModuloEnergia del usuario): Q4 (2N3906) con el emisor hacia la salida del
% LMR33630 por R22 = 12 kohm, la base a la salida del LM1085 por R24 = 10 kohm y el colector en el
% nodo FB del LMR33630, con R23 = 10 kohm a tierra. El LMR33630 fija FB en 1.0 V, de modo que la
% corriente de R23 circula por R22 y la salida del LMR33630 queda V_EB + R22*V_FB/R23 por encima
% de la del LM1085. Divisor del LM1085: 120 ohm superior (esquematico) y 200, 360 o 1000 + 30 ohm
% inferiores segun el conmutador (606).
%
% Fuentes: hojas de datos LMR33630 (SNVSAN3F), LM1085 (SNVS038H). La hoja de datos del 2N3906
% no esta disponible: sus valores son supuestos.
clear; clc;
run('parametros_electrico.m');
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 08: FUENTE DE LA BARRA METEOROLOGICA ===\n\n');

%% 0. Datos
LM.Vref = [1.225 1.250 1.270];   % V, -40 a 125 C
LM.Iadj = [0 55e-6 120e-6];      % A, corriente del terminal de ajuste (minima supuesta 0)
LM.Vdo = 1.5;                    % V, caida maxima a 3 A, -40 a 125 C
LM.Imin = 10e-3;                 % A, carga minima maxima (con 25 V de diferencia)
LM.R_JA = 22.8;                  % C/W, TO-220
LM.Vdiff_max = 29;               % V
R25 = 120;                       % ohm, resistencia superior (esquematico ModuloEnergia)
R_inf = [200 360 1000+30];       % ohm, resistencias inferiores (606)
tolR = 0.01;
LMR.Vfb = [0.985 1.000 1.015];   % V
LMR.f_sw = [340e3 400e3 460e3];  % Hz, variante A
LMR.I_max = 3; LMR.Isc = [3.85 4.5 5.05]; LMR.Ilim = [2.9 3.5 4.1];   % A
R22 = 12e3; R23 = 10e3; R24 = 10e3;
% 2N3906 (ON Semiconductor, 2N3906/D Rev. 4): ganancia minima de 60 con 0.1 mA y V_CE = 1 V;
% V_CEO 40 V. La hoja de datos solo da V_BE(sat) de 0.65 a 0.85 V con 10 mA, que se toma como
% cota superior de V_EB con 100 uA. SUPOSICION: cota inferior de 0.55 V y valor tipico de 0.65 V.
Q.Veb = [0.55 0.65 0.85]; Q.beta_min = 60; Q.Vceo = 40;
V_in = [20.84 25.2 34.56];       % V, linea protegida (minima, nominal, maxima)
I_met = 0.300;                   % A, carga de diseno por salida (606)
eta = 0.90;                      % eficiencia supuesta en 606 y en la memoria 01
fprintf('0. Divisor del LM1085: %d ohm y %d / %d / %d ohm; seguimiento R22 = %.0f k, R23 = %.0f k, R24 = %.0f k\n\n', R25, R_inf(1), R_inf(2), R_inf(3), R22/1e3, R23/1e3, R24/1e3);

%% 1. Tensiones de salida del LM1085
% V_o = V_ref (1 + R_inf/R_sup) + I_ADJ R_inf
Vo = zeros(3, 3);
for k = 1:3
    Vo(k,1) = LM.Vref(1)*(1 + R_inf(k)*(1-tolR)/(R25*(1+tolR))) + LM.Iadj(1)*R_inf(k);
    Vo(k,2) = LM.Vref(2)*(1 + R_inf(k)/R25) + LM.Iadj(2)*R_inf(k);
    Vo(k,3) = LM.Vref(3)*(1 + R_inf(k)*(1+tolR)/(R25*(1-tolR))) + LM.Iadj(3)*R_inf(k);
end
nom = {'3.3 V', '5.0 V', '12.0 V'};
fprintf('1. Salidas del LM1085 (tolerancias de la referencia, de I_ADJ y de resistencias de 1 %%)\n');
for k = 1:3
    fprintf('   %6s: %.3f V (%.3f a %.3f V)\n', nom{k}, Vo(k,2), Vo(k,1), Vo(k,3));
end
I_div = LM.Vref(2)/R25;
fprintf('   Corriente del divisor %.1f mA >= carga minima %.0f mA: %s\n', I_div*1e3, LM.Imin*1e3, ok(I_div >= LM.Imin));
% Los instrumentos los elige el operador (decision del usuario, 2026-11-15): se informan los rangos
% y los extremos, comparados con tolerancias usuales de +-5 % y +-10 %.
fprintf('   5.0 V dentro de +-5 %% (4.75 a 5.25 V): %s\n', ok(Vo(2,1) >= 4.75 && Vo(2,3) <= 5.25));
fprintf('   12 V dentro de +-10 %% (10.8 a 13.2 V): %s; >= 12 V en todo el rango: %s (minimo %.2f V)\n', ok(Vo(3,1) >= 10.8 && Vo(3,3) <= 13.2), ok(Vo(3,1) >= 12), Vo(3,1));
fprintf('   Conexion directa: %.2f a %.1f V (24 V +-10 %% admite hasta 26.4 V)\n\n', V_in(1), E.bat.V_max);

%% 2. Red de seguimiento
I_C = LMR.Vfb/R23;
H_min = Q.Veb(1) + R22*(1-tolR)*LMR.Vfb(1)/(R23*(1+tolR));
H_nom = Q.Veb(2) + R22*LMR.Vfb(2)/R23;
H_max = Q.Veb(3) + R22*(1+tolR)*LMR.Vfb(3)/(R23*(1-tolR))*(1 + 1/Q.beta_min) + LMR.Vfb(3)/R23/Q.beta_min*R24*(1+tolR);
fprintf('2. Seguimiento: corriente de Q4 %.0f uA; diferencia entrada-salida del LM1085 %.2f V (%.2f a %.2f V)\n', I_C(2)*1e6, H_nom, H_min, H_max);
fprintf('   Minima por encima de la caida maxima del LM1085 (%.1f V): %s (margen %.2f V)\n', LM.Vdo, ok(H_min > LM.Vdo), H_min - LM.Vdo);
Vo_lmr = Vo + [H_min H_nom H_max];
for k = 1:3
    fprintf('   %6s: salida del LMR33630 %.2f V (%.2f a %.2f V)\n', nom{k}, Vo_lmr(k,2), Vo_lmr(k,1), Vo_lmr(k,3));
end
P_Q4 = I_C(3)*(max(Vo_lmr(:)) - LMR.Vfb(1));
fprintf('   Disipacion de Q4 %.1f mW; V_CE maxima %.1f V <= %.0f V: %s\n\n', P_Q4*1e3, max(Vo_lmr(:)) - LMR.Vfb(1), Q.Vceo, ok(max(Vo_lmr(:)) - LMR.Vfb(1) <= Q.Vceo));

%% 3. LMR33630: rango de operacion
Vlmr_max = max(Vo_lmr(:)); Vlmr_min = min(Vo_lmr(:));
fprintf('3. Salida del LMR33630 de %.2f a %.2f V, dentro de 1 a 24 V: %s; <= 95 %% de la entrada minima: %s\n', Vlmr_min, Vlmr_max, ok(Vlmr_min >= 1 && Vlmr_max <= 24), ok(Vlmr_max <= 0.95*V_in(1)));
fprintf('   Entrada maxima %.2f V <= 36 V: %s\n\n', V_in(3), ok(V_in(3) <= 36));

%% 4. Bobina (procedimiento de la hoja de datos: K = 0.3 con la corriente maxima del dispositivo)
K = 0.3;
Lf = @(Vi, Vo_) (Vi - Vo_)./(LMR.f_sw(2)*K*LMR.I_max).*Vo_./Vi;
L_req = max(Lf(V_in(2), Vo_lmr(:,2)));
L_sel = 18e-6;
L_min = 0.28*Vlmr_max/LMR.f_sw(2);
rip = @(Vi, Vo_) (Vi - Vo_).*Vo_./(Vi*L_sel*LMR.f_sw(2));
rip_nom = rip(V_in(2), Vo_lmr(:,2));
rip_max = max(max(rip(V_in(3), Vo_lmr), [], 'all'), max(rip(V_in(1), Vo_lmr), [], 'all'));
fprintf('4. Bobina: %.1f uH con la entrada nominal y la mayor salida; se adopta %.0f uH\n', L_req*1e6, L_sel*1e6);
fprintf('   Inductancia minima %.1f uH: %s; rizado nominal %.2f a %.2f A (>= 10 %% de %d A: %s); maximo %.2f A\n', L_min*1e6, ok(L_sel >= L_min), min(rip_nom), max(rip_nom), LMR.I_max, ok(min(rip_nom) >= 0.1*LMR.I_max), rip_max);
fprintf('   Saturacion >= limite del lado bajo (%.1f A maximo); preferible >= limite del lado alto (%.2f A)\n\n', LMR.Ilim(3), LMR.Isc(3));

%% 5. Condensador de salida del LMR33630
% Escalon de carga: la barra completa (0.3 A). Variacion admisible: la que conserva la caida
% maxima del LM1085, H_min - V_DO (criterio del texto: el regulador lineal opera siempre por
% encima de su caida maxima).
dI = I_met + I_div; dV = H_min - LM.Vdo;
D = Vo_lmr(:,2)./V_in(2);
C_req = max(dI./(LMR.f_sw(2)*dV*K).*((1 - D).*(1 + K) + K^2/12*(2 - D)));
% Seleccion: 4 x 22 uF ceramicos, valor de la tabla de la hoja de datos para 400 kHz y salidas de
% 5 y 12 V. SUPOSICION: X7R de 25 V que conservan la mitad de su capacidad con la tension continua.
C_nom = 4*22e-6; C_eff = 0.5*C_nom;
ESR = 2e-3/4;    % SUPOSICION: 2 mohm por condensador
Vr = rip_nom.*sqrt(ESR^2 + (1/(8*LMR.f_sw(2)*C_eff))^2);
fprintf('5. Salida: escalon de %.2f A con %.2f V admisibles: C >= %.1f uF\n', dI, dV, C_req*1e6);
fprintf('   4 x 22 uF X7R 25 V: %.0f uF efectivos: %s; maximo 10 veces el valor de diseno (%.0f uF): %s\n', C_eff*1e6, ok(C_eff >= C_req), 10*C_req*1e6, ok(C_eff <= 10*C_req));
for k = 1:3
    fprintf('   %6s: rizado %.1f mV (%.2f %% de %.2f V)\n', nom{k}, Vr(k)*1e3, Vr(k)/Vo_lmr(k,2)*100, Vo_lmr(k,2));
end
fprintf('   Entrada del LM1085 (salida del LMR33630): ademas 10 uF (esquematico) junto al regulador\n\n');

%% 6. Condensadores auxiliares del LMR33630
fprintf('6. BOOT 100 nF (>= 10 V); VCC 1 uF de 16 V; PG con 100 kohm a VCC; EN a VIN\n\n');

%% 7. LM1085-ADJ: condensador de salida y disipacion
P_LM = H_max*(I_met + I_div);
TJ_LM = E.T_int + P_LM*LM.R_JA;
fprintf('7. LM1085: salida 10 uF de tantalio o 50 uF de aluminio (estabilidad, hoja de datos);\n');
fprintf('   el esquematico tiene 47 uF electroliticos, por debajo de los 50 uF de aluminio recomendados.\n');
fprintf('   Disipacion maxima %.2f W; union %.0f C (<= 125 C: %s)\n\n', P_LM, TJ_LM, ok(TJ_LM <= 125));

%% 8. LMR33630: disipacion
P_out = Vlmr_max*(I_met + I_div);
P_lmr = P_out*(1 - eta)/eta;
R_JA_lmr = 42.9;   % C/W, DDA (tabla, placa normalizada)
TJ_lmr = E.T_int + P_lmr*R_JA_lmr;
fprintf('8. LMR33630: %.2f W de salida, %.2f W de perdidas con eta = %.2f; union %.0f C (<= 125 C: %s)\n\n', P_out, P_lmr, eta, TJ_lmr, ok(TJ_lmr <= 125));

%% 9. LM1085-12 de la bobina del rele
% Entrada desde el lado del conector del cargador (hasta 29.4 V mas la caida del diodo de bloqueo);
% mismos criterios de estabilidad que el LM1085-ADJ.
fprintf('9. LM1085-12 (rele): entrada 10 uF de 50 V; salida 10 uF de tantalio de 16 V o mas\n');
fprintf('   Diferencia con 29.4 V en el conector: %.1f V (maximo absoluto 18 V); se supera con mas de 30 V\n', 29.4 - 12);
% Diodo de libre circulacion de la bobina: 1N4001 (ON Semiconductor, 1N4001/D Rev. 14): 50 V,
% 1 A medios, 30 A de pico no repetitivo; la bobina toma 75 mA con 12 V.
fprintf('   Diodo de la bobina 1N4001: 50 V >= 12 V y 1 A >= 75 mA: %s\n\n', ok(50 >= 12 && 1 >= 0.075));

%% 10. Resumen
fprintf('=== RESUMEN ===\n');
fprintf('LM1085: %.2f / %.2f / %.2f V; seguimiento %.2f V (%.2f a %.2f V), margen %.2f V sobre la caida.\n', Vo(1,2), Vo(2,2), Vo(3,2), H_nom, H_min, H_max, H_min - LM.Vdo);
fprintf('LMR33630ADDA: bobina %.0f uH; salida 4 x 22 uF; P %.2f W. LM1085: %.2f W.\n', L_sel*1e6, P_lmr, P_LM);

R = struct('Vo', Vo, 'H', [H_min H_nom H_max], 'Vo_lmr', Vo_lmr, 'L', L_sel, 'L_req', L_req, ...
    'C_req', C_req, 'C_out_nom', C_nom, 'Vr', Vr, 'P_LM', P_LM, 'TJ_LM', TJ_LM, 'P_lmr', P_lmr, 'TJ_lmr', TJ_lmr);
save('meteo_electrico.mat', 'R');
