function [ST,SFC] = objective_function(x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% objective_function.m called from optimizer to produce single-output of
% ST/SFC given the input characteristics desired.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fpr = x(1);
    beta = x(2);
    cpr = x(3);
    global CONSTS;
    CONSTS.turbo.fpr = fpr;
    CONSTS.turbo.beta = beta;
    CONSTS.turbo.cpr = cpr;
    [ST,SFC] = TurboFan(CONSTS);

end