function qntile=quantile(x,p,varargin)
% Calculate quantile of a data set, x
%
% matlab percentile function
% a) gives different values from splus / excel and
% b) isn't even readily available (part of statistics toolbox).
% Also, matlab doesn't specify how percentile calculated, when in fact there are a bunch of ways.
% See http://mathworld.wolfram.com/Quantile.html (This function uses the Q7
% deffinition).
%
% Here, we calculate it so it matches up with splus / excel
%
% INPUT:
%   x - vector of values whos quantile we're after
%   p - quantile
%
% Optional input:
%   DIM - scalar, or 'All'
%         The dimension along which to find the quantile. Default '1',
%         defaults to 1.
%   percentile (false) - assume p refers to percentile (divide by 100 prior
%   to calculation)
% 
% OUTPUT
%   qntile - quantile of x
%
% NB - 'p' defines a fraction of values, so should be between 0 and 1
%
% EXAMPLES
%
% % Vector input.
% >> x=rand(100,1);
% >> quantile(x,0.5) % median value
% ans = 
%          0.924520219258406
% >> quantile(x, 50)
% Error using quantile (line 113)
% p (50.000000) should be between 0 and 1 
% >> quantile(x, 50, 'percentile', 1)
% ans =
%          0.924520219258406
% quantile(x, [5, 10, 50, 95], 'percentile', 1)
% ans =
%         0.0893996149700841
%          0.203576795930286
%          0.924520219258406
%           1.77256697121096
% % Matrix input
% >> m=rand(4, 5, 10);
% >> q = quantile(m, 0.5);
% >> size(q)
% ans =
%      1     5    10   % It worked along the 1st dimesnion, so is returning
%                      % quantile's with the size of the 2nd and 3rd
%                      % dimensions.
% >> q = quantile(m, 0.5, 2);
% >> size(q)
% ans =
%      1     4    10
% >> q = quantile(m, 0.5, 3);
% >> size(q)
% ans =
%      1     4     5
% >> q = quantile(m, [5, 10, 50, 95], 3, 'percentile', 1);
% >> size(q)
% ans =
%      4     4     5
% % If dimension is set to 'All', then it flattens the matrix.
% >> a = rand(5, 5);
% >> quantile(a, 0.5)
% ans =
%   Columns 1 through 3
%          0.470696635874201         0.341975792395652         0.377527146252593
%   Columns 4 through 5
%          0.261450582796841         0.356676672691004
% >> quantile(a, 0.5, 'All')
% ans =
%          0.377527146252593
% >> quantile(reshape(a, [numel(a), 1]), 0.5)
% ans =
%          0.377527146252593
% % And test the values returned...
% >> a = rand(1, 10);
% >> quantile(a, 0.5)
% ans =
%         0.60714704708398
% >> b = rand(1, 10);
% >> quantile(b, 0.5)
% ans =
%          0.107590221996404
% >> c = rand(1, 10);
% >> quantile(c, 0.5)
% ans =
%          0.449956059316183
% >> d = rand(1, 10);
% >> quantile(d, 0.5)
% ans =
%          0.513291359760298
% >> A = [a; b; c; d];
% >> quantile(A, 0.5, 2)
% ans =
%   Columns 1 through 3
%           0.60714704708398         0.107590221996404         0.449956059316183
%   Column 4
%          0.513291359760298
%
% Adapted from Ted's function of the same name to enable processing of
% multi-dimension matrices.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   quantile.m  $
% $Revision:   1.1  $
% $Author:   edward.barratt  $
% $Date:   Nov 13 2014 16:15:44  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin<2
        help quantile
        return
    end

    All = 0; DIM = 1;
    % See if dimension is defined.
    if nargin > 2
        if isnumeric(varargin{1})
            DIM = varargin{1};
            if mod(DIM, 1) ~= 0
                error('DIM must be an integer value')
            elseif DIM > ndims(x)
                error('You have requested quantiles along dimension %d, but there are only %d dimensions.', DIM, ndims)
            end
            varargin = varargin(2:end);
        elseif isequal(varargin{1}, 'All')
            All = 1; DIM = 1;
            varargin = varargin(2:end);
        end
    end

    if ~isnumeric(x)
        error('x should be numeric')
    end
    if ~isnumeric(p)
        error('p should be numeric')
    end
    options=struct;
    options.percentile=false;
    options=checkArguments(options,varargin);

    % Permute the matrix, so that the requested dimension is the first
    % dimension.
    SliceColons = '';
    if All
        x = reshape(x, [numel(x), 1]);
    else
        Order = unique([DIM, 1:ndims(x)], 'stable');
        x = permute(x, Order);
        for D = 2:ndims(x)
            SliceColons = [SliceColons,',:']; %#ok<AGROW>
        end
    end
    FloorSlice = ['Y(floor(mwx)', SliceColons, ')'];
    CeilSlice = ['Y(ceil(mwx)', SliceColons, ')'];
    % These 'Slices' are strings that can be eval'd. While it is best to
    % avoid 'eval', I don't know another way to ensure we are getting the
    % correct slices regardless of the number of dimensions.
    
    % Sort the permuted array along it's first dimension.
    Y=sort(x, 1); %#ok<NASGU>  % It is used, but by an eval.

    % Use general formula from quantile page on Mathworld.com:
    % Need these coefficients
    a=1;
    b=-1;
    c=0;
    d=1;
    Shape = size(x);
    Nx=Shape(1);

    if options.percentile
        p=p/100;
    end

    Np=length(p);
    for Pi=1:Np
        pIndex=p(Pi);
        if any(pIndex<0) || any(pIndex>1)
            error('p (%f) should be between 0 and 1',pIndex)
        end
        %(fractional) index of sorted order statistic in which quantile lies (mwx short for MathWorld 'x')
        mwx = a + (Nx + b) * pIndex;
        % Righto , here we go!
        FloorY = eval(FloorSlice);
        CeilY = eval(CeilSlice);       
        qntileSlice =FloorY + (CeilY - FloorY).*(c+d*(mwx-floor(mwx)));
        if Pi == 1
            qntile = qntileSlice;
        else
            qntile = cat(1, qntile, qntileSlice);
        end
    end
end