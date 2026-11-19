function construir_modelos()
%CONSTRUIR_MODELOS  Genera lazo_elevacion.slx y lazo_orientacion.slx.
%   Los modelos usan dos variables del espacio de trabajo base:
%     K   parámetros del controlador (KE o KO de parametros_control)
%     PL  parámetros de la planta, del sensor y del escenario (PE o PO)
%   simular_escenarios.m las asigna antes de cada simulación.

aqui = fileparts(mfilename('fullpath'));
crear_modelo(aqui, 'lazo_elevacion', 'elevacion');
crear_modelo(aqui, 'lazo_orientacion', 'orientacion');
end

%% =====================================================================
function crear_modelo(carpeta, nombre, tipo)
if bdIsLoaded(nombre), close_system(nombre, 0); end
archivo = fullfile(carpeta, [nombre '.slx']);
if exist(archivo, 'file'), delete(archivo); end
new_system(nombre); open_system(nombre);
set_param(nombre, 'Solver', 'ode1', 'FixedStep', '1e-3', 'StopTime', 'PL.t_fin', ...
    'SaveOutput', 'off', 'SaveTime', 'off', 'ReturnWorkspaceOutputs', 'on');
s = nombre;
elev = strcmp(tipo, 'elevacion');

% ---------------- Fuentes ----------------
add_block('simulink/Sources/Clock', [s '/Reloj']);
if elev
    add_block('simulink/Sources/Step', [s '/Consigna H'], 'Time', 'PL.t_ref', ...
        'Before', 'PL.H_ini', 'After', 'PL.H_fin', 'SampleTime', '0');
    mlfb([s '/Altura a angulo'], codigo_H_a_th(), {'PL'}, '');
else
    add_block('simulink/Sources/Step', [s '/Consigna beta'], 'Time', 'PL.t_ref', ...
        'Before', 'PL.b_ini', 'After', 'PL.b_fin', 'SampleTime', '0');
end
mlfb([s '/Escenario'], codigo_escenario(elev), {'PL'}, '');

% ---------------- Controlador (Arduino) ----------------
mlfb([s '/Controlador'], codigo_controlador(), {'K'}, 'K.Ts');

% ---------------- Motor paso a paso, reductor y mecanismo ----------------
add_block('simulink/Math Operations/Gain', [s '/Grados por pulso'], 'Gain', 'PL.res');
add_block('simulink/Continuous/Integrator', [s '/Angulo del motor'], 'InitialCondition', 'PL.th0');
add_block('simulink/Discontinuities/Quantizer', [s '/Micropasos'], 'QuantizationInterval', 'PL.res');
add_block('simulink/Continuous/Integrator', [s '/Retroceso sin energia'], 'InitialCondition', '0');
add_block('simulink/Math Operations/Sum', [s '/Suma motor'], 'Inputs', '++');
mlfb([s '/Flanco del juego'], codigo_flanco(elev), {'PL'}, '');
add_block('simulink/Math Operations/Sum', [s '/Suma juego'], 'Inputs', '++');
add_block('simulink/Math Operations/MinMax', [s '/Traba'], 'Function', 'min', 'Inputs', '2');

% ---------------- Sensor MPU-6050 ----------------
add_block('simulink/Sources/Random Number', [s '/Ruido'], 'Mean', '0', ...
    'Variance', 'PL.sigma^2', 'Seed', 'PL.semilla', 'SampleTime', 'K.Ts');
add_block('simulink/Sources/Constant', [s '/Sesgo y cabeceo'], 'Value', sesgo_expr(elev));
add_block('simulink/Math Operations/Sum', [s '/Suma sensor'], 'Inputs', '+++');
add_block('simulink/Discrete/Zero-Order Hold', [s '/Lectura I2C'], 'SampleTime', 'K.Ts');

% ---------------- Registro ----------------
if elev
    mlfb([s '/Angulo a altura'], codigo_th_a_H(), {'PL'}, '');
    nm = 9;
else
    nm = 7;
end
add_block('simulink/Signal Routing/Mux', [s '/Mux'], 'Inputs', num2str(nm));
add_block('simulink/Sinks/To Workspace', [s '/Registro'], 'VariableName', 'sal', ...
    'SaveFormat', 'Array', 'SampleTime', 'K.Ts');

% ---------------- Conexiones ----------------
c = @(a, b) add_line(s, a, b, 'autorouting', 'smart');
c('Reloj/1', 'Escenario/1');
if elev
    c('Consigna H/1', 'Altura a angulo/1');
    c('Altura a angulo/1', 'Controlador/1');
else
    c('Consigna beta/1', 'Controlador/1');
