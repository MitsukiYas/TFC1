# Pivote delantero (lado izquierdo): conjunto, detalle del servo, detalle del cubo y planos K1 a K7. Medidas en mm.
# Coordenadas globales: y negativo hacia afuera; z: 0 = cara inferior del bastidor; corte en x = 490.
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon, Circle, Rectangle

KPI = 15.1; t = math.tan(math.radians(KPI)); s_, c_ = math.sin(math.radians(KPI)), math.cos(math.radians(KPI))
yax = lambda z: -100 + (z + 59) * t
CK, CF, CS, CW, CB, CA, CG, CP = '#1d9e75', '#b8bec8', '#d9534f', '#6f6f6f', '#3c7fc4', '#e8b04b', '#555555', '#8e6fc1'


def poly(ax, pts, fc, a=0.6, lw=0.8, ls='-', z=2):
    ax.add_patch(Polygon(pts, closed=True, fc=fc if ls == '-' else 'none', ec='k', lw=lw, alpha=a if ls == '-' else 1, ls=ls, zorder=z))


def rr(ax, y0, y1, z0, z1, fc, a=0.6, ls='-', lw=0.8, z=2):
    poly(ax, [(y0, z0), (y1, z0), (y1, z1), (y0, z1)], fc, a, lw, ls, z)


def hdim(ax, x1, x2, y, txt, fs=8):
    ax.annotate('', xy=(x1, y), xytext=(x2, y), arrowprops=dict(arrowstyle='<->', lw=0.7))
    ax.text((x1 + x2) / 2, y + 1, txt, ha='center', va='bottom', fontsize=fs)


def vdim(ax, y1, y2, x, txt, fs=8, left=False):
    ax.annotate('', xy=(x, y1), xytext=(x, y2), arrowprops=dict(arrowstyle='<->', lw=0.7))
    ax.text(x + (-1.5 if left else 1.5), (y1 + y2) / 2, txt, ha='right' if left else 'left', va='center', fontsize=fs)


# --- Sistema local del eje del pivote: u a lo largo del eje (hacia arriba), v perpendicular (hacia afuera = -y).
# Origen local: punto del eje en la cara superior del brazo superior de la mangueta (z = 200).
O = (yax(200), 200)


def L2G(v, u):
    # v positivo hacia el bastidor (+y), u positivo hacia arriba a lo largo del eje
    return (O[0] + v * c_ + u * s_, O[1] - v * s_ + u * c_)


def lrect(v0, v1, u0, u1):
    return [L2G(v0, u0), L2G(v1, u0), L2G(v1, u1), L2G(v0, u1)]


# Pila a lo largo del eje (u, mm), ver SERVO_DETALLE:
ST = dict(lug=(-10, 0), arandela=(0, 2), brazo=(2, 14), buje=(4, 12), sep=(14, 26), k4=(16, 26), horn=(26, 29), placa=(26, 29),
          servo=(29, 69.5), k3=(-10, 26))

