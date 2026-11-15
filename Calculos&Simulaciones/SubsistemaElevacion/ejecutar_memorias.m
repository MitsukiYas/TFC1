%% EJECUTAR_MEMORIAS  Corre las memorias de cálculo del subsistema de elevación en orden.
% Todas leen parametros_elevacion.m; la 03 y la 04 usan cargas_elevacion.mat (generado por la 02).
% (Cada memoria ejecuta "clear", por eso se llaman una por una.)
run('memoria_01_geometria.m');            fprintf('\n\n');
run('memoria_02_cargas.m');               fprintf('\n\n');
run('memoria_03_acoplador_U.m');          fprintf('\n\n');
run('memoria_04_cartelas_travesano.m');     fprintf('\n\n');
run('memoria_05_par_requerido.m');        fprintf('\n\n');
run('memoria_06_requerimientos_motor.m'); fprintf('\n\n');
run('memoria_07_eje_salida.m');      fprintf('\n\n');
run('memoria_08_pasador_base.m');
fprintf('\n\n');
run('memoria_09_soportes_base.m');
fprintf('\n\n');
run('memoria_10_error_altura.m');
fprintf('\n\n');
run('memoria_11_brazos.m');
fprintf('\n\n');
run('memoria_12_masa.m');
