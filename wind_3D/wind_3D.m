%% Wind field in 3D space
clear;
% close all;

nx = 1000; 
ny = 1000;
nz = 100;


vx = linspace(-5e2, 5e2, nx); % positions of x, y and z in space
vy = linspace(-5e2, 5e2, ny);

x0 = 3e2;
y0 = 3e2;
r0x = 0.5e2;
r0y = 0.5e2;

x1 = -3e2; 
y1 = 3e2;
r1x = 0.5e2; 
r1y = 0.5e2;


% vz = linspace(-5e2, 5e2, nz);

[x_, y_] = ndgrid(vx, vy); % ndgrid of position vectors
r_ = sqrt(x_.^2 + y_.^2);
phi_ = unwrap(angle(x_ + 1j .* y_));

x = (x_ - x0)/r0x; y = (y_ - y0)/r0y;
x11 = (x_ - x1)/r1x; y11 = (y_ - y1)/r1y;

% x = x_; y = y_;


r = sqrt(x.^2 + y.^2);

% phi = unwrap(angle(x + 1j .* y));
phi = pi/2 - atan2(y, x);

A = 5 .* exp(-(r - 1)/(2 .* 1^2));

r1 = sqrt(x11.^2 + y11.^2);

% phi = unwrap(angle(x + 1j .* y));
phi1 = pi/2 - atan2(y11, x11);

A1 = 5 .* exp(-(r1 - 1)/(2 .* 1^2));

ux = 5;

% velocity
u = ux  .* ones(size(x));
v = zeros(size(x));
w = zeros(size(x));

% u = ux .* ones(size(x));% + A .* cos(phi) + A1 .* cos(phi1);
% v = zeros(size(x)); % -A .* sin(phi) - A1 .* sin(phi1);
% w = zeros(size(x));





%%

% quiver3(x, y, z, u, v, w)


%% Have the co-ordinate system in polar form

% r = sqrt(x_.^2 + y_.^2);
% theta = atan(z./x);
% phi = atan(y./x);

% theta = unwrap(angle(z + 1j .* x));
theta = pi/12;
% phi = unwrap(angle(x_ + 1j .* y_));


% [r, theta, phi] = ndgrid(r, theta, phi);

vr = cos(theta) .* cos(phi_) .* u + cos(theta) .* sin(phi_) .* v + sin(theta) .* w;
vtheta = sin(theta) .* cos(phi_) .* u + sin(theta) .* sin(phi_) .* v - cos(theta) .* w;
vphi = -sin(phi_) .* u + cos(phi_) .* v;

%% plot of radial velocity
% 
% 
% % figure; surf(x, y, z, vr); shading interp; colorbar; colormap('jet');
% 
% 
% [faces,verts,colors] = isosurface(x,y,z,vr,-3,vr); 
% patch('Vertices',verts,'Faces',faces,'FaceVertexCData',colors,...
%     'FaceColor','interp','EdgeColor','interp')
% % view(-7.5,7.5)
% axis vis3d
% colormap jet; colorbar;
%  
%  xlabel('X'); ylabel('Y'); zlabel('Z');

%% Plot radial velocity  

[idx] = ((abs(r_) - 3e2 .* sqrt(2)) < 1e-1) & ((abs(r_) - 3e2 .* sqrt(2)) > 1e-2);


figure; plot(phi_(idx).* 180/pi, vr(idx), '*'); grid on;
%% 
figure; 
h = pcolor(x_,y_, vr);
set(h,'ZData',-1+zeros(size(vr)));
shading interp;
colormap('jet');
hold on;
% surface(x_, y_, (vr)); shading flat; colormap('jet'); colorbar;
% figure; surface(r_ .* cos(phi_), r_ .* sin(phi_), (vr.')); shading flat; colormap('jet'); colorbar;
e = 20;
quiver(x_(1:e:end, 1:e:end), y_(1:e:end, 1:e:end), u(1:e:end, 1:e:end), v(1:e:end, 1:e:end), 2, 'w');

% figure; surface(r_, phi_, (phi_ - atan2(v, u)) .* 180/pi); shading flat; colorbar;


%% Converitng vr into u, v and w

