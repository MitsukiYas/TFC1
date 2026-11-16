%% MEMORIA 09 - Soportes de la base: placas laterales, escuadras, postes y fijación del reductor
% Origen en el pivote actuado; x hacia adelante, z hacia arriba, y lateral (+ lado accionado).
% Criterio de las uniones con perfil V-slot: ninguna carga se transmite por fricción de la tuerca en T
% a lo largo de la ranura. Las tuercas en T trabajan solo a extracción (dato Ooznest: 684 N, M5, serie 20).
%   - x: escuadra de tope (Bracket L universal doble, 20 x 20 x 38 mm, t = 3 mm, 6061-T6) en la cara
%        delantera del poste: la fuerza en x extrae o comprime su tuerca en T.
%   - y: tornillos placa-poste (extracción) o contacto placa-poste.
%   - z: placas apoyadas en el plano del chasis (contacto, hacia abajo) y tornillos placa-poste (corte, hacia
%        arriba); placa derecha atornillada además al reductor. Sin travesaño inferior (STEP del usuario, 2026-11-13).
%   - Reductor: 4 x M5 A2-70 + tuerca en T en los largueros (solo z y momento alrededor de y); su fuerza
%        en x pasa a la placa derecha (centrador Ø60 H8 + 4 x M6) y de ahí a la escuadra derecha.
% Fuentes: ADM 2005 (Tabla 3.3-1M: 6061-T6, 6063-T5; Tabla 3.4-1; 3.4.5; 5.1.1); ISO 3506-1 (A2-70);
% Naylamp (perfil 2020: I = 6988 mm^4; escuadra 6061-T6); Ooznest (tuerca en T); Shigley Ec. 5-21, Tablas 7-9 y A-11;
% catálogo DIN 471; Lee Spring pp. 286 y 298.
clear; clc;
run('parametros_elevacion.m');
load('cargas_elevacion.mat');
M_s = @(th) P.res.n*(P.res.M_alto + P.res.k*deg2rad(th_max - th));   % N·m (memoria 05)
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 09: SOPORTES DE LA BASE ===\n\n');

%% 1. Datos
Al61 = P.Al6061;                                   % placas y escuadras
Al63 = struct('Ftu', 150, 'Fty', 110, 'Fsu', 90);  % ADM Tabla 3.3-1M, 6063-T5 extruido (t <= 12.5 mm)
W2020 = 6988/10;                                   % mm^3, I/c del perfil 2020 (Naylamp)
% SUPOSICIÓN: la sección del 2020 se trata como compacta (sin pandeo local de los labios de la ranura).
% SUPOSICIÓN: la capacidad de extracción de 684 N de Ooznest se toma como última y se divide por nu = 1.95.
F_T_adm = P.tuercaT.F_extr/P.nu;
d5 = 5; As5 = pi/4*(d5 - 0.9382*0.8)^2;
V5_adm = P.f_ssy*P.A270.Rp02/P.ny*As5;              % N, corte admisible de un M5 A2-70
z_base = -49.8;                                    % mm, cara inferior del reductor (medición CAD)
x_post = -35;                                      % mm, eje de los postes
% Escuadras
b_esc = 38; t_esc = 3; e_esc = 10;
% SUPOSICIÓN: los agujeros de la escuadra están a 10 mm de la arista interior (mitad del ala de 20 mm)
% y la flexión del ala se toma con ese brazo de palanca, sobre todo su ancho de 38 mm.
n_esc = 2;                                         % tornillos por ala (escuadra "doble")
z_escL = 79; z_escR = 99;                          % mm, centro de las escuadras izquierda y derecha
% Reductor sobre los largueros
xb = 35; yb = 30;                                  % mm, agujeros de la cara inferior a +/- 35 (x) y +/- 30 (y)
W_mr = (2.14 + 2.5)*g;                             % N, reductor + motor (CAD)
n_pl = [4 3];                                      % tornillos placa-poste: izquierda, derecha
fprintf('1. Tuerca en T: %.0f N / nu = %.0f N admisibles. M5 A2-70 al corte: %.0f N\n\n', P.tuercaT.F_extr, F_T_adm, V5_adm);

