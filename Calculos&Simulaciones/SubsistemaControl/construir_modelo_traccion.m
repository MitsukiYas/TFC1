function construir_modelo_traccion()
%CONSTRUIR_MODELO_TRACCION  Genera lazo_traccion.slx (tracción y dirección).
%   Dos motorreductores con PI de velocidad y diferencial electrónico en el eje
%   posterior, y dos servomotores de dirección Ackermann en el eje frontal.
%   Usa las variables del espacio de trabajo base K (KT) y PL (PT).

carpeta = fileparts(mfilename('fullpath'));
s = 'lazo_traccion';
if bdIsLoaded(s), close_system(s, 0); end
archivo = fullfile(carpeta, [s '.slx']);
if exist(archivo, 'file'), delete(archivo); end
new_system(s); open_system(s);
set_param(s, 'Solver', 'ode1', 'FixedStep', '1e-4', 'StopTime', 'PL.t_fin', ...
    'SaveOutput', 'off', 'SaveTime', 'off', 'ReturnWorkspaceOutputs', 'on');

% ---------------- Consignas ----------------
add_block('simulink/Sources/Clock', [s '/Reloj']);
mlfb([s '/Escenario'], cod_escenario(), {'PL'}, '');

% ---------------- Firmware (Arduino) ----------------
mlfb([s '/Mando de direccion'], cod_mando(), {'K'}, 'K.Ts');
mlfb([s '/Diferencial electronico'], cod_diferencial(), {'K', 'PL'}, 'K.Ts');
for n = {'izq', 'der'}
    mlfb([s '/Controlador ' n{1}], cod_controlador(), {'K'}, 'K.Ts');
    add_block('simulink/Discrete/Unit Delay', [s '/ADC corriente ' n{1}], 'SampleTime', 'K.Ts', 'InitialCondition', '0');
end

% ---------------- Actuadores ----------------
for n = {'izq', 'der'}
    add_block('simulink/Discontinuities/Rate Limiter', [s '/Servo ' n{1}], ...
        'RisingSlewLimit', 'PL.w_servo', 'FallingSlewLimit', '-PL.w_servo');
    mlfb([s '/Motor y neumatico ' n{1}], cod_rueda(), {'PL'}, '');
    add_block('simulink/Continuous/Integrator', [s '/Giro rueda ' n{1}], 'InitialCondition', '0');
    add_block('simulink/Discontinuities/Quantizer', [s '/Encoder ' n{1}], 'QuantizationInterval', '2*pi/PL.cuentas');
end

% ---------------- Vehículo ----------------
mlfb([s '/Geometria de direccion'], cod_geometria(), {'PL'}, '');
mlfb([s '/Cinematica'], cod_cinematica(), {'PL'}, '');
mlfb([s '/Dinamica longitudinal'], cod_dinamica(), {'PL'}, '');
add_block('simulink/Continuous/Integrator', [s '/Velocidad'], 'InitialCondition', '0');
mlfb([s '/Pose'], cod_pose(), {}, '');
add_block('simulink/Continuous/Integrator', [s '/Rumbo'], 'InitialCondition', '0');
add_block('simulink/Continuous/Integrator', [s '/Posicion x'], 'InitialCondition', '0');
add_block('simulink/Continuous/Integrator', [s '/Posicion y'], 'InitialCondition', '0');

add_block('simulink/Signal Routing/Mux', [s '/Mux'], 'Inputs', '21');
add_block('simulink/Sinks/To Workspace', [s '/Registro'], 'VariableName', 'sal', ...
    'SaveFormat', 'Array', 'SampleTime', '0.002');

