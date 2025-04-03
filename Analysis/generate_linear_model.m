function linmod = generate_linear_model(rate_matrix, params, params0)
% generate_linear_model generates a linear model of the rate matrix
%
% Inputs:
%   rate_matrix: rate matrix (Trial x Time)
%   params: parameters (peak velocity, duration)
%   params0: grand average parameters (peak velocity, duration)
%
% Outputs:
%   linmod: linear model structure
%   rate prediction given peak velocity v and duration d is
%
%   rate_prediction = linmod.ssc0 + linmod.wv * (v - linmod.v00) + linmod.wr * (10/d - linmod.r00)
%
%   or if the model is the reduced one with only velocity
%
%   rate_prediction = linmod.ssc0 + linmod.wv0 * (v - linmod.v00)
%
%   Note linmod.v00 and linmod.r00 are the grand average peak velocity and average velocity (15/duration).
%   linmod.wv and linmod.wr are the coefficients for the full model.
%   linmod.wv0 is the coefficient for the reduced model.

vpeak = abs(params(:, 1)); % peak velocity
sdur = abs(params(:, 2)); % duration
ss = rate_matrix; % rate matrix (Trial x Time)

ss0 = nanmean(ss, 1); % mean rate across trials
dss = ss - ss0; % deviation from mean rate
v0 = nanmean(vpeak); % mean peak velocity
r0 = nanmean(15 ./ sdur); % mean average velocity (see Markanday et al., 2024)

dv = vpeak - v0; % deviation from mean peak velocity
dr = 10 ./ sdur - r0; % deviation from mean average velocity
dz = [dv dr];
cc = dz' * dz; % covariance matrix

w12 = pinv(cc) * dz' * dss; % full linear model coefficients

wv = w12(1, :); % velocity coefficients
wr = w12(2, :); % duration coefficients
wv0 = (dv' * dss) / (dv' * dv); % reduced model with only velocity

% now we shift the mean ss0 the value corresponding to the grand averages
v00 = params0(1); % grand average peak velocity
r00 = params0(2); % grand average average velocity

% corrected PSTH 1
wc = (v00 - v0) * wv + (r00 - r0) * wr;
ssc = ss0 + wc; % shifted ss0 for v00 and r00

% corrected PSTH 2
wc = (v00 - v0) * wv0;
ssc0 = ss0 + wc; % shift ss0 for v00 in the reduced model

%output
linmod = struct('wv0', wv0, ...
                'wv', wv, ...
                'wr', wr, ...
                'ssc', ssc, ...
                'ssc0', ssc0, ...
                'v00', v00, ...
                'r00', r00);

end
