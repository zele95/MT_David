function [FT_Data] = getAeroCoeff(FT_Data,filterAccels)
% Calculate aerodynamic coefficients and add it to the input struct
%
% [FT_Data] = getAeroCoeff(FT_Data)
%
% FT_Data        struct containing the fligh test data including the engine and
%                mass and balance data
%
% FT_Data        output struct with the aerodynamic coefficients added
%
% ZHAW,	Author: David Haber-Zelanto - 20.10.2020.


% constants
b  = 10.67;      % [m], refrence wing span
S  = 15.7935;    % [m^2], wing reference aera
c  = 1.602;      % [m], Mean aerodynamic chord


aoa  = FT_Data.AOA_cg*pi/180;
qdyn = 1/2*FT_Data.Density.*FT_Data.TAS_cg.^2;

% pre-allocate memory
Cx   = zeros(length(FT_Data.Time), 1);
Cy   = zeros(length(FT_Data.Time), 1);
Cz   = zeros(length(FT_Data.Time), 1);
Cl   = zeros(length(FT_Data.Time), 1);
Cm   = zeros(length(FT_Data.Time), 1);
Cn   = zeros(length(FT_Data.Time), 1);
CD   = zeros(length(FT_Data.Time), 1);
CL   = zeros(length(FT_Data.Time), 1);
CT   = zeros(length(FT_Data.Time), 1);

%% loop over samples
for i=1:length(FT_Data.Time)
    % propeller tip coordinate system to body (ACS to BCS)
    P2B = [-1,0,0; ...
            0,1,0; ...
            0,0,-1];
    % inertia tensor in body coordinates
    I   = P2B*[FT_Data.I_xx(i),-FT_Data.I_xy(i),-FT_Data.I_xz(i);...
              -FT_Data.I_xy(i), FT_Data.I_yy(i) -FT_Data.I_yz(i);...
              -FT_Data.I_xz(i),-FT_Data.I_yz(i), FT_Data.I_zz(i)];
          
    
          if filterAccels == true
     % accelerations filtered
    Nd  = [FT_Data.ax_f(i); ...
           FT_Data.ay_f(i);...
           FT_Data.az_f(i)];
          else
	% accelerations
    Nd  = [FT_Data.ax(i); ...
           FT_Data.ay(i);...
           FT_Data.az(i)];
          end
       
      
    % omega dot
    Od  = [FT_Data.pdot(i); ...
           FT_Data.qdot(i); ...
           FT_Data.rdot(i)];
       
    % omega
	O   = [FT_Data.p(i); ...
           FT_Data.q(i); ...
           FT_Data.r(i)];
       
	% engine moments in body coordinates
    ME  = [FT_Data.Le(i); ...
           FT_Data.Me(i); ...
           FT_Data.Ne(i)];

    % engine forces in body coordinates
	FE  = [FT_Data.Xe(i); ...
           FT_Data.Ye(i); ...
           FT_Data.Ze(i)];
    
        
    % aerodynamic reference point from propeller tip
    RP  = [2.3919      ; 0.00      ; -0.1524  ];
    
    % CG position from propeller tip ACS
    CG  = [FT_Data.cg_x(i) ; FT_Data.cg_y(i) ; FT_Data.cg_z(i)];
    
    % lever arm CG-reference point in body axis
    D   = P2B*(CG-RP);
    
    %% forces and moments sll in body c.s.
    
    % total forces
    FTot   = Nd.*FT_Data.Mass(i);
     
    % total moments at CG
    Mcg  = I*Od+cross(O,I*O); 
    
    % aerodynamic forces
    FA   = FTot-FE;
    
    % aerodynamic moments about CG
    MAcg = Mcg-ME;
    
	% aerodynamic moments about reference point
    MA   = MAcg-cross(FA,D);

    %% non-dimensionalize
    
    % force coefficients
    Cx(i)   = FA(1)/(qdyn(i)*S);
    Cy(i)   = FA(2)/(qdyn(i)*S);
    Cz(i)   = FA(3)/(qdyn(i)*S);
    CD(i)   = -( Cx(i)*cos(aoa(i)) + Cz(i)*sin(aoa(i)));
    CL(i)   = -(-Cx(i)*sin(aoa(i)) + Cz(i)*cos(aoa(i)));  

    % moment coefficients
    Cl(i)   = MA(1)/(qdyn(i)*S*b);
    Cm(i)   = MA(2)/(qdyn(i)*S*c);
    Cn(i)   = MA(3)/(qdyn(i)*S*b);
    
    % thrust coefficient
    CT(i)   = FT_Data.Thrust(i)/(qdyn(i) * S);
end

%% assign to output
FT_Data.Cx = Cx;
FT_Data.Cy = Cy;
FT_Data.Cz = Cz;
FT_Data.Cl = Cl;
FT_Data.Cm = Cm;
FT_Data.Cn = Cn;
FT_Data.CD = CD;
FT_Data.CL = CL;

FT_Data.CT = CT;


