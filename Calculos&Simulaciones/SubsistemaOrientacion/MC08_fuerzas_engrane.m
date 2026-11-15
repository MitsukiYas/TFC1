function R = MC08_fuerzas_engrane(P, R)
% MC08  Fuerzas en el engrane, resistencia del diente y holguras.
mc_encabezado(8, 'Fuerzas en el engrane y resistencia del diente', ...
    'Calcular las fuerzas del engrane, verificar el diente (Lewis) y la holgura de fondo.', ...
    {'Shigley Ec. 13-42, 13-43 y 15-53', 'KHK Tabla 4.23', 'Metals4U, SAE 660', 'Hoja de datos 17HS16-2004S1'});
c = cos(P.phi_n); l = R.lambda;
R.W_Gt = P.S * R.T_out / (R.d_2/2);                     % tangencial en la corona = axial en el sin fin
W = R.W_Gt / (c*cos(l) - P.mu_s*sin(l));
R.W_Wt = W * (c*sin(l) + P.mu_s*cos(l));                % tangencial en el sin fin = axial en la corona
R.W_r  = W * sin(P.phi_n);                              % radial de separacion
mc_seccion('Fuerzas (con factor S y mu estatico)');
mc_dato('Tangencial en la corona = axial sobre el sin fin', R.W_Gt, 'N', '%.2f');
mc_dato('Tangencial en el sin fin = axial sobre la corona', R.W_Wt, 'N', '%.2f');
mc_dato('Radial de separacion', R.W_r, 'N', '%.2f');
mc_dato('Comprobacion: W_Wt d_w/2 = T_motor', R.W_Wt*R.d_w/2, 'N m', '%.4f');

mc_seccion('Flexion del diente de la corona (Lewis, Shigley 15-53)');
p_n = pi*P.m_mod*cos(l);
R.sigma_lewis = R.W_Gt / (p_n * P.F_e * P.y_lewis);
R.FS_lewis = P.Sy_bronce_cent / R.sigma_lewis;
b_min = 2*P.m_mod*sqrt(R.q + 1) + 1.5*P.m_mod;          % KHK Tabla 4.23, nota 4
mc_dato('Paso normal p_n', p_n*1e3, 'mm', '%.3f');
mc_dato('Ancho de cara F_e', P.F_e*1e3, 'mm', '%.1f');
mc_dato('Ancho minimo recomendado por KHK', b_min*1e3, 'mm', '%.2f');
mc_dato('Esfuerzo de flexion sigma_a', R.sigma_lewis/1e6, 'MPa', '%.1f');
mc_dato('FS con Sy = 95 MPa (centrifugado)', R.FS_lewis, '-', '%.2f');
mc_dato('FS con Sy = 140 MPa (colada continua)', P.Sy_bronce_cont/R.sigma_lewis, '-', '%.2f');
R = mc_verificacion(R, 'Flexion del diente (estatica)', sprintf('FS = %.2f', R.FS_lewis), 'FS >= 1', R.FS_lewis >= 1);
mc_nota('Verificacion estatica: no evalua desgaste ni fatiga.');

mc_seccion('Holgura de fondo con a = 21.25 mm');
c_nom = 0.25*P.m_mod;                                   % KHK: h = 2.25 m, h_a = 1.00 m
r_root_g = R.d_2/2 - 1.25*P.m_mod;
r_root_w = R.d_w/2 - 1.25*P.m_mod;
R.c1 = P.a_CAD - P.r_tip_w_CAD - r_root_g;
R.c2 = P.a_CAD - P.r_tip_g_CAD - r_root_w;
mc_dato('Holgura normal 0.25 m', c_nom*1e3, 'mm', '%.2f');
mc_dato('Cresta del sin fin - fondo de la corona', R.c1*1e3, 'mm', '%.3f');
mc_dato('Cresta de la corona - fondo del sin fin', R.c2*1e3, 'mm', '%.3f');
R = mc_verificacion(R, 'Holgura de fondo', sprintf('%.2f mm', min(R.c1,R.c2)*1e3), '>= 0.25 mm', min(R.c1,R.c2) >= c_nom - 1e-9);

mc_seccion('Flecha del sin fin (AGMA 6022-D19, 15.5)');
p_x = pi*P.m_mod;
d_r = R.d_w - 2*1.25*P.m_mod;                           % diametro de raiz del sin fin
I_w = pi*d_r^4/64;
F_eq = sqrt(R.W_r^2 + R.W_Wt^2);                        % resultante radial + tangencial sobre el sin fin
y_adm = P.k_flecha_sinfin * p_x;                        % 0.025 p_x
R.l_max_sinfin = (y_adm*48*P.E_agma*I_w/F_eq)^(1/3);   % carga centrada (k = 0.5, caso mas desfavorable)
mc_dato('Paso axial p_x', p_x*1e3, 'mm', '%.3f');
mc_dato('Diametro de raiz del sin fin', d_r*1e3, 'mm', '%.2f');
mc_dato('Carga sobre el sin fin', F_eq, 'N', '%.2f');
mc_dato('Flecha admisible 0.025 p_x', y_adm*1e3, 'mm', '%.4f');
mc_dato('Separacion maxima entre apoyos del sin fin', R.l_max_sinfin*1e3, 'mm', '%.0f');
mc_nota('Con la carga en el centro del vano (k = 0.5), y = F l^3/(48 E I) (AGMA Ec. 43).');
R = mc_verificacion(R, 'Flecha del sin fin (vano maximo)', sprintf('l <= %.0f mm', R.l_max_sinfin*1e3), 'y <= 0.025 p_x', 'CUMPLE si l <= l_max');

mc_seccion('Cargas que el sin fin transmitiria al eje del motor');
R.F_rad_w = sqrt(R.W_r^2 + R.W_Wt^2);
mc_dato('Carga axial del sin fin', R.W_Gt, 'N', '%.2f');
mc_dato('Limite axial dinamico del motor', P.Fa_motor_max, 'N', '%.0f');
mc_dato('Carga radial del sin fin (radial + tangencial)', R.F_rad_w, 'N', '%.2f');
mc_dato('Limite radial dinamico del motor (a 20 mm)', P.Fr_motor_max, 'N', '%.0f');
mc_nota('Superan los limites: el sin fin se apoya en sus propios rodamientos (MC-10).');
end
