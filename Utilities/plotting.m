function plotting(t, brk, FT_MData)


% engine
figure
plot(t,FT_MData.RPM);
hold on
plot(t,FT_MData.RPM_model)
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
% axis([15.01 17 2200 2550])
grid on
legend('RPM aircraft [min^{-1}]','RPM engine model [min^{-1}]','Location','southeast')
xlabel('t [s]')
ylabel('RPM')
% title('ENGINE MAPPING')

% filtering angular velocity
figure
subplot(3,1,1)
plot(t,FT_MData.p_b);
hold on
plot(t,FT_MData.p*180/pi)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
legend('p ','p filtered')
xlabel('t [s]')
ylabel('p [deg/s]')

subplot(3,1,2)
plot(t,FT_MData.q_b);
hold on
plot(t,FT_MData.q*180/pi)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
legend('q','q filtered')
xlabel('t [s]')
ylabel('q [deg/s]')

subplot(3,1,3)
plot(t,FT_MData.r_b);
hold on
plot(t,FT_MData.r*180/pi)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
legend('r','r filtered')
xlabel('t [s]')
ylabel('r [deg/s]')
sgtitle('FILTERING ANGULAR VELOCITY')

% filtering accels
figure
subplot(3,1,1)
plot(t,FT_MData.ax);
hold on
plot(t,FT_MData.ax_f)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
legend('a_x','a_x filtered')
xlabel('t [s]')
ylabel('a_x [m/s^2]')

subplot(3,1,2)
plot(t,FT_MData.ay);
hold on
plot(t,FT_MData.ay_f)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
legend('a_y','a_y filtered')
xlabel('t [s]')
ylabel('a_y [m/s^2]')

subplot(3,1,3)
plot(t,FT_MData.az);
hold on
plot(t,FT_MData.az_f)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
legend('a_z','a_z filtered')
xlabel('t [s]')
ylabel('a_z [m/s^2]')
sgtitle('FILTERING ACCELERATIONS')

% misalignment corrections

% accelerations
figure
subplot(3,2,1)
% sgtitle('MEASURED/BODY C.S.')
plot(t,FT_MData.Acceleration_x)
hold on
plot(t,FT_MData.Acceleration_x_b)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('a_x [m/s^2]')
legend('measured signal','corrected to BCS.','Location','northwest')

subplot(3,2,3)
plot(t,FT_MData.Acceleration_y)
hold on
plot(t,FT_MData.Acceleration_y_b)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('a_y [m/s^2]')

subplot(3,2,5)
plot(t,FT_MData.Acceleration_z)
hold on
plot(t,FT_MData.Acceleration_z_b)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('a_z [m/s^2]')

% angular velocity
subplot(3,2,2)
plot(t,FT_MData.Roll_rate)
hold on
plot(t,FT_MData.p_b)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('p [m/s^2]')

subplot(3,2,4)
plot(t,FT_MData.Pitch_rate)
hold on
plot(t,FT_MData.q_b)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('q [m/s^2]')

subplot(3,2,6)
plot(t,FT_MData.Yaw_rate)
hold on
plot(t,FT_MData.r_b)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('r [m/s^2]')

% error model corrections
figure
subplot(3,1,1)
plot(t,FT_MData.AOA)
hold on
plot(t,FT_MData.alpha_adb)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('\alpha [\circ]')
legend('\alpha','\alpha_{corr}','Location','southeast')
% sgtitle('MEASURED/CORRECTED')

subplot(3,1,2)
plot(t,FT_MData.AOS)
hold on
plot(t,FT_MData.beta_adb)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('\beta [\circ]')
legend('\beta','\beta_{corr}')

subplot(3,1,3)
plot(t,FT_MData.TAS)
hold on
plot(t,FT_MData.tas_adb)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('TAS [m/s]')
legend('TAS','TAS_{corr}')

% translating parameters to cg
figure
subplot(3,1,1)
plot(t,FT_MData.AOA_cg)
hold on
plot(t,FT_MData.alpha_adb)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('\alpha [\circ]')
legend('AOA_{cg}','AOA_{adb}')
% sgtitle('CG/ADB')

subplot(3,1,2)
plot(t,FT_MData.AOS_cg)
hold on
plot(t,FT_MData.beta_adb)
xlabel('t [s]')
ylabel('\beta [\circ]')
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
legend('AOS_{cg}','AOS_{adb}')

subplot(3,1,3)
plot(t,FT_MData.TAS_cg)
hold on
plot(t,FT_MData.tas_adb)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('TAS [m/s]')
legend('TAS{cg}','TAS{adb}')

% dynamic pressure
figure
plot(t,1/2*FT_MData.Density.*FT_MData.tas_adb.^2)
hold on
plot(t,1/2*FT_MData.Density.*FT_MData.TAS_cg.^2)
plot(t, FT_MData.Dynamic_pressure)
grid on
if isempty(brk)
   % do nothing
else
y=ylim;
plot([brk brk],[y(1) y(2)],'g')
end
xlabel('t [s]')
ylabel('q_{dyn} [Pa]')
legend('qdyn_{adb}','qdyn_{cg}','qdyn_m')
title('DYNAMIC PRESSURE')

end