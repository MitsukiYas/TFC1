%% MEMORIA 04 - Filtro pi a la salida del LTC4364-2
% Frecuencia de resonancia, amortiguamiento, impedancia de salida, atenuacion a la frecuencia
% de conmutacion del TPS54540 (500 kHz), corriente de la bobina y condensadores ceramicos.
% (TFC/cap6/606, PENDIENTE del filtro pi.)
%
% Topologia: nodo A (salida del LTC4364: electrolitico C1 + ceramico) - bobina L - nodo B
% (electrolitico C2 + ceramico) - convertidores TPS54540 y LMR33630.
%
% Fuentes: hoja de datos SAMXON GT (470 uF, 50 V, 10 x 30 mm: impedancia maxima 0.043 ohm a
% 100 kHz y 20 C; tan(delta) 0.10 a 120 Hz; tolerancia +-20 %); hoja de datos LTC4364
% (ceramicos a la salida hasta un decimo del electrolitico); memorias 01 y 03.
% Formulas de circuitos LC (resonancia, factor de calidad, divisor de impedancias).
clear; clc;
run('parametros_electrico.m');
load('demanda_electrico.mat', 'D');
load('limitador_electrico.mat', 'R'); R03 = R; clear R;
msg = {'NO CUMPLE', 'CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 04: FILTRO PI ===\n\n');

%% 0. Datos
L_f   = 4.7e-6;            % H (606)
C_el  = 470e-6;            % F, cada electrolitico (606)
tol_C = 0.20;              % tolerancia del electrolitico
ESR_100k = 0.043;          % ohm, impedancia maxima a 100 kHz (a esa frecuencia, 1/(wC) = 3.4 mohm: es la ESR)
tand_120 = 0.10;           % factor de disipacion a 120 Hz, 50 V
ESR_120 = tand_120/(2*pi*120*C_el);
% SUPOSICION: inductancia serie del electrolitico radial de 10 mm, 15 nH (la hoja de datos no la da).
ESL_el = 15e-9;
% SUPOSICION: ceramico multicapa X7R: ESR 5 mohm, ESL 1 nH.
ESR_ce = 5e-3; ESL_ce = 1e-9;
f_sw = 500e3;              % Hz, TPS54540 (606)
f_sw_rng = [450e3 550e3];
V_min = 20.84;             % V, minimo de la linea protegida
I_carga = D.I_prot_max;    % A
P_in = I_carga*V_min;      % W, potencia que toman los convertidores en el caso mas severo
% Fuente que alimenta el nodo A: los dos FDMS86150 y la resistencia de deteccion (memoria 03).
R_src = 2*4.85e-3 + R03.R_sns;
fprintf('0. ESR del electrolitico: <= %.3f ohm a 100 kHz; %.2f ohm a 120 Hz (de tan delta)\n', ESR_100k, ESR_120);
fprintf('   Entre ambas frecuencias la ESR decrece; se usa %.3f ohm, el valor de menor amortiguamiento.\n\n', ESR_100k);

%% 1. Resonancia y amortiguamiento (L con C2, la rama del lado de los convertidores)
C_rng = C_el*[1-tol_C 1 1+tol_C];
f0 = 1./(2*pi*sqrt(L_f*C_rng));
Z0 = sqrt(L_f./C_rng);
Q = Z0/ESR_100k;
fprintf('1. Resonancia L-C2: %.2f kHz (%.2f a %.2f kHz con la tolerancia de C2)\n', f0(2)/1e3, f0(3)/1e3, f0(1)/1e3);
fprintf('   Impedancia caracteristica %.3f ohm; factor de calidad con la ESR: %.2f (%.2f a %.2f)\n', Z0(2), Q(2), Q(3), Q(1));
fprintf('   f_sw / f0 = %.0f: la conmutacion queda %.1f decadas por encima de la resonancia\n\n', f_sw/f0(2), log10(f_sw/f0(2)));

