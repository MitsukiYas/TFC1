function R = MC14_presupuesto_error(P, R)
% MC14  Presupuesto de error angular de inclinacion.
mc_encabezado(14, 'Presupuesto de error angular', ...
    'Comparar el error en lazo abierto y en lazo cerrado con la tolerancia de 0.5 grados.', ...
    {'IEC 61724-1:2021', 'InvenSense PS-MPU-6000A-00 rev. 3.4'});
juego = P.j_t / (R.d_2/2) * 180/pi;
res_paso = P.paso / R.i;
res_micro = P.paso / P.micro / R.i;
abierto = [juego, res_paso, 0, P.err_montaje, P.err_rod, 0];
cerrado = [0, res_micro, P.err_imu, P.err_montaje, P.err_rod, R.giro_tor];
nombres = {'Juego del engrane', 'Resolucion del actuador', 'Exactitud del sensor inercial', ...
           'Montaje del sensor y soportes', 'Holgura de los rodamientos', 'Giro por torsion del eje'};
fprintf('   %-34s %14s %14s\n', 'Fuente', 'Abierto [gr]', 'Cerrado [gr]');
for k = 1:numel(nombres)
    fprintf('   %-34s %14.4f %14.4f\n', nombres{k}, abierto(k), cerrado(k));
end
R.err_ab_lin = sum(abierto); R.err_ab_rss = sqrt(sum(abierto.^2));
R.err_ce_lin = sum(cerrado); R.err_ce_rss = sqrt(sum(cerrado.^2));
fprintf('   %-34s %14.3f %14.3f\n', 'Suma lineal', R.err_ab_lin, R.err_ce_lin);
fprintf('   %-34s %14.3f %14.3f\n', 'Suma cuadratica (RSS)', R.err_ab_rss, R.err_ce_rss);
mc_seccion('Efectos del sensor inercial (hoja de datos)');
mc_dato('Error por escala 3% con calibracion solo de offset, 30 gr', ...
        P.mpu_escala*sind(30)*cosd(30)*180/pi, 'grados', '%.2f');
mc_dato('Variacion de salida a cero g (0-70 C) en inclinacion', asind(P.mpu_zerog), 'grados', '%.2f');
mc_nota('El valor de 0.1 grados exige calibracion de seis posiciones y compensacion de temperatura.');
R = mc_verificacion(R, 'Error en lazo cerrado (suma lineal)', sprintf('%.3f gr', R.err_ce_lin), '<= 0.5 gr', R.err_ce_lin <= P.eps_adm);
end
