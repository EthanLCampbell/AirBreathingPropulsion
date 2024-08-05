function [ST,SFC] = TurboJetwAB(CONSTS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TurboJet() called from main to produce single-output of FOM/SFC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% UNPACK ENGINE
[efficiencies, combustor, thermo, freestream, turbo] = ...
    deal(CONSTS.efficiencies, CONSTS.combustor, CONSTS.thermo, ...
    CONSTS.freestream, CONSTS.turbo);

[etad, etab, etan, etaab] =...
    deal(efficiencies.etad, efficiencies.etab, efficiencies.etan,...
    efficiencies.etaab);

[cpr, dcpr] = ...
    deal(turbo.cpr, turbo.dcpr);

[T0, P0, M0, G, R_air, a0, U0] = ...
    deal(freestream.T0, freestream.P0, freestream.M0,...
    freestream.G, freestream.R_air, freestream.a0, freestream.U0);

[cph, cpc, cpAB, gamh, gamc, gamAB] = ...
    deal(thermo.cph, thermo.cpc, thermo.cpAB, thermo.gamh, thermo.gamc,...
    thermo.gamAB);

[Tt4, H, Tt7] = deal(combustor.Tt4, combustor.H, combustor.abTt7);

beta = 1; %turbojets have no bypass 
fpr = 1; %"fan" included in compressor (since no bypass)

%% STEP THROUGH ENGINE

% Mostly same as turbojet until station 7
% Precompute exponent fractions: 
Fgh = (gamh-1)./gamh;
Fgc = (gamc-1)./gamc;

% across diffuser: (& convert from static to total)
tauR = (1 + 0.5 * (gamc -1) .* M0^2);
Tt2 = T0 * tauR;
Pt2 = P0 .* (1 + 0.5 * (gamc -1) .* M0^2 .* etad)^(1 ./ Fgc);

% compressor efficiencies (function of compression)
etac = 1 - 0.0075 .* (cpr - 1); % compressor efficiency
etat = 1 - 0.004 .* (cpr - 1); % turbine efficiency

% temperature ratio (function of compression)
tauc = 1 + (cpr^Fgc - 1)/etac;

% across compressor
Tt3 = Tt2 * tauc;
Pt3 = cpr*Pt2;

% across burner 
% from energy balance to main burner: 
f = (cph .* Tt4 - cpc .* Tt3) ./ (H .* etab - cph .* Tt4); 
Pt4 = Pt3; %no pressure gain in brayton combustion 

% across turbine (power balance)
Tt5 = Tt4 - (cpc / cph) .* (Tt3 - Tt2) ./ (1 + f);
Pt5 = Pt4 .* ( 1 - (1 - Tt5 / Tt4) ./ etat)^(1 ./ Fgh);

% across afterburner 
tauR = Tt2/T0;
tauLambda = Tt4 / T0;
tauT = Tt5 / Tt4;
tauAB = Tt7/Tt5;
tauLambdaAB = tauLambda * tauAB * tauT;

% from energy balance to afterburner: 
fAB = (1+f) * (tauLambdaAB-tauLambda*tauT)/(etaab*H/(cpc*T0)-tauLambdaAB);

SFC = (f+fAB)/ST * 3600;  

warning("Turbojet w/ Afterburner not implemented yet")
ST = 0;6
SFC = 0;






