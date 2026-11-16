%% MEMORIA 08 - Pasador continuo del pivote actuado (base)
% El pasador está fijo (apretado con perilla y tuerca) en el apoyo del lado no accionado,
% atraviesa el brazo no accionado y su KFL08, el casquillo de los resortes y termina dentro
% del agujero de la KFL08 del brazo accionado. En el lado accionado no hay apoyo: el marco
% de los brazos inferiores se apoya en el eje del reductor (memoria 07).
% Fuentes: plano KFL08 (Naylamp: 48 x 27 x 13 mm, ala 4 mm, agujero Ø8); ISO 3506-1 (sección roscada);
% ficha AISI 4140 (Sy = 900 MPa, Ø <= 16); Lee Spring (resortes, pp. 285, 286, 298); Shigley 11.ª ed., pp. 519-521.
% Requiere cargas_elevacion.mat (memoria 02).
clear; clc;
run('parametros_elevacion.m');
load('cargas_elevacion.mat');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 08: PASADOR CONTINUO DEL PIVOTE ACTUADO ===\n\n');

%% 1. Datos
n = P.nodo; d = n.d_pasador;
t_apoyo  = 5;      % mm, espesor del apoyo del lado no accionado (decisión del usuario)
L_perilla = 12;    % mm, rosca tomada por la perilla (confirmado por el usuario)
t_ala_KFL = 4;     % mm, ala de la KFL08 (plano Naylamp)
h_cubo    = n.t_KFL - t_ala_KFL;   % mm, cubo del anillo interior que sobresale del ala (9 mm)
gap       = P.U.w - 2*(n.t_arandela + n.t_tuerca + P.tubo_b + n.t_KFL);   % mm, entre caras de los cubos
% SUPOSICIÓN: el pasador termina 0.5 mm antes de la cara del tubo del brazo accionado (dentro del agujero de la KFL08).
fin_KFL2 = 0.5;
% SUPOSICIÓN: plano fresado de 0.5 mm de profundidad a lo largo de todo el cubo (prisioneros de la KFL08).
h_plano = 0.5;
% Casquillo de los resortes: libre entre los cubos de las KFL08, con juego axial reducido
% SUPOSICIÓN: juego axial total de 1.5 mm para absorber la dilatación térmica y la humedad del POM-C
% (sin coeficiente de dilatación citado todavía; verificar con la ficha del proveedor).
juego_casq = 1.5;                % mm (total)
% Casquillo Ø22 x Ø8.1 (deslizante sobre el pasador h6). El diámetro exterior se verifica en la sección 7
% contra el cierre del resorte (Shigley Ec. 10-53 y 10-55) y el mandril máximo del catálogo (23.81 mm).
D_casq = 22; d_casq = 8.1;

%% 2. Geometría del pasador (x = 0 en la cara interior del apoyo, hacia el brazo accionado)
x_KFL1 = n.t_tuerca + n.t_arandela + P.tubo_b + n.t_KFL/2;     % plano medio de la KFL08 no accionada
x_cubo1 = [n.t_tuerca + n.t_arandela + P.tubo_b + t_ala_KFL, n.t_tuerca + n.t_arandela + P.tubo_b + n.t_KFL];
x_gap = x_cubo1(2) + [0 gap];
x_cubo2 = x_gap(2) + [0 h_cubo];
x_KFL2 = x_gap(2) + n.t_KFL/2;
x_fin  = x_gap(2) + n.t_KFL - fin_KFL2;
L_pas  = L_perilla + t_apoyo + x_fin;
L_rosca = L_perilla + t_apoyo + n.t_tuerca;
fprintf('1. Pasador Ø%d h6 de AISI 4140\n', d);
fprintf('   Largo total = %.1f mm (rosca M8 %.0f + rectificado %.1f)\n', L_pas, L_rosca, L_pas - L_rosca);
fprintf('   Planos fresados (prof. %.1f mm) bajo los cubos: x = %.1f-%.1f y %.1f-%.1f mm desde la cara del apoyo\n', ...
        h_plano, x_cubo1, x_cubo2);
