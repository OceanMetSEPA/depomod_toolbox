classdef ModelFit < dynamicprops
    
    properties
        Eastings    = [];
        Northings   = [];
        Values      = [];
        ModelValues = [];
        OffsetX     = 0;
        OffsetY     = 0;
        Survey@Depomod.Survey.TransectSurvey;
        ModelSurvey@Depomod.Survey.TransectSurvey;
        Sur@Depomod.Sur.Base;
    end
    
    methods (Static = true)
        function MF = createFromSurvey(survey, varargin)
            MF = Depomod.Stats.ModelFit;
            MF.Survey = survey;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'offsetX' % 
                        MF.OffsetX = varargin{i+1};
                    case 'offsetY' % 
                        MF.OffsetY = varargin{i+1};
                    case 'sur' % 
                        MF.Sur = varargin{i+1};
                    case 'modelSurvey' % 
                        MF.ModelSurvey = varargin{i+1};
                end
            end
            
            if isempty(MF.ModelSurvey)
                MF.ModelSurvey = MF.Survey.clone;
                MF.ModelSurvey.setValuesFromSur(MF.Sur);
            end
            
            MF.setDataFromSurveys;
        end
        
        function MF = createFromMultiSurveys(surveys, modelSurveys, varargin)
            MF = Depomod.Stats.ModelFit;
            MF.OffsetX = 0;
            MF.OffsetY = 0;
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
                switch varargin{i}
                    case 'offsetX' % 
                        MF.OffsetX = varargin{i+1};
                    case 'offsetY' % 
                        MF.OffsetY = varargin{i+1};
                end
            end
            
            for s = 1:numel(surveys)
                mf = Depomod.Stats.ModelFit;
                mf.Survey      = surveys{s};
                mf.ModelSurvey = modelSurveys{s}
                mf.OffsetX = MF.OffsetX;
                mf.OffsetY = MF.OffsetY;
                
                mf.setDataFromSurveys;
                
                surveyData = mf.Survey.toMatrix;
                modelData  = mf.ModelSurvey.toMatrix;

                MF.Eastings    = vertcat(MF.Eastings,    surveyData(:,6));
                MF.Northings   = vertcat(MF.Northings,   surveyData(:,7));
                MF.Values      = vertcat(MF.Values,      surveyData(:,9));
                MF.ModelValues = vertcat(MF.ModelValues, modelData(:,9));  
            end
            
        end
    end
    
    methods
        function MF = ModelFit(varargin)
        end
        
        function setDataFromSurveys(MF)
            surveyData = MF.Survey.toMatrix;
            modelData  = MF.ModelSurvey.toMatrix;
            
            MF.Eastings  = surveyData(:,6);
            MF.Northings = surveyData(:,7);
            MF.Values      = surveyData(:,9);
            MF.ModelValues = modelData(:,9);                   
        end
        
        function r = residuals(MF)
            r = MF.ModelValues - MF.Values;
        end
        
        function sr = squaredResiduals(MF)
            sr = (MF.residuals).^2;
        end
        
        function r = ratios(MF)
            r = MF.ModelValues./MF.Values;
        end
        
        function mr = meanRatio(MF)
            r = MF.absoluteRatios;
            isValid = isfinite(r) & ~isnan(r);
            
            if sum(isValid) < numel(MF.Values)*0.75
                mr = NaN;
            else
                mr = mean(r(isValid));
            end
        end
        
        function ar = absoluteRatios(MF)
            ar = 10.^abs(log10(MF.ModelValues./MF.Values));
        end
        
        function m = mean(MF)
            m = mean(MF.Values);
        end
        
        function mm = modelMean(MF)
            mm = mean(MF.ModelValues);
        end
        
        function gm = geometricMean(MF)
            gm = prod(MF.Values).^(1/numel(MF.Values));
        end
        
        function gmm = geometricModelMean(MF)
            gmm = prod(MF.ModelledValues).^(1/numel(MF.ModelledValues));
        end
        
        function rmse = rmse(MF)
            rmse = sqrt(MF.variance);
        end
        
        function v = variance(MF)
            v = mean(MF.squaredResiduals);
        end
        
        function b = bias(MF)
            b = mean(MF.residuals);
        end
        
        function rmse = zeroRMSE(MF)
            rmse = sqrt(mean((MF.Values).^2));
        end

    end
    
end

