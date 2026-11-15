function R = MC04_cargas_eje_giro(P, R)
% MC04  Momento gravitacional, carga de viento y friccion de rodamientos.
mc_encabezado(4, 'Cargas sobre el eje de giro', ...
    'Calcular el momento gravitacional M_piv(theta), el momento de viento y la friccion.', ...
    {'NTE E.020, Art. 12 (cargas de viento)', 'Modelo CAD (alturas de centros de masa)'});

% Plataforma: placa de aluminio y tornillería (CAD)
m_placa = P.V_placa * P.rho_al;
m_torn  = P.V_torn * P.rho_torn;
R.m_p_real = m_placa + m_torn;
R.z_p = (m_placa*P.z_placa + m_torn*P.z_torn) / R.m_p_real;

mc_seccion('Plataforma (CAD)');
mc_dato('Masa de la placa y su tornilleria', R.m_p_real, 'kg', '%.4f');
mc_dato('Altura del CM de la plataforma z_p', R.z_p*1e3, 'mm', '%.2f');
mc_nota('Soportes de ABS no considerados: eleva z_p (conservador para cargas).');

% Momento gravitacional: se prueban ambos signos de d_cm y se toma el peor
th = R.th;
Mg_pos = P.g*(P.m_carga*( P.d_cm*cos(th) + P.z_s*sin(th)) + P.m_plat*R.z_p*sin(th));
Mg_neg = P.g*(P.m_carga*(-P.d_cm*cos(th) + P.z_s*sin(th)) + P.m_plat*R.z_p*sin(th));
if max(abs(Mg_neg)) >= max(abs(Mg_pos)), R.Mg = Mg_neg; else, R.Mg = Mg_pos; end
[R.Mg_max, k] = max(abs(R.Mg));
R.th_Mg_max = th(k);
R.Mg_0 = P.g*P.m_carga*P.d_cm;
R.th_cero = atand(P.m_carga*P.d_cm / (P.m_carga*P.z_s + P.m_plat*R.z_p));

mc_seccion('Momento gravitacional');
mc_nota('M_piv = g[m_carga(d_cm cos(th) + z_s sin(th)) + m_plat z_p sin(th)]');
mc_dato('|M_piv| maximo', R.Mg_max, 'N m', '%.4f');
mc_dato('Angulo del maximo', R.th_Mg_max*180/pi, 'grados', '%.1f');
mc_dato('M_piv en theta = 0', R.Mg_0, 'N m', '%.4f');
mc_dato('Angulo en que M_piv cambia de signo', R.th_cero, 'grados', '%.1f');

% Viento (NTE E.020): V_h = V para h <= 10 m
P_kgf = P.f_r * 0.005 * P.C_forma * P.V_viento^2;
R.P_viento = P_kgf * P.kgf;
R.F_v = R.P_viento * P.A_exp;
R.M_v = R.F_v * P.h_cp;
mc_seccion('Viento (NTE E.020)');
mc_dato('Presion P_h = f_r 0.005 C V^2', P_kgf, 'kgf/m^2', '%.2f');
mc_dato('Presion', R.P_viento, 'Pa', '%.1f');
mc_dato('Fuerza lateral F_v', R.F_v, 'N', '%.3f');
mc_dato('Momento de viento M_v', R.M_v, 'N m', '%.4f');
mc_dato('Relacion M_v / M_piv(0)', R.M_v/R.Mg_0, '-', '%.2f');
mc_nota('V = 75 km/h solo vale donde el mapa eolico de la NTE da 75 km/h o menos.');

mc_seccion('Friccion de rodamientos (modelo SKF simplificado)');
P_rod = hypot((P.m_carga + P.m_plat)*P.g, R.F_v) / P.n_rod;     % carga por rodamiento
T_sellos = P.n_rod*(0.5*P.mu_rod*P_rod*P.d_eje + P.M_sello);    % con sellos de contacto
T_escudos = P.n_rod*(0.5*P.mu_rod*P_rod*P.d_eje);               % con escudos ZZ (sin roce)
mc_dato('Carga por rodamiento', P_rod, 'N', '%.2f');
mc_dato('T_rod con sellos de contacto (2 x 0.01 N m)', T_sellos, 'N m', '%.4f');
mc_dato('T_rod con escudos ZZ', T_escudos, 'N m', '%.2e');
mc_dato('T_rod adoptado (conservador)', P.T_rod, 'N m', '%.4f');
mc_nota('Se conserva el valor con sellos: los escudos ZZ no rozan el aro interior.');
end
