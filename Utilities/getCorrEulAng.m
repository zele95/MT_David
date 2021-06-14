function [cor_PHI, cor_THE, cor_PSI] = getCorrEulAng(phi, the, psi, DELthe)

% conversion
phi    =     phi*pi/180;
the    =     the*pi/180;
psi    =     psi*pi/180;

for i = 1:length(phi) 
% euler angles rotational matrices
PSI = [ cos(psi(i)) sin(psi(i)) 0
       -sin(psi(i)) cos(psi(i)) 0
        0        0        1];
THE = [cos(the(i)) 0 -sin(the(i))
       0        1  0
       sin(the(i)) 0  cos(the(i))];
PHI = [1  0        0
       0  cos(phi(i)) sin(phi(i))
       0 -sin(phi(i)) cos(phi(i))];
% back rotation to earth coordinate system
LBE = PHI*THE*PSI;
LEB = LBE.';

% rotation matrix for misalignment angle
DTHE   = [cos(DELthe) 0 -sin(DELthe)
          0           1  0
          sin(DELthe) 0  cos(DELthe)];

% applying back rotation to earth coordinates to unity vectors      
Vb = eye(3);
Ve = LEB*DTHE.'*Vb;

% corrected Euler angles
cor_PHI(i,1) =  atan2( Ve(3,2), Ve(3,3) ) *180/pi;
cor_THE(i,1) = -asin ( Ve(3,1)          ) *180/pi;
cor_PSI(i,1) =  atan2( Ve(2,1), Ve(1,1) ) *180/pi;

end