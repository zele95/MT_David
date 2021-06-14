function [FT_Data_all_files,t , brk] = getData(files)
% Load flight test, Weight and balance and Engine data for a given file name
% 
% [FT_Data, t, brk] = loadFtData(files)
%
% files               structure array with the fields 'name', 'start', and
%                     'end' of the files to be loaded          
%
% FT_Data_all_files   struct containing only the necessary and corrected
%                     flight test data, extended with the mass and balance 
%                     data, propulsion data, aerodynamic coefficients and
%                     some calculated parameters
%                                                
% t                   t monotonically increasing time vector over all the 
%                     loaded data
%
% brk                 breakpoints between test points
%
% This function initializes and calls Simulink engine model and uses
% scripts for mass and inertia estimation. Also uses functions for
% aerodynamic ceofficients calculation and error model, filtering
% and data organizing functions etc.
% 
%
% ZHAW,	Author: David Haber-Zelanto - 16.10.2020.

%% LOAD MANOEUVRE FT DATA

for j=1:length(files)

    load(files(j).name);
    
    [FT_MData]=organizeData(FT_MData);
    
    % remove only field (Time) that is not double and add one for Time(double)
    FT_MData   = timetable2table(FT_MData);
    FT_MData.t = FT_MData.Time - FT_MData.Time(1);
    FT_MData.t = seconds(FT_MData.t);
    FT_MData   = removevars(FT_MData, 'Time');
    FT_MData   = movevars(FT_MData,'t','Before','Roll_angle');
    
    
    % define start and end times to cut
    idx0 = find(FT_MData.t >= files(j).start, 1);
    idxn = find(FT_MData.t <= files(j).end, 1, 'last');
    t_manoeuv = FT_MData.t - FT_MData.t(idx0);
    
    
    FT_MData.Properties.VariableNames{'t'}='Time';
    
    %% ADD WEIGHT AND BALANCE
    
    % assemble input parameter
    WnBIn.Time = FT_MData.Time;
    WnBIn.Fuel = FT_MData.Fuel;
    
    % mass and balance estimation
    [WnBOut] = getWnBData(WnBIn,files(j).name);
    
    % add WnB signals to the data
    FT_MData.Mass  = WnBOut.Mass;
    FT_MData.I_xx  = WnBOut.I_xx;
    FT_MData.I_yy  = WnBOut.I_yy;
    FT_MData.I_zz  = WnBOut.I_zz;
    FT_MData.I_xy  = WnBOut.I_xy;
    FT_MData.I_xz  = WnBOut.I_xz;
    FT_MData.I_yz  = WnBOut.I_yz;
    
    
    FT_MData.cg_x  = WnBOut.cg_x;
    FT_MData.cg_y  = WnBOut.cg_y;
    FT_MData.cg_z  = WnBOut.cg_z;
    
    %% ADD ENGINE FORCES AND MOMENTS
    
    % limit throttle values to 0-100
    FT_MData.Power_setting(FT_MData.Power_setting<0) = 0;
    FT_MData.Power_setting(FT_MData.Power_setting>100) = 100;
    
    % input signals
    engIn.t  =FT_MData.Time;
    engIn.cgx=FT_MData.cg_x;
    engIn.cgy=FT_MData.cg_y;
    engIn.cgz=FT_MData.cg_z;
    engIn.rho=FT_MData.Density;
    engIn.T  =FT_MData.Temperature;
    engIn.TAS=FT_MData.TAS;
    engIn.Altitude=FT_MData.Altitude; % should delete
    engIn.pst=FT_MData.Static_pressure;
    engIn.Thr=FT_MData.Power_setting/100;
    engIn.Mix=0.06667*ones(height(FT_MData),1);
    engIn.Amix=1*ones(height(FT_MData),1);
    engIn.RPM=FT_MData.RPM;
    
    % run simulink engine model
    [engOut] = getEngData(engIn);
    
    % engine forces and mom
    FT_MData.Xe  =  engOut.Xe;
    FT_MData.Ye  =  engOut.Ye;
    FT_MData.Ze  =  engOut.Ze;
    FT_MData.Le  =  engOut.Le;
    FT_MData.Me  =  engOut.Me;
    FT_MData.Ne  =  engOut.Ne;
    FT_MData.RPM_model =  engOut.RPM;
    FT_MData.Thrust = engOut.Thrust;
    
    %% ADDITIONAL DATA CALCULATION
    
    % constants
    b  = 10.67;      % [m], refrence wing span
    c  = 1.602;      % [m], Mean aerodynamic chord
    %% CORRECT IMU DATA
    
    % correct data for IMU misalignment of 4.75 deg
    
    angle = 4.75*pi/180;  % [rad] IMU on the baggage compartment floor (Measured on the aircraft)
    
    % Ly=[cos(angle), 0 , -sin(angle);...
    %        0,       1  ,    0;...
    %     sin(angle), 0 , cos(angle)];
    
    [FT_MData.Phi, FT_MData.Theta, FT_MData.Psi] = getCorrEulAng(FT_MData.Roll_angle, FT_MData.Pitch_angle, FT_MData.Yaw_angle, angle);   %[deg]
    
    FT_MData.Acceleration_x_b = FT_MData.Acceleration_x.*cos(angle)-FT_MData.Acceleration_z.*sin(angle); %[m/s^2]
    FT_MData.Acceleration_y_b = FT_MData.Acceleration_y;                                                 %[m/s^2]
    FT_MData.Acceleration_z_b = FT_MData.Acceleration_x.*sin(angle)+FT_MData.Acceleration_z.*cos(angle); %[m/s^2]
    
    FT_MData.p_b  = FT_MData.Roll_rate.*cos(angle)-FT_MData.Yaw_rate.*sin(angle); %[deg/s]
    FT_MData.q_b  = FT_MData.Pitch_rate;                                          %[deg/s]
    FT_MData.r_b  = FT_MData.Roll_rate.*sin(angle)+FT_MData.Yaw_rate.*cos(angle); %[deg/s]
    
    %% CORRECT ACCELERATIONS
    
    % filter p, q, r
    FT_MData.p      = lowPassFilter(FT_MData.p_b,50,0.01)*pi/180;  % [rad/s]
    FT_MData.q      = lowPassFilter(FT_MData.q_b,50,0.01)*pi/180;  % [rad/s]
    FT_MData.r      = lowPassFilter(FT_MData.r_b,50,0.01)*pi/180;  % [rad/s]
    
    % differentiate p, q, r
    FT_MData.pdot     = gradient(FT_MData.p)./gradient(FT_MData.Time);  % [rad/s^2]
    FT_MData.qdot     = gradient(FT_MData.q)./gradient(FT_MData.Time);  % [rad/s^2]
    FT_MData.rdot     = gradient(FT_MData.r)./gradient(FT_MData.Time);  % [rad/s^2]
    
    %  add position of IMU and boom to the data and correct acceleration
    
    % IMU
    x_imu = 3.3894;       % [m] from propeller tip (Flavio MT)
    y_imu = 0;            % [m] not measured = 0
    z_imu = -0.266+0.05;  % [m] measured on the aircraft -- 5cm= wooden board + IMU_height/2 (David)
    
    % ADB                                         STA106.63-(STA0->propeller tip)-ADB(rod->vanes)-rod-(spar->leading edge)
    x_boom = 1.1735;      % [m] from propeller tip, (106.63-2.2)*0.0245 - (0.42-0.185)-0.65-0.5
    y_boom = 5.31947;     % [m] from centerline (Flavio MT)
    z_boom = 0;           % [m]
    
    % calculate IMU and ADB offset and convert in body coordinates
    FT_MData.x_imu_cg = -1*(x_imu - FT_MData.cg_x); % [m]
    FT_MData.y_imu_cg =  1*(y_imu - FT_MData.cg_y); % [m]
    FT_MData.z_imu_cg = -1*(z_imu - FT_MData.cg_z); % [m]
    
    FT_MData.x_boom_cg = -1*(x_boom - FT_MData.cg_x); % [m]
    FT_MData.y_boom_cg =  1*(y_boom - FT_MData.cg_y); % [m]
    FT_MData.z_boom_cg = -1*(z_boom - FT_MData.cg_z); % [m]
    
    
    FT_MData.ax = FT_MData.Acceleration_x_b ...                                 % [m/s^2]
        + (FT_MData.q.^2    + FT_MData.r.^2) .* FT_MData.x_imu_cg ...
        - (FT_MData.p.*FT_MData.q - FT_MData.rdot) .* FT_MData.y_imu_cg ...
        - (FT_MData.p.*FT_MData.r + FT_MData.qdot) .* FT_MData.z_imu_cg;
    
    FT_MData.ay = FT_MData.Acceleration_y_b ...                                 % [m/s^2]
        - (FT_MData.p.*FT_MData.q + FT_MData.rdot) .* FT_MData.x_imu_cg ...
        + (FT_MData.p.^2    + FT_MData.r.^2) .* FT_MData.y_imu_cg ...
        - (FT_MData.q.*FT_MData.r - FT_MData.pdot) .* FT_MData.z_imu_cg;
    
    FT_MData.az = FT_MData.Acceleration_z_b ...                                 % [m/s^2]
        - (FT_MData.p.*FT_MData.r - FT_MData.qdot) .* FT_MData.x_imu_cg ...
        - (FT_MData.q.*FT_MData.r + FT_MData.pdot) .* FT_MData.y_imu_cg ...
        + (FT_MData.p.^2    + FT_MData.q.^2) .* FT_MData.z_imu_cg;
    
    % filter accelerations
    FT_MData.ax_f      = lowPassFilter(FT_MData.ax,40,0.01);  % [m/s^2]
    FT_MData.ay_f      = lowPassFilter(FT_MData.ay,40,0.01);  % [m/s^2]
    FT_MData.az_f      = lowPassFilter(FT_MData.az,40,0.01);  % [m/s^2]
    
    %% CORRECT AIR DATA
    
    % calibrate AoA, AoS and tas_adb at the boom
    [FT_MData.alpha_adb, FT_MData.beta_adb, FT_MData.tas_adb] = getCorrSens(FT_MData);
    
    % estimate u, v and w at the boom
    FT_MData.alpha_adb = FT_MData.alpha_adb*pi/180; % [rad]
    FT_MData.beta_adb  = FT_MData.beta_adb*pi/180;  % [rad]
    
    FT_MData.u_boom   = FT_MData.tas_adb .* cos(FT_MData.alpha_adb).* cos(FT_MData.beta_adb);   % [m/s] estimate for u at boom
    FT_MData.v_boom   = FT_MData.tas_adb .* sin(FT_MData.beta_adb);                             % [m/s] estimate for v at boom
    FT_MData.w_boom   = FT_MData.tas_adb .* sin(FT_MData.alpha_adb).* cos(FT_MData.beta_adb);   % [m/s] estimate for w at boom
    
    % calculate u, v and w at the CG
    [FT_MData.u_cg, FT_MData.v_cg, FT_MData.w_cg] = getCGVel( FT_MData.x_boom_cg, FT_MData.y_boom_cg, FT_MData.z_boom_cg, ...
        FT_MData.u_boom,    FT_MData.v_boom,    FT_MData.w_boom, ...
        FT_MData.p,         FT_MData.q,         FT_MData.r);
    
    % calculate corrected tas_adb, AoA and AoS at the CG
    FT_MData.TAS_cg  = sqrt(FT_MData.u_cg.^2 + FT_MData.v_cg.^2 + FT_MData.w_cg.^2);  % [m/s]
    FT_MData.AOA_cg  = atan(FT_MData.w_cg./FT_MData.u_cg);                            % [rad]
    FT_MData.AOS_cg  = asin(FT_MData.v_cg./FT_MData.TAS_cg);                          % [rad]
    
    FT_MData.alpha_adb = FT_MData.alpha_adb*180/pi; % [deg]
    FT_MData.beta_adb  = FT_MData.beta_adb*180/pi;  % [deg]
    
    FT_MData.AOA_cg = FT_MData.AOA_cg*180/pi; % [deg]
    FT_MData.AOS_cg = FT_MData.AOS_cg*180/pi; % [deg]
    
    % calculate some additional parameters
    FT_MData.ps      = b*FT_MData.p./(2*FT_MData.TAS_cg);      % p star body [-]
    FT_MData.qs      = c*FT_MData.q./(2*FT_MData.TAS_cg);      % q star body [-]
    FT_MData.rs      = b*FT_MData.r./(2*FT_MData.TAS_cg);      % r star body [-]
    
    %% compose one big table of all manoeuvres
    if j == 1
        % it's the first iteration, create variables
        FT_Data_all_files = FT_MData(idx0:idxn, :);
        t = t_manoeuv(idx0:idxn, :);
%         brk = t(1);
        brk = [];
    else
        % variables exist already, append
        FT_Data_all_files= [FT_Data_all_files; FT_MData(idx0:idxn, :)];
        brk = [brk; t(end)];
        t = [t; t(end) + t_manoeuv(idx0:idxn, :)];
    end
end
end
