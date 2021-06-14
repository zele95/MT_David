function [engOut] = getEngData(engIn)
% Calculate aerodynamic coefficients and add it to the input struct
%
% [engOut] = getEngData(engIn)
%
% engIn          struct containing the engine data necessary for the
%                simulink model
%
% engOut         output struct with engine forces and moments
%
% ZHAW,	Author: David Haber-Zelanto - 16.10.2020.

%% set signal values from input

% period of initialization of the engine to get rid of the transient
nInit = 300;

% signals
cgx  = [ones(nInit,1) * engIn.cgx(1); engIn.cgx];
cgy  = [ones(nInit,1) * engIn.cgy(1); engIn.cgy];
cgz  = [ones(nInit,1) * engIn.cgz(1); engIn.cgz];
rho  = [ones(nInit,1) * engIn.rho(1); engIn.rho];
T    = [ones(nInit,1) * engIn.T(1); engIn.T];
tas  = [ones(nInit,1) * engIn.TAS(1); engIn.TAS];  
pst  = [ones(nInit,1) * engIn.pst(1); engIn.pst];
Thr  = [ones(nInit,1) * engIn.Thr(1); engIn.Thr];
Mix  = [ones(nInit,1) * engIn.Mix(1); engIn.Mix];
Amix = [ones(nInit,1) * engIn.Amix(1); engIn.Amix];

% set constant values necessary for the simulink model (from iniac)
Par= Init_Propulsion;

Par.IC.N0              = 0.75*2700/60*2*pi;
Par.Sim.Ts.EOM         = 1/200;                         % [s], sample time for the EoM

Par.Environment.Atmosphere.rho_0  = 1.225000e+00;       % Static Density at 0km Geopotential Height         [kg/m^3]
Par.Environment.Atmosphere.R      = 287.05307;          % Gas Constant                                      [J/kg*K]
Par.Environment.Atmosphere.g_n    = 9.80665;            % Earth Acceleration at 45°32'33'' Latitude         [m/s^2]
Par.Environment.Atmosphere.ga_0   = -6.500000e-03;      % Temperature Gradient for H<11km                   [K/m]

Par.Configuration.Geometry.ACS2b  =  [-1  0  0 ;... % arm transformation matrix from 
                                       0  1  0 ;... %  aircraft coord. system to body axis
                                       0  0 -1 ];

assignin('base','Par',Par);

% run simulink model

% signal 1   2   3   4   5    6   7    8    9   10             
U    = [cgx,cgy,cgz,rho, T ,tas, pst ,Thr, Mix,Amix];

k = (-nInit/100:0.01:-0.01)';
t    = [k;engIn.t];

[y] = sim('Engine',t,[],[t U]);

% access output elements with removed initialization
engOut.Xe = y.yout((nInit+1):end,4);
engOut.Ye = y.yout((nInit+1):end,5);
engOut.Ze = y.yout((nInit+1):end,6);
engOut.Le = y.yout((nInit+1):end,1);
engOut.Me = y.yout((nInit+1):end,2);
engOut.Ne = y.yout((nInit+1):end,3);
engOut.RPM= y.yout((nInit+1):end,8);
engOut.Thrust= y.yout((nInit+1):end,7);


end

