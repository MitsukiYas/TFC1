function MC16_resumen(R)
% MC16  Resumen de verificaciones.
mc_encabezado(16, 'Resumen de verificaciones', 'Listar todas las verificaciones.', {});
fprintf('   %-40s %-18s %-16s %s\n', 'Verificacion', 'Resultado', 'Criterio', 'Estado');
for k = 1:size(R.verif, 1)
    fprintf('   %-40s %-18s %-16s %s\n', R.verif{k,:});
end
end
