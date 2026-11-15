%% MEMORIA 10 - Errores mecánicos de altura del plano óptico (tolerancia +/- 15 mm, decisión del usuario)

% H = z_p + L·sin(theta) + A + z_c  ->  dH = L·cos(theta)·(d_theta_s + d_theta_b) + e_j + e_d
% Solo se evalúan los términos mecánicos (banda muerta, juego de agujeros y deformación).
% El error del sensor del brazo (d_theta_s) no se calcula aquí: se obtiene el error angular
% que los términos mecánicos dejan disponible para el sensor.
clear; clc;
run('parametros_elevacion.m');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
tol = 15;   % mm, tolerancia de altura (decisión del usuario)
fprintf('=== MEMORIA 10: ERRORES MECÁNICOS DE ALTURA ===\n\n');

%% 1. Errores mecánicos
% SUPOSICIÓN: banda muerta del control de 0.1° en el brazo.
d_banda = deg2rad(0.1);
% Juego en los agujeros con la rosca (opción A): diametral <= 0.25 mm en el apoyo de la base y en el acoplador.
e_juego = 2*0.25;                            % mm, peor caso vertical
% SUPOSICIÓN: deformación elástica de brazos y base <= 1 mm (no calculada: el valor es una cota propia; la memoria 11 solo verifica resistencia).
e_elast = 1.0;
fprintf('1. Mecánicos: banda muerta %.1f°, juego de agujeros %.2f mm, deformación %.1f mm\n\n', rad2deg(d_banda), e_juego, e_elast);

%% 2. Errores mecánicos por altura del plano óptico y error angular disponible para el sensor
H0 = P.H15_0 - P.L0*sind(15) + (P.A - P.A0);   % mm, H(theta = 0) (calibración de la memoria 01)
Hs = [904 1000 1150 1300];
fprintf('2. Error mecánico de altura (suma lineal) y error angular disponible para el sensor\n');
fprintf('%10s %8s %12s %10s %12s %10s %14s\n', 'H (mm)', 'theta', 'banda (mm)', 'juego', 'deformación', 'total', 'sensor adm.');
d_th_adm = inf;
for H = Hs
  th = asin((H - H0)/P.L);
  k = P.L*cos(th);
  e_b = k*d_banda;
  e_mec = e_b + e_juego + e_elast;
  d_s = (tol - e_mec)/k;                      % rad, error angular admisible del sensor a esta altura
  d_th_adm = min(d_th_adm, d_s);
  fprintf('%10.0f %7.1f° %12.2f %10.2f %12.1f %10.1f %13.2f°  %s\n', H, rad2deg(th), e_b, e_juego, e_elast, e_mec, rad2deg(d_s), ok(e_mec <= tol));
end
fprintf('   Error angular admisible del sensor (gobierna la posición baja): %.2f°\n', rad2deg(d_th_adm));
