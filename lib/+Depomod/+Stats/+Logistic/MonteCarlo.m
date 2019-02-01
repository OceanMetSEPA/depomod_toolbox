classdef MonteCarlo < dynamicprops
    
    properties
        Curves = {};
        Fit@Depomod.Stats.Logistic.Fit;
    end
    
    methods
        function MC = MonteCarlo(logisticFit, N)
            MC.Fit = logisticFit;
            
            for c = 1:N
               MC.Curves{c} = logisticFit.randomCurve;                
            end
        end
        
        function s = size(MC)
            s = numel(MC.Curves);
        end
        
        function s = sample(MC, x)
            s = NaN(MC.size, numel(x));
            
            for c = 1:MC.size
               for v = 1:numel(x)
                   s(c,v) = MC.Curves{c}.solution(x(v));                   
               end
            end
        end
        
        function s = inverseSample(MC, y)
            s = NaN(MC.size, numel(y));
            
            for c = 1:MC.size
               for v = 1:numel(y)
                   s(c,v) = MC.Curves{c}.inverseSolution(y(v));                   
               end
            end
        end    
        
        function p = percentile(MC, x, pctile)
            s = MC.sample(x);
            p = Depomod.Stats.Utils.quantile(s,pctile);
        end 
        
        function p = inversePercentile(MC, y, pctile)
            s = MC.inverseSample(y);
            p = Depomod.Stats.Utils.quantile(s,pctile);
        end
        
        function plot(MC)
            for c = 1:MC.size
                MC.Curves{c}.plot(MC.Fit.X(1):MC.Fit.X(end))
                hold on;
            end
            
            MC.Fit.plot;
        end
    end
    
end

