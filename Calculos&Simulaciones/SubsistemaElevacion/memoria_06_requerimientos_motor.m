%% MEMORIA 06 - Requerimientos del motorreductor de tornillo sin fin
% Traduce el par requerido en el pivote actuado (memoria 05) en requisitos
% para el reductor y para el motor, en función de la relación de reducción.
% Las eficiencias por relación son valores de referencia del catálogo técnico
% Motovario VSF (NMRV040, sección 2.5, "Mesh data"); reemplazarlas con las del
% producto candidato cuando se tenga su hoja de datos.
% Requiere cargas_elevacion.mat (memorias 02 y 05).
clear; clc;
run('parametros_elevacion.m');
load('cargas_elevacion.mat');
fprintf('=== MEMORIA 06: REQUERIMIENTOS DEL MOTORREDUCTOR ===\n\n');

%% 1. Variables de diseño (editar)
S        = 1.30;           % factor de seguridad de par (mismo criterio que orientación)
% SUPOSICIÓN: inercia del rotor no publicada en la ficha; valor provisional. Aun con un valor 10 veces mayor el término es < 0.002 N·m.
J_m      = 0.30e-4;        % kg·m^2, inercia del rotor + sin fin (REEMPLAZAR con el motor candidato)
% SUPOSICIÓN: tolerancia de altura de +/- 15 mm (presupuesto de la memoria 10, aceptada por el usuario) (no viene de una norma).
tol_h    = 15;             % mm, tolerancia de altura del plano óptico (propuesta, sin lazo cerrado)
H_med    = [1000 1300];    % mm, rango típico de alturas de medición
% SUPOSICIÓN: holgura de 3 mm alrededor del resorte (valor propio).
d_res    = P.res.OD/2 + 3; % mm, distancia mínima del pivote al plano del motor (resorte + holgura)

% Relaciones y eficiencias de referencia (Motovario NMRV040: dinámica a 1400 rpm y estática)
i_v   = [30   40   50   60   80   100];
% SUPOSICIÓN: eficiencias del Motovario NMRV040 aplicadas al reductor StepperOnline (que no las publica). Además, eta_d
% SUPOSICIÓN: es a 1400 rpm de entrada; a 61.5 rpm la eficiencia real está entre eta_s y eta_d.
eta_d = [0.71 0.66 0.63 0.59 0.53 0.48];
eta_s = [0.45 0.40 0.36 0.32 0.28 0.24];

%% 2. Datos de entrada desde las memorias anteriores
T_out = Tmax;                        % N·m, par máximo en el eje de salida (con resortes)
w_out = w_max;                       % rad/s
n_out = w_out*60/(2*pi);             % rpm
th_max_op = th_max;                  % grados
H_base_ = H_base + (P.A - P.A0);     % mm
fprintf('1. Datos de entrada\n');
fprintf('   Par máximo de salida T_out = %.2f N·m (con resortes)\n', T_out);
fprintf('   Velocidad máxima de salida = %.4f rad/s = %.2f rpm\n', w_out, n_out);
fprintf('   Aceleración angular        = %.4f rad/s^2\n\n', alfa);

%% 3. Requisitos del reductor
T_red = S*T_out;
fprintf('2. Requisitos del reductor\n');
fprintf('   Par admisible de salida >= S·T_out = %.2f N·m\n', T_red);
fprintf('   Autobloqueo (catálogo Motovario): en reposo, eficiencia estática < 0.50;\n');
fprintf('     en movimiento, eficiencia dinámica < 0.40.\n');
% Juego angular admisible sin lazo cerrado, en la altura de medición más baja (peor caso)
thH = asind((H_med - H_base_)/P.L);
jb  = rad2deg(tol_h./(P.L*cosd(thH)));
fprintf('   Juego angular para +/- %d mm sin lazo cerrado: <= %.2f° (a %d mm) y <= %.2f° (a %d mm)\n', ...
        tol_h, jb(1), H_med(1), jb(2), H_med(2));
fprintf('   (Con el lazo cerrado del sensor inercial, el juego no se acumula si el ajuste final se hace siempre en el mismo sentido.)\n');
fprintf('   Carga radial en la salida: hasta %.0f N si el eje del reductor soporta el pivote (reacción de la base)\n', R_base);
fprintf('   Distancia mínima del eje de salida al plano de apoyo del motor: %.1f mm (resorte)\n\n', d_res);

%% 4. Requisitos del motor según la relación
fprintf('3. Requisitos del motor por relación (eficiencias de referencia)\n');
fprintf('%6s %8s %8s %10s %12s %12s %10s %10s\n', 'i', 'eta_d', 'eta_s', 'n_m [rpm]', 'T_arr [N·m]', 'T_mov [N·m]', 'P_out [W]', 'Autobloq.');
for k = 1:numel(i_v)
  i = i_v(k);
  n_m   = n_out*i;
  T_arr = S*T_out/(i*eta_s(k)) + S*J_m*i*alfa;       % arranque desde el reposo (eficiencia estática)
  T_mov = S*T_out/(i*eta_d(k)) + S*J_m*i*alfa;       % en movimiento, a n_m (eficiencia dinámica)
  P_o   = T_out*w_out;
  if eta_s(k) < 0.5, ab = 'SI'; else, ab = 'NO'; end
  fprintf('%6d %8.2f %8.2f %10.1f %12.3f %12.3f %10.2f %10s\n', i, eta_d(k), eta_s(k), n_m, T_arr, T_mov, P_o, ab);
end
fprintf('\n   T_arr: par de retención mínimo del motor a la corriente configurada.\n');
fprintf('   T_mov: par de pull-out mínimo del motor a la velocidad n_m (curva par-velocidad del fabricante).\n');
fprintf('   Término inercial del motor con J_m = %.1e kg·m^2: %.4f N·m (i = 50)\n\n', J_m, S*J_m*50*alfa);

