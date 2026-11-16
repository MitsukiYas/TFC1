%% PARAMETROS_ELECTRICO  Datos de entrada comunes a las memorias de calculo del
% subsistema electrico (capitulo 6). Lo ejecutan las demas memorias con
% run('parametros_electrico.m'). Unidades SI (V, A, ohm, F, H, W, m, s) salvo indicacion.
%
% Los valores salen de TFC/cap6/603 y 606 y de las hojas de datos citadas alli.
% Las entradas marcadas SUPOSICION no las fija el texto y deben confirmarse.

%% ---------------- Bateria 7S (606) ----------------
E.bat.V_corte   = 17.5;   % V, 2.5 V por celda, corte de la celda INR18650-30Q
E.bat.V_min     = 21.0;   % V, agotamiento seguro de diseno (3.0 V por celda)
E.bat.V_nom     = 25.2;   % V, nominal
E.bat.V_max     = 29.4;   % V, carga completa (4.2 V por celda)
E.bat.I_carga_max = 9.0;  % A, corriente de carga maxima del paquete CM Batteries 7S3P
E.bat.I_carga_std = 4.5;  % A, corriente de carga estandar

%% ---------------- Corrientes del sistema (603, 606) ----------------
E.I_demanda_max = 18;     % A, mayor demanda simultanea de la barra de actuadores
E.I_fusible     = 20;     % A, fusible principal de tipo lento

%% ---------------- Diodo TVS SMBJ30A (Vishay, hoja de datos 88392) ----------------
E.tvs.V_WM      = 30.0;   % V, tension de trabajo
E.tvs.V_BR_min  = 33.3;   % V, ruptura minima a 1 mA
E.tvs.V_BR_max  = 36.8;   % V, ruptura maxima a 1 mA
E.tvs.V_C       = 48.4;   % V, limitacion maxima a I_PP
E.tvs.I_PP      = 12.4;   % A, corriente de pico con la onda 10/1000 us
E.tvs.P_PPM     = 600;    % W, potencia de pico con la onda 10/1000 us
E.tvs.t_mitad   = 1.0e-3; % s, la onda 10/1000 us decae al 50 % en 1 ms

%% ---------------- Limites de los dispositivos en la entrada ----------------
E.lim.V_DS_DMP4015 = 40;  % V, MOSFET de proteccion de polaridad DMP4015SPS (Diodes DS35518)
E.lim.V_LTC2944    = 65;  % V, maximo absoluto de SENSE+ del LTC2944 (2944fa)
E.lim.V_TPS54540   = 42;  % V, entrada maxima del TPS54540
E.lim.V_TPS54560   = 60;  % V, entrada maxima de operacion del TPS54560

%% ---------------- Cableado ----------------
mu0 = 4*pi*1e-7;          % H/m
% Longitud de los cables (decision del usuario, 2026-11-15): 300 mm, sujeta a cambio.
E.cable.l = 0.300;        % m, cable de bateria (ida y vuelta, cada conductor) y cable hacia las cargas
% SUPOSICION: conductores AWG 12 (diametro 2.053 mm) para 20 A; el texto no fija la seccion.
E.cable.r = 2.053e-3/2;   % m, radio del conductor
% SUPOSICION: separacion entre centros de los dos conductores, de 3 mm (pegados)
% a 25 mm (sueltos). Se toma el caso de mayor inductancia.
E.cable.D = [3 25]*1e-3;  % m

%% ---------------- Temperatura ----------------
E.T_int = 50;             % grados C, temperatura interna maxima de diseno de los gabinetes (606)
