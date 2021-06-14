% ESTIMATION OF CY
%
%
% Loads only necessary FT Data for chosen manoeuvres, adds mass and balance
% values as well as engine forces and moments and calculates aerodynamic
% coefficients. Modelling and regression is done aswell.
%
%
% ZHAW,	Author: David Haber-Zelanto - 08.12.2020.

clear variables
close all

% add all the subfolders in this directory to the path
addpath(genpath(pwd));

filterAccels = true;

%% SELECT MANOEUVRES

files = struct('name', {}, 'start', {}, 'end', {});

%% shss

files(end+1) = struct('name',{'FID_1.MID_109.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);%good
files(end+1) = struct('name',{'FID_1.MID_110.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);%good
% files(end+1) = struct('name',{'FID_1.MID_117.CG_FWD.Mass_M.Alt_DESC.S_M.P_L.Mnvr_SHSS.mat'},'start', 0,'end', 10000);

files(end+1) = struct('name',{'FID_7.MID_112.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_7.MID_118.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_7.MID_119.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_SHSS.mat'},'start', 0,'end', 10000);

files(end+1) = struct('name',{'FID_11.MID_114.CG_FWD.Mass_M.Alt_M.S_L.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);%good
% % files(end+1) = struct('name',{'FID_11.MID_1151.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_11.MID_1152.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);%good
% files(end+1) = struct('name',{'FID_11.MID_1161.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_11.MID_1162.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);%good

% % files(end+1) = struct('name',{'FID_15.MID_111.CG_FWD.Mass_M.Alt_M.S_M.P_M.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_15.MID_120.CG_FWD.Mass_M.Alt_M.S_M.P_H.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_15.MID_180.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_15.MID_181.CG_FWD.Mass_M.Alt_M.S_M.P_H.Mnvr_SHSS.mat'},'start', 0,'end', 10000);

files(end+1) = struct('name',{'FID_16.MID_187.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_16.MID_188.CG_FWD.Mass_M.Alt_M.S_M.P_L.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_16.MID_189.CG_FWD.Mass_M.Alt_M.S_M.P_H.Mnvr_SHSS.mat'},'start', 0,'end', 10000);
files(end+1) = struct('name',{'FID_16.MID_190.CG_FWD.Mass_M.Alt_M.S_M.P_H.Mnvr_SHSS.mat'},'start', 0,'end', 10000);

%% FLIGHT TEST DATA + WEIGHT AND BALANCE + ENGINE FORCES AND MOMENTS 

[FT_MData, t , brk] = getData(files);

%% AERODYNAMIC COEFFICIENTS CALCULATION

[FT_MData] = getAeroCoeff(FT_MData,filterAccels);

%% MODELLING
FT_MData.AOS_cg = FT_MData.AOS_cg*pi/180;

[theta, FT_MData.Cy_pred] = ols_fit(FT_MData, 'Cy', {'1', 'AOS_cg'});

% [theta, FT_MData.Cy_pred] = ols_fit(FT_MData, 'Cy', {'1', 'AOS_cg','Rudder','ps','rs'});



%% RESULTS

plotting(t, brk , FT_MData)

% estimation
figure
plot(t,FT_MData.Cy)
hold on
plot(t,FT_MData.Cy_pred)
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
xlabel('t [s]')
ylabel('C_Y')
legend('C_Y','C_Y estimated')
set(gca,'FontSize',15)
% title('REGRESSION')



