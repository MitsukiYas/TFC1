%% MEMORIA 05 - PRESUPUESTO DE MASA Y CENTRO DE GRAVEDAD LONGITUDINAL (sin ruedas)
% x medido desde la cara trasera del bastidor. Las masas con SUPOSICIÓN están marcadas.
% Elevación + orientación: 10.874 kg (503); CG a partir del reparto de reacciones del modelo (memoria_04).
% Se calcula el CG de la elevación a theta = 15°: fija en el pivote (x = 54 mm) y parte móvil a x_piv + x_cg_mov.
x_piv = 0.054; Lbr = 0.600; th = 15; m_mov = 2.4224 + 1.9055; m_fij = 10.874 - m_mov;
x_cg_mov = (2.4224*Lbr*cosd(th) + 1.9055*(Lbr/2)*cosd(th))/m_mov;
x_el = (m_fij*x_piv + m_mov*(x_piv + x_cg_mov))/10.874;
%            nombre                               masa [kg]  x [m]    fuente
T = {
 'Elevación + orientación (θ = 15°)'               10.874     x_el     '503';
 'Bastidor de perfil 2020 (memoria_04)'             3.32      0.250    'modelo, 0.49 kg/m SUPOSICIÓN';
 'Placas de unión L (8 esquinas, 40 g)'             0.32      0.250    'Probots';
 'Gabinete de potencia (Cubo S)'                    1.5       0.215    'SUPOSICIÓN (usuario)';
 'Gabinete de control (Cubo S)'                     1.5       0.215    'SUPOSICIÓN (usuario)';
 'Batería 7S3P + gabinete Cubo D'                   2.16      0.250    '606 + SUPOSICIÓN 0.6 kg';
 'Motorreductores 42PG-775-67 con encoder (2 × 0.9 kg)' 1.8   0.050    'dato del usuario';
 'Servomotores RDS3225 (2 × 60 g)'                  0.12      0.490    'hoja del fabricante';
};
m = cell2mat(T(:,2)); x = cell2mat(T(:,3));
for i = 1:size(T,1), fprintf('%-42s %7.3f kg   x = %5.0f mm   %s\n', T{i,1}, m(i), x(i)*1e3, T{i,4}); end
fprintf('TOTAL sin ruedas, soportes de rueda ni cubierta: %.2f kg\n', sum(m));
xcg = sum(m.*x)/sum(m);
fprintf('CG longitudinal: x = %.0f mm desde la cara trasera = %.0f mm del eje trasero (eje a 50 mm, distancia entre ejes 440 mm)\n', xcg*1e3, (xcg-0.05)*1e3);
fprintf('Reparto estático sin ruedas: eje trasero %.1f %%, eje delantero %.1f %%\n', 100*(0.49-xcg)/0.44, 100*(xcg-0.05)/0.44);
