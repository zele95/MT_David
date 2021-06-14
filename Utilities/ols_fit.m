function [theta, y_pred] = ols_fit(data, y_name, x_names, do_print)
% Perform ordinary least square (OLS) regression
%
% [theta, y_pred] = ols_fit(data, y_name, x_names)
%
% data          TABLE or TIMETABLE containing the data to be fitted
% y_name        STRING containing the name of the column to fit
% x_names       CELL ARRAY of strings that contain the column names of the
%               covariates to be used in the model
% do_print      optional, if not given or set to TRUE, the function prints
%               a summary of the estimation to the console. If set to
%               FALSE, no output is produced
%
% theta         estimated parameter vector
% y_pred        model prediction
%
% Example:
% Assume that your data contains the columns called y, x1, x2 and you 
% would like to fit y as a function of the covariates x1 and x2:
%
% y = theta_0 + x1*theta_1 + x2*theta_2 + e
%
% where e is the error term. The equation above can be fitted with the
% following call to the function:
%
% [theta, y_pred] = fitlm_(data, 'y', {'1', 'x1', 'x2'})
%
% where the '1' is used to define a model intercept term (also called bias
% or offset).
%
% NOTE:
% This function is not the most efficient or robust implementation for OLS
% regression, but it uses the standard MATLAB functions.
%
% A useful script with a lot of background can be found here:
% https://web.stanford.edu/~mrosenfe/soc_meth_proj3/matrix_OLS_NYU_notes.pdf
%
% ZHAW,	Author: R. Monstein - 26.10.2019

% handle optional paramter do_print
 if ~exist('do_print','var')
      do_print = true;
 end

% check input data types
if ~istable(data)
    error('The parameter ''data'' is expected to be a table.');
end
if ~ischar(y_name)
    error('The parameter ''y_name'' is expected to be a cell array.');
end
if ~iscell(x_names)
    error('The parameter ''x_names'' is expected to be a cell array.');
end
if ~islogical(do_print)
    error('The parameter ''do_print'' is expected to be boolean.');
end

% check input size
if isempty(data) || isempty(y_name) || isempty(x_names)
    error('At least one of the function parameters is empty')
end

% check if column names are in the data
for i=1:length(x_names)
    if ~any(strcmp(x_names{i}, data.Properties.VariableNames))
        if ~strcmp(x_names{i}, '1')
            error('Column ''%s'' can not be found in ''data''', x_names{i});
        end
    end
end

% assemble matix X
if any(strcmp('1', x_names))
    % remove '1' from the column names
    x_names_ = x_names(~strcmp(x_names, '1'));
    X = [ones(height(data), 1), table2array(data(:, x_names_))];
else
    X = table2array(data(:, x_names));
end

y = table2array(data(:, y_name));

% check if there are NaN in X or y
if (sum(isnan(X)) + sum(isnan(y))) > 0
   error('Data contains NaN'); 
end

% estimate parameters
theta = pinv(X'*X) * X'*y;

% calculate model prediction
y_pred = X*theta;

% calculate residuals
e = y - y_pred;

% estimate standard error
sigma2 = (e'*e)/(length(y) - length(theta));
P = sigma2*(pinv(X'*X));    % variance-covariance matrix
se = sqrt(diag(P));

if do_print
    
    % replace '1' with a more readable 'intercept', if it exists
    x_names{strcmp(x_names, '1')} = 'intercept';
    
    % model string
    model_str = sprintf('%s = ', y_name);
    for i=1:length(x_names)
        if i ~= 1
            model_str = sprintf('%s + ', model_str);
        end
        model_str = sprintf('%s%s', model_str, x_names{i});
    end
    fprintf('Estimated model:\n\n');
    fprintf('\t%s\n\n', model_str);
    fprintf('with the following model parameter\n\n');
    tb = table(theta, se, abs(se./theta), ...
               'VariableNames', {'param_value', 'standard_error', 'rel_error'}, ...
               'RowNames', x_names);
    disp(tb);
    fprintf(['The ''param_value'' is the estimate of the parameter,\n' ...
        'the ''standard_error'' is the estimated standard error of ' ...
        'the parameter (in the units of the corresponding ' ...
        'parameter),\nand the ''rel_error'' is the normalized ' ...
        'standard error (i.e. as fraction of the parameter value).']);
end

end