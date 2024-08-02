# AIR BREATHING CYCLE ANALYSIS README.md

# Description: 
- Air-breathing parametric cycle analysis function that allows for minimizing thrust specific fuel consumption while keeping thrust above necessary mission requirements.
- Takes engine inputs such as: post-burner temperature, fan and compressor pressure ratios, bypass ratios, etc and yields specific thrust and fuel consumption as outputs.
- Has the following engines implemented: [turbofan, turbojet, turbojet with afterburning]
- Has the following optimization methods: [single run, gradient optimization, particle swarm optimization]

# What works so far?
Any combination of the following:
- Standard Turbojet and Turbofan engines
- Single, gradient-based, and particle swarm optimizers

# TODO: 
- have thermodynamic properties (specific heat capacity, ratio, R, etc) pull from thermo data tables based on air temperature.
- create/test turbojet with afterburning function (wip)
- create turbofan with afterburners function 
- make turbojet with afterburning have options for optimization (wip)
- have altitude/atmosphere model that we can base air and thermodynamic data off of 
- create graphics outputs for sweeps and optimizers?
- create GUI using mlapp designer? (semi-wip)
