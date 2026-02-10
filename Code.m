%% ========================================================================
%  Code.m
%  Description : Multi-Regional Input-Output (MRIO) Analysis for Embodied
%                Employment and Value-Added in Interprovincial Trade
%                across 31 Chinese Provinces (3-sector aggregation)
%
%  Year        : 2012, 2015, 2017 (set year below)
%  Sectors     : 3 sectors per province (93 = 31 provinces x 3 sectors)
%  Sectors Notes : The original data covers 31 provinces and 42 departments, aggregated into 3 departments.
%
%  Key Outputs : (1) Embodied employment transfer matrices
%                (2) Embodied value-added transfer matrices
%
%  Data Source : MRIO tables - CEADs MRIO tables(https://www.ceads.net.cn/)
%                Socio-economic data (Data Source: National Bureau of Statistics of China (https://www.stats.gov.cn/sj/ndsj/); China Labor Statistical Yearbook (https://data.cnki.net/yearBook?type=type&code=A))
%
%% ========================================================================

close all; clear all;

% =========================================================================
% SET YEAR
% =========================================================================
year = 2012;  % Change to 2015 or 2017 as needed

% =========================================================================
% LOAD PREPROCESSED DATA
% =========================================================================
load([num2str(year), '_MRIO_preprocessed.mat'], ...
    'Mid_use', 'Final_use', 'Final_use2', ...
    'export', 'ERR', 'Total_output', 'import', ...
    'add_value', 'Total_add_value', 'Total_input', ...
    'Empl');

% =========================================================================
% EMBODIED EMPLOYMENT ANALYSIS
% =========================================================================

% ---- Step 1: Compute direct input coefficient matrix A ----
% A(i,j) = intermediate input from sector i to sector j / total input of j
A = Mid_use ./ repmat(Total_input, [93, 1]);

% ---- Step 2: Compute Leontief inverse matrix L ----
% L = (I - A)^(-1), capturing both direct and indirect effects
I = eye(93);
L_reverse = inv(I - A);

% ---- Step 3: Compute employment intensity and diagonalize ----
% Employment intensity: employment per unit of output for each sector
C = Empl ./ Total_output;
C(isnan(C)) = 0;
C(isinf(C)) = 0;
CC = diag(C);  % Diagonal matrix of employment intensity (93 x 93)

% ---- Step 4: Compute embodied employment matrix ----
% Embodied employment = Employment intensity * Leontief inverse * Final demand
% Ec(i,s): employment embodied in sector i induced by final demand of province s
Ec = CC * L_reverse * Final_use2;

% ---- Step 5: Aggregate to province level (with self-trade) ----
% Ec2(r,s): total embodied employment in province r induced by province s
for r = 1:31
    Ec2(r,:) = nansum(Ec((r-1)*3+1:r*3, :), 1);
end

% ---- Step 6: Remove self-trade (intra-provincial flows) ----
% Ec3: sector-level embodied employment excluding intra-provincial flows
% Ec4: province-level embodied employment excluding intra-provincial flows
Ec3 = Ec;
for r = 1:31
    Ec3((r-1)*3+1:r*3, r) = 0;           % Set self-trade to zero
    Ec4(r,:) = nansum(Ec3((r-1)*3+1:r*3, :), 1);  % Aggregate to province level
end

% ---- Step 7: Compute export, import, and net employment transfer ----
% Export: total employment embodied in goods exported to other provinces
% Import: total employment embodied in goods imported from other provinces
Export_empl = nansum(Ec4, 2);       % Row sum: employment exported by province r
Import_empl = nansum(Ec4', 2);      % Column sum: employment imported by province r
Net_empl    = Export_empl - Import_empl;  % Net employment transfer

% ---- Step 8: Compute net employment flow matrix ----
% EcN(r,s) = Ec4(r,s) - Ec4(s,r): net flow from province r to province s
Ecrs = Ec4;     % Employment embodied in province r's exports to province s
Ecsr = Ec4';    % Employment embodied in province s's exports to province r
EcN  = Ecrs - Ecsr;

% =========================================================================
% EMBODIED VALUE-ADDED ANALYSIS
% =========================================================================

% ---- Step 9: Compute value-added intensity and diagonalize ----
% Value-added intensity: value-added per unit of output for each sector
Total_add_value_vertical = Total_add_value';
d = Total_add_value_vertical ./ Total_output;
d(isnan(d)) = 0;
d(isinf(d)) = 0;
D = diag(d);  % Diagonal matrix of value-added intensity (93 x 93)

% ---- Step 10: Compute embodied value-added matrix ----
% V = Value-added intensity * Leontief inverse * Final demand
% V(i,s): value-added embodied in sector i induced by final demand of province s
V = D * L_reverse * Final_use2;

% ---- Step 11: Aggregate to province level (with self-trade) ----
% V2(r,s): total embodied value-added in province r induced by province s
for r = 1:31
    V2(r,:) = nansum(V((r-1)*3+1:r*3, :), 1);
end

% ---- Step 12: Remove self-trade (intra-provincial flows) ----
% V3: sector-level embodied value-added excluding intra-provincial flows
% V4: province-level embodied value-added excluding intra-provincial flows
V3 = V;
for r = 1:31
    V3((r-1)*3+1:r*3, r) = 0;
    V4(r,:) = nansum(V3((r-1)*3+1:r*3, :), 1);
end

% ---- Step 13: Compute export, import, and net value-added transfer ----
Export_add_value = nansum(V4, 2);
Import_add_value = nansum(V4', 2);
Net_add_value    = Export_add_value - Import_add_value;

% ---- Step 14: Compute net value-added flow matrix ----
Vrs = V4;
Vsr = V4';
VN  = Vrs - Vsr;

fprintf('Analysis complete for year %d.\n', year);
