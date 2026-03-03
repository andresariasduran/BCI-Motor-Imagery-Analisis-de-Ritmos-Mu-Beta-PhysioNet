# BCI Motor Imagery: Análisis de Ritmos Mu/Beta (PhysioNet)
Un Pipeline de Preprocesamiento y Análisis de Señales EEG para la Clasificación de Imaginería Motora.

Autor: Andrés Arias  
Físico (PhD) | Machine Learning & Neurotechnology  

## Resumen

Este proyecto implementa un flujo de trabajo profesional en MATLAB/EEGLAB para procesar datos del dataset PhysioNet EEGMMIDB. El objetivo es aislar fuentes cerebrales independientes y cuantificar la Desincronización Relacionada con Eventos (ERD).


## Pipeline de Procesamiento (Justificaciones Técnicas)

# 1. Limpieza de Artefactos Críticos (Pre-filtrado)

¿Por qué eliminar picos antes de filtrar?
Se realizó una inspección visual para eliminar artefactos de gran amplitud. Aplicar un filtro sobre un pico de voltaje ej. 500 uV

causa un efecto de "Smearing" (distribución), donde el filtro "esparce" el ruido hacia los datos limpios adyacentes, obligando a rechazar más datos de los necesarios post-filtrado.

# 2. Filtrado FIR de Fase Cero (1-40 Hz)

High-pass (1 Hz): Configurado para optimizar la convergencia del algoritmo ICA. Elimina derivas galvánicas y sudor.
Low-pass (40 Hz): Elimina el ruido de la línea eléctrica (60 Hz) y la actividad muscular de alta frecuencia (EMG).

# 3. ASR (Artifact Subspace Reconstruction) & Interpolación

Algoritmo ASR: Se utilizó un criterio de ráfaga (Burst Criterion) de 20 para reparar ráfagas de ruido.
Interpolación Esférica: Los canales eliminados por ruido (ej. 2 canales en S01) fueron reconstruidos mediante splines esféricos para mantener la consistencia espacial de la malla de 64 canales.
Re-referencia: Se aplicó una Referencia Promedio (CAR) para actuar como un filtro espacial que resalta la actividad local de la corteza motora.

# 4. ICA (Independent Component Analysis) & ICLabel

Rank Deficiency: Dado que se interpolaron canales, el ICA se ejecutó con una reducción de rango vía PCA (Rank = 62) para evitar inestabilidad matemática.
IA de Clasificación: Se utilizó el plugin ICLabel.
Hallazgo: El IC24 fue identificado como 96.9% Brain, localizado sobre C3.
Decisión: Se preservaron los componentes tipo "Other" para evitar la distorsión de la señal, eliminando únicamente "Eye" y "Muscle" con probabilidad >80%.

# 5. Análisis de Resultados: Dinámica Espectral

Event-Related Spectral Perturbation (ERSP)
Se analizaron épocas de -1 a 4 segundos para capturar la dinámica completa del movimiento imaginado.
Identificación del Ritmo Mu: Se observó una caída de potencia (ERD) en la franja de 8-13 Hz.
Asimetría Funcional: En el sujeto analizado, se detectó una respuesta robusta en el hemisferio contralateral derecho (C4) para la mano izquierda, mientras que la respuesta en C3 fue transitoria (0.2s - 0.4s).
Rebote Beta (ERS): Se identificó una sincronización posterior en 17 Hz, confirmando la recuperación de la corteza motora tras la tarea.

# 5. Mejoras Futuras y Escalabilidad (Roadmap)

Para llevar este clasificador de BCI a un nivel de producción o aplicaciones en tiempo real, se proponen las siguientes líneas de desarrollo:
1. Extracción de Características con CSP (Common Spatial Patterns)
   
# Propuesta: Implementar algoritmos de CSP para maximizar la diferencia de varianza entre las clases (Mano Izquierda vs. Derecha).

Justificación: Mientras que el análisis por canal (C3/C4) es informativo, el CSP calcula filtros espaciales óptimos que pueden revelar la ERD incluso en sujetos con baja relación señal-ruido, mejorando la precisión de la clasificación.