end
c('Lectura I2C/1', 'Controlador/2');
c('Escenario/1', 'Controlador/3');                 % en
c('Controlador/1', 'Grados por pulso/1');          % pulsos/s
c('Grados por pulso/1', 'Angulo del motor/1');
c('Angulo del motor/1', 'Micropasos/1');
c('Escenario/2', 'Retroceso sin energia/1');       % velocidad de descenso
c('Micropasos/1', 'Suma motor/1');
c('Retroceso sin energia/1', 'Suma motor/2');
c('Suma motor/1', 'Flanco del juego/1');
c('Escenario/3', 'Flanco del juego/2');            % ráfaga (km/h)
c('Suma motor/1', 'Suma juego/1');
c('Flanco del juego/1', 'Suma juego/2');
c('Suma juego/1', 'Traba/1');
c('Escenario/4', 'Traba/2');                       % límite de traba
c('Traba/1', 'Suma sensor/1');
c('Sesgo y cabeceo/1', 'Suma sensor/2');
c('Ruido/1', 'Suma sensor/3');
c('Suma sensor/1', 'Lectura I2C/1');
% registro: consigna, ángulo real, medido filtrado, estado, discrepancia, pulsos, en, [H*, H]
if elev
    c('Altura a angulo/1', 'Mux/1');
else
    c('Consigna beta/1', 'Mux/1');
end
c('Traba/1', 'Mux/2');
c('Controlador/2', 'Mux/3');
c('Controlador/3', 'Mux/4');
c('Controlador/4', 'Mux/5');
c('Controlador/1', 'Mux/6');
c('Escenario/1', 'Mux/7');
if elev
    c('Consigna H/1', 'Mux/8');
    c('Traba/1', 'Angulo a altura/1');
    c('Angulo a altura/1', 'Mux/9');
end
c('Mux/1', 'Registro/1');

% ---------------- Subsistemas para la figura ----------------
agrupar(s, {'Grados por pulso','Angulo del motor','Micropasos','Retroceso sin energia', ...
    'Suma motor','Flanco del juego','Suma juego','Traba'}, 'Motor, reductor y mecanismo');
agrupar(s, {'Ruido','Sesgo y cabeceo','Suma sensor','Lectura I2C'}, 'Sensor MPU-6050');
Simulink.BlockDiagram.arrangeSystem(s);
Simulink.BlockDiagram.arrangeSystem([s '/Motor, reductor y mecanismo']);
Simulink.BlockDiagram.arrangeSystem([s '/Sensor MPU-6050']);
save_system(s, archivo);
close_system(s, 0);
fprintf('Modelo creado: %s\n', archivo);
end

%% =====================================================================
function e = sesgo_expr(elev)
if elev, e = 'PL.sesgo + PL.cabeceo'; else, e = 'PL.sesgo'; end
end

function agrupar(s, nombres, titulo)
h = zeros(1, numel(nombres));
for k = 1:numel(nombres), h(k) = get_param([s '/' nombres{k}], 'Handle'); end
Simulink.BlockDiagram.createSubsystem(h);
% El subsistema nuevo queda con el nombre por omisión 'Subsystem'
sub = find_system(s, 'SearchDepth', 1, 'BlockType', 'SubSystem', 'Name', 'Subsystem');
set_param(sub{1}, 'Name', titulo);
end

function mlfb(ruta, codigo, params, ts)
add_block('simulink/User-Defined Functions/MATLAB Function', ruta);
ch = find(sfroot, '-isa', 'Stateflow.EMChart', 'Path', ruta);
ch.Script = codigo;
for k = 1:numel(params)
    d = ch.find('-isa', 'Stateflow.Data', 'Name', params{k});
    d.Scope = 'Parameter';
end
if ~isempty(ts)
    ch.ChartUpdate = 'DISCRETE';
    ch.SampleTime = ts;
end
end

%% =====================================================================
%  Código de los bloques MATLAB Function
%  =====================================================================
function t = codigo_H_a_th()
t = sprintf([ ...
'function th = altura_a_angulo(H, PL)\n' ...
'%% Consigna de altura del plano óptico -> ángulo del brazo (Ecuación eq:altura_elev)\n' ...
'th = asind((H - PL.H0)/PL.Lmm);\n']);
end

function t = codigo_th_a_H()
t = sprintf([ ...
'function H = angulo_a_altura(th, PL)\n' ...
'H = PL.H0 + PL.Lmm*sind(th);\n']);
end

function t = codigo_escenario(elev)
if elev
    t = sprintf([ ...
'function [en, v_desc, V, lim] = escenario(t, PL)\n' ...
'%% en = 0 durante la parada de emergencia (sin energía en el driver ni en el Arduino)\n' ...
'en = 1;\n' ...
'if t >= PL.t_parada(1) && t < PL.t_parada(2), en = 0; end\n' ...
'%% Sin corriente de retención, el reductor no se bloquea y el brazo desciende\n' ...
'v_desc = -PL.v_desc*(1 - en);\n' ...
'V = 0;\n' ...
'lim = 1e3;\n' ...
'if t >= PL.t_traba, lim = PL.th_traba; end\n']);
else
    t = sprintf([ ...
'function [en, v_desc, V, lim] = escenario(t, PL)\n' ...
'en = 1; v_desc = 0; lim = 1e3;\n' ...
'V = 0;\n' ...
'if t >= PL.t_rafaga(1) && t < PL.t_rafaga(2), V = PL.V_rafaga; end\n']);
end
end