%% 2. Fuerzas de los pasadores sobre las placas y el reductor (envolvente, por lado)
% D = pivote inferior, B = pivote superior (memoria 02). El lado derecho del pivote inferior
% llega al reductor por el eje de salida (memoria 07).
% SUPOSICIÓN: el diferencial vertical por viento lateral (dV_base) es la fuerza total de cada lado,
% repartida entre sus dos pivotes; se suma una sola vez a la fuerza vertical del lado.
% SUPOSICIÓN: toda la fuerza lateral del viento sobre el mecanismo llega a un solo lado (conservador).
F_lat = 5.96 + 3.60 + 4*Pv*(P.tubo_h/1000)*Lt;     % N
Lm = P.L/1000; Am = P.A/1000;
% Refinamiento (2026-11-13): el pasador del pivote actuado es un voladizo desde la placa libre con el extremo
% guiado por la KFL08 del brazo accionado (memoria 08). Las cargas que recibe el pasador (reacción del brazo libre
% en su KFL08 y resultante de cada resorte sobre el casquillo) se reparten entre la placa libre y la guía según la
% viga empotrada-apoyada: fracción en la guía f(a) = a^2(3L - a)/(2L^3) (L = x_KFL2). Lo que toma la guía pasa al
% brazo accionado y de ahí al eje del reductor. Los resortes se cierran así dentro de la base: la pata móvil carga
% el marco (incluido en el equilibrio del paralelogramo), la espira carga el pasador y la pata fija carga la varilla
% de anclaje, que reparte su fuerza entre las dos placas.
% SUPOSICIÓN: reductor alineado con el pasador sin carga (delta = 0) y extremo guiado sin juego.
nd = P.nodo; gapn = P.U.w - 2*(nd.t_arandela + nd.t_tuerca + P.tubo_b + nd.t_KFL);
x_K1 = nd.t_tuerca + nd.t_arandela + P.tubo_b + nd.t_KFL/2;
x_g1 = nd.t_tuerca + nd.t_arandela + P.tubo_b + nd.t_KFL; x_K2 = x_g1 + gapn + nd.t_KFL/2;
x_rs = x_g1 + gapn/2 + [-1 1]*(P.res.L_cuerpo + 2*nd.holg_res)/2;
fK = @(a) a.^2.*(3*x_K2 - a)/(2*x_K2^3);
f_D = fK(x_K1); f_C = fK(x_rs);
% Reparto de la varilla de anclaje entre placas (simplemente apoyada en los planos medios)
Lr_a = diff(P.anc.y_placa); aF_a = [-1 1]*P.res.y_pata_fija - P.anc.y_placa(1);
shR = aF_a/Lr_a; shL = 1 - shR;                       % fracción de cada pata que va a la placa motor / libre
fprintf('   Pasador: fracción a la guía (KFL08 accionada): brazo libre %.3f, resortes %.3f / %.3f\n', f_D, f_C);
FxL = 0; FzL_dn = 0; FzL_up = 0; FxR = 0; FzR = 0; FxG = 0; FzG_up = 0; MyG = 0; FxG0 = 0;
for th = th_v
  Mres = P.res.M_alto + P.res.k*deg2rad(th_max - th);
  for dM = [-1 0 1]*P.res.k*deg2rad(P.res.tol_libre)
    Mr = Mres + dM;
    Cm = Mr/(P.res.l_m/1000)*[sind(th) -cosd(th)];   % N, varilla transversal sobre cada pata móvil
    Cf = -Mr/(P.res.l_f/1000)*P.res.e_psi;           % N, varilla de anclaje sobre cada pata fija
    C  = Cm + Cf;                                    % N, de cada espira sobre el pasador
    An = -Cf;                                        % N, de cada pata fija sobre la varilla de anclaje
    for phi = phi_v
      for sw = [-1 1]
        x = resolver_paralelogramo(th, phi, sw, Lm, Am, m_c, z_cmc/1000, m_brazo, g, F_long, z_cp_long/1000, ...
              F_U_x, z_U_x/1000, Pv, P.tubo_b/1000, P.tubo_h/1000, Lt, P.res.n*Mr, P.res.r_pata/1000);
        % Fuerzas de los brazos SOBRE los pasadores = -(fuerzas sobre los brazos), por lado
        B = -[x(1) x(2)]/2; D = -[x(5) x(6)]/2;
        Gd = D + f_D*D + f_C(1)*C + f_C(2)*C;                     % sobre el eje del reductor
        PL = B + (1 - f_D)*D + (1 - f_C(1))*C + (1 - f_C(2))*C + An*sum(shL);   % placa libre
        PR = B + An*sum(shR);                                     % placa motor (sin el reductor)
        FxL = max(FxL, abs(PL(1)));
        FzL_dn = max(FzL_dn, -PL(2) + dV_base);
        FzL_up = max(FzL_up,  PL(2) + dV_base);
        FxR = max(FxR, abs(PR(1) + Gd(1)));                       % escuadra derecha: placa + x del reductor
        FzR = max(FzR, abs(PR(2)) + dV_base);
        FxG = max(FxG, abs(Gd(1))); FxG0 = max(FxG0, abs(D(1)));
        FzG_up = max(FzG_up, Gd(2) + dV_base);
        MyG = max(MyG, abs(x(9)) + abs(Gd(1))*abs(z_base)/1000);
      end
    end
  end
