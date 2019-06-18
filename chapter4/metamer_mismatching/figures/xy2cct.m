function cct = xy2cct(xy)
uv = zeros(size(xy, 1), 2);
uv(:, 1) = 4*xy(:,1) ./ (-2*xy(:, 1) + 12*xy(:, 2) + 3);
uv(:, 2) = 6*xy(:,2) ./ (-2*xy(:, 1) + 12*xy(:, 2) + 3);
cct = zeros(size(xy, 1), 1);
for i = 1:size(uv, 1)
    cct(i, :) = uv2cct(uv(i, :));
end
end

function Tc = uv2cct(uv)
% From CIE1960UCS (u, v) to CCT
% Calculate correlated color temperature of light source with Robertson's Method
% Partly Written by zhang fuzheng,@zju;
% 
u=uv(1);
v=uv(2);
% Load isotemperature line data;
% T is from 1MK^-1 to 1000MK^-1(10^6 to 1000K) with 1MK^-1 interval; 
load('cctdata.mat'); % T, (ut,vt), tt(the slope of isotemperature line)

% Find adjacent lines to (us, vs) 
n = length (T); 
index = 0; 
d1 = ((v-vt(1)) - tt(1)*(u-ut(1)))/sqrt(1+tt(1)*tt(1)); 
for i=2:n
    d2 = ((v-vt(i)) - tt(i)*(u-ut(i)))/sqrt(1+tt(i)*tt(i));
    if (d1/d2 < 0)
        index = i;
        break;
    else
        d1 = d2;
    end
end
if index == 0
	Tc = -1; 
	disp('Failed to calculate CCT! Note that CCT must be from 10^6 to 1000K!');   
else   
    Tc = 1/(1/T(index-1)+d1/(d1-d2)*(1/T(index)-1/T(index-1)));
    Tc= round(Tc);
end
end
