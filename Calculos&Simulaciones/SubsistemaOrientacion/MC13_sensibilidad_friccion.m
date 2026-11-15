function R = MC13_sensibilidad_friccion(P, R)
% MC13  Sensibilidad de la transmision al coeficiente de friccion.
mc_encabezado(13, 'Sensibilidad al coeficiente de friccion', ...
    'Evaluar eficiencia, autobloqueo, torque del motor y FS de pull-out para varios mu.', {});
fprintf('   %8s %8s %16s %14s %12s\n', 'mu', 'eta', 'mu/mu_lim', 'T_motor [N m]', 'FS pull-out');
R.sens = zeros(numel(P.mu_tabla), 5);
for k = 1:numel(P.mu_tabla)
    mu = P.mu_tabla(k);
    Tm = R.T_m_fun(mu);
    fila = [mu, R.eta_f(mu), mu/R.mu_lim, Tm, R.T_po/Tm];
    R.sens(k,:) = fila;
    fprintf('   %8.3f %8.3f %16.2f %14.4f %12.2f\n', fila);
end
mc_nota('Con mu < mu_lim desaparece el autobloqueo.');
end
