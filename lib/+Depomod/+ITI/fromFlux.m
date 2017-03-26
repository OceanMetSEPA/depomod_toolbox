function [iti] = fromFlux(flux)
    % Returns the ITI associated with the passed in benthic flux
    %
    % Usage:
    % 
    %    Depomod.ITI.fromFlux()
    % 
    %
    % OUTPUT:
    %    
    %    iti: a decimal representing the Infaunal Trophic Index value
    %    related to particular flux benthic quantity
    %
    % EXAMPLES:
    %
    %    iti = Depomod.ITI.fromFlux(191.8)
    %    ans =
    %        30.002
    %
  
    flux = log10(flux + 1.0);
    
    curve = Depomod.ITI.fluxCurve;
    
    % Set iti as a NaN. If the flux is not identied within the model domain
    % in the loop below, the ITI is undefined and therefore is returned as
    % NaN
    iti = NaN;
  
    for seg = 1:7
           
      if flux >= curve(seg, 1) && flux <= curve(seg, 2)
          segment = curve(seg, :);
          iti = flux * segment(3) + segment(4);
          break
      end
    end
end

