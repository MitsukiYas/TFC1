function R = MC10_rodamientos(P, R)
% MC10  Verificacion estatica de los rodamientos MR2010A (ZZ).
mc_encabezado(10, 'Rodamientos', ...
    'Verificar la capacidad estatica de los rodamientos del eje y del sin fin.', ...
    {'Ficha MR2010A (C0 = 80.8 kgf)', 'P0 = 0.6 Fr + 0.5 Fa, P0 >= Fr (catalogo SKF)'});
P0 = @(Fr, Fa) max(Fr, 0.6*Fr + 0.5*Fa);
mc_seccion('Eje basculante: rodamiento derecho (fijo axialmente)');
R.P0_eje = P0(R.R_der, R.W_Wt);
R.S0_eje = P.C0_rod / R.P0_eje;
mc_dato('Carga radial', R.R_der, 'N', '%.2f');
mc_dato('Carga axial (axial de la corona)', R.W_Wt, 'N', '%.2f');
mc_dato('0.6 Fr + 0.5 Fa', 0.6*R.R_der + 0.5*R.W_Wt, 'N', '%.2f');
mc_dato('P0', R.P0_eje, 'N', '%.2f');
mc_dato('C0', P.C0_rod, 'N', '%.0f');
mc_dato('S0', R.S0_eje, '-', '%.2f');
R = mc_verificacion(R, 'Rodamiento mas cargado del eje', sprintf('S0 = %.2f', R.S0_eje), 'S0 >= 1', R.S0_eje >= 1);
mc_nota('La reaccion izquierda cambia de signo: el alojamiento debe retenerlo en ambos sentidos.');

mc_seccion('Sin fin: cota superior (un rodamiento toma toda la carga)');
R.P0_w = P0(R.F_rad_w, R.W_Gt);
R.S0_w = P.C0_rod / R.P0_w;
mc_dato('Carga radial (radial + tangencial del sin fin)', R.F_rad_w, 'N', '%.2f');
mc_dato('Carga axial (tangencial de la corona)', R.W_Gt, 'N', '%.2f');
mc_dato('P0', R.P0_w, 'N', '%.2f');
mc_dato('S0', R.S0_w, '-', '%.2f');
R = mc_verificacion(R, 'Rodamientos del sin fin (cota)', sprintf('S0 = %.2f', R.S0_w), 'S0 >= 1', R.S0_w >= 1);
mc_nota('Cota independiente de la separacion entre rodamientos del sin fin.');
end
