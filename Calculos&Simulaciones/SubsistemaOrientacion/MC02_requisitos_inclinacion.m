function R = MC02_requisitos_inclinacion(P, R)
% MC02  Pitch admisible del chasis y umbral beta_min (requisito IEC 61724-1).
mc_encabezado(2, 'Requisitos de inclinacion y azimut', ...
    'Calcular el pitch admisible del chasis y la inclinacion minima beta_min.', ...
    {'IEC 61724-1:2021 (Clase A: 0.5 grados inclinacion, 1.0 grados azimut)'});
mc_seccion('Pitch admisible |p| <= az_adm * tan(beta)');
mc_nota('Desviacion de azimut por pitch p: p*cot(beta) (aproximacion lineal).');
mc_nota('Toda la tolerancia de azimut se asigna al pitch (rumbo del robot paralelo a la fila).');
umbral = P.margen_pitch * P.err_imu;
fprintf('   %10s %22s %16s\n', 'beta [gr]', 'pitch admisible [gr]', 'cumple >= umbral');
for b = P.beta_tabla
    p_adm = P.az_adm * tand(b);
    if p_adm >= umbral, c = 'Si'; else, c = 'No'; end
    fprintf('   %10.0f %22.3f %16s\n', b, p_adm, c);
end
R.beta_min = atand(umbral / P.az_adm);
mc_seccion('Umbral de verificacion');
mc_dato('Umbral de pitch medible (margen x exactitud IMU)', umbral, 'grados');
mc_dato('beta_min = atan(umbral / az_adm)', R.beta_min, 'grados', '%.2f');
mc_nota('Se redondea a 12 grados (criterio de diseno del trabajo).');
end
