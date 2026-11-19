# Ensamble de la estructura (504): BOM y vistas. Coordenadas en mm.
# x: 0 = cara trasera -> 500 delante; y: 0 = lado izquierdo -> 400; z: 0 = cara inferior del bastidor.
import csv, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

G = {'perfil': '#8a93a3', 'eje': '#3c7fc4', 'propia': '#1d9e75', 'ref': '#e8b04b', 'ref2': '#d9534f', 'rueda': '#555555'}
M = []  # (id, x0, x1, y0, y1, z0, z1, grupo, alpha)


def add(i, x0, x1, y0, y1, z0, z1, g, a=1.0):
    M.append((i, x0, x1, y0, y1, z0, z1, g, a))


# E1 largueros exteriores 500 (inferiores y superiores)
for z0 in (0, 240):
    for y0 in (0, 380):
        add('E1', 0, 500, y0, y0 + 20, z0, z0 + 20, 'perfil')
# E2 postes 220
for x0 in (0, 480):
    for y0 in (0, 380):
        add('E2', x0, x0 + 20, y0, y0 + 20, 20, 240, 'perfil')
# E3 travesanos 360: extremos sup./inf. y dos de la bateria
for z0 in (0, 240):
    for x0 in (0, 480):
        add('E3', x0, x0 + 20, 20, 380, z0, z0 + 20, 'perfil')
for x0 in (140, 340):
    add('E3', x0, x0 + 20, 20, 380, 0, 20, 'perfil')
# E4 largueros de elevacion 460 (planos medios de la base en y = 80.5 y 319.5)
for yc in (80.5, 319.5):
    add('E4', 20, 480, yc - 10, yc + 10, 240, 260, 'perfil')
# E5 / E6 travesanos de eje, bajo los largueros inferiores
add('E5', 40, 60, -70, 470, -20, 0, 'eje')
# F1 soportes de motor en L (izq. y der.)
add('F1', 20, 86, 0, 24, 20, 24, 'propia'); add('F1', 20, 86, 20, 24, 24, 70, 'propia')
add('F1', 20, 86, 376, 400, 20, 24, 'propia'); add('F1', 20, 86, 376, 380, 24, 70, 'propia')
# F2 soportes del pivote en la cara exterior de los postes delanteros (alma, labio, brazo inferior y superior)
for sg, y0 in ((1, 0), (-1, 400)):
    def yy(a, b):
        return (y0 + sg * a, y0 + sg * b) if sg == 1 else (y0 + sg * b, y0 + sg * a)
    add('F2', 476, 504, *yy(-6, 0), -6, 220, 'propia'); add('F2', 476, 504, *yy(0, 20), -6, 0, 'propia')
    add('F2', 476, 504, *yy(-51, -6), 154, 166, 'propia'); add('F2', 476, 504, *yy(-40, -6), 204, 216, 'propia')
    add('R', 470, 510, *yy(-37, -17), 216, 257, 'ref2', 0.35)
# F3 soportes de gabinete en L
add('F3', 90, 340, 0, 123, 20, 23, 'propia'); add('F3', 90, 340, 120, 123, 23, 198, 'propia', 0.55)
add('F3', 90, 340, 277, 400, 20, 23, 'propia'); add('F3', 90, 340, 277, 280, 23, 198, 'propia', 0.55)
# F4 placa base de la bateria
add('F4', 135, 365, 130, 270, 20, 24, 'propia')
# Referencias (no son de la estructura)
add('R', 90, 340, 20, 120, 23, 198, 'ref', 0.25); add('R', 90, 340, 280, 380, 23, 198, 'ref', 0.25)
add('R', 150, 350, 140, 260, 24, 110, 'ref', 0.25)
add('R', 29, 71, 24, 149.5, 20, 62, 'ref2', 0.35); add('R', 29, 71, 250.5, 376, 20, 62, 'ref2', 0.35)  # 147.5 mm con eje y encoder
for xc, w in ((50, 50), (490, 50)):
    for yc in (-100, 500):
        add('W', xc - 100, xc + 100, yc - w / 2, yc + w / 2, -59, 141, 'rueda', 0.12)


def caras(x0, x1, y0, y1, z0, z1):
    v = [(x0, y0, z0), (x1, y0, z0), (x1, y1, z0), (x0, y1, z0), (x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)]
    f = [[0, 1, 2, 3], [4, 5, 6, 7], [0, 1, 5, 4], [2, 3, 7, 6], [1, 2, 6, 5], [0, 3, 7, 4]]
    return [[v[i] for i in q] for q in f]