# ======================= CONJUNTO =======================
fig, ax = plt.subplots(figsize=(14, 13))
ax.axhline(-59, color='k', lw=1)
rr(ax, -125, -75, -59, 141, CW, 0.13, z=1); rr(ax, -105, -95, 16, 66, CW, 0.4, z=1)
ax.text(-100, -48, 'rueda genérica Ø200 × 50\nnúcleo de 10 (referencia)', ha='center', fontsize=8)
rr(ax, 0, 20, 0, 260, CF, 0.45, z=1); rr(ax, 0, 20, 240, 260, CF, 0.7, z=1); rr(ax, 0, 20, 0, 20, CF, 0.7, z=1)
ax.text(3, 130, 'poste', fontsize=8)
# F2
poly(ax, [(-6, -6), (20, -6), (20, 0), (0, 0), (0, 220), (-6, 220)], CF, 0.9)
rr(ax, -51, -6, 154, 166, CF, 0.9)
poly(ax, [(-6, 204), (-40, 204), L2G(-14, 14), (-6, 216 + 0)], CF, 0.9)
ax.text(-30, 140, 'F2', fontsize=10, weight='bold')
# K1 mangueta
rr(ax, -73, -63, 31, 200, CK); rr(ax, -63, yax(175) + 10, 170, 180, CK); rr(ax, -63, yax(195) + 9, 190, 200, CK)
rr(ax, -73, -53, 31, 51, CK)
ax.text(-88, 118, 'K1\nmangueta', fontsize=9, weight='bold', ha='right')
# bujes, arandelas, K2, K3
cyl = lambda u0, u1, d: lrect(-d / 2, d / 2, u0, u1)
poly(ax, [(yax(171) - 6 / c_, 171), (yax(179) - 6 / c_, 179), (yax(179) + 6 / c_, 179), (yax(171) + 6 / c_, 171)], CB, 0.85)
poly(ax, cyl(*ST['buje'], 12), CB, 0.85)
poly(ax, [(yax(166) - 8 / c_, 166), (yax(170) - 8 / c_, 170), (yax(170) + 8 / c_, 170), (yax(166) + 8 / c_, 166)], CA, 0.9)
poly(ax, cyl(*ST['arandela'], 16), CA, 0.9)
poly(ax, [(yax(150) - 6 / c_, 150), (yax(154) - 6 / c_, 154), (yax(154) + 6 / c_, 154), (yax(150) + 6 / c_, 150)], CG, 0.9)
poly(ax, [(yax(150) - 4 / c_, 150), (yax(183) - 4 / c_, 183), (yax(183) + 4 / c_, 183), (yax(150) + 4 / c_, 150)], CG, 0.9)
poly(ax, cyl(*ST['k3'], 8), CG, 0.95, z=3)
# separadores, placa K7, K4, horn, servo
for v in (-17, 17):
    pass
poly(ax, cyl(*ST['k4'], 24), CK, 0.8, z=3)
poly(ax, cyl(*ST['horn'], 24), '#999999', 0.9, z=3)
poly(ax, lrect(-16, 16, *ST['placa']), CP, 0.35, z=2)
poly(ax, lrect(-10, 10, *ST['servo']), CS, 0.45)
ax.text(*L2G(14, 52), 'servo RDS3225\n(invertido)', fontsize=8)
ax.text(*L2G(26, 27), 'K7 placa', fontsize=8)
ax.text(*L2G(-46, 20), 'K4 + horn', fontsize=8)
ax.text(yax(150) + 10, 145, 'K2', fontsize=8); ax.text(*L2G(6, -8), 'K3', fontsize=8)
# cubo delantero: espiga fija K5, cubo-brida K6 con dos 688, tuerca
rr(ax, -73, -53, 37, 45, CG, 0.95, z=3)
rr(ax, -89, -73, 35, 47, CG, 0.95, z=3)
rr(ax, -113, -89, 37, 45, CG, 0.95, z=3)
rr(ax, -95, -89, 13, 69, CA, 0.85); rr(ax, -105, -95, 28.5, 53.5, CA, 0.85)
rr(ax, -95, -90, 33, 49, CB, 0.9, z=4); rr(ax, -105, -100, 33, 49, CB, 0.9, z=4)
rr(ax, -113, -105, 34.5, 47.5, CG, 0.9)
ax.text(-138, 80, 'K5 espiga fija Ø8\nK6 cubo-brida con 2 × 688\n(ver CUBO_DELANTERO_DETALLE)', fontsize=8)
# eje y flujo
ax.plot([yax(-59), yax(285)], [-59, 285], 'k-.', lw=0.8)
ax.text(yax(282) + 3, 282, 'eje del pivote (KPI 15.1°)', fontsize=8)
ax.plot(-100, -59, 'o', color='k'); ax.text(-97, -70, 'centro de la huella (e = 0)', fontsize=8)
pasos = [L2G(0, 50), L2G(0, 27.5), L2G(0, 21), L2G(0, -5), (-68, 160), (-68, 60), (-100, 41)]
for i in range(len(pasos) - 1):
    ax.annotate('', xy=pasos[i + 1], xytext=pasos[i], arrowprops=dict(arrowstyle='->', color='#d9534f', lw=1.6), zorder=10)
