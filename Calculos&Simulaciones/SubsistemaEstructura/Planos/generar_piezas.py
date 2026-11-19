# Planos de las piezas propias de la estructura (504). Medidas en mm.
import math, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Circle, Polygon

C = '#1d9e75'


def hdim(ax, x1, x2, y, txt, ext_from=None):
    ax.annotate('', xy=(x1, y), xytext=(x2, y), arrowprops=dict(arrowstyle='<->', lw=0.7))
    ax.text((x1 + x2) / 2, y + 1.5, txt, ha='center', va='bottom', fontsize=8)
    if ext_from is not None:
        for x in (x1, x2):
            ax.plot([x, x], [ext_from, y], lw=0.4, color='0.4')


def vdim(ax, y1, y2, x, txt, ext_from=None):
    ax.annotate('', xy=(x, y1), xytext=(x, y2), arrowprops=dict(arrowstyle='<->', lw=0.7))
    ax.text(x + 1.5, (y1 + y2) / 2, txt, ha='left', va='center', fontsize=8)
    if ext_from is not None:
        for y in (y1, y2):
            ax.plot([ext_from, x], [y, y], lw=0.4, color='0.4')


def rect(ax, x, y, w, h, fc=C, alpha=0.35, ls='-'):
    ax.add_patch(Rectangle((x, y), w, h, fc=fc if ls == '-' else 'none', ec='k', lw=0.8, alpha=1, ls=ls))
    if ls == '-':
        ax.add_patch(Rectangle((x, y), w, h, fc=fc, ec='none', alpha=alpha))


def hole(ax, x, y, d):
    ax.add_patch(Circle((x, y), d / 2, fc='white', ec='k', lw=0.8))
    ax.plot([x - d * 0.7, x + d * 0.7], [y, y], lw=0.3, color='0.4', ls='-.')
    ax.plot([x, x], [y - d * 0.7, y + d * 0.7], lw=0.3, color='0.4', ls='-.')


def fin(ax, titulo, xl, yl):
    ax.set_title(titulo, fontsize=9); ax.set_aspect('equal'); ax.set_xlim(*xl); ax.set_ylim(*yl); ax.axis('off')


# ---------------- F1: soporte de motor en L ----------------
fig, axs = plt.subplots(1, 3, figsize=(15, 5.6), gridspec_kw={'width_ratios': [1.35, 1.35, 0.8]})
a = axs[0]  # vista frontal (cara de la brida), x-z
rect(a, 0, 0, 66, 50); a.plot([0, 66], [4, 4], 'k--', lw=0.5)
hole(a, 30, 21, 26)
for ang in (45, 135, 225, 315):
    hole(a, 30 + 17.5 * math.cos(math.radians(ang)), 21 + 17.5 * math.sin(math.radians(ang)), 4.5)
a.add_patch(Circle((30, 21), 17.5, fc='none', ec='0.5', lw=0.4, ls='-.'))
hdim(a, 0, 66, 58, '66', 50); vdim(a, 0, 50, 72, '50', 66)
hdim(a, 0, 30, -8, '30', 0); vdim(a, 0, 21, -12, '21', 0)
a.text(47, 41, 'Ø26 H7\n4 × Ø4.5 en Ø35\n(a 45°)', fontsize=7.5)
fin(a, 'Vista frontal (cara de la brida del motor)', (-22, 92), (-16, 66))
a = axs[1]  # vista superior, x-y
rect(a, 0, 0, 66, 24); rect(a, 0, 20, 66, 4, alpha=0.7)
for x in (10, 30, 50):
    hole(a, x, 10, 5.5)
hdim(a, 0, 66, 30, '66', 24); vdim(a, 0, 24, 72, '24', 66)
hdim(a, 0, 10, -6, '10', 0); hdim(a, 10, 30, -6, '20'); hdim(a, 30, 50, -6, '20')
vdim(a, 0, 10, -8, '10', 0)
a.text(0, -16, '3 × Ø5.5 (M5 a la ranura superior del larguero E1)', fontsize=7.5)
a.text(0, 26, 'ala vertical', fontsize=7)
fin(a, 'Vista superior (ala de apoyo)', (-14, 90), (-20, 40))
a = axs[2]  # vista lateral, y-z
a.add_patch(Polygon([(0, 0), (24, 0), (24, 50), (20, 50), (20, 4), (0, 4)], fc=C, ec='k', lw=0.8, alpha=0.5))
hdim(a, 0, 24, 56, '24', 50); vdim(a, 0, 50, 30, '50', 24); vdim(a, 0, 4, -6, '4', 0)
hdim(a, 20, 24, -6, '4', 0)
a.text(-4, -14, 'Radio interior R1', fontsize=7)
fin(a, 'Vista lateral', (-14, 44), (-18, 66))
fig.suptitle('F1 · Soporte de motor en L · 6061-T6, mecanizado de 4 mm · 2 piezas (izquierda y derecha, simétricas)\n'
             'Montaje: ala de apoyo sobre el larguero inferior E1 en x = 20 a 86 mm; eje del motor en x = 50, z = 41', fontsize=10)
