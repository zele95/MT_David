% ESTIMATION OF CL
%
%
% Loads only necessary FT Data for chosen manoeuvres, adds mass and balance
% values as well as engine forces and moments and calculates aerodynamic
% coefficients. Modelling and regression is done aswell.
%
%
% ZHAW,	Author: David Haber-Zelanto - 08.12.2020.

clear variables
% close all

% add all the subfolders in this directory to the path
addpath(genpath(pwd));

filterAccels = true;

%% SELECT MANOEUVRES 

files = struct('name', {}, 'start', {}, 'end', {});

%% phugoid 

% % % files(end+1) = struct('name',{'FID_1.MID_53.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
% % % files(end+1) = struct('name',{'FID_1.MID_54.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
% % % files(end+1) = struct('name',{'FID_1.MID_55.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_2.MID_55.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_6.MID_63.CG_AFT.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_6.MID_64.CG_AFT.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
% % % files(end+1) = struct('name',{'FID_6.MID_65.CG_AFT.Mass_M.Alt_H.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_7.MID_56.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
% % % files(end+1) = struct('name',{'FID_7.MID_57.CG_FWD.Mass_M.Alt_H.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
% % % files(end+1) = struct('name',{'FID_11.MID_58.CG_FWD.Mass_M.Alt_H.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
% files(end+1) = struct('name',{'FID_11.MID_59.CG_FWD.Mass_M.Alt_H.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
% % % files(end+1) = struct('name',{'FID_11.MID_60.CG_FWD.Mass_M.Alt_H.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
% % % files(end+1) = struct('name',{'FID_16.MID_66.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_16.MID_67.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Phugoid.mat'},'start', 0,'end', 10000);

%% stall

files(end+1) = struct('name',{'FID_2.MID_163.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Stall.mat'},'start', 0,'end', 27);
files(end+1) = struct('name',{'FID_6.MID_1661.CG_AFT.Mass_M.Alt_M.S_M.P_M.Mnvr_Stall.mat'},'start', 0,'end', 24);
files(end+1) = struct('name',{'FID_6.MID_1662.CG_AFT.Mass_M.Alt_M.S_M.P_M.Mnvr_Stall.mat'},'start', 0,'end', 15);
% files(end+1) = struct('name',{'FID_7.MID_113.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_Stall.mat'},'start', 0,'end', 50);
files(end+1) = struct('name',{'FID_7.MID_164.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_Stall.mat'},'start', 0,'end', 77);
files(end+1) = struct('name',{'FID_11.MID_1014.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_Stall.mat'},'start', 0, 'end', 43);
files(end+1) = struct('name',{'FID_15.MID_162.CG_FWD.Mass_M.Alt_M.S_M.P_IDLE.Mnvr_Stall.mat'},'start', 0,'end', 43);
files(end+1) = struct('name',{'FID_15.MID_177.CG_FWD.Mass_M.Alt_M.S_M.P_2400.Mnvr_Stall.mat'},'start', 0,'end', 47);
files(end+1) = struct('name',{'FID_15.MID_178.CG_FWD.Mass_M.Alt_M.S_M.P_2400.Mnvr_Stall.mat'},'start', 0,'end', 43);
files(end+1) = struct('name',{'FID_15.MID_179.CG_FWD.Mass_M.Alt_M.S_M.P_2400.Mnvr_Stall.mat'},'start', 0,'end', 45);

%% climb
% files(end+1) = struct('name',{'FID_6.MID_1001.CG_AFT.Mass_M.Alt_4000.S_L.P_H.Mnvr_Climb.mat'},'start', 0,'end',10000);


%% FLIGHT TEST DATA + WEIGHT AND BALANCE + ENGINE FORCES AND MOMENTS 

[FT_MData, t , brk] = getData(files);

%% AERODYNAMIC COEFFICIENTS CALCULATION

[FT_MData] = getAeroCoeff(FT_MData,filterAccels);

%% MODELLING
FT_MData.AOA_cg = FT_MData.AOA_cg*pi/180;
FT_MData.Elevator = FT_MData.Elevator*pi/180;

% [theta, FT_MData.CL_pred] = ols_fit(FT_MData, 'CL', {'1', 'AOA_cg','AOS_cg'});
% [theta, FT_MData.CL_pred] = ols_fit(FT_MData, 'CL', {'1', 'AOA_cg','AOS_cg','Elevator'});
% [theta, FT_MData.CL_pred] = ols_fit(FT_MData, 'CL', {'1', 'AOA_cg','Elevator','qs','CT'});

% [theta, FT_MData.CL_pred] = ols_fit(FT_MData, 'CL', {'1', 'AOA_cg','Elevator','qs'});

[theta, FT_MData.CL_pred] = ols_fit(FT_MData, 'CL', {'1', 'AOA_cg','Elevator','qs','CT'});


%% PLOTTING

plotting(t, brk , FT_MData)

% estimation
figure
plot(t,FT_MData.CL)
hold on
plot(t,FT_MData.CL_pred)
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
xlabel('t [s]')
ylabel('C_L')
legend('CL','CL estimated')
set(gca,'FontSize',15)
% title('REGRESSION')



