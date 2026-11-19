%% SIMULAR_TRACCION  Simulación del control de tracción y dirección.
% Regenera lazo_traccion.slx, ejecuta los escenarios y guarda las figuras y el
% reporte resultados_traccion.txt en esta carpeta. Columnas de 'sal' (cada 2 ms):
% 1 v*, 2 v, 3 w*izq, 4 w med izq, 5 w*der, 6 w med der, 7 d izq, 8 d der, 9 I izq,
% 10 I der, 11 F tracción, 12 N posterior, 13 pendiente, 14 T izq, 15 T der,
% 16 delta izq [°], 17 delta der [°], 18 curvatura del firmware, 19 curvatura real, 20 x, 21 y.

clear; clc; close all;
carpeta = fileparts(mfilename('fullpath'));
if isempty(carpeta), carpeta = pwd; end
cd(carpeta);
construir_modelo_traccion();
archivo = fullfile(carpeta, 'resultados_traccion.txt');
if exist(archivo, 'file'), delete(archivo); end
diary(archivo);
fprintf('SIMULACIÓN DEL CONTROL DE TRACCIÓN Y DIRECCIÓN\nGenerado: %s\n\n', datestr(now));

[KT, PT] = parametros_traccion();
dt = 0.002;
fprintf('Geometría: L = %.0f mm, pivotes b = %.0f mm, vía trasera t = %.0f mm, R_min = %.3f m\n', ...
    PT.L*1e3, PT.b*1e3, PT.t*1e3, PT.Rmin);
fprintf('Motor: R = %.3f ohm, ke = %.3f V·s/rad, kt = %.3f N·m/A, I0 = %.1f A ', PT.R, PT.ke, PT.kt, PT.I0);
fprintf('(bloqueo a 24 V: %.1f A con este modelo; %.1f A según el fabricante)\n', 24/PT.R, PT.I_bloqueo_fab);
fprintf('Encoder: %d pulsos/vuelta del motor (SUPOSICIÓN) -> %d cuentas por vuelta de rueda\n', PT.ppr, PT.cuentas);
fprintf('Servo: %.0f°/s sin carga, %.0f°/s con %.2f N·m (de %.2f N·m de bloqueo)\n', ...
    PT.w_servo0, PT.w_servo, PT.T_servo, PT.T_bloq_servo);
fprintf('PI: Kp = %.4f /(rad/s), Ti = %.3f s (tau_m = %.3f s, tau_cl = %.2f s a %.1f V), Ts = %.0f ms\n\n', ...
    KT.Kp, KT.Ti, KT.tau_m, KT.tau_cl, KT.V_dis, KT.Ts*1e3);
Vb = [29.4 21.7];

%% S1. Arranque en terreno plano
fprintf('=== S1. Arranque en terreno plano hasta %.1f m/s (rampa de %.1f m/s²) ===\n', PT.v_nom, PT.a_ref);
figure('Name', 'S1', 'Position', [100 100 900 600]);
for k = 1:2
    P = PT; P.V_bat = Vb(k); P.t_fin = 8;
    s = simular(KT, P); t = tiempo(s, dt); r = metricas(s, t, P);
    informe(Vb(k), r, KT);
    graficar(t, s, P, k, sprintf('Plano, V_{bat} = %.1f V', Vb(k)), KT);
end
guardar(gcf, 'Ctrl_Trac_Plano');

%% S2. Arranque en la pendiente de 16°
fprintf('\n=== S2. Arranque desde el reposo en la pendiente de %d° ===\n', PT.pend);
figure('Name', 'S2', 'Position', [100 100 900 600]);
for k = 1:2
    P = PT; P.V_bat = Vb(k); P.pend0 = PT.pend; P.t_fin = 10;
    s = simular(KT, P); t = tiempo(s, dt); r = metricas(s, t, P);
    informe(Vb(k), r, KT);
    fprintf('     retroceso inicial %.1f mm; F máx. %.1f N frente a mu·N_r = %.1f N en ese instante -> %s\n', ...
        r.retro*1e3, r.F_max, r.muN_en_Fmax, ok(r.F_max <= r.muN_en_Fmax));
    graficar(t, s, P, k, sprintf('Pendiente de %d°, V_{bat} = %.1f V', PT.pend, Vb(k)), KT);
end
guardar(gcf, 'Ctrl_Trac_Pendiente');
fprintf('  Sensibilidad al neumático supuesto (V_bat = 29.4 V):\n');
for sp = [0.05 0.15]
    P = PT; P.V_bat = 29.4; P.pend0 = PT.pend; P.t_fin = 10; P.s_pico = sp;
    s = simular(KT, P); t = tiempo(s, dt); r = metricas(s, t, P);
    fprintf('     deslizamiento al pico %.2f: v suelo %.3f m/s (deslizamiento %.1f %%), error de rueda %.3f m/s\n', ...
        sp, r.v_fin, 100*r.desl, r.e_w);
