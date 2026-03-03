%% BCI MOTOR IMAGERY PIPELINE (PhysioNet EEGMMIDB)
% Autor: [Andrés Arias] 
% Descripción: Pipeline completo de preprocesamiento y análisis ERD/ERS.

clear; close all; [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

% --- 1. PARÁMETROS Y RUTAS ---
subj = 'S001';
raw_path = '../data/raw/'; 
res_path = '../data/derivatives/';
if ~exist(res_path, 'dir'), mkdir(res_path); end

% --- 2. IMPORTACIÓN Y MERGE (Runs 04, 08, 12 - Imaginería) ---
fprintf('>>> Importando y uniendo datasets...\n');
EEG1 = pop_biosig([raw_path subj 'R04.edf']);
EEG2 = pop_biosig([raw_path subj 'R08.edf']);
EEG3 = pop_biosig([raw_path subj 'R12.edf']);
EEG = pop_mergeset([EEG1 EEG2 EEG3]); 

% --- 3. LIMPIEZA DE CANALES Y COORDENADAS ---
for i = 1:EEG.nbchan % Limpieza de labels (quitar puntos)
    EEG.chanlocs(i).labels = strrep(EEG.chanlocs(i).labels, '.', '');
end
EEG = pop_chanedit(EEG, 'lookup', 'standard_1005.elc');
ALLCHANLOCS = EEG.chanlocs; % Guardar plantilla para interpolación

% --- 4. FILTRADO (1-40 Hz) ---
% Filtro FIR de fase cero para evitar distorsión temporal.
EEG = pop_eegfiltnew(EEG, 'locutoff', 1, 'hicutoff', 40);

% --- 5. LIMPIEZA AUTOMÁTICA (ASR) ---
% Eliminamos canales ruidosos y ráfagas de artefactos.
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion', 5, 'ChannelCriterion', 0.8, ...
    'Highpass', 'off', 'BurstCriterion', 20);
EEG = pop_interp(EEG, ALLCHANLOCS, 'spherical'); % Recuperar los 64 canales
EEG = pop_reref(EEG, []); % Referencia Promedio (CAR)

% --- 6. ICA & ICLABEL ---
% Reducción de rango por canales borrados (PCA)
num_pcs = EEG.nbchan - 2; % Ajustar según canales borrados por ASR
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'pca', num_pcs);
EEG = pop_iclabel(EEG, 'default');
% Eliminar componentes Oculares > 80% (Excepto IC22/IC24 identificados como Brain)
EEG = pop_subcomp(EEG, find(EEG.etc.ic_classification.ICLabel.classifications(:,2) > 0.8), 0);

% --- 7. EPOCHING Y GUARDADO ---
EEG = pop_epoch(EEG, {'T1' 'T2'}, [-1 4], 'newname', 'S01_epochs', 'epochinfo', 'yes');
EEG = pop_rmbase(EEG, [-1000 0]);
pop_saveset(EEG, 'filename', [subj '_final_processed.set'], 'filepath', res_path);
