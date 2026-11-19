%% MEMORIA 07 - SOPORTE DEL SERVOMOTOR DE DIRECCIÓN EN EL EXTREMO DEL TRAVESAÑO DELANTERO
% Silla en U de 6061-T6 de 4 mm que abraza el extremo del travesaño 2020 (20 mm de ancho): placa superior
% con la base del servo y dos labios laterales apoyados en las caras del perfil. Se atornilla con dos M5
% en la ranura superior (y = -25 y -5 mm). El par del servo (eje vertical) se reacciona como par de
% fuerzas entre labios y caras del perfil.
clear; clc;
T_s  = 2.35;      % N·m, par de bloqueo a 6.5 V (tabla de comparación de servomotores, 505)
L_s  = 0.040;     % m, SUPOSICIÓN: distancia en y entre los puntos de apoyo de los dos labios
F    = T_s/L_s;   % N
b    = 0.010;     % m, SUPOSICIÓN: largo de contacto de cada labio sobre el perfil
t    = 0.004;     % m, espesor del labio
h    = 0.010;     % m, altura de aplicación (mitad de los 20 mm de la cara del perfil)
sig  = 6*(F*h)/(b*t^2);               % Pa, flexión en la raíz del labio
Fadm = 240e6/1.65;                    % Pa, Fty(6061-T6)/1.65
fprintf('Fuerza en cada labio: %.1f N\n', F);
fprintf('Flexión en la raíz del labio: %.1f MPa frente a %.0f MPa, FS = %.1f\n', sig/1e6, Fadm/1e6, Fadm/sig);
fprintf('Presión de contacto labio-perfil: %.2f MPa\n', F/(b*h)/1e6);
% Reacción del suelo en el pivote (modelo memoria_04, rueda delantera)
fprintf('Carga vertical por rueda delantera (modelo): 39.6 N estático, 79.3 N con kd = 2\n');
% Espacio entre el borde del bastidor y el plano interior de la rueda
s = 100; ancho_rueda = 55;
fprintf('Espacio libre bastidor-rueda: %.1f mm\n', s - ancho_rueda/2);
fprintf('Excentricidad del pivote (12 mm por dentro de la cara interior de la rueda) respecto al plano de la rueda: %.0f mm (505 usa 15 mm)\n', ancho_rueda/2 + 12);