%% 2. Modelo en frecuencia
f = logspace(2, 7, 4000); w = 2*pi*f;
Zel = @(w) ESR_100k + 1i*w*ESL_el + 1./(1i*w*C_el);
Zce = @(w, C) ESR_ce + 1i*w*ESL_ce + 1./(1i*w*C);
par = @(a, b) a.*b./(a + b);
ZL = 1i*w*L_f;
C_ce_op = [0 100e-9 1e-6 4.7e-6 10e-6 22e-6];   % opciones de ceramico en cada nodo
fprintf('2. Atenuacion y impedancia de salida segun el ceramico de cada nodo\n');
fprintf('   (atenuacion de tension A->B; Zout en B hasta %.0f kHz, con fuente ideal y con R_src = %.0f mohm)\n', f_sw/10/1e3, R_src*1e3);
fprintf('   %10s %12s %12s %12s %14s %14s\n', 'Ceramico', 'At. 450k', 'At. 500k', 'At. 550k', 'Zout,max (0)', 'Zout,max (Rs)');
At = zeros(numel(C_ce_op), 3); Zmax = zeros(numel(C_ce_op), 2);
for k = 1:numel(C_ce_op)
    if C_ce_op(k) == 0
        Zn = Zel(w);
    else
        Zn = par(Zel(w), Zce(w, C_ce_op(k)));
    end
    H = Zn./(ZL + Zn);                         % tension: nodo A -> nodo B
    Zout0 = par(Zn, ZL);                       % fuente ideal en A
    Zout1 = par(Zn, ZL + par(Zn, R_src));      % nodo A con el mismo banco y la fuente R_src
    At(k,:) = 20*log10(abs(interp1(f, H, [f_sw_rng(1) f_sw f_sw_rng(2)])));
    % La interaccion con el lazo de control de los convertidores ocurre muy por debajo de la
    % frecuencia de conmutacion: se busca el pico de Zout hasta f_sw/10 (alrededor de f0).
    m = f <= f_sw/10;
    Zmax(k,:) = [max(abs(Zout0(m))) max(abs(Zout1(m)))];
    fprintf('   %8.1f uF %10.1f dB %10.1f dB %10.1f dB %12.3f ohm %12.3f ohm\n', C_ce_op(k)*1e6, At(k,1), At(k,2), At(k,3), Zmax(k,1), Zmax(k,2));
end
% Ideal (sin parasitos), para comparar
H_id = 1/(1 - (f_sw/f0(2))^2);
fprintf('   LC ideal sin parasitos: %.1f dB a 500 kHz\n', 20*log10(abs(H_id)));
fprintf('   Por encima de la resonancia, la ESR y la ESL del electrolitico fijan la atenuacion; el\n');
fprintf('   ceramico la mejora mientras su impedancia sea menor que la ESR del electrolitico.\n');
C_ce_min = 1/(2*pi*f_sw*ESR_100k);
fprintf('   Capacidad a la que el ceramico iguala la ESR del electrolitico a 500 kHz: %.1f uF\n\n', C_ce_min*1e6);

%% 2b. Sensibilidad a la ESL del electrolitico y a la perdida de capacidad del ceramico
% El ceramico y la ESL del electrolitico forman una antirresonancia en 1/(2 pi sqrt(ESL C)). Si cae
% cerca de 500 kHz, el ceramico empeora la atenuacion. La ESL no la da la hoja de datos y la
% capacidad efectiva de un X7R baja con la tension continua aplicada; se recorren ambos.
ESL_rng = [10 15 20]*1e-9;
k_dc = [0.5 1.0];   % fraccion de la capacidad nominal que queda con la tension continua
C_nom = [10e-6 22e-6 2*22e-6];
fprintf('2b. Atenuacion a 450 / 500 / 550 kHz (peor de las tres) segun ESL y capacidad efectiva\n');
fprintf('   %16s', 'Ceramico nominal'); fprintf(' | ESL %2.0f nH: 50%% / 100%%', ESL_rng*1e9); fprintf('\n');
At_s = zeros(numel(C_nom), numel(ESL_rng), numel(k_dc));
fs = [f_sw_rng(1) f_sw f_sw_rng(2)]; ws = 2*pi*fs;
for a = 1:numel(C_nom)
    fprintf('   %13.0f uF', C_nom(a)*1e6);
    for b = 1:numel(ESL_rng)
        for c = 1:numel(k_dc)
            Zel_b = ESR_100k + 1i*ws*ESL_rng(b) + 1./(1i*ws*C_el);
            Zn = par(Zel_b, Zce(ws, k_dc(c)*C_nom(a)));
            At_s(a,b,c) = max(20*log10(abs(Zn./(1i*ws*L_f + Zn))));
        end
        fprintf(' | %8.1f / %6.1f dB', At_s(a,b,1), At_s(a,b,2));
    end
    fprintf('\n');
