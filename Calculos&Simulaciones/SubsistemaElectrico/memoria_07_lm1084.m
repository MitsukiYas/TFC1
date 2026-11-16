%% MEMORIA 07 - Regulador lineal LM1084-3.3
% Condensadores de entrada y salida, estabilidad, margen de caida, disipacion y diodo de
% proteccion (TFC/cap6/606, PENDIENTE del LM1084-3.3).
%
% Fuente: hoja de datos LM1084, Texas Instruments, SNVS037H (marzo de 2024): caracteristicas
% electricas, Stability Consideration, Protection Diodes, Power Supply Recommendations,
% Thermal Considerations. Datos del circuito: 606 y memorias 01 y 05.
clear; clc;
run('parametros_electrico.m');
load('demanda_electrico.mat', 'D');
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 07: REGULADOR LM1084-3.3 ===\n\n');

%% 0. Datos
L.Vout = [3.235 3.300 3.365];   % V, -40 a 125 C, 4.8 V <= VIN <= 15 V, 0 <= I <= plena carga
L.Vin_spec = 4.8;               % V, entrada minima con la que se especifica la salida
L.Vdo_max = 1.5;                % V, caida maxima a 5 A en todo el rango de temperatura
L.Iq_max = 10e-3;               % A, corriente de reposo maxima
L.R_JA = 22.7;                  % C/W, encapsulado TO-220 (NDE)
L.TJ_ctrl = 125; L.TJ_out = 150;   % C, maximos de la seccion de control y de salida
L.Vdiff_max = 27;               % V, diferencia maxima entre entrada y salida (3.3 V)
L.C_out_tant = 10e-6; L.C_out_al = 50e-6;   % F, desacoplo recomendado para la estabilidad
L.C_in = 10e-6;                 % F, recomendado a la entrada
L.C_diodo = 1000e-6;            % F, salida a partir de la cual se recomienda el diodo externo
V_in = [4.87 5.00 5.14];        % V, linea de 5.0 V con sus tolerancias (606)
I_3 = D.I_3V3_dis;              % A, carga de diseno de la linea de 3.3 V (606)
I_3_ident = D.I_3V3_ident;      % A, carga identificada (GNSS)
fprintf('0. Entrada %.2f a %.2f V; carga de diseno %.2f A (identificada %.3f A)\n\n', V_in(1), V_in(3), I_3, I_3_ident);

%% 1. Margen de entrada
fprintf('1. Entrada minima %.2f V >= %.1f V (condicion de la especificacion de salida): %s\n', V_in(1), L.Vin_spec, ok(V_in(1) >= L.Vin_spec));
fprintf('   Diferencia minima %.2f V >= caida maxima %.1f V (a 5 A): %s\n', V_in(1) - L.Vout(3), L.Vdo_max, ok(V_in(1) - L.Vout(3) >= L.Vdo_max));
fprintf('   Diferencia maxima %.2f V <= %.0f V: %s\n', V_in(3) - L.Vout(1), L.Vdiff_max, ok(V_in(3) - L.Vout(1) <= L.Vdiff_max));
fprintf('   Salida de %.3f a %.3f V\n\n', L.Vout(1), L.Vout(3));

%% 2. Condensadores y estabilidad
% El LM1084 necesita resistencia serie en el condensador de salida (cero cerca de 500 kHz):
% desacoplo recomendado de 10 uF de tantalio o 50 uF de aluminio; a la entrada, 10 uF.
fprintf('2. Salida: %.0f uF de tantalio (o %.0f uF de aluminio), por la resistencia serie que requiere el lazo\n', L.C_out_tant*1e6, L.C_out_al*1e6);
fprintf('   Entrada: %.0f uF junto al regulador\n', L.C_in*1e6);
% Variacion por escalon de carga: dV = dI * ESR (hoja de datos).
% SUPOSICION: resistencia serie de un tantalio de 10 uF entre 0.5 y 2 ohm (depende del modelo).
ESR_t = [0.5 2];
dV = I_3*ESR_t;
fprintf('   Escalon de 0 a %.2f A: %.0f a %.0f mV (%.1f a %.1f %% de 3.3 V) segun la resistencia serie\n\n', I_3, dV(1)*1e3, dV(2)*1e3, dV(1)/3.3*100, dV(2)/3.3*100);

%% 3. Disipacion
P = (V_in(3) - L.Vout(1))*I_3 + V_in(3)*L.Iq_max;
P_sin_Iq = (5.0 - 3.3)*I_3;
TJ = E.T_int + P*L.R_JA;
fprintf('3. Disipacion maxima %.2f W (606 indica %.2f W sin la corriente de reposo)\n', P, P_sin_Iq);
fprintf('   Union %.0f C con %.1f C/W y %.0f C de ambiente; control <= %.0f C: %s\n\n', TJ, L.R_JA, E.T_int, L.TJ_ctrl, ok(TJ <= L.TJ_ctrl));

%% 4. Diodo de proteccion
C_out_total = L.C_out_tant;
fprintf('4. Diodo externo entre salida y entrada: recomendado con %.0f uF o mas a la salida;\n', L.C_diodo*1e6);
fprintf('   con %.0f uF no es necesario (el diodo interno soporta los picos de descarga).\n\n', C_out_total*1e6);

%% 5. Resumen
fprintf('=== RESUMEN ===\n');
fprintf('Entrada %.0f uF; salida %.0f uF de tantalio; disipacion %.2f W; union %.0f C.\n', L.C_in*1e6, L.C_out_tant*1e6, P, TJ);

R = struct('Vin_min', V_in(1), 'margen', V_in(1) - L.Vout(3), 'P', P, 'TJ', TJ, 'C_in', L.C_in, 'C_out', L.C_out_tant, 'dV_step', dV);
save('lm1084_electrico.mat', 'R');
