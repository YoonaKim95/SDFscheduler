clear
clc
%SDFgraph    = SDFgraph_read('scheduling_example1/toy1.xml');
%Schedule    = Schedule_read('scheduling_example1/toy1_4_schedule.xml');
%SDFgraph    = SDFgraph_read('scheduling_example1/toy2.xml');
%Schedule    = Schedule_read('scheduling_example1/toy2_3_schedule.xml');
%SDFgraph    = SDFgraph_read('scheduling_example2/toy_cap.xml');
%Schedule    = Schedule_read('scheduling_example2/task_default_2_schedule.xml');
%Schedule    = Schedule_read('scheduling_example2/task_default_3_schedule.xml');

%SDFgraph    = SDFgraph_read('Example _ ETL/toy1.xml');
%Schedule    = Schedule_read('Example _ ETL/task_1_3_schedule.xml');
SDFgraph    = SDFgraph_read('Example _ ETL/toy2.xml');
%Schedule    = Schedule_read('Example _ ETL/task_2_2_schedule.xml');
%SDFgraph    = SDFgraph_read('Example _ ETL/toy_cap.xml');
%Schedule    = Schedule_read('Example _ ETL/task_cap_2_schedule.xml');
%SDFgraph    = SDFgraph_read('Example _ ETL/toy3_ex.xml');
%SDFgraph    = SDFgraph_read('Example _ ETL/toy4_ex.xml');
nSchedule = Algorithm_2_DLS(SDFgraph);
%Schedule_evaluate(SDFgraph, Schedule);
Schedule_evaluate(SDFgraph, nSchedule);
Schedule_write(SDFgraph, nSchedule, '.');
