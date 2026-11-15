function R = MC15_condicion_viento(P, R)
% MC15  Rafaga maxima con la que la corona no cruza el juego del engrane.
mc_encabezado(15, 'Condicion de operacion por viento', ...
    'Calcular la rafaga maxima para la que el peso retiene la corona contra un flanco.', ...
    {'NTE E.020, Ec. 12.4 (sin factor de rafaga)', 'GTS Majes S.A.C. (2020), datos SCADA'});
kq = 0.005 * P.C_forma * P.kgf;            % Pa por (km/h)^2
Ah = P.A_exp * P.h_cp;
mc_nota('Sensor equilibrado sobre el eje; placa y tornilleria del CAD (sin ABS); sin friccion.');
mc_nota('Area y brazo de la envolvente; el limite se expresa como rafaga maxima.');
fprintf('   %10s %20s %20s %20s\n', 'theta [gr]', 'M retencion [N m]', 'V max 0.50 kg', 'V max MS-80');
R.V_lim = zeros(size(P.th_viento));
for k = 1:numel(P.th_viento)
    s = sind(P.th_viento(k));
    Mh  = P.g*(P.m_carga*P.z_s + R.m_p_real*R.z_p)*s;
    Mh2 = P.g*(P.m_ms80*P.z_s  + R.m_p_real*R.z_p)*s;
    R.V_lim(k) = sqrt(Mh/(kq*Ah));
    fprintf('   %10.0f %20.4f %17.1f km/h %15.1f km/h\n', P.th_viento(k), Mh, R.V_lim(k), sqrt(Mh2/(kq*Ah)));
end
mc_seccion('Referencia de sitio');
mc_dato('Media diaria maxima en Majes 20T (2016-2019)', P.Vmedia_max_majes*3.6, 'km/h', '%.1f');
mc_nota('Son medias diarias: no indican la frecuencia de rafagas.');

mc_seccion('Velocidad de diseno a la que cada verificacion llega a FS = 1');
mc_nota('Misma cadena de calculo que MC-04 a MC-12, con M_v proporcional a V^2.');
nombres = {'Motor, pull-out', 'Motor, retencion', 'Prisioneros de soportes ABS', ...
           'Prisioneros de la corona', 'Eje, fluencia', 'Diente de la corona (Lewis)'};
fs130 = fs_viento(P, R, P.V_mapa_max);
R.V_FS1 = zeros(1, numel(nombres));
fprintf('   %-32s %16s %18s\n', 'Verificacion', 'FS a 130 km/h', 'V con FS = 1');
for k = 1:numel(nombres)
    lo = P.V_viento; hi = 600;
    for it = 1:60
        m = (lo + hi)/2; f = fs_viento(P, R, m);
        if f(k) >= 1, lo = m; else, hi = m; end
    end
    R.V_FS1(k) = lo;
    fprintf('   %-32s %16.2f %13.0f km/h\n', nombres{k}, fs130(k), lo);
end
R = mc_verificacion(R, 'Viento maximo del mapa (130 km/h)', sprintf('FS min = %.2f', min(fs130)), 'FS >= 1', min(fs130) >= 1);
end

function fs = fs_viento(P, R, V)
% Repite la cadena de MC-04 a MC-12 con viento V (km/h) y devuelve los FS.
M_v = R.M_v * (V/P.V_viento)^2;
To_t = abs(R.Mg) + M_v + P.T_rod + R.J_total*R.acc;
[T_out, k] = max(To_t);
Tm = P.S*T_out/(R.i*R.eta_s) + P.S*R.J_m*R.i*R.acc(k);
c = cos(P.phi_n); l = R.lambda;
W_Gt = P.S*T_out/(R.d_2/2);
W = W_Gt/(c*cos(l) - P.mu_s*sin(l));
W_Wt = W*(c*sin(l) + P.mu_s*cos(l)); W_r = W*sin(P.phi_n);
F_g = hypot(W_Gt, W_r) + P.V_corona*P.rho_bronce*P.g;
M = F_g*P.a_cor + R.F_i*P.a_imu + W_Wt*P.r_corona;
T = P.S*T_out; d = P.d_eje;
svm = sqrt((P.Kt*32*M/(pi*d^3))^2 + 3*(16*T/(pi*d^3))^2);
r = d/2;
H = P.F_ret_n4*P.F_ext_ins/(P.T_asiento_n4/(P.K_par*P.d_n4));
sig_l = W_Gt/(pi*P.m_mod*cos(l)*P.F_e*P.y_lewis);
fs = [R.T_po/Tm, R.T_ret/Tm, P.n_pris*H*r/T, P.n_pris*P.F_ret_n4*r/T, P.Sy_eje/svm, P.Sy_bronce_cent/sig_l];
% M no incluye viento: la fuerza sobre la plataforma cae junto a los rodamientos
% y no cambia el momento del voladizo, que es el que dimensiona el eje.
end
