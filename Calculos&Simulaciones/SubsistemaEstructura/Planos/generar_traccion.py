# Conjunto de tracción trasera (lado izquierdo) y planos de T1 y T2. Medidas en mm.
# Corte en x = 50 (eje trasero). y negativo hacia afuera; z: 0 = cara inferior del bastidor.
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon, Circle, Rectangle

CK, CF, CM, CW, CB, CA = '#1d9e75', '#b8bec8', '#d9534f', '#6f6f6f', '#3c7fc4', '#e8b04b'


def rr(ax, y0, y1, z0, z1, fc, a=0.6, ls='-', lw=0.8, z=1):
    ax.add_patch(Polygon([(y0, z0), (y1, z0), (y1, z1), (y0, z1)], closed=True, fc=fc if ls == '-' else 'none',
                         ec='k', lw=lw, alpha=a if ls == '-' else 1, ls=ls, zorder=z))


def hdim(ax, x1, x2, y, txt):
    ax.annotate('', xy=(x1, y), xytext=(x2, y), arrowprops=dict(arrowstyle='<->', lw=0.7))
    ax.text((x1 + x2) / 2, y + 1.5, txt, ha='center', va='bottom', fontsize=8)


def vdim(ax, y1, y2, x, txt):
    ax.annotate('', xy=(x, y1), xytext=(x, y2), arrowprops=dict(arrowstyle='<->', lw=0.7))
    ax.text(x + 1.5, (y1 + y2) / 2, txt, ha='left', va='center', fontsize=8)


# ======================= CONJUNTO (corte y-z) =======================
fig, axs = plt.subplots(2, 1, figsize=(14, 15), gridspec_kw={'height_ratios': [1.15, 1]})
ax = axs[0]
ax.axhline(-59, color='k', lw=1)
rr(ax, -125, -75, -59, 141, CW, 0.15); rr(ax, -105, -95, 16, 66, CW, 0.45)
ax.text(-100, -50, 'rueda genérica Ø200 × 50\nnúcleo de 10 (referencia)', ha='center', fontsize=8)
rr(ax, -70, 60, -20, 0, '#3c7fc4', 0.35); ax.text(-40, -15, 'travesaño E5', fontsize=8)
rr(ax, 0, 20, 0, 20, CF, 0.9); ax.text(3, 8, 'E1', fontsize=8)
# F1
rr(ax, 0, 24, 20, 24, CK, 0.8); rr(ax, 20, 24, 24, 70, CK, 0.8); ax.text(26, 66, 'F1', fontsize=9, weight='bold')
# motor
rr(ax, 24, 77.5, 20, 62, CM, 0.45); rr(ax, 77.5, 144, 21, 61, CM, 0.3); rr(ax, 144, 149.5, 23, 59, '#8a2be2', 0.35)
rr(ax, 22, 24, 28, 54, CM, 0.6)
ax.text(85, 38, 'motorreductor 42PG-775-67\ncon encoder de fábrica\n(147.5 desde la punta del eje)', fontsize=8)
ax.text(140, 64, 'encoder', fontsize=7.5)
rr(ax, 2, 24, 37, 45, '#555555', 0.9)
# acople
rr(ax, -16, 14, 31, 51, CA, 0.8); ax.text(-14, 54, 'acople flexible\nØ20 × 30 (8–12)', fontsize=7.5)
# T1 soporte de rodamientos
rr(ax, -66, -2, 0, 4, CK, 0.8)
rr(ax, -26, -18, 4, 62, CK, 0.8); rr(ax, -66, -58, 4, 62, CK, 0.8)
rr(ax, -26, -18, 27, 55, CB, 0.85); rr(ax, -66, -58, 27, 55, CB, 0.85)
ax.text(-48, 66, 'T1', fontsize=9, weight='bold')
ax.text(-62, 72, '2 × 6001-2RS (12 × 28 × 8)', fontsize=7.5)
for yb in (-12, -52):
    rr(ax, yb - 2.75, yb + 2.75, -8, 4, '#555555', 0.9); rr(ax, yb - 4.25, yb + 4.25, 4, 9, '#555555', 0.9)
