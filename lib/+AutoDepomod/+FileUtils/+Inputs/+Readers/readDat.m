function [ outStruct ] = readDat( fileName )

    fd = fopen(fileName,'rt');
    header1 = fgetl(fd);
    header2 = fgetl(fd);
    header3 = fgetl(fd);
    data   = textscan(fd, '%u%f%f%u%f%f');
    fclose(fd);
        
    outStruct.Header1 = header1;
    outStruct.Header2 = header2;
    outStruct.Header3 = header3;
    outStruct.Data = data;   
end

