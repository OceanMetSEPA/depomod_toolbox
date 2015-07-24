function [ curve ] = fluxCurve()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   fluxCurve.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:26  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a matrix representing the piecewise linear model which AutoDepomod uses
    % for mapping benthic flux to ITI, Each row in the matrix represents a line segment
    % based on the following 4 columns
    %
    %  1: The base 10 log of the start fluxvalue for the segment
    %  2: The base 10 log of the end fluxvalue for the segment
    %  3: The gradient of the line segment
    %  4: The y-intercept of the line segment
    %
    % Usage:
    % 
    %    AutoDepomod.ITI.fluxCurve()
    % 
    %
    % OUTPUT:
    %    
    %    curve: a 7 x 4 matrix describing the piecewise linear model
    %
    % EXAMPLES:
    %
    %    lineSegments = AutoDepomod.ITI.fluxCurve()
    %
    
    % List of piecewise line segments
    %
    %  x start, x end, gradient, y-intercept
    %
    % The gradients and intercepts relate to the logarithmic (base 10)
    % x-axis, so the values need to be logged, as does the flux value when
    % evaluating
    %
    curve = [         0.0       log10(5.0)   -1.43067558  59.0;
                log10(5.0)    log10(111.0)  -17.08318727  69.94063548;
              log10(111.0)    log10(300.0)  -20.84306608  77.63080201;
              log10(300.0)   log10(1000.0)  -22.94987147  82.84961442;
             log10(1000.0)   log10(2700.0)  -20.86406126  76.59218377;
             log10(2700.0)  log10(10000.0)   -3.517187041 17.06874817;
            log10(10000.0)             Inf    0.0          1.0         ];
end

