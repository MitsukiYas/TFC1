%% MEMORIA 09 - Resistencias pull-up del bus I2C y de la salida ALCC del LTC2944
% Tramos del bus (602): 5.0 V (microcontrolador, placa del BNO055, LTC2944 en la placa de
% potencia, lado de alta del traslador) y 3.3 V (lado de baja del traslador, dos MPU-6050).
% El traslador de MOSFET separa los tramos: cada uno sube con su propia resistencia.
% Decision del usuario (2026-11-15): el bus opera en modo estandar, a 100 kHz.
%
% Fuentes: NXP UM10204 Rev. 7.0 (1 de octubre de 2021): modo estandar, t_r <= 1000 ns,
% C_b <= 400 pF, V_OL <= 0.4 V con 3 mA; R_p(min) = (V_DD - V_OL)/I_OL y R_p(max) = t_r/(0.8473 C_b)
% (seccion 7.1). LTC2944 (2944fa): V_OL 0.4 V con 3 mA en SDA y ALCC, fuga 1 uA, C_IN 10 pF.
% MPU-6050 (PS-MPU-6000A-00 Rev. 3.4): C_I < 10 pF, I2C hasta 400 kHz. BNO055 (Bosch
% BST-BNO055-DS000-18, Rev. 1.8): modos estandar y rapido, estiramiento de reloj, C_in <= 10 pF.
clear; clc;
run('parametros_electrico.m');
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 09: PULL-UP DEL BUS I2C Y DE ALCC ===\n\n');

%% 0. Datos
I2C.f = 100e3; I2C.tr = 1000e-9; I2C.Cb_max = 400e-12; I2C.Vol = 0.4; I2C.Iol = 3e-3;
I2C.Ci = 10e-12; I2C.k = 0.8473;
V5 = [4.87 5.00 5.14];        % V, linea de 5.0 V (606)
V3 = [3.235 3.300 3.365];     % V, linea de 3.3 V (LM1084-3.3)
% Cables (602 y usuario): MPU-6050 de orientacion 1 m, de elevacion 0.3 m, BNO055 0.3 m;
% placa de potencia (LTC2944) a placa de control 0.3 m como maximo.
L.mpu = [1.0 0.3]; L.bno = 0.3; L.ltc = 0.3;
% SUPOSICION: capacidad de cada linea del cable de 100 pF/m (cable multiconductor sin blindaje);
% para la seleccion se exige ademas que cumpla con 150 pF/m.
C_m = 100e-12; C_m_max = 150e-12;
% SUPOSICION: 20 pF de pistas y conectores por tramo; 10 pF por terminal de cada dispositivo.
C_pcb = 20e-12;
% Las resistencias pull-up de las placas del BNO055, del traslador y de los GY-521 no se
% consideran (decision del usuario: no tienen un efecto apreciable).
n5 = 4;   % microcontrolador, BNO055, LTC2944, traslador
n3 = 3;   % traslador, dos MPU-6050
Cf5 = @(Cm) n5*I2C.Ci + C_pcb + Cm*(L.bno + L.ltc);
Cf3 = @(Cm) n3*I2C.Ci + C_pcb + Cm*sum(L.mpu);
C5 = Cf5(C_m); C3 = Cf3(C_m);
fprintf('0. Capacidad por linea con %.0f pF/m: tramo de 5.0 V %.0f pF; tramo de 3.3 V %.0f pF (limite %.0f pF)\n', C_m*1e12, C5*1e12, C3*1e12, I2C.Cb_max*1e12);
fprintf('   Con %.0f pF/m: %.0f pF y %.0f pF\n\n', C_m_max*1e12, Cf5(C_m_max)*1e12, Cf3(C_m_max)*1e12);

