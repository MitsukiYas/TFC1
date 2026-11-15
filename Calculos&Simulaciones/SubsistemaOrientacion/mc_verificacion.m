function R = mc_verificacion(R, nombre, resultado_txt, criterio_txt, cumple)
% MC_VERIFICACION  Imprime el resultado de una verificacion y lo guarda en R.verif.
%   cumple : true/false, o un texto que se imprime tal cual (p. ej. 'POR VERIFICAR').
if islogical(cumple) || isnumeric(cumple)
    if cumple, estado = 'CUMPLE'; else, estado = 'NO CUMPLE'; end
else
    estado = cumple;
end
fprintf('   >> %-40s %-18s criterio %-16s : %s\n', nombre, resultado_txt, criterio_txt, estado);
if ~isfield(R, 'verif'), R.verif = {}; end
R.verif(end+1, :) = {nombre, resultado_txt, criterio_txt, estado};
end
