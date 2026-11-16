function R = MC09_eje_basculante(P, R, carpeta_fig)
% MC09  Eje basculante: reacciones, esfuerzos, flecha, pendientes y torsion.
mc_encabezado(9, 'Eje basculante', ...
    'Verificar resistencia, flecha, pendientes y giro por torsion del eje de 10 mm.', ...
    {'Shigley Tablas 3-2, 7-2, A-5, A-9 (caso 10) y A-20; Ec. de energia de distorsion'});
g = P.g; L = P.L_rod; a = P.a_cor; ai = P.a_imu; d = P.d_eje;
m_corona = P.V_corona * P.rho_bronce;
R.F_plat = hypot((P.m_carga + P.m_plat)*g, R.F_v);       % pesos + viento
R.F_g = hypot(R.W_Gt, R.W_r) + m_corona*g;               % engrane + peso de la corona
R.F_i = P.m_imu * g;                                      % tarjeta del IMU (sin la chapa de ABS)
R.M_a = R.W_Wt * P.r_corona;                              % momento de la fuerza axial de la corona
R.T_eje = P.S * R.T_out;
mc_nota('Viga simplemente apoyada en los rodamientos con voladizo a la derecha.');
mc_nota('Cargas en planos distintos sumadas como colineales y del mismo sentido (conservador).');
mc_seccion('Cargas');
mc_dato('Plataforma (pesos y viento), total en dos soportes', R.F_plat, 'N', '%.2f');
mc_dato('Corona: resultante tangencial-radial + peso', R.F_g, 'N', '%.2f');
mc_dato('Tarjeta del IMU', R.F_i, 'N', '%.3f');
mc_dato('Momento concentrado de la fuerza axial', R.M_a, 'N m', '%.4f');

% Reacciones (x = 0 en el rodamiento izquierdo)
R.R_der = (R.F_plat/2*P.x_sop + R.F_plat/2*(L-P.x_sop) + R.F_g*(L+a) + R.F_i*(L+ai) + R.M_a) / L;
R.R_izq = R.F_plat + R.F_g + R.F_i - R.R_der;
R.M_max = R.F_g*a + R.F_i*ai + R.M_a;
mc_seccion('Reacciones y momentos');
mc_dato('Reaccion en el rodamiento derecho', R.R_der, 'N', '%.2f');
mc_dato('Reaccion en el rodamiento izquierdo', R.R_izq, 'N', '%.2f');
mc_dato('Momento flector maximo (rodamiento derecho)', R.M_max, 'N m', '%.4f');
mc_dato('Par (S T_out), corona - soporte derecho', R.T_eje, 'N m', '%.4f');