fig = plt.figure(figsize=(13, 10)); ax = fig.add_subplot(111, projection='3d')
for i, x0, x1, y0, y1, z0, z1, g, a in M:
    ax.add_collection3d(Poly3DCollection(caras(x0, x1, y0, y1, z0, z1), facecolor=G[g],
                                         edgecolor='k' if (a == 1 or g == 'propia') else 'none', linewidths=0.3, alpha=a))
for t, x, y, z in [('E1', 250, -30, 275), ('E2', -15, -25, 130), ('E3', 10, 200, 275), ('E4', 250, 80, 285),
                   ('E5', 50, -95, -30), ('F1', 50, -20, 85), ('F2', 490, -70, 230),
                   ('F3', 215, -10, 215), ('F4', 250, 200, 35)]:
    ax.text(x, y, z, t, fontsize=11, weight='bold', color='k')
ax.set_xlim(-80, 620); ax.set_ylim(-150, 550); ax.set_zlim(-70, 280)
ax.set_box_aspect((700, 700, 350)); ax.view_init(elev=24, azim=-58)
ax.set_xlabel('x [mm]'); ax.set_ylabel('y [mm]'); ax.set_zlabel('z [mm]')
ax.legend(handles=[Patch(color=G['perfil'], label='Perfil V-slot 2020 (E1 a E4)'),
                   Patch(color=G['eje'], label='Travesaño del eje trasero (E5)'),
                   Patch(color=G['propia'], label='Piezas propias (F1 a F4)'),
                   Patch(color=G['ref'], alpha=.4, label='Gabinetes (referencia)'),
                   Patch(color=G['ref2'], alpha=.4, label='Motores 42PG y servos (referencia)'),
                   Patch(color=G['rueda'], alpha=.2, label='Ruedas (referencia)')], loc='upper left', fontsize=9)
ax.set_title('Ensamble de la estructura (504). Origen: esquina trasera izquierda inferior del bastidor', fontsize=11)
plt.tight_layout(); plt.savefig('ENSAMBLE_ISO.png', dpi=140); plt.close()


def vista(ax, pi, pj, flip, titulo):
    for i, x0, x1, y0, y1, z0, z1, g, a in M:
        c = {'x': (x0, x1), 'y': (y0, y1), 'z': (z0, z1)}
        a0, a1 = c[pi]; b0, b1 = c[pj]
        ax.add_patch(plt.Rectangle((a0, b0), a1 - a0, b1 - b0, fc=G[g], ec='k' if a == 1 else 'none', lw=0.3,
                                   alpha=a if a < 1 else 0.85))
    ax.set_aspect('equal'); ax.set_title(titulo, fontsize=10)
    if flip:
        ax.invert_yaxis()


def cota(ax, p, q, off, txt, vert=False):
    if vert:
        ax.annotate('', xy=(off, p), xytext=(off, q), arrowprops=dict(arrowstyle='<->', lw=0.8))
        ax.text(off + 8, (p + q) / 2, txt, fontsize=8, va='center')
    else:
        ax.annotate('', xy=(p, off), xytext=(q, off), arrowprops=dict(arrowstyle='<->', lw=0.8))
        ax.text((p + q) / 2, off - 6, txt, fontsize=8, ha='center', va='bottom')


fig, axs = plt.subplots(1, 3, figsize=(18, 7))
vista(axs[0], 'x', 'y', False, 'Planta (x–y), y crece hacia abajo')
axs[0].set_xlim(-130, 690); axs[0].set_ylim(-175, 575)
cota(axs[0], 0, 500, -150, '500'); cota(axs[0], 50, 490, 545, 'ejes 440')
cota(axs[0], 0, 400, -110, '400', True); cota(axs[0], -100, 500, 630, 'vía 600', True)
axs[0].invert_yaxis()
vista(axs[1], 'x', 'z', False, 'Lateral (x–z)')
axs[1].set_xlim(-150, 640); axs[1].set_ylim(-95, 320)
cota(axs[1], 0, 260, -120, '260', True); cota(axs[1], 0, 500, 300, '500')
axs[1].axhline(-59, color='k', lw=1); axs[1].text(-90, -80, 'suelo: 59 bajo el bastidor, 39 bajo E5', fontsize=8)
vista(axs[2], 'y', 'z', False, 'Frontal (y–z)')
axs[2].set_xlim(-150, 560); axs[2].set_ylim(-95, 320)
cota(axs[2], -100, 500, 300, 'vía 600'); cota(axs[2], 0, 400, 275, '400')
axs[2].axhline(-59, color='k', lw=1)
for a in axs:
    a.grid(alpha=.2)
