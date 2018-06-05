function nSchedule = Schedule_evaluate(SDFgraph, Schedule)
%list of time events
events = table;
nProcessors = length(Schedule.taskGroup.scheduleGroups);
for idx = 1:nProcessors
    scheduleGroup   = Schedule.taskGroup.scheduleGroups(idx);
    ntask = length(scheduleGroup.tasks);
    for jdx = 1:ntask
        task  = scheduleGroup.tasks(jdx);
        repetition = str2num(task.repetition);
        rtime      = str2double(task.startTime);
        ractor     = task.name;
        ractoridx  = SDFgraph.map_name2idx(ractor);
        rexec      = SDFgraph.actors(ractoridx).execTime;
        for rdx = 0:repetition-1
            %add start time
            event.actor = ractor;
            event.thread= idx;
            event.time  = rtime + rdx * rexec;
            event.type  = "start";
            events = [events; struct2table(event)];
            event.time  = event.time + rexec;
            event.type  = "finish";
            events = [events; struct2table(event)];
        end
        assert(str2double(task.endTime) == event.time, 'event time mismatched.');
    end
end
events = sortrows(events,'type');
events = sortrows(events,'time');
clear idx jdx rdx ntask event rtime task repetition rtime ractor ractoridx rexec scheduleGroup

%time requirement
t0      = events(1,:).time;
t2      = events(end,:).time;
ntimes   = [];
for idx=1:nProcessors
    mEvents = events(events.thread == idx, :);
    ntime   = mEvents(end,:).time - (mEvents(1,:).time - t0);
    ntimes  = [ntimes; ntime];
end
t1 = max(ntimes);
period_duration = t1 - t0;
if(period_duration <= SDFgraph.timeConstraints)
    disp('the time constraint satisfied.');
end

%add events of next period
% events_pure = events;
% for tt = t1:period_duration:t2
%     for idx=1:size(events_pure,1)
%         event  = events_pure(idx,:);
%         event.time = event.time + tt;
%         if (event.time < t2)
%             events = [events; event];
%         end
%     end
% end
% events = sortrows(events,'type');
% events = sortrows(events,'time');
clear mEvents event ntimes ntime idx tt t0 t1 t2

%number of buffer
matrix_buffers  = zeros(size(SDFgraph.channels));
for idx = 1:size(matrix_buffers,1)
	for jdx = 1:size(matrix_buffers,2)
        if(~isempty(SDFgraph.channels{idx,jdx}))
            matrix_buffers(idx, jdx) = SDFgraph.channels{idx,jdx}.initialTokens;
        end
	end  
end %end init
max_buffers = matrix_buffers;
init_buffers= matrix_buffers;

nevents = size(events, 1);
for idx = 1:nevents
    event = events(idx,:);
    ractor_idx  = SDFgraph.map_name2idx(event.actor);
    if (event.type == "start")
        for jdx = 1:size(SDFgraph.channels,1)
           if(~isempty(SDFgraph.channels{jdx, ractor_idx}))
               matrix_buffers(jdx, ractor_idx) = matrix_buffers(jdx, ractor_idx) - SDFgraph.channels{jdx, ractor_idx}.rate_out;
               assert(matrix_buffers(jdx, ractor_idx) >= 0, 'schedule not satisfied input/output constrain.');
           end
        end
    else
        for jdx = 1:size(SDFgraph.channels,2)
            if(~isempty(SDFgraph.channels{ractor_idx, jdx}))
               matrix_buffers(ractor_idx, jdx) = matrix_buffers(ractor_idx, jdx) + SDFgraph.channels{ractor_idx, jdx}.rate_in;
               if (matrix_buffers(ractor_idx, jdx) > max_buffers(ractor_idx, jdx))
                   max_buffers(ractor_idx, jdx) = matrix_buffers(ractor_idx, jdx);
               end
           end
        end
    end
end
nBuffers = sum(max_buffers(:));
diff     = matrix_buffers - init_buffers;
assert(sum(diff(:)) == 0, 'buffer after period different from initial buffer');
nSchedule = Schedule;
nSchedule.taskGroup.buffer = nBuffers;
disp(['number of processor: ' num2str(nProcessors)]);
disp(['number of buffer: ' num2str(nBuffers)]);
clear idx jdx nevents event ractor_idx init_buffers max_buffers diff
end







