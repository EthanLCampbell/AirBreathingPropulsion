function [x_opt,fval] = Optimizer(CONSTS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimizer.m called from main to produce single-output of FOM/SFC for
% given objective.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% unpack intitial inputs
[turbo] = deal(CONSTS.turbo);
[fpr, beta, cpr] = deal(turbo.fpr, turbo.beta, turbo.cpr);

% initial guess for [fpr, beta, cpr]
x0 = [fpr, beta, cpr];

% define upper and lower bounds for search
lb = [1, 0, 1];
ub = [8, 35, 60];

% optimizer options
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'interior-point');

% call optimizer
[x_opt,fval] = fmincon(@objective_function,x0,[],[],[],[],lb,ub,[],options);

end