end
T_op = 1.30*Tmax; T_red = 38;
fprintf('2. Fuerzas por lado (envolvente)\n');
fprintf('   Placa izquierda: x = %.1f N, z abajo = %.1f N, z arriba = %.1f N\n', FxL, FzL_dn, FzL_up);
fprintf('   Escuadra derecha (pivote sup. + x del reductor): x = %.1f N\n', FxR);
fprintf('   Reductor: x = %.1f N (a la placa derecha; %.1f N sin el reparto del pasador), z que levanta = %.1f N\n', FxG, FxG0, FzG_up);
fprintf('   Lateral total = %.1f N\n\n', F_lat);

%% 3. Escuadras de tope (x)
fprintf('3. Escuadras de tope (2 x M5 por ala, 6061-T6, t = %d mm)\n', t_esc);
for k = 1:2
  if k == 1, F = FxL; nom = 'izquierda'; else, F = FxR; nom = 'derecha'; end
  sig = 6*F*e_esc/(b_esc*t_esc^2);
  adm = Al61.Fty/P.ny;
  fprintf('   %-9s F = %6.1f N: tuerca T %5.1f N (FS = %.1f), corte M5 %5.1f N (FS = %.1f), flexión ala %5.1f MPa (adm. %.1f) -> %s\n', ...
          nom, F, F/n_esc, F_T_adm/(F/n_esc), F/n_esc, V5_adm/(F/n_esc), sig, adm, ok(F/n_esc <= F_T_adm && sig <= adm));
end
fprintf('\n');

%% 4. Tornillos placa-poste (y) y apoyos en z
% Una fuerza lateral que separa la placa del poste la hace bascular sobre la arista delantera del poste
% (x = -25): los tornillos (x = -35) quedan a 10 mm de esa arista y la fuerza actúa en el pivote (x = 0).
F_bolt_y = F_lat*25/10;
fprintf('4. Tornillos placa-poste: extracción total %.1f N\n', F_bolt_y);
for k = 1:2
  fprintf('   Placa %s (%d tornillos): %.1f N por tuerca T -> FS = %.1f %s\n', subsref({'izquierda','derecha'}, substruct('{}', {k})), n_pl(k), ...
          F_bolt_y/n_pl(k), F_T_adm/(F_bolt_y/n_pl(k)), ok(F_bolt_y/n_pl(k) <= F_T_adm));