plt.tight_layout(); plt.savefig('ENSAMBLE_VISTAS.png', dpi=140); plt.close()

bom = [
    ('E1', 'Perfil V-slot 2020, 6063-T5, corte 500 mm', 'Larguero exterior (inferior y superior)', 4, 'Naylamp (catálogo V-slot)', 'Estándar, corte'),
    ('E2', 'Perfil V-slot 2020, corte 220 mm', 'Poste', 4, 'Naylamp', 'Estándar, corte'),
    ('E3', 'Perfil V-slot 2020, corte 360 mm', 'Travesaño de extremo (4) y de batería (2, centros en x = 150 y 350)', 6, 'Naylamp', 'Estándar, corte'),
    ('E4', 'Perfil V-slot 2020, corte 460 mm', 'Larguero de elevación (centros en y = 80.5 y 319.5)', 2, 'Naylamp', 'Estándar, corte'),
    ('E5', 'Perfil V-slot 2020, corte 540 mm', 'Travesaño del eje trasero, bajo los largueros (y de −70 a 470)', 1, 'Naylamp', 'Estándar, corte'),
    ('F1', 'Soporte de motor en L, 6061-T6, 4 mm', 'Brida del 42PG al larguero inferior (izquierdo y derecho, simétricos)', 2, 'Propia', 'Plano F1'),
    ('F2', 'Soporte del pivote y del servo, 6061-T6 mecanizado', 'Cara exterior del poste delantero: pasador del pivote (brazo inferior), buje y servo (brazo superior); izquierdo y derecho, simétricos', 2, 'Propia', 'Plano F2'),
    ('F3', 'Soporte de gabinete en L, 5052-H32, 3 mm', 'Cubo S sobre el larguero inferior y el travesaño de batería (izquierdo y derecho, simétricos)', 2, 'Propia', 'Plano F3'),
    ('F4', 'Placa base de batería, 5052-H32, 4 mm', 'Cubo D sobre los travesaños de batería', 1, 'Propia', 'Plano F4'),
    ('N1', 'Escuadra L universal simple 20×20×14.5, 3 mm', 'Uniones internas: 3 por esquina (24), 2 por extremo de E3 de batería y de E4 (16), 2 por cruce de E5 con larguero (4)', 44, 'Naylamp (ID 467)', 'Estándar'),
    ('N2', 'Placa de unión L de 4 agujeros 60×60×2, 6063-T5', 'Refuerzo exterior de esquina', 8, 'Probots', 'Estándar'),
    ('N3', 'Tornillo M5×8 de bajo perfil', 'Escuadras N1 (2 por escuadra)', 88, 'Naylamp (ID 474)', 'Estándar'),
    ('N4', 'Tornillo M5×10', 'Placas N2 (32), F1 (6), F3 (6)', 44, 'Naylamp (ID 475)', 'Estándar'),
    ('N5', 'Tuerca en T de inserción M5, acero niquelado', 'Una por tornillo M5', 144, 'Naylamp (ID 599)', 'Estándar'),
    ('N6', 'Tornillo M4×8 de cabeza cilíndrica, ISO 4762, A2-70', 'Brida del motor a F1 (4 por motor)', 8, 'ISO 4762', 'Estándar'),
    ('N8', 'Tornillo M5×10 de cabeza avellanada, ISO 10642', 'Placa F4 a los travesaños de batería', 4, 'ISO 10642', 'Estándar'),
    ('N9', 'Tornillo M5×12 de cabeza cilíndrica, ISO 4762, A2-70', 'F2 al poste y al larguero inferior (4 por pieza)', 8, 'ISO 4762', 'Estándar'),
    ('N7', 'Tapa de extremo 2020', 'Extremos expuestos de E5', 2, 'Naylamp (ID 472)', 'Estándar'),
    ('P1', 'Tornillería de los gabinetes a F3 y F4', 'Según la plantilla de fijación de Ensto', 0, 'Pendiente', 'Pendiente'),
    ('P2', 'Tornillería del soporte del servo a F2', 'Según el soporte en U del RDS3225', 0, 'Pendiente', 'Pendiente'),
]
with open('BOM_estructura.csv', 'w', newline='', encoding='utf-8-sig') as f:
    w = csv.writer(f); w.writerow(['Item', 'Descripción', 'Uso', 'Cantidad', 'Fuente', 'Tipo']); w.writerows(bom)
L = 4 * 500 + 4 * 220 + 6 * 360 + 2 * 460 + 540
print('Longitud total de perfil: %d mm' % L)