%% 5. Evaluación de un candidato (editar con los datos del catálogo)
cand.nombre = 'StepperOnline NMRVS40-G50-D14 + 34HS31-6004S';
cand.i      = 50;      % relación
cand.eta_d  = 0.63;    % no informada por el fabricante: referencia Motovario NMRV040 i = 50
cand.eta_s  = 0.36;    % no informada por el fabricante: referencia Motovario NMRV040 i = 50
cand.T_red  = 38;      % N·m, par máximo permisible de salida (StepperOnline)
I_nom = 6.0; I_conf = 3.0;               % A, corriente nominal y configurada (50 %)
% SUPOSICIÓN: par de retención proporcional a la corriente configurada.
cand.T_ret  = 4.8*I_conf/I_nom;          % N·m, retención escalada con la corriente (4.8 N·m a 6 A)
% Pull-out: curva OYOSTEPPER del 34HS31-6004S (driver DM860T, 48 V, 6 A RMS, 2000 micropasos).
% A n_m ~ 61.5 rpm (~2.05 kpps) la curva de 48 V da ~3.85 N·m. ESTIMACIÓN para 24 V y 3 A:
% (a) bajo la velocidad de esquina el par es ~proporcional a la corriente -> x I_conf/6;
% (b) la velocidad de esquina escala con V/(L·I): 24/(L·3) = 48/(L·6), igual que la curva,
%     y la curva es plana hasta ~150-200 rpm, por lo que 61.5 rpm sigue en la zona plana.
% SUPOSICIÓN: lectura aproximada de la curva (48 V, 6 A) y escalado lineal con la corriente a 24 V y 3 A. No es dato del fabricante.
T_po_48V_6A = 3.85;                      % N·m, leído de la curva a ~2 kpps
cand.T_po   = T_po_48V_6A*I_conf/I_nom;  % N·m, estimación (no es dato del fabricante a 24 V)
cand.juego  = NaN;     % grados, no informado por el fabricante
fprintf('4. Evaluación del candidato: %s\n', cand.nombre);
n_m = n_out*cand.i;
if isnan(cand.eta_s)
  eta_s_c = cand.eta_d*(0.36/0.63);   % estimación con la proporción ηs/ηd de NMRV040 i = 50
  fprintf('   eta_s no informada: se estima %.3f (proporción ηs/ηd de referencia)\n', eta_s_c);
else
  eta_s_c = cand.eta_s;
end
T_arr = S*T_out/(cand.i*eta_s_c) + S*J_m*cand.i*alfa;
T_mov = S*T_out/(cand.i*cand.eta_d) + S*J_m*cand.i*alfa;
chk = {'NO CUMPLE','CUMPLE'};
fprintf('   Reductor: %.1f N·m admisibles >= %.2f N·m -> %s\n', cand.T_red, T_red, chk{(cand.T_red >= T_red) + 1});
fprintf('   Autobloqueo estático (eta_s = %.2f < 0.50) -> %s\n', eta_s_c, chk{(eta_s_c < 0.5) + 1});
fprintf('   Autobloqueo dinámico (eta_d = %.2f < 0.40) -> %s\n', cand.eta_d, chk{(cand.eta_d < 0.4) + 1});
if cand.eta_d >= 0.4
  fprintf('     -> Sin autobloqueo dinámico: mantener corriente de retención en el driver (ver texto).\n');
end
% Verificación de que la corriente alcanza su valor en cada paso (criterio L·I/V frente al periodo de paso)
V = 24; L_f = 3.8e-3; R_f = 0.42;      % V, H, ohm (ficha 34HS31-6004S)
f_paso = n_m/60*200;                   % pasos completos por segundo
% SUPOSICIÓN: criterio aproximado L·I/V para el tiempo de subida de la corriente (ignora la f.c.e.m. y la resistencia).
t_sub  = L_f*I_conf/V;                 % s, tiempo aproximado de subida de corriente
fprintf('   Frecuencia de paso completo a %.1f rpm = %.0f Hz (periodo %.2f ms); subida de corriente L·I/V = %.2f ms\n', ...
        n_m, f_paso, 1000/f_paso, 1000*t_sub);
fprintf('   Velocidad del motor: %.1f rpm\n', n_m);
fprintf('   Retención: %.2f N·m >= %.3f N·m -> %s (%.2f veces el requerido con S; %.2f sin S)\n', cand.T_ret, T_arr, chk{(cand.T_ret >= T_arr) + 1}, cand.T_ret/T_arr, cand.T_ret/T_arr*S);
if isnan(cand.T_po)
  fprintf('   Pull-out: PENDIENTE (requiere >= %.3f N·m a %.0f rpm)\n', T_mov, n_m);
else
  fprintf('   Pull-out: %.2f N·m >= %.3f N·m -> %s (%.2f veces el requerido con S; %.2f sin S)\n', cand.T_po, T_mov, chk{(cand.T_po >= T_mov) + 1}, cand.T_po/T_mov, cand.T_po/T_mov*S);
  fprintf('   Pull-out con la eficiencia estática como cota a baja velocidad: %.2f N·m >= %.3f N·m -> %s (FS = %.2f)\n', cand.T_po, T_arr, chk{(cand.T_po >= T_arr) + 1}, cand.T_po/T_arr);
end
if isnan(cand.juego)
  fprintf('   Juego: no informado (referencia Motovario tamaño 040: 18-34 arcmin)\n');
else
  fprintf('   Juego: %.1f° -> Δh sin lazo = %.1f mm a %d mm de altura\n', cand.juego, P.L*cosd(thH(1))*deg2rad(cand.juego), H_med(1));
end