function t = codigo_flanco(elev)
if elev
    t = sprintf([ ...
'function off = flanco(th, V, PL)\n' ...
'%% El momento externo (gravedad menos resortes) apoya el brazo en un flanco del juego.\n' ...
'M = interp1(PL.th_tab, PL.M_tab, th, ''linear'', ''extrap'');\n' ...
'off = PL.b2*sign(M);\n']);
else
    t = sprintf([ ...
'function off = flanco(th, V, PL)\n' ...
'%% Momento de retención del peso del sensor y la placa (MC-15) menos la ráfaga,\n' ...
'%% que actúa en sentido opuesto. Si cambia de signo, la corona cruza el juego.\n' ...
'M = PL.Kret*sind(th) - sign(th)*PL.Kv*V^2;\n' ...
'off = PL.b2*sign(M);\n']);
end
end

function t = codigo_controlador()
t = strjoin({ ...
'function [f, yf, est, d] = controlador(ref, y, en, K)'
'% Lazo de posición del Arduino (ejecuta cada K.Ts).'
'%   ref  consigna de ángulo [grados]      y   lectura del MPU-6050 [grados]'
'%   en   1 con energía, 0 en parada        f   pulsos/s hacia el driver DM542'
'%   yf   lectura filtrada                  est 1 medir, 2 mover, 3 en banda, 4 falla'
'%   d    discrepancia pasos comandados - giro medido [grados]'
'persistent st yfs pc v cmdf cmdf0 yf0 tgt t_esp ref_ant ini'
'if isempty(st)'
'    st = 1; yfs = y; pc = y; v = 0; cmdf = y; cmdf0 = y; yf0 = y;'
'    tgt = y; t_esp = 0; ref_ant = ref; ini = false;'
'end'
'd = 0;'
'if en < 0.5'
'    % Parada: el Arduino queda sin energía; al rearmar arranca desde cero'
'    ini = false; st = 1; v = 0; f = 0; yf = y; est = 0;'
'    return'
'end'
'if ~ini'
'    yfs = y; pc = y; cmdf = y; v = 0; st = 1; t_esp = 0; ini = true;'
'end'
'yfs = yfs + K.a*(y - yfs);'
'r = min(max(ref, K.lim_min), K.lim_max);'
'if abs(r - ref_ant) > 1e-9 && st ~= 4'
'    if st == 3'
'        t_esp = K.T_asent;   % en reposo el filtro ya está asentado'
'    else'
'        t_esp = 0;'
'    end'
'    st = 1;'
'end'
'ref_ant = r;'
'switch st'
'    case 1  % medir: espera a que se asiente el filtro'
'        v = 0;'
'        t_esp = t_esp + K.Ts;'
'        if t_esp >= K.T_asent'
'            e = r - yfs;'
'            if abs(e) <= K.banda'
'                st = 3;'
'            else'
'                if K.dir_final ~= 0 && sign(e) ~= K.dir_final'
'                    D = K.Kp*e - K.dir_final*K.a_off;   % pasa la consigna y vuelve en el sentido final'
'                else'
'                    D = K.Kp*e;'
'                end'
'                tgt = pc + D; cmdf0 = cmdf; yf0 = yfs; st = 2;'
'            end'
'        end'
'    case 2  % mover con perfil trapezoidal'
'        dr = tgt - pc;'
'        vm = min([K.wmax, sqrt(2*K.alfa*abs(dr)), abs(v) + K.alfa*K.Ts]);'
'        if abs(dr) <= vm*K.Ts'
'            v = dr/K.Ts; st = 1; t_esp = 0;'
'        else'
'            v = sign(dr)*vm;'
'        end'
'        d = (cmdf - cmdf0) - (yfs - yf0);'
'        if abs(d) > K.umbral'
'            v = 0; st = 4;'
'        end'
'        if (yfs > K.lim_max + K.banda && v > 0) || (yfs < K.lim_min - K.banda && v < 0)'
'            v = 0; st = 4;'
'        end'
'    case 3  % en banda: vigila la deriva'
'        v = 0;'
'        if abs(r - yfs) > K.banda_re'
'            st = 1; t_esp = 0;   % espera a que el filtro se asiente antes de corregir'
'        end'
'    otherwise  % falla: motor detenido'
'        v = 0;'
'end'
'pc = pc + v*K.Ts;'
'cmdf = cmdf + K.a*(pc - cmdf);'
'f = v/K.res;'
'yf = yfs;'
'est = st;'
}, newline);
end
