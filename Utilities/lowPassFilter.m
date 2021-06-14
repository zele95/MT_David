function [y] = lowPassFilter(x, wc, ts, nInit)
% zero-phase low pass filter
%
% [yo] = lowPassFilter(x, wc, ts)
%
% x             data series input
% ts            sample time [s]
% wc            cutoff frequency [rad/s]
% nInit         optional, number of samples to initialize the filter
%
% y             filtered data series
%
% The signal is filtered based on a first order low pass filter twice: Once
% regularly and once a flipped version of it. Then the flipped filtered
% signal is flipped again and the average of the two is taken.
%
% Source of the low-pass filter:
% http://api.ning.com/files/kEMcVsMpknzEkGLj3nJV*t0wZgYgINUFj-28r*Mm-AOyJCwPtmeiPaU5q50*M8l0X0nbYRISmeC6stSc7i7mGuvoPS7D8InI/ConversionofTransferFunctions.pdf
%
% Initialization of the filter:
% To avoid being affected too much by noise in the first sample, you can
% set nInit > 1 to use the mean of the first nInit samples to initialize
% the filter.
%
% ZHAW,	Author: R. Monstein - 16.10.2019

if ~exist('nInit', 'var')
    % initialize if parameter is not passed to the function
    nInit = 1;
end

if ~iscolumn(x)
    % make column vector, if it isn't already
    x=x';
end

% filter signal
y = (lpfilt(x) + flip(lpfilt(flip(x)))) / 2;

    function [y] = lpfilt(x)
        tau = 1/wc;                                 % time constant
        c1 = (2*tau-ts)/(2*tau+ts);                 % constant 1
        c2 = ts/(2*tau+ts);                         % constant 2
        
        % initialize first sample
        x(1) = mean(x(1:nInit));

        % initialize output
        y = x;
        
        % iterate over vector and apply filter
        for i=1:length(x)-1
            y(i+1) = c1*y(i) + c2*x(i) + c2*x(i+1);
        end
    end
end