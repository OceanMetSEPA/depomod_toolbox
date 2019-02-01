classdef Fit
    
    properties
        Parameters = [];       % x_0, L, k
        ConfidenceLimits = []; % 1 x sigma
        X = [];
        Y = [];
        VarCov = []
        Curve@Depomod.Stats.Logistic.Curve;
    end
    
    methods
        function F = Fit(x,y)
           [Qpre, params, cl, varcov] = Depomod.Stats.Utils.fit_logistic(x, y);
 
           F.Parameters = params([2 3 1]);
           F.ConfidenceLimits = cl([2 3 1]);
           F.VarCov = varcov;
           F.X = x;
           F.Y = y;
           
           F.Curve = Depomod.Stats.Logistic.Curve(...
               F.Parameters(1),...
               F.Parameters(2),...
               F.Parameters(3)...
               )
        end
        
        function c = randomCurve(F)
            p1 = F.randomParameter(1);
            p2 = F.randomParameter(2);
            p3 = F.randomParameter(3);
                
            c = Depomod.Stats.Logistic.Curve(p1, p2, p3);
        end
        
        function p = randomParameter(F, paramIdx)
            p = (randn*F.ConfidenceLimits(paramIdx)) + F.Parameters(paramIdx);
        end
        
        function plot(F)
            plot(F.X, F.Y, 'wo', 'MarkerFaceColor','r');
            hold on;
            grid on;
            F.Curve.plot(F.X(1):F.X(end));
            ylim([0 1])
        end
        
        function m = monteCarlo(F, N)
            m = Depomod.Stats.Logistic.MonteCarlo(F, N);
        end
    end
    
end

