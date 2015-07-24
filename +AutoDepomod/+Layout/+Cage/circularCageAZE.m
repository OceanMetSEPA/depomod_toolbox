function [ AZEArea ] = circularCageAZE( AZEDistance, cageRadius, longitudinalNumber, transverseNumber, longitudinalCageDistance, transverseCageDistance )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   circularCageAZE.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:46  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here

    % Notional AZE radius of each individual cage
    singleCageAZERadius = AZEDistance + cageRadius;

    % Notional AZE area of each cage
    singleCageAZEArea = pi * singleCageAZERadius^2;
    
    % Area of the square enclosing the individual cage AZE
    % area
    singleCageAZEBoundedSquare = (singleCageAZERadius*2)^2
    
    % Area of the corners associated with each individual cage AZE
    singleCageCornerArea = singleCageAZEBoundedSquare - singleCageAZEArea
    
    singleCageLongitudinalRectangle = (singleCageAZERadius*2) * ((singleCageAZERadius*2) + longitudinalCageDistance)
    singleCageTransverseRectangle   = (singleCageAZERadius*2) * ((singleCageAZERadius*2) + transverseCageDistance)
    
    singleCageLongitudinalSegmentArea = (singleCageAZERadius^2) * acos(longitudinalCageDistance/(2*singleCageAZERadius))
    singleCageTransverseSegmentArea   = (singleCageAZERadius^2) * acos(transverseCageDistance/(2*singleCageAZERadius))
    
    singleCageLongitudinalTriangleArea = (longitudinalCageDistance / 4 * singleCageAZERadius * sin(acos(longitudinalCageDistance/(2*singleCageAZERadius)))) * 2
    singleCageTransverseTriangleArea = (transverseCageDistance / 4 * singleCageAZERadius * sin(acos(transverseCageDistance/(2*singleCageAZERadius)))) * 2

    singleCageLongitudinalOverlapArea = 2 * (singleCageLongitudinalSegmentArea - singleCageLongitudinalTriangleArea)
    singleCageTransverseOverlapArea = 2 * (singleCageTransverseSegmentArea - singleCageTransverseTriangleArea)
    
    singleCageLongitudinalSideIndent = (singleCageLongitudinalRectangle - singleCageCornerArea - singleCageAZEArea - (singleCageAZEArea - singleCageLongitudinalOverlapArea))/2
    singleCageTransverseSideIndent = (singleCageTransverseRectangle - singleCageCornerArea - singleCageAZEArea - (singleCageAZEArea - singleCageTransverseOverlapArea))/2

    totalCageRectangle = (((longitudinalNumber - 1) * longitudinalCageDistance) + (2 * singleCageAZERadius)) * (((transverseNumber - 1) * transverseCageDistance) + (2 * singleCageAZERadius))
    totalSideIndents = ((longitudinalNumber - 1) * singleCageLongitudinalSideIndent * 2 + (transverseNumber - 1) * singleCageTransverseSideIndent * 2)

    AZEArea = totalCageRectangle - totalSideIndents - singleCageCornerArea
end

