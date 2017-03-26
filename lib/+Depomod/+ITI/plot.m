function plot()
    % Generates a plot showing the relationship between benthic flux and
    % ITI. This relationship is based on the peicewise linear segments used
    % in AutoDepomod.
    %
    % Usage:
    % 
    %    Depomod.ITI.plot()
    % 
    %
    % OUTPUT:
    %    
    %    no explicit matlab output other than a generated plot.
    %
    % EXAMPLES:
    %
    %    Depomod.ITI.plot
    %    

    x = [0:0.2:20 20:10:500 500:100:10000 10000:1000:100000];
    y = zeros(size(x));
    
    for i = 1:size(x,2)
        y(1,i) = Depomod.ITI.fromFlux(x(i));
    end
    
    figure;
    semilogx(x,y)
    grid on
    ylabel('ITI');
    xlabel('Flux (g m-2 yr-1)');
    title('AutoDepomod implementation of flux/ITI relationship')
end

