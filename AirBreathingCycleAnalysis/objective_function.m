function [SFC] = objective_function(x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% objective_function.m called from optimizer to produce single-output of
% ST/SFC given the input characteristics desired.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global CONSTS;
    if strcmp(CONSTS.engine,"turbofan")
        cpr = x(1);
        beta = x(2);
        fpr = x(3);
        CONSTS.turbo.fpr = fpr;
        CONSTS.turbo.beta = beta;
        CONSTS.turbo.cpr = cpr;
        [~,SFC] = TurboFan(CONSTS);
    elseif strcmp(CONSTS.engine,"turbojet")
        cpr = x(1);
        CONSTS.turbo.cpr = cpr;
        [~,SFC] = TurboJet(CONSTS);
    elseif strcmp(CONSTS.engine,"turbojetwAB")
        warning("objective function for afterburner case not implemented")
    end
end