# depomod_toolbox
A MATLAB toolbox for reading, processing and manipulating the particle tracking models AutoDepomod and NewDepomod

## Dependencies
This toolbox works best with the following packages
- the [rcm_toolbox](https://github.com/OceanMetSEPA/rcm_toolbox) MATLAB library
- the [os_toolbox](https://github.com/OceanMetSEPA/os_toolbox) MATLAB library
- the [UTide](https://uk.mathworks.com/matlabcentral/fileexchange/46523--utide--unified-tidal-analysis-and-prediction-functions) MATLAB library
- A working and authorised copy of Admiralty TotalTide software
- the [totaltide_toolbox](https://github.com/OceanMetSEPA/totaltide_toolbox) MATLAB library

## Examples

A comprehensive suite of examples can be found in the \scripts directory

The examples below describe some basic steps for creating a new project from a template and run the model using the command line interface.

### Define name and location
A reasonable default location is below, but it can be anywhere.

    rootDir = 'C:\newdepomod_projects\';

Name the project, this will become the root directory name and prefix of all filenames

    projectName = 'bay_of_fish';

Create project from template with desired location and name
    
    project = NewDepomod.Project.createFromTemplate(rootDir, projectName)
 
    % project = 
    %   Project with properties:
    % 
    %        version: 2
    %       location: [1x1 NewDepomod.PropertiesFile]
    %     bathymetry: [1x1 NewDepomod.BathymetryFile]
    %      flowmetry: [1x1 NewDepomod.FlowmetryFile]
    %           name: 'bay_of_fish'
    %           path: 'C:\newdepomod_projects\bay_of_fish'
    %     solidsRuns: [1 Depomod.Run.Collection]
    %       EmBZRuns: [1 Depomod.Run.Collection]
    %       TFBZRuns: [1 Depomod.Run.Collection]

Notice there includes 1 solids run and 1 EmBZ run as well as objects describing the bathymetry and flow data
     
### View the bathymetry

    figure;
    project.bathymetry.plot

### View the flow (requires rcm_toolbox MATLAB library)

    flowProfile = project.flowmetry.toRCMProfile

    flowProfile.Bins{1}.scatterPlot % bed
    flowProfile.Bins{3}.scatterPlot % surface

### Inspect the solids run

    solidsRun = project.solidsRuns.item(1)

    % solidsRun = 
    %   Solids with properties:
    % 
    %              defaultPlotLevels: [4 192 1553 10000]
    %                    defaultUnit: 'g m^{-2} y^{-1}'
    %                      modelFile: [1x1 NewDepomod.PropertiesFile]
    %         physicalPropertiesFile: [1x1 NewDepomod.PropertiesFile]
    %              configurationFile: [1x1 NewDepomod.PropertiesFile]
    %                    runtimeFile: [1x1 NewDepomod.PropertiesFile]
    %                     inputsFile: [1x1 NewDepomod.InputsPropertiesFile]
    %            iterationInputsFile: []
    %         exportedTimeSeriesFile: []
    %     consolidatedTimeSeriesFile: []
    %                      solidsSur: []
    %                      carbonSur: []
    %             iterationRunNumber: '1'
    %                  modelFileName: 'bay_of_fish-1-NONE.depomodmodelproperties'
    %                        project: [1x1 NewDepomod.Project]
    %                    cfgFileName: []
    %                      runNumber: '1'
    %                          cages: [2 Depomod.Layout.Site]


Notice this references all of the input (e.g. cages, inputs, physical) files and all of the output files (sur(face), time series) which will be written when the mdoel is executed. So this object can be used to navigate all of the information related to a particular run.

Check out the biomass

    solidsRun.inputsFile.FeedInputs.biomass
    solidsRun.inputsFile.FeedInputs.stockingDensity

    % ans =
    % 1000
    % ans =
    % 13.0826

And some of the physical properties

    solidsRun.physicalPropertiesFile.Transports.bottomRoughnessLength.smooth
    solidsRun.physicalPropertiesFile.Transports.resuspension.walker.dispersionCoefficientX

    % ans =
    % 0.00003
    % ans =
    % 0.1

And some of the cage properties

    solidsRun.cages.consolidatedCages.size       % count
    solidsRun.cages.consolidatedCages.cageArea   % m2
    solidsRun.cages.consolidatedCages.cageVolume % m3

    % ans =
    %      8
    % ans =
    %           6369.80278655024
    % ans =
    %           76437.6334386029
          
### Execute model run

- Open up user interface
- Open up bay_of_fish project
- Navigate to models
- Right-click on the solids (NONE) run #1
- Select single run

### Read results files

Check run ITI score (ITI contour around 80% particles)

    solidsRun.log.Eqs.benthic.iti

Check DZR impact area (equivalent to 4g m-2 y-1)

    solidsRun.log.Eqs.BenthicImpactedAreaEQS.area

Check mass released...

    solidsRun.log.Masses.solids.released.run

...and compare with mass remaining in domain - the difference is "exported"

    solidsRun.log.Masses.solids.balance.run

Measure the predicted area of a specific impact level

    solidsRun.solidsSur.area(4) % 4 g m-2

Get the predicted value at a specific location

    solidsRun.solidsSur.valueAt(351000,1068800) % easting, northing

### Plot impact

    solidsRun.plot


