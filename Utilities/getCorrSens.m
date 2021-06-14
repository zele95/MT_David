function [alpha, beta, tas] = getCorrSens ( FT_MData )  
% Correction of AOA,AOS,TAS at the ADB using Flavio's error models
%
% [a, b, tas] = getCorrSens ( FT_MData ) 
%
% FT_MData     manoeuvre data cointaining measured AOA, AOS, TAS, and right
%              aileron deflection
%
% a            corrected angle of attack
%
% b            corrected angle of sideslip
%
% tas          corrected true airspeed
%
% ZHAW,	Author: David Haber-Zelanto - 14.12.2020.

% models are made by Raphael

alpha_m = FT_MData.AOA*pi/180;
beta_m = FT_MData.AOS*pi/180;
pst = FT_MData.Static_pressure;
temp = FT_MData.Temperature;

b_alpha =-0.1;
b_beta  = 0;
b_qc    = -150;
k_alpha = 1.8;
k_beta  = 1;
k_qc    = 1.1;


%% alpha

    % alpha_m = b_alpha + k_alpha * alpha;
     
    % inversion
    alpha = (alpha_m-b_alpha)/k_alpha;
    
%% beta

    % beta_m =  b_beta + k_beta * beta; 
    
    % inversion
    beta = (beta_m-b_beta)/k_beta;

    %% TAS
  
    gamma = 1.4;
    R = 287.053;
    a = sqrt((gamma*R).*temp);
 
    M = FT_MData.TAS./a;
    qc_m = pst.*((1+0.2*M.^2).^(7/2)-1);   

    % qc_m_corr = b_qc + k_qc*qc_m;
    
    % inversion
    qc = (qc_m-b_qc)/k_qc;
    
    M_corr = sqrt(5*(((qc./pst)+1).^(2/7)-1));
    tas = M_corr.*a; 
    
    

%% convert into degrees
beta = beta*180/pi;
alpha = alpha*180/pi;

            
end          