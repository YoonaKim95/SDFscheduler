function Mapping_Schedule_Challenge(inputfile, outputfolder)
if nargin < 2
  outputfolder = '.';
end
SDFgraph    = SDFgraph_read(inputfile);
Schedule = Algorithm_2_DLS(SDFgraph,0);
Schedule_evaluate(SDFgraph, Schedule);
Schedule_write(SDFgraph, Schedule, outputfolder);
end