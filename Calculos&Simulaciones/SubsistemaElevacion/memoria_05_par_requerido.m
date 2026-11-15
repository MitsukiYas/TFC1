%% MEMORIA 05 - Perfil de movimiento, inercia y par requerido en el pivote actuado
% Perfil trapezoidal, inercia respecto al pivote actuado y par en el eje de
% salida a lo largo del barrido, con pendiente y viento longitudinal.
% Requiere cargas_elevacion.mat (memoria 02). Genera Elev_Torque_MATLAB.png.
clear; clc;
run('parametros_elevacion.m');
load('cargas_elevacion.mat');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 05: PERFIL, INERCIA Y PAR REQUERIDO ===\n\n');

L = P.L/1000; Lt = (P.L + 2*P.voladizo_brazo)/1000;    % m
th0 = P.th_min; th1 = th_max;                            % grados
H = @(th) H_base + (P.A - P.A0) + P.L*sind(th);          % mm, plano óptico

%% 1. Perfil trapezoidal (barrido completo)
dth = deg2rad(th1 - th0);
t_a = P.f_a*P.t_b;
w_max = dth/(P.t_b - t_a);
alfa  = w_max/t_a;
fprintf('1. Perfil de movimiento (barrido completo)\n');
fprintf('   Delta theta = %.2f° (%.4f rad), t_b = %.1f s, t_a = %.2f s\n', th1 - th0, dth, P.t_b, t_a);
fprintf('   w_max = %.4f rad/s (%.2f °/s), alfa = %.4f rad/s^2\n', w_max, rad2deg(w_max), alfa);
fprintf('   Velocidad máx. de altura = %.1f mm/s (en theta = %d°)\n', P.L*cosd(th0)*w_max, th0);

% Ajuste típico con la misma w_max y alfa
thA = asind((P.H_ajuste - H_base - (P.A - P.A0))/P.L);
dA  = deg2rad(abs(diff(thA)));
d_acel = w_max^2/alfa;                       % rad recorridos en acelerar + frenar
if dA >= d_acel
  t_aj = 2*w_max/alfa + (dA - d_acel)/w_max;
else
  t_aj = 2*sqrt(dA/alfa);
end
fprintf('   Ajuste típico %d -> %d mm: theta %.1f° -> %.1f°, tiempo = %.1f s\n\n', ...
        P.H_ajuste(1), P.H_ajuste(2), thA(1), thA(2), t_aj);

%% 2. Inercia respecto al pivote actuado
m_c = P.blk.m + m_U + m_herr;                            % kg, masa que se traslada con el acoplador
J_c = m_c*L^2;                                           % acoplador en traslación (masa puntual a L)
% SUPOSICIÓN: brazos como barras esbeltas uniformes de largo Lt; la inercia propia del bloque no cuenta porque el acoplador solo se traslada.
J_b = 4*m_brazo*(Lt^2/12 + (L/2)^2);                     % 4 brazos alrededor de sus pivotes base
J   = J_c + J_b;
fprintf('2. Inercia\n');
fprintf('   Acoplador (m = %.3f kg)   J = %.4f kg·m^2\n', m_c, J_c);
fprintf('   Brazos (4 x %.3f kg)       J = %.4f kg·m^2\n', m_brazo, J_b);
fprintf('   Total                      J = %.4f kg·m^2\n\n', J);

%% 3. Par a lo largo del barrido (trabajo virtual; suma de módulos)
% La transmisión autobloqueante obliga al motor a impulsar siempre la carga,
% por eso los términos se suman en valor absoluto.
Pv = P.viento.P;
F_blk_x = Pv*P.blk.A_frontal;                            % N
F_U_x   = Pv*(2*P.U.t*L_ala)*1e-6;                       % N, cantos de las alas
% SUPOSICIÓN: viento longitudinal sobre el área proyectada completa de los cuatro brazos, sin apantallamiento entre ellos (conservador).
A_brazo_x = @(th) (P.tubo_b/1000)*(Lt*sind(th) + (P.tubo_h/1000)*cosd(th));  % m^2 por brazo
M_g = @(th, phi) (W_acop*L + 2*W_brazo*L/2).*cosd(th - phi);         % N·m (ambos lados)
M_v = @(th) (F_blk_x + F_U_x)*L*sind(th) + 4*Pv*A_brazo_x(th)*(L/2).*sind(th);
T_rod = P.n_rod*P.T_rod_1;
M_s = @(th) P.res.n*(P.res.M_alto + P.res.k*deg2rad(th1 - th));    % N·m, resortes (ambos lados)