end
% Diseño vigente (STEP del usuario): las placas llegan al plano del chasis y no hay travesaño inferior.
% Hacia abajo, la placa libre apoya su canto (5 x 90 mm, x = -45 a 45) en el chasis; hacia arriba, su canto
% superior (z = 180) apoya contra la cara inferior del travesaño superior (x = -45 a -25), que pasa la fuerza a los
% postes por sus tornillos de testa. Los tornillos placa-poste no se cuentan en z: sus tuercas en T solo
% resistirían por fricción a lo largo de la ranura vertical (criterio de la memoria).
% SUPOSICIÓN: el canto superior de la placa libre queda en contacto con el travesaño (en el STEP hay 0.2 mm de luz).
% SUPOSICIÓN: el chasis bajo las placas es plano y continuo (pendiente: fijación al chasis).
A_c = 5*90;
fprintf('   Apoyo del canto de la placa libre en el chasis (abajo): %.2f MPa\n', FzL_dn/A_c);
fprintf('   Apoyo del canto superior de la placa libre en el travesaño (arriba): %.1f N sobre 5 x 20 mm = %.2f MPa\n', FzL_up, FzL_up/(5*20));
% Travesaño superior: une los postes con tornillos M5 a la rosca del agujero central (unión de testa)
fprintf('   Travesaño superior a los postes: corte por tornillo %.1f N (FS = %.1f)\n\n', FzL_up/2, V5_adm/(FzL_up/2));
% SUPOSICIÓN: el travesaño superior se une a los postes con un tornillo M5 por extremo, roscado en el agujero
% central del perfil (unión de testa), y la fuerza vertical lo carga solo al corte.

%% 5. Aplastamiento de los pasadores y tornillos en las placas (6061-T6, t = 5)
t_pl = 5;
Rmax = max([R_base, R_base_sup]);
cap_pas = 2*Al61.Ftu/P.nu*P.nodo.d_pasador*t_pl;
cap_M5  = 2*Al61.Ftu/P.nu*d5*t_pl;
fprintf('5. Placas 6061-T6 t = %d mm\n', t_pl);
fprintf('   Pasador Ø8 (%.1f N): capacidad %.0f N -> FS = %.1f %s\n', Rmax, cap_pas, cap_pas/Rmax, ok(cap_pas >= Rmax));
fprintf('   Tornillo de la escuadra (%.1f N): capacidad %.0f N -> FS = %.1f %s\n', max(FxL, FxR)/n_esc, cap_M5, cap_M5/(max(FxL, FxR)/n_esc), ok(cap_M5 >= max(FxL, FxR)/n_esc));
% Placa derecha - reductor: 4 x M6 en Ø75 (B derecho + x del reductor)
d6 = 6; As6 = pi/4*(d6 - 0.9382*1.0)^2; V6_adm = P.f_ssy*P.A270.Rp02/P.ny*As6;
F6 = hypot(FxR, FzR)/4;
fprintf('   M6 placa-reductor: %.1f N por tornillo (corte adm. %.0f N) -> FS = %.1f %s\n\n', F6, V6_adm, V6_adm/F6, ok(V6_adm >= F6));

%% 6. Reductor sobre los largueros (4 x M5 A2-70 + tuerca en T)
% Momento alrededor de y en la cara inferior: par de reacción + fuerza x del eje a 49.8 mm de altura.
% SUPOSICIÓN: el peso del motorreductor no se descuenta (conservador) y la placa derecha no toma momento.
fprintf('6. Fijación del reductor a los largueros\n');
for T = [T_op T_red]
  My = T + FxG*abs(z_base)/1000;
  F_t = My/(2*2*xb/1000) + FzG_up/4;         % N por tornillo (fila traccionada)
  fprintf('   T = %4.1f N·m: M_y = %.1f N·m -> %.1f N por tuerca T (adm. %.0f) -> FS = %.2f %s\n', T, My, F_t, F_T_adm, F_T_adm/F_t, ok(F_t <= F_T_adm));
