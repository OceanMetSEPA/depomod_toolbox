function bool = isRCMPackageAvailable(varargin)
    % Ensure the RCM package is available

    bool       = 0;
    throwError = 1;

    if ~isempty(varargin)
        for i = 1:2:size(varargin,2)
            switch varargin{i}
              case 'throwError'
                throwError = varargin{i + 1};
            end
        end
    end

    if ~size(what('RCM'),1) > 0
        if throwError
            error('AutoDepomod:PackageUnavailable', ...
                'RCM MATLAB package cannot be found.');
        end
    else
        bool = 1;
    end
end