c = @(a, b) add_line(s, a, b, 'autorouting', 'smart');
c('Reloj/1', 'Escenario/1');
c('Escenario/2', 'Mando de direccion/1');            % curvatura pedida
c('Escenario/1', 'Diferencial electronico/1');       % v*
c('Mando de direccion/3', 'Diferencial electronico/2');   % curvatura del firmware
c('Escenario/4', 'Diferencial electronico/3');             % V_bat (LTC2944)
c('Mando de direccion/1', 'Servo izq/1');
c('Mando de direccion/2', 'Servo der/1');
c('Servo izq/1', 'Geometria de direccion/1');
c('Servo der/1', 'Geometria de direccion/2');
c('Geometria de direccion/1', 'Cinematica/2');
c('Velocidad/1', 'Cinematica/1');
c('Escenario/3', 'Dinamica longitudinal/4');
c('Velocidad/1', 'Dinamica longitudinal/3');
c('Dinamica longitudinal/1', 'Velocidad/1');
c('Velocidad/1', 'Pose/1');
c('Geometria de direccion/1', 'Pose/2');
c('Rumbo/1', 'Pose/3');
c('Pose/1', 'Rumbo/1');
c('Pose/2', 'Posicion x/1');
c('Pose/3', 'Posicion y/1');
lados = {'izq', 'der'};
for k = 1:2
    n = lados{k}; m = ['Motor y neumatico ' n];
    c(sprintf('Diferencial electronico/%d', k), ['Controlador ' n '/1']);
    c(['Encoder ' n '/1'], ['Controlador ' n '/2']);
    c([m '/1'], ['ADC corriente ' n '/1']);
    c(['ADC corriente ' n '/1'], ['Controlador ' n '/3']);
    c('Escenario/4', ['Controlador ' n '/4']);
    c(['Controlador ' n '/1'], [m '/1']);
    c('Escenario/4', [m '/2']);
    c(sprintf('Cinematica/%d', k), [m '/3']);
    c('Escenario/3', [m '/4']);
    c([m '/3'], ['Giro rueda ' n '/1']);
    c(['Giro rueda ' n '/1'], ['Encoder ' n '/1']);
    c([m '/2'], sprintf('Dinamica longitudinal/%d', k));
end
% Registro: 1 v*, 2 v, 3 w*izq, 4 w med izq, 5 w*der, 6 w med der, 7 d izq, 8 d der,
% 9 I izq, 10 I der, 11 F tracción, 12 N posterior, 13 pendiente, 14 T izq, 15 T der,
% 16 delta izq real [°], 17 delta der real [°], 18 curvatura del firmware, 19 curvatura real,
% 20 x, 21 y
fuentes = {'Escenario/1', 'Velocidad/1', 'Diferencial electronico/1', 'Controlador izq/2', ...
    'Diferencial electronico/2', 'Controlador der/2', 'Controlador izq/1', 'Controlador der/1', ...
    'Motor y neumatico izq/1', 'Motor y neumatico der/1', 'Dinamica longitudinal/2', ...
    'Dinamica longitudinal/3', 'Escenario/3', 'Motor y neumatico izq/2', 'Motor y neumatico der/2', ...
    'Servo izq/1', 'Servo der/1', 'Mando de direccion/3', 'Geometria de direccion/1', ...
    'Posicion x/1', 'Posicion y/1'};
for k = 1:numel(fuentes), c(fuentes{k}, sprintf('Mux/%d', k)); end
c('Mux/1', 'Registro/1');

agrupar(s, {'Geometria de direccion', 'Cinematica', 'Dinamica longitudinal', 'Velocidad', ...
    'Pose', 'Rumbo', 'Posicion x', 'Posicion y'}, 'Vehiculo');
agrupar(s, {'Giro rueda izq', 'Giro rueda der', 'Encoder izq', 'Encoder der'}, 'Encoders');
Simulink.BlockDiagram.arrangeSystem(s);
Simulink.BlockDiagram.arrangeSystem([s '/Vehiculo']);
save_system(s, archivo);
close_system(s, 0);
fprintf('Modelo creado: %s\n', archivo);
end