end
fprintf('   Peso del motorreductor = %.1f N (compresión sobre los largueros)\n\n', W_mr);

%% 7. Postes con el travesaño superior
% El travesaño superior une los postes en el plano y-z: reparten la carga lateral (y) entre los dos postes.
% Para las cargas en x (plano del mecanismo) los dos postes se flectan igual y los travesaños no ayudan:
% cada poste trabaja en voladizo desde el plano base.
% SUPOSICIÓN: uniones travesaño-poste articuladas (un tornillo M5 de testa no transmite momento) y postes
% empotrados en el chasis; la carga lateral se reparte por igual entre los dos postes.
fprintf('7. Postes 2020 con el travesaño superior (6063-T5, adm. Fty/ny = %.1f MPa)\n', Al63.Fty/P.ny);
for k = 1:2
  if k == 1, F = FxL; z = z_escL; else, F = FxR; z = z_escR; end
  M = F*(z - z_base) + F_lat/2*(150 - z_base);   % N·mm; lateral repartida entre los dos postes
  % SUPOSICIÓN: la flexión en x y en y se suman directamente (sección simétrica, I_x = I_y).
  fprintf('   Poste %-9s: M = %.0f N·mm, sigma = %.1f MPa -> %s\n', subsref({'izquierdo','derecho'}, substruct('{}', {k})), M, M/W2020, ok(M/W2020 <= Al63.Fty/P.ny));
end
fprintf('\n');

%% 8. Varilla de anclaje de las patas fijas (opción a: entre las placas base, placa libre prolongada)
% Varilla Ø8 AISI 4140 con extremos Ø6 h6 en agujeros H7 de las dos placas 6061-T6 (t = 5); los escalones
% Ø8/Ø6 apoyan en las caras interiores y fijan la varilla axialmente (sin anillos).
% La placa libre se prolonga hasta x = 45 con el mismo contorno que la placa motor (decisión del usuario).
% Fuentes: ADM 2005 sec. 5.1.1 (distancia al borde >= 1.5D; < 2D reduce el aplastamiento) y 5.2.6 (2.5D entre
% pernos); Shigley 11.ª ed. Tabla 7-9 (H7/h6) y Tabla A-11; Lee Spring p. 298.
% SUPOSICIÓN: se aplica la sec. 5.1.1 del ADM (escrita para pernos y remaches) a la varilla como pasador, y el
% agujero Ø61 de la placa motor (aloja con holgura el resalte Ø60 del reductor) se trata como un borde de la placa.
a = P.anc; c = a.c; D6 = a.d_ext;
Mb = P.res.M_alto + P.res.k*deg2rad(P.res.barrido);        % N·m, por resorte en la posición baja
Mb_tol = Mb + P.res.k*deg2rad(P.res.tol_libre);             % N·m, con la tolerancia de posición libre
Ff = Mb_tol/(P.res.l_f/1000);                               % N, por pata fija (peor caso)
u_F = P.res.e_psi;                                           % dirección de la fuerza de la varilla sobre la placa
fprintf('8. Varilla de anclaje: centro (x, z) = (%.2f, %.2f) mm; pata fija a %.0f mm de la tangencia (psi = %.2f°)\n', c, P.res.l_f, P.res.psi);
fprintf('   Par por resorte en la posición baja: %.3f N·m (+ tolerancia de posición libre: %.3f N·m) -> F = %.1f N por pata\n', Mb, Mb_tol, Ff);
fprintf('   Límite de Lee Spring: %.3f N·m -> %s\n', P.res.M_nom, ok(Mb_tol <= P.res.M_nom));
% a) Distancias al borde en las placas (mm desde el centro del agujero)
e_inf = c(2) - z_base;                         % borde inferior (plano del chasis)
e_inf_F = e_inf/abs(u_F(2));                   % medida en la dirección de la fuerza
e_del = 45 - c(1);                             % borde delantero de las placas (x = 45)
e_60  = norm(c) - 30.5;                        % borde del agujero Ø61 de la placa motor (resalte Ø60 del reductor con holgura)
s_66  = min(vecnorm([26.5 -26.5; -26.5 -26.5] - c, 2, 2));   % a los agujeros Ø6.6 del reductor (centro a centro)
fprintf('   a) Bordes (D = %d): inferior %.2f (en la dirección de la fuerza %.2f), delantero %.2f, Ø61 %.2f; a Ø6.6: %.2f entre centros\n', ...
        D6, e_inf, e_inf_F, e_del, e_60, s_66);
