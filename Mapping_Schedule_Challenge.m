function Mapping_Schedule_Challenge(inputfile, outputfolder)
if nargin < 2
  outputfolder = '.';
end
SDFgraph    = SDFgraph_read(inputfile);
Schedule = Algorithm_1_HLFET(SDFgraph,0);
Schedule_evaluate(SDFgraph, Schedule);
Schedule_write(SDFgraph, Schedule2, outputfolder);
end