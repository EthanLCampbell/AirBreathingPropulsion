%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author:   Ethan Labianca-Campbell
%  Date:     7/20/2024
%  linkedIn  https://www.linkedin.com/in/ethan-labianca-campbell/
%
%  NOTES:
%  -   Set efficiency values to 1 for ideal cycle analysis
% 
%  Generates parametric cycle analysis graphics for the following engines:
%  -   Turbofan Engine (separated bypass case)
%  -   Turbojet Engine (standard case)
%  -   Turbojet Engine w/ Afterburning
%
%  With the following analysis methods:
%  -   single-run specific thrust & fuel consumption
%  -   gradient-based optimization of specific fuel consumption
%  -   particle-swarm optimizatin of specific fuel consumption
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all;

addpath(genpath("AirBreathingCycleAnalysis"))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    AIR-BREATHING PROPULSION PARAMETRIC CYCLE ANALYSIS MAIN FUNCTION   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
run_types = ["single","optimize_gradient","optimize_pso"];
run = run_types(3);

engine_types = ["turbojet","turbofan","turbojetwAB"];
engine = engine_types(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ENGINE PARAMETERS (USER INPUTS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Engine Efficiency Parameters

etad = 0.95; % diffuser efficiency
etab = 0.98; % burner flame efficiency
etan = 0.95; % nozzle efficiency 
etanprime = etan;% bypass nozzle efficiency
etacprime = 0.9; % fan bypass efficiency
etaab = 0.96; % afterburner flame efficiency
efficiencies = struct('etad', etad, 'etab', etab, 'etan', etan,...
    'etanprime', etanprime, 'etacprime', etacprime,'etaab',etaab);

% Engine Combustion Parameters
Tt4 = 2520; % Post-burner total temperature [Rankine]
H = 18500; % Fuel Heating Value [BTU/lbm]
% Afterburner Combustion Parameters
abTt7 = 3500; % Post-afterburner total temperature [Rankine]
combustor = struct('Tt4', Tt4, 'H', H, 'abTt7', abTt7);

% Thermodynamic properties
cph = 0.27; % const-pressure heat capacity [BTU/(lb*R)] (hot)
cpc = 0.25; % const-pressure heat capacity [BTU/(lb*R)] (cold)
cpAB = 0.28; % const-pressure heat capabity [BTU/lb*R] (afterburner)
gamh = 1.33; % specific heat ratio (hot)
gamc = 1.4; % specific heat ratio (cold)
gamAB = 1.3; % specific heat ratio (afterburner)
thermo = struct('cph',cph,'cpc', cpc,'cpAB',cpAB,'gamh',gamh,...
    'gamc',gamc,'gamAB',gamAB);

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
CONSTS = struct('engine',engine,'efficiencies', efficiencies, 'combustor', combustor,...
    'thermo', thermo, 'freestream', freestream, 'turbo', turbo);

% Minimum specific thrust required:
ST_min = 2000; %[lbf*s/lbm] 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COMPUTATION & OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% SINGLE RUN %%
if strcmp(run,"single")
    if strcmp(engine,"turbofan")
        % Run turbofan for outputs
        [ST,SFC] = TurboFan(CONSTS);
        % Outputs
        fprintf('INPUTS: \n')
        fprintf(' => cpr  = %d\n', cpr)
        fprintf(' => beta = %d\n', beta)
        fprintf(' => fpr  = %d\n', fpr)
        fprintf(' => dH   = %d [BTU/lbm]\n', H)
        fprintf(' => Tt4  = %d [R]\n', Tt4)
        fprintf('OUTPUTS: \n')
        fprintf(' => SFC = %s\n', num2str(SFC));
        fprintf(' => ST  = %s\n', num2str(ST));
    elseif strcmp(engine,"turbojet")
        % Run turbofan for outputs
        [ST,SFC] = TurboJet(CONSTS);
        % Outputs
        fprintf('INPUTS: \n')
        fprintf(' => cpr = %d\n', cpr)
        fprintf(' => dH   = %d [BTU/lbm]\n', H)
        fprintf(' => Tt4  = %d [R]\n', Tt4)
        fprintf('OUTPUTS: \n')
        fprintf(' => SFC = %s\n', num2str(SFC));
        fprintf(' => ST  = %s\n', num2str(ST));
    elseif strcmp(engine,"turbojetwAB")
        warning("WIP - afterburning case not implemented yet")
        [ST,SFC] = TurboJetwAB(CONSTS);
        % Outputs
        fprintf('INPUTS: \n')
        fprintf(' => cpr = %d\n', cpr)
        fprintf(' => dH   = %d [BTU/lbm]\n', H)
        fprintf(' => Tt4  = %d [R]\n', Tt4)
        fprintf(' => Tt7  = %d [R]\n',abTt7)
        fprintf('OUTPUTS: \n')
        fprintf(' => SFC = %s\n', num2str(SFC));
        fprintf(' => ST  = %s\n', num2str(ST));
    end
end


%% OPTIMIZER %% 
% Gradient based
if strcmp(run,"optimize_gradient")
    % Run optimizer for outputs
    [x_opt,fval] = gradient_optimizer(CONSTS);
    % Outputs
    if strcmp(CONSTS.engine,"turbofan")
        fprintf('The minimum SFC value is: %s\n', num2str(fval));
        fprintf(' => cpr = %d\n', x_opt(1))
        fprintf(' => beta = %d\n', x_opt(2))
        fprintf(' => fpr = %d\n', x_opt(3))
    elseif strcmp(CONSTS.engine,"turbojet")
        fprintf('The minimum SFC value is: %s\n', num2str(fval));
        fprintf(' => cpr = %d\n', x_opt(1))
    end

elseif strcmp(run, "optimize_pso")
    [x_opt,fval] = pso_optimizer(CONSTS);
    % Outputs
    if strcmp(CONSTS.engine,"turbofan")
        fprintf('The minimum SFC value is: %s\n', num2str(fval));
        fprintf(' => cpr = %d\n', x_opt(1))
        fprintf(' => beta = %d\n', x_opt(2))
        fprintf(' => fpr = %d\n', x_opt(3))
    elseif strcmp(CONSTS.engine,"turbojet")
        fprintf('The minimum SFC value is: %s\n', num2str(fval));
        fprintf(' => cpr = %d\n', x_opt(1))
    end
end

%% GRAPHICS RUN %% - (WIP)
if strcmp(run,"sweep_cpr")

elseif strcmp(run,"sweep_beta")

elseif strcmp(run,"sweep_fpr")

end