plt.tight_layout(); plt.savefig('F1_soporte_motor.png', dpi=150); plt.close()

# ---------------- F3: soporte de gabinete en L ----------------
fig, axs = plt.subplots(1, 3, figsize=(16, 6), gridspec_kw={'width_ratios': [1.6, 1.6, 0.8]})
a = axs[0]  # vista superior x-y
rect(a, 0, 0, 250, 123); rect(a, 0, 120, 250, 3, alpha=0.7)
for x in (25, 125, 225):
    hole(a, x, 10, 5.5)
rect(a, 0, 20, 250, 100, ls='--')
a.text(150, 70, 'apoyo del Cubo S\n(250 × 100)', fontsize=7.5, ha='center')
hdim(a, 0, 250, 132, '250', 123); vdim(a, 0, 123, 258, '123', 250)
hdim(a, 0, 25, -10, '25', 0); hdim(a, 25, 125, -10, '100'); hdim(a, 125, 225, -10, '100')
vdim(a, 0, 10, -12, '10', 0); a.text(0, -38, '3 × Ø5.5 al larguero E1 (y = 10). La base apoya sin tornillos sobre el travesaño de batería E3 (x = 150 global)', fontsize=7.5)
fin(a, 'Vista superior (base)', (-22, 285), (-44, 150))
a = axs[1]  # vista frontal x-z (pared)
rect(a, 0, 0, 250, 178); rect(a, 0, 0, 250, 3, alpha=0.7)
rect(a, 0, 3, 250, 175, ls='--')
a.text(125, 90, 'Agujeros de fijación del Cubo S\nsegún la plantilla de Ensto (pendiente)', fontsize=8, ha='center')
hdim(a, 0, 250, 186, '250', 178); vdim(a, 0, 178, 258, '178', 250)
fin(a, 'Vista desde el interior (pared)', (-10, 285), (-10, 200))
a = axs[2]  # vista lateral y-z
a.add_patch(Polygon([(0, 0), (123, 0), (123, 178), (120, 178), (120, 3), (0, 3)], fc=C, ec='k', lw=0.8, alpha=0.5))
hdim(a, 0, 123, 186, '123', 178); vdim(a, 0, 178, 130, '178', 123); vdim(a, 0, 3, -8, '3', 0)
a.text(30, 20, 'Plegado a 90°\nradio interior 6 (2t)', fontsize=7.5)
fin(a, 'Vista lateral', (-20, 165), (-10, 200))
fig.suptitle('F3 · Soporte de gabinete en L · 5052-H32, chapa de 3 mm plegada · 2 piezas (izquierda y derecha, simétricas)\n'
             'Montaje: base sobre el larguero inferior E1 y el travesaño de batería en x = 90 a 340 mm; pared en y = 120 a 123', fontsize=10)
plt.tight_layout(); plt.savefig('F3_soporte_gabinete.png', dpi=150); plt.close()

# ---------------- F4: placa base de bateria ----------------
fig, a = plt.subplots(figsize=(10, 6.5))
rect(a, 0, 0, 230, 140)
for x in (15, 215):
    for y in (30, 110):
        hole(a, x, y, 5.5)
rect(a, 15, 10, 200, 120, ls='--')
a.text(115, 70, 'Cubo D (200 × 120)\nagujeros de fijación según la plantilla\nde Ensto (pendiente)', fontsize=8, ha='center')
hdim(a, 0, 230, 150, '230', 140); vdim(a, 0, 140, 240, '140', 230)
hdim(a, 0, 15, -10, '15', 0); hdim(a, 15, 215, -10, '200'); vdim(a, 0, 30, -12, '30', 0); vdim(a, 30, 110, -12, '80')
a.text(0, -26, '4 × Ø5.5 avellanados a 90° para M5 de cabeza avellanada (ISO 10642), a las ranuras de E3 (x = 150 y 350 globales):\nquedan bajo el gabinete, por eso van avellanados', fontsize=8)
fin(a, 'F4 · Placa base de batería · 5052-H32, 4 mm · 1 pieza\nMontaje: x = 135 a 365, y = 130 a 270, sobre los travesaños de batería', (-25, 265), (-40, 165))
plt.tight_layout(); plt.savefig('F4_placa_bateria.png', dpi=150); plt.close()
print('ok')

