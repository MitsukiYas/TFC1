function R = MC07_torque_trayectoria(P, R, carpeta_fig)
% MC07  Torque de salida y torque del motor a lo largo del barrido.
mc_encabezado(7, 'Torque a lo largo de la trayectoria', ...
    'Calcular T_out(t) y T_motor(t) y generar la figura de torques.', {});
R.Tout_t = abs(R.Mg) + R.M_v + P.T_rod + R.J_total*R.acc;
% Inercia del lado del motor: rotor + sin fin (cilindro de acero) + acoplamiento
m_w = P.rho_acero*pi*(R.d_w/2)^2*P.L_sinfin;
R.J_sinfin = 0.5*m_w*(R.d_w/2)^2;
R.J_m = P.J_rotor + R.J_sinfin + P.J_acople;
Tm = @(eta) P.S*R.Tout_t/(R.i*eta) + P.S*R.J_m*R.i*R.acc;
R.Tm_s_t = Tm(R.eta_s);
R.Tm_d_t = Tm(R.eta_d);
[R.T_out, k] = max(R.Tout_t);
R.t_Tout = R.t(k); R.th_Tout = R.th(k);
R.T_motor = max(R.Tm_s_t);
R.T_motor_d = max(R.Tm_d_t);
R.T_m_fun = @(mu) P.S*R.T_out/(R.i*R.eta_f(mu)) + P.S*R.J_m*R.i*R.acc(k);
mc_nota('T_out = |M_piv| + M_v + T_rod + J_total |alfa| (suma de modulos: autobloqueo).');
mc_nota('T_motor = S T_out/(i eta) + S J_m i |alfa|, J_m = rotor + sin fin + acoplamiento.');
mc_seccion('Resultados');
mc_dato('Inercia del lado del motor J_m', R.J_m, 'kg m^2', '%.3e');
mc_dato('T_out maximo', R.T_out, 'N m', '%.4f');
mc_dato('Instante del maximo', R.t_Tout, 's', '%.2f');
mc_dato('Angulo del maximo', R.th_Tout*180/pi, 'grados', '%.1f');
mc_dato('T_motor maximo (eficiencia estatica)', R.T_motor, 'N m', '%.4f');
mc_dato('T_motor maximo (eficiencia dinamica)', R.T_motor_d, 'N m', '%.4f');

% Figura: retencion y pull-out escalados a la corriente configurada
T_ret = P.T_ret_nom * P.I_set / P.I_nom;
T_po  = P.T_po_min * P.I_set / P.I_curva;
f = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 800 600]);
subplot(2,1,1);
plot(R.t, abs(R.Mg), 'LineWidth', 1.2); hold on;
plot(R.t, R.Tout_t, 'LineWidth', 1.5);
plot(R.t, R.M_v*ones(size(R.t)), '--', 'LineWidth', 1.0);
grid on; xlabel('Tiempo [s]'); ylabel('Torque [N m]');
legend('|M_{piv}|', 'T_{out}', 'M_v', 'Location', 'southeast');
title('Torques en el eje de salida durante el barrido');
subplot(2,1,2);
plot(R.t, R.Tm_s_t, 'LineWidth', 1.5); hold on;
plot(R.t, R.Tm_d_t, 'LineWidth', 1.2);
plot(R.t, T_po*ones(size(R.t)), 'k--');
plot(R.t, T_ret*ones(size(R.t)), 'k:');
grid on; xlabel('Tiempo [s]'); ylabel('Torque [N m]');
legend('T_{motor} (\eta_s)', 'T_{motor} (\eta_d)', 'Pull-out a 1.40 A', 'Retencion a 1.40 A', 'Location', 'east');
title('Torque requerido en el motor frente a su capacidad');
print(f, fullfile(carpeta_fig, 'Tilt_Torques_MATLAB.png'), '-dpng', '-r200');
close(f);
mc_nota('Figura guardada: Tilt_Torques_MATLAB.png');
end
