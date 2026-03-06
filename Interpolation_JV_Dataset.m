% =========================================================================
% JV Data Interpolation Script with File Selection & Step Size Input
% Author: Biswajit Pal
% Date: July 2025
% =========================================================================

clc;
clear;

%% --- Step 1: Select JV Data File ---
[filename, pathname] = uigetfile({'*.txt;*.csv;*.dat', ...
    'Data Files (*.txt, *.csv, *.dat)'}, 'Select JV Data File');

if isequal(filename, 0)
    disp('User canceled file selection.');
    return;
end

fullpath = fullfile(pathname, filename);
disp(['Loading file: ', fullpath]);

%% --- Step 2: Load JV Data (2-column format) ---
try
    data = readmatrix(fullpath);  % Works for numeric files
catch
    error('Failed to read file. Ensure it contains two columns of numeric data.');
end

if size(data,2) < 2
    error('File must contain at least two columns: Voltage and Current.');
end

V_raw = data(:,1);  % Voltage (V)
J_raw = data(:,2);  % Current Density (mA/cm² or A/cm²)

%% --- Step 3: Popup to Enter Interpolation Step Size ---
defaultStep = {'0.001'};  % Default value
prompt = {'Enter interpolation voltage step size (V):'};
dlgtitle = 'Set Interpolation Step Size';
dims = [1 40];
answer = inputdlg(prompt, dlgtitle, dims, defaultStep);

if isempty(answer)
    disp('User canceled interpolation step input.');
    return;
end

stepSize = str2double(answer{1});
if isnan(stepSize) || stepSize <= 0
    error('Invalid step size. Please enter a positive numeric value.');
end

%% --- Step 4: Interpolate JV Data ---
interp_method = 'spline';  % Options: 'spline', 'linear', 'pchip'

V_min = min(V_raw);
V_max = max(V_raw);
V_interp = V_min:stepSize:V_max;

if numel(V_interp) < 2
    error('Step size too large. Not enough points to interpolate.');
end

J_interp = interp1(V_raw, J_raw, V_interp, interp_method);

%% --- Step 5: Plot Original and Interpolated JV Curves ---
figure('Name', 'Interpolated JV Curve', 'Color', 'w');
plot(V_raw, J_raw, 'ro', 'MarkerSize', 6, 'DisplayName', 'Original Data');
hold on;
plot(V_interp, J_interp, 'b-', 'LineWidth', 2, ...
     'DisplayName', sprintf('Interpolated (%.4f V step)', stepSize));
xlabel('Voltage (V)', 'FontSize', 12);
ylabel('Current Density (J)', 'FontSize', 12);
title('Interpolated JV Curve', 'FontSize', 14);
legend('Location', 'Best');
grid on;
set(gca, 'FontSize', 11);

%% --- Step 6: Save Interpolated Data (Optional) ---
choice = questdlg('Do you want to save the interpolated JV data?', ...
                  'Save Interpolated Data', ...
                  'Yes', 'No', 'Yes');

if strcmp(choice, 'Yes')
    outputData = [V_interp(:), J_interp(:)];
    [~, name, ~] = fileparts(filename);
    outname = sprintf('%s_Interpolated_%.6fV.txt', name, stepSize);
    outpath = fullfile(pathname, outname);
    writematrix(outputData, outpath, 'Delimiter', 'tab');
    disp(['Interpolated data saved to: ', outpath]);
end
