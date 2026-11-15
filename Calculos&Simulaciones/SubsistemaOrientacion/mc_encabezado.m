function mc_encabezado(num, titulo, objetivo, referencias)
% MC_ENCABEZADO  Imprime el encabezado de una memoria de calculo.
%   num         : numero de la memoria (entero)
%   titulo      : titulo de la memoria
%   objetivo    : que se calcula y para que
%   referencias : cell array con las fuentes citadas
linea = repmat('=', 1, 78);
fprintf('\n%s\n', linea);
fprintf(' MEMORIA DE CALCULO MC-%02d: %s\n', num, upper(titulo));
fprintf('%s\n', linea);
fprintf(' Objetivo: %s\n', objetivo);
if ~isempty(referencias)
    fprintf(' Referencias:\n');
    for k = 1:numel(referencias)
        fprintf('   - %s\n', referencias{k});
    end
end
fprintf('%s\n', repmat('-', 1, 78));
end
