function Xf = filter_matrix(X, varargin)
% Filter a matrix of spike trains with a Gaussian kernel
%
% Input:
%   X: binary matrix where each COLUMN is a spike train (Time x Trials)
%
% Output:
%   Xf: filtered spike train matrix
%
% Optional arguments:
%   sigma: standard deviation of the Gaussian kernel (default: 1.5 ms)
%   L: length of the Gaussian kernel (default: -1 and same as the data)
%   scheme: 0 for forward-backward filtering, 1 for standard filtering (default: 0)

    default_sigma = 1.5;
    default_L = -1;
    default_scheme = 0;

    p = inputParser;
    addRequired(p, 'X', @isnumeric);
    addParameter(p, 'sigma', default_sigma, @isnumeric);
    addParameter(p, 'L', default_L, @isnumeric);
    addParameter(p, 'scheme', default_scheme, @isnumeric);
    parse(p, X, varargin{:});

    if p.Results.sigma<=0
        Xf = X;
    else
        sigma = p.Results.sigma;
        if p.Results.L==-1
            L = 2*ceil(sigma*3)+1;
        else
            L = p.Results.L;
        end

    %     sigma = 1;
    %     L = 6;

    %     sigma = 0.75;
    %     L = 5;

        ker = gausswin(L, L/2/sigma);
        ker = ker/sum(ker);
        nker = numel(ker);

        B = zeros(nker, size(X,2));

        Y = [B; X; B];
    if p.Results.scheme>0
        Xf = X;
        for i=1:size(X, 2)
            Xf(:,i) = conv(Y(:,i), ker, 'same');
        end
    else
        Xf = filtfilt(ker, 1, Y);
    end

    Xf = Xf((nker+1):(nker+size(X,1)),:);
    end
end