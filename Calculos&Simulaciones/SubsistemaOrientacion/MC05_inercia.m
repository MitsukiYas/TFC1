function R = MC05_inercia(P, R)
% MC05  Momento de inercia respecto al eje de giro.
mc_encabezado(5, 'Inercia respecto al eje de giro', ...
    'Calcular J_total a partir del modelo CAD y las masas de diseno.', ...
    {'Modelo CAD (integrales de r^2 dV respecto al eje)'});
R.J_carga = P.m_carga * (P.k2_s + P.d_cm^2);
J_plat_real = P.rho_al*P.Jv_placa + P.rho_torn*P.Jv_torn;
R.J_plat = J_plat_real * P.m_plat / R.m_p_real;     % escalada a la masa de diseno
R.J_corona = P.rho_bronce * P.Jv_corona;
R.J_eje = P.rho_acero * P.Jv_eje;
R.J_total = R.J_carga + R.J_plat + R.J_corona + R.J_eje;
mc_dato('Sensor J = m(k_s^2 + d_cm^2)', R.J_carga, 'kg m^2', '%.4e');
mc_dato('Plataforma (escalada a 0.25 kg)', R.J_plat, 'kg m^2', '%.4e');
mc_dato('Corona', R.J_corona, 'kg m^2', '%.3e');
mc_dato('Eje', R.J_eje, 'kg m^2', '%.3e');
mc_dato('J_total', R.J_total, 'kg m^2', '%.4e');
mc_dato('Termino inercial J_total * alfa', R.J_total*R.alfa, 'N m', '%.2e');
mc_nota('Sensor con densidad uniforme y CM en su centro geometrico.');
end