%% =====================================================================
function agrupar(s, nombres, titulo)
h = zeros(1, numel(nombres));
for k = 1:numel(nombres), h(k) = get_param([s '/' nombres{k}], 'Handle'); end
Simulink.BlockDiagram.createSubsystem(h);
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
function t = cod_escenario()
t = strjoin({ ...
'function [v_ref, kappa, phi, V_bat] = escenario(t, PL)'
'% Velocidad en rampa de PL.a_ref hasta PL.v_nom; curvatura pedida por tramos'
'v_ref = min(PL.v_nom, PL.a_ref*max(0, t - PL.t_arr));'
'kappa = 0;'
'if t >= PL.giro(1) && t < PL.giro(2), kappa = PL.giro(3); end'
'if t >= PL.giro2(1) && t < PL.giro2(2), kappa = PL.giro2(3); end'
'phi = PL.pend0;'
'if t >= PL.pend_t(1), phi = PL.pend_t(2); end'
'V_bat = PL.V_bat;'
}, newline);
end

function t = cod_mando()
t = strjoin({ ...
'function [d_izq, d_der, kappa_fw] = mando_direccion(kappa_ref, K)'
'% Ackermann: ángulos de las ruedas frontales para la curvatura pedida, con la'
'% velocidad de cada consigna limitada a la del servo. kappa_fw es la curvatura que'
'% corresponde a esas consignas y la usa el diferencial electrónico.'
'persistent a_izq a_der'
'if isempty(a_izq), a_izq = 0; a_der = 0; end'
'kap = min(max(kappa_ref, -K.kappa_max), K.kappa_max);'
'obj_izq = atand(K.L*kap/(1 - K.b*kap/2));'
'obj_der = atand(K.L*kap/(1 + K.b*kap/2));'
'if K.w_servo > 0'
'    paso = K.w_servo*K.Ts;'
'    a_izq = a_izq + min(max(obj_izq - a_izq, -paso), paso);'
'    a_der = a_der + min(max(obj_der - a_der, -paso), paso);'
'else'
'    a_izq = obj_izq; a_der = obj_der;'
'end'
'd_izq = a_izq; d_der = a_der;'
'ti = tand(a_izq); td = tand(a_der);'
'kappa_fw = 0.5*(ti/(K.L + K.b*ti/2) + td/(K.L - K.b*td/2));'
}, newline);
end

function t = cod_diferencial()
t = strjoin({ ...
'function [w_izq, w_der] = diferencial(v_ref, kappa, V_bat, K, PL)'
'% Velocidades de las ruedas posteriores para virar sin arrastre (505), con la vía trasera.'
'% Si la rueda exterior pediría más velocidad de la que el motor da con la tensión'
'% disponible, se reduce la velocidad de avance.'
'if K.limitar_curva > 0.5'
'    V_ef = min(K.V_mot, K.d_max_abs*V_bat);'
'    w_lim = (V_ef - K.R*K.I_plano)/K.ke;'
'    v_ref = min(v_ref, w_lim*K.r/(1 + K.t*abs(kappa)/2));'
'end'
'if PL.diferencial > 0.5'
'    w_izq = v_ref*(1 - K.t*kappa/2)/K.r;'
'    w_der = v_ref*(1 + K.t*kappa/2)/K.r;'
'else'
'    w_izq = v_ref/K.r; w_der = w_izq;'
'end'
}, newline);
end

function t = cod_controlador()
t = strjoin({ ...
'function [d, w_med] = controlador_rueda(w_ref, th, I, V_bat, K)'
'% PI de velocidad de una rueda posterior (Arduino, cada K.Ts).'
'%   th: giro de la rueda contado por el encoder del motor [rad]; I: salida CS [A]'
'persistent th_ant xi'
'if isempty(th_ant), th_ant = th; xi = 0; end'
'w_med = (th - th_ant)/K.Ts;'
'th_ant = th;'
'e = w_ref - w_med;'
'd_max = min(K.d_max_abs, K.V_mot/V_bat);   % motor de 24 V con batería de hasta 29.4 V (603)'
'u = K.Kp*e + xi;'
'exceso = max(0, abs(I) - K.I_lim);          % límite de corriente de 8 A (603)'
'u = u - sign(u)*K.Kc*exceso;'
'd = min(max(u, -d_max), d_max);'
'if (abs(u) < d_max || sign(e) ~= sign(u)) && exceso == 0'
'    xi = xi + K.Ki*K.Ts*e;'
'end'
}, newline);
end

