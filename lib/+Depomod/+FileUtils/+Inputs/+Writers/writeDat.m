function [ fileInfo,sizeInBytes ] = writeDat( datStruct, fileName )
    %WRITEDAT Summary of this function goes here
    %   Detailed explanation goes here
    
    MACHINEFORMAT='ieee-be';
    PERMISSION='w';
    numberOfMembers = length(datStruct.Data{1});
    filePointer = fopen(fileName,PERMISSION,MACHINEFORMAT);
    
    % Write header lines
    fprintf(filePointer,[datStruct.Header1,'\r\n']);
    fprintf(filePointer,[datStruct.Header2,'\r\n']);
    fprintf(filePointer,[datStruct.Header3,'\r\n']);
        
    % Write each data record
    for index = 1:numberOfMembers
                
        rowData = [ double(datStruct.Data{1}(index)) % coerce to double so that entire row does not get truncated into integers
                    datStruct.Data{2}(index)
                    datStruct.Data{3}(index)
                    double(datStruct.Data{4}(index)) % coerce to double so that entire row does not get truncated into integers
                    datStruct.Data{5}(index)
                    datStruct.Data{6}(index)
                  ];
            
        % Write row to file
        fprintf(filePointer, '%-9.0u %-9.2f %-9.2f %-9.0u %-9.2f %-9.2f\r\n', rowData);
    end
    
    % End file file a single '#' character
    fprintf(filePointer,'#\r\n');
    
    fclose(filePointer);
    fileInfo=dir(fileName);
    sizeInBytes=fileInfo.bytes;
end

