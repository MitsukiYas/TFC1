%% SIMULAR_ESCENARIOS  Simulación de los lazos de elevación y orientación.
% Ejecuta los escenarios con lazo_elevacion.slx y lazo_orientacion.slx
% (los crea con construir_modelos si no existen), guarda las figuras en esta
% carpeta y el reporte en resultados_control.txt.
%
% Columnas de 'sal': 1 consigna [°], 2 ángulo real [°], 3 medido filtrado [°],
% 4 estado (0 parada, 1 medir, 2 mover, 3 en banda, 4 falla), 5 discrepancia [°],
% 6 pulsos/s, 7 en; elevación además: 8 H* [mm], 9 H [mm].

clear; clc; close all;
carpeta = fileparts(mfilename('fullpath'));
if isempty(carpeta), carpeta = pwd; end
cd(carpeta);
if true   % los modelos se regeneran siempre desde construir_modelos.m
    construir_modelos();
end
archivo = fullfile(carpeta, 'resultados_control.txt');
if exist(archivo, 'file'), delete(archivo); end
diary(archivo);
fprintf('SIMULACIÓN DE LOS LAZOS DE ELEVACIÓN Y ORIENTACIÓN\nGenerado: %s\n\n', datestr(now));

[KE, PE, KO, PO] = parametros_control();
fprintf('Período del lazo %.0f ms; ruido del sensor %.3f° rms; filtro tau = %.2f s; espera %.1f s\n', ...
    KE.Ts*1e3, PE.sigma, KE.Ts/KE.a - KE.Ts, KE.T_asent);
fprintf('Elevación: %.4f°/pulso, juego %.3f°, banda %.2f°, w_max %.2f°/s, alfa %.2f°/s²\n', ...
    KE.res, KE.juego, KE.banda, KE.wmax, KE.alfa);
fprintf('Orientación: %.5f°/pulso, juego %.3f°, banda %.2f°, w_max %.2f°/s, alfa %.2f°/s²\n\n', ...
    KO.res, KO.juego, KO.banda, KO.wmax, KO.alfa);
thH = @(H) asind((H - PE.H0)/PE.Lmm);
tolH = 15;     % mm (503)
tolB = 0.5;    % grados (IEC 61724-1, 502)

%% E1. Ajuste de altura de 1000 a 1300 mm y de 1300 a 1000 mm
fprintf('=== E1. Ajuste de altura ===\n');
casos = [1000 1300; 1300 1000];
figure('Name', 'E1', 'Position', [100 100 900 600]);
for k = 1:2
    P = PE; P.H_ini = casos(k,1); P.H_fin = casos(k,2); P.th0 = thH(P.H_ini) + PE.b2; P.t_fin = 25;
    s = simular('lazo_elevacion', KE, P);
    r = resumen(s, KE.Ts, P.t_ref);
    eH = s(end,9) - P.H_fin;
    fprintf('  %4d -> %4d mm: en banda a los %.2f s de la orden, %d movimientos, error final %+.2f mm (tol. ±%d) -> %s\n', ...
        casos(k,1), casos(k,2), r.t_banda, r.n_mov, eH, tolH, ok(abs(eH) <= tolH));
    subplot(2,2,k); t = tiempo(s, KE.Ts);
    plot(t, s(:,8), 'k--', t, s(:,9), 'b', 'LineWidth', 1.2); grid on;
    xlabel('Tiempo [s]'); ylabel('Altura del plano óptico [mm]');
    title(sprintf('%d a %d mm', casos(k,1), casos(k,2))); legend('Consigna', 'Real', 'Location', 'best');
    subplot(2,2,k+2);
    plot(t, s(:,9) - s(:,8), 'b', 'LineWidth', 1.2); hold on;
    yline([-tolH tolH], 'r--'); grid on; ylim([-40 40]);
    xlabel('Tiempo [s]'); ylabel('Error de altura [mm]');
end
guardar(gcf, 'Ctrl_Elev_Ajuste');

