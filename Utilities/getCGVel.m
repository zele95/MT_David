function [u_cg,v_cg,w_cg] = getCGVel(x_boomcg,y_boomcg,z_boomcg,u_b,v_b,w_b,p,q,r)
% Velocity components at the CG from ADB velocity and cg_adb offset 
%
% [u_cg,v_cg,w_cg] = getCGVel(x_boomcg,y_boomcg,z_boomcg,u_b,v_b,w_b,p,q,r)
%
% x_boomcg  lever arm CG to air data boom in x direction
% y_boomcg  lever arm CG to air data boom in y direction
% z_boomcg  lever arm CG to air data boom in z direction
% u_b       body-axis velocity in x direction at the boom
% v_b       body-axis velocity in y direction at the boom
% w_b       body-axis velocity in z direction at the boom
% p         roll rate in body-axis
% q         pitch rate in body-axis
% r         yaw rate in body-axis
%
% u_cg      body-axis velocity in x direction at CG
% v_cg      body-axis velocity in x direction at CG
% w_cg      body-axis velocity in x direction at CG
%
% ZHAW,	Author: David Haber-Zelanto - 01.12.2020.

u_cg = u_b + r.*y_boomcg - q.*z_boomcg;
v_cg = v_b + p.*z_boomcg - r.*x_boomcg;
w_cg = w_b + q.*x_boomcg - p.*y_boomcg;

