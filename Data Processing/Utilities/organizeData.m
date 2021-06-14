function [FT_Data]=organizeData(FT_Data)
% Keeps and renames only selected parameters
%
% [FT_Data]=organizeData(FT_Data)
%
% FT_Data     structure with processed, not organized FT Data
%
% FT_Data     output structure with renamed and only selected parameters 
%
% Depending whether it is flight or manoeuvre data, function uses corresponding 
% signal_mapping excel file, where is needed to specify which parameters to 
% keep. 
% In order for function to work, data has to be unorganized.
%
% ZHAW,	Author: David Haber-Zelanto - 10.11.2020.


if strcmp(FT_Data.Properties.VariableNames(end),'calcPressureAltitude') % width(FT_Data)>=73; 
   
       Sign_Mapp=readtable('signal_mapping_flight.xlsx');
for i=1:width(FT_Data)
    if Sign_Mapp.Keep(i)==1
    FT_Data.Properties.VariableNames(Sign_Mapp.Original_Name(i))=Sign_Mapp.New_Name(i);
    else
    FT_Data=removevars(FT_Data,Sign_Mapp.Original_Name(i));
    end
end
    
    else
        
       Sign_Mapp=readtable('signal_mapping_manoeuvre.xlsx');
for i=1:width(FT_Data)
    if Sign_Mapp.Keep(i)==1
    FT_Data.Properties.VariableNames(Sign_Mapp.Original_Name(i))=Sign_Mapp.New_Name(i);
    else
    FT_Data=removevars(FT_Data,Sign_Mapp.Original_Name(i));
    end
end
end    
end
    
