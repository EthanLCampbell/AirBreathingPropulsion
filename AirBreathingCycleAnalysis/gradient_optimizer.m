function [x_opt,fval] = gradient_optimizer(CONSTS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gradient_optimizer.m called from main to produce single-output of FOM/SFC
% for given objective.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(CONSTS.engine,"turbofan")
    % unpack intitial inputs
    [turbo] = deal(CONSTS.turbo);
    [cpr, beta, fpr] = deal(turbo.cpr, turbo.beta, turbo.fpr);
    
    % initial guess for [fpr, beta, cpr]
    x0 = [cpr, beta, fpr];
    
    % define upper and lower bounds for search
    lb = [1, 0, 1]; %[fpr,beta,cpr]
    ub = [60, 35, 15]; %[fpr,beta,cpr]
    
    % optimizer options
    options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'interior-point');
    
    % call optimizer
    [x_opt,fval] = fmincon(@objective_function,x0,[],[],[],[],lb,ub,[],options);
end
if strcmp(CONSTS.engine,"turbojet")
    % unpack intitial inputs
    [turbo] = deal(CONSTS.turbo);
    [cpr] = deal(turbo.cpr);
    
    % initial guess for [fpr, beta, cpr]
    x0 = [cpr];
    
    % define upper and lower bounds for search
    lb = [1];
    ub = [60];
    
    % optimizer options
    options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'interior-point');
    
    % call optimizer
    [x_opt,fval] = fmincon(@objective_function,x0,[],[],[],[],lb,ub,[],options);
end
end

