%% MEMORIA 02 - Etapa de entrada: diodo TVS de entrada y diodo de libre circulacion
% Transitorio inductivo al abrir el interruptor de parada de emergencia (MOSFET de canal P)
% con el sistema en carga (TFC/cap6/603, PENDIENTE de la parada de emergencia).
%
% Al abrir el interruptor, la corriente del cableado no puede anularse de inmediato:
%  - Lado de la bateria: la inductancia del cable de bateria eleva la tension del nodo de
%    entrada (entre el punto del cargador y el interruptor). La limita el TVS de entrada.
%  - Lado de las cargas: la inductancia del cableado hacia las cargas lleva el nodo de salida
%    por debajo de tierra. El diodo de libre circulacion (anodo a tierra, catodo a la salida)
%    conduce esa corriente hacia los condensadores de las cargas.
%
% Fuentes: hoja de datos SMBJ5.0A-SMBJ188A (Vishay 88392); DMP4015SPS (Diodes DS35518);
% LTC2944 (2944fa). Inductancia de una linea de dos conductores: formula clasica de
% electromagnetismo (PENDIENTE: fuente bibliografica para citarla en el .tex).
clear; clc;
run('parametros_electrico.m');
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 02: TVS DE ENTRADA Y DIODO DE LIBRE CIRCULACION ===\n\n');

%% 1. Inductancia del cableado
% Linea de dos conductores paralelos de radio r, separados D entre centros, longitud l,
% incluida la inductancia interna de los conductores (1/4 por conductor, en baja frecuencia):
%   L = (mu0*l/pi) * (ln(D/r) + 1/4)
Lfun = @(l, D, r) mu0*l/pi .* (log(D./r) + 0.25);
L_rango = Lfun(E.cable.l, E.cable.D, E.cable.r);
L_cab = max(L_rango);
fprintf('1. Inductancia del cable de %.0f mm (AWG 12):\n', E.cable.l*1e3);
fprintf('   D = %.0f mm: %.3f uH;  D = %.0f mm: %.3f uH\n', E.cable.D(1)*1e3, L_rango(1)*1e6, E.cable.D(2)*1e3, L_rango(2)*1e6);
fprintf('   Se adopta el mayor valor: L = %.3f uH\n\n', L_cab*1e6);

%% 2. Corriente y energia al abrir
% Cota de la corriente interrumpida: 20 A, por encima de la mayor corriente de la bateria,
% 19.6 A con 21.0 V (memoria 01). El fusible es de 25 A (ATOF 0287025) y ya no es la cota.
I0 = E.I_interr;
E_cab = 0.5*L_cab*I0^2;
fprintf('2. Corriente interrumpida: %.0f A (cota de la demanda); energia en el cable: %.1f uJ\n\n', I0, E_cab*1e6);

%% 3. TVS de entrada SMBJ30A
fprintf('3. TVS de entrada SMBJ30A (catodo al nodo de entrada, anodo a tierra)\n');
c1 = E.tvs.V_WM >= E.bat.V_max;
fprintf('   Tension de trabajo %.1f V >= bateria cargada %.1f V: %s\n', E.tvs.V_WM, E.bat.V_max, ok(c1));
c2 = E.tvs.V_BR_min > E.bat.V_max;
fprintf('   Ruptura minima %.1f V > %.1f V (no conduce en operacion normal): %s\n', E.tvs.V_BR_min, E.bat.V_max, ok(c2));

% Tension de limitacion a la corriente interrumpida. La hoja de datos da dos puntos:
% V_BR,max a 1 mA y V_C a I_PP. SUPOSICION: variacion lineal entre ambos para extrapolar a I0.
R_din = (E.tvs.V_C - E.tvs.V_BR_max)/E.tvs.I_PP;
V_C_I0 = E.tvs.V_BR_max + R_din*I0;
fprintf('   Resistencia dinamica estimada: %.3f ohm\n', R_din);
fprintf('   Tension de limitacion estimada a %.0f A: %.1f V (%.1f V a %.1f A segun la hoja de datos)\n', I0, V_C_I0, E.tvs.V_C, E.tvs.I_PP);

