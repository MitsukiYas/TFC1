function x = resolver_paralelogramo(th, phi, sw, L, A, m_c, z_cm, m_b, g, F_bl, z_bl, F_U, z_Ux, Pv, b, h, Lt, Ms, r_p)
% Equilibrio plano del paralelogramo (ambos lados juntos). Unidades: m, N, N·m.
c = cosd(th); s = sind(th);
gv = g*[sind(phi), -cosd(phi)];
B = [0 A]; D = [0 0]; E = L*[c s]; C = E + [0 A];
mid = L/2*[c s];                                   % centro de cada brazo respecto a su pivote base
Fw_b = sw*2*Pv*b*(Lt*s + h*c)*[1 0];              % viento sobre los dos brazos de un nivel
Wb = 2*m_b*gv;                                     % peso de los dos brazos de un nivel
Fs = Ms/r_p*[-s c];                                % resortes sobre el travesaño
rs = r_p*[c s];
cr = @(r, f) r(1)*f(2) - r(2)*f(1);
M = zeros(9); R = zeros(9,1);
% Brazo superior: B (1,2), C (3,4)
M(1,[1 3]) = 1; R(1) = -(Fw_b(1) + Wb(1));
M(2,[2 4]) = 1; R(2) = -(Fw_b(2) + Wb(2));
rC = C - B; M(3,3) = -rC(2); M(3,4) = rC(1); R(3) = -cr(mid, Fw_b + Wb);
% Brazo inferior: D (5,6), E (7,8), T (9)
M(4,[5 7]) = 1; R(4) = -(Fw_b(1) + Wb(1) + Fs(1));
M(5,[6 8]) = 1; R(5) = -(Fw_b(2) + Wb(2) + Fs(2));
M(6,7) = -E(2); M(6,8) = E(1); M(6,9) = 1; R(6) = -(cr(mid, Fw_b + Wb) + cr(rs, Fs));
% Acoplador: recibe -C y -E, peso, viento
Fc = m_c*gv; Fwb = sw*[F_bl 0]; FwU = sw*[F_U 0];
M(7,[3 7]) = -1; R(7) = -(Fc(1) + Fwb(1) + FwU(1));
M(8,[4 8]) = -1; R(8) = -(Fc(2) + Fwb(2) + FwU(2));
M(9,3) = A; M(9,4) = 0;                            % momento respecto a E de -C aplicado en (0,A): -(0*(-Cz) - A*(-Cx))
R(9) = -(cr([0 z_cm], Fc) + cr([0 z_bl], Fwb) + cr([0 z_Ux], FwU));
x = M\R;
end
