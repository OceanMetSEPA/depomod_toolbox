classdef Fit
    
    properties
        Parameters = [];       % L, k, x_0
        ConfidenceLimits = []; % 1 x sigma
        X = [];
        Y = [];
        VarCov = []
        Curve@Depomod.Stats.Logistic.Curve;
    end
    
    methods
        function F = Fit(x,y)
           [Qpre, params, cl, varcov] = Depomod.Stats.Utils.fit_logistic(x, y);
 
           F.Parameters       = params([2 3 1]);
           F.ConfidenceLimits = cl([2 3 1]);
           F.VarCov = varcov;
           F.X = x;
           F.Y = y;
           
           F.Curve = Depomod.Stats.Logistic.Curve(...
               F.Parameters(1),...
               F.Parameters(2),...
               F.Parameters(3)...
               );
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
            plot(F.X, F.Y, 'wo', 'MarkerFaceColor','k');
            hold on;
            grid on;
            F.Curve.plot(F.X(1):F.X(end), 'Colour', 'k', 'LineWidth', 1.5);
            ylim([0 1]);
        end
        
        function bool = acceptable(F)
           % Tentative method for filtering out bad fits
           % Probably need more criteria
           
           % This simply tries to screen out fits that have enormous
           % ranges of asymptotic values
           %
           % and that the slope isn't almost completely vertical
           bool = F.ConfidenceLimits(1)<(F.Parameters(1)*10) & ...
               F.ConfidenceLimits(2) < 999999;
        end
        
        function bool = unacceptable(F)
            % convenience
            bool = ~F.acceptable;
        end
        
        function m = monteCarlo(F, N)
            m = Depomod.Stats.Logistic.MonteCarlo(F, N);
        end
    end
    
end

