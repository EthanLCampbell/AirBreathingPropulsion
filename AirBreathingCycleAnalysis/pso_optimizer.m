function [x_opt,fval] = pso_optimizer(CONSTS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pso_optimizer.m called from main to produce single-output of FOM/SFC for
% given objective.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PARTICLE POLITICAL LEANING
% PSO parameters 
    numParticles = 30; % Number of particles in the swarm
    maxIterations = 100; % Maximum number of iterations
    inertia = 0.7; % Inertia weight
    cognitiveCoeff = 1.5; % Cognitive (particle) coefficient
    socialCoeff = 2.0; % Social (swarm) coefficient

%% ENGINE-BASED INITIAL GUESS
if strcmp(CONSTS.engine,"turbofan")
    [turbo] = deal(CONSTS.turbo);
    [cpr, beta, fpr] = deal(turbo.cpr, turbo.beta, turbo.fpr);
    x0 = [cpr,beta,fpr]; % Initial guess
    lb = [1, 0, 1]; % Lower bounds for [cpr, beta, fpr]
    ub = [60, 35, 8]; % Upper bounds for [cpr, beta, fpr]
elseif strcmp(CONSTS.engine,"turbojet")
    [turbo] = deal(CONSTS.turbo);
    [cpr] = deal(turbo.cpr);
    x0 = [cpr]; % initial guess
    lb = [1]; %lower bound of [cpr]
    ub = [60]; %upper bound of [cpr]
end
numDimensions = length(x0); % num dimensions in design space

%% PSO SETUP 
% Initialize the swarm
    swarm = repmat(struct('position', [], 'velocity', [], 'cost', [], 'bestPosition', [], 'bestCost', []), numParticles, 1);
    globalBestCost = inf;
    globalBestPosition = [];
% Initialize particles
    for i = 1:numParticles
        swarm(i).position = lb + rand(1, 3) .* (ub - lb);
        swarm(i).velocity = zeros(1, 3);
        swarm(i).cost = objective_function(swarm(i).position);
        swarm(i).bestPosition = swarm(i).position;
        swarm(i).bestCost = swarm(i).cost;
        
        if swarm(i).cost < globalBestCost
            globalBestCost = swarm(i).cost;
            globalBestPosition = swarm(i).position;
        end
    end

% PSO main loop 
for iter = 1:maxIterations
        for i = 1:numParticles
            % Update velocity
            swarm(i).velocity = inertia * swarm(i).velocity + ...
                                cognitiveCoeff * rand(1, numDimensions) .* (swarm(i).bestPosition - swarm(i).position) + ...
                                socialCoeff * rand(1, numDimensions) .* (globalBestPosition - swarm(i).position);
            
            % Update position
            swarm(i).position = swarm(i).position + swarm(i).velocity;
            
            % Apply bounds
            swarm(i).position = max(lb, min(ub, swarm(i).position));
            
            % Evaluate new position
            swarm(i).cost = objective_function(swarm(i).position);
            
            % Update personal best
            if swarm(i).cost < swarm(i).bestCost
                swarm(i).bestCost = swarm(i).cost;
                swarm(i).bestPosition = swarm(i).position;
            end
            
            % Update global best
            if swarm(i).cost < globalBestCost
                globalBestCost = swarm(i).cost;
                globalBestPosition = swarm(i).position;
            end
        end
        
        % Display iteration information
        fprintf('Iteration %d: Best SFC = %.4f\n', iter, globalBestCost);
    end
    
    x_opt = globalBestPosition;
    fval = globalBestCost;

end