fprintf('      Mínimo 1.5D = %.1f -> %s; 2.5D entre agujeros = %.1f -> %s; aplastamiento sin reducción (borde en la dirección de la fuerza >= 2D) -> %s\n', ...
        1.5*D6, ok(min([e_inf e_del e_60]) >= 1.5*D6), 2.5*D6, ok(s_66 >= 2.5*D6), ok(e_inf_F >= 2*D6));
% b) Viga simplemente apoyada en los planos medios de las placas, con las dos patas fijas
ys = a.y_placa; yF = [-1 1]*P.res.y_pata_fija; Lr = diff(ys);
aF = yF - ys(1);                               % posiciones de las cargas desde el apoyo libre
RB = Ff*sum(aF)/Lr; RA = 2*Ff - RB;            % N, reacciones (A = placa libre, B = placa motor)
Mx = @(x) RA*x - Ff*max(0, x - aF(1)) - Ff*max(0, x - aF(2));
xs = linspace(0, Lr, 2001); Mmax = max(arrayfun(Mx, xs));
W8 = pi*a.d^3/32; s8 = Mmax/W8; adm8 = P.nodo.Sy_pasador/1.5;   % criterio del texto para elementos de acero: FS >= 1.5
fprintf('   b) Viga de %.1f mm entre planos medios: R_libre = %.1f N, R_motor = %.1f N, M máx = %.0f N·mm\n', Lr, RA, RB, Mmax);
fprintf('      sigma = %.1f MPa (adm. Sy/1.5 = %.0f MPa, criterio FS >= 1.5) -> FS = %.1f %s\n', s8, adm8, P.nodo.Sy_pasador/s8, ok(s8 <= adm8));
% Flecha en los puntos de carga (superposición, viga simplemente apoyada)
EI = P.E_acero*pi*a.d^4/64;
fl = @(x, ac) (x <= ac).*(Ff*(Lr - ac).*x.*(Lr^2 - (Lr - ac)^2 - x.^2)/(6*EI*Lr)) + ...
              (x >  ac).*(Ff*ac.*(Lr - x).*(Lr^2 - ac^2 - (Lr - x).^2)/(6*EI*Lr));
