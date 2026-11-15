%% MEMORIA 02 - Cargas de diseño del subsistema de elevación
% Masas, momentos gravitacionales con pendiente, viento lateral (NTE E.020),
% momento de alabeo, fuerzas por lado y torsión de diseño del travesaño.
% Guarda los resultados en cargas_elevacion.mat para las memorias 03 y 04.
clear; clc;
run('parametros_elevacion.m');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c))+1};

fprintf('=== MEMORIA 02: CARGAS ===\n\n');

%% 1. Geometría derivada (ver memoria 01)
H_base   = P.H15_0 - P.L0*sind(15);
th_max   = P.th_max;
H        = @(th) H_base + (P.A - P.A0) + P.L*sind(th);
n        = P.nodo;
w_c      = P.U.w - 2*(n.t_arandela + n.t_tuerca + P.tubo_b/2);       % mm
L_ala    = P.U.z_piv_sup + P.A + P.U.z_bajo_inf;                       % mm
z_piv_inf_suelo = H_base - (P.blk.H_cupula_sobre_viga + P.U.z_piv_sup + P.A0); % mm, pivote actuado sobre el suelo

%% 2. Masas
m_U   = ((P.U.w + 2*P.U.t)*P.U.Lx + 2*(L_ala - P.U.t)*P.U.Lx)*P.U.t*1e-9*P.Al5052.rho;
m_brazo = (P.L + 2*P.voladizo_brazo)/1000*P.tubo_mlin;
m_herr = P.m_herrajes_acoplador;
if isnan(m_herr)
  fprintf('AVISO: masa de herrajes del acoplador no definida (COMPLETAR en parámetros). Se usa 0 kg.\n\n');
  m_herr = 0;
end
% SUPOSICIÓN: el CM del bloque de orientación, de la U y de los herrajes está sobre la línea de pivotes y en el plano medio.
W_acop = (P.blk.m + m_U + m_herr)*g + 2*(m_brazo*g)/2;   % N, cargas en el acoplador (incluye mitad de brazos superiores)
W_brazo = m_brazo*g;
fprintf('1. Masas\n');
fprintf('   Bloque de orientación              = %7.3f kg\n', P.blk.m);
fprintf('   Pieza en U                         = %7.3f kg\n', m_U);
fprintf('   Herrajes del acoplador             = %7.3f kg\n', m_herr);
fprintf('   Cada brazo (%.0f mm)                = %7.3f kg\n', P.L + 2*P.voladizo_brazo, m_brazo);
fprintf('   Carga vertical en el acoplador     = %7.2f N\n\n', W_acop);

%% 3. Momento gravitacional en el pivote actuado (total, ambos lados)
% Trabajo virtual en paralelogramo: el acoplador se traslada, M = W*L*cos(theta - phi)
% phi = pendiente longitudinal (positiva = subiendo con el brazo hacia adelante)
Mg = @(th, phi) (W_acop*P.L/1000 + 2*W_brazo*(P.L/2)/1000).*cosd(th - phi);
th_v  = linspace(P.th_min, th_max, 200);
phi_v = linspace(-P.pendiente, P.pendiente, 33);
Mg_max = 0; th_Mg = NaN; phi_Mg = NaN;
for phi = phi_v
  [m, i] = max(Mg(th_v, phi));
  if m > Mg_max, Mg_max = m; th_Mg = th_v(i); phi_Mg = phi; end
end
fprintf('2. Momento gravitacional (ambos lados)\n');
fprintf('   Máximo = %.2f N·m en theta = %.1f°, pendiente = %+d°\n', Mg_max, th_Mg, phi_Mg);
fprintf('   Por lado = %.2f N·m\n\n', Mg_max/2);

%% 4. Viento lateral (NTE E.020, Art. 12)
Pv = P.viento.P;                               % Pa
F_blk  = P.blk.F_viento;                       % N (sección de orientación)
% SUPOSICIÓN: el viento lateral actúa solo sobre el ala de barlovento de la U (la de sotavento se considera apantallada).
F_ala  = Pv*(P.U.Lx/1000)*(L_ala/1000);        % N, una ala de la U (barlovento)
% SUPOSICIÓN: los cuatro brazos reciben viento completo, sin apantallamiento (conservador).
Lt = (P.L + 2*P.voladizo_brazo)/1000;          % m, largo de corte del tubo
F_brazo = Pv*(P.tubo_h/1000)*Lt;               % N, cara lateral de un brazo (largo completo del tubo)
fprintf('3. Viento lateral\n');
fprintf('   Presión de diseño                  = %.2f kgf/m^2 = %.1f Pa\n', P.viento.P_kgf, Pv);
fprintf('   Fuerza sobre el bloque             = %7.2f N\n', F_blk);
fprintf('   Fuerza sobre un ala de la U        = %7.2f N\n', F_ala);
fprintf('   Fuerza sobre cada brazo            = %7.2f N (x4)\n', F_brazo);