fprintf('   Casquillo Ø%d x Ø%.1f x %.1f mm (juego axial total %.1f mm)\n\n', D_casq, d_casq, gap - juego_casq, juego_casq);

%% 3. Cargas sobre el pasador
% a) Reacción del brazo no accionado en su KFL08 (envolvente de la memoria 02)
R1 = R_base;
% b) Resortes (opción 1, enrollando). Cada espira recibe la fuerza de la varilla transversal en la pata móvil
% (perpendicular al brazo, hacia -v, a l_m del pivote) y la de la varilla de anclaje en la pata fija (-e_psi, a l_f
% de la tangencia). Por equilibrio del resorte, el casquillo (y el pasador) recibe la suma vectorial de ambas.
F_res = 0; th_Fres = NaN; F_pata = 0; F_pf = 0;
for th = linspace(P.th_min, P.th_max, 200)
  M = P.res.M_alto + P.res.k*deg2rad(P.th_max - th + P.res.tol_libre);   % con la tolerancia de posición libre (+15°)
  Fm = M/(P.res.l_m/1000)*[sind(th) -cosd(th)];     % N, varilla transversal sobre la pata móvil
  Ff = -M/(P.res.l_f/1000)*P.res.e_psi;              % N, varilla de anclaje sobre la pata fija
  if norm(Fm + Ff) > F_res, F_res = norm(Fm + Ff); th_Fres = th; end
  F_pata = max(F_pata, norm(Fm)); F_pf = max(F_pf, norm(Ff));
end
x_res  = x_gap(1) + gap/2 + [-1 1]*(P.res.L_cuerpo + 2*n.holg_res)/2;            % centros de los resortes
fprintf('2. Cargas\n');
fprintf('   Reacción del brazo no accionado en x = %.1f mm: %.1f N\n', x_KFL1, R1);
fprintf('   Pata móvil: %.1f N; pata fija: %.1f N; resultante sobre el casquillo: %.1f N por resorte (theta = %.1f°; x = %.0f y %.0f mm)\n\n', ...
        F_pata, F_pf, F_res, th_Fres, x_res);

%% 4. Pasador en voladizo desde el apoyo, con el extremo guiado por la KFL08 accionada
% SUPOSICIÓN: el apoyo empotra el pasador (conservador para el momento en la rosca) y el marco
% sostenido por el reductor fija la posición de la KFL08 accionada.
E = P.E_acero; I = pi*d^4/64; EI = E*I;   % Shigley Tabla A-5
yP = @(Pf, a, x) Pf*a^2.*(3*x - a)/(6*EI);       % flecha en x >= a por una carga Pf en a
k2 = 3*EI/x_KFL2^3;                               % N/mm, rigidez del extremo guiado
y_libre = yP(R1, x_KFL1, x_KFL2) + yP(F_res, x_res(1), x_KFL2) + yP(F_res, x_res(2), x_KFL2);
M_cargas = R1*x_KFL1 + F_res*sum(x_res);          % N·mm en x = 0, sin la guía
d_s = d - 0.9382*1.25; W_r = pi*d_s^3/32;        % sección roscada (ISO 3506-1 Anexo A)
FS_min = 1.5;              % criterio del texto para elementos de acero (FS respecto a Sy)
adm = n.Sy_pasador/FS_min; % esfuerzo admisible con FS >= 1.5, para la desalineación admisible
% Desalineación delta entre el eje del reductor y la posición libre del extremo del pasador.
% Momento en el apoyo: M = |M_cargas - k2·x_KFL2·(y_libre - delta)| (delta del mismo signo que la carga = peor caso)
M_alineado = abs(M_cargas - k2*x_KFL2*y_libre);
delta_adm  = (adm*W_r - M_cargas)/(k2*x_KFL2) + y_libre;
fprintf('3. Flexión del pasador (sección roscada junto al apoyo, d_s = %.2f mm, Sy = %.0f MPa, criterio FS >= %.1f)\n', d_s, n.Sy_pasador, FS_min);
fprintf('   Rigidez del extremo guiado k = %.1f N/mm; flecha libre del extremo = %.2f mm\n', k2, y_libre);
fprintf('   Sin guía (voladizo puro): %.1f MPa\n', M_cargas/W_r);
fprintf('   Reductor alineado con el pasador sin carga: %.1f MPa (FS = %.2f) -> %s\n', M_alineado/W_r, n.Sy_pasador/(M_alineado/W_r), ok(n.Sy_pasador/(M_alineado/W_r) >= FS_min));
fprintf('   Desalineación admisible del eje del reductor: %.2f mm (en el sentido más desfavorable; con adm. Sy/1.5 = %.1f MPa)\n', delta_adm, adm);
delta_spec = 0.7;   % mm, tolerancia de coaxialidad aceptada por el usuario (2026-11-13, revisión)
M_spec = abs(M_cargas - k2*x_KFL2*(y_libre - delta_spec));   % misma convención que delta_adm (corregido 2026-11-13)
fprintf('   Con la tolerancia propuesta de %.1f mm: %.1f MPa (FS = %.2f) -> %s\n', delta_spec, M_spec/W_r, n.Sy_pasador/(M_spec/W_r), ok(n.Sy_pasador/(M_spec/W_r) >= FS_min));
fprintf('   Fuerza en la KFL08 accionada: %.1f N alineado; %.1f N con la tolerancia (C0 = %.0f N)\n\n', k2*y_libre, k2*(y_libre - delta_spec), P.KFL.C0);