t = linspace(0, P.t_b, 1001);
theta = zeros(size(t)); acc = zeros(size(t));
for k = 1:numel(t)
  tk = t(k);
  if tk < t_a
    th_r = 0.5*alfa*tk^2; acc(k) = alfa;
  elseif tk <= P.t_b - t_a
    th_r = 0.5*alfa*t_a^2 + w_max*(tk - t_a); acc(k) = 0;
  else
    tr = P.t_b - tk; th_r = dth - 0.5*alfa*tr^2; acc(k) = -alfa;
  end
  theta(k) = th0 + rad2deg(th_r);
end
phis = linspace(-P.pendiente, P.pendiente, 33);
Mg_env = zeros(size(theta)); Mgs_env = zeros(size(theta));
for phi = phis
  Mg_env  = max(Mg_env,  M_g(theta, phi));
  for dM = [-1 0 1]*P.res.n*P.res.k*deg2rad(P.res.tol_libre)   % tolerancia de posición libre (Lee p. 286)
    Mgs_env = max(Mgs_env, abs(M_g(theta, phi) - (M_s(theta) + dM)));
  end
end
% SUPOSICIÓN: se suman los módulos de todos los términos con la pendiente más desfavorable en cada ángulo (viento máximo,
% SUPOSICIÓN: pendiente máxima y aceleración simultáneos; conservador).
T_out0 = Mg_env + abs(M_v(theta)) + T_rod + J*abs(acc);      % sin resorte
T_out  = Mgs_env + abs(M_v(theta)) + T_rod + J*abs(acc);     % con resortes
fprintf('3a. Resortes: %d x Lee LTL135T 03 S, k = %.3f N·m/rad c/u, %.2f N·m c/u en theta máx.\n', P.res.n, P.res.k, P.res.M_alto);
fprintf('    Deflexión de cada resorte: %.0f° (alto) a %.0f° (bajo), nominal %d° -> uso %.0f %% del par nominal\n', ...
        P.res.defl_alto, P.res.defl_bajo, P.res.defl_nom, 100*(P.res.M_alto + P.res.k*deg2rad(P.res.barrido))/P.res.M_nom);
fprintf('    T_out máx. sin resortes = %.2f N·m\n', max(T_out0));
fprintf('    Tolerancia de posición libre ±%d° (Lee p. 286): ±%.3f N·m por resorte, incluida en la envolvente\n', P.res.tol_libre, P.res.k*deg2rad(P.res.tol_libre));
fprintf('    Par máximo por resorte con tolerancia = %.3f N·m <= %.3f N·m (Lee p. 298, 270°) -> %s\n', ...
        P.res.M_alto + P.res.k*deg2rad(P.res.barrido + P.res.tol_libre), P.res.M_nom, ...
        ok(P.res.M_alto + P.res.k*deg2rad(P.res.barrido + P.res.tol_libre) <= P.res.M_nom));
[Tmax, i] = max(T_out);
fprintf('3. Par en el eje de salida (ambos brazos)\n');
fprintf('   Viento longitudinal: bloque %.2f N, alas %.2f N, brazos %.2f-%.2f N (c/u)\n', ...
        F_blk_x, F_U_x, Pv*A_brazo_x(th0), Pv*A_brazo_x(th1));
fprintf('   Fricción de rodamientos (cota) = %.3f N·m\n', T_rod);
fprintf('   Término inercial máx. J·alfa   = %.4f N·m\n', J*alfa);
fprintf('   En theta = %.1f°: |gravedad - resortes| %.2f + viento %.2f + fricción %.2f + inercia %.3f\n', ...
        theta(i), Mgs_env(i), abs(M_v(theta(i))), T_rod, J*abs(acc(i)));
fprintf('   T_out máx = %.2f N·m (t = %.2f s, theta = %.1f°)\n', Tmax, t(i), theta(i));
fprintf('   T_out en theta máx = %.2f N·m\n', T_out(end));

%% 4. Figura
try
f = figure('Visible','off', 'Color','w');
plot(theta, T_out, 'k', 'LineWidth', 2); hold on;
plot(theta, T_out0, 'k:', 'LineWidth', 1.5);
plot(theta, Mgs_env, 'b--', 'LineWidth', 1.5);
plot(theta, abs(M_v(theta)), 'r-.', 'LineWidth', 1.5);
grid on;
xlabel('\theta [°]'); ylabel('Par [N·m]');
legend('Par de salida con resortes', 'Par de salida sin resortes', '|Gravedad - resortes| (envolvente)', 'Viento longitudinal', 'Location','east');
title('Par requerido en el pivote actuado a lo largo del barrido');
print(f, 'Elev_Torque_MATLAB.png', '-dpng', '-r200');
fprintf('\nFigura guardada: Elev_Torque_MATLAB.png\n');
catch err
  fprintf('\nNo se pudo generar la figura: %s\n', err.message);
end
save('cargas_elevacion.mat', 'J', 'Tmax', 'w_max', 'alfa', 't_aj', '-append');
