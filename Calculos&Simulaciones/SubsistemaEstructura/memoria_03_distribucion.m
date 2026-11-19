%% MEMORIA 03 - BASTIDOR CON LA DISTRIBUCIÓN DE COMPONENTES (segunda pasada)
% Cambios respecto a memoria_01: ejes en x = 50 y 490 mm, ruedas fuera del bastidor (momento R*s en cada
% apoyo), gabinetes en su posición real y esfuerzo con torsión.
% Pórtico espacial de perfil V-slot 2020 (6063-T5), resuelto por el método
% de rigidez directa con elementos viga 3D (12 GDL). Uniones rígidas.
% Ejes: x longitudinal (0 = cara trasera), y lateral, z vertical (0 = cara inferior).
% Todas las SUPOSICIONES están marcadas y se listan en el esquema .md.
clear; clc;

%% 1. Datos
g = 9.81;
% Perfil 2020: I de Naylamp (catálogo V-slot 2020)
I  = 6.988e-9;                 % m^4, Ix = Iy [Naylamp]
c  = 0.010;                    % m, fibra extrema
S  = I/c;                      % m^3
A  = 1.6e-4;                   % m^2  SUPOSICIÓN: Naylamp no publica el área
Jt = 1.0e-9;                   % m^4  SUPOSICIÓN: Naylamp no publica la constante de torsión (se hace sensibilidad)
E  = 69.6e9; G = 26.2e9;       % Pa, 6063 [Aluminum Design Manual]
Fty = 110e6; ny = 1.65;        % 6063-T5 [ADM], mismo criterio que 503
Fadm = Fty/ny;                 % 66.7 MPa
mlin = 0.49;                   % kg/m  SUPOSICIÓN: sin fuente (valor del texto actual)

% Envolvente exterior del chasis (dato del usuario): 500 x 400 x 260 mm
Lx = 0.500; Ly = 0.400; Lz = 0.260; e = 0.010;   % e: eje del perfil a la cara
xs = [e Lx-e]; ys = [e Ly-e]; zs = [e Lz-e];

% Ruedas: distancia entre ejes 450 mm y vía 380 mm (504/505)
x_rr = 0.050; x_ft = 0.490;   % m, eje trasero a 50 mm de la cara trasera (el motor 42PG libra el poste); eje delantero en el poste delantero
s_r = 0.060;                  % m, SUPOSICIÓN: plano medio de la rueda a 60 mm de la cara lateral (ver esquema)

% Subsistema de elevación (memoria_12 y cargas_elevacion.mat de 503)
m_elev = 10.874; m_mov = 2.4224 + 1.9055;      % kg, total y parte móvil (acoplador + brazos)
x_piv  = 0.054;                                 % m, pivote actuado a 54 mm de la cara trasera (P.x_pivote_frente = 446)
y_pl   = [0.5*Ly-0.11945, 0.5*Ly+0.11945];      % m, planos medios de las placas (238.9 mm)
Lbr = 0.600;
% Gabinetes (cap. 6): potencia y control a los lados largos, batería al centro del piso
m_gab  = 1.5;   % kg c/u con contenido  SUPOSICIÓN: falta masa del catálogo Ensto y del contenido
m_bat  = 1.56 + 0.6;   % kg, paquete 7S3P (606) + gabinete Cubo D  SUPOSICIÓN: 0.6 kg del gabinete
kd = 2.0;       % SUPOSICIÓN (fuente 5): factor dinámico vertical por irregularidades
h_obst = 0.020; % m, SUPOSICIÓN (fuente 5): obstáculo bajo una rueda delantera

%% 2. Nodos y elementos
N = []; addN = @(N,p) [N; p];
% esquinas: id = 1..8
for zz = zs, for yy = ys, for xx = xs, N = addN(N,[xx yy zz]); end, end, end
nidN = @(N,p) find(all(abs(N - p) < 1e-6, 2), 1);
xi = sort(unique([xs x_rr x_ft x_piv 0.110 0.150 0.350 0.320]));
% nodos intermedios en los largueros exteriores (superior e inferior) y en los largueros de elevación
for zz = zs, for yy = ys, for xx = xi
    if isempty(nidN(N,[xx yy zz])), N = addN(N,[xx yy zz]); end
end, end, end
for yy = y_pl, for xx = unique([xs x_piv 0.110 0.250]), N = addN(N,[xx yy zs(2)]); end, end
% travesaños inferiores de la batería (x = 0.150 y 0.350) con nodos en y de la batería
for xx = [0.150 0.350], for yy = [0.5*Ly-0.065, 0.5*Ly+0.065], N = addN(N,[xx yy zs(1)]); end, end

