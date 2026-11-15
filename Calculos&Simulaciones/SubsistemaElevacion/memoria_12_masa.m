%% MEMORIA 12 - Presupuesto de masa del subsistema de elevación
% Masas por pieza a partir de: volúmenes de los sólidos del STEP del usuario (MECANISMO ELEVACIÓN, 2026-11-13),
% dimensiones de las piezas nuevas (memorias 08 y 09) y masas ya usadas en las memorias 01, 02, 08 y 09.
% Densidades: Shigley 11.ª ed., Tabla A-5 (peso específico w / g): aluminio 26.6 kN/m^3, acero al carbono
% 76.5 kN/m^3, acero inoxidable 76.0 kN/m^3. 5052-H32: 2680 kg/m^3 (parámetros, memoria 03).
% SUPOSICIÓN: el AISI 4140 y la tornillería A2 se asimilan al acero al carbono y al inoxidable de la Tabla A-5.
clear; clc;
run('parametros_elevacion.m');
fprintf('=== MEMORIA 12: PRESUPUESTO DE MASA ===\n\n');
rAl = 26.6e3/g*1e-9; rAc = 76.5e3/g*1e-9; rIx = 76.0e3/g*1e-9; r52 = P.Al5052.rho*1e-9;   % kg/mm^3
cil = @(d, L) pi/4*d^2*L;                                                                 % mm^3
% {grupo, pieza, cantidad, masa unitaria [kg], origen}
it = {};
add = @(it, gr, nom, n, m, src) [it; {gr, nom, n, m, src}];
% 1. Acoplador y subsistema de orientación (memoria 02)
it = add(it, 1, 'Subsistema de orientación', 1, P.blk.m, 'CAD (memoria 02)');
it = add(it, 1, 'Acoplador en U (5052-H32)', 1, 0.174, 'memoria 01');
it = add(it, 1, 'Herrajes del acoplador', 1, P.m_herrajes_acoplador, 'memoria 02');
% 2. Brazos y marco inferior
it = add(it, 2, 'Brazo (tubo 650 mm)', 4, P.tubo_mlin*0.650, '0.574 kg/m');
it = add(it, 2, 'Travesaño', 1, 30872*rAl, 'STEP');
it = add(it, 2, 'Cartela en T (5052-H32)', 4, 24948/4*r52, 'STEP');
it = add(it, 2, 'Tornillería de cartelas (M5x45, separador, arandelas, tuerca)', 8, (8606 + 6075 + 904 + 1476)/8*rIx, 'STEP');
it = add(it, 2, 'Varilla transversal Ø8 x 143.5', 1, (cil(8, 128.5) + 2*cil(6, 7.5))*rAc, 'memoria 09');
% Pieza en L: bloque sobre el tubo (15 x 25.4 x 13.65) + ala lateral (18 x 10 x 18)
VL = 15*25.4*13.65 + 18*10*18 - cil(6, 8);
it = add(it, 2, 'Pieza en L (6061-T6)', 2, VL*rAl, 'memoria 09');
it = add(it, 2, 'Tornillería de la pieza en L (M5, separador, arandela, tuerca)', 2, (1076 + 759 + 56 + 185)*rIx, 'STEP (similar)');
% 3. Nodos de la base
it = add(it, 3, 'Pasador del pivote actuado Ø8 x 196.5', 1, cil(8, 196.5)*rAc, 'memoria 08');
it = add(it, 3, 'Pasador superior Ø8 x 267.9', 1, cil(8, 267.9)*rAc, 'vistas');
it = add(it, 3, 'KFL08', 4, 0.0264, 'Naylamp (memoria 02)');
it = add(it, 3, 'Tornillos y tuercas de las KFL08', 8, (6980 + 2634)/16*rIx, 'STEP');
it = add(it, 3, 'Tuerca M8 + arandela', 2, (5008 + 1631)/7*rIx, 'STEP');
it = add(it, 3, 'Perilla M8', 3, 0.004367, 'memoria 02');
it = add(it, 3, 'Separador Ø14 x Ø8.2 x 25.8', 1, pi/4*(14^2 - 8.2^2)*25.8*rAc, 'vistas');
% SUPOSICIÓN: el separador del pivote superior se cuenta en acero (material por definir; caso más pesado).
it = add(it, 3, 'Casquillo POM-C', 1, 0.0558, 'memoria 08');
Lw = pi*(P.res.OD - P.res.d)*P.res.espiras + 45 + 39;   % mm, alambre del cuerpo + patas cortadas
it = add(it, 3, 'Resorte LTL/LTR135T 03 S', 2, cil(P.res.d, Lw)*rIx, 'Lee p. 298');
it = add(it, 3, 'Varilla de anclaje Ø8 x 242.4', 1, (cil(8, 233.4) + 2*cil(6, 4.5))*rAc, 'memoria 09');
% 4. Transmisión
it = add(it, 4, 'Motorreductor NMRVS40 + 34HS31', 1, 2.14 + 2.5, 'CAD (memoria 09)');
it = add(it, 4, 'Eje escalonado (4140)', 1, (cil(18, 81) + cil(22, 2) + cil(14, 25))*rAc, 'memoria 07');
it = add(it, 4, 'Chavetas 5x5x20 y 6x6x40', 1, (5*5*20 + 6*6*40)*rAc, 'memoria 07');
it = add(it, 4, 'Brida (AISI 303) + 4 M3 con tuerca', 1, (9527 + 469 + 249)*rIx, 'STEP');
% 5. Estructura de la base
it = add(it, 5, 'Poste 2020 x 250', 2, 82147/2*rAl, 'STEP');
it = add(it, 5, 'Travesaño superior 2020 x 218.9', 1, 35964*rAl, 'STEP');
% Placa libre prolongada: placa del STEP + prolongación (29 x 100 + triángulo 29 x 33 / 2) x 5
it = add(it, 5, 'Placa libre (prolongada)', 1, (68874 + (29*100 + 29*33/2)*5)*rAl, 'STEP + memoria 09');
it = add(it, 5, 'Placa motor', 1, 71418*rAl, 'STEP');
% SUPOSICIÓN: escuadra Bracket L doble 20 x 20 x 38 x 3 como dos alas planas (sin agujeros).
it = add(it, 5, 'Escuadra 20 x 20 x 38', 2, (20 + 17)*38*3*rAl, 'catálogo (aprox.)');
% SUPOSICIÓN: tornillos M5 de la base como el M5x10 del STEP (436 mm^3), tuercas en T de 138 mm^3 (STEP),
% M6 como 1.5 veces un M5.
it = add(it, 5, 'Tornillos M5 + tuerca en T (base y reductor)', 21, (436 + 138)*rIx, 'STEP (similar)');
it = add(it, 5, 'Tornillos M6 placa-reductor', 4, 1.5*436*rIx, 'estimado');
% Largueros 2020 del reductor: largo según el chasis (no se incluyen).
nomg = {'Acoplador y subsistema de orientación', 'Brazos y marco inferior', 'Nodos de la base y resortes', ...
        'Transmisión', 'Estructura de la base'};
tot = 0; mg = zeros(1,5);
for gidx = 1:5
  fprintf('%d. %s\n', gidx, nomg{gidx});
  for k = 1:size(it, 1)
    if it{k,1} ~= gidx, continue; end
    m = it{k,3}*it{k,4};
    fprintf('   %-62s %2d x %7.4f = %7.4f kg  (%s)\n', it{k,2}, it{k,3}, it{k,4}, m, it{k,5});
    mg(gidx) = mg(gidx) + m;
  end
  fprintf('   Subtotal: %.3f kg\n\n', mg(gidx)); tot = tot + mg(gidx);
end
fprintf('TOTAL del subsistema (sin los largueros del reductor): %.2f kg\n', tot);
fprintf('Masa que se mueve con el mecanismo (grupos 1 y 2): %.2f kg\n', sum(mg(1:2)));
save('masa_elevacion.mat', 'mg', 'tot', 'nomg');