# ---------------- F2: soporte del pivote en el poste ----------------
t15 = math.tan(math.radians(15.1))
fig, axs = plt.subplots(1, 3, figsize=(16, 9), gridspec_kw={'width_ratios': [1.3, 0.9, 0.9]})
a = axs[0]  # vista lateral (y-z); y negativo hacia la izquierda (afuera)
a.add_patch(Polygon([(-6, -6), (20, -6), (20, 0), (0, 0), (0, 220), (-6, 220)], fc=C, ec='k', lw=0.8, alpha=0.5))
a.add_patch(Rectangle((-51, 154), 45, 12, fc=C, ec='k', lw=0.8, alpha=0.5))
a.add_patch(Rectangle((-40, 204), 34, 12, fc=C, ec='k', lw=0.8, alpha=0.5))
a.add_patch(Rectangle((0, 0), 20, 230, fc='0.85', ec='0.5', lw=0.5, ls='--'))
a.text(3, 120, 'poste\n(referencia)', fontsize=7, color='0.4')
yb = lambda z: -100 + (z + 59) * t15
a.plot([yb(140), yb(232)], [140, 232], 'k-.', lw=0.6)
for zc, d in ((160, 8), (210, 12)):
    yc = yb(zc); dx = d / 2 / math.cos(math.radians(15.1))
    for k in (-1, 1):
        a.plot([yb(zc - 6) + k * dx, yb(zc + 6) + k * dx], [zc - 6, zc + 6], 'k-', lw=0.6)
hdim(a, -51, -6, 135, '45', 154); hdim(a, -40, -6, 232, '34', 216)
hdim(a, yb(160), -6, 120, '%.1f' % (-6 - yb(160)) + ' (en z = 160)')
hdim(a, yb(210), -6, 250, '%.1f' % (-6 - yb(210)) + ' (en z = 210)')
vdim(a, -6, 220, 32, '226', 20); vdim(a, 154, 166, -62, '12'); vdim(a, 204, 216, -62, '12')
vdim(a, -6, 160, -85, '166', -51); vdim(a, -6, 210, -110, '216', -40)
hdim(a, -6, 0, -18, '6'); hdim(a, 0, 20, -18, '20'); vdim(a, -6, 0, 26, '6')
a.text(-122, -72, 'Cotas 166 y 216: desde la cara inferior del labio a los ejes de los brazos.\nBrazo inferior: Ø8 H7 pasante (pasador fijo del pivote). Brazo superior: Ø12 H7 pasante (buje 8 × 12 × 8).\nAmbos ejes inclinados 15.1° (arriba hacia el poste).', fontsize=7.5)
a.text(-40, 268, 'Cara superior del brazo superior a 15°,\nperpendicular al eje: base del servo', fontsize=7.5)
fin(a, 'Vista lateral (y–z), lado izquierdo', (-125, 45), (-80, 290))
a = axs[1]  # vista frontal del alma (x-z) desde afuera
rect(a, 0, -6, 28, 226)
for z in (10, 60, 110, 180):
    hole(a, 14, z, 5.5)
a.add_patch(Rectangle((0, 154), 28, 12, fc='none', ec='k', lw=0.6, ls='--'))
a.add_patch(Rectangle((-8, 204), 44, 12, fc='none', ec='k', lw=0.6, ls='--'))
hdim(a, 0, 28, 230, '28', 220); hdim(a, 0, 14, -20, '14', -6)
for z0, z1, tx in ((-6, 10, '16'), (10, 60, '50'), (60, 110, '50'), (110, 180, '70')):
    vdim(a, z0, z1, 36, tx)
a.text(-2, -40, '4 × Ø5.5 para M5×12 (ISO 4762) con tuerca\nen T: tres al poste, una al larguero inferior', fontsize=7.5)
fin(a, 'Vista desde afuera (alma)', (-8, 60), (-50, 245))
a = axs[2]  # vista superior (x-y) de los brazos
a.add_patch(Rectangle((0, -51), 28, 45, fc=C, ec='k', lw=0.8, alpha=0.3))
a.add_patch(Rectangle((-8, -40), 44, 34, fc=C, ec='k', lw=0.8, alpha=0.5))
a.add_patch(Rectangle((0, -6), 28, 26, fc=C, ec='k', lw=0.8, alpha=0.5))
hole(a, 14, yb(210), 12); hole(a, 14, yb(160), 8)
for xs_ in (-3, 31):
    hole(a, xs_, yb(210), 3.3)
hdim(a, -3, 31, -58, '34 (M4 de los separadores)')
a.text(38, -30, 'brazo superior\n44 de ancho', fontsize=7)
hdim(a, 0, 28, 26, '28', 20); vdim(a, -51, -6, -14, '45'); vdim(a, -6, 20, -14, '26 (alma + labio)')
a.text(-8, -70, 'Brazo superior: 44 de ancho en x, Ø12 H7 para el buje y 2 × M4 roscados\n(a ±17 del eje, perpendiculares a la cara a 15°) para los separadores de la placa K7.\nRefrentados Ø18 × 1 perpendiculares al eje en las caras que tocan la mangueta.', fontsize=7.5)
fin(a, 'Vista superior', (-30, 70), (-90, 40))
fig.suptitle('F2 · Soporte del pivote y del servo · 6061-T6 mecanizado · 2 piezas (izquierda y derecha, simétricas)\n'
             'Montaje: cara exterior del poste delantero (x = 476 a 504); el labio inferior apoya bajo el larguero inferior. '
             'Eje del pivote: pasa por el centro de la huella (y = −100, suelo) con KPI 15.1°', fontsize=10)
plt.tight_layout(); plt.savefig('F2_soporte_pivote.png', dpi=150); plt.close()
print('F2 ok')
