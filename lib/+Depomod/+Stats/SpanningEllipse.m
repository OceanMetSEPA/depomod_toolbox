classdef SpanningEllipse < dynamicprops
    
    properties
        EnclosingPoints = [];
        Centre = [];
        MajorSemiAxis@double;
        MinorSemiAxis@double;
        A = [];
        U = [];
        D = [];
        V = [];
    end
    
    methods
        function SE = SpanningEllipse(points)
            SE.EnclosingPoints = points;
            
            [SE.A, SE.Centre] = MinVolEllipse(points', .01);
            [SE.U SE.D SE.V] = svd(SE.A);

            SE.MajorSemiAxis = 1/sqrt(SE.D(1,1));
            SE.MinorSemiAxis = 1/sqrt(SE.D(2,2));            
        end
        
        function a = area(SE)
            a = pi * SE.MajorSemiAxis * SE.MinorSemiAxis;
        end
        
        function c = curve(SE, varargin)
            
            % resolution?
            
            N = 100;
            theta = [0:1/N:2*pi+1/N];
            state=[];
            state(1,:) = SE.MajorSemiAxis*cos(theta); 
            state(2,:) = SE.MinorSemiAxis*sin(theta);
            c = SE.V * state; % rotate
            c(1,:) = c(1,:) + SE.Centre(1);% shift
            c(2,:) = c(2,:) + SE.Centre(2);
        end
        
        function plot(SE)
            c = SE.curve;
            
            plot(c(1,:),c(2,:),'-', 'LineWidth', 1, 'Color', [0.99 0.99 0.99]);
        end
    end
    
end

