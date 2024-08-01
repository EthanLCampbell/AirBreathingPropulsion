function [ST,SFC] = TurboFan(CONSTS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TurboFan() called from main to produce single-output of FOM/SFC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% UNPACK ENGINE
[efficiencies, combustor, thermo, freestream, turbo] = ...
    deal(CONSTS.efficiencies, CONSTS.combustor, CONSTS.thermo,...
    CONSTS.freestream, CONSTS.turbo);

[etad, etab, etan, etanprime, etacprime] =...
    deal(efficiencies.etad, efficiencies.etab, efficiencies.etan,...
    efficiencies.etanprime, efficiencies.etacprime);

[fpr, beta, cpr, dcpr, dbeta, dfpr] = ...
    deal(turbo.fpr, turbo.beta, turbo.cpr, turbo.dcpr,...
    turbo.dbeta, turbo.dfpr);

[T0, P0, M0, G, R_air, a0, U0] = ...
    deal(freestream.T0, freestream.P0, freestream.M0,...
    freestream.G, freestream.R_air, freestream.a0, freestream.U0);

[cph, cpc, gamh, gamc] = ...
    deal(thermo.cph, thermo.cpc, thermo.gamh, thermo.gamc);

[Tt4, H] = deal(combustor.Tt4, combustor.H);

%% COMPUTE ACROSS ENGINE COMPONENTS 
% Precompute exponent fractions: 
Fgh = (gamh-1)./gamh;
Fgc = (gamc-1)./gamc;

% across diffuser: (& convert from static to total)
Tt2 = T0 .* (1 + 0.5 * (gamc -1) .* M0^2);
Pt2 = P0 .* (1 + 0.5 * (gamc -1) .* M0^2 .* etad)^(1 ./ Fgc);

% across fan: 
taucprime = 1 + (fpr^Fgc - 1)./etacprime;
Tt13 = Tt2 * taucprime;
Pt13 = Pt2 * fpr;
U7prime = sqrt(2 .* cpc .* Tt13 .* etanprime .*...
    (1 - (P0 ./ Pt13)^Fgc) .* 778 .* G);


etac = 1 - 0.0075 .* (cpr - 1); % compressor efficiency
etat = 1 - 0.004 .* (cpr - 1); % turbine efficiency
tauc = 1 + (cpr^Fgc - 1)/etac;

%across compressor
Tt3 = Tt13 * tauc;
Pt4 = cpr*Pt13;

%across burner 
f = (cph .* Tt4 - cpc .* Tt3) ./ (H .* etab - cph .* Tt4);
Tt5 = Tt4 - (cpc / cph) .* (Tt3 - Tt2 + beta .*...
    (Tt13 - Tt2)) ./ (1 + f);
Pt5 = Pt4 .* ( 1 - (1 - Tt5 / Tt4) ./ etat)^(1 ./ Fgh);

if Pt5 > P0 && f > 0
    U7 = sqrt(2 .* cph .* Tt5 .* etan .* (1 - (P0 / Pt5)^Fgh) .* 778 .* G);
    ST = ((U7 .* (1 + f) - U0) + beta .*...
        (U7prime - U0)) ./ (G .* (1 + beta)); % SpT
    SFC = 3600 .* f ./((1 + beta) .* ST); % SFC
else
    ST = 0; 
    SFC = 1.3;
end

if not(isreal(ST)) || ST < 0
    ST = []; % specific thrust
    SFC = []; % specific fuel consumption
end 

