% PROCESSING OF RAW FLIGHT TEST DATA FOR A SINGLE FLIGHT
%
% Loads all cRIO and IMU data, applyies delay caused by converter filters,
% synchronizes cRIO and IMU data, signal values are converted to physical
% (calibration) and in the end error models of ADB are applyied.
% It is needed to specify the folder that contains all the raw data
% excel files + cRIO startTimes and synchronization excel file of a single 
% flight.
% Processed data is saved in a concurrent folder named 'Data' inside 
% 'Flights' folder. 
%
% Additional option is organized data based on input given in the
% signal_mapping_flight.xlsx
%
% ZHAW,	Author: David Haber-Zelanto - 05.11.2020.

clc 
clear all
close all

% add all the subfolders in this directory to the path
directory = pwd; 
addpath(genpath(directory));

% specify the folder that contains all raw data excel files + cRIO
% startTimes and synchronization excel file
Folder = uigetdir;

tic
[FT_Data] = processData(Folder);
toc

% % uncomment for organized data
% [FT_Data]=organizeData(FT_Data);

% save data
[~,name,~] = fileparts(Folder);
name = name(1:end-4);

path = fullfile(pwd,'Data','Flights',strcat(name,'.mat'));
save(path,'FT_Data');
