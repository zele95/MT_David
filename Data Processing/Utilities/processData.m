function [FT_Data] = processData(Folder)
% Load all cRIO and IMU raw data and return processed file
%
% [FT_Data] = processData(Folder)
%
% Folder    folder that contains all the raw data excel files + cRIO
%           startTimes and synchronization excel file of a single flight.
%
% FT_Data   struc containing all processed flight test data for a single
%           flight
%
% Loads all cRIO and IMU data, applyies delay caused by converter filters,
% synchronizes cRIO and IMU data, signal values are converted to physical
% (calibration) and in the end error models of ADB are applyied.
%
% DAVID COMMENT: All calculations are made by Flavio and this script 
% resembles Flavio's calculations, made in his original scripts, to get the
% same results. Not all results (depending  on the flight) are exactly the 
% same (though neglectable) so the prediction is that Flavio modifyied his 
% scripts for different flights (mostly considering retiming and 
% synchronizing the tables on the different places in the script). There is
% space to make modifications and slightly more correct data..
%
% Constructed and symplified from Flavio's A_AfterFlightProcessing_v3.mat
% and B_fromRaw2Values_V2.mat
%
% ZHAW,	Author: David Haber-Zelanto - 10.11.2020.


%% 0. GET ALL THE FILES OF A SINGLE FLIGHT RAW DATA

% add all the subfolders in this directory to the path
directory = pwd; 
addpath(genpath(directory));