nid = @(p) nidN(N,p);
El = [];
addLine = @(El,pts) [El; [pts(1:end-1)' pts(2:end)']];
lineNodes = @(cond, key) sortrows([find(cond) N(cond,key)], 2);
% largueros longitudinales exteriores (4) y de elevación (2)
for zz = zs, for yy = ys
    L = lineNodes(abs(N(:,2)-yy)<1e-6 & abs(N(:,3)-zz)<1e-6, 1); El = addLine(El, L(:,1)');
end, end
for yy = y_pl
    L = lineNodes(abs(N(:,2)-yy)<1e-6 & abs(N(:,3)-zs(2))<1e-6, 1); El = addLine(El, L(:,1)');
end
% travesaños de los extremos (sup. con nodos de largueros de elevación)
for zz = zs, for xx = xs
    L = lineNodes(abs(N(:,1)-xx)<1e-6 & abs(N(:,3)-zz)<1e-6, 2); El = addLine(El, L(:,1)');
end, end
% travesaños inferiores de batería
for xx = [0.150 0.350]
    L = lineNodes(abs(N(:,1)-xx)<1e-6 & abs(N(:,3)-zs(1))<1e-6, 2); El = addLine(El, L(:,1)');
end
% postes
for yy = ys, for xx = xs, El = [El; nid([xx yy zs(1)]) nid([xx yy zs(2)])]; end, end
nN = size(N,1); nE = size(El,1);
nid = @(p) nidN(N,p);

%% 3. Masa del bastidor
Lel = vecnorm(N(El(:,2),:) - N(El(:,1),:), 2, 2);
m_bast = mlin*sum(Lel);

%% 4. Matriz de rigidez
K = zeros(6*nN);
T = cell(nE,1);
for k = 1:nE
    [ke, Tk] = viga3d(N(El(k,1),:), N(El(k,2),:), E, G, A, I, I, Jt);
    T{k} = Tk; d = [6*El(k,1)-5:6*El(k,1), 6*El(k,2)-5:6*El(k,2)];
    K(d,d) = K(d,d) + Tk'*ke*Tk;
end

%% 5. Casos de carga
casos = {'LC1 estático, theta=15°', 'LC2 dinámico kd, theta=15°', ...
         'LC3 pendiente 16° + a=0.3 m/s^2', 'LC4 rueda delantera sobre obstáculo'};
apoyos = [nid([x_rr ys(1) zs(1)]) nid([x_rr ys(2) zs(1)]) nid([x_ft ys(1) zs(1)]) nid([x_ft ys(2) zs(1)])];
th = 15;
% Momento de la parte móvil respecto a la línea de pivotes (hacia adelante)
x_cg_mov = (2.4224*Lbr*cosd(th) + 1.9055*(Lbr/2)*cosd(th))/m_mov;
res = struct();
for lc = 1:4
    F = zeros(6*nN,1);
    switch lc
        case 1, fz = 1; fx = 0;
        case 2, fz = kd; fx = 0;
        case 3, fz = cosd(16); fx = -(sind(16) + 0.3/g);   % componente hacia atrás (subida)
        case 4, fz = 1; fx = 0;
    end
    % peso propio repartido en los nodos de cada elemento
    for k = 1:nE
        w = mlin*Lel(k)*g/2;
        for n = El(k,:), F(6*n-3) = F(6*n-3) - fz*w; F(6*n-5) = F(6*n-5) + fx*w; end
    end
    % elevación: peso fijo en el pivote y par de la parte móvil como par vertical
    % entre x_piv y 0.110 m sobre cada larguero de elevación
    Wfix = (m_elev - m_mov)*g; Wmov = m_mov*g;
    Mmov = Wmov*x_cg_mov;                 % N·m alrededor de y
    dxp = 0.110 - x_piv;
    for yy = y_pl
        n1 = nid([x_piv yy zs(2)]); n2 = nid([0.110 yy zs(2)]);
        F(6*n1-3) = F(6*n1-3) - fz*(Wfix + Wmov)/2 + fz*Mmov/2/dxp;
        F(6*n2-3) = F(6*n2-3) - fz*Mmov/2/dxp;
        F(6*n1-5) = F(6*n1-5) + fx*(Wfix + Wmov)/2;
        % momento de la fuerza longitudinal (altura del CG de la elevación ~ 0.3 m SUPOSICIÓN)
        F(6*n1-1) = F(6*n1-1) + fx*(Wfix+Wmov)/2*0.30;
    end
    % gabinetes laterales: carga en los largueros exteriores superior e inferior
    for yy = ys, for zz = zs, for xx = [0.110 0.320]
        n = nid([xx yy zz]); F(6*n-3) = F(6*n-3) - fz*m_gab*g/4; F(6*n-5) = F(6*n-5) + fx*m_gab*g/4;
    end, end, end
    % batería sobre los travesaños inferiores
    for xx = [0.150 0.350], for yy = [0.5*Ly-0.065, 0.5*Ly+0.065]
        n = nid([xx yy zs(1)]); F(6*n-3) = F(6*n-3) - fz*m_bat*g/4; F(6*n-5) = F(6*n-5) + fx*m_bat*g/4;
    end, end
    % Apoyos: z en las 4 ruedas; x en las traseras (tracción); y en las delanteras
    fij = [6*apoyos-3, 6*apoyos(1:2)-5, 6*apoyos(3)-4, 6*apoyos(4)-4];
    lib = setdiff(1:6*nN, fij);
    F0 = F; Mw = zeros(6*nN,1); sg = [-1; 1; -1; 1];
    for it = 1:10
        F = F0 + Mw;
        U = zeros(6*nN,1);
        U(lib) = K(lib,lib) \ F(lib);
        if lc == 4
            Uu = zeros(6*nN,1); Uu(6*apoyos(3)-3) = 1;
            Uu(lib) = -K(lib,lib) \ (K(lib,fij)*Uu(fij));
            Rg = K*U - F; Ru = K*Uu;
            rz_g = Rg(6*apoyos-3); rz_u = Ru(6*apoyos-3);
            d_star = min(-rz_g(rz_u < 0)./rz_u(rz_u < 0));
            res(lc).d_star = d_star*1e3;
            U = U + min(h_obst, d_star)*Uu;
        end
        R = K*U - F;
        Mw(6*apoyos-2) = sg*s_r.*R(6*apoyos-3);   % la rueda empuja a s_r fuera del apoyo
    end
    R = K*U - F;
    % esfuerzos
    smax = 0; kmax = 0; taum = 0; mj = 0; vj = 0; Fe = zeros(nE,12);
    for k = 1:nE
        d = [6*El(k,1)-5:6*El(k,1), 6*El(k,2)-5:6*El(k,2)];
        [ke,~] = viga3d(N(El(k,1),:), N(El(k,2),:), E, G, A, I, I, Jt);
        f = ke*T{k}*U(d); Fe(k,:) = f';
        Mmax = max([hypot(f(5),f(6)) hypot(f(11),f(12))]);   % flexión biaxial (resultante, conservador)
        mj = max(mj,Mmax); vj = max(vj, max(hypot(f(2),f(3)), hypot(f(8),f(9))));
        sgm = abs(f(1))/A + Mmax/S; tau = max(abs(f(4)),abs(f(10)))*c/Jt; s = sqrt(sgm^2 + 3*tau^2); taum = max(taum,tau);
        if s > smax, smax = s; kmax = k; end
    end
    % giro de cabeceo en el pivote de elevación
    pitch = mean([U(6*nid([x_piv y_pl(1) zs(2)])-1), U(6*nid([x_piv y_pl(2) zs(2)])-1)]);
    res(lc).nombre = casos{lc}; res(lc).smax = smax/1e6; res(lc).Fe = Fe; res(lc).taum = taum/1e6; res(lc).Mj = mj; res(lc).Vj = vj; res(lc).elem = kmax;
    res(lc).wmax = max(abs(U(3:6:end)))*1e3; res(lc).pitch = rad2deg(pitch);
    res(lc).Rz = R(6*apoyos-3)';
end

%% 6. Resultados
fprintf('Nodos: %d   Elementos: %d   Longitud de perfil: %.2f m   Masa del bastidor: %.2f kg\n', nN, nE, sum(Lel), m_bast);
fprintf('Esfuerzo admisible 6063-T5: %.1f MPa\n\n', Fadm/1e6);
for lc = 1:4
    r = res(lc);
    fprintf('%-40s  smax = %6.1f MPa (FS = %4.2f)  w_max = %6.3f mm  pitch base = %7.4f°\n', ...
        r.nombre, r.smax, Fadm/1e6/r.smax, r.wmax, r.pitch);
    fprintf('   Reacciones Rz [N] (RI, RD, FI, FD): %s\n', mat2str(round(r.Rz,1)));
    k = r.elem; fprintf('   Elemento crítico: (%.0f,%.0f,%.0f)-(%.0f,%.0f,%.0f) mm\n', N(El(k,1),:)*1e3, N(El(k,2),:)*1e3);
end
for lc=1:4, fprintf('%s: M extremo máx = %.2f N·m, V extremo máx = %.1f N\n', res(lc).nombre, res(lc).Mj, res(lc).Vj); end
fprintf('\nRigidez torsional del bastidor: %.1f N·m/°   Alzamiento que descarga la diagonal: %.3f mm\n', NaN, res(4).d_star);

function [ke, T] = viga3d(p1, p2, E, G, A, Iy, Iz, J)
L = norm(p2-p1); ex = (p2-p1)/L;
ref = [0 0 1]; if abs(dot(ex,ref)) > 0.99, ref = [1 0 0]; end
ey = cross(ref, ex); ey = ey/norm(ey); ez = cross(ex, ey);
R = [ex; ey; ez]; T = blkdiag(R,R,R,R);
k = zeros(12);
a = E*A/L; t = G*J/L;
bz = E*Iz/L^3; by = E*Iy/L^3;
k([1 7],[1 7]) = a*[1 -1; -1 1];
k([4 10],[4 10]) = t*[1 -1; -1 1];
idz = [2 6 8 12];
k(idz,idz) = bz*[12 6*L -12 6*L; 6*L 4*L^2 -6*L 2*L^2; -12 -6*L 12 -6*L; 6*L 2*L^2 -6*L 4*L^2];
idy = [3 5 9 11];
k(idy,idy) = by*[12 -6*L -12 -6*L; -6*L 4*L^2 6*L 2*L^2; -12 6*L 12 6*L; -6*L 2*L^2 6*L 4*L^2];
ke = k;
end
