%% MEMORIA 11 - Brazos del paralelogramo: flexión, compresión y pandeo (tubo 6061-T6 31.75 x 25.4 x 2)
% Cada brazo es un tubo rectangular de L = 600 mm entre pivotes. Se verifica con la envolvente de theta, pendiente y
% viento longitudinal (los mismos casos de la memoria 02) y con la sobrecarga del reductor (38 N·m).
% Fuentes: ADM 2005, Parte I-A: Tabla 3.3-4 (constantes de pandeo, temple -T6), 3.4.1, 3.4.7 (columnas),
% 3.4.9 (elementos planos de columnas), 3.4.14 (vigas tubulares), 3.4.16 (alas comprimidas), 3.4.18 (almas en
% flexión), 3.4.20 (corte) y 4.1.1 / 4.1.2 (carga axial combinada con flexión); Tabla 3.3-1M (6061-T6).
% Requiere cargas_elevacion.mat (memorias 02 y 05).
clear; clc;
run('parametros_elevacion.m');
load('cargas_elevacion.mat');
msg = {'NO CUMPLE','CUMPLE'}; ok = @(c) msg{double(logical(c)) + 1};
fprintf('=== MEMORIA 11: BRAZOS ===\n\n');

%% 1. Sección y esfuerzos admisibles (ADM 2005)
Al = P.Al6061; E = Al.E; Fcy = Al.Fcy; Fty = Al.Fty; nu = P.nu; ny = P.ny;
h = P.tubo_h; b = P.tubo_b; t = P.tubo_t;            % h en el plano del mecanismo
A  = b*h - (b - 2*t)*(h - 2*t);
Ix = (b*h^3 - (b - 2*t)*(h - 2*t)^3)/12;             % flexión en el plano del mecanismo
Iy = (h*b^3 - (h - 2*t)*(b - 2*t)^3)/12;             % flexión fuera del plano
Sx = Ix/(h/2); rx = sqrt(Ix/A); ry = sqrt(Iy/A);
J  = 2*t*(b - t)^2*(h - t)^2/((b - t) + (h - t));    % tubo de pared delgada
% SUPOSICIÓN: anchos planos tomados como el lado exterior menos 2t (sin descontar el radio interior de las esquinas),
% lo que da b/t mayores que los reales (conservador).
bt_ala = (b - 2*t)/t;  ht_alma = (h - 2*t)/t;        % flexión en el plano: alas = lados de 25.4, almas = lados de 31.75
bt_max = max(bt_ala, ht_alma);
% Constantes de pandeo, Tabla 3.3-4 (MPa)
Bc = Fcy*(1 + sqrt(Fcy/15510)); Dc = Bc/10*sqrt(Bc/E); Cc = 0.41*Bc/Dc;
Bp = Fcy*(1 + Fcy^(1/3)/21.7);  Dp = Bp/10*sqrt(Bp/E); k1c = 0.35; k2c = 2.27;
Bbr = 1.3*Fcy*(1 + Fcy^(1/3)/13.3); Dbr = Bbr/20*sqrt(6*Bbr/E); k1b = 0.50; k2b = 2.04;
% a) Columna (3.4.7) con k = 1 en los dos planos
% SUPOSICIÓN: k = 1 en el plano y fuera de él (pivotes articulados; la KFL08 de una hilera no se cuenta como empotramiento).
Lc = P.L; kLr = max(Lc/rx, Lc/ry);
S1c = (Bc - nu*Fcy/ny)/Dc; S2c = Cc;
if kLr <= S1c, Fcol = Fcy/ny; elseif kLr < S2c, Fcol = (Bc - Dc*kLr)/nu; else, Fcol = pi^2*E/(nu*kLr^2); end
% b) Elementos planos de columnas (3.4.9), pared más esbelta
S1p = (Bp - nu/ny*Fcy)/(1.6*Dp); S2p = k1c*Bp/(1.6*Dp);
if bt_max <= S1p, Floc = Fcy/ny; elseif bt_max < S2p, Floc = (Bp - 1.6*Dp*bt_max)/nu; else, Floc = k2c*sqrt(Bp*E)/(nu*1.6*bt_max); end
Fa = min(Fcol, Floc); Fao = Floc;
% SUPOSICIÓN: Fao (columna corta, ADM 4.7.2) se toma igual al admisible del elemento más esbelto (3.4.9), sin el promedio ponderado.
% c) Viga: ala comprimida (3.4.16), almas en flexión (3.4.18, m = 0.65 para flexión simétrica) y pandeo lateral (3.4.14)
S1f = (Bp - Fcy)/(1.6*Dp); S2f = k1c*Bp/(1.6*Dp);
if bt_ala <= S1f, Ff = Fcy/ny; elseif bt_ala < S2f, Ff = (Bp - 1.6*Dp*bt_ala)/ny; else, Ff = k2c*sqrt(Bp*E)/(ny*1.6*bt_ala); end
m_w = 1.15 + (-1)/2;
S1w = (Bbr - 1.3*Fcy)/(m_w*Dbr); S2w = k1b*Bbr/(m_w*Dbr);
if ht_alma <= S1w, Fw = 1.3*Fcy/ny; elseif ht_alma < S2w, Fw = (Bbr - m_w*Dbr*ht_alma)/ny; else, Fw = k2b*sqrt(Bbr*E)/(ny*m_w*ht_alma); end
% SUPOSICIÓN: Cb = 1 y Lb = L (sin arriostramiento lateral intermedio) en 3.4.14.
Lb = P.L; lam14 = Lb*Sx/(1*sqrt(Iy*J/2));
S1t = ((Bc - Fcy)/(1.6*Dc))^2; S2t = (Cc/1.6)^2;
if lam14 <= S1t, Flt = Fcy/ny; elseif lam14 < S2t, Flt = (Bc - 1.6*Dc*sqrt(lam14))/ny; else, Flt = pi^2*E/(2.56*ny*lam14); end
Fb = min([Ff Fw Flt]); Ft = Fty/ny;
fprintf('1. Tubo %.2f x %.2f x %.1f: A = %.1f mm^2, Ix = %.0f mm^4, Iy = %.0f mm^4, Sx = %.0f mm^3, J = %.0f mm^4\n', h, b, t, A, Ix, Iy, Sx, J);
fprintf('   Columna (3.4.7): kL/r = %.1f (S1 = %.1f, S2 = %.1f) -> %.1f MPa; paredes (3.4.9): b/t = %.2f (S1 = %.2f) -> %.1f MPa\n', kLr, S1c, S2c, Fcol, bt_max, S1p, Floc);
fprintf('   Viga: ala (3.4.16) b/t = %.2f -> %.1f MPa; alma (3.4.18) h/t = %.2f -> %.1f MPa; lateral (3.4.14) %.1f (S1 = %.1f) -> %.1f MPa\n', ...
        bt_ala, Ff, ht_alma, Fw, lam14, S1t, Flt);
