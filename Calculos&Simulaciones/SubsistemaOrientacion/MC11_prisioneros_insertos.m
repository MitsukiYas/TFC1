function R = MC11_prisioneros_insertos(P, R)
% MC11  Fijacion de la corona y de los soportes al eje con prisioneros.
mc_encabezado(11, 'Prisioneros e insertos', ...
    'Verificar la fijacion por prisioneros de la corona (bronce) y de los soportes (ABS con insertos).', ...
    {'Shigley Tabla 7-4, Ec. 8-27, Tabla 8-15', 'PennEngineering SI, IPFC-M4 en ABS', 'SPIROL, guia de diseno de insertos'});
r = P.d_eje/2;
mc_seccion('Corona de bronce (Tabla 7-4, prisionero n.o 4 como valor conservador)');
T_cubo = P.n_pris * P.F_ret_n4 * r;
R.FS_pris_T = T_cubo / R.T_eje;
R.FS_pris_A = P.n_pris * P.F_ret_n4 / R.W_Wt;
mc_dato('Retencion por prisionero', P.F_ret_n4, 'N', '%.0f');
mc_dato('Par transmisible por cubo', T_cubo, 'N m', '%.2f');
mc_dato('FS frente al par', R.FS_pris_T, '-', '%.2f');
mc_dato('FS frente a la fuerza axial de la corona', R.FS_pris_A, '-', '%.1f');
R = mc_verificacion(R, 'Prisioneros de la corona (par)', sprintf('FS = %.2f', R.FS_pris_T), 'FS >= 4', R.FS_pris_T >= P.FS_din_min);

mc_seccion('Soportes de ABS con insertos IPFC-M4');
F_asiento_n4 = P.T_asiento_n4 / (P.K_par * P.d_n4);     % fuerza del n.o 4 a su par de asiento
T_lim = P.K_par * P.F_ext_ins * P.d_M4;                 % par de apriete con el que el inserto llega a la extraccion
H = P.F_ret_n4 * P.F_ext_ins / F_asiento_n4;            % HIPOTESIS: la retencion escala con la fuerza de apriete
T_sop = P.n_pris * H * r;
R.FS_sop = T_sop / R.T_eje;
mc_dato('Fuerza del n.o 4 a su par de asiento (T = K F d)', F_asiento_n4, 'N', '%.0f');
mc_dato('Extraccion del inserto en ABS', P.F_ext_ins, 'N', '%.0f');
mc_dato('Par de apriete M4 que alcanza la extraccion', T_lim, 'N m', '%.3f');
mc_dato('Retencion estimada por prisionero', H, 'N', '%.0f');
mc_dato('Par transmisible estimado por soporte', T_sop, 'N m', '%.2f');
mc_dato('FS estimado frente al par', R.FS_sop, '-', '%.2f');
mc_nota('HIPOTESIS: la retencion es proporcional a la fuerza del prisionero.');
mc_nota('Datos del inserto en ABS moldeado; el ABS impreso puede ser menos resistente.');
R = mc_verificacion(R, 'Prisioneros de los soportes (par)', sprintf('FS ~ %.2f', R.FS_sop), 'FS >= 4', R.FS_sop >= P.FS_din_min);
mc_nota('Verificar en el prototipo el par al que el soporte desliza sobre el eje.');

mc_seccion('Acople motor - sin fin con prisioneros (cota con el prisionero mas pequeno)');
T_ac = R.T_motor;                                   % torque maximo en el motor (incluye S)
T_cap = P.F_ret_n0 * P.d_acople/2;                  % un solo prisionero n.o 0
R.FS_acople = T_cap / T_ac;
mc_dato('Torque a transmitir', T_ac, 'N m', '%.4f');
mc_dato('Retencion del prisionero n.o 0 (Tabla 7-4)', P.F_ret_n0, 'N', '%.0f');
mc_dato('Par transmisible con un prisionero n.o 0 en eje de 5 mm', T_cap, 'N m', '%.3f');
mc_dato('FS (cota inferior)', R.FS_acople, '-', '%.2f');
mc_nota('Cualquier prisionero de acero de tamano n.o 0 o mayor cumple; Tabla 7-4: acero contra eje de acero.');
mc_nota('El empuje del sin fin (MC-08) debe tomarlo su rodamiento fijo, no el acople.');
R = mc_verificacion(R, 'Prisioneros del acople (par)', sprintf('FS >= %.1f', R.FS_acople), 'FS >= 4', R.FS_acople >= P.FS_din_min);
end