% 4a. Momento de alabeo sobre el acoplador, respecto al eje de los pivotes inferiores
z_cp_blk = P.A + P.U.z_piv_sup + P.blk.z_eje + P.blk.h_cp;   % mm sobre pivote inferior del acoplador
z_ala    = P.A + P.U.z_piv_sup - L_ala/2;                   % mm, centro del ala
% SUPOSICIÓN: cada brazo superior entrega la mitad de su carga lateral en su pivote superior (viga simplemente apoyada).
M_r = F_blk*z_cp_blk/1000 + F_ala*z_ala/1000 + 2*(F_brazo/2)*P.A/1000;   % brazos superiores entregan la mitad en el pivote superior
% SUPOSICIÓN: el momento de alabeo se equilibra solo con fuerzas verticales opuestas en los dos lados, separados w_c.
dV_acop = M_r/(w_c/1000);                                    % N, fuerza vertical diferencial por lado
fprintf('   Momento de alabeo en el acoplador  = %7.3f N·m\n', M_r);
fprintf('   Fuerza vertical diferencial por lado = +/- %.1f N\n', dV_acop);

% 4b. Momento de alabeo en la base (todo el conjunto, respecto a los pivotes base)
th = th_max;   % caso más alto
z_blk_base = H(th) - P.blk.H_cupula_sobre_viga + P.blk.z_eje + P.blk.h_cp - z_piv_inf_suelo;
z_brazos   = (P.L/2)*sind(th) + P.A/2;
z_U_base   = P.L*sind(th) + z_ala;
M_base = F_blk*z_blk_base/1000 + 4*F_brazo*z_brazos/1000 + F_ala*z_U_base/1000;
dV_base = M_base/(w_c/1000);
fprintf('   Momento de alabeo en la base (theta = %.1f°) = %.2f N·m\n', th, M_base);
fprintf('   Fuerza vertical diferencial en la base = +/- %.1f N\n\n', dV_base);

%% 5. Torsión de diseño del travesaño (marco inferior)
% El motor acciona un solo brazo inferior; el travesaño entrega al otro brazo
% su parte del momento gravitacional más el diferencial por viento lateral.
% Viento longitudinal (en el plano del mecanismo): también se reparte entre lados
A_brazo_x = @(th) (P.tubo_b/1000)*(Lt*sind(th) + (P.tubo_h/1000)*cosd(th));
M_v = @(th) (Pv*P.blk.A_frontal + Pv*(2*P.U.t*L_ala)*1e-6)*(P.L/1000)*sind(th) ...
            + 4*Pv*A_brazo_x(th)*(P.L/2000).*sind(th);
M_s = @(th) P.res.n*(P.res.M_alto + P.res.k*deg2rad(th_max - th));   % N·m, resortes (uno por lado)
% Cada resorte alivia su propio lado; el travesaño lleva la mitad del par neto simétrico más el diferencial
% SUPOSICIÓN: el lado no accionado toma exactamente la mitad del par neto (reparto simétrico) y todo el diferencial
% SUPOSICIÓN: por viento lateral pasa por el travesaño; los brazos superiores no aportan rigidez al alabeo.
dMt = P.res.n*P.res.k*deg2rad(P.res.tol_libre);   % N·m, tolerancia de posición libre (Lee p. 286), ambos resortes
T_trav = @(th, phi) (max(abs(Mg(th, phi) - M_s(th) - dMt), abs(Mg(th, phi) - M_s(th) + dMt)) + M_v(th))/2 + dV_acop*(P.L/1000)*cosd(th);
T_t = 0; th_T = NaN; phi_T = NaN;
for phi = phi_v
  [m, i] = max(T_trav(th_v, phi));
  if m > T_t, T_t = m; th_T = th_v(i); phi_T = phi; end
end
fprintf('4. Torsión de diseño del travesaño\n');
fprintf('   |Gravedad - resortes| por lado     = %7.2f N·m\n', abs(Mg(th_T, phi_T) - M_s(th_T))/2);
fprintf('   Viento longitudinal por lado       = %7.2f N·m\n', M_v(th_T)/2);
fprintf('   Diferencial por viento lateral     = %7.2f N·m\n', dV_acop*(P.L/1000)*cosd(th_T));
fprintf('   T_t = %.2f N·m (theta = %.1f°, pendiente = %+d°; incluye la tolerancia de posición libre de los resortes)\n\n', T_t, th_T, phi_T);