% Pulso: la corriente decae linealmente de I0 a 0 con la tension (V_C - V_bat) sobre el cable.
t_tvs = L_cab*I0/(V_C_I0 - E.bat.V_max);
% Energia en el TVS: la del cable mas la que entrega la bateria durante el pulso.
E_tvs = 0.5*I0*t_tvs*V_C_I0;
% Energia de la onda 10/1000 us nominal: decaimiento exponencial al 50 % en 1 ms.
E_nom = E.tvs.P_PPM*E.tvs.t_mitad/log(2);
fprintf('   Duracion del pulso: %.3f us; energia en el TVS: %.1f uJ\n', t_tvs*1e6, E_tvs*1e6);
c3 = E_tvs < E_nom;
fprintf('   Energia nominal de la onda 10/1000 us: %.0f mJ; relacion %.1e: %s\n\n', E_nom*1e3, E_tvs/E_nom, ok(c3));

%% 4. Condensador de entrada que absorbe la energia del cable sin que conduzca el TVS
% La energia del cable carga el condensador desde V_bat,max hasta como maximo V_BR,min:
%   C >= 2 E / (V_BR,min^2 - V_bat,max^2)
C_min_in = 2*E_cab/(E.tvs.V_BR_min^2 - E.bat.V_max^2);
fprintf('4. Capacidad minima en el nodo de entrada para no superar %.1f V: %.2f uF\n\n', E.tvs.V_BR_min, C_min_in*1e6);

%% 5. Tension que deben soportar los dispositivos del nodo de entrada
% Sin el condensador del punto 4, o si este falla, el nodo llega a la limitacion del TVS.
V_nodo = max(V_C_I0, E.tvs.V_C);
fprintf('5. Tension maxima del nodo de entrada (limitada por el TVS): %.1f V\n', V_nodo);
fprintf('   MOSFET de parada de emergencia, tension drenador-fuente requerida >= %.1f V\n', V_nodo);
c5 = V_nodo < E.lim.V_DS_DMP4015;
fprintf('   Una pieza de 40 V, como la DMP4015SPS (%.0f V): %s\n', E.lim.V_DS_DMP4015, ok(c5));
c6 = V_nodo < E.lim.V_LTC2944;
fprintf('   LTC2944, SENSE+ maximo %.0f V: %s\n', E.lim.V_LTC2944, ok(c6));
fprintf('   Diodo de bloqueo del cargador, tension inversa requerida >= %.1f V\n', V_nodo);
% El MOSFET de proteccion de polaridad conduce durante este transitorio (V_DS cercana a 0),
% y su compuerta queda protegida por el Zener de 15 V.
fprintf('   MOSFET de polaridad: conduce durante el transitorio; no queda expuesto\n\n');

%% 6. Diodo de libre circulacion a la salida del interruptor
% Mismo cable supuesto hacia las cargas. La corriente decae sobre la tension de la barra
% (los condensadores de las cargas) mas la caida del diodo; se toma la barra minima.
L_out = L_cab;
E_out = 0.5*L_out*I0^2;
t_fw = L_out*I0/E.bat.V_min;
fprintf('6. Diodo de libre circulacion (anodo a tierra, catodo a la salida del interruptor)\n');
fprintf('   Corriente de pico: %.0f A durante %.3f us; energia %.1f uJ, que pasa a los condensadores de las cargas\n', I0, t_fw*1e6, E_out*1e6);
% En operacion normal el diodo bloquea la tension de la barra; la barra de actuadores
% puede llegar a la limitacion de sus TVS SMBJ30A.
V_RRM_fw = E.tvs.V_C;
fprintf('   Tension inversa requerida >= %.1f V (limitacion de los SMBJ30A de la barra de actuadores)\n', V_RRM_fw);
fprintf('   Corriente de pico no repetitiva requerida >= %.0f A (pulso de %.3f us)\n\n', I0, t_fw*1e6);

%% 7. Resumen
fprintf('=== RESUMEN ===\n');
fprintf('TVS de entrada: SMBJ30A, igual que en los drivers. Energia %.1e veces la nominal.\n', E_tvs/E_nom);
fprintf('Condensador de entrada: >= %.2f uF absorbe la energia del cable sin que conduzca el TVS.\n', C_min_in*1e6);
fprintf('MOSFET de parada de emergencia y diodo de bloqueo: >= %.1f V; con piezas de 40 V no cumple.\n', V_nodo);
fprintf('Diodo de libre circulacion: >= %.1f V inversos y >= %.0f A de pico no repetitivo.\n', V_RRM_fw, I0);

R.L_cable = L_cab; R.I_interrumpida = I0; R.E_cable = E_cab;
R.V_C_tvs = V_C_I0; R.t_tvs = t_tvs; R.E_tvs = E_tvs; R.C_min_entrada = C_min_in;
R.V_nodo_entrada = V_nodo; R.V_RRM_libre = V_RRM_fw; R.t_libre = t_fw;
save('entrada_electrico.mat', 'R');