%% 1. Limites de la resistencia
Rmin = @(V) (V - I2C.Vol)/I2C.Iol;
Rmax = @(C) I2C.tr/(I2C.k*C);
R5 = [Rmin(V5(3)) Rmax(Cf5(C_m_max))]; R3 = [Rmin(V3(3)) Rmax(Cf3(C_m_max))];
fprintf('1. Tramo de 5.0 V: R_min %.2f kohm; R_max %.2f kohm (%.2f con %.0f pF/m)\n', R5(1)/1e3, Rmax(C5)/1e3, R5(2)/1e3, C_m_max*1e12);
fprintf('   Tramo de 3.3 V: R_min %.2f kohm; R_max %.2f kohm (%.2f con %.0f pF/m)\n\n', R3(1)/1e3, Rmax(C3)/1e3, R3(2)/1e3, C_m_max*1e12);

%% 2. Seleccion (serie E12, el mayor valor que cumple tambien con 150 pF/m: menor corriente)
E12 = [1 1.2 1.5 1.8 2.2 2.7 3.3 3.9 4.7 5.6 6.8 8.2];
s = reshape(E12'*10.^(2:4), 1, []);
pick = @(R) max(s(s >= R(1) & s <= R(2)));
Rp5 = pick(R5); Rp3 = pick(R3);
tr5 = I2C.k*Rp5*[C5 Cf5(C_m_max)]; tr3 = I2C.k*Rp3*[C3 Cf3(C_m_max)];
fprintf('2. Se adoptan %.1f kohm (5.0 V) y %.1f kohm (3.3 V)\n', Rp5/1e3, Rp3/1e3);
fprintf('   Tiempo de subida %.0f ns (%.0f con %.0f pF/m) y %.0f ns (%.0f) (<= 1000 ns)\n', tr5(1)*1e9, tr5(2)*1e9, C_m_max*1e12, tr3(1)*1e9, tr3(2)*1e9);
fprintf('   Corriente en nivel bajo %.2f mA y %.2f mA (<= 3 mA)\n\n', V5(3)/Rp5*1e3, V3(3)/Rp3*1e3);

%% 3. Ocupacion del bus a 100 kHz (50 tramas/s, 605)
% Lectura de registros: inicio, direccion + escritura, registro, inicio repetido, direccion +
% lectura, N datos, parada: unos (3 + N) bytes de 9 bits mas 2 bits de inicio y parada.
% Datos por trama: BNO055 6 bytes (angulos); cada MPU-6050 14 bytes (aceleracion, temperatura,
% giro); LTC2944 cuatro lecturas de 2 bytes (carga, tension, corriente, temperatura).
lect = [6 14 14 2 2 2 2];
bits = sum((3 + lect)*9 + 2);
t_bus = bits/I2C.f; T_trama = 1/50;
fprintf('3. Por trama: %d bits, %.2f ms a %.0f kHz, %.0f %% de los %.0f ms de cada trama\n\n', bits, t_bus*1e3, I2C.f/1e3, t_bus/T_trama*100, T_trama*1e3);

%% 4. Salida ALCC del LTC2944 (drenador abierto) hacia la terminal 31 del microcontrolador
Ra_min = Rmin(V5(3));
Ra = 10e3;
fprintf('4. ALCC: R_min %.2f kohm; se adopta %.0f kohm (%.2f mA en nivel bajo; caida por fuga %.0f mV)\n\n', Ra_min/1e3, Ra/1e3, V5(3)/Ra*1e3, 1e-6*Ra*1e3);

%% 5. Resumen
fprintf('=== RESUMEN ===\n');
fprintf('I2C a 100 kHz: %.1f kohm en el tramo de 5.0 V (%.0f pF) y %.1f kohm en el de 3.3 V (%.0f pF); bus ocupado %.0f %%.\n', Rp5/1e3, C5*1e12, Rp3/1e3, C3*1e12, t_bus/T_trama*100);
fprintf('ALCC: %.0f kohm a 5.0 V.\n', Ra/1e3);

R = struct('C5', C5, 'C3', C3, 'R5', R5, 'R3', R3, 'Rp5', Rp5, 'Rp3', Rp3, 'tr5', tr5, 'tr3', tr3, ...
    't_bus', t_bus, 'R_alcc', Ra);
save('pullups_electrico.mat', 'R');