ax.text(40, 275, 'Transmisión del giro (flechas rojas):\n1. el cuerpo del servo está fijo a la placa K7, que se apoya en dos\n'
        '    separadores sobre el brazo superior de F2\n2. el horn del servo mueve el acople K4 (4 × M3)\n'
        '3. K4 mueve el eje K3 (pasador elástico Ø3)\n4. K3 mueve la mangueta K1 (otro pasador Ø3)\n'
        '5. K1 gira sobre K2 (abajo) y sobre el buje de F2 (arriba)\n6. la espiga K5 está fija en K1; la rueda gira sobre ella\n'
        '    con el cubo-brida K6 (dos 688) y K1 la orienta', fontsize=8.5, va='top')
ax.text(40, 140, 'Cargas: la rueda empuja K1 hacia arriba y la arandela superior\nla apoya contra el brazo superior de F2. Los bujes toman las\n'
        'cargas radiales; el servo solo transmite par.', fontsize=8.5, va='top')
ax.set_aspect('equal'); ax.set_xlim(-145, 250); ax.set_ylim(-80, 300); ax.grid(alpha=.15)
ax.set_xlabel('y [mm] (negativo hacia afuera)'); ax.set_ylabel('z [mm]')
ax.set_title('Conjunto del pivote delantero izquierdo, corte en x = 490 (el derecho es simétrico)', fontsize=11)
plt.tight_layout(); plt.savefig('PIVOTE_CONJUNTO.png', dpi=140); plt.close()

# ======================= DETALLE DEL SERVO (sistema del eje) =======================
fig, axs = plt.subplots(1, 2, figsize=(16, 9.5), gridspec_kw={'width_ratios': [1.25, 1]})
a = axs[0]
rr(a, -10, 10, -10, 0, CK, 0.5); a.text(-62, -6, 'K1 (brazo sup.)', fontsize=8)
rr(a, -8, 8, 0, 2, CA, 0.9); a.text(13, 0.3, 'arandela 8.2 × 16 × 2', fontsize=7.5)
rr(a, -22, 22, 2, 14, CF, 0.9); a.text(-62, 7, 'F2 brazo sup.', fontsize=8)
rr(a, -6, -4, 4, 12, CB, 0.9); rr(a, 4, 6, 4, 12, CB, 0.9); a.text(16, 8.5, 'buje 8 × 12 × 8', fontsize=7.5)
for v in (-17, 17):
    rr(a, v - 3.5, v + 3.5, 14, 26, '#c9c9c9', 0.9)
a.text(19, 18, 'separador M4\nF-F × 12 (2)', fontsize=7.5)
rr(a, -12, 12, 16, 26, CK, 0.7); a.text(-62, 20, 'K4 Ø24 × 10', fontsize=8)
rr(a, -32, 22, 26, 29, CP, 0.4); rr(a, -12, 12, 26, 29, '#999999', 0.9)
a.text(24, 27, 'K7 placa 3 mm (agujero Ø26)', fontsize=7.5); a.text(-62, 27, 'horn Ø24 × 3', fontsize=8)
rr(a, -30, 10, 29, 69.5, CS, 0.4); a.text(-26, 50, 'servo (40 × 20 × 40.5)', fontsize=8)
rr(a, -4, 4, -10, 26, CG, 0.95, z=3); a.text(-2.5, -18, 'K3 Ø8', fontsize=8)
for u in (-5, 21):
    a.plot([-7, 7], [u, u], 'k', lw=1.4, zorder=5)
a.text(20, -6, 'pasadores elásticos Ø3', fontsize=7.5)
a.plot([0, 0], [-16, 76], 'k-.', lw=0.6)
vdim(a, -10, 0, -80, '10'); vdim(a, 0, 2, -80, '2'); vdim(a, 2, 14, -80, '12'); vdim(a, 14, 26, -80, '12')
vdim(a, 26, 29, -80, '3'); vdim(a, 29, 69.5, -80, '40.5'); vdim(a, -10, 26, -88, '36 (K3)', left=True)
hdim(a, -32, 22, 74, '54 (K7)'); hdim(a, -30, 10, 32, '40 (servo)', fs=7.5); hdim(a, -22, 22, -24, '44 (brazo de F2)', fs=7.5); hdim(a, -17, 17, -34, '34 (separadores)', fs=7.5)
a.text(-100, -42, 'Eje del pivote vertical en esta vista (en el robot está inclinado 15.1°).\n'
       'La cara superior del brazo de F2 y la placa K7 son perpendiculares al eje.\n'
       'El brazo superior de F2 se ensancha a 44 mm en x para recibir los separadores.', fontsize=8, va='top')