yfl = fl(aF, aF(1)) + fl(aF, aF(2));
dM = P.res.k*max(yfl)/P.res.l_f;               % N·m, pérdida de par por la flecha (giro de la pata = y/l_f)
fprintf('      Flecha en las patas: %.3f / %.3f mm -> giro %.2f°, variación de par %.3f N·m (%.1f %%)\n', yfl, rad2deg(max(yfl)/P.res.l_f), dM, 100*dM/Mb);
% c) Extremos Ø6: corte, flexión en el apoyo y aplastamiento en las placas
% Sin anillos: los escalones Ø8/Ø6 fijan la varilla entre las caras interiores de las placas (juego total j8).
% El extremo mide t - j8 para no salir nunca de la cara exterior (lado motor: carcasa del reductor).
j8 = 0.5;                                     % mm, juego total de los escalones entre las caras interiores
L_ext = a.t_placa - j8;                       % mm, largo del extremo Ø6
L_ap  = L_ext - j8;                           % mm, apoyo mínimo en la placa (varilla corrida al lado opuesto)
R6 = max(RA, RB);
tau6 = 4*R6/(pi*D6^2); M6 = R6*(j8 + L_ap/2); s6 = M6/(pi*D6^3/32);   % brazo al centro del apoyo desde el escalón
cap6 = 2*P.Al6061.Ftu/P.nu*D6*L_ap;           % ADM 3.4.5 (mismo criterio que la sección 5), sobre el apoyo mínimo
fprintf('   c) Extremo Ø6 (%.1f N): corte %.1f MPa, flexión %.1f MPa (adm. %.0f) -> %s\n', R6, tau6, s6, adm8, ok(max(s6, tau6/P.f_ssy) <= adm8));
fprintf('      Aplastamiento en la placa (apoyo mínimo %.1f mm): capacidad %.0f N -> FS = %.0f %s\n', L_ap, cap6, cap6/R6, ok(cap6 >= R6));
% d) Ajustes y largos (Shigley Tabla 7-9: H7/h6, holgura de ubicación; Tabla A-11)
it = P.IT;
L8 = diff(a.y_placa) - a.t_placa - j8;        % mm, tramo Ø8 entre caras interiores
fprintf('   d) Extremos Ø6 h6 (0/-%.3f) en agujeros Ø6 H7 (+%.3f/0); sin anillos: los escalones fijan la varilla\n', it.IT6(1), it.IT7(1));
fprintf('      Tramo Ø8 = %.1f mm (juego %.1f); extremos Ø6 = %.1f mm; largo total = %.1f mm\n', L8, j8, L_ext, L8 + 2*L_ext);
fprintf('      El extremo queda entre %.1f y %.1f mm por dentro de la cara exterior de cada placa\n', a.t_placa - L_ext, a.t_placa - L_ext + j8);
fprintf('      Montaje: la varilla se coloca antes de cerrar la segunda placa (el tramo Ø8 no pasa por los agujeros Ø6).\n');
% La ranura del anillo queda fuera de las placas, donde el momento es nulo: no se verifica concentración de esfuerzos.
fprintf('   Agujero en ambas placas: (x, z) = (%.2f, %.2f) mm desde el pivote -> CAD (%.2f, %.2f)\n\n', c, c(1) + 108.85, c(2) - 22.75);

%% 9. Varilla transversal de las patas móviles (Ø8 AISI 4140 sobre los dos brazos inferiores)
% Viga simplemente apoyada en los ejes de los tubos; patas móviles cerca del centro.
t = P.trv; Fm = Mb_tol/(P.res.l_m/1000);
aM = [-1 1]*P.res.y_pata_movil - t.y_apoyo(1); Lt2 = diff(t.y_apoyo);
RBm = Fm*sum(aM)/Lt2; RAm = 2*Fm - RBm;
Mxm = @(x) RAm*x - Fm*max(0, x - aM(1)) - Fm*max(0, x - aM(2));
Mm = max(arrayfun(Mxm, linspace(0, Lt2, 2001))); sm = Mm/W8;
EIt = P.E_acero*pi*t.d^4/64;
flm = @(x, ac) (x <= ac).*(Fm*(Lt2 - ac).*x.*(Lt2^2 - (Lt2 - ac)^2 - x.^2)/(6*EIt*Lt2)) + ...
               (x >  ac).*(Fm*ac.*(Lt2 - x).*(Lt2^2 - ac^2 - (Lt2 - x).^2)/(6*EIt*Lt2));
ym = flm(aM, aM(1)) + flm(aM, aM(2));
fprintf('9. Varilla transversal: centro (u, v) = (%.1f, %.2f) mm; %.1f N por pata; viga de %.1f mm\n', t.uv, Fm, Lt2);
fprintf('   M máx = %.0f N·mm, sigma = %.1f MPa -> FS = %.1f %s; flecha %.3f mm (giro de la pata %.2f°)\n', Mm, sm, P.nodo.Sy_pasador/sm, ok(sm <= adm8), max(ym), rad2deg(max(ym)/P.res.l_m));
fprintf('   Reacción en cada apoyo (agujero ciego): %.1f N\n', max(RAm, RBm));
L8t = 2*P.sopL.y_ala(1) - 0.5; Lext = P.sopL.prof - 0.5;
fprintf('   Varilla: tramo Ø8 = %.1f mm, extremos Ø6 h6 x %.1f mm (agujeros ciegos Ø6 H7 x %.0f); largo total %.1f mm\n', L8t, Lext, P.sopL.prof, L8t + 2*Lext);
fprintf('   Montaje: una pieza en L, la varilla y luego la segunda pieza; los escalones fijan la varilla axialmente.\n\n');