%% E2. Parada de emergencia con descenso del brazo y recuperación
fprintf('\n=== E2. Parada de emergencia a 1300 mm ===\n');
P = PE; P.H_ini = 1300; P.H_fin = 1300; P.th0 = thH(1300) + PE.b2; P.t_fin = 90;
P.t_parada = [10 70];
fprintf('  SUPOSICIÓN: descenso de %.2f°/s durante %.0f s de parada\n', P.v_desc, diff(P.t_parada));
s = simular('lazo_elevacion', KE, P); t = tiempo(s, KE.Ts);
i_rearme = find(t >= P.t_parada(2), 1);
H_min = min(s(:,9));
i_ok = find(t > P.t_parada(2) & s(:,4)' == 3, 1);
fprintf('  Altura al rearmar: %.1f mm (%.1f mm bajo la consigna)\n', s(i_rearme,9), 1300 - s(i_rearme,9));
fprintf('  Altura mínima: %.1f mm; vuelve a la banda %.2f s después del rearme; error final %+.2f mm -> %s\n', ...
    H_min, t(i_ok) - P.t_parada(2), s(end,9) - 1300, ok(abs(s(end,9) - 1300) <= tolH));
figure('Name', 'E2', 'Position', [100 100 900 350]);
plot(t, s(:,8), 'k--', t, s(:,9), 'b', 'LineWidth', 1.2); hold on;
xregion(P.t_parada(1), P.t_parada(2), 'FaceColor', [1 0.8 0.8]);
yline(1300 + [-tolH tolH], 'r--'); grid on;
xlabel('Tiempo [s]'); ylabel('Altura del plano óptico [mm]');
legend('Consigna', 'Real', 'Parada', 'Tolerancia', 'Location', 'southeast');
guardar(gcf, 'Ctrl_Elev_Parada');

%% E3. Umbral de detección de atascos
fprintf('\n=== E3. Detección de atascos ===\n');
nsem = 20;
dmax = zeros(nsem, 3);
for j = 1:nsem
    P = PE; P.semilla = j; P.t_fin = 25; K = KE; K.umbral = 1e3;
    P.H_ini = 1000; P.H_fin = 1300; P.th0 = thH(1000) + PE.b2;
    s = simular('lazo_elevacion', K, P); dmax(j,1) = max(abs(s(:,5)));
    P.H_ini = 1300; P.H_fin = 1000; P.th0 = thH(1300) + PE.b2;
    s = simular('lazo_elevacion', K, P); dmax(j,2) = max(abs(s(:,5)));
    Q = PO; Q.semilla = j; Q.t_fin = 15; Q.b_ini = -30; Q.b_fin = 30; Q.th0 = -30 + PO.b2; K = KO; K.umbral = 1e3;
    s = simular('lazo_orientacion', K, Q); dmax(j,3) = max(abs(s(:,5)));
end
fprintf('  Discrepancia máxima sin atasco en %d semillas de ruido:\n', nsem);
fprintf('    elevación, subida: %.3f°; bajada: %.3f°\n', max(dmax(:,1:2)));
fprintf('    orientación, barrido de -30° a +30°: %.3f° (incluye el cruce del juego en 0°; 502 no define detección de atascos)\n', max(dmax(:,3)));
umbrales = [0.25 0.5 1.0 2.0];
th_tr = 45;
fprintf('  Brazo trabado a %.0f° durante la subida de 1000 a 1300 mm:\n', th_tr);
fprintf('  %10s %18s %22s %24s\n', 'umbral [°]', 'falsas alarmas', 'detección [s]', 'giro del motor tras traba [°]');
for u = umbrales
    fa = sum(dmax(:,1:2) > u, 'all');
    P = PE; P.H_ini = 1000; P.H_fin = 1300; P.th0 = thH(1000) + PE.b2; P.t_fin = 25;
    P.th_traba = th_tr; P.t_traba = 0; K = KE; K.umbral = u;
    s = simular('lazo_elevacion', K, P); t = tiempo(s, KE.Ts);
    i_tr = find(s(:,2) >= th_tr - 1e-3, 1);
    i_f = find(s(:,4) == 4, 1);
    if isempty(i_f)
        fprintf('  %10.2f %18d %22s %24s\n', u, fa, 'no detecta', '-');
    else
        giro = sum(s(i_tr:i_f,6))*KE.Ts*KE.res;   % grados en el brazo ordenados al motor con el brazo trabado
        fprintf('  %10.2f %18d %22.2f %24.2f\n', u, fa, t(i_f) - t(i_tr), giro);
    end
end
fprintf('  Falsas alarmas: movimientos de elevación (de %d) cuya discrepancia supera el umbral.\n', 2*nsem);

%% O1. Orientación de 0 a 20°
fprintf('\n=== O1. Ajuste de inclinación ===\n');
casos = [0 20; 20 -12];
figure('Name', 'O1', 'Position', [100 100 900 600]);
for k = 1:2
    Q = PO; Q.b_ini = casos(k,1); Q.b_fin = casos(k,2); Q.th0 = casos(k,1) - PO.b2*sign(casos(k,1)); Q.t_fin = 12;
    s = simular('lazo_orientacion', KO, Q);
    r = resumen(s, KO.Ts, Q.t_ref);
    e = s(end,2) - Q.b_fin;
    fprintf('  %+3d° -> %+3d°: en banda a los %.2f s, %d movimientos, error real %+.3f° (tol. ±%.1f°) -> %s\n', ...
        casos(k,1), casos(k,2), r.t_banda, r.n_mov, e, tolB, ok(abs(e) <= tolB));
    t = tiempo(s, KO.Ts);
    subplot(2,2,k); plot(t, s(:,1), 'k--', t, s(:,2), 'b', 'LineWidth', 1.2); grid on;
    xlabel('Tiempo [s]'); ylabel('Inclinación [°]'); title(sprintf('%+d° a %+d°', casos(k,1), casos(k,2)));
    legend('Consigna', 'Real', 'Location', 'best');
    subplot(2,2,k+2); plot(t, s(:,2) - s(:,1), 'b', 'LineWidth', 1.2); hold on;
    yline([-tolB tolB], 'r--'); grid on; ylim([-1.5 1.5]);
    xlabel('Tiempo [s]'); ylabel('Error de inclinación [°]');
end
guardar(gcf, 'Ctrl_Orient_Ajuste');

%% O2. Ráfaga con el límite de 502
fprintf('\n=== O2. Ráfaga de %.0f km/h (límite de 502 para |theta| >= 12°) ===\n', PO.V_lim(2));
betas = [20 10];
figure('Name', 'O2', 'Position', [100 100 900 600]);
for k = 1:2
    Q = PO; Q.b_ini = betas(k); Q.b_fin = betas(k); Q.th0 = betas(k) - PO.b2*sign(betas(k)); Q.t_fin = 40;
    Q.V_rafaga = PO.V_lim(2); Q.t_rafaga = [10 25];
    Mret = Q.Kret*sind(betas(k)); Mv = Q.Kv*Q.V_rafaga^2;
    s = simular('lazo_orientacion', KO, Q); t = tiempo(s, KO.Ts);
    en_raf = t >= Q.t_rafaga(1) & t < Q.t_rafaga(2);
    e = s(:,2) - s(:,1);
    fprintf('  beta = %2d°: M_ret %.4f N·m, M_rafaga %.4f N·m -> %s\n', betas(k), Mret, Mv, ...
        ternario(Mv > Mret, 'cruza el juego', 'no cruza el juego'));
    fprintf('     error máximo %.3f°; correcciones del lazo: %d; error al final %+.3f°\n', ...
        max(abs(e)), sum(diff(s(:,4)) ~= 0 & s(2:end,4) == 2), e(end));
    fprintf('     tiempo con |error| > %.1f° durante y después de la ráfaga: %.2f s\n', tolB, sum(abs(e) > tolB)*KO.Ts);
    subplot(2,1,k); plot(t, e, 'b', 'LineWidth', 1.2); hold on;
    xregion(Q.t_rafaga(1), Q.t_rafaga(2), 'FaceColor', [1 0.8 0.8]);
    yline([-tolB tolB], 'r--'); grid on; ylim([-1.5 1.5]);
    xlabel('Tiempo [s]'); ylabel('Error de inclinación [°]');
    title(sprintf('\\beta = %d°, ráfaga de %.0f km/h', betas(k), Q.V_rafaga));
end
guardar(gcf, 'Ctrl_Orient_Rafaga');

diary off;
fprintf('\nReporte: %s\n', archivo);

%% =====================================================================
function s = simular(modelo, K, PL)
assignin('base', 'K', K); assignin('base', 'PL', PL);
out = sim(modelo);
s = out.sal;
end

function t = tiempo(s, Ts)
t = (0:size(s,1)-1)*Ts;
end

function r = resumen(s, Ts, t_ref)
t = tiempo(s, Ts);
i = find(t > t_ref + Ts & s(:,4)' == 3, 1);
r.t_banda = t(i) - t_ref;
r.n_mov = sum(diff(s(:,4)) ~= 0 & s(2:end,4) == 2);
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