a.set_aspect('equal'); a.set_xlim(-112, 80); a.set_ylim(-60, 84); a.axis('off')
a.set_title('Corte en el plano que contiene el eje del pivote y la dirección x', fontsize=10)
b = axs[1]  # vista desde arriba (perpendicular al eje)
rr(b, -30, 10, -10, 10, CS, 0.3)
b.add_patch(Circle((0, 0), 12, fc='#999999', ec='k', lw=0.8, alpha=0.7))
b.add_patch(Circle((0, 0), 4, fc=CG, ec='k', lw=0.6))
poly(b, [(-32, -16), (22, -16), (22, 16), (-32, 16)], CP, 0.2, ls='-')
b.add_patch(Circle((0, 0), 13, fc='none', ec='k', lw=0.6, ls='--'))
for x in (-17, 17):
    b.add_patch(Circle((x, 0), 2.25, fc='white', ec='k', lw=0.6))
rr(b, -22, 22, 20, 26, CF, 0.5)
b.text(-30, 29, 'brazo superior de F2 (44 de ancho en x), debajo', fontsize=7.5)
hdim(b, -32, 22, -24, '54'); vdim(b, -16, 16, 26, '32'); hdim(b, -30, 10, 14, '40 (servo)', fs=7.5); hdim(b, 0, 10, -14, '10', fs=7.5)
b.text(-34, -40, 'Cuerpo del servo: 40 × 20 (hoja de datos); salida a 10 mm de un extremo\n'
       '(SUPOSICIÓN, medir). Agujeros de la carcasa a K7: plantilla del servo real.\n'
       'Agujero central Ø26 para el horn; 2 × Ø4.5 para los separadores a ±17.', fontsize=7.5, va='top')
b.set_aspect('equal'); b.set_xlim(-40, 45); b.set_ylim(-58, 42); b.axis('off'); b.set_title('Vista desde arriba del servo y la placa K7', fontsize=10)
fig.suptitle('Detalle del accionamiento de la dirección: el soporte en U del fabricante gira con la salida (horn y eje trasero), '
             'por eso no se usa como base;\nel servo se fija por su carcasa a la placa K7', fontsize=10)
plt.tight_layout(); plt.savefig('SERVO_DETALLE.png', dpi=140); plt.close()

# ======================= DETALLE DEL CUBO DELANTERO =======================
fig, ax = plt.subplots(figsize=(13, 7))
rr(ax, -125, -75, -10, 92, CW, 0.12, z=1); rr(ax, -105, -95, 16, 66, CW, 0.45, z=1)
ax.text(-123, 86, 'neumático (50)', fontsize=7.5); ax.text(-104, 70, 'núcleo 10', fontsize=7.5)
rr(ax, -73, -53, 25, 57, CK, 0.45); ax.text(-70, 59, 'K1 (alojamiento 20)', fontsize=8)
rr(ax, -73, -53, 37, 45, CG, 0.95, z=3); rr(ax, -89, -73, 35, 47, CG, 0.95, z=3); rr(ax, -113, -89, 37, 45, CG, 0.95, z=3)
rr(ax, -95, -89, 13, 69, CA, 0.75); rr(ax, -105, -95, 28.5, 53.5, CA, 0.75)
rr(ax, -95, -90, 33, 49, CB, 0.9, z=4); rr(ax, -105, -100, 33, 49, CB, 0.9, z=4)
rr(ax, -100, -95, 35, 47, '#c9c9c9', 0.9, z=4)
rr(ax, -107, -105, 33, 49, '#999999', 0.9); rr(ax, -113, -107, 34.5, 47.5, CG, 0.9)
for zz in (21, 61):
    rr(ax, -105, -89, zz - 2, zz + 2, '#777777', 0.9, z=5)