function t = cod_rueda()
t = strjoin({ ...
'function [I, T, w] = motor_neumatico(d, V_bat, v_i, phi, PL)'
'% Motorreductor con puente H (valores medios, sin inductancia) que mueve una'
'% rueda posterior con deslizamiento longitudinal lineal hasta mu·N.'
'c = cosd(phi); s = sind(phi);'
'N_r = PL.m*PL.g*c - (PL.m*PL.g*c*PL.Lcm - PL.m*PL.g*s*PL.hcm)/PL.L;'
'N_i = N_r/2;'
'F_max = PL.mu*N_i;'
'vr = max(abs(v_i), PL.v_min);'
'C = F_max/PL.s_pico;'
'a0 = PL.kt*(d*V_bat/PL.R - PL.I0*tanh(v_i/0.05));'
'a1 = PL.kt*PL.ke/PL.R;'
'w = (a0 + C*PL.r*v_i/vr)/(a1 + C*PL.r^2/vr);'
'F = C*(w*PL.r - v_i)/vr;'
'if abs(F) > F_max'
'    F = sign(F)*F_max;'
'    w = (a0 - F*PL.r)/a1;'
'end'
'I = (d*V_bat - PL.ke*w)/PL.R;'
'T = F*PL.r;'
}, newline);
end

function t = cod_geometria()
t = strjoin({ ...
'function [kappa, discrepancia] = geometria(d_izq, d_der, PL)'
'% Curvatura que imponen los ángulos reales de las ruedas frontales. Si no cumplen'
'% Ackermann, cada rueda pide una curvatura distinta y la diferencia se arrastra.'
'ti = tand(d_izq); td = tand(d_der);'
'k_izq = ti/(PL.L + PL.b*ti/2);'
'k_der = td/(PL.L - PL.b*td/2);'
'kappa = 0.5*(k_izq + k_der);'
'discrepancia = k_izq - k_der;'
}, newline);
end

function t = cod_cinematica()
t = strjoin({ ...
'function [v_izq, v_der] = cinematica(v, kappa, PL)'
'% Velocidad del centro de cada rueda posterior (vía trasera PL.t)'
'v_izq = v*(1 - PL.t*kappa/2);'
'v_der = v*(1 + PL.t*kappa/2);'
}, newline);
end

function t = cod_dinamica()
t = strjoin({ ...
'function [dv, F, N_r] = dinamica(T_izq, T_der, v, phi, PL)'
'% Equilibrio longitudinal de 505 con la masa de diseño'
'c = cosd(phi); s = sind(phi);'
'F = (T_izq + T_der)/PL.r;'
'F_rr = PL.fr*PL.m*PL.g*c*tanh(v/0.01);'
'dv = (F - PL.m*PL.g*s - F_rr)/(PL.m + 2*PL.J_rueda/PL.r^2);'
'N_f = (PL.m*PL.g*c*PL.Lcm - PL.m*PL.g*s*PL.hcm - PL.m*dv*PL.hcm)/PL.L;'
'N_r = PL.m*PL.g*c - N_f;'
}, newline);
end

function t = cod_pose()
t = strjoin({ ...
'function [dpsi, dx, dy] = pose(v, kappa, psi)'
'% Trayectoria del centro del eje posterior en el plano'
'dpsi = v*kappa;'
'dx = v*cos(psi);'
'dy = v*sin(psi);'
}, newline);
end
