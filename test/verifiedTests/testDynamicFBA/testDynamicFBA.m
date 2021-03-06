% The COBRAToolbox: testDynamicFBA.m
%
% Purpose:
%     - testDynamicFBA tests the DynamicFBA function and its different outputs
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017

% define global paths
global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR filesep 'test' filesep 'verifiedTests' filesep 'testDynamicFBA'])

load('ecoli_core_model', 'model');
load testDataDynamicFBA;

smi = {'EX_glc(e)' 'EX_ac(e)'}; % exchange reaction for substrate in environment

smc = [10.8; 0.4]; % Glucose, Acetate concentration (all in mM)

Xec = 0.001; % initial biomass
dt = 1.0/100.0; % time steps
time = 1.0/dt; % simulation time

%define solver packages
solverPkgs = {'tomlab_cplex'};

% set tolerance
tol = 1e-8;

for k = 1:length(solverPkgs)

    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    end

    % change the COBRA solver (LP)
    solverLPOK = changeCobraSolver(solverPkgs{k});

    if solverLPOK == 1
        fprintf('   Testing dynamicFBA using %s ... ', solverPkgs{k});
        [concentrationMatrixtest, excRxnNamestest, timeVectest, biomassVectest] = dynamicFBA(model, smi, smc, Xec, dt, time);

        assert(any(any(abs(concentrationMatrixtest - concentrationMatrix) < tol)))
        assert(isequal(excRxnNamestest, excRxnNames))
        assert(isequal(timeVectest, timeVec))
        assert(any(abs(biomassVectest - biomassVec) < tol))
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    end

end

% close open figure
close all

% change the directory
cd(CBTDIR)
