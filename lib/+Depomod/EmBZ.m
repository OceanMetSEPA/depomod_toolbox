classdef EmBZ
    
    % EMBZ Summary of this class goes here
    % Detailed explanation goes here
    
    properties (Constant = true)
        ExcretionRate  = 0.01925408834889; % day-1
        DecayRate      = -log(0.5)/250;    % day-1
        LinearDays     = 7;                % days
        LinearFraction = 0.1;              %
    end
    
    methods (Static = true)
        
        function [ mass ] = kineticModel(mass, t, varargin)

            % EMBZMODEL Summary of this function goes here
            % Detailed explanation goes here

            excretionRate  = Depomod.EmBZ.ExcretionRate;
            decayRate      = Depomod.EmBZ.DecayRate;
            linearDays     = Depomod.EmBZ.LinearDays;
            linearFraction = Depomod.EmBZ.LinearFraction;
            
            massBalanceFraction = 1.0;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'excretionRate'
                  excretionRate = varargin{i+1};
                case 'decayRate'
                  decayRate = varargin{i+1};
                case 'linearDays'
                  linearDays = varargin{i+1};
                case 'linearFraction'
                  linearFraction = varargin{i+1};
                case 'massBalanceFraction'
                  massBalanceFraction = varargin{i+1};
              end
            end

            linearPeriod = t(t<=linearDays);
            remainder    = t(t>linearDays);

            linearPeriodMasses = cumsum(exp(-decayRate).^linspace(6,0,linearDays)).*(linearFraction*massBalanceFraction*mass / linearDays);
            remainderMasses    = ((excretionRate*massBalanceFraction*(1-linearFraction)*mass)/(decayRate - excretionRate))*(exp(-excretionRate*(remainder-linearDays)) - exp(-decayRate*(remainder-linearDays))) + linearPeriodMasses(linearDays)*exp(-decayRate*(remainder-linearDays));

            mass = horzcat(linearPeriodMasses(linearPeriod), remainderMasses);
        end
        
        function mass = multiTreatmentKineticModel(treatments, varargin)
            
            % day/mass, day/mass, day/mass, etc.
            % treatments = [0, 500; 400 300; 550 225; 600 500];
            
            extendDays = 118;
            
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'extendDays'
                  extendDays = varargin{i+1};
              end
            end

            maxTime = max(treatments(:,1)) + extendDays;

            timeVector = 1:1:maxTime;
            output = zeros(length(treatments), maxTime);
                        
            for i = 1:size(treatments,1)
                output(i, (treatments(i,1)):maxTime) = Depomod.EmBZ.kineticModel(treatments(i,2),1:1:(maxTime-treatments(i,1)+1),varargin{:});
            end

            mass = sum(output,1);

            plot(timeVector,mass); grid on
        end
        
        function mass = excretionModel(treatment, t, varargin)
            excretionRate  = Depomod.EmBZ.ExcretionRate;
            linearDays     = Depomod.EmBZ.LinearDays;
            linearFraction = Depomod.EmBZ.LinearFraction;
                        
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'excretionRate'
                  excretionRate = varargin{i+1};
                case 'linearDays'
                  linearDays = varargin{i+1};
                case 'linearFraction'
                  linearFraction = varargin{i+1};
              end
            end
            
            mass = zeros(length(t),1);
            
            for tIdx = 1:length(t)
            	if t(tIdx) <=7
                    mass(tIdx) = (linearFraction*treatment/linearDays)*t(tIdx);
                else
                    mass(tIdx) = linearFraction * treatment ...
                        + (1-linearFraction)*treatment*(1-exp(-excretionRate*(t(tIdx)-linearDays)));
                end
            end            
        end
        
        function mass = massReleased2MassTreated(massReleased, t, varargin)
            excretionRate  = Depomod.EmBZ.ExcretionRate;
            linearDays     = Depomod.EmBZ.LinearDays;
            linearFraction = Depomod.EmBZ.LinearFraction;
                        
            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'excretionRate'
                  excretionRate = varargin{i+1};
                case 'linearDays'
                  linearDays = varargin{i+1};
                case 'linearFraction'
                  linearFraction = varargin{i+1};
              end
            end
            
            if t <=7
                mass = (linearDays*massReleased)/(linearFraction*t);
            else
                mass = massReleased / (linearFraction + (1-linearFraction)*(1-exp(-excretionRate*(t-linearDays))));
            end
        end
        
        function d = theoreticalMaximaDays()
            d = log(Depomod.EmBZ.ExcretionRate/Depomod.EmBZ.DecayRate)/(Depomod.EmBZ.ExcretionRate - Depomod.EmBZ.DecayRate);
        end
        
        function f = theoreticalMaxFraction()
            f = Depomod.EmBZ.kineticModel(1,Depomod.EmBZ.theoreticalMaximaDays);
        end
        
        function b = grams2Biomass(mass)
            % Returns the treatable biomass in t associated with a mass of the active ingredient EmBZ in g.

            % dose rate = 50 ?g / kg (per day for 7 days)
            %           = 50 mg / t 
            %           = 0.05 g / t
            b = mass / (7 * 0.05);
        end
        
        function g = biomass2Grams(biomass)
            % Returns the mass of the active ingredient EmBZ in g for a biomass
            % described in t.

            % "Slice is supplied as a premix in 2.5 kg sachets, each containing 5 g of emamectin benzoate (EmBZ)
            % in an inert matrix. Each sachet of premix is wet or dry coated onto sufficient quantity of 
            % pelletised fish feed to produce 500 kg of medicated feed. The recommended dose rate is 50 ?g 
            % per kg of fish biomass per day for seven consecutive days. It therefore follows that for effective 
            % treatment each tonne of biomass will require 5 kg of medicated feed per day for the seven days 
            % of the treatment".

            % dose rate = 50 ?g / kg 
            %           = 50 mg / t 
            %           = 0.05 g / t

            g = biomass * (7 * 0.05);
        end


    end
    
end