fprintf('   Admisibles: Fa = %.1f, Fao = %.1f, Fb = %.1f, Ft = %.1f MPa\n\n', Fa, Fao, Fb, Ft);

%% 2. Esfuerzos internos a lo largo de cada brazo (por lado)
% Cargas por brazo: mitad de las fuerzas de pasador de su nivel (resolver_paralelogramo), su peso y el viento sobre
% él (repartidos a lo largo), la mitad de la fuerza de las patas móviles en u = l_m (solo brazos inferiores) y el par.
% El brazo accionado recibe el par T completo en su pivote y entrega T/2 al otro brazo inferior por el travesaño (u = 65).
% SUPOSICIÓN: reparto por mitades entre los dos lados (como en las memorias 02 y 09) y transferencia de T/2 por el travesaño.
Lm = P.L/1000; Am = P.A/1000; u = linspace(0, P.L, 601);
M_s = @(th) P.res.n*(P.res.M_alto + P.res.k*deg2rad(th_max - th));
cr = @(r, f) r(1)*f(2) - r(2)*f(1);
env = struct('sup', [0 0 0 0], 'acc', [0 0 0 0], 'lib', [0 0 0 0]);   % [N_comp, N_trac, M, interacción]
for th = th_v
  c = cosd(th); s = sind(th); eu = [c s]; ev = [-s c];
  for phi = phi_v
    gv = g*[sind(phi) -cosd(phi)];
    for sw = [-1 1]
     for dM = [-1 0 1]*P.res.n*P.res.k*deg2rad(P.res.tol_libre)   % tolerancia de posición libre (Lee p. 286)
      x = resolver_paralelogramo(th, phi, sw, Lm, Am, m_c, z_cmc/1000, m_brazo, g, F_long, z_cp_long/1000, ...
            F_U_x, z_U_x/1000, Pv, P.tubo_b/1000, P.tubo_h/1000, Lt, M_s(th) + dM, P.res.r_pata/1000);
      q = (m_brazo*gv + sw*Pv*(P.tubo_b/1000)*(Lt*s + (P.tubo_h/1000)*c)*[1 0])/P.L;   % N/mm, por brazo
      Fs = (M_s(th) + dM)/(P.res.r_pata/1000)*[-s c]/2;                                          % N, por brazo inferior
      for caso = {'sup', 'acc', 'lib'}
        cs = caso{1};
        if strcmp(cs, 'sup'), F0 = [x(1) x(2)]/2; else, F0 = [x(5) x(6)]/2; end
        uk = u(2:end-1)';                                % mm (columna)
        Xx = uk*eu(1); Xz = uk*eu(2);
        N = -(F0*eu' + (q*eu')*uk);                      % tracción +, N
        M = (-Xx*F0(2) + Xz*F0(1))/1000 + (-Xx.*uk*q(2) + Xz.*uk*q(1))/2000;   % N·m
        if ~strcmp(cs, 'sup')
          m2 = uk > P.res.l_m;
          M = M + m2.*(((P.res.l_m*eu(1) - Xx)*Fs(2) - (P.res.l_m*eu(2) - Xz)*Fs(1))/1000);
          N = N - m2*(Fs*eu');
          if strcmp(cs, 'acc'), M = M + x(9) - (uk > P.cart.u_trav)*x(9)/2;
          else,                 M = M + (uk > P.cart.u_trav)*x(9)/2; end
        end
        fa = max(0, -N)/A; fb = abs(M)*1000/Sx;
        Fe = pi^2*E/(nu*(P.L/rx)^2);
        Ic = max(fa/Fa + fb./(Fb*(1 - fa/Fe)), fa/Fao + fb/Fb);   % Cm = 1 (SUPOSICIÓN: conservador)
        It = max(0, N)/A/Ft + fb/Fb;
        In = (N < 0).*Ic + (N >= 0).*It;
        Nmax_c = max(max(0, -N)); Nmax_t = max(max(0, N)); Mmax = max(abs(M)); Imax = max(In);
        env.(cs) = max(env.(cs), [Nmax_c Nmax_t Mmax Imax]);
      end
     end
    end
  end
end
nom = struct('sup', 'Brazo superior (libre)', 'acc', 'Brazo inferior accionado', 'lib', 'Brazo inferior libre');
fprintf('2. Envolvente por brazo (servicio)\n');
for cs = {'sup', 'acc', 'lib'}
  e = env.(cs{1});
  fprintf('   %-26s compresión %6.1f N, tracción %6.1f N, M máx %5.2f N·m -> interacción %.3f %s\n', ...
          nom.(cs{1}), e(1), e(2), e(3), e(4), ok(e(4) <= 1));
end
fprintf('\n');

%% 3. Sobrecarga del reductor en el brazo accionado
% Par máximo permisible del reductor (38 N·m) aplicado en el pivote del brazo accionado, sección bruta.
% SUPOSICIÓN: la sección de la raíz se evalúa bruta; los agujeros de la brida y de la KFL08 están en la zona
% donde el par lo toman los tornillos (memoria 07).
T_red = 38;
s_red = T_red*1000/Sx;
fprintf('3. Sobrecarga: T = %.0f N·m en la raíz del brazo accionado -> %.1f MPa (Fb = %.1f) -> %s\n', T_red, s_red, Fb, ok(s_red <= Fb));
