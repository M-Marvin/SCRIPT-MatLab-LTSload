An simple script to load binary .raw files from LTspice into MATLAB.
The data points get loaded as matrix of size n x m, where m is the number of variables, and n the number of time-points.
An cell array containing the variable names for the indecies of the m columns is also provided.

The script does not yet support loading .raw files where all values where forced to be safed with double precision, but it would be easy to modify it for those too.