end

%% S3. Entrada brusca en la pendiente a velocidad nominal
fprintf('\n=== S3. Entrada en la pendiente de %d° a %.1f m/s ===\n', PT.pend, PT.v_nom);
figure('Name', 'S3', 'Position', [100 100 900 350]);
for k = 1:2
    P = PT; P.V_bat = Vb(k); P.pend_t = [6 PT.pend]; P.t_fin = 10;
    s = simular(KT, P); t = tiempo(s, dt);
    vw = rueda_media(s, P);
    i6 = t >= 6; [vmin, j] = min(vw(i6)); t6 = t(i6);
    i_rec = find(t > t6(j) & abs(vw' - PT.v_nom) <= 0.02, 1);
    fprintf('  V_bat = %.1f V: velocidad de rueda mínima %.3f m/s; vuelve a ±0.02 m/s en %s; I máx. %.2f A\n', ...
        Vb(k), vmin, ternario(isempty(i_rec), 'no vuelve', sprintf('%.2f s', t(i_rec) - 6)), max(s(i6,9)));
    plot(t, vw, 'LineWidth', 1.2); hold on;
end
xline(6, 'k:'); grid on; xlabel('Tiempo [s]'); ylabel('Velocidad de rueda \omega r [m/s]'); ylim([0 1.2]);
legend('V_{bat} = 29.4 V', 'V_{bat} = 21.7 V', 'Entrada en la pendiente', 'Location', 'southeast');
guardar(gcf, 'Ctrl_Trac_Escalon');

%% S4. Viraje de radio mínimo: diferencial y mando de la dirección
fprintf('\n=== S4. Viraje de radio %.2f m a %.1f m/s, V_bat = 29.4 V ===\n', PT.Rmin, PT.v_nom);
casos = {'sin diferencial', 0, 0, 0; ...
         'diferencial sin límite de velocidad en curva', 1, 0, 0; ...
         'diferencial con límite en curva, consigna de dirección sin limitar', 1, 0, 1; ...
         'diferencial con límite en curva y consigna limitada a la velocidad del servo', 1, PT.w_servo, 1};
figure('Name', 'S4', 'Position', [100 100 900 1000]);
for k = 1:4
    P = PT; P.diferencial = casos{k,2}; P.giro = [6 12 1/PT.Rmin]; P.t_fin = 14;
    K = KT; K.w_servo = casos{k,3}; K.limitar_curva = casos{k,4};
    s = simular(K, P); t = tiempo(s, dt);
    ig = t >= 8 & t < 12; it = t >= 5.9 & t < 7;
    fprintf('  %s:\n', casos{k,1});
    fprintf('     en el viraje: I interior %.2f A, exterior %.2f A; T interior %+.2f, exterior %+.2f N·m; v %.3f m/s\n', ...
        mean(s(ig,9)), mean(s(ig,10)), mean(s(ig,14)), mean(s(ig,15)), mean(s(ig,2)));
    fprintf('     al entrar: I máx. %.2f A, I mín. %.2f A; servos en posición a los %.2f s\n', ...
        max(s(it,9:10), [], 'all'), min(s(it,9:10), [], 'all'), t_servo(s, t, 6));
    subplot(4,1,k); plot(t, s(:,9), 'b', t, s(:,10), 'r', 'LineWidth', 1.2); hold on;
    xregion(6, 12, 'FaceColor', [0.85 0.85 1]); grid on; ylim([-6 8]);
    xlabel('Tiempo [s]'); ylabel('Corriente [A]'); title(casos{k,1});
    legend('Rueda interior', 'Rueda exterior', 'Viraje', 'Location', 'southwest');
end
guardar(gcf, 'Ctrl_Trac_Viraje');
for Vb_k = Vb
    w_lim = (min(KT.V_mot, KT.d_max_abs*Vb_k) - KT.R*KT.I_plano)/KT.ke;
    fprintf('  Límite en curva con V_bat = %.1f V: rueda exterior hasta %.1f rpm -> v máx. %.3f m/s en R_min (%.3f m/s en recta)\n', ...
        Vb_k, w_lim*60/(2*pi), w_lim*KT.r/(1 + KT.t*KT.kappa_max/2), min(PT.v_nom, w_lim*KT.r));
end

%% S5. Maniobra en S
fprintf('\n=== S5. Maniobra en S: radio 2 m a la izquierda y luego a la derecha ===\n');
P = PT; P.giro = [5 8 1/2]; P.giro2 = [8 11 -1/2]; P.t_fin = 14;
s = simular(KT, P); t = tiempo(s, dt);
fprintf('  Ángulos máximos: izquierda %.1f°/%.1f°, derecha %.1f°/%.1f° (rueda izq/der)\n', ...
    max(s(:,16)), max(s(:,17)), min(s(:,16)), min(s(:,17)));
ie = (t >= 7 & t < 8) | (t >= 10 & t < 11);   % último segundo de cada tramo
fprintf('  Corriente máx. %.2f A; error medio de rueda al final de cada tramo %.4f m/s\n', ...
    max(s(:,9:10), [], 'all'), mean(abs([s(ie,3)-s(ie,4); s(ie,5)-s(ie,6)]))*P.r);
figure('Name', 'S5', 'Position', [100 100 900 350]);
subplot(1,2,1); plot(t, s(:,16), 'b', t, s(:,17), 'r', 'LineWidth', 1.2); grid on;
xlabel('Tiempo [s]'); ylabel('Ángulo de la rueda frontal [°]'); legend('Izquierda', 'Derecha', 'Location', 'southwest');
subplot(1,2,2); plot(s(:,20), s(:,21), 'b', 'LineWidth', 1.2); axis equal; grid on;
xlabel('x [m]'); ylabel('y [m]'); title('Trayectoria del eje posterior');
guardar(gcf, 'Ctrl_Trac_S');

%% S6. Resolución del encoder
fprintf('\n=== S6. Resolución del encoder del motor (plano, 1 m/s) ===\n');
for ppr = [7 16 64]
    P = PT; P.ppr = ppr; P.cuentas = 2*ppr*P.i_red; P.t_fin = 8; K = KT; K.cuentas = P.cuentas;
    s = simular(K, P); t = tiempo(s, dt); ir = t >= 5;
    fprintf('  %2d pulsos/vuelta (%4d cuentas por vuelta de rueda): paso de velocidad %.4f m/s; ', ...
        ppr, P.cuentas, 2*pi/P.cuentas/K.Ts*P.r);
    fprintf('desviación del ciclo de trabajo %.4f; ondulación de v %.4f m/s\n', std(s(ir,7)), std(s(ir,2)));
end

diary off;
fprintf('\nReporte: %s\n', archivo);

%% =====================================================================
function s = simular(K, PL)
assignin('base', 'K', K); assignin('base', 'PL', PL);
out = sim('lazo_traccion');
s = out.sal;
end

function t = tiempo(s, dt)
t = (0:size(s,1)-1)*dt;
end

function vw = rueda_media(s, P)
% Velocidad media de las ruedas medida por los encoders (filtrada 0.1 s), en m/s
vw = movmean((s(:,4) + s(:,6))/2*P.r, 50);
end

function r = metricas(s, t, P)
ir = t >= P.t_arr + P.v_nom/P.a_ref + 1;
r.v_fin = s(end,2);
vw = rueda_media(s, P);
r.e_w = max(abs(P.v_nom - vw(ir)));
r.desl = 1 - s(end,2)/vw(end);
r.I_max = max(s(:,9:10), [], 'all');
r.d_max = max(s(:,7:8), [], 'all');
r.retro = -min(cumsum(s(:,2))*(t(2) - t(1)));
ia = t >= P.t_arr;
[r.F_max, j] = max(s(ia,11));
muN = P.mu*s(ia,12);
r.muN_en_Fmax = muN(j);
end

function ts = t_servo(s, t, t0)
fin = s(find(t >= 10, 1), 16);
i = find(t >= t0 & abs(s(:,16)' - fin) < 0.05, 1);
ts = t(i) - t0;
end

function informe(Vb, r, K)
fprintf('  V_bat = %.1f V: error de velocidad de rueda en régimen %.3f m/s; v suelo %.3f m/s (deslizamiento %.1f %%)\n', ...
    Vb, r.e_w, r.v_fin, 100*r.desl);
fprintf('     I máx. %.2f A (límite %.0f A), ciclo máx. %.2f\n', r.I_max, K.I_lim, r.d_max);
end

function graficar(t, s, P, k, titulo, K)
subplot(2,2,k); plot(t, s(:,1), 'k--', t, rueda_media(s, P), 'b', t, s(:,2), 'g', 'LineWidth', 1.2); grid on;
xlabel('Tiempo [s]'); ylabel('Velocidad [m/s]'); title(titulo); ylim([-0.2 1.2]);
legend('Consigna', 'Rueda (\omega r)', 'Suelo', 'Location', 'southeast');
subplot(2,2,k+2); plot(t, s(:,9), 'b', 'LineWidth', 1.2); hold on; yline(K.I_lim, 'r--');
grid on; xlabel('Tiempo [s]'); ylabel('Corriente por motor [A]'); ylim([-2 10]);
end

function m = ok(c)
if c, m = 'CUMPLE'; else, m = 'NO CUMPLE'; end
end

function m = ternario(c, a, b)
if c, m = a; else, m = b; end
end

function guardar(h, nombre)
theme(h, 'light');
exportgraphics(h, fullfile(fileparts(mfilename('fullpath')), [nombre '.png']), 'Resolution', 200);
end