%% 6. Reacciones en los nodos: equilibrio plano completo del paralelogramo
% Ejes del robot: x hacia adelante (hacia el acoplador), z perpendicular al chasis.
% Pivotes: base inferior D = (0,0), base superior B = (0,A), acoplador inferior E = L(cos, sin), superior C = E + (0,A).
% Incógnitas (fuerzas de los pasadores SOBRE los brazos, ambos lados juntos):
%   x = [Bx Bz Cx Cz Dx Dz Ex Ez T], T = par del reductor sobre los brazos inferiores (antihorario +).
% Cargas: pesos con la pendiente (gravedad = g·(sin phi, -cos phi), coherente con Mg ∝ cos(theta - phi)),
% viento longitudinal (+/-x), resortes sobre el travesaño.
% SUPOSICIÓN: el brazo superior no está unido al travesaño y solo recibe fuerzas en sus pasadores, su peso y viento.
% SUPOSICIÓN: el CM del acoplador está sobre la línea de pivotes (desfase axial de 4.5 mm compensado con la posición de la viga).
m_blk = P.blk.m;
z_blk = P.A + P.U.z_piv_sup + P.blk.z_cm;                                  % mm sobre E
A_alma = (P.U.w + 2*P.U.t)*P.U.Lx; A_alas = 2*(L_ala - P.U.t)*P.U.Lx;
z_U = (A_alma*(P.A + P.U.z_piv_sup - P.U.t/2) + A_alas*(P.A + P.U.z_piv_sup - P.U.t - (L_ala - P.U.t)/2))/(A_alma + A_alas);
% SUPOSICIÓN: la mitad de los herrajes del acoplador en cada pivote del acoplador.
m_c   = m_blk + m_U + m_herr;
z_cmc = (m_blk*z_blk + m_U*z_U + m_herr*P.A/2)/m_c;                       % mm sobre E
F_U_x = Pv*(2*P.U.t*L_ala)*1e-6;                                          % N, cantos de las alas
z_U_x = P.A + P.U.z_piv_sup - L_ala/2;                                    % mm sobre E
z_cp_long = P.A + P.U.z_piv_sup + P.blk.z_cp_frontal;                     % mm sobre E
F_long = Pv*P.blk.A_frontal;                                              % N
Lm = P.L/1000; Am = P.A/1000;
cr = @(r, f) r(1)*f(2) - r(2)*f(1);
resolver = @(th, phi, sw, dM) resolver_paralelogramo(th, phi, sw, Lm, Am, m_c, z_cmc/1000, m_brazo, g, ...
            F_long, z_cp_long/1000, F_U_x, z_U_x/1000, Pv, P.tubo_b/1000, P.tubo_h/1000, Lt, ...
            M_s(th) + dM, P.res.r_pata/1000);
R_bi = 0; R_bs = 0; R_ai = 0; R_as = 0; F_bs_ax = 0; T_chk = 0;
for th = th_v
  for phi = phi_v
    for sw = [-1 1]
     for dM = [-1 0 1]*dMt
      x = resolver(th, phi, sw, dM);
      R_bi = max(R_bi, hypot(x(5)/2, abs(x(6))/2 + dV_base));    % base inferior (por lado)
      R_bs = max(R_bs, hypot(x(1)/2, abs(x(2))/2 + dV_base));    % base superior
      R_ai = max(R_ai, hypot(x(7)/2, abs(x(8))/2 + dV_acop));    % acoplador inferior
      R_as = max(R_as, hypot(x(3)/2, abs(x(4))/2 + dV_acop));    % acoplador superior
      F_bs_ax = max(F_bs_ax, hypot(x(1), x(2))/2);                % fuerza en cada brazo superior (sin alabeo)
     end
    end
  end
end
% SUPOSICIÓN: el diferencial vertical por viento lateral se suma completo a cada pivote del lado cargado (conservador).
% Comprobación: el par T del equilibrio coincide con el modelo de trabajo virtual (memoria 05) sin viento
x0 = resolver(30, 0, 0, 0);
T_tv = Mg(30, 0) - M_s(30);
R_acop = max(R_ai, R_as); R_base = R_bi;
fprintf('5. Reacciones radiales por nodo y lado (equilibrio completo, envolvente theta/pendiente/viento)\n');
fprintf('   Comprobación: T de equilibrio %.3f N·m = trabajo virtual %.3f N·m (theta 30°, sin viento)\n', x0(9), T_tv);
fprintf('   Acoplador inferior / superior      = %7.1f / %.1f N\n', R_ai, R_as);
fprintf('   Base inferior (actuado) / superior = %7.1f / %.1f N\n', R_bi, R_bs);
fprintf('   Fuerza en cada brazo superior      = %7.1f N (sin el diferencial por alabeo)\n', F_bs_ax);
fprintf('   KFL08: S0 = C0/P0 = %.1f -> %s (rodamiento; la carcasa de zinc no está clasificada)\n\n', ...
        P.KFL.C0/max([R_ai R_as R_bi R_bs]), ok(P.KFL.C0/max([R_ai R_as R_bi R_bs]) >= 1));
R_base_sup = R_bs;

save('cargas_elevacion.mat', 'T_t', 'th_T', 'phi_T', 'Mg_max', 'M_r', 'dV_acop', ...
     'M_base', 'dV_base', 'R_acop', 'R_base', 'W_acop', 'w_c', 'L_ala', 'm_U', 'F_long', 'z_cp_blk', 'm_herr', 'm_brazo', 'W_brazo', 'H_base', 'th_max', 'R_base_sup', 'F_bs_ax', 'R_ai', 'R_as', 'm_c', 'Pv', 'Lt', 'th_v', 'phi_v', 'z_cmc', 'F_long', 'z_cp_long', 'F_U_x', 'z_U_x');
fprintf('Resultados guardados en cargas_elevacion.mat\n');

