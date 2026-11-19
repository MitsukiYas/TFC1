%% MEMORIA 02 - UNIONES DE ESQUINA Y NUDOS (sobre memoria_01)
% Para cada nudo se suman los momentos de los extremos que llegan (equilibrio del nudo:
% el momento que el nudo debe transmitir por sus placas es el mayor momento de un extremo).
% Fuerza por tuerca en T: M / (2 x 20 mm / 2)... ver abajo. Admisible por tuerca = 684/1.95.
run('memoria_01_bastidor.m');
Fnut = 684/1.95;       % N [Ooznest, valor adoptado; n_u de 503]
dpl  = 0.020;          % m, separación de los dos agujeros de una rama de la placa L [Probots]
esq  = [];
for ix = xs, for iy = ys, for iz = zs, esq(end+1) = nid([ix iy iz]); end, end, end
fprintf('\n--- Nudos de esquina (8) ---\n');
for lc = 1:4
    Mn = zeros(1,nN); Vn = zeros(1,nN); Nn = zeros(1,nN);
    for k = 1:nE
        for e = 1:2
            n = El(k,e); o = (e-1)*6;
            f = res(lc).Fe(k,:);
            Mn(n) = max(Mn(n), hypot(f(o+5), f(o+6)));
            Vn(n) = max(Vn(n), hypot(f(o+2), f(o+3)));
            Nn(n) = max(Nn(n), abs(f(o+1)));
        end
    end
    res(lc).Mn = Mn; res(lc).Vn = Vn; res(lc).Nn = Nn;
    [mm, i] = max(Mn(esq));
    fprintf('%-38s  M esquina = %5.2f N·m  V = %5.1f N  N = %5.1f N  -> tuerca por M: %5.0f N\n', ...
        res(lc).nombre, mm, Vn(esq(i)), Nn(esq(i)), mm/dpl/2);
end
% Se toma como brazo de palanca de la placa L la separación de los agujeros (20 mm) y
% dos tuercas por rama: par de fuerzas F con brazo 20 mm -> F = M/0.020 por rama;
% con la placa tomando el momento en las dos ramas, F = M/(2*0.020).
fprintf('\nAdmisible por tuerca: %.0f N\n', Fnut);
[~,lc] = max(arrayfun(@(r) max(r.Mn(esq)), res));
mm = max(res(lc).Mn(esq));
fprintf('Caso crítico en esquinas: %s, M = %.2f N·m -> tuerca %.0f N, FS = %.2f\n', res(lc).nombre, mm, mm/dpl/2, Fnut/(mm/dpl/2));
% Todos los nudos
[mt, it] = max(res(lc).Mn);
fprintf('Nudo con mayor momento de toda la malla: (%.0f,%.0f,%.0f) mm, M = %.2f N·m\n', N(it,:)*1e3, mt);
