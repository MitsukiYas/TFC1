function R = MC03_cinematica(P, R)
% MC03  Perfil trapezoidal de velocidad del barrido.
mc_encabezado(3, 'Perfil de movimiento', ...
    'Obtener velocidad y aceleracion angulares y la velocidad del motor.', {});
dth = P.th_max - P.th_min;
t_a = P.f_a * P.t_b;
R.w_max = dth / (P.t_b - t_a);          % rad/s
R.alfa  = R.w_max / t_a;                % rad/s^2
i = P.Z2 / P.Z1;
R.n_motor = R.w_max * i * 60 / (2*pi);  % rpm
% Trayectoria muestreada; la usan las memorias MC-04 en adelante
t = linspace(0, P.t_b, 50001);
th = zeros(size(t)); acc = zeros(size(t));
f1 = t < t_a; f3 = t > P.t_b - t_a; f2 = ~f1 & ~f3;
th(f1) = P.th_min + 0.5*R.alfa*t(f1).^2;
th(f2) = P.th_min + 0.5*R.alfa*t_a^2 + R.w_max*(t(f2) - t_a);
th(f3) = P.th_max - 0.5*R.alfa*(P.t_b - t(f3)).^2;
acc(f1 | f3) = R.alfa;                 % modulo de la aceleracion
R.t = t; R.th = th; R.acc = acc; R.t_a = t_a;
mc_seccion('Resultados');
mc_dato('Tiempo de aceleracion t_a = f_a t_b', t_a, 's');
mc_dato('Velocidad angular maxima', R.w_max, 'rad/s', '%.4f');
mc_dato('Velocidad angular maxima', R.w_max*180/pi, 'grados/s', '%.2f');
mc_dato('Aceleracion angular', R.alfa, 'rad/s^2', '%.4f');
mc_dato('Velocidad maxima del motor', R.n_motor, 'rpm', '%.1f');
end
