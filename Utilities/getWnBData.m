function [WnBOut] = getWnBData(WnBIn,manouvreName)
% Calculates inertia and cg position for fuel amount and crew configuration
% 
% [WnBOut] = getWnBData(WnBIn)
%
% WnBIn      structure containing time and fuel amount        
%
% WnBOut     struct containing moments of inertia and cg position
%
% This function uses mass and inertia estimation functions. Crew
% configuration is computed from the file name that is set as a local
% variable
% 
% ZHAW,	Author: David Haber-Zelanto - 01.12.2020.

% constant masses
pilotMass = 82;       % [kg] Hans(he was flying on all considered flights)
Kevin     = 70;       % [kg]
Flavio    = 66;       % [kg]
acEmpty   = 751.67;   % [kg] From weighting=estimate
baggage   = 10;       % [kg]

% empty mass estimation
[Mass] = getMassEsti ;

% conversion
usg2l    = 3.785;        % [l/USG]
avgasRho = 0.719;        % [kg/l]; (Ref. https://aviationdirect.co.za/conversion-table/)
usg2lbs  = 5.99;         % [lbs/USG], Conversion factor form USG to lbs (Ref. https://www.caa.govt.nz/assets/legacy/Publications/Other/Fuel-Conversion-Stickers-AVGAS.pdf)


% variable masses for different flights
copilotMass  = 1;         % for equipment when fte is sitting back
paxLeftMass  = 1;         % for equipment in the back seat
paxRightMass = 1;

% Flavio attended only flights 1,3 and 16
if contains(manouvreName, 'FID_1.') || contains(manouvreName, 'FID_16') 
    fteMass = Flavio;
    else
    fteMass = Kevin;
end

% AFT CG- fte sitting back
if contains(manouvreName,'FWD')
    copilotMass = fteMass;
    
else
    paxRightMass = fteMass; 
 
end

% for inertiaEsti
Mass.m_pilot    = convmass(pilotMass,'kg','lbm');
Mass.m_copilot  = convmass(copilotMass,'kg','lbm');
Mass.m_paxLeft  = convmass(paxLeftMass,'kg','lbm');
Mass.m_paxRight = convmass(paxRightMass,'kg','lbm');

% remaining fuel amount
fuelRemaining =  WnBIn.Fuel(1)* usg2l * avgasRho;   % [kg]

% fuel for inertia estimation
m_fuel_usg_left = WnBIn.Fuel(1)/2;                  % [USG], Volume of fuel (max. 24)
Mass.m_fuel_left = m_fuel_usg_left*usg2lbs;
m_fuel_usg_right = WnBIn.Fuel(1)/2;                 % [USG], Volume of fuel (max. 24)
Mass.m_fuel_right = m_fuel_usg_right*usg2lbs;

% actual aircraft mass
zeroFuelWeight = pilotMass + copilotMass  + paxLeftMass + paxRightMass + acEmpty + baggage;
ATOM =  zeroFuelWeight + fuelRemaining;              % [kg] actually not ATOM but actual mass
WnBOut.Mass = ones(length(WnBIn.Time),1) * ATOM;     % [kg]
% for inertiaEsti
Mass.m_aircraftMass = convmass(ATOM,'kg','lbm');     % [lbs]

% inertia and cg
[Inertia, CG] = getInertiaEsti(Mass);

% inertia moments around cg in aircraft coordinates
WnBOut.I_xx = Inertia.I_xx*ones(length(WnBIn.Fuel),1);
WnBOut.I_yy = Inertia.I_yy*ones(length(WnBIn.Fuel),1);
WnBOut.I_zz = Inertia.I_zz*ones(length(WnBIn.Fuel),1);
WnBOut.I_xy = Inertia.I_xy*ones(length(WnBIn.Fuel),1);
WnBOut.I_xz = Inertia.I_xz*ones(length(WnBIn.Fuel),1);
WnBOut.I_yz = Inertia.I_yz*ones(length(WnBIn.Fuel),1);


% cg position from propeller tip in aircraft coordinate system
WnBOut.cg_x = CG.cg_x*ones(length(WnBIn.Fuel),1); %positive backwards
WnBOut.cg_y = CG.cg_y*ones(length(WnBIn.Fuel),1); %positive right
WnBOut.cg_z = CG.cg_z*ones(length(WnBIn.Fuel),1); %positive upwards

end