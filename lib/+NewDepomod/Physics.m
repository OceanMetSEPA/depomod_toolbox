classdef Physics
    
    properties (Constant = true)
        rho               = 1025
        vonKarmanConstant = 0.41
        
        shearVelocityRoughConstant      = 4.9;
        shearVelocityRoughFactor        = 5.6;
        shearVelocityTransitionalFactor = 8.18;
        shearVelocityRoughSmoothFactor  = 0.65;
        
        % default Improvement project erosion equation used the parameters
        % below. An alternative "second-choice" formulation involved a
        % constant of 0.009 and an exponent of 0.36
        
        defaultZ0              = 0.00003; % m
        defaultTauCrit         = 0.02;
        defaultErosionConstant = 0.031;
        defaultErosionExponent = 1.0;
        
        defaultBedFlowHeight = 3.0; % m
        
        defaultRegime = 'rough'
    end
    
    methods (Static = true)
        
        function uStar = shearVelocity(flowSpeed, varargin)
            regime = NewDepomod.Physics.defaultRegime;
            z      = NewDepomod.Physics.defaultBedFlowHeight;
            z0     = NewDepomod.Physics.defaultZ0;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'regime'
                  regime = varargin{i+1};
                case 'z'
                  z = varargin{i+1};
                case 'z0'
                  z0 = varargin{i+1};
              end
            end
            
            switch regime
                case 'rough'
                    uStar = flowSpeed./(NewDepomod.Physics.shearVelocityRoughConstant + NewDepomod.Physics.shearVelocityRoughFactor * log10(z/(5*z0)));
                case 'transitional'               
                    uStar = flowSpeed./(NewDepomod.Physics.shearVelocityTransitionalFactor * log10(z/(5*z0)));
                case 'smooth'
                    uStar = flowSpeed./(NewDepomod.Physics.shearVelocityRoughSmoothFactor * log10(z/(5*z0)));
                case 'low' % Law of the Wall
                    uStar = (flowSpeed.*NewDepomod.Physics.vonKarmanConstant)./(log10(z/z0));
                otherwise
                    error('Specified regime not supported')
            end
        end
        
        function tau = shearStress(flowSpeed, varargin)
            rho = NewDepomod.Physics.rho;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'rho'
                  rho = varargin{i+1};
              end
            end
            
            uStar = NewDepomod.Physics.shearVelocity(flowSpeed, varargin{:});
            tau   = rho.*(uStar).^2;
        end
        
        function er = erosionPotential(flowSpeed, varargin)
            tauCrit         = NewDepomod.Physics.defaultTauCrit;
            erosionConstant = NewDepomod.Physics.defaultErosionConstant;
            erosionExponent = NewDepomod.Physics.defaultErosionExponent;
        
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'tauCrit'
                  tauCrit = varargin{i+1};
                case 'erosionConstant'
                  erosionConstant = varargin{i+1};
                case 'erosionExponent'
                  erosionExponent = varargin{i+1};
              end
            end
            
            shearStressExceedances = NewDepomod.Physics.shearStress(flowSpeed) - tauCrit;
            shearStressExceedances(shearStressExceedances<0)=0.0
            
            er = erosionConstant.*shearStressExceedances.^erosionExponent;
        end
    end
    
end

