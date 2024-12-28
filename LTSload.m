%% LTSload - loads an LTspice .raw waveform file
%
% [variables, datapoints] = LTSload(filename)
%
% filename - the path to the .raw waveform file
% variables - an array of the variable names
% datapoints - the matrix of the data values, the columns correspond to the
% variables entries.
function [variables, datapoints] = LTSload(filename)
    
    fin = fopen(filename,'r', 'n', 'UTF-16LE');
    
    if fin == -1
        error("invalid filename, file could not be accessed!");
    end
    
    num_vars = 0;
    num_points = 0;
    time_var = 0;

    fprintf("Parse LLTspice raw file:\n");

    while ~feof(fin)
        line = fgetl(fin);
        
        if startsWith(line, "No. Variables")
            numidx = regexp(line, "\d+");
            if (isempty(numidx))
                error("invalid No. Variables tag, number expected!");
                try fclose(fin); catch end
            end
            num_vars = str2double(line(numidx:end));
            fprintf("Num variables: %d\n", num_vars);
        elseif startsWith(line, "No. Points")
            numidx = regexp(line, "\d+");
            if (isempty(numidx))
                error("invalid No. Points tag, number expected!");
                try fclose(fin); catch end
            end
            num_points = str2double(line(numidx:end));
            fprintf("Num data points: %d\n", num_points);
        elseif startsWith(line, "Variables")
            if isempty(num_vars)
                error("Unexpected Variables tag, No. Variables expected first!");
                try fclose(fin); catch end
            end
            
            fprintf("Variables: ");
            variables = cell(1, num_vars);
            for i = (1:num_vars)
                varLine = fgetl(fin);
                tok = regexp(varLine, "(\d+)\t([^\t]+)\t([^\t]+)", 'tokens');
                if ~isequal(size(tok), [1 1]) || ~isequal(size(tok{:}), [1 3])
                    error("invalid variable line in Variables tag!");
                    try fclose(fin); catch end
                end
                groups = tok{:};
                id = str2double(groups{1}) + 1;
                variables{id} = groups{2};

                if isequal(groups{2}, "time")
                    time_var = id;
                end

                fprintf("%s ", groups{2});
            end
            fprintf("\n");
        elseif startsWith(line, "Binary")
            if isempty(variables) || isempty(num_points)
                error("Unexpected Binary tag, Variables and No. Points tag expected first!");
                try fclose(fin); catch end
            end
            
            fprintf("parse binary\n");
            
            datapoints = zeros(num_points,num_vars);
            for r = 1:num_points
                for c = 1:num_vars
                    if c == time_var
                        valD = abs(fread(fin,1,'double')); % why are the time values sometimes negative ???
                        datapoints(r,c) = valD;
                    else
                        valF = fread(fin,1,'float');
                        datapoints(r,c) = valF;
                    end
                end
            end

            break
        end
    end
    
    fclose(fin);
    
    fprintf("Complete, data matrix: %d x %d\n", num_points, num_vars);

end
