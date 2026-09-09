% --- Fixed ANFIS Training Data Generator with Temperature Variance ---
clear training_data;

% 1. Panel Parameters from your screenshot
Vmp_module = 54.7; 
Voc_module = 64.2;
alpha_Voc = -0.36 / 100; % -0.36%/degC
N_series = 10;

% 2. Create ranges (Sweeping T so Grid Partition does not crash)
G_sweep = 100:50:1200;   % Irradiance spectrum
T_sweep = 15:5:45;       % Temperature spectrum (creates max > min)

training_data = [];

% 3. Calculate array Vmp targets
for G = G_sweep
    for T = T_sweep
        dT = T - 25;
        
        % Calculate temperature degradation + irradiance log-drop
        if G > 0
            Vmp_corrected = (Vmp_module + (Voc_module * alpha_Voc * dT)) * (1 + 0.025 * log(G/1000));
        else
            Vmp_corrected = 0;
        end
        
        Vmp_array = Vmp_corrected * N_series;
        
        % [Input 1: G, Input 2: T, Output: Vmp_array]
        training_data = [training_data; G, T, Vmp_array];
    end
end

assignin('base', 'training_data', training_data);
disp('=== NEW DATASET READY ===');
disp('Run "neuroFuzzyDesigner" now to load this updated "training_data".');

% Extract the first 2 columns as your inputs (161x2)
fuz_inputs = training_data(:, 1:2);

% Extract the 3rd column as your target output (161x1)
fuz_outputs = training_data(:, 3);