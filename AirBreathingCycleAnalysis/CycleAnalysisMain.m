%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author:   Ethan Labianca-Campbell
%  Date:     7/20/2024
%  linkedIn  https://www.linkedin.com/in/ethan-labianca-campbell/
%
%  NOTES:
%  -   Set efficiency values to 1 for ideal cycle analysis
% 
%  Generates parametric cycle analysis graphics for the following engines:
%  -   Turbofan Engine (axial-flow based)
%
%  With the following analysis methods:
%  -   single-run specific thrust & fuel consumption
%  -   brute-force optimization of specific thrust & fuel consumption (WIP)
%  -   "smart" optimization algorithm of specific thrust & fuel
%      consumption (WIP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all;

addpath(genpath("AirBreathingCycleAnalysis"))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    AIR-BREATHING PROPULSION PARAMETRIC CYCLE ANALYSIS MAIN FUNCTION   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
run_types = ["single","optimize_gradient"];
run = run_types(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ENGINE PARAMETERS (USER INPUTS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Engine Efficiency Parameters

etad = 0.95; % diffuser efficiency
etab = 0.98; % burner efficiency
etan = 0.95; % nozzle efficiency 
etanprime = etan;% bypass nozzle efficiency
etacprime = 0.9; % fan bypass efficiency
efficiencies = struct('etad', etad, 'etab', etab, 'etan', etan,...
    'etanprime', etanprime, 'etacprime', etacprime);

% Engine Combustion Parameters
Tt4 = 3000; % Post-burner total temperature [Rankine]
H = 18500; % Fuel Heating Value [BTU/lbm]
combustor = struct('Tt4', Tt4, 'H', H);

% Thermodynamic properties
cph = 0.27; % const-pressure heat capacity [BTU/(lb*R)] (hot)
cpc = 0.25; % const-pressure heat capacity [BTU/(lb*R)] (cold)
gamh = 1.33; % specific heat ratio (hot)
gamc = 1.4; % specific heat ratio (cold)
thermo = struct('cph', cph, 'cpc', cpc, 'gamh', gamh, 'gamc', gamc);

% Free-stream 
T0 = 411.86; %[R] @ 30kft
P0 = 4.3; %[psi] @30kft
M0 = 0.83;
G = 32.174; %[ft/s^2]
R_air = G * 53.35; %[ft^2 / (s^2 * °R)]
a0 = sqrt(gamc * R_air * T0); %[ft/s]
U0 = M0 * a0; %[ft/s]
freestream = struct('T0', T0, 'P0', P0, 'M0', M0, 'G', G,...
    'R_air', R_air, 'a0', a0, 'U0', U0);

% Compressor and Fan Parameters
fpr = 1.2;
beta = 5;
cpr = 25;
dcpr = 1; % change in CPR for iteration
dbeta = 0.5; % change in bypass ratio for iteration
dfpr = 0.1; % change in fan pressure ratio
turbo = struct('fpr', fpr, 'beta', beta, 'cpr', cpr, 'dcpr', dcpr,...
    'dbeta', dbeta, 'dfpr', dfpr);

% Pack constants
global CONSTS;
CONSTS = struct('efficiencies', efficiencies, 'combustor', combustor,...
    'thermo', thermo, 'freestream', freestream, 'turbo', turbo);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COMPUTATION & OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SINGLE RUN %%
if strcmp(run,"single")
    % Run turbofan for outputs
    [ST,SFC] = TurboFan(CONSTS);
    % Outputs
    fprintf('INPUTS: \n')
    fprintf(' => cpr = %d\n', cpr)
    fprintf(' => beta = %d\n', beta)
    fprintf(' => fpr = %d\n', fpr)
    fprintf('OUTPUTS: \n')
    fprintf(' => SFC = %s\n', num2str(SFC));
    fprintf(' => ST  = %s\n', num2str(ST));
end


%% OPTIMIZER %% 
if strcmp(run,"optimize_gradient")
    % Run optimizer for outputs
    [x_opt,fval] = Optimizer(CONSTS);
    % Outputs
    fprintf('The minimum SFC value is: %s\n', fval);
    fprintf(' => cpr = %d\n', x_opt(3))
    fprintf(' => beta = %d\n', x_opt(2))
    fprintf(' => fpr = %d\n', x_opt(1))
end

