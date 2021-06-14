function [Inertia_OEM, CG_OEM] = getInertiaEstiOEM


%Calculation of the Moments of Intertia in Respect to DATCOM by the USAF
%Aircraft Model: PA-28-161 Warrior III
%Registration: HB-PRL
%K. Spillmann, 19. August 2019, V1.0


run('PA28_estimation_mass_V1')

%% Variable Masses
% m_fuel_usg_left = 0;	%Volume of fuel (max. 24) [USG]
% m_fuel_left = m_fuel_usg_left*usg2lbs;	%Mass of fuel [lbs]
% m_fuel_usg_right = 0;	%Volume of fuel (max. 24) [USG]
% m_fuel_right = m_fuel_usg_right*usg2lbs;	%Mass of fuel [lbs]
% m_baggage = convmass(0,'kg','lbm');    %Mass of baggage (max. 200 lbs) [lbs]
% m_pilot = convmass(0','kg','lbm'); %Mass of pilot and front passenger [lbs]
% m_pax = convmass(0,'kg','lbm');  %Mass of rear passengers [lbs]
% m_total = m_empty;

%% Origin of Remote Coordinate System
x_dir = 96.683;                                                         % [in], Dist to STA 44.5
y_dir = 0.0;                                                            % [in], Dist to BL 0.0
z_dir = 59.055;                                                         % [in], Dist to WL 40.0
x_0 = x_dir-44.5;                                                       % [in], Origin of x-axis from acft ref. axis
y_0 = y_dir;                                                            % [in], Origin of y-axis from acft ref. axis
% z_0 = z_dir-40.0;                                                       % [in], Origin of z-axis from acft ref. axis

%% Fuselage
x_fuselage = 165.904*0.98;                                                   % [in], Position of fuselage centroid location in x-direction (Ref. CAD)
y_fuselage = y_0;                                                       % [in], Position of fuselage centroid location in y-direction (Ref. AFM)
z_fuselage = 60.63;                                                     % [in], Position of fuselage centroid location in z-direction (Ref. CAD)

l_fuselage = 273.978;                                                   % [in], Fuselage length incl. nacelle and spinner (Ref. CAD)
d_max = convlength(1.05,'m','in');                                      % [in], Max. fuselage diameter (Ref. Jane's All The World's Aircraft 1987-88)
w_max = convlength(1.24,'m','in');                                      % [in], Max. fuselage width (Ref. Jane's All The World's Aircraft 1987-88)
d_avg = (d_max+w_max)/2;                                                % [in], Average max. diameter of fueslage
S_fuselage = 3.297e4;                                                   % [in^2], Fuselage wetted area (Ref. CAD)
% x_mean_fuselage = 126.534;                                              % [in], Longitudinal centroidal distance of fuselage from nose (Ref. CAD)

% ref_K_2 = abs(l_fuselage/2-x_mean_fuselage)/(l_fuselage/2);
K_2 = 0.91;                                                             % [-], Correction factor (Ref. DATCOM Fig. 8.1-24)
% ref_K_3 = sqrt(d_avg)*m_fstructure/m_fuselage;
K_3 = 0.225;                                                            % [-], Correction factor (Ref. DATCOM Fig. 8.1-25)

moment_x_fuselage = x_fuselage*m_fuselage;                              % [lbs*in]
moment_y_fuselage = y_fuselage*m_fuselage;                              % [lbs*in]
moment_z_fuselage = z_fuselage*m_fuselage;                              % [lbs*in]
moment_x2_fuselage = x_fuselage^2*m_fuselage;                           % [lbs*in^2]
moment_y2_fuselage = y_fuselage^2*m_fuselage;                           % [lbs*in^2]
moment_z2_fuselage = z_fuselage^2*m_fuselage;                           % [lbs*in^2]

I_ox_fuselage = m_fuselage*K_3/4*(S_fuselage/pi/l_fuselage)^2;          % [lbs*in^2]
I_oy_fuselage = m_fuselage*S_fuselage*K_2/37.68*(3*d_avg/2/l_fuselage+l_fuselage/d_avg); %[lbs*in^2]
I_oz_fuselage = I_oy_fuselage;                                          % [lbs*in^2]

%% Wing
x_wing = 148.786*0.98;                                                       % [in], Position of wing centroid location in x-direction (Ref. CAD)
y_wing = y_0;                                                           % [in], Position of wing centroid location in y-direction (Ref. CAD)
z_wing = 54.538;                                                        % [in], Position of wing centroid location in z-direction (Ref. CAD)

Lambda_le_W = deg2rad(5);                                               % [rad], Sweep of wing leading edge (Ref. Jane's All The World's Aircraft 1987-88)
b_wing = convlength(35,'ft','in');                                      % [in], Wing span (Ref. AFM)
c_r_wing = convlength(2.20,'m','in');                                   % [in], Root chord length at plane of symmetry (Ref. CAD)
c_t_wing = convlength(3.52,'ft','in');                                  % [in], Tip chord length of wing (Ref. AFM)
% y_mean_wing = convlength(2.505,'m','in');                               % [in], Lateral centroidal distance of half-wing from acft plane of symmetry (Ref. CAD)

C_a_wing = b_wing*tan(Lambda_le_W)/2;                                   % Wing parametr measured parallel to plane of symmetry
C_b_wing = c_t_wing+b_wing*tan(Lambda_le_W)/2;                          % Wing parameter measured parallel to plane of symmetry
C_c_wing = c_r_wing;                                                    % Wing parametr measured parallel to plane of symmetry

rho_wing = m_wing/0.5/(-C_a_wing+C_b_wing+C_c_wing);                    % [-], Ratio of Mass to chord for wing shapes
m_wing_x = rho_wing/6*(-C_a_wing^2+C_b_wing^2+C_b_wing*C_c_wing+C_c_wing^2);

K_0_wing = 0.703;                                                       % [-], Correction factor for any wing design
% ref_K_1 = y_mean_wing/(b_wing/6*(c_r_wing+2*c_t_wing)/(c_r_wing+c_t_wing));
K_1 = 0.94;                                                             % [-], Correction factor (Ref. DATCOM Fig. 8.1-23)

moment_x_wing = x_wing*m_wing;                                          % [lbs*in]
moment_y_wing = y_wing*m_wing;                                          % [lbs*in]
moment_z_wing = z_wing*m_wing;                                          % [lbs*in]
moment_x2_wing = x_wing^2*m_wing;                                       % [lbs*in^2]
moment_y2_wing = y_wing^2*m_wing;                                       % [lbs*in^2]
moment_z2_wing = z_wing^2*m_wing;                                       % [lbs*in^2]

I_wing = rho_wing/12*(-C_a_wing^3+C_b_wing^3+C_c_wing^2*C_b_wing+C_c_wing*C_b_wing^2+C_c_wing^3);
I_ox_wing = m_wing*b_wing^2*K_1/24*(c_r_wing+3*c_t_wing)/(c_r_wing+c_t_wing); % [lbs*in^2]
I_oy_wing = K_0_wing*(I_wing-m_wing_x^2/m_wing);                        % [lbs*in^2]
I_oz_wing = I_oy_wing+I_ox_wing;                                        % [lbs*in^2]

%% Stabilator
x_stabilator = 297.328*0.98;                                                 % [in], Position of stabilator centroid location in x-direction (Ref. CAD)
y_stabilator = y_0;                                                     % [in], Position of stabilator centroid location in y-direction (Ref. CAD)
z_stabilator = 65.002;                                                  % [in], Position of stabilator centroid location in z-direction (Ref. CAD)

Lambda_le_stabilator = deg2rad(0);                                      % [rad], Sweep of stabilator leading edge (Ref. AFM)
b_stabilator = convlength(12.98,'ft','in');                             % [in], Stabilator span (Ref. AFM)
c_r_stabilator = convlength(2.5,'ft','in');                             % [in], Root chord length of stabilator at plane of symmetry (Ref. AFM)
c_t_stabilator = c_r_stabilator;                                        % [in], Tip chord length of stabilator
% y_mean_stabilator = 33.41;                                              % [in], Lateral centroidal distance of half-stabilator from acft plane of symmetry (Ref. CAD)

C_a_stabilator = b_stabilator*tan(Lambda_le_stabilator)/2;
C_b_stabilator = c_t_stabilator+b_stabilator*tan(Lambda_le_stabilator)/2;
C_c_stabilator = c_r_stabilator;

rho_stabilator = m_stabilator/2/(-C_a_stabilator+C_b_stabilator+C_c_stabilator);
m_stabilator_x = rho_stabilator/6*(-C_a_stabilator^2+C_b_stabilator^2+C_b_stabilator*C_c_stabilator+C_c_stabilator^2);

K_0_stabilator = 0.771;                                                 % [-], Correction factor for any tail surface
% ref_K_4 = y_mean_stabilator/(b_stabilator/6*(c_r_stabilator+2*c_t_stabilator)/(c_r_stabilator+c_t_stabilator));
K_4 = 0.64;                                                             % [-], Correction factor (Ref. DATCOM Fig. 8.1-26)

moment_x_stabilator = x_stabilator*m_stabilator;                        % [lbs*in]
moment_y_stabilator = y_stabilator*m_stabilator;                        % [lbs*in]
moment_z_stabilator = z_stabilator*m_stabilator;                        % [lbs*in]
moment_x2_stabilator = x_stabilator^2*m_stabilator;                     % [lbs*in^2]
moment_y2_stabilator = y_stabilator^2*m_stabilator;                     % [lbs*in^2]
moment_z2_stabilator = z_stabilator^2*m_stabilator;                     % [lbs*in^2]

I_stabilator = rho_stabilator/12*(-C_a_stabilator^3+C_b_stabilator^3+C_c_stabilator^2*C_b_stabilator+C_c_stabilator*C_b_stabilator^2+C_c_stabilator^3);
I_ox_stabilator = m_stabilator*b_stabilator^2*K_4/24*(c_r_stabilator+3*c_t_stabilator)/(c_r_stabilator+c_t_stabilator); % [lbs*in^2]
I_oy_stabilator = K_0_stabilator*(I_stabilator-m_stabilator_x^2/m_stabilator); % [lbs*in^2]
I_oz_stabilator = I_oy_stabilator+I_ox_stabilator;                      % [lbs*in^2]

%% Vertical Stabilizer
x_vertical = 289.543*0.98;                                                   % [in], Position of vertical stabilizer centroid location in x-direction (Ref. CAD)
y_vertical = y_0;                                                       % [in], Position of vertical stabilizer centroid location in y-direction (Ref. CAD)
z_vertical = 86.116;                                                    % [in], Position of vertical stabilizer centroid location in z-direction (Ref. CAD)

Lambda_le_vertical = deg2rad(36);                                       % [rad], Sweep of vertical stabilizer leading edge (Ref. CAD)
b_vertical = convlength(1.469,'m','in');                                % [in], Vertical stabilizer span (Ref. CAD)
c_r_vertical = convlength(1.394,'m','in');                              % [in], Root chord length of vertical stabilizer at fuselage (Ref. CAD)
c_t_vertical = convlength(0.575521,'m','in');                           % [in], Tip chord length of vertical stabilizer (Ref. CAD)
% z_mean_vertical = convlength(0.508,'m','in');                           % [in], Vertical centroidal distance of vertical stabilizer from its theoretical root chord (Ref. CAD)
C_a_vertical = b_vertical*tan(Lambda_le_vertical);
C_b_vertical = c_t_vertical+b_vertical*tan(Lambda_le_vertical);
C_c_vertical = c_r_vertical;

rho_vertical = m_vertical/2/(-C_a_vertical+C_b_vertical+C_c_vertical);
m_vertical_x = rho_vertical/6*(-C_a_vertical^2+C_b_vertical^2+C_b_vertical*C_c_vertical+C_c_vertical^2);

K_0_vertical = 0.771;                                                   % [-], Correction factor for any tail surface
% ref_K_5 = z_mean_vertical/(b_vertical/3*(c_r_vertical+2*c_t_vertical)/(c_r_vertical+c_t_vertical));
K_5 = 0.74;                                                             % [-], Correction factor (Ref. DATCOM Fig. 8.1-27)

moment_x_vertical = x_vertical*m_vertical;                              % [lbs*in]
moment_y_vertical = y_vertical*m_vertical;                              % [lbs*in]
moment_z_vertical = z_vertical*m_vertical;                              % [lbs*in]
moment_x2_vertical = x_vertical^2*m_vertical;                           % [lbs*in^2]
moment_y2_vertical = y_vertical^2*m_vertical;                           % [lbs*in^2]
moment_z2_vertical = z_vertical^2*m_vertical;                           % [lbs*in^2]

I_vertical = rho_vertical/12*(-C_a_vertical^3+C_b_vertical^3+C_c_vertical^2*C_b_vertical+C_c_vertical*C_b_vertical^2+C_c_vertical^3);
I_ox_vertical = m_vertical*b_vertical^2*K_5/18*(1+(2*c_r_vertical*c_t_vertical)/(c_r_vertical+c_t_vertical)^2); % [lbs*in^2]
I_oz_vertical = K_0_vertical*(I_vertical-m_vertical_x^2/m_vertical);    % [lbs*in^2]
I_oy_vertical = I_ox_vertical+I_oz_vertical;                            % [lbs*in^2]

%% Power Plant
x_pplant = 81.863*0.98;                                                      % [in], Position of power plant centroid location in x-direction (Ref. CAD)
y_pplant = y_0;                                                         % [in], Position of power plant centroid location in y-direction (Ref. CAD)
z_pplant = 55.253;                                                      % [in], Position of power plant centroid location in z-direction (Ref. CAD)

l_engine = 29.05+7.0;                                                   % [in], Length of engine inlc. spinner (Ref. O-320 Operator Manual & AMM)
d_engine = 32.24;                                                       % [in], Avg. diameter of engine (Ref. O-320 Operator Manual)
l_nacelle = 36.516;                                                     % [in], Length of nacelle (Ref. CAD)

moment_x_pplant = x_pplant*m_pplant;                                    % [lbs*in]
moment_y_pplant = y_pplant*m_pplant;                                    % [lbs*in]
moment_z_pplant = z_pplant*m_pplant;                                    % [lbs*in]
moment_x2_pplant = x_pplant^2*m_pplant;                                 % [lbs*in^2]
moment_y2_pplant = y_pplant^2*m_pplant;                                 % [lbs*in^2]
moment_z2_pplant = z_pplant^2*m_pplant;                                 % [lbs*in^2]

I_oy_pplant = 0.061*(0.75*m_pplant*d_engine^2+m_engine*l_engine^2+(m_pplant-m_engine)*l_nacelle^2); % [lbs*in^2]
I_ox_pplant = 0.083*m_pplant*d_engine^2;                                % [lbs*in^2]
I_oz_pplant = I_oy_pplant;                                              % [lbs*in^2]

%% Gear
x_gear_nose = 79.136*0.98;                                                   % [in], Position of gear centroid location in x-direction (Ref. CAD)
y_gear_nose = y_0;                                                      % [in], Position of gear centroid location in y-direction (Ref. AFM)
z_gear_nose = 17.758;                                                   % [in], Position of gear centroid location in z-direction (Ref. CAD)

x_gear_main_left = 157.089*0.98;                                             % [in], Position of gear centroid location in x-direction (Ref. CAD)
y_gear_main_left = 61.039;                                              % [in], Position of gear centroid location in y-direction (Ref. CAD)
z_gear_main_left = 25.745;                                              % [in], Position of gear centroid location in z-direction (Ref. CAD)

x_gear_main_right = 157.089*0.98;                                            % [in], Position of gear centroid location in x-direction (Ref. CAD)
y_gear_main_right = -61.039;                                            % [in], Position of gear centroid location in y-direction (Ref. CAD)
z_gear_main_right = 25.745;                                             % [in], Position of gear centroid location in z-direction (Ref. CAD)

r_gear_nose = 5;                                                        % [in], Gear radius (Ref. AFM)
r_gear_main_left = 6;                                                   % [in], Gear radius (Ref. AFM)
r_gear_main_right = 6;                                                  % [in], Gear radius (Ref. AFM)

moment_x_gear_nose = x_gear_nose*m_gear/3;                              % [lbs*in]
moment_y_gear_nose = y_gear_nose*m_gear/3;                              % [lbs*in]
moment_z_gear_nose = z_gear_nose*m_gear/3;                              % [lbs*in]
moment_x2_gear_nose = x_gear_nose^2*m_gear/3;                           % [lbs*in^2]
moment_y2_gear_nose = y_gear_nose^2*m_gear/3;                           % [lbs*in^2]
moment_z2_gear_nose = z_gear_nose^2*m_gear/3;                           % [lbs*in^2]

moment_x_gear_main_left = x_gear_main_left*m_gear/3;                    % [lbs*in]
moment_y_gear_main_left = y_gear_main_left*m_gear/3;                    % [lbs*in]
moment_z_gear_main_left = z_gear_main_left*m_gear/3;                    % [lbs*in]
moment_x2_gear_main_left = x_gear_main_left^2*m_gear/3;                 % [lbs*in^2]
moment_y2_gear_main_left = y_gear_main_left^2*m_gear/3;                 % [lbs*in^2]
moment_z2_gear_main_left = z_gear_main_left^2*m_gear/3;                 % [lbs*in^2]

moment_x_gear_main_right = x_gear_main_right*m_gear/3;                  % [lbs*in]
moment_y_gear_main_right = y_gear_main_right*m_gear/3;                  % [lbs*in]
moment_z_gear_main_right = z_gear_main_right*m_gear/3;                  % [lbs*in]
moment_x2_gear_main_right = x_gear_main_right^2*m_gear/3;               % [lbs*in^2]
moment_y2_gear_main_right = y_gear_main_right^2*m_gear/3;               % [lbs*in^2]
moment_z2_gear_main_right = z_gear_main_right^2*m_gear/3;               % [lbs*in^2]

I_ox_gear_nose = 2/5*m_gear/3*r_gear_nose^2;                            % [lbs*in^2]
I_oy_gear_nose = I_ox_gear_nose;                                        % [lbs*in^2]
I_oz_gear_nose = I_ox_gear_nose;                                        % [lbs*in^2]

I_ox_gear_main_left = 2/5*m_gear/3*r_gear_main_left^2;                  % [lbs*in^2]
I_oy_gear_main_left = I_ox_gear_main_left;                              % [lbs*in^2]
I_oz_gear_main_left = I_ox_gear_main_left;                              % [lbs*in^2]

I_ox_gear_main_right = 2/5*m_gear/3*r_gear_main_right^2;                % [lbs*in^2]
I_oy_gear_main_right = I_ox_gear_main_right;                            % [lbs*in^2]
I_oz_gear_main_right = I_ox_gear_main_right;                            % [lbs*in^2]

%% Fuel
% x_fuel_left = x_0+95.0+80.6-78.4;                                       % [in], Position of fuel centroid location in x-direction (Ref. AFM & AMM)
% y_fuel_left = y_0-mean([88.75 57.00]);                                  % [in], Position of fuel centroid location in y-direction (Ref. AFM)
% z_fuel_left = z_0+20;                                                   % [in], Position of fuel centroid location in z-direction (Ref. estimated CAD)
% 
% x_fuel_right = x_0+95.0+80.6-78.4;                                      % [in], Position of fuel centroid location in x-direction (Ref. AFM & AMM)
% y_fuel_right = y_0+mean([88.75 57.00]);                                 % [in], Position of fuel centroid location in y-direction (Ref. AFM)
% z_fuel_right = z_0+20;                                                  % [in], Position of fuel centroid location in z-direction (Ref. estimated CAD)
% 
% w_tank = 29;                                                            % [in], Width of fuel tank (estimated)
% l_tank = 24;                                                            % [in], Length of fuel tank (estimated)
% h_tank = 16;                                                            % [in], Height of fuel tank (estimated)
% 
% moment_x_fuel_left = x_fuel_left*m_fuel_left;                           % [lbs*in]
% moment_y_fuel_left = y_fuel_left*m_fuel_left;                           % [lbs*in]
% moment_z_fuel_left = z_fuel_left*m_fuel_left;                           % [lbs*in]
% moment_x2_fuel_left = x_fuel_left^2*m_fuel_left;                        % [lbs*in^2]
% moment_y2_fuel_left = y_fuel_left^2*m_fuel_left;                        % [lbs*in^2]
% moment_z2_fuel_left = z_fuel_left^2*m_fuel_left;                        % [lbs*in^2]
% 
% moment_x_fuel_right = x_fuel_right*m_fuel_right;                        % [lbs*in]
% moment_y_fuel_right = y_fuel_right*m_fuel_right;                        % [lbs*in]
% moment_z_fuel_right = z_fuel_right*m_fuel_right;                        % [lbs*in]
% moment_x2_fuel_right = x_fuel_right^2*m_fuel_right;                     % [lbs*in^2]
% moment_y2_fuel_right = y_fuel_right^2*m_fuel_right;                     % [lbs*in^2]
% moment_z2_fuel_right = z_fuel_right^2*m_fuel_right;                     % [lbs*in^2]
% 
% I_ox_fuel_left = m_fuel_left/12*(w_tank^2+h_tank^2);                    % [lbs*in^2]
% I_oy_fuel_left = m_fuel_left/12*(l_tank^2+h_tank^2);                    % [lbs*in^2]
% I_oz_fuel_left = m_fuel_left/12*(l_tank^2+w_tank^2);                    % [lbs*in^2]
% 
% I_ox_fuel_right = m_fuel_right/12*(w_tank^2+h_tank^2);                  % [lbs*in^2]
% I_oy_fuel_right = m_fuel_right/12*(l_tank^2+h_tank^2);                  % [lbs*in^2]
% I_oz_fuel_right = m_fuel_right/12*(l_tank^2+w_tank^2);                  % [lbs*in^2]
% 
% %% Baggage
% x_baggage = x_0+142.8+80.6-78.4;                                        % [in], Position of cargo centroid location in x-direction (Ref. AFM & AMM)
% y_baggage = y_0;                                                        % [in], Position of cargo centroid location in y-direction (Ref. AFM)
% z_baggage = z_0+20;                                                     % [in], Position of cargo centroid location in z-direction (Ref. estimated CAD)
% 
% w_baggage = 33;                                                         % [in], Width of cargo (estimated)
% l_baggage = 27;                                                         % [in], Length of cargo (estimated)
% h_baggage = 47;                                                         % [in], Height of cargo (estimated)
% 
% moment_x_baggage = x_baggage*m_baggage;                                 % [lbs*in]
% moment_y_baggage = y_baggage*m_baggage;                                 % [lbs*in]
% moment_z_baggage = z_baggage*m_baggage;                                 % [lbs*in]
% moment_x2_baggage = x_baggage^2*m_baggage;                              % [lbs*in^2]
% moment_y2_baggage = y_baggage^2*m_baggage;                              % [lbs*in^2]
% moment_z2_baggage = z_baggage^2*m_baggage;                              % [lbs*in^2]
% 
% I_ox_baggage = m_baggage/12*(w_baggage^2+h_baggage^2);                  % [lbs*in^2]
% I_oy_baggage = m_baggage/12*(l_baggage^2+h_baggage^2);                  % [lbs*in^2]
% I_oz_baggage = m_baggage/12*(l_baggage^2+w_baggage^2);                  % [lbs*in^2]
% 
% %% Passengers and Pilot
% x_pilot = x_0+80.5+80.6-78.4;                                           % [in], Position of crew centroid location in x-direction (Ref. AFM & AMM)
% y_pilot = y_0;                                                          % [in], Position of crew centroid location in y-direction (Ref. AFM)
% z_pilot = z_0+40;                                                       % [in], Position of crew centroid location in z-direction (Ref. estimated CAD)
% 
% w_pilot = 33;                                                           % [in], Width of crew (estimated)
% l_pilot = 15;                                                           % [in], Length of crew (estimated)
% h_pilot = 50;                                                           % [in], Height of crew (estimated)
% 
% moment_x_pilot = x_pilot*m_pilot;                                       % [lbs*in]
% moment_y_pilot = y_pilot*m_pilot;                                       % [lbs*in]
% moment_z_pilot = z_pilot*m_pilot;                                       % [lbs*in]
% moment_x2_pilot = x_pilot^2*m_pilot;                                    % [lbs*in^2]
% moment_y2_pilot = y_pilot^2*m_pilot;                                    % [lbs*in^2]
% moment_z2_pilot = z_pilot^2*m_pilot;                                    % [lbs*in^2]
% 
% I_ox_pilot = m_pilot/12*(w_pilot^2+h_pilot^2);                          % [lbs*in^2]
% I_oy_pilot = m_pilot/12*(l_pilot^2+h_pilot^2);                          % [lbs*in^2]
% I_oz_pilot = m_pilot/12*(l_pilot^2+w_pilot^2);                          % [lbs*in^2]
% 
% x_pax = x_0+118.1+80.6-78.4;                                            % [in], Position of payload centroid location in x-direction (Ref. AFM & AMM)
% y_pax = y_0;                                                            % [in], Position of payload centroid location in y-direction (Ref. AFM)
% z_pax = z_0+40;                                                         % [in], Position of payload centroid location in z-direction (Ref. estimated CAD)
% w_pax = 33;                                                             % [in], Width of pax (estimated)
% l_pax = 15;                                                             % [in], Length of pax (estimated)
% h_pax = 50;                                                             % [in], Height of pax (estimated)
% 
% moment_x_pax = x_pax*m_pax;                                             % [lbs*in]
% moment_y_pax = y_pax*m_pax;                                             % [lbs*in]
% moment_z_pax = z_pax*m_pax;                                             % [lbs*in]
% moment_x2_pax = x_pax^2*m_pax;                                          % [lbs*in^2]
% moment_y2_pax = y_pax^2*m_pax;                                          % [lbs*in^2]
% moment_z2_pax = z_pax^2*m_pax;                                          % [lbs*in^2]
% 
% I_ox_pax = m_pax/12*(w_pax^2+h_pax^2);                                  % [lbs*in^2]
% I_oy_pax = m_pax/12*(l_pax^2+h_pax^2);                                  % [lbs*in^2]
% I_oz_pax = m_pax/12*(l_pax^2+w_pax^2);                                  % [lbs*in^2]

%% Products of Mass and Centroid Locations
moment_x_total = moment_x_wing+moment_x_stabilator+moment_x_vertical+...
                 moment_x_fuselage+moment_x_pplant+...
                 moment_x_gear_nose+moment_x_gear_main_left+...
                 moment_x_gear_main_right;  % [lbs*in]
moment_y_total = moment_y_wing+moment_y_stabilator+moment_y_vertical+...
                 moment_y_fuselage+moment_y_pplant+...
                 moment_y_gear_nose+moment_y_gear_main_left+...
                 moment_y_gear_main_right;  % [lbs*in]
moment_z_total = moment_z_wing+moment_z_stabilator+moment_z_vertical+...
                 moment_z_fuselage+moment_z_pplant+...
                 moment_z_gear_nose+moment_z_gear_main_left+...
                 moment_z_gear_main_right;  % [lbs*in]

moment_x2_total = moment_x2_wing+moment_x2_stabilator+...
                  moment_x2_vertical+moment_x2_fuselage+...
                  moment_x2_pplant+...
                  moment_x2_gear_nose+moment_x2_gear_main_left+...
                  moment_x2_gear_main_right;                                      % [lbs*in^2]
moment_y2_total = moment_y2_wing+moment_y2_stabilator+...
                  moment_y2_vertical+moment_y2_fuselage+...
                  moment_y2_pplant+...
                  moment_y2_gear_nose+moment_y2_gear_main_left+...
                  moment_y2_gear_main_right;                                      % [lbs*in^2]
moment_z2_total = moment_z2_wing+moment_z2_stabilator+...
                  moment_z2_vertical+moment_z2_fuselage+...
                  moment_z2_pplant+...
                  moment_z2_gear_nose+moment_z2_gear_main_left+...
                  moment_z2_gear_main_right;                                      % [lbs*in^2]

%% Inertia about the Remote Axis
I_ox_total = I_ox_wing+I_ox_vertical+I_ox_stabilator+I_ox_fuselage+...
             I_ox_gear_nose+I_ox_gear_main_left+I_ox_gear_main_right+I_ox_pplant;                                                  % [lbs*in^2]
I_oy_total = I_oy_wing+I_oy_vertical+I_oy_stabilator+I_oy_fuselage+...
             I_oy_gear_nose+I_oy_gear_main_left+I_oy_gear_main_right+I_oy_pplant;                                                  % [lbs*in^2]
I_oz_total = I_oz_wing+I_oz_vertical+I_oz_stabilator+I_oz_fuselage+...
             I_oz_gear_nose+I_oz_gear_main_left+I_oz_gear_main_right+I_oz_pplant;                                                  % [lbs*in^2]

I_x = moment_y2_total+moment_z2_total+I_ox_total;                       % [lbs*in^2]
I_y = moment_x2_total+moment_z2_total+I_oy_total;                       % [lbs*in^2]
I_z = moment_y2_total+moment_x2_total+I_oz_total;                       % [lbs*in^2]

%% Inertia about Aircraft Centroid
lbsin2Toslugft2 = 1/144/32.17;                                          % Conversion factor from lbs-in^2 to slug-ft^2
slugft22kgm2 = 1.355817961893;                                          % Conversion factor from slug*ft^2 to kg*m^2

I_xx_lbs = I_x-(moment_y_total^2+moment_z_total^2)/m_empty;             % [lbs*in^2], Rolling
I_yy_lbs = I_y-(moment_x_total^2+moment_z_total^2)/m_empty;             % [lbs*in^2], Pitching
I_zz_lbs = I_z-(moment_x_total^2+moment_y_total^2)/m_empty;             % [lbs*in^2], Yawing

I_xx_slug = I_xx_lbs*lbsin2Toslugft2;                                   % [slug*ft^2]
I_yy_slug = I_yy_lbs*lbsin2Toslugft2;                                   % [slug*ft^2]
I_zz_slug = I_zz_lbs*lbsin2Toslugft2;                                   % [slug*ft^2]

I_xx = I_xx_slug*slugft22kgm2;                                          % [kg*m^2]
I_yy = I_yy_slug*slugft22kgm2;                                          % [kg*m^2]
I_zz = I_zz_slug*slugft22kgm2;                                          % [kg*m^2]
        
Inertia_OEM.I_xx = I_xx;
Inertia_OEM.I_yy = I_yy;
Inertia_OEM.I_zz = I_zz;
      


%% Center of gravity position
in2m = 0.0254;


CG_OEM.cg_x = (moment_x_total/m_empty-(x_0+2.2))*in2m;
CG_OEM.cg_y = (moment_y_total/m_empty-y_0)*in2m;
CG_OEM.cg_z = (moment_z_total/m_empty-z_dir)*in2m;
%% Ixz moment of inertia estimation

% fuselage
x_fuselage_cg = x_fuselage-(x_0+2.2)-CG_OEM.cg_x*1/in2m;
z_fuselage_cg = z_fuselage-z_dir-CG_OEM.cg_z*1/in2m;
moment_xz_fuselage = m_fuselage*x_fuselage_cg*z_fuselage_cg;

% wing
x_wing_cg = x_wing-(x_0+2.2)-CG_OEM.cg_x*1/in2m;
z_wing_cg = z_wing-z_dir-CG_OEM.cg_z*1/in2m;
moment_xz_wing = m_wing*x_wing_cg*z_wing_cg;

% horizontal stabilizer
x_stabilator_cg = x_stabilator-(x_0+2.2)-CG_OEM.cg_x*1/in2m;
z_stabilator_cg = z_stabilator-z_dir-CG_OEM.cg_z*1/in2m;
moment_xz_stabilator = m_stabilator*x_stabilator_cg*z_stabilator_cg;

% vertical stabilizer
x_vertical_cg = x_vertical-(x_0+2.2)-CG_OEM.cg_x*1/in2m;
z_vertical_cg = z_vertical-z_dir-CG_OEM.cg_z*1/in2m;
moment_xz_vertical = m_vertical*x_vertical_cg*z_vertical_cg;

% power plant
x_pplant_cg = x_pplant-(x_0+2.2)-CG_OEM.cg_x*1/in2m;
z_pplant_cg = z_pplant-z_dir-CG_OEM.cg_z*1/in2m;
moment_xz_pplant = m_pplant*x_pplant_cg*z_pplant_cg;

% gear
x_gear_nose_cg = x_gear_nose-(x_0+2.2)-CG_OEM.cg_x*1/in2m;
z_gear_nose_cg = z_gear_nose-z_dir-CG_OEM.cg_z*1/in2m;
moment_xz_gear_nose = m_gear/3*x_gear_nose_cg*z_gear_nose_cg;

x_gear_main_left_cg = x_gear_main_left-(x_0+2.2)-CG_OEM.cg_x*1/in2m;
z_gear_main_left_cg = z_gear_main_left-z_dir-CG_OEM.cg_z*1/in2m;
moment_xz_gear_main_left = m_gear/3*x_gear_main_left_cg*z_gear_main_left_cg;

x_gear_main_right_cg = x_gear_main_right-(x_0+2.2)-CG_OEM.cg_x*1/in2m;
z_gear_main_right_cg = z_gear_main_right-z_dir-CG_OEM.cg_z*1/in2m;
moment_xz_gear_main_right = m_gear/3*x_gear_main_right_cg*z_gear_main_right_cg;

% sum of all sections
moment_xz_total = moment_xz_wing+moment_xz_stabilator+...
                  moment_xz_vertical+moment_xz_fuselage+...
                  moment_xz_pplant+...
                  moment_xz_gear_nose+moment_xz_gear_main_left+...
                  moment_xz_gear_main_right
 moment_xy_total = 0;  
 moment_yz_total = 0; 
% considering all subsections are symetrical            
I_oxy_total = 0;             
I_oxz_total = 0; 
I_oyz_total = 0;

% total cross moment
Inertia_OEM.I_xy = (I_oxy_total+moment_xy_total)*lbsin2Toslugft2*slugft22kgm2;
Inertia_OEM.I_xz = (I_oxz_total+moment_xz_total)*lbsin2Toslugft2*slugft22kgm2;
Inertia_OEM.I_yz = (I_oyz_total+moment_yz_total)*lbsin2Toslugft2*slugft22kgm2;
end