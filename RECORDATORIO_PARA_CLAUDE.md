# RECORDATORIO_PARA_CLAUDE

Convenciones de redacción de la tesis que Claude debe respetar al escribir o revisar capítulos.

## 1. No citar números de ecuaciones, tablas ni figuras de las fuentes

En el texto de la tesis **no** se mencionan números concretos de ecuaciones, tablas, figuras o páginas de las referencias externas. Ejemplos de lo que **no** se escribe:

- «la Ecuación 13-46 de \citet{shigley2012mecanico}»
- «según la Tabla 7-4 de \citet{shigley2012mecanico}»
- «las Ecuaciones 6-10 y 6-17 a 6-19 y las Tablas 6-2 y 6-4 de la misma fuente»

En su lugar, se cita solo la fuente y se describe el método o el dato:

- «la eficiencia directa se calcula según \citet{shigley2012mecanico}»
- «una fuerza de retención de 712 N \citep{shigley2012mecanico}»
- «el límite de fatiga según la misma fuente es...»

**Por qué:** la numeración de ecuaciones y tablas cambia entre ediciones (por ejemplo, Shigley 9.ª frente a 11.ª), y una cita a un número que no coincide con la edición del `.bib` es un error verificable. Citar solo la fuente evita ese problema.

**Alcance:** aplica a libros, normas y catálogos. Las referencias internas del propio documento (`\ref{eq:...}`, `\ref{tab:...}`, `\ref{fig:...}`) sí se usan con normalidad.

## 2. Referencias internas entre paréntesis

No se escriben remisiones del tipo «(ver la selección de rodamientos)» o «(ver el presupuesto de error angular)» sin `\ref`. Si la remisión no aporta, se elimina; no se añade un `\ref` solo para justificarla.