end
fprintf('   Sin ceramico:');
for b = 1:numel(ESL_rng)
    Zel_b = ESR_100k + 1i*ws*ESL_rng(b) + 1./(1i*ws*C_el);
    fprintf(' ESL %2.0f nH: %.1f dB;', ESL_rng(b)*1e9, max(20*log10(abs(Zel_b./(1i*ws*L_f + Zel_b)))));
end
fprintf('\n\n');

%% 3. Limite de ceramicos a la salida del LTC4364 (nodo A)
C_ce_max_A = C_el/10;
fprintf('3. Nodo A: ceramicos hasta %.0f uF (un decimo del electrolitico, LTC4364)\n\n', C_ce_max_A*1e6);

%% 4. Estabilidad con los convertidores (resistencia de entrada negativa)
% Un convertidor regulado toma potencia constante: su resistencia de entrada incremental es
% -V^2/P. La impedancia de salida del filtro debe ser mucho menor que ese valor.
% PENDIENTE: fuente bibliografica (criterio de Middlebrook) si se cita en el .tex.
R_in = V_min^2/P_in;
fprintf('4. Resistencia de entrada de los convertidores: -%.1f ohm (%.1f W a %.2f V)\n', R_in, P_in, V_min);
for k = 1:numel(C_ce_op)
    fprintf('   Ceramico %4.1f uF: Zout,max %.3f ohm, %.0f veces menor (%.0f dB)\n', C_ce_op(k)*1e6, Zmax(k,1), R_in/Zmax(k,1), 20*log10(R_in/Zmax(k,1)));
end
fprintf('\n');

%% 5. Bobina
% Corriente continua: la demanda maxima. Pico: el limite de corriente del LTC4364 (memoria 03),
% que acota tambien el arranque y un cortocircuito a la salida del filtro.
I_L_dc = I_carga;
I_L_pk = R03.I_lim(3);
fprintf('5. Bobina de %.1f uH\n', L_f*1e6);
fprintf('   Corriente continua %.2f A; pico %.2f A (limite maximo del LTC4364)\n', I_L_dc, I_L_pk);
fprintf('   Corriente de saturacion requerida > %.2f A (606 indicaba > 12 A, para el limite anterior de 10 A)\n', I_L_pk);
fprintf('   Resistencia de la bobina: por cada 10 mohm, %.1f mW y %.1f mV\n\n', I_L_dc^2*10e-3*1e3, I_L_dc*10e-3*1e3);

%% 6. Resumen
% Ceramicos adoptados: 22 uF X7R de 50 V por nodo (decision del usuario, 2026-11-15).
k10 = find(C_ce_op == 22e-6);
fprintf('=== RESUMEN ===\n');
fprintf('Resonancia %.2f kHz (%.2f a %.2f kHz); Q = %.1f con la ESR de %.0f mohm.\n', f0(2)/1e3, f0(3)/1e3, f0(1)/1e3, Q(2), ESR_100k*1e3);
fprintf('Atenuacion a 500 kHz: %.1f dB sin ceramicos; %.1f dB con 22 uF en cada nodo.\n', At(1,2), At(k10,2));
fprintf('Zout,max %.3f ohm frente a %.1f ohm de los convertidores.\n', Zmax(k10,1), R_in);
fprintf('Bobina: saturacion > %.2f A, corriente continua %.2f A.\n', I_L_pk, I_L_dc);

R = struct('f0', f0, 'Z0', Z0, 'Q', Q, 'C_ce_op', C_ce_op, 'At', At, 'Zout_max', Zmax, ...
    'R_in', R_in, 'C_ce_min', C_ce_min, 'C_ce_max_A', C_ce_max_A, 'I_L_dc', I_L_dc, 'I_L_pk', I_L_pk);
save('filtro_electrico.mat', 'R');
