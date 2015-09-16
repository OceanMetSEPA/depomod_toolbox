function [ flux ] = toFlux( iti )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   toFlux.m  $
% $Revision:   1.3  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:26  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns the benthic flux associated with the passed in ITI
    %
    % Usage:
    % 
    %    AutoDepomod.ITI.toFlux()
    % 
    %
    % OUTPUT:
    %    
    %    flux: a decimal representing the benthic flux related to
    %    particular ITI
    %
    % EXAMPLES:
    %
    %    flux = AutoDepomod.ITI.toFlux(30)
    %    ans =
    %        191.846...
    %
    
    curve = AutoDepomod.ITI.fluxCurve;
    
    % If the iti is outside thedomain of the function (which is 1 < ITI < 59),
    % return the appropriate extremity.
    if iti < 3.01
        % This is a bit of a hack. There is a discontinuity in the ITI
        % curve at ITI ~ 3.
        flux = 10000;
    elseif iti > 59
        flux = 0;
    else
        for seg = 1:7
               
          % Need to subtract 1 from the fluxes in the flux->ITI evaluations for each comparison since
          % this is how the conversion adds 1 to avoid taking logs of 0.
          if iti <= (AutoDepomod.ITI.fromFlux(10^curve(seg, 1)-1)) && iti >= (AutoDepomod.ITI.fromFlux(10^curve(seg, 2)-1))
              segment = curve(seg, :);
              flux = 10^((iti - segment(4))/segment(3)) - 1.0;
              
              break
          end
        end
    end
end