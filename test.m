clear
clc

%SDFgraph    = SDFgraph_read('Example_ETL/toy1.xml');
%SDFgraph    = SDFgraph_read('Example_ETL/toy2.xml');
%SDFgraph    = SDFgraph_read('Example_ETL/toy_cap.xml');
%SDFgraph    = SDFgraph_read('Example_ETL/toy3_ex.xml');
SDFgraph    = SDFgraph_read('Example_ETL/toy4_ex.xml');

Schedule1 = Algorithm_1_HLFET(SDFgraph,0);
Schedule2 = Algorithm_2_DLS(SDFgraph,0);
Schedule_evaluate(SDFgraph, Schedule1);
Schedule_evaluate(SDFgraph, Schedule2);
Schedule_write(SDFgraph, Schedule2, '.');
