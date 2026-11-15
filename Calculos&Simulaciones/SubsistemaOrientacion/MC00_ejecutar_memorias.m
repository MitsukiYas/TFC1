% MC00_EJECUTAR_MEMORIAS  Corre en orden las memorias de calculo del
% subsistema de orientacion del piranometro.
%
% Uso: abrir esta carpeta en MATLAB (o GNU Octave) y ejecutar
%   >> MC00_ejecutar_memorias
% Salidas (en la misma carpeta):
%   memoria_calculo_orientacion.txt   reporte completo
%   Tilt_Torques_MATLAB.png           torques a lo largo del barrido
%   Tilt_Eje_MATLAB.png               diagramas de momento flector y torsor
%   resultados_orientacion.mat        estructuras P (datos) y R (resultados)

clear; clc; close all;
carpeta = fileparts(mfilename('fullpath'));
if isempty(carpeta), carpeta = pwd; end
archivo = fullfile(carpeta, 'memoria_calculo_orientacion.txt');
if exist(archivo, 'file'), delete(archivo); end
diary(archivo);

fprintf('MEMORIAS DE CALCULO - SUBSISTEMA DE ORIENTACION DE PIRANOMETRO\n');
fprintf('Generado: %s\n', datestr(now));

R = struct();
P = MC01_datos_entrada();
R = MC02_requisitos_inclinacion(P, R);
R = MC03_cinematica(P, R);
R = MC04_cargas_eje_giro(P, R);
R = MC05_inercia(P, R);
R = MC06_transmision_sinfin(P, R);
R = MC07_torque_trayectoria(P, R, carpeta);
R = MC08_fuerzas_engrane(P, R);
R = MC09_eje_basculante(P, R, carpeta);
R = MC10_rodamientos(P, R);
R = MC11_prisioneros_insertos(P, R);
R = MC12_motor(P, R);
R = MC13_sensibilidad_friccion(P, R);
R = MC14_presupuesto_error(P, R);
R = MC15_condicion_viento(P, R);
MC16_resumen(R);

diary off;
save(fullfile(carpeta, 'resultados_orientacion.mat'), 'P', 'R');
fprintf('\nReporte: %s\n', archivo);