%% 10. Pieza en L de la varilla transversal (6061-T6, una por brazo)
% Fuentes: ADM 2005 sec. 5.1.1 y 3.4.5 (mismo criterio que la sección 5); unión de las cartelas (memoria 04).
L_ = P.sopL; F10 = max(RAm, RBm);
D6 = 6; e_up = L_.v_sup - t.uv(2); e_u = min(t.uv(1) - L_.u_ala(1), L_.u_ala(2) - t.uv(1));
fac = min(1, e_up/(2*D6));                         % reducción del aplastamiento (borde en la dirección de la fuerza)
cap10 = fac*2*P.Al6061.Ftu/P.nu*D6*L_.prof;
fprintf('10. Pieza en L: agujero ciego Ø6 a (u, v) = (%.0f, %.2f); bordes: superior %.1f, en u %.1f (1.5D = %.0f) -> %s\n', ...
        t.uv, e_up, e_u, 1.5*D6, ok(min(e_up, e_u) >= 1.5*D6));
fprintf('    Aplastamiento (factor %.2f por borde < 2D): capacidad %.0f N para %.1f N -> FS = %.0f %s\n', fac, cap10, F10, cap10/F10, ok(cap10 >= F10));
% Brazo superior a theta máx.: distancia entre ejes de brazos = A*cos(theta_máx)
v_sup_brazo = P.A*cosd(P.th_max) - P.tubo_h/2;
fprintf('    Altura sobre la cara del tubo: %.2f mm; holgura al brazo superior en theta máx. = %.2f mm -> %s\n', ...
        L_.v_sup - P.tubo_h/2, v_sup_brazo - L_.v_sup, ok(v_sup_brazo - L_.v_sup > 0));
% Perno M5 vertical: la fuerza hacia arriba en el ala (|y| = 68.5) hace bascular la pieza sobre el canto exterior del tubo
y_F = L_.y_ala(1) + L_.prof/2; y_b = 87.2; y_ext = 99.9;
F_b = F10*(y_ext - y_F)/(y_ext - y_b);
Fi5 = P.M5.frac_precarga*P.M5.As*P.A270.Rp02;
fprintf('    Perno M5 A2-70 en u = %.1f: tracción por palanca %.0f N < precarga %.0f N -> %s\n', L_.u_perno, F_b, Fi5, ok(F_b < Fi5));
fprintf('    Bordes del perno en la pieza: %.1f / %.1f mm (1.5D = 7.5) -> %s\n', L_.u_perno - L_.u(1), L_.u(2) - L_.u_perno, ...
        ok(min(L_.u_perno - L_.u(1), L_.u(2) - L_.u_perno) >= 7.5));
% Flexión del ala lateral en la cara interior del tubo (sección u = 19 a 34, v = 15.875 a v_sup)
b10 = diff(L_.u); h10 = L_.v_sup - P.tubo_h/2; M10 = F10*(74.5 - y_F);
fprintf('    Flexión en la raíz del ala: %.2f MPa (adm. %.0f) -> %s\n', M10/(b10*h10^2/6), P.Al6061.Fty/P.ny, ok(M10/(b10*h10^2/6) <= P.Al6061.Fty/P.ny));
% SUPOSICIÓN: cabeza del tornillo M5 de 5 mm de alto (DIN 912), alojada en un avellanado de 5.5 mm para no
% sobresalir de v_sup; verificar con la pieza comprada.
fprintf('    Avellanado para la cabeza: 5.5 mm; agarre del perno = %.1f mm de pieza + %.2f de tubo\n', h10 - 5.5, P.tubo_h);
