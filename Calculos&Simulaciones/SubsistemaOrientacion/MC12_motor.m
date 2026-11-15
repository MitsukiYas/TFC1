function R = MC12_motor(P, R)
% MC12  Verificacion del motor 17HS16-2004S1.
mc_encabezado(12, 'Motor a pasos', ...
    'Verificar el motor frente a retencion y pull-out a la corriente configurada.', ...
    {'StepperOnline 17HS16-2004S1: pagina, hoja de datos y curva (DM542T, 24 V, 2.05 A pico)'});
R.T_ret = P.T_ret_nom * P.I_set / P.I_nom;
R.T_po = P.T_po_min * P.I_set / P.I_curva;
R.FS_ret = R.T_ret / R.T_motor;
R.FS_po = R.T_po / R.T_motor;
mc_dato('Torque requerido (eficiencia estatica)', R.T_motor, 'N m', '%.4f');
mc_dato('Retencion escalada a 1.40 A', R.T_ret, 'N m', '%.3f');
mc_dato('Pull-out minimo 0-90 rpm (60 rpm) en el ensayo', P.T_po_min, 'N m', '%.2f');
mc_dato('Pull-out escalado a 1.40 A de pico', R.T_po, 'N m', '%.3f');
mc_dato('FS frente a retencion', R.FS_ret, '-', '%.2f');
mc_dato('FS frente a pull-out', R.FS_po, '-', '%.2f');
mc_nota('Escalado lineal con la corriente (valido a baja velocidad); tension >= 24 V.');
R = mc_verificacion(R, 'Motor frente a pull-out', sprintf('FS = %.2f', R.FS_po), 'FS >= 1', R.FS_po >= 1);
R = mc_verificacion(R, 'Motor frente a retencion', sprintf('FS = %.2f', R.FS_ret), 'FS >= 1', R.FS_ret >= 1);
end
