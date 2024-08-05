function [ST,SFC] = TurboJet(CONSTS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TurboJet() called from main to produce single-output of FOM/SFC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% UNPACK ENGINE
[efficiencies, combustor, thermo, freestream, turbo] = ...
    deal(CONSTS.efficiencies, CONSTS.combustor, CONSTS.thermo,...
    CONSTS.freestream, CONSTS.turbo);

[etad, etab, etan] =...
    deal(efficiencies.etad, efficiencies.etab, efficiencies.etan);

[cpr, dcpr] = ...
    deal(turbo.cpr, turbo.dcpr);

[T0, P0, M0, G, R_air, a0, U0] = ...
    deal(freestream.T0, freestream.P0, freestream.M0,...
    freestream.G, freestream.R_air, freestream.a0, freestream.U0);

[cph, cpc, gamh, gamc] = ...
    deal(thermo.cph, thermo.cpc, thermo.gamh, thermo.gamc);

[Tt4, H] = deal(combustor.Tt4, combustor.H);

beta = 1; %turbojets have no bypass 
fpr = 1; %"fan" included in compressor (since no bypass)

%% COMPUTE ACROSS ENGINE COMPONENTS 
% Precompute exponent fractions: 
Fgh = (gamh-1)./gamh;
Fgc = (gamc-1)./gamc;

% across diffuser: (& convert from static to total)
Tt2 = T0 .* (1 + 0.5 * (gamc -1) .* M0^2);
Pt2 = P0 .* (1 + 0.5 * (gamc -1) .* M0^2 .* etad)^(1 ./ Fgc);

% compressor efficiencies (function of compression)
etac = 1 - 0.0075 .* (cpr - 1); % compressor efficiency
etat = 1 - 0.004 .* (cpr - 1); % turbine efficiency

% temperature ratio (function of compression)
tauc = 1 + (cpr^Fgc - 1)/etac;

%across compressor
Tt3 = Tt2 * tauc;
Pt4 = cpr*Pt2;

%across burner 
f = (cph .* Tt4 - cpc .* Tt3) ./ (H .* etab - cph .* Tt4);

%across turbine (power balance)
Tt5 = Tt4 - (cpc / cph) .* (Tt3 - Tt2) ./ (1 + f);
Pt5 = Pt4 .* ( 1 - (1 - Tt5 / Tt4) ./ etat)^(1 ./ Fgh);

if Pt5 > P0 && f > 0
    U7 = sqrt(2 .* cph .* Tt5 .* etan .* (1 - (P0 / Pt5)^Fgh) .* 778 .* G);
    ST = ((U7 .* (1 + f) - U0))/G; % SpT [s]
    SFC = 3600 .* f ./ ST; % SFC [lbm/(hr*lbf)]
else
    ST = 0; 
    SFC = 1.3;
end

if not(isreal(ST)) || ST < 0
    ST = []; % specific thrust
    SFC = []; % specific fuel consumption
    warning("impossible / trivial solution found")
end 
end
