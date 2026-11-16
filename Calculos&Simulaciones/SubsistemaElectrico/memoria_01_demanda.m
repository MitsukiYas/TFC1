%% MEMORIA 01 - Demanda de corriente de cada linea del subsistema electrico
% Corriente de la barra de actuadores, de la linea de 6.5 V (servomotores), de la linea de
% 5.0 V, de la linea de 3.3 V y de la barra meteorologica, en el caso mas severo y en el
% promedio. Base de las memorias 03 a 09 (TFC/cap6/606, PENDIENTE de la demanda por linea).
%
% Fuentes: los valores del texto de TFC/cap6/603 (seccion de demanda de corriente) y 606
% (balance de energia); motorreductor 42PG-775-67, servomotor RDS3225, E220-900T30D,
% SAM-M8Q, Raspberry Pi 4 y encoders Omron E6B2 segun lo ya escrito alli.
%
% Convenciones del texto que se respetan:
%  - Barra de actuadores: la corriente de los motores de traccion se suma tal cual a la barra
%    (603: "10 A para ambos y unos 10.3 A en la barra"); es una cota, pues con PWM la
%    corriente de la barra es la del motor multiplicada por el ciclo de trabajo.
%  - Convertidores y drivers con eficiencia 0.90; corrientes a 25.2 V salvo indicacion.
%  - Linea de 5.0 V: cotas superiores de la Raspberry Pi (8 W) y del microcontrolador (4 W).
clear; clc;
run('parametros_electrico.m');
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 01: DEMANDA DE CORRIENTE POR LINEA ===\n\n');

%% 0. Datos de entrada (del texto)
eta = 0.90;                 % eficiencia de convertidores y drivers (606, 603)
V_nom = E.bat.V_nom;        % 25.2 V
V_min = E.bat.V_min;        % 21.0 V, barra de actuadores en el peor caso
% Minimo de la linea protegida: 606 la da "de 21.7 a 29.4 V", pero el LTC4364-2 solo desconecta
% por debajo de 20.84 V y la bateria baja hasta 21.0 V; se toma el umbral de desconexion.
V_prot_min = 20.84;         % V
V_5 = 5.0;                  % V
V_serv = 6.5;               % V, linea de servomotores

% Motorreductor 42PG-775-67 (603): <0.7 A en vacio, <6 A a 4.90 N.m; se toman como valores.
M.I0 = 0.7; M.In = 6.0; M.Tn = 4.90; M.I_lim = 8.0;   % A, A, N.m, A (limite del controlador)
M.V = 24; M.n0 = 120; M.nn = 105;                      % V, rpm en vacio, rpm en el punto nominal
T.plano = 0.61; T.pend = 3.97; T.arr = 5.65;           % N.m por rueda (603)
r_rueda = 3.97/(79.4/2);                               % m, radio implicito en 603 (0.10 m)
v_robot = 1.0;                                         % m/s (606)
Imot = @(T) M.I0 + (M.In - M.I0)/M.Tn*T;               % relacion lineal corriente-torque

% Motores paso a paso, corriente en la barra (603)
S.I_orient_mov = 0.15;      % A, orientacion en movimiento
S.I_elev_mov   = 0.55;      % A, elevacion en movimiento a 4.20 A de pico
S.P_ret_orient = 0.69;      % W, retencion al 50 % (0.73^2 * 1.30)
S.P_ret_elev   = 1.85;      % W, retencion al 50 % (2.10^2 * 0.42)

% Servomotores RDS3225 (603)
V.N = 2; V.I_bloq = 2.3; V.I_rep = 5e-3;   % unidades, A (a 6.5 V), A en reposo

% Linea de 5.0 V (606)
L5.P_rpi = 8.0; L5.P_mcu = 4.0; L5.P_imu = 0.15; L5.P_enc = 1.2;   % W
L5.I_gnss = 0.029;                          % A, a 3.3 V; el LM1084 lo toma igual de 5.0 V
L5.I_lora_rx = 0.0172; L5.I_lora_tx = 0.620; L5.duty_tx = 0.10;
I_3_dis = 0.15;   % A, carga con que 606 dimensiona el LM1084-3.3 (incluye margen)
% Meteorologica (606)
W.I_max = 0.300;            % A por salida (3 instrumentos de 100 mA)
W.dropout = 1.85;           % V, regulador lineal de seguimiento
W.V_sal = [3.3 5.0 12.0];   % V, salidas posibles

