function [ exp ] = combinar_experimentos( folder_fullPath )
%combinar_experimentos Esta função combina todos os experimentos
%   de uma pasta. Esta pasta deve conter diversos ensaios de um
%   mesmo tipo. Esperasse também que todos os ensaios possuam uma
%   variável chamada 'y1y2' com os valores de saída e uma chamada
%   'u1u2' com os valores de entrada no sistema.

if folder_fullPath == 0, return, end

localStruct = struct();

myFiles = dir(fullfile(folder_fullPath, '*.mat'));
for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(folder_fullPath, baseFileName);
    load(fullFileName);
    
    localStruct.(strcat('u1_',int2str(k))) = u1u2.Data(:,1);
    localStruct.(strcat('u2_',int2str(k))) = u1u2.Data(:,2);
    
    localStruct.(strcat('y1_',int2str(k))) = y1y2.Data(:,1);
    localStruct.(strcat('y2_',int2str(k))) = y1y2.Data(:,2);
    
    try
        localStruct.('y1_Media') = localStruct.('y1_Media') + y1y2.Data(:,1);
    catch ME
        switch ME.identifier
            case 'MATLAB:nonExistentField'
                localStruct.('y1_Media') = 0;
                localStruct.('y1_Media') = localStruct.('y1_Media') + y1y2.Data(:,1);
        end
    end
    
    
    try
        localStruct.('y2_Media') = localStruct.('y2_Media') + y1y2.Data(:,2);
    catch ME
        switch ME.identifier
            case 'MATLAB:nonExistentField'
                localStruct.('y2_Media') = 0;
                localStruct.('y2_Media') = localStruct.('y2_Media') + y1y2.Data(:,2);
        end
    end
    
end

localStruct.('y1_Media') = localStruct.('y1_Media') / k;
localStruct.('y2_Media') = localStruct.('y2_Media') / k;

localStruct.('time') = y1y2.Time;

try
    localArray = [localStruct.('time') localStruct.('u1_1') localStruct.('u2_1') localStruct.('y1_Media') localStruct.('y2_Media')];
    localTable = array2table(localArray, 'VariableNames', {'Time', 'Aquecedor1', 'Aquecedor2', 'Sensor1', 'Sensor2'});
    exp = localTable;
catch ME
    switch ME.identifier
        case 'MATLAB:catenate:dimensionMismatch'
            exp = localStruct;
    end
    
end

end