%% 5. Sección con plano fresado bajo el cubo de la KFL08 no accionada
% Momento a lo largo de todo el pasador (cargas a la derecha del corte menos la fuerza de la guía), con la
% desalineación de la tolerancia en los dos sentidos; módulo según la sección: roscada (x <= t_tuerca), con plano
% (bajo los cubos) o llena.
xp = x_cubo1(1);
xs = linspace(0, x_KFL2, 2001);
Pq = [R1 F_res F_res]; aq = [x_KFL1 x_res];
% Módulo resistente mínimo de la sección circular con un plano (integración numérica)
[yy, zz] = meshgrid(linspace(-d/2, d/2, 801));
A = (yy.^2 + zz.^2 <= (d/2)^2) & (zz <= d/2 - h_plano);
dA = (d/800)^2;
zc = sum(zz(A))*dA/(sum(A(:))*dA);
Iz = sum((zz(A) - zc).^2)*dA; Iy = sum(yy(A).^2)*dA;
W_pl = min([Iz/(d/2 - h_plano - zc), Iz/(d/2 + zc), Iy/(d/2)]);
W = pi*d^3/32; Wx = W*ones(size(xs));
Wx(xs <= n.t_tuerca) = W_r;
Wx((xs >= x_cubo1(1) & xs <= x_cubo1(2)) | (xs >= x_cubo2(1) & xs <= x_cubo2(2))) = W_pl;
sg_max = 0; x_sg = NaN; Mx = 0; Wsel = W;
for dl = [-1 1]*delta_spec
  Rg = k2*(y_libre - dl);
  Mv = arrayfun(@(x) sum(Pq.*max(0, aq - x)) - Rg*(x_KFL2 - x), xs);
  [m, i] = max(abs(Mv)./Wx);
  if m > sg_max, sg_max = m; x_sg = xs(i); Mx = abs(Mv(i)); Wsel = Wx(i); end
end
fprintf('4. Máximo a lo largo del pasador (delta = +/-%.1f mm): x = %.1f mm, M = %.0f N·mm, W = %.1f mm^3, sigma = %.1f MPa -> %s\n', ...
        delta_spec, x_sg, Mx, Wsel, sg_max, ok(n.Sy_pasador/sg_max >= FS_min));
fprintf('   (planos fresados W = %.1f mm^3; sección roscada W = %.1f mm^3)\n\n', W_pl, W_r);

%% 6. KFL08
fprintf('5. KFL08 no accionada: %.1f N -> s0 = %.1f (C0 de Mädler 62660800)\n', R1, P.KFL.C0/R1);
% SUPOSICIÓN: la KFL08 de Naylamp tiene el mismo rodamiento que la Mädler 62660800 (Naylamp no publica C ni C0).