%% 1. Barra de actuadores
fprintf('1. BARRA DE ACTUADORES (a %.1f V)\n', V_nom);
I_serv_bar = @(I_serv, Vb) V.N*I_serv*V_serv/(eta*Vb);   % corriente que toma el convertidor de 6.5 V
I_ret = (S.P_ret_orient + S.P_ret_elev)/eta/V_nom;
I_rep_bar = I_ret + I_serv_bar(V.I_rep, V_nom);
fprintf('   Reposo (retencion 50 %% + servos): %.3f A\n', I_rep_bar);

casos = {'Avance en plano a 1 m/s', T.plano; 'Subida de 16 grados a 1 m/s', T.pend; 'Arranque en la pendiente', T.arr};
I_trac = zeros(1,3);
for k = 1:3
    Im = Imot(casos{k,2});
    I_trac(k) = 2*Im;
    fprintf('   %s: %.2f N.m por rueda, %.2f A por motor, %.2f A ambos\n', casos{k,1}, casos{k,2}, Im, I_trac(k));
end
fprintf('   Son corrientes de motor; con PWM la barra entrega V_motor*I/V_barra (ver punto 7).\n');
fprintf('   Sumarlas tal cual a la barra, como hace 603, es una cota superior.\n');
I_bar_arr = I_trac(3) + I_rep_bar;
fprintf('   Barra en el arranque en pendiente: %.2f A (603: 13.9 A)\n', I_bar_arr);

% Caso mas severo: a la tension nominal y con la barra minima (la carga de potencia constante pide mas)
I_sev_nom = 2*M.I_lim + S.I_elev_mov + S.I_orient_mov + I_serv_bar(V.I_bloq, V_nom);
I_sev_min = 2*M.I_lim + (S.I_elev_mov + S.I_orient_mov)*V_nom/V_min + I_serv_bar(V.I_bloq, V_min);
fprintf('   Caso mas severo a %.1f V: %.2f A (603: 18 A)\n', V_nom, I_sev_nom);
fprintf('   Caso mas severo a %.1f V (cargas de potencia constante): %.2f A\n\n', V_min, I_sev_min);

%% 2. Linea de 6.5 V (servomotores)
I_6_max = V.N*V.I_bloq; I_6_rep = V.N*V.I_rep;
fprintf('2. LINEA DE %.1f V (servomotores)\n', V_serv);
fprintf('   Maxima (ambos en bloqueo): %.2f A; en reposo: %.3f A\n', I_6_max, I_6_rep);
fprintf('   Entrada del convertidor: %.2f A a %.1f V; %.2f A a %.1f V\n', I_serv_bar(V.I_bloq, V_nom), V_nom, I_serv_bar(V.I_bloq, V_min), V_min);
fprintf('   TPS54560 (corriente de salida maxima 5 A): %s\n\n', ok(I_6_max < 5));

%% 3. Linea de 5.0 V
I_base_5 = (L5.P_rpi + L5.P_mcu + L5.P_imu + L5.P_enc)/V_5;
I_lora_med = (1-L5.duty_tx)*L5.I_lora_rx + L5.duty_tx*L5.I_lora_tx;
% La linea de 3.3 V sale de la de 5.0 V por un regulador lineal: su corriente se suma igual.
I_prom_5 = I_base_5 + L5.I_gnss + I_lora_med;   % promedio con la carga identificada de 3.3 V
I_max_5  = I_base_5 + I_3_dis + L5.I_lora_tx;   % maximo con la carga de diseno de 3.3 V
fprintf('3. LINEA DE 5.0 V (salida del TPS54540)\n');
fprintf('   Promedio (LoRa con ciclo de 10 %%, 3.3 V con el GNSS): %.2f A, %.1f W (606: 13.9 W)\n', I_prom_5, I_prom_5*V_5);
fprintf('   Maxima (LoRa transmitiendo de continuo, 3.3 V con %.2f A): %.2f A, %.1f W\n', I_3_dis, I_max_5, I_max_5*V_5);
I_in5_prom = I_prom_5*V_5/eta/V_nom;
I_in5_max  = I_max_5*V_5/eta/V_prot_min;
fprintf('   Entrada del convertidor: promedio %.2f A a %.1f V; maxima %.2f A a %.1f V\n', I_in5_prom, V_nom, I_in5_max, V_prot_min);
fprintf('   TPS54540 (corriente de salida maxima 5 A): %s\n\n', ok(I_max_5 < 5));

