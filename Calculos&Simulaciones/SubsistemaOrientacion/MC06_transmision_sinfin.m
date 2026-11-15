function R = MC06_transmision_sinfin(P, R)
% MC06  Geometria, eficiencia y autobloqueo del par tornillo sin fin - corona.
mc_encabezado(6, 'Transmision tornillo sin fin - corona', ...
    'Calcular geometria, eficiencias, autobloqueo y friccion dinamica.', ...
    {'Shigley Ec. 13-43, 13-46, 13-47 y 15-38', 'KHK Gear Technical Reference, Ec. 4.27 y Tabla 4.23'});
i = P.Z2 / P.Z1;
R.i = i;
R.d_w = P.d_ext - 2*P.m_mod;                 % addendum = 1.00 m (KHK Tabla 4.23)
R.q = R.d_w / P.m_mod;
R.lambda = atan(P.m_mod*P.Z1 / R.d_w);
R.d_2 = P.m_mod * P.Z2;
R.a = (R.d_w + R.d_2) / 2;
c = cos(P.phi_n); l = R.lambda;
R.eta_f  = @(mu) (c - mu*tan(l)) ./ (c + mu*cot(l));   % directa (el sin fin mueve la corona), Shigley 13-46
R.etai_f = @(mu) (c - mu*cot(l)) ./ (c + mu*tan(l));   % inversa (la corona mueve el sin fin), de Shigley 13-43
R.eta_s = R.eta_f(P.mu_s);
R.eta_inv = R.etai_f(P.mu_s);
R.mu_lim = c * tan(l);                                 % KHK Ec. 4.27

% Friccion dinamica (AGMA, Shigley 15-38) a la velocidad maxima del motor
V_w = pi * R.d_w * R.n_motor / 60;      % m/s, en el diametro de paso del sin fin
R.V_s = V_w / cos(l);                   % Shigley 13-47
Vs_fpm = R.V_s / 0.00508;               % ft/min
if Vs_fpm == 0
    R.mu_d = 0.15;
elseif Vs_fpm <= 10
    R.mu_d = 0.124*exp(-0.074*Vs_fpm^0.645);
else
    R.mu_d = 0.103*exp(-0.110*Vs_fpm^0.450) + 0.012;
end
R.eta_d = R.eta_f(R.mu_d);

mc_seccion('Geometria');
mc_dato('Diametro de paso del sin fin d_w = d_ext - 2m', R.d_w*1e3, 'mm', '%.2f');
mc_dato('Factor diametral q = d_w/m', R.q, '-', '%.2f');
mc_dato('Angulo de avance lambda', R.lambda*180/pi, 'grados', '%.3f');
mc_dato('Diametro de paso de la corona d_2 = m Z2', R.d_2*1e3, 'mm', '%.2f');
mc_dato('Distancia entre centros a', R.a*1e3, 'mm', '%.3f');
mc_seccion('Eficiencia y autobloqueo');
mc_dato('Eficiencia estatica eta_s (mu = 0.15)', R.eta_s, '-', '%.4f');
mc_dato('Eficiencia inversa eta_inv', R.eta_inv, '-', '%.4f');
mc_dato('mu limite de autobloqueo = cos(phi_n) tan(lambda)', R.mu_lim, '-', '%.4f');
mc_dato('Margen de autobloqueo mu_s / mu_lim', P.mu_s/R.mu_lim, '-', '%.2f');
R = mc_verificacion(R, 'Autobloqueo en reposo', sprintf('eta_inv = %.3f', R.eta_inv), 'eta_inv < 0', R.eta_inv < 0);
mc_seccion('Friccion dinamica (AGMA)');
mc_dato('Velocidad de deslizamiento V_s', R.V_s, 'm/s', '%.4f');
mc_dato('Velocidad de deslizamiento V_s', Vs_fpm, 'ft/min', '%.2f');
mc_dato('Coeficiente de friccion dinamico', R.mu_d, '-', '%.4f');
mc_dato('Eficiencia dinamica', R.eta_d, '-', '%.4f');
mc_dato('Margen de autobloqueo con mu dinamico', R.mu_d/R.mu_lim, '-', '%.2f');
mc_nota('Por debajo de mu_lim el autobloqueo desaparece: se mantiene corriente de retencion y lazo cerrado.');
end
