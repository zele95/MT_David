function []=cutToManoeuvres
%  Cuts flight test data into manoeuvres and adds fuel data
%
% Cuts flight test data into manouevres and stores them as a separate file
% with a descriptive name.
% Function takes all the flight test data from the folder 'Flights' and
% saves the manoeuvre data in the 'Manoeuvre' folder
%
% ZHAW,	Author: David Haber-Zelanto - 13.11.2020.

% add all the subfolders in this directory to the path
addpath(genpath(pwd));

% set files to process
files = dir(fullfile(pwd,'Data', 'Flights'));

%% Cut data into manoeuvres for each flight
for j=1:length(files);
    if strcmp(files(j).name, '.') || strcmp(files(j).name, '..');
        continue;
    end
    
%load meta data
name=fullfile(pwd,'Data Processing','Manoeuvre data',strcat('cutManoeuvres_',files(j).name(8:end-4),'.csv'));

cutData             = readtable(name, 'Format', '%d %d %s %s %s %s %s %s %f %f %{HH:mm:ss}D %{HH:mm:ss}D %{dd.MM.yyyy}D');
cutData.CG          = categorical(cutData.CG);
cutData.Mass        = categorical(cutData.Mass);
cutData.iniAltitude = categorical(cutData.iniAltitude);
cutData.iniSpeed    = categorical(cutData.iniSpeed);
cutData.iniPower    = categorical(cutData.iniPower);
cutData.Manoeuvre   = categorical(cutData.Manoeuvre);

cutData.Start       = cutData.Date + timeofday(cutData.Start);
cutData.End         = cutData.Date + timeofday(cutData.End);
cutData.Start       = datetime(cutData.Start,'Format','dd.MM.yyyy HH:mm:ss');
cutData.End         = datetime(cutData.End,'Format','dd.MM.yyyy HH:mm:ss');

% load flight test data
load(files(j).name);

%% iterate over test points, process data and save it
for i=1:height(cutData)
    
    % cut flight data
    range = timerange(cutData.Start(i), cutData.End(i));
    FT_MData = FT_Data(range,:);
    
    % add some parameters to the manoeuvre data
    FT_MData.Trim(:) = ones(height(FT_MData),1) * cutData.Trim(i);
    FT_MData.Fuel(:) = ones(height(FT_MData),1) * cutData.Fuel(i);
    
    
    filename = strcat('FID_', num2str(cutData.Flight_ID(i)), ...
                      '.MID_', num2str(cutData.Manoeuvre_ID(i)), ...
                      '.CG_', char(cutData.CG(i)), ...
                      '.Mass_', char(cutData.Mass(i)), ...
                      '.Alt_', char(cutData.iniAltitude(i)), ...
                      '.S_', char(cutData.iniSpeed(i)), ...
                      '.P_', char(cutData.iniPower(i)), ...
                      '.Mnvr_', char(cutData.Manoeuvre(i)));
                  
   
    save(fullfile('Data','Manoeuvres',strcat(filename,'.mat')),'FT_MData');
    
end
end
end

