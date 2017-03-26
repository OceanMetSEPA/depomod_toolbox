function [ obj ] = readCfg(path)
    % This in principle could read the whole file but for now is simply to
    % read the dispersion coefficients
    
    % Prepare output struct. Only dispersion for now.
    obj = struct;    
    obj.DispersionCoefficients = cell(3,2);
    
    % read file
    fd = fopen(path,'rt');

    %% Read dispersion coefficients
    dataCount = 1;
    dispCoeffRegex = '([\d\.]+)   k(x|y|z)  \{m2\/s (Horizontal|Vertical) dispersion coefficient \((x|y|z)\)  SITE CHANGE';
    
    while ~feof(fd)
        l = fgets(fd);

        [match,tokens] = regexp(l, dispCoeffRegex,'match','tokens');

        if size(tokens,2) > 0
            obj.DispersionCoefficients{dataCount,1} = tokens{1}{2};
            obj.DispersionCoefficients{dataCount,2} = str2num(tokens{1}{1});

            dataCount = dataCount + 1;
        end
    end
end

