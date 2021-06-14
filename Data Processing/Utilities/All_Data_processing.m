% PROCESSING OF RAW FLIGHT TEST DATA FOR ALL FLIGHTS
%
% Uses processData function which loads all cRIO and IMU data, applyies 
% delay caused by converter filters, synchronizes cRIO and IMU data, signal
% values are converted to physical(calibration) and in the end error models
% of ADB are applyied. 
% Flight data is also cut into manoeuvres.
%
% It is needed to specify the folder that contains all 
% the raw data folders of all the flights.
% Processed data is saved in a concurrent folder named 'Data' inside 
% 'Flights' folder. 
%
% Additional option is organized data based on input given in the
% signal_mapping_flight.xlsx
%
% ZHAW,	Author: David Haber-Zelanto - 10.11.2020.

clc 
clear all
close all


% add all the subfolders in this directory to the path
directory = pwd; 
addpath(genpath(directory));

% choose folder with all raw flight data folders
rawDataFolder = uigetdir;
Path = strcat(rawDataFolder,'\');

% get all the raw folders
RawFoldersList = dir(Path);
RawFoldersList = RawFoldersList([RawFoldersList(:).isdir]);

for i= 1:length(RawFoldersList);
    if strcmp(RawFoldersList(i).name, '.') || strcmp(RawFoldersList(i).name, '..');
        continue;
    end
    
 Folder=fullfile(RawFoldersList(i).folder,RawFoldersList(i).name);
    

[FT_Data] = processData(Folder);

  
% uncomment for organized data
% [FT_Data]=organizeData(FT_Data); 
 

[~,name,~] = fileparts(Folder);
name = name(1:end-4);

path = fullfile(pwd,'Data','Flights',strcat(name,'.mat'));
save(path,'FT_Data');

clear FT_Data Folder
end

cutToManoeuvres;