% Esfuerzos en la seccion del rodamiento derecho
sig = P.Kt*32*R.M_max/(pi*d^3);
tau = 16*R.T_eje/(pi*d^3);
R.sig_vm = sqrt(sig^2 + 3*tau^2);
R.FS_eje = P.Sy_eje / R.sig_vm;
R.d_min = (32*P.n_d/(pi*P.Sy_eje) * sqrt((P.Kt*R.M_max)^2 + 0.75*R.T_eje^2))^(1/3);
V_max = R.F_g + R.F_i;
tau_v = 4*V_max/(3*pi*d^2/4);
mc_seccion('Esfuerzos en la seccion critica');
mc_dato('sigma = Kt 32 M / (pi d^3)', sig/1e6, 'MPa', '%.2f');
mc_dato('tau = 16 T / (pi d^3)', tau/1e6, 'MPa', '%.2f');
mc_dato('sigma von Mises', R.sig_vm/1e6, 'MPa', '%.2f');
mc_dato('FS a la fluencia (Sy = 310 MPa)', R.FS_eje, '-', '%.2f');
mc_dato('FS a la fluencia (Sy = 530 MPa, 1045 CD)', P.Sy_CD/R.sig_vm, '-', '%.2f');
mc_dato('Diametro minimo (n = 3)', R.d_min*1e3, 'mm', '%.2f');
mc_dato('Cortante transversal maximo 4V/3A', tau_v/1e6, 'MPa', '%.2f');
R = mc_verificacion(R, 'Resistencia del eje a la fluencia', sprintf('FS = %.2f', R.FS_eje), 'FS >= 3.0', R.FS_eje >= P.n_d);
mc_seccion('Fatiga (vida infinita, ED-Goodman, Shigley Ec. 6-10, 6-17 a 6-19, 7-4 y 7-7)');
Sut_ksi = P.Sut_HR/6.894757e6;
ka = P.ka_a * Sut_ksi^P.ka_b;                       % Ec. 6-18, superficie maquinada
kb = (d*1e3/7.62)^(-0.107);                         % Ec. 6-19, 7.62 <= d <= 51 mm (barra rotatoria: conservador)
Se = ka*kb*P.ke_99*0.5*P.Sut_HR;                    % Ec. 6-17 y 6-10; kc = 1 con Von Mises (6-9), kd = kf = 1
sig_a = P.Kf_fat*32*R.M_max/(pi*d^3);               % todo alternante (inversion completa)
tau_a = P.Kf_fat*16*R.T_eje/(pi*d^3);
sig_a_vm = sqrt(sig_a^2 + 3*tau_a^2);               % Ec. 7-4; sigma'_m = 0
R.FS_fat = Se/sig_a_vm;                             % Goodman (Ec. 6-41) con sigma'_m = 0
ciclos_anio = 365*24*3600/P.t_ciclo;
mc_dato('Sut (AISI 1045 HR)', P.Sut_HR/1e6, 'MPa', '%.0f');
mc_dato('ka (maquinado)', ka, '-', '%.3f');
mc_dato('kb', kb, '-', '%.3f');
mc_dato('ke (99 %)', P.ke_99, '-', '%.3f');
mc_dato('Limite de fatiga Se', Se/1e6, 'MPa', '%.1f');
mc_dato('Esfuerzo alternante de von Mises', sig_a_vm/1e6, 'MPa', '%.2f');
mc_dato('FS a fatiga (vida infinita)', R.FS_fat, '-', '%.2f');
mc_dato('Ciclos por anio (operacion continua)', ciclos_anio, 'ciclos', '%.0f');
mc_nota('Conservador: superficie maquinada (la barra es rectificada), Sut del 1045 HR, Kf = Kt = 2 en flexion y torsion.');
mc_nota('Con FS > 1 para vida infinita, el numero de ciclos no limita la vida del eje.');
R = mc_verificacion(R, 'Fatiga del eje (vida infinita)', sprintf('FS = %.2f', R.FS_fat), 'FS >= 1', R.FS_fat >= 1);

% Flecha y pendientes por integracion numerica de M/EI
I = pi*d^4/64;
[y_cor, p_izq, p_der, p_cor] = flecha_eje(P, R, false, I);          % solo cargas del voladizo
[y_cor2, p_izq2, p_der2, p_cor2, x, Mx] = flecha_eje(P, R, true, I); % todas las cargas (figura)
R.y_cor = max(y_cor, y_cor2);
R.pend_rod = max([p_izq, p_der, p_izq2, p_der2]);
R.pend_cor = max(p_cor, p_cor2);
mc_seccion('Flecha y pendientes (E = 207 GPa)');
mc_dato('Flecha en la corona (solo cargas del voladizo)', y_cor*1e3, 'mm', '%.4f');
mc_dato('Pendiente en el rodamiento izquierdo', max(p_izq, p_izq2), 'rad', '%.5f');
mc_dato('Pendiente en el rodamiento derecho', max(p_der, p_der2), 'rad', '%.5f');
mc_dato('Pendiente en la corona', R.pend_cor, 'rad', '%.5f');
mc_dato('Diferencia entre bordes del diente (ancho F_e)', R.pend_cor*P.F_e*1e3, 'mm', '%.4f');
R = mc_verificacion(R, 'Flecha en la corona', sprintf('%.4f mm', R.y_cor*1e3), '<= 0.076 mm', R.y_cor <= P.y_adm);
R = mc_verificacion(R, 'Pendiente en los rodamientos', sprintf('%.5f rad', R.pend_rod), '<= 0.001 rad', R.pend_rod <= P.pend_rod_adm);
R.pend_cor_min = R.pend_cor*180/pi*60;               % minutos de arco
mc_dato('Pendiente en la corona', R.pend_cor_min, 'min de arco', '%.2f');
mc_dato('Angularidad admisible de la caja (AGMA 6022, 7.3)', P.ang_caja_adm*180/pi*60, 'min de arco', '%.1f');
mc_nota('AGMA no da un limite de pendiente del eje: se usa su tolerancia de angularidad de la caja.');
% Pendiente con la carga de operacion: misma cadena (S, mu estatico, suma colineal) con la rafaga maxima de
% operacion P.V_op, sin factor de rafaga, en lugar del viento de diseno. Fija el margen de montaje.
kv = (P.V_op/P.V_viento)^2/P.f_r;
To_op = max(abs(R.Mg) + R.M_v*kv + P.T_rod + R.J_total*R.acc);
cn = cos(P.phi_n); lam = R.lambda;
WGt_op = P.S*To_op/(R.d_2/2); W_op = WGt_op/(cn*cos(lam) - P.mu_s*sin(lam));
Rop = R; Rop.F_g = hypot(WGt_op, W_op*sin(P.phi_n)) + m_corona*g;
Rop.M_a = W_op*(cn*sin(lam) + P.mu_s*cos(lam))*P.r_corona;
Rop.F_plat = hypot((P.m_carga + P.m_plat)*g, R.F_v*kv);
[~, ~, ~, pc1] = flecha_eje(P, Rop, false, I); [~, ~, ~, pc2] = flecha_eje(P, Rop, true, I);
R.pend_cor_op = max(pc1, pc2); R.pend_cor_op_min = R.pend_cor_op*180/pi*60;
R.ang_montaje_adm = (P.ang_caja_adm - R.pend_cor_op)*180/pi*60;
mc_dato('Rafaga maxima de operacion', P.V_op, 'km/h', '%.0f');
mc_dato('T_out de operacion', To_op, 'N m', '%.4f');
mc_dato('Pendiente en la corona, carga de operacion', R.pend_cor_op, 'rad', '%.5f');
mc_dato('Pendiente en la corona, carga de operacion', R.pend_cor_op_min, 'min de arco', '%.2f');
mc_dato('Margen para la angularidad de montaje (operacion)', R.ang_montaje_adm, 'min de arco', '%.2f');
mc_dato('Margen con la carga de diseno (referencia)', (P.ang_caja_adm - R.pend_cor)*180/pi*60, 'min de arco', '%.2f');
R = mc_verificacion(R, 'Pendiente en la corona, operacion (AGMA 6022)', sprintf('%.1f min', R.pend_cor_op_min), '<= 5 min', R.pend_cor_op <= P.ang_caja_adm);
mc_nota('La pendiente se suma a la angularidad de los alojamientos; verificar el contacto con tinta azul (AGMA 6022, 7.1).');