% Folder = uigetdir;
Path = strcat(Folder,'\');

% get all the files
FileList = [dir(strcat(Path, '*.csv')); dir(strcat(Path, '*.xlsx'))];

for i=1:9
    FileList(i).whole = strcat(FileList(i).folder, '\' , FileList(i).name);
end

%% 1. IMPORTING DATA, INTRODUCING DELAYS AND SYNCHRONIZING IMU AND cRIO DATA
%% Import IMU Data

% import imu data
basicData = readtable(FileList(1).whole,'Format','%{yyyy-MM-dd}D%{HH:mm:ss.SSS}D%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%C%f%f','HeaderLines',31);  %%skipped first 2 rows like Flavio!!! dont know why 
basicData.Properties.VariableNames = {'GPSDate','GPSTime','GPSTimeS','Roll','RollStd','Pitch','PitchStd','Yaw','YawStd','DeltaVelocityX','DeltaVelocityY','DeltaVelocityZ','TotalAcceleration','DeltaAngleX','DeltaAngleY','DeltaAngleZ','TotalRotationRate','XAcceleration', 'YAcceleration','ZAcceleration','AltitudeMSL','PositionType','Latitude','Longitude'};

% import adb reference imu data 
ADBData = readtable(FileList(2).whole,'Format','%{yyyy-MM-dd}D%f%f%f%f%f%f%f%f','HeaderLines',16);  %%skipped first row of data like Flavio!! he probably missed it
ADBData.Properties.VariableNames = {'GPSDate','GPSTime','DeltaVelocityX_ADB','DeltaVelocityY_ADB','DeltaVelocityZ_ADB','TotalAcceleration_ADB','XAcceleration_ADB', 'YAcceleration_ADB','ZAcceleration_ADB'};

% import marker data
markerData = readtable(FileList(3).whole,'Format','%{yyyy-MM-dd}D%{HH:mm:ss.SSS}D','HeaderLines',9);  %%skipped first row of data like Flavio!! he probably missed it
markerData.Properties.VariableNames = {'GPSDate','GPSTime'};
markerData.GPSTime.Second = round(markerData.GPSTime.Second./5,3)*5;

% DAVID COMMENT:
% Flavio did not import first row of the data (that is actually neglectable),
% synchronization is made by Flavio and how he imported the data so it 
% is better to leave it like this and dont mess up the synchronization

%% Merge IMU Data

% merge with adb reference data and convert to timetable
basicData = [basicData, ADBData(:,3:end)];

basicData.GPSTime = basicData.GPSDate + timeofday(basicData.GPSTime);
imuData = table2timetable(basicData,'RowTimes',basicData.GPSTime);

imuData.GPSTime = [];
imuData.GPSDate=[];  
imuData.GPSTimeS = [];
imuData.PositionType = [];


% merge with marker data
markerData.imuMarkerID = (1:1:height(markerData))';
markerData.GPSTime = markerData.GPSDate + timeofday(markerData.GPSTime);
imuMarkerData = table2timetable(markerData,'RowTimes',markerData.GPSTime);

imuMarkerData.GPSTime= [];
imuMarkerData.GPSDate = [];

data = synchronize(imuData, imuMarkerData);

%% Importing cRIO data

% import start times of each converter
startTimes = readtable(FileList(8).whole,'DatetimeType' ,'datetime');

shift= duration('02:00:00.000');  % because of the time difference of IMU and cRIO

% import 5 Hz data
table5Hz = readtable(FileList(4).whole);

startTime = startTimes.startTime(1)-shift;
startTime = datetime(startTimes.startDate(1)+startTime,'Format','HH:mm:ss.SSS');

table5Hz.RecordingTime = (startTime:seconds(0.2):(startTime+(height(table5Hz)-1)*seconds(0.2)))';
table5Hz = table2timetable(table5Hz,'RowTimes',table5Hz.RecordingTime);
table5Hz.RecordingTime = [];

% import 100 Hz data
table100Hz = readtable(FileList(5).whole);

startTime = startTimes.startTime(2)-shift;
startTime = datetime(startTimes.startDate(2)+startTime,'Format','HH:mm:ss.SSS');

table100Hz.RecordingTime = (startTime:seconds(0.01):(startTime+(height(table100Hz)-1)*seconds(0.01)))';
table100Hz = table2timetable(table100Hz,'RowTimes',table100Hz.RecordingTime);
table100Hz.RecordingTime = [];
    
% import 1613 Hz data
table1613Hz = readtable(FileList(6).whole);

startTime = startTimes.startTime(3)-shift;
startTime = datetime(startTimes.startDate(3)+startTime,'Format','HH:mm:ss.SSS');

table1613Hz.RecordingTime = (startTime:seconds(0.00060546875):(startTime+(height(table1613Hz)-1)*seconds(0.00060546875)))';
table1613Hz = table2timetable(table1613Hz,'RowTimes',table1613Hz.RecordingTime);
table1613Hz.RecordingTime = [];
    
% import 1000 Hz data
table10000Hz = readtable(FileList(7).whole);

startTime = startTimes.startTime(4)-shift;
startTime = datetime(startTimes.startDate(4)+startTime,'Format','HH:mm:ss.SSS');

table10000Hz.RecordingTime = (startTime:seconds(9.9945068359375E-05):(startTime+(height(table10000Hz)-1)*seconds(9.9945068359375E-05)))';
table10000Hz = table2timetable(table10000Hz,'RowTimes',table10000Hz.RecordingTime);
table10000Hz.RecordingTime = [];

rpmSamplingRate = 1/9.9945068359375E-05;
table10000Hz.crioRPMcorr = tachorpm(table10000Hz.RPM,rpmSamplingRate,'FitType','linear');
table10000Hz.RPM = [];

%% cRIO data time shift cause of filters

% delays (calculated by Flavio)
delayNI9208 = 0.007614569;
delayNI9219 = 0.00864522;
delayNI9222 = 0.008566032;
delayNI9237 = 0.024229163;

delayNI9208 = round(delayNI9208 / 0.01);
delayNI9219 = round(delayNI9219 / 0.01);
delayNI9222 = round(delayNI9222 / 9.9945068359375E-05);
delayNI9237 = round(delayNI9237 / 0.00060546875);

% apply delay to 1613Hz data
table1613Hz = lag(table1613Hz, -delayNI9237);

% apply delay to 1000Hz data
table10000Hz = lag(table10000Hz, -delayNI9222);
table10000Hz = retime(table10000Hz,'regular','linear','TimeStep',seconds(0.01));

% apply delay to 100Hz data, pressure data has a different delay
table100HzPressure = table100Hz(:,1:2);
table100HzPressure = lag(table100HzPressure, -delayNI9208);

table100Hz.Pressure0 = [];
table100Hz.Pressure1 = [];
table100Hz = lag(table100Hz, -delayNI9219);

table100Hz = synchronize(table100Hz, table100HzPressure);

% synchronization of cRIO data
crioTable = synchronize(table5Hz, table100Hz);
crioTable = synchronize(crioTable, table1613Hz);
crioTable = synchronize(crioTable, table10000Hz);

% resample all cRIO data to 0.01 sec
crioTable = retime(crioTable,'regular','linear','TimeStep',seconds(0.01));

crioTable.crioMarker = crioTable.Marker;
crioTable.Marker = [];

%% Merge IMU and cRIO data

% extract marker times
crioMarker = crioTable.Time(find(crioTable.crioMarker < -10));
crioMarker = datetime(crioMarker,'Format','dd.MM.yyyy HH:mm:ss.SSSSS');

imuMarker = data.Time(find(~isnan(data.imuMarkerID)));
imuMarker = datetime(imuMarker,'Format','dd.MM.yyyy HH:mm:ss.SSSSS');

% import Flavio's synchronization
syncing = readtable(FileList(9).whole);

% calculate IMU and cRIO time shift
refTime =  crioMarker(syncing.value(1));
refTime.Second = syncing.value(2);
dtCrioMinImu = refTime - imuMarker(syncing.value(3));

dtCrioMinImu = duration(dtCrioMinImu, 'Format', 'hh:mm:ss.SSSSS');
dtCrioMinImu = seconds(dtCrioMinImu);
dtCrioMinImu = round(dtCrioMinImu / 0.01);

% apply time shift to cRIO data
crioTable = lag(crioTable, -dtCrioMinImu);

% resample IMU data to 0.01 seconds
data = retime(data,'regular','linear','TimeStep',seconds(0.01));
data.imuMarkerID = [];

% synchronize IMU and cRIO data
data = synchronize(data, crioTable);

% unneccesary step that i keep just to have the same results like Flavio(it gives one row more to data)
imuMarkerData.Time = datetime(imuMarkerData.Time,'Format','HH:mm:ss.SSSSS');
imuMarkerData.Time.Second = round(imuMarkerData.Time.Second,2);
data = synchronize(data, imuMarkerData);
% DAVID COMMENT: could be removed 

data.Time = datetime(data.Time,'Format','dd.MM.yyyy HH:mm:ss.SSS');

% to see if synchronization by markers is done correctly
figure
plot(data.Time, data.imuMarkerID*0+1,'rx');
hold on
plot(crioTable.Time, -crioTable.crioMarker,'b');
xlabel('Time')
ylabel('Voltage [V]');
title('Synchronization by markers');
legend('IMU Marker Signal(Marker ID)','cRIO Marker Signal')

% remove marker data
data.imuMarkerID=[];
data.crioMarker= [];


% Rename for proper description
data.Properties.VariableNames(1:27)=strcat('imu',data.Properties.VariableNames(1:27));

data.Properties.VariableNames{'OAT0'} = 'crioTATraw';
data.Properties.VariableNames{'OAT1'} = 'crioSensorTempRaw';
data.Properties.VariableNames{'Pressure0'} = 'crioStaticPressureRaw';
data.Properties.VariableNames{'Pressure1'} = 'crioDynamicPressureRaw';
data.Properties.VariableNames{'RelativeHumidity'} = 'crioRelativeHumidityRaw';
data.Properties.VariableNames{'AOAAOS0'} = 'crioAOAraw';
data.Properties.VariableNames{'AOAAOS1'} = 'crioAOSraw';
data.Properties.VariableNames{'Deflection0'} = 'crioAileronRaw';
data.Properties.VariableNames{'Deflection1'} = 'crioElevatorRaw';
data.Properties.VariableNames{'Deflection2'} = 'crioRudderRaw';
data.Properties.VariableNames{'Deflection3'} = 'crioPowerSettingRaw';
data.Properties.VariableNames{'Force2'} = 'crioForceRightXraw';
data.Properties.VariableNames{'Force3'} = 'crioForceRightYraw';
data.Properties.VariableNames{'Force4'} = 'crioForceLeftXraw';
data.Properties.VariableNames{'Force5'} = 'crioForceLeftYraw';

%% 2. CALIBRATION AND ERROR MODELS
%% Import Gain and Offset Values

go = readtable('calibration.csv');
go.parameter = string(go.parameter);

%% Conversion from measured values to physical values 

% temperature from C to K
data.crioTATcorr = data.crioTATraw + 273.15;
data.crioSensorTempCorr = data.crioSensorTempRaw + 273.15;

% using calibration values
data.crioAileronLeftCorr = -148.11 * data.crioAileronRaw.^2 + 41.041 * data.crioAileronRaw + 7.9919;
data.crioAileronRightCorr = 105.13 * data.crioAileronRaw.^2 + 108.64 * data.crioAileronRaw + 11.485;
data.crioAileronCorr = -(data.crioAileronLeftCorr + data.crioAileronRightCorr) / 2; 
data.crioElevatorCorr = data.crioElevatorRaw .* go(go.parameter == {'elevator'},:).g + go(go.parameter == {'elevator'},:).o;
data.crioRudderCorr = data.crioRudderRaw .* go(go.parameter == {'rudder'},:).g + go(go.parameter == {'rudder'},:).o;
data.crioPowerSettingCorr = data.crioPowerSettingRaw .* go(go.parameter == {'powerSetting'},:).g + go(go.parameter == {'powerSetting'},:).o;

data.crioForceLeftXcorr = data.crioForceLeftXraw .* go(go.parameter == {'forceLeftX'},:).g + go(go.parameter == {'forceLeftX'},:).o;
data.crioForceLeftYcorr = data.crioForceLeftYraw .* go(go.parameter == {'forceLeftY'},:).g + go(go.parameter == {'forceLeftY'},:).o;
data.crioForceRightXcorr = data.crioForceRightXraw .* go(go.parameter == {'forceRightX'},:).g + go(go.parameter == {'forceRightX'},:).o;
data.crioForceRightYcorr = data.crioForceRightYraw .* go(go.parameter == {'forceRightY'},:).g + go(go.parameter == {'forceRightY'},:).o;

data.crioRelativeHumidityCorr = data.crioRelativeHumidityRaw .* go(go.parameter == {'humidity'},:).g + go(go.parameter == {'humidity'},:).o;

data.crioStaticPressureConv = -data.crioStaticPressureRaw .* go(go.parameter == {'staticP'},:).g + go(go.parameter == {'staticP'},:).o;
data.crioDynamicPressureConv = -data.crioDynamicPressureRaw .* go(go.parameter == {'dynP'},:).g + go(go.parameter == {'dynP'},:).o;
data.crioAOAconv = data.crioAOAraw .* go(go.parameter == {'aoa'},:).g + go(go.parameter == {'aoa'},:).o;
data.crioAOSconv = -(data.crioAOSraw .* go(go.parameter == {'aos'},:).g + go(go.parameter == {'aos'},:).o);

% remove some Data again... 
data.crioDynamicPressureConv(data.crioDynamicPressureConv < 0) = NaN;

%% Error Model Implementation 
    %% Static Pressure Error Model

    cIntercept = -62.576;
    cAOA = 2.6815;
    cAOS = 3.5064;
    Cp_dyn_adb = 0.1673;
    cAOA_AOS = -0.10916;
    cAOA_p_dyn_adb = -0.0010315;
    cAOS_p_dyn_adb = -0.0033852;
    cAOA_2 = -0.17619;
    cAOS_2 = -0.43008;
    Cp_dyn_adb_2 = -5.48E-05;
    cAOA_2_AOS = 0.015596;
    cAOA_AOS_2 = 0.015899;
    cAOA_2_AOS_2 = -0.0011762;

    data.crioStaticPressureCorr = data.crioStaticPressureConv + cIntercept + ...
        data.crioAOAconv * cAOA + ...
        data.crioAOSconv * cAOS + ...
        data.crioDynamicPressureConv * Cp_dyn_adb + ...
        data.crioAOAconv .* data.crioAOSconv * cAOA_AOS + ...
        data.crioAOAconv .* data.crioDynamicPressureConv * cAOA_p_dyn_adb + ...
        data.crioAOSconv .* data.crioDynamicPressureConv * cAOS_p_dyn_adb + ...
        data.crioAOAconv .^2 * cAOA_2 + ...
        data.crioAOSconv .^2 * cAOS_2 + ...
        data.crioDynamicPressureConv .^2 * Cp_dyn_adb_2 + ...
        data.crioAOAconv .^2 .* data.crioAOSconv * cAOA_2_AOS + ...
        data.crioAOAconv .* data.crioAOSconv .^2 * cAOA_AOS_2 + ...
        data.crioAOAconv .^2 .* data.crioAOSconv .^2 * cAOA_2_AOS_2;

    clear cIntercept cAOA cAOS Cp_dyn_adb cAOA_AOS cAOA_p_dyn_adb ...
        cAOS_p_dyn_adb cAOA_2 cAOS_2 Cp_dyn_adb_2 cAOA_2_AOS cAOA_AOS_2 ...
        cAOA_2_AOS_2
    
    %% Dynamic Pressure Error Model

    cIntercept = -101.08;
    cAOA = 0.88716;
    cAOS = 0.097975;
    Cp_dyn_adb = 1.2566;
    cAOA_AOS = 0.006931;
    cAOA_2 = -0.14535;
    cAOS_2 = -0.47525;
    Cp_dyn_adb_2 = -9.99E-05;
    cAOA_2_AOS = 0.0083155;
    cAOA_AOS_2 = 0.0059558;
    cAOA_2_AOS_2 = -0.00044339;

    data.crioDynamicPressureCorr = cIntercept + ...
        data.crioAOAconv * cAOA + ... 
        data.crioAOSconv * cAOS + ... 
        data.crioDynamicPressureConv * Cp_dyn_adb + ...
        data.crioAOAconv .* data.crioAOSconv * cAOA_AOS + ...
        data.crioAOAconv.^2 * cAOA_2 + ...
        data.crioAOSconv.^2 * cAOS_2 + ...
        data.crioDynamicPressureConv.^2 * Cp_dyn_adb_2 + ...
        data.crioAOAconv.^2 .* data.crioAOSconv * cAOA_2_AOS + ...
        data.crioAOAconv .* data.crioAOSconv.^2 * cAOA_AOS_2 + ...
        data.crioAOAconv.^2 .* data.crioAOSconv.^2 * cAOA_2_AOS_2;

    clear cIntercept cAOA cAOS Cp_dyn_adb cAOA_AOS cAOA_2 cAOS_2 ...
        Cp_dyn_adb_2 cAOA_2_AOS cAOA_AOS_2 cAOA_2_AOS_2;

    %% AOA Error Model

    cIntercept = 26.199;
    cAOA = 1.1337;
    cAOS = 0.90991;
    Cp_dyn_adb = -0.054734;
    cAOA_AOS = 0.00029598;
    cAOA_p_dyn_adb = -9.18E-05;
    cAOS_p_dyn_adb = -0.00056731;
    cAOA_2 = -0.0052728;
    cAOS_2 = -0.019915;
    Cp_dyn_adb_2 = 2.70E-05; 

    data.crioAOAcorr = cIntercept + ...
        data.crioAOAconv * cAOA + ...
        abs(data.crioAOSconv) * cAOS + ...
        data.crioDynamicPressureConv * Cp_dyn_adb + ...
        data.crioAOAconv .* abs(data.crioAOSconv) * cAOA_AOS + ...
        data.crioAOAconv .* data.crioDynamicPressureConv * cAOA_p_dyn_adb + ...
        abs(data.crioAOSconv) .* data.crioDynamicPressureConv * cAOS_p_dyn_adb + ...
        data.crioAOAconv .^2 * cAOA_2 + ...
        data.crioAOSconv .^2 * cAOS_2 + ...
        data.crioDynamicPressureConv .^2 * Cp_dyn_adb_2;

    clear cIntercept cAOA cAOS Cp_dyn_adb cAOA_p_dyn_adb cAOS_p_dyn_adb ...
        cAOA_2 cAOS_2 Cp_dyn_adb_2 cAOA_p_dyn_adb_2 cAOS_p_dyn_adb_2

    %% AOS Error Model
    
    cIntercept = 0.31951;
    cAOA = -0.0016799;
    cAOS = 0.96204;
    Cp_dyn_adb = -0.00021011;
    cAOA_AOS = 0.00037494;
    cAOA_2 = -9.44E-05;
    
    data.crioAOScorr = cIntercept + ...
        data.crioAOAconv * cAOA + ...
        data.crioAOSconv * cAOS + ...
        data.crioDynamicPressureConv * Cp_dyn_adb + ...
        data.crioAOAconv .* data.crioAOSconv * cAOA_AOS + ...
        data.crioAOAconv .^2 * cAOA_2;

    clear cIntercept cAOA cAOS Cp_dyn_adb cAOA_AOS cAOA_2


%% Additional parameters calculations

data.crioDynamicPressureCorr(data.crioDynamicPressureCorr < 0) = NaN;

% Specific molar mass of air
R = 287.058;


% Density
data.calcDensity= data.crioStaticPressureCorr./(R*data.crioTATcorr);

% TAS
data.calcTAS= sqrt(2 * data.crioDynamicPressureCorr ./ data.calcDensity);

% Pressure altitude
data.calcPressureAltitude = (1-(data.crioStaticPressureCorr / 101325).^0.190284) * 145366.45 * 0.3048;   

%% save data
FT_Data=data;

% [~,name,~] = fileparts(Folder);
% name = name(1:end-4);
% 
% path = fullfile(pwd,'Data','Flights',strcat(name,'.mat'));
% save(path,'FT_Data');
end
