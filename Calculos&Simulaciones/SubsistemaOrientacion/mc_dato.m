function mc_dato(nombre, valor, unidad, formato)
% MC_DATO  Imprime un dato en una sola linea: nombre, valor y unidad.
if nargin < 4 || isempty(formato), formato = '%.4g'; end
txt = sprintf(formato, valor);
fprintf('   %-52s %12s %s\n', nombre, txt, unidad);
end