ax.text(-121, 3, '4 × M4 al núcleo (PCD 40)', fontsize=7.5)
ax.plot([-100, -100], [-10, 92], 'k-.', lw=0.5); ax.text(-99, -8, 'plano de la rueda', fontsize=7.5)
ax.plot([-73, -73], [-10, 92], 'k:', lw=0.6)
hdim(ax, -100, -73, 96, '27 (pivote a plano de rueda)')
hdim(ax, -73, -53, 74, '20'); hdim(ax, -89, -73, 74, '16'); hdim(ax, -95, -89, 74, '6'); hdim(ax, -105, -95, 74, '10'); hdim(ax, -113, -105, 74, '8')
vdim(ax, 37, 45, -48, 'Ø8')
ax.annotate('Ø12 (resalte)', xy=(-80, 47), xytext=(-84, 60), fontsize=8, arrowprops=dict(arrowstyle='-', lw=0.5))
ax.annotate('Ø56', xy=(-92, 69), xytext=(-118, 66), fontsize=8, arrowprops=dict(arrowstyle='-', lw=0.5))
ax.annotate('2 × 688-2RS', xy=(-102, 33), xytext=(-122, 12), fontsize=8, arrowprops=dict(arrowstyle='-', lw=0.5))
ax.text(-40, 88, 'K5 espiga fija Ø8 (AISI 1045): asiento a presión en K1, resalte Ø12 × 16 que hace de separador,\n'
        'tramo Ø8 h6 para dos rodamientos 688-2RS (8 × 16 × 5) y rosca M8 con arandela y tuerca autoblocante.\n'
        'K6 cubo-brida (6061-T6): disco Ø56 × 6 + centrador Ø25 g6 × 10; agujero Ø16 H7 con resalte interior\n'
        'de 5 mm entre los rodamientos; 4 × Ø4.5 en PCD 40. Gira con la rueda.\n'
        'Reemplaza las dos KFL08 y el eje giratorio.', fontsize=8, va='top')
ax.set_aspect('equal'); ax.set_xlim(-130, 70); ax.set_ylim(-14, 100); ax.grid(alpha=.15)
ax.set_xlabel('y [mm]'); ax.set_ylabel('z [mm]'); ax.set_title('Cubo de la rueda delantera izquierda (corte en el eje de la rueda)', fontsize=10)
plt.tight_layout(); plt.savefig('CUBO_DELANTERO_DETALLE.png', dpi=140); plt.close()

# ======================= K1 MANGUETA =======================
fig, axs = plt.subplots(1, 2, figsize=(14, 9), gridspec_kw={'width_ratios': [1.5, 0.7]})
a = axs[0]
yl, yu = yax(175) + 10, yax(195) + 9
pts = [(-73, 31), (-53, 31), (-53, 51), (-63, 51), (-63, 170), (yl, 170), (yl, 180), (-63, 180), (-63, 190), (yu, 190), (yu, 200), (-73, 200)]
poly(a, pts, CK, 0.5)
a.plot([yax(25), yax(215)], [25, 215], 'k-.', lw=0.6)
for zc, d, lbl in ((175, 12, 'Ø12 H7 (buje 8 × 12 × 8)'), (195, 8, 'Ø8 H7 (eje K3) + Ø3 transversal')):
    pp = [(yax(zc - 5) - d / 2 / c_, zc - 5), (yax(zc + 5) - d / 2 / c_, zc + 5), (yax(zc + 5) + d / 2 / c_, zc + 5), (yax(zc - 5) + d / 2 / c_, zc - 5)]
    a.plot([pp[0][0], pp[1][0]], [pp[0][1], pp[1][1]], 'k', lw=0.6); a.plot([pp[2][0], pp[3][0]], [pp[2][1], pp[3][1]], 'k', lw=0.6)
    a.text(yl + 18, zc - 2, lbl + ', eje a 15.1°', fontsize=7.5)
