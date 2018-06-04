SDFgraph = SDFgraph_read('toy_cap.xml');
Schedule = Schedule_read('task_default_4_schedule.xml');
Schedule_write(SDFgraph, Schedule);