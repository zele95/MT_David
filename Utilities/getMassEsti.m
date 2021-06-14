function [Mass] = getMassEsti
% returns necessary mass values for inertia estimation
%
%[Mass] = getMassEsti
%
% Mass    structure with mass values
%
% function uses Kevin's script for mass estimation
%
% ZHAW,	Author: David Haber-Zelanto - 20.10.2020.


%Estimation of Mass Distribution in Respect to Roskam Cessna Method and CAD Reference File
%Aircraft Model: PA-28-161 Warrior III
%Registration: HB-PRL
%K. Spillmann, 19. August 2019, V1.0

%% Wing Mass
S_wing  = 170;                                                          % [ft^2], Wing area
n_limit = 4.4;                                                          % [g], Limit load factor (Ref. AFM)
s_f     = 1.5;                                                          % [-], Safety factor
n_ult   = n_limit*s_f;                                                  % [g], Design ultimate load factor
b_wing  = convlength(35,'ft','in');                                     % [in], Wing span (Ref. AFM)
AR_wing	= convlength(b_wing,'in','ft')^2/S_wing;                        % [-], Wing aspect ratio
m_to = 2440;                                                            % [lbs], Take-off mass (Ref. AFM)

% [lbs], Mass of wing (Ref. Roskam Part V, Chp. 5, Eq. 5.2)
m_wing = 0.04674*m_to^0.397*S_wing^0.360*n_ult^0.397*AR_wing^1.712;

Mass.m_wing = m_wing;

%% Stabilator Mass
S_stabilator = 26.5;                                                    % [ft^2], Stabilator area (Ref. Jane's All The World's Aircraft 1987-88)
b_stabilator = convlength(12.98,'ft','in');                             % [in], Stabilator span (Ref. AFM)
AR_stabilator = convlength(b_stabilator,'in','ft')^2/S_stabilator;      % [-], Stabilator aspect ratio
c_r_stabilator = convlength(2.5,'ft','in');                             % [in], Root chord length of stabilator at plane of symmetry (Ref. AFM)
t_r_stabilator = 0.12*convlength(c_r_stabilator,'in','ft');             % [ft], Stabilator max. root thickness (Ref. assumed NACA 0012 profile)

% [lbs], Mass of stabilator (Ref. Roskam Part V, Chp. 5, Eq. 5.12)
m_stabilator = 3.184*m_to^0.887*S_stabilator^0.101*AR_stabilator^0.138/174.04/t_r_stabilator^0.223;

Mass.m_stabilator = m_stabilator;

%% Vertical Stabilizer Mass
Lambda_le_vertical = deg2rad(36);                                       % [rad], Sweep of vertical stabilizer leading edge (Ref. CAD)
b_vertical = convlength(1.469,'m','in');                                % [in], Vertical stabilizer span (Ref. CAD)
c_r_vertical = convlength(1.394,'m','in');                              % [in], Root chord length of vertical stabilizer at fuselage (Ref. CAD)
S_vertical = 7.4+4.1;                                                   % [ft^2], Vertical tail area (Ref. Jane's All The World's Aircraft 1987-88)
AR_vertical = convlength(b_vertical,'in','ft')^2/S_vertical;            % [-], Vertical stabilator aspect ratio
t_r_vertical = 0.10*convlength(c_r_vertical,'in','ft');                 % [ft], Vertical stabilizer max. root thickness (Ref. assumed NACA 0010 profile)
Lambda_quarter_vertical = Lambda_le_vertical;                           % [rad], Sweep of vertical stabilizer at quarter chord

% [lbs], Mass of vertical stabilizer (Ref. Roskam Part V, Chp. 5, Eq. 5.13)
m_vertical = 1.68*m_to^0.567*S_vertical^1.249*AR_vertical^0.482/(639.95*t_r_vertical^0.747*cos(Lambda_quarter_vertical)^0.882);	

Mass.m_vertical = m_vertical;

