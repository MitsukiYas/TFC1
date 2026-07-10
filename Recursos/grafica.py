import matplotlib.pyplot as plt

# Variables de los puntos (Valor Técnico, Valor Económico) que puedes modificar
solucion1 = (0.49, 0.88)
solucion2 = (0.82, 0.64)
solucion3 = (0.83, 0.38)

# Configuración de la figura principal
plt.figure(figsize=(8, 5))

# Trazar la línea diagonal de referencia (y = x)
plt.plot([0, 1], [0, 1], color='#34A853', linestyle='-')

# Graficar los puntos con sus respectivos colores y marcadores
plt.scatter(*solucion1, color='#EA4335', marker='s', label='Solución 1', zorder=5)
plt.scatter(*solucion2, color='#4285F4', marker='D', label='Solución 2', zorder=5)
plt.scatter(*solucion3, color='#FBBC05', marker='^', label='Solución 3', zorder=5)

# Configuración de límites, ejes y etiquetas
plt.xlim(0, 1)
plt.ylim(0, 1)
plt.xlabel('Valor Técnico')
plt.ylabel('Valor Económico')

# Formato visual de la cuadrícula y la leyenda
plt.grid(True, linestyle='-', alpha=0.5)
plt.legend(loc='center left', bbox_to_anchor=(1.02, 0.4), frameon=False, handletextpad=0.1)

# Ajustar el diseño y mostrar la gráfica final
plt.tight_layout()
plt.show()