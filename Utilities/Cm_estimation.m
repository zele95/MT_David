% ESTIMATION OF Cm
%
%
% Loads only necessary FT Data for chosen manoeuvres, adds mass and balance
% values as well as engine forces and moments and calculates aerodynamic
% coefficients. Modelling and regression is done aswell.
%
%
% ZHAW,	Author: David Haber-Zelanto - 16.10.2020.

clear variables
close all

% add all the subfolders in this directory to the path
addpath(genpath(pwd));

filterAccels = false;

%% SELECT MANOEUVRES

files = struct('name', {}, 'start', {}, 'end', {});

%% short period

files(end+1) = struct('name',{'FID_2.MID_2.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_2.MID_3.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_2.MID_31.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 15);
% files(end+1) = struct('name',{'FID_2.MID_1009.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);

% % files(end+1) = struct('name',{'FID_6.MID_33.CG_AFT.Mass_M.Alt_M.S_H.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% % files(end+1) = struct('name',{'FID_6.MID_34.CG_AFT.Mass_M.Alt_M.S_H.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% % files(end+1) = struct('name',{'FID_6.MID_35.CG_AFT.Mass_M.Alt_M.S_H.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% % files(end+1) = struct('name',{'FID_6.MID_36.CG_AFT.Mass_M.Alt_M.S_H.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_6.MID_37.CG_AFT.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 8);
% % files(end+1) = struct('name',{'FID_6.MID_38.CG_AFT.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_6.MID_39.CG_AFT.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_6.MID_42.CG_AFT.Mass_M.Alt_H.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% % files(end+1) = struct('name',{'FID_6.MID_401.CG_AFT.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_6.MID_402.CG_AFT.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_6.MID_411.CG_AFT.Mass_M.Alt_H.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_6.MID_412.CG_AFT.Mass_M.Alt_H.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);

files(end+1) = struct('name',{'FID_7.MID_8.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_7.MID_9.CG_FWD.Mass_M.Alt_M.S_H.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_7.MID_10.CG_FWD.Mass_M.Alt_M.S_H.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_7.MID_11.CG_FWD.Mass_M.Alt_M.S_H.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_7.MID_12.CG_FWD.Mass_M.Alt_M.S_H.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_7.MID_13.CG_FWD.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 6,'end', 20);
% files(end+1) = struct('name',{'FID_7.MID_51.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_7.MID_1010.CG_FWD.Mass_M.Alt_H.S_M.P_H.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_7.MID_1013.CG_FWD.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 6,'end', 20);
files(end+1) = struct('name',{'FID_11.MID_14.CG_FWD.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 20);
files(end+1) = struct('name',{'FID_11.MID_15.CG_FWD.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 20);
files(end+1) = struct('name',{'FID_11.MID_16.CG_FWD.Mass_M.Alt_H.S_L.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
 
% files(end+1) = struct('name',{'FID_11.MID_17.CG_FWD.Mass_M.Alt_H.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_11.MID_18.CG_FWD.Mass_M.Alt_H.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_11.MID_19.CG_FWD.Mass_M.Alt_H.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_11.MID_20.CG_FWD.Mass_M.Alt_H.S_M.P_M.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_11.MID_52.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);

files(end+1) = struct('name',{'FID_15.MID_49.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000); 
files(end+1) = struct('name',{'FID_15.MID_50.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);

files(end+1) = struct('name',{'FID_16.MID_30.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_16.MID_31.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_ShortPeriod.mat'},'start', 0,'end', 10000);

%% stall

% % % files(end+1) = struct('name',{'FID_2.MID_163.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Stall.mat'},'start', 0,'end', 27);
% % % files(end+1) = struct('name',{'FID_6.MID_1661.CG_AFT.Mass_M.Alt_M.S_M.P_M.Mnvr_Stall.mat'},'start', 0,'end', 17);
% % % files(end+1) = struct('name',{'FID_6.MID_1662.CG_AFT.Mass_M.Alt_M.S_M.P_M.Mnvr_Stall.mat'},'start', 0,'end', 13);
% % % files(end+1) = struct('name',{'FID_7.MID_113.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_Stall.mat'},'start', 0,'end', 60);
files(end+1) = struct('name',{'FID_7.MID_164.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Stall.mat'},'start', 0,'end', 77);%good
% % % files(end+1) = struct('name',{'FID_11.MID_1014.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_Stall.mat'},'start', 0, 'end', 43);
files(end+1) = struct('name',{'FID_15.MID_162.CG_FWD.Mass_M.Alt_M.S_M.P_IDLE.Mnvr_Stall.mat'},'start', 0,'end', 41);%good
files(end+1) = struct('name',{'FID_15.MID_177.CG_FWD.Mass_M.Alt_M.S_M.P_2400.Mnvr_Stall.mat'},'start', 0,'end', 47);%good
files(end+1) = struct('name',{'FID_15.MID_178.CG_FWD.Mass_M.Alt_M.S_M.P_2400.Mnvr_Stall.mat'},'start', 0,'end', 43);%good
files(end+1) = struct('name',{'FID_15.MID_179.CG_FWD.Mass_M.Alt_M.S_M.P_2400.Mnvr_Stall.mat'},'start', 0,'end', 45);%good

%% FLIGHT TEST DATA + WEIGHT AND BALANCE + ENGINE FORCES AND MOMENTS 

[FT_MData, t , brk] = getData(files);

%% AERODYNAMIC COEFFICIENTS CALCULATION

[FT_MData] = getAeroCoeff(FT_MData,filterAccels);

%% MODELLING

FT_MData.AOA_cg = FT_MData.AOA_cg*pi/180;
FT_MData.Elevator = FT_MData.Elevator*pi/180;


% [theta, FT_MData.Cm_pred] = ols_fit(FT_MData, 'Cm', {'1', 'AOA_cg','qs','Elevator'});

[theta, FT_MData.Cm_pred] = ols_fit(FT_MData, 'Cm', {'1', 'AOA_cg','qs','Elevator','CT'});




% simulink model in ReDSim
% Cm0 =  0.070;
% Cm_alpha = -1.023;
% Cm_q = -6.348;
% Cm_de = -0.603;
% FT_MData.Cm_sim = Cm0 + Cm_alpha.*FT_MData.AOA_cg*pi/180 + Cm_q.*FT_MData.qs + Cm_de.*FT_MData.Elevator*pi/180;

%% PLOTTING

plotting(t, brk , FT_MData)

% estimation
figure
plot(t,FT_MData.Cm)
hold on
plot(t,FT_MData.Cm_pred)
% plot(t,FT_MData.Cm_sim)
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
xlabel('t [s]')
ylabel('C_m [-]')
% legend('Cm','Cm estimated','Cm simulator')
legend('Cm','Cm estimated')
set(gca,'FontSize',15)
% title('REGRESSION')