%% 4. Linea de 3.3 V
I_3_ident = L5.I_gnss;
fprintf('4. LINEA DE 3.3 V (LM1084-3.3, desde la linea de 5.0 V)\n');
fprintf('   Carga identificada (GNSS): %.3f A; valor de diseno de 606: %.2f A\n', I_3_ident, I_3_dis);
fprintf('   Potencia disipada en el LM1084 con %.2f A: %.2f W (606: 0.26 W)\n', I_3_dis, (V_5-3.3)*I_3_dis);
fprintf('   Esta corriente ya esta incluida en la de 5.0 V (regulador lineal).\n\n');

%% 5. Barra meteorologica
fprintf('5. BARRA METEOROLOGICA (%.0f mA por salida)\n', W.I_max*1e3);
for k = 1:numel(W.V_sal)
    P_in = (W.V_sal(k) + W.dropout)*W.I_max/eta;
    fprintf('   %4.1f V: %.1f W en la entrada; %.3f A a %.1f V, %.3f A a %.1f V\n', W.V_sal(k), P_in, P_in/V_nom, V_nom, P_in/V_prot_min, V_prot_min);
end
I_met = W.I_max;
fprintf('   Conexion directa a la linea protegida: %.2f A a cualquier tension (%.1f W a %.1f V)\n', I_met, I_met*V_nom, V_nom);
fprintf('   Se adopta %.2f A, el mayor, en el promedio y en el caso severo.\n\n', I_met);

%% 6. Linea protegida (entrada del LTC4364-2): convertidor de 5.0 V + meteorologica
I_prot_max  = I_in5_max + I_met;
I_prot_prom = I_in5_prom + I_met;
fprintf('6. LINEA PROTEGIDA (LTC4364-2, filtro pi)\n');
fprintf('   Maxima: %.2f A (a %.1f V); promedio: %.2f A\n\n', I_prot_max, V_prot_min, I_prot_prom);

%% 7. Promedio total en la bateria
P_trac_med = 77.6;   % W, 606
P_total = P_trac_med + S.P_ret_orient + S.P_ret_elev + 0.07 + 15.4 + 7.6;   % W, como en 606
fprintf('7. PROMEDIO EN LA BATERIA\n');
fprintf('   Potencia %.1f W (606: 103.2 W); corriente a %.1f V: %.2f A (606: 4.10 A)\n', P_total, V_nom, P_total/V_nom);
% Estimacion alternativa de la traccion media con un modelo de motor de corriente continua,
% V = ke*w + R*I, ajustado a los dos puntos del fabricante a 24 V (vacio y nominal), ambos
% referidos al eje de salida del reductor. kt = T/(I - I0) es menor que ke porque incluye la
% eficiencia del reductor (kt/ke). La potencia electrica es V_motor*I, que con PWM es la que
% entrega la barra (sin las perdidas de los controladores).
w = @(n) n*2*pi/60;
x = [w(M.n0) M.I0; w(M.nn) M.In] \ [M.V; M.V];
ke = x(1); R_m = x(2); kt = M.Tn/(M.In - M.I0);
w_r = v_robot/r_rueda;
Pmot = @(T) (ke*w_r + R_m*Imot(T))*Imot(T);            % W por motor a 1 m/s
n24 = @(T) (M.V - R_m*Imot(T))/ke*60/(2*pi);            % rpm con 24 V aplicados
fprintf('   Modelo del motor: R = %.3f ohm, ke = %.3f V.s/rad, kt = %.3f N.m/A (kt/ke = %.2f)\n', R_m, ke, kt, kt/ke);
fprintf('   Comprobacion: en la pendiente gira a %.0f rpm con 24 V (603: 108 rpm)\n', n24(T.pend));
P_pl = 2*Pmot(T.plano); P_pe = 2*Pmot(T.pend);
fprintf('   A %.1f m/s: plano %.1f W (606: %.1f W), pendiente %.1f W (606: %.1f W)\n', v_robot, P_pl, 12.3/0.374, P_pe, 79.4/0.374);
P_trac_mod = 0.75*P_pl + 0.25*P_pe;
P_total_mod = P_total - P_trac_med + P_trac_mod;
I_med_mod = P_total_mod/V_nom;
C_mod = I_med_mod*1.0/(0.80*0.95)*1.25;   % misma expresion y factores que 606
fprintf('   Traccion media: %.1f W frente a %.1f W; total %.1f W, %.2f A\n', P_trac_mod, P_trac_med, P_total_mod, I_med_mod);
fprintf('   Capacidad requerida con ese valor: %.2f Ah (606: 6.74 Ah; bateria elegida: 8.85 Ah minimos): %s\n\n', C_mod, ok(C_mod <= 8.85));

%% 8. Corriente total de la bateria en el caso mas severo y fusible
I_5_nom = I_max_5*V_5/eta/V_nom;
I_tot_nom = I_sev_nom + I_5_nom + I_met;
I_tot_min = I_sev_min + I_in5_max + I_met;   % entrada de 5.0 V con la linea protegida en 20.84 V (cota)
fprintf('8. CORRIENTE TOTAL DE LA BATERIA EN EL CASO MAS SEVERO\n');
fprintf('   A %.1f V: %.2f A (barra %.2f + 5.0 V %.2f + meteorologica %.2f)\n', V_nom, I_tot_nom, I_sev_nom, I_5_nom, I_met);
fprintf('   A %.1f V: %.2f A\n', V_min, I_tot_min);
fprintf('   Fusible de %.0f A: margen %.1f %% a %.1f V y %.1f %% a %.1f V\n', E.I_fusible, (1-I_tot_nom/E.I_fusible)*100, V_nom, (1-I_tot_min/E.I_fusible)*100, V_min);
fprintf('   El parrafo del fusible de 606 cita los 18 A de la barra; 603 (parada de emergencia) ya habla de unos 19 A.\n');
fprintf('   Rango del LTC2944 (25 A): %s\n\n', ok(I_tot_min < 25));

%% 9. Resumen
fprintf('=== RESUMEN (A) ===\n');
fprintf('%-34s %10s %10s\n', 'Linea', 'Promedio', 'Maxima');
fprintf('%-34s %10.2f %10.2f\n', 'Barra de actuadores (25.2 V)', (P_trac_med + S.P_ret_orient + S.P_ret_elev + 0.07)/V_nom, I_sev_nom);
fprintf('%-34s %10.3f %10.2f\n', '6.5 V (salida)', I_6_rep, I_6_max);
fprintf('%-34s %10.2f %10.2f\n', '5.0 V (salida)', I_prom_5, I_max_5);
fprintf('%-34s %10.3f %10.2f\n', '3.3 V (salida; diseno)', I_3_ident, I_3_dis);
fprintf('%-34s %10.2f %10.2f\n', 'Meteorologica (salida / directa)', I_met, I_met);
fprintf('%-34s %10.2f %10.2f\n', 'Linea protegida (entrada)', I_prot_prom, I_prot_max);
fprintf('%-34s %10.2f %10.2f\n', 'Total en la bateria', P_total/V_nom, I_tot_nom);

D = struct();
D.I_bar_reposo = I_rep_bar; D.I_trac_casos = I_trac; D.I_bar_arranque = I_bar_arr;
D.I_bar_severo_nom = I_sev_nom; D.I_bar_severo_min = I_sev_min;
D.I_6V5_max = I_6_max; D.I_6V5_rep = I_6_rep;
D.I_5V_prom = I_prom_5; D.I_5V_max = I_max_5; D.I_in5_prom = I_in5_prom; D.I_in5_max = I_in5_max;
D.I_3V3_ident = I_3_ident; D.I_3V3_dis = I_3_dis;
D.I_meteo = I_met; D.I_prot_prom = I_prot_prom; D.I_prot_max = I_prot_max;
D.P_total_prom = P_total; D.I_bat_prom = P_total/V_nom;
D.motor = struct('R', R_m, 'ke', ke, 'kt', kt); D.P_trac_mod = P_trac_mod;
D.P_total_mod = P_total_mod; D.I_bat_prom_mod = I_med_mod; D.C_bat_mod = C_mod;
D.I_bat_severo_nom = I_tot_nom; D.I_bat_severo_min = I_tot_min;
save('demanda_electrico.mat', 'D');
