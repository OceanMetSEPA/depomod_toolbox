classdef SpatialEnsembleFit < dynamicprops
    
    properties
        RMSE     = [];
        Bias     = [];
        Variance = [];
        
        Survey@Depomod.Survey.TransectSurvey;
        ModelSurveys@Depomod.Survey.TransectSurvey;
        Sur@Depomod.Sur.Base;
        ModelFits@Depomod.Stats.ModelFit;
    end
    
    methods (Static = true)
        function SEF = createFromSurvey(survey, sur, varargin)
            % Might want to change this so that the x and y shift occur
            % relative to the cage major axis rather than the ardinal
            % directions
            
            SEF = Depomod.Stats.SpatialEnsembleFit;

            SEF.Survey = survey;
            SEF.Sur    = sur;
            
            xRange = -100:25:100;
            yRange = -100:25:100;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'sur' % 
                        SEF.Sur = varargin{i+1};
                    case 'xRange' % 
                        xRange = varargin{i+1};
                    case 'yRange' % 
                        xRange = varargin{i+1};
                end
            end
            
            for xi = 1:numel(xRange)
                for yi = 1:numel(yRange)
                    
                    modelSurvey = SEF.Survey.clone;
                    modelSurvey.shiftPoints('x', xRange(xi), 'y', yRange(yi));
                    modelSurvey.setValuesFromSur(SEF.Sur);
                    
                    modelFit = Depomod.Stats.ModelFit.createFromSurvey(...
                        SEF.Survey, ...
                        'modelSurvey', modelSurvey, ...
                        'offsetX', xRange(xi), ...
                        'offsetY', yRange(yi) ...
                        );
                    
                    SEF.ModelSurveys(end+1) = modelSurvey;
                    SEF.ModelFits(end+1)    = modelFit;
                end
            end
            
            SEF.setDataFromFits;
        end
    end
    
    methods
        function SEF = SpatialEnsembleFit(varargin)
        end
        
        function s = size(SEF)
            s = numel(SEF.ModelFits);
        end
        
        function setDataFromFits(SEF)
            for m = 1:SEF.size
            
                SEF.RMSE(m)     = SEF.ModelFits(m).rmse;
                SEF.Variance(m) = SEF.ModelFits(m).variance;
                SEF.Bias(m)     = SEF.ModelFits(m).bias;
            end
        end

        function rmse = rmse(SEF)
            rmse = [];
            for m = 1:SEF.size
                rmse(m) = SEF.ModelFits(m).rmse;
            end
        end
        
        function bias = bias(SEF)
            bias = [];
            for m = 1:SEF.size
                bias(m) = SEF.ModelFits(m).bias;
            end
        end
        
        function rr = rmseRank(SEF)
            rmse = SEF.rmse;
            [~, rr] = sort(rmse);
        end
    end
    
end