a.plot([-73, -53], [41, 41], 'k-.', lw=0.5); a.plot([-73, -53], [37, 37], 'k', lw=0.5); a.plot([-73, -53], [45, 45], 'k', lw=0.5)
a.text(-79, 18, 'Ø8 H7 pasante (espiga fija K5, a presión), paralelo a y', fontsize=7.5)
vdim(a, 31, 200, -95, '169'); vdim(a, 170, 180, 0, '10'); vdim(a, 190, 200, 0, '10'); vdim(a, 180, 190, 0, '10'); vdim(a, 31, 51, -88, '20')
hdim(a, -73, -53, 22, '20'); hdim(a, -73, -63, 208, '10'); hdim(a, -63, yl, 160, '%.1f' % (yl + 63)); hdim(a, -63, yu, 214, '%.1f' % (yu + 63))
a.text(-120, 41, 'eje de la rueda\nen z = 41', fontsize=7)
a.text(-80, 232, 'Coordenadas globales: montante en y = −73 a −63; brazos en z = 170 a 180 y 190 a 200;\n'
       'refrentar las caras de los brazos perpendiculares al eje (Ø18, 1 mm) para las arandelas de empuje.', fontsize=7.5)
a.set_aspect('equal'); a.set_xlim(-130, 45); a.set_ylim(10, 245); a.axis('off'); a.set_title('Vista lateral (y–z)', fontsize=9)
b = axs[1]
rr(b, 0, 20, 31, 200, CK, 0.5)
for z0, z1 in ((170, 180), (190, 200), (31, 51)):
    b.plot([0, 20], [z0, z0], 'k--', lw=0.4); b.plot([0, 20], [z1, z1], 'k--', lw=0.4)
b.add_patch(Circle((10, 41), 4, fc='white', ec='k', lw=0.6))
hdim(b, 0, 20, 205, '20'); b.text(-2, 20, 'Espesor en x: 20 (x = 480 a 500)', fontsize=7.5)
b.set_aspect('equal'); b.set_xlim(-10, 45); b.set_ylim(10, 220); b.axis('off'); b.set_title('Vista frontal (x–z)', fontsize=9)
fig.suptitle('K1 · Mangueta · 6061-T6 mecanizada de placa de 20 mm · 2 piezas (izquierda y derecha, simétricas)', fontsize=10)
plt.tight_layout(); plt.savefig('K1_mangueta.png', dpi=150); plt.close()

# ======================= K2 a K7 =======================
fig, axs = plt.subplots(3, 2, figsize=(15, 13))


def eje(ax, tramos, titulo, notas, ylim=(-42, 30)):
    x = 0
    for L, d, lbl in tramos:
        rr(ax, x, x + L, -d / 2, d / 2, '#9aa5b1', 0.6)
        hdim(ax, x, x + L, d / 2 + 3, '%g' % L)
        ax.text(x + L / 2, -d / 2 - 4, lbl, ha='center', va='top', fontsize=7.5)
        x += L
    hdim(ax, 0, x, max(d for _, d, _ in tramos) / 2 + 12, 'total %g' % x)
    ax.text(0, -24, notas, fontsize=7.5, va='top')
    ax.set_aspect('equal'); ax.set_xlim(-5, max(x + 10, 70)); ax.set_ylim(*ylim); ax.axis('off'); ax.set_title(titulo, fontsize=9)


eje(axs[0, 0], [(3, 12, 'cabeza Ø12'), (29, 8, 'Ø8 h6')], 'K2 · Pasador inferior del pivote · AISI 1045 · 2 piezas',
    'Ranura para anillo DIN 471-8 a 27 mm de la cabeza.\nEntra por debajo del brazo inferior de F2; la mangueta gira sobre él con un buje.')
eje(axs[0, 1], [(10, 8, 'en K1'), (2, 8, ''), (12, 8, 'buje de F2'), (2, 8, ''), (10, 8, 'en K4')], 'K3 · Eje del servo · AISI 1045, Ø8 h6 · 2 piezas',
    'Dos agujeros transversales Ø3 (pasadores elásticos ISO 8752 3 × 20):\na 5 mm del extremo inferior (K1) y a 5 mm del superior (K4).')
a = axs[1, 0]
rr(a, 0, 10, -12, 12, CK, 0.5); rr(a, 0, 10, -4, 4, 'white', 1)
a.plot([5, 5], [-12, 12], 'k--', lw=0.6)
hdim(a, 0, 10, 15, '10'); vdim(a, -12, 12, 13, 'Ø24'); vdim(a, -4, 4, -3, 'Ø8 H7', left=True)
a.add_patch(Circle((40, 0), 12, fc=CK, ec='k', lw=0.8, alpha=0.5)); a.add_patch(Circle((40, 0), 4, fc='white', ec='k', lw=0.6))
for ang in (45, 135, 225, 315):
    a.add_patch(Circle((40 + 7 * math.cos(math.radians(ang)), 7 * math.sin(math.radians(ang))), 1.6, fc='white', ec='k', lw=0.5))
