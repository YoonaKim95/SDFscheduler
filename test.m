clear
clc
%SDFgraph    = SDFgraph_read('scheduling_example1/toy1.xml');
%Schedule    = Schedule_read('scheduling_example1/toy1_4_schedule.xml');
SDFgraph    = SDFgraph_read('scheduling_example1/toy2.xml');
Schedule    = Schedule_read('scheduling_example1/toy2_3_schedule.xml');
%SDFgraph    = SDFgraph_read('scheduling_example2/toy_cap.xml');
%Schedule    = Schedule_read('scheduling_example2/task_default_2_schedule.xml');
%Schedule    = Schedule_read('scheduling_example2/task_default_3_schedule.xml');
nSchedule    = Schedule_evaluate(SDFgraph, Schedule);
