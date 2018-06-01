SDFgraph = SDFgraph_read('scheduling_example1/toy1.xml');
Schedule = Schedule_read('scheduling_example1/toy1_4_schedule.xml');

outpath = [SDFgraph.filepath '/' SDFgraph.filename '_schedule.xml'];