a.text(55, 0, '4 × M3 a r = 7\n(plantilla del horn:\nSUPOSICIÓN, medir)', fontsize=7.5, va='center')
a.text(-2, -18, 'Agujero transversal Ø3 a 5 mm de la cara inferior (pasador de K3). Se atornilla al horn de aluminio del servo.', fontsize=7.5, va='top')
a.set_aspect('equal'); a.set_xlim(-12, 90); a.set_ylim(-26, 22); a.axis('off'); a.set_title('K4 · Acople servo-eje · 6061-T6 · 2 piezas', fontsize=9)
eje(axs[1, 1], [(20, 8, 'en K1 (H7/p6)'), (16, 12, 'resalte Ø12'), (16, 8, 'Ø8 h6: 2 × 688'), (8, 8, 'M8')],
    'K5 · Espiga fija de la rueda delantera · AISI 1045 · 2 piezas',
    'Fija en la mangueta; no gira. El resalte de 16 mm ubica el cubo K6 en el plano de la rueda.\nArandela Ø8 y tuerca M8 autoblocante aprietan los aros interiores de los 688.')
a = axs[2, 0]
rr(a, 0, 6, -28, 28, CA, 0.6); rr(a, 6, 16, -12.5, 12.5, CA, 0.6); rr(a, 0, 16, -8, 8, 'white', 1)
rr(a, 5, 10, -8, -6.5, CA, 0.9); rr(a, 5, 10, 6.5, 8, CA, 0.9)
rr(a, 0, 5, -8, 8, CB, 0.3); rr(a, 10, 15, -8, 8, CB, 0.3)
for zz in (-20, 20):
    rr(a, 0, 6, zz - 2.25, zz + 2.25, 'white', 1)
hdim(a, 0, 6, 31, '6'); hdim(a, 6, 16, 31, '10'); hdim(a, 0, 16, 38, '16')
vdim(a, -28, 28, -6, 'Ø56', left=True); vdim(a, -12.5, 12.5, 19, 'Ø25 g6'); vdim(a, -8, 8, 30, 'Ø16 H7 (688)')
a.text(-2, -34, 'Resalte interior Ø13 × 5 entre los rodamientos (azul). 4 × Ø4.5 en PCD 40 a 90°.\nEl centrador entra en el agujero Ø25 del núcleo; gira con la rueda.', fontsize=7.5, va='top')
a.set_aspect('equal'); a.set_xlim(-14, 75); a.set_ylim(-46, 44); a.axis('off'); a.set_title('K6 · Cubo-brida delantero · 6061-T6 · 2 piezas', fontsize=9)
a = axs[2, 1]
poly(a, [(-32, -16), (22, -16), (22, 16), (-32, 16)], CP, 0.35)
a.add_patch(Circle((0, 0), 13, fc='white', ec='k', lw=0.8))
for x in (-17, 17):
    a.add_patch(Circle((x, 0), 2.25, fc='white', ec='k', lw=0.6))
rr(a, -30, 10, -10, 10, CS, 0.12, ls='--')
hdim(a, -32, 22, 20, '54'); vdim(a, -16, 16, 25, '32'); hdim(a, -17, 17, -21, '34'); vdim(a, -13, 13, -35, 'Ø26', left=True)
a.text(-36, -32, 'Aluminio 6061-T6 de 3 mm. Contorno del servo en trazos.\nAgujeros de la carcasa del servo: plantilla del servo real.', fontsize=7.5, va='top')
a.set_aspect('equal'); a.set_xlim(-50, 45); a.set_ylim(-46, 32); a.axis('off'); a.set_title('K7 · Placa del servo · 6061-T6, 3 mm · 2 piezas', fontsize=9)
plt.tight_layout(); plt.savefig('K2_K7_piezas.png', dpi=150); plt.close()
print('ok')