%% 7. Casquillo de los resortes: holgura con el resorte cargado (Shigley Ec. 10-53 y 10-55)
D_m = P.res.OD - P.res.d;                 % mm, diámetro medio libre
% Con la opción 1 el resorte trabaja enrollándose: el diámetro se reduce (Shigley p. 521), que es el caso de Ec. 10-53.
% SUPOSICIÓN: se usa la deflexión total (cuerpo + patas) como deflexión del cuerpo (conservador).
% Se suma la tolerancia de la posición libre (+15°, Lee Spring p. 286) como deflexión adicional en el peor caso.
th_c = (P.res.defl_bajo + P.res.tol_libre)/360;   % vueltas, posición baja
D_c = P.res.espiras*D_m/(P.res.espiras + th_c);       % Ec. 10-53
Delta = D_c - P.res.d - D_casq;           % Ec. 10-55
fprintf('6. Casquillo Ø%d: diámetro interior del resorte a %.0f° = %.2f mm; holgura diametral = %.2f mm -> %s\n', ...
        D_casq, P.res.defl_bajo + P.res.tol_libre, D_c - P.res.d, Delta, ok(Delta > 0));
fprintf('   Mandril máximo del catálogo = %.2f mm -> %s\n', P.res.mandril, ok(D_casq <= P.res.mandril));
V_casq = pi/4*(D_casq^2 - d_casq^2)*(gap - juego_casq);    % mm^3
fprintf('   Volumen = %.0f mm^3: aluminio %.0f g, acero %.0f g\n', V_casq, V_casq*2.70e-3, V_casq*7.85e-3);

%% 8. Material del casquillo
% Fuente: thyssenkrupp Materials Poland, "Engineering plastics" (tabla de propiedades): densidad,
% absorción de humedad a saturación, límite de fluencia, temperatura máxima de trabajo continuo y
% susceptibilidad a la abrasión (µm/km).
% Requerimientos:
%  R1 carga: presión de contacto en el agujero <= sigma_y/FS
%  R2 temperatura: ambiente de 10 a 45 °C (Tabla de requerimientos, req. 6)
%  SUPOSICIÓN: la pieza puede calentarse 25 °C sobre el ambiente al sol -> T_trabajo continuo >= 70 °C
%  R3 estabilidad: absorción de humedad a saturación <= 1 % (lluvias eventuales, req. 6); el crecimiento
%     del casquillo no debe cerrar el juego axial ni el juego del agujero
%  R4 masa mínima
nom  = {'PA6', 'PA6G', 'POM-C', 'PET', 'PE 1000 (UHMW)', 'PE 500'};
rho  = [1.14 1.15 1.41 1.39 0.94 0.98];      % g/cm^3
hum  = [9 6.5 0.8 0.6 0.01 0.01];            % %
sy   = [76 85 68 90 20 27];                  % MPa
Tmx  = [70 90 100 115 80 80];                % °C
abr  = [19 12 45 3 8 100];                   % µm/km
p_ag = 2*F_res/(d_casq*(gap - juego_casq));  % MPa, presión media en el agujero
FS_pl = 3;
% SUPOSICIÓN: factor de seguridad 3 para plásticos (fluencia lenta y dispersión de propiedades).
fprintf('\n7. Material del casquillo (presión en el agujero = %.3f MPa; volumen %.1f cm^3)\n', p_ag, V_casq/1000);
fprintf('%-16s %6s %7s %7s %6s %7s  %s\n', 'Material', 'masa g', 'sy/FS', 'T máx', 'hum %', 'abras.', 'R1-R3');
for k = 1:numel(nom)
  c = (sy(k)/FS_pl >= p_ag) && (Tmx(k) >= 70) && (hum(k) <= 1);
  fprintf('%-16s %6.1f %7.1f %7d %6.2f %7d  %s\n', nom{k}, rho(k)*V_casq/1000, sy(k)/FS_pl, Tmx(k), hum(k), abr(k), ok(c));
end

% Material adoptado (decisión del usuario): POM-C (acetal copolímero), color negro o estabilizado contra UV.
k_sel = 3;
fprintf('   Adoptado: %s, masa %.1f g, casquillo Ø%d x Ø%.1f x %.1f mm\n', nom{k_sel}, rho(k_sel)*V_casq/1000, D_casq, d_casq, gap - juego_casq);
