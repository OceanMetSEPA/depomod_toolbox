classdef LogFile < AutoDepomod.LogFile
    
    
    properties (Constant = true)
        runNoRow = 4;    
    end
    
    methods
        
        function LF = LogFile(path)
            LF = LF@AutoDepomod.LogFile(path)
        end
    end
    
    methods (Access = private)
        
        function rns = runNumbers(LF)
            % Returns a list of the run numbers for all of the runs
            % described in the logfile
            rns = LF.table(2:end,LF.runNoRow);
        end
        
    end
end