% Giro por torsion con T_out sin factor S; se usa en el presupuesto de error (MC-14)
J_p = pi*d^4/32;
R.giro_tor = R.T_out*P.L_tor/(P.G*J_p) * 180/pi;
mc_seccion('Giro por torsion');
mc_dato('Giro corona - soporte derecho (T_out sin S)', R.giro_tor, 'grados', '%.4f');

% Figura de momento flector y torsor
xs = x*1e3;
Tx = zeros(size(x));
Tx(x >= L - P.x_sop & x <= L + a) = R.T_eje;
f = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 800 600]);
subplot(2,1,1);
plot(xs, -Mx, 'LineWidth', 1.5); grid on;
xlabel('Distancia al rodamiento izquierdo [mm]'); ylabel('Momento flector [N m]');
title('Momento flector en el eje (todas las cargas, supuestas colineales)');
subplot(2,1,2);
plot(xs, Tx, 'LineWidth', 1.5); grid on;
xlabel('Distancia al rodamiento izquierdo [mm]'); ylabel('Momento torsor [N m]');
title('Momento torsor en el eje');
print(f, fullfile(carpeta_fig, 'Tilt_Eje_MATLAB.png'), '-dpng', '-r200');
close(f);
mc_nota('Figura guardada: Tilt_Eje_MATLAB.png');
end

function [y_cor, p_izq, p_der, p_cor, x, Mx] = flecha_eje(P, R, con_plat, I)
% Integra M/EI dos veces e impone y = 0 en ambos rodamientos.
L = P.L_rod; a = P.a_cor; ai = P.a_imu;
x = linspace(0, L + ai, 40001); dx = x(2) - x(1);
cargas = [L + a, R.F_g; L + ai, R.F_i];
if con_plat
    cargas = [cargas; P.x_sop, R.F_plat/2; L - P.x_sop, R.F_plat/2];
end
Rd = (sum(cargas(:,1).*cargas(:,2)) + R.M_a) / L;
Ri = sum(cargas(:,2)) - Rd;
Mx = Ri*x + Rd*max(x - L, 0) + R.M_a*(x >= L + a);   % con el par M_a, M vale 0 en el extremo libre
for k = 1:size(cargas,1)
    Mx = Mx - cargas(k,2)*max(x - cargas(k,1), 0);
end
kap = Mx/(P.E*I);
th = cumsum(kap)*dx; y = cumsum(th)*dx;
[~, iL] = min(abs(x - L));
c1 = -(y(iL) - y(1))/L;
th = th + c1; y = y + c1*x; y = y - y(1);
[~, ig] = min(abs(x - (L + a)));
y_cor = abs(y(ig)); p_izq = abs(th(1)); p_der = abs(th(iL)); p_cor = abs(th(ig));
end