%% Power Plant Masses
k_fsp = 5.87;                                                           % [lbs/gal], Correction factor for AVGAS (Ref. Roskam Part V, Chp. 6, Eq. 6.15)
usg2lbs = 5.99;                                                         % [lbs/USG], Conversion factor form USG to lbs (Ref. https://www.caa.govt.nz/assets/legacy/Publications/Other/Fuel-Conversion-Stickers-AVGAS.pdf)

m_fuel_usg_left = 17;                                                   % [USG], Volume of fuel (max. 24)
m_fuel_left = m_fuel_usg_left*usg2lbs;                                  % [lbs], Mass of fuel
m_fuel_usg_right = 17;                                                  % [USG], Volume of fuel (max. 24)
m_fuel_right = m_fuel_usg_right*usg2lbs;                                % [lbs], Mass of fuel
m_trappedFluids = 2*usg2lbs+2*6.4;                                      % [lbs], Mass of trapped fluids (AVGAS and oil)
m_engine = 281;                                                         % [lbs], Mass of engine (Ref. O-320 Operator Manual)
m_prop = 42;                                                            % [lbs], Mass of propeller (Ref. Website of Sensenich)
m_fs = 0.40*(m_fuel_left+m_fuel_right)/k_fsp;                           % [lbs], Mass of fuel system (Ref. Roskam Part V, Chp. 6, Eq. 6.15)

% [lbs], Mass of power plant
m_pplant = m_engine+m_prop+m_fs+m_trappedFluids;

Mass.m_pplant = m_pplant;
Mass.m_engine = m_engine;

%% Gear Mass
m_ldg = m_to;                                                           % [lbs], Design landing weight
n_ultl = 5.7;                                                           % [-], Ultimate load factor for landing (Ref. Roskam Part V, Chp. 5, Eq. 5.38)
l_s_m = convlength(4.5,'in','ft');                                      % [ft], Shock strut length for main gear (Ref. AMM)	
l_s_n = convlength(3.25,'in','ft');                                     % [ft], Shock strut length for nose gear (Ref. AMM)	

% [lbs], Mass of gear (Ref. Roskam Part V, Chp. 5, Eq. 5.38)
m_gear = 0.013*m_to+0.362*m_ldg^0.417*n_ultl^0.950*l_s_m^0.183+6.2+0.0013*m_to+0.007157*m_ldg^0.749*n_ultl*l_s_n^0.788;

Mass.m_gear = m_gear;

%% Fuselage Masses
w_max = convlength(1.24,'m','in');                                      % [in], Max. fuselage width (Ref. Jane's All The World's Aircraft 1987-88)
p_max = convlength(w_max,'in','ft');                                    % [ft], Max. fuselage perimeter
l_fn = convlength(216.665,'in','ft');                                   % [ft], Fuselage lenght without nacelle (Ref. CAD)
N_pax = 4;                                                              % [-], Number of passengers incl. crew
K_n = 0.24;                                                             % [lbs/hp], Correction factor for horizontal opposed engines
P_to = 160;                                                             % [HP], Take-off power

m_nacelle = K_n*P_to;                                                   % [lbs], Mass of nacelle (Ref. Roskam Part V, Chp. 5, Eq. 5.29)
m_fstructure = 0.04682*m_to^0.692*p_max^0.374*l_fn^0.590;               % [lbs], Mass of fuselage structure (Ref. Roskam Part V, Chp. 5, Eq. 5.23)
m_fc = 0.0168*m_to;                                                     % [lbs], Mass of flight control system (Ref. Roskam Part V, Chp. 7, Eq. 7.2)
m_els = 0.0268*m_to;                                                    % [lbs], Mass of electrical system(Ref. Roskam Part V, Chp. 7, Eq. 7.13)
m_iae = convmass(50,'kg','lbm');                                        % [lbs], Mass of instruments, avionics and electrics (estimated)
m_various = convmass(136,'kg','lbm');                                   % [lbs], Various masses not considered elsewhere (estimated)
m_fur = 0.412*N_pax^1.145*m_to^0.489;                                   % [lbs], Mass of furnishing(Ref. Roskam Part V, Chp. 7, Eq. 7.41)
m_fixEquip = m_fc+m_iae+m_els+m_fur+m_various;                          % [lbs], Mass of fixed equipment

% [lbs], fuselage mass
m_fuselage = m_fstructure+m_fixEquip+m_nacelle;

Mass.m_fuselage = m_fuselage;
Mass.m_fstructure = m_fstructure;

%% Empty Mass
m_empty = m_wing+m_fuselage+m_gear+m_stabilator+m_vertical+m_pplant;    % [lbs], Empty mass
OEM = convmass(m_empty,'lbm','kg');                                     % [kg], Operating empty mass

%% Baggage
m_baggage = convmass(10,'kg','lbm');                                    % [lbs], Mass of baggage (max. 200 lbs)

Mass.m_baggage = m_baggage;

%% Passengers and Pilot
m_pilot = convmass(82+70,'kg','lbm');                                   % [lbs], Mass of pilot and front passenger
m_pax = convmass(1+1,'kg','lbm');                                       % [lbs], Mass of rear passengers

m_pax = m_pax;

%% Total Mass
m_total = m_empty+m_fuel_left+m_fuel_right+m_pax+m_pilot+m_baggage;     % [lbs], Actual take-off mass which should be less than 2440 lbs
ATOM = convmass(m_total,'lbm','kg');                                    % [kg], Actual take-off mass which should be less than 1107 kg

end