ax.text(-58, 11, 'M5', fontsize=7)
# semieje, cubo y tuerca
rr(ax, -113, -1, 35, 47, '#555555', 0.9, z=2)
rr(ax, -95, -89, 13, 69, CA, 0.85); rr(ax, -105, -95, 28.5, 53.5, CA, 0.85); ax.text(-120, 74, 'brida trasera\n(chaveta) y 4 × M4', fontsize=8)
rr(ax, -113, -105, 33, 49, '#555555', 0.9)
ax.text(-140, 20, 'T2 semieje Ø12', fontsize=8, ha='left')
# flujo del par
pts = [(110, 41), (13, 41), (-8, 41), (-40, 41), (-100, 41), (-100, 0)]
for i in range(len(pts) - 1):
    ax.annotate('', xy=pts[i + 1], xytext=pts[i], arrowprops=dict(arrowstyle='->', color='#d9534f', lw=1.8), zorder=10)
ax.text(30, 128, 'Transmisión (flechas rojas):\n1. el motorreductor, fijo a F1 por su brida (4 × M4), gira su eje Ø8 en D\n'
        '2. el acople flexible pasa el par al semieje T2 y absorbe la desalineación\n3. T2 gira en dos rodamientos 6001 del soporte T1, fijo al travesaño E5\n'
        '4. la brida de arrastre (chaveta 4 × 4) mueve la rueda por 4 × M4\nLa carga de la rueda la toman T1 y E5; el eje del motor solo recibe par.', fontsize=8.5, va='top')
ax.plot([-100, -100], [-59, 141], 'k-.', lw=0.5)
ax.set_aspect('equal'); ax.set_xlim(-150, 230); ax.set_ylim(-70, 145); ax.grid(alpha=.15)
ax.set_xlabel('y [mm] (negativo hacia afuera)'); ax.set_ylabel('z [mm]')
ax.set_title('Tracción trasera izquierda: corte en x = 50 (eje trasero); el lado derecho es simétrico', fontsize=11)
# ======================= PLANTA de la esquina =======================
ax = axs[1]
rr(ax, 0, 160, 0, 20, CF, 0.8); rr(ax, 0, 20, 0, 160, CF, 0.8)    # aquí: eje horizontal = x, vertical = y (invertido abajo)
rr(ax, 40, 60, -70, 160, '#3c7fc4', 0.35)
rr(ax, 20, 86, 0, 24, CK, 0.8); rr(ax, 20, 86, 20, 24, CK, 0.95)
rr(ax, 29, 71, 24, 149.5, CM, 0.4)
rr(ax, 40, 60, -16, 14, CA, 0.8)
rr(ax, 30, 70, -66, -2, CK, 0.5); rr(ax, 30, 70, -26, -18, CK, 0.8); rr(ax, 30, 70, -66, -58, CK, 0.8)
rr(ax, 44, 56, -113, -1, '#555555', 0.9)
rr(ax, -50, 150, -125, -75, CW, 0.2); rr(ax, 22, 78, -95, -89, CA, 0.8); rr(ax, 37.5, 62.5, -105, -95, CA, 0.8)
rr(ax, 90, 160, 20, 120, '#e8b04b', 0.25); ax.text(110, 70, 'gabinete', fontsize=8)
for yb in (-12, -52):
    ax.add_patch(Circle((50, yb), 2.75, fc='white', ec='k', lw=0.6, zorder=5))
for t, x, y in (('E1', 100, 6), ('E3 trasero', 2, 140), ('E5', 61, 140), ('F1', 75, 28), ('motor 42PG', 33, 100), ('acople', 62, 0),
                ('T1', 72, -40), ('T2', 58, -120), ('brida', 80, -92), ('rueda', -40, -100)):
    ax.text(x, y, t, fontsize=8)
ax.set_aspect('equal'); ax.set_xlim(-60, 170); ax.set_ylim(150, -145); ax.grid(alpha=.15)
ax.set_xlabel('x [mm]'); ax.set_ylabel('y [mm] (negativo hacia afuera)')
ax.set_title('Planta de la esquina trasera izquierda', fontsize=11)
plt.tight_layout(); plt.savefig('TRACCION_CONJUNTO.png', dpi=140); plt.close()

# ======================= T1 soporte de rodamientos =======================
fig, axs = plt.subplots(1, 3, figsize=(16, 6), gridspec_kw={'width_ratios': [1.3, 1, 1]})
a = axs[0]  # lateral y-z (coordenadas locales: y' = -y - 10)
rr(a, 0, 64, 0, 4, CK, 0.5); rr(a, 16, 24, 4, 62, CK, 0.5); rr(a, 56, 64, 4, 62, CK, 0.5)
for y0 in (16, 56):
    a.plot([y0, y0 + 8], [27, 27], 'k--', lw=0.5); a.plot([y0, y0 + 8], [55, 55], 'k--', lw=0.5)
for yb in (10, 50):
    a.plot([yb - 2.75, yb - 2.75], [0, 4], 'k', lw=0.5); a.plot([yb + 2.75, yb + 2.75], [0, 4], 'k', lw=0.5)
hdim(a, 0, 64, 70, '64'); hdim(a, 16, 24, 64, '8'); hdim(a, 56, 64, 64, '8'); hdim(a, 0, 16, -8, '16'); hdim(a, 24, 56, -8, '32')
hdim(a, 0, 10, -16, '10'); hdim(a, 10, 50, -16, '40')
vdim(a, 0, 62, 68, '62'); vdim(a, 0, 4, -6, '4'); vdim(a, 0, 41, 26, '41 (eje)')
a.text(0, -28, 'Ø28 H7 en cada pared (6001-2RS), con anillo DIN 472 por fuera.\n2 × Ø5.5 a E5 (ranura superior), a 10 y 50 mm del borde interior (y = −12 y −52 globales).', fontsize=7.5)
a.set_aspect('equal'); a.set_xlim(-12, 88); a.set_ylim(-36, 80); a.axis('off'); a.set_title('Vista lateral (borde interior a la izquierda)', fontsize=9)
a = axs[1]  # frontal x-z de una pared
rr(a, 0, 40, 0, 4, CK, 0.3); rr(a, 0, 40, 4, 62, CK, 0.5)
a.add_patch(Circle((20, 41), 14, fc='white', ec='k', lw=0.8))
hdim(a, 0, 40, 66, '40'); vdim(a, 27, 55, 44, 'Ø28 H7'); vdim(a, 0, 41, -6, '41')
a.set_aspect('equal'); a.set_xlim(-12, 60); a.set_ylim(-10, 75); a.axis('off'); a.set_title('Vista de una pared (x–z)', fontsize=9)
a = axs[2]  # superior x-y
rr(a, 0, 40, 0, 64, CK, 0.3); rr(a, 0, 40, 16, 24, CK, 0.6); rr(a, 0, 40, 56, 64, CK, 0.6)
for yb in (10, 50):
    a.add_patch(Circle((20, yb), 2.75, fc='white', ec='k', lw=0.6))
hdim(a, 0, 40, 68, '40'); vdim(a, 0, 64, 44, '64'); hdim(a, 0, 20, -6, '20')
a.set_aspect('equal'); a.set_xlim(-10, 60); a.set_ylim(-14, 76); a.axis('off'); a.set_title('Vista superior', fontsize=9)
fig.suptitle('T1 · Soporte de rodamientos del semieje · 6061-T6 mecanizado · 2 piezas (izquierda y derecha)\n'
             'Montaje: sobre la cara superior del travesaño E5, x = 30 a 70, y = −2 a −66 (lado izquierdo)', fontsize=10)
plt.tight_layout(); plt.savefig('T1_soporte_rodamientos.png', dpi=150); plt.close()

# ======================= T2 semieje y T3 cubo =======================
fig, axs = plt.subplots(2, 1, figsize=(14, 8))
a = axs[0]
x = 0
for L, d, lbl in ((15, 12, 'acople'), (2, 12, ''), (8, 12, '6001'), (32, 12, ''), (8, 12, '6001'), (23, 12, ''),
                  (16, 12, 'brida (chavetero 4 × 2.5 × 16)'), (8, 12, 'M12 × 1.25')):
    rr(a, x, x + L, -d / 2, d / 2, '#9aa5b1', 0.6)
    if L >= 6:
        hdim(a, x, x + L, d / 2 + 3, '%g' % L)
    a.text(x + L / 2, -d / 2 - 4, lbl, ha='center', va='top', fontsize=7.5)
    x += L
hdim(a, 0, x, 18, 'total %g' % x)
a.text(0, -22, 'Ø12 h6 en todo el largo (k6 en los asientos de los rodamientos). Ranuras para anillos DIN 471-12 por fuera de cada rodamiento.\n'
       'Rosca M12 × 1.25 y tuerca autoblocante para retener la brida (queda dentro del agujero Ø25 del núcleo). Material: AISI 1045.', fontsize=7.5, va='top')
a.set_aspect('equal'); a.set_xlim(-5, 125); a.set_ylim(-34, 26); a.axis('off'); a.set_title('T2 · Semieje trasero · AISI 1045 · 2 piezas', fontsize=9)
plt.tight_layout(); plt.savefig('T2_semieje.png', dpi=150); plt.close()

# ======================= Bridas de rueda (trasera y delantera) =======================
fig, axs = plt.subplots(1, 2, figsize=(13, 6.5))
a = axs[0]  # corte axial
rr(a, 0, 6, -28, 28, '#e8b04b', 0.6); rr(a, 6, 16, -12.5, 12.5, '#e8b04b', 0.6); rr(a, 0, 16, -6, 6, 'white', 1)
for zz in (-20, 20):
    rr(a, 0, 6, zz - 2.25, zz + 2.25, 'white', 1)
hdim(a, 0, 6, 31, '6'); hdim(a, 6, 16, 31, '10'); hdim(a, 0, 16, 38, '16')
vdim(a, -28, 28, -8, 'Ø56'); vdim(a, -12.5, 12.5, 19, 'Ø25 g6')
a.annotate('agujero Ø12 H7\ncon chavetero 4 × 1.8', xy=(11, -4), xytext=(24, -24), fontsize=7.5, arrowprops=dict(arrowstyle='-', lw=0.5))
a.text(-6, -40, 'El centrador Ø25 × 10 entra en el agujero del núcleo de la rueda;\nel disco apoya en la cara del núcleo.', fontsize=7.5, va='top')
a.set_aspect('equal'); a.set_xlim(-14, 60); a.set_ylim(-52, 44); a.axis('off'); a.set_title('Corte axial', fontsize=9)
a = axs[1]  # vista frontal
a.add_patch(Circle((0, 0), 28, fc='#e8b04b', ec='k', lw=0.8, alpha=0.6))
a.add_patch(Circle((0, 0), 20, fc='none', ec='0.4', lw=0.5, ls='-.'))
a.add_patch(Circle((0, 0), 6, fc='white', ec='k', lw=0.8))
for ang in (0, 90, 180, 270):
    import math as _m
    a.add_patch(Circle((20 * _m.cos(_m.radians(ang)), 20 * _m.sin(_m.radians(ang))), 2.25, fc='white', ec='k', lw=0.6))
a.add_patch(Rectangle((-2, 5), 4, 2.5, fc='white', ec='k', lw=0.6))
hdim(a, -20, 20, 33, 'PCD 40'); a.text(31, 0, '4 × Ø4.5 a 90°\n(M4 de la rueda)', fontsize=7.5, va='center')
a.set_aspect('equal'); a.set_xlim(-34, 62); a.set_ylim(-36, 42); a.axis('off'); a.set_title('Vista frontal (versión trasera, con chavetero)', fontsize=9)
fig.suptitle('T3 · Brida de rueda trasera · 6061-T6 · 2 piezas\nAgujero Ø12 H7 con chavetero 4 × 1.8, chaveta 4 × 4 × 16. '
             'La delantera es el cubo-brida K6 (con dos 688), ver K2_K7_piezas', fontsize=10)
plt.tight_layout(); plt.savefig('BRIDAS_rueda.png', dpi=150); plt.close()
print('ok')
