function nSchedule = Algorithm_2_DLS(SDFgraph)
%number of buffer
matrix_buffers = gen_init_buffers(SDFgraph);

%occurence of each actor
actor_occ   = cal_occurrence_of_actors(SDFgraph);

for nProcessors = 1:1000
    numIter = floor(30*sqrt(nProcessors));
    [nSchedule, ~] = Algorithm_2_DLS_multi(SDFgraph, nProcessors, numIter, matrix_buffers, actor_occ);
    if(~strcmp(nSchedule.type, 'unset'))
        break;
    end
end
end

function [nSchedule, maxBuff]= Algorithm_2_DLS_multi(SDFgraph, nProcessors, numIter, matrix_buffers, actor_occ)
    nSchedule.type = 'unset';
    maxBuff        = 10^6;
    nValid         = 0;
    for iter = 1:numIter
        Schedule   = Algorithm_2_DLS_impl(SDFgraph, nProcessors, matrix_buffers, actor_occ);
        [Schedule, constraint_OK, nProc, nBuff]   = Schedule_evaluate(SDFgraph, Schedule, 0);
        if (constraint_OK==1 && nProc==nProcessors)
            nValid = nValid + 1;
            if( nBuff < maxBuff)
                maxBuff = nBuff;
                nSchedule = Schedule;
            end
        end
    end
    disp(['num. of processors: ' num2str(nProcessors) '. Valid rate: ' num2str(double(nValid)/double(numIter))]);
end

function nSchedule = Algorithm_2_DLS_impl(SDFgraph, nProcessors, matrix_buffers, actor_occ)
    nSchedule.type = 'PaSTA';
    nSchedule.xmlns = 'http://peace.snu.ac.kr/CICXMLSchema';
    nSchedule.taskGroup.name = 'task';
    nSchedule.taskGroup.buffer = 0;
    scheduleGroups = [];

    %begin of the algorithm
    max_buffers = matrix_buffers;
    p_start     = -1* ones(nProcessors, 1); %store next starting time
    pool        = zeros(nProcessors, 1); %store next available time
    events      = table;
    nevent.type = "start";
    nevent.time = 0;
    nevent.actor= 0;
    events      = [events; struct2table(nevent)];

    while(sum(actor_occ(:))>0 || size(events,1)>0)
        events = sortrows(events,'time');
        event   = events(1,:);
        if(event.type == "start")
            runable_actor = shuffle(runable_actors(SDFgraph, matrix_buffers, actor_occ));
            avail_procs   = procs_priority(p_start, pool, shuffle(available_procs(pool, event.time)));
            for idx=1:length(avail_procs)
                if(idx <= length(runable_actor))
                    %add to scheduleGroups, change pool available time, change
                    %matrix_buffers, add new event to event pool, reduce actor
                    %occurence
                    rproc      = avail_procs(idx);
                    ractor_idx = runable_actor(idx);
                    mActor = SDFgraph.actors(ractor_idx);
                    scheduleGroups = add_task_to_schedule(scheduleGroups, rproc, mActor, event.time);
                    pool(rproc) = event.time + mActor.execTime;
                    if(p_start(rproc) == -1)
                        p_start(rproc) =  event.time;
                    end
                    actor_occ(ractor_idx) = actor_occ(ractor_idx) - 1;
                    for jdx = 1:size(SDFgraph.channels,1)
                       if(~isempty(SDFgraph.channels{jdx, ractor_idx}))
                           matrix_buffers(jdx, ractor_idx) = matrix_buffers(jdx, ractor_idx) - SDFgraph.channels{jdx, ractor_idx}.rate_out;
                       end
                    end
                    nevent.type = "finish";
                    nevent.time = pool(rproc);
                    nevent.actor= ractor_idx;
                    events      = [events; struct2table(nevent)];
                end
            end
        else
            %matrix_buffers, add new event to event pool
            ractor_idx = event.actor;
            for rdx = 1:size(SDFgraph.channels,2)
                if(~isempty(SDFgraph.channels{ractor_idx, rdx}))
                   matrix_buffers(ractor_idx, rdx) = matrix_buffers(ractor_idx, rdx) + SDFgraph.channels{ractor_idx, rdx}.rate_in;
                   if (matrix_buffers(ractor_idx, rdx) > max_buffers(ractor_idx, rdx))
                       max_buffers(ractor_idx, rdx) = matrix_buffers(ractor_idx, rdx);
                   end
                end
            end
            nevent.type = "start";
            nevent.time = event.time;
            nevent.actor= 0;
            events      = [events; struct2table(nevent)];
        end
        events      = events(2:end,:);
    end

    nSchedule.taskGroup.scheduleGroups = scheduleGroups;
end

function result = procs_priority(p_start, pool, actors)
    criteria = pool(actors) - p_start(actors);
    [~,I]    = sort(criteria);
    result   = actors(I);
end

function matrix_buffers = gen_init_buffers(SDFgraph)
    matrix_buffers  = zeros(size(SDFgraph.channels));
    for idx = 1:size(matrix_buffers,1)
        for jdx = 1:size(matrix_buffers,2)
            if(~isempty(SDFgraph.channels{idx,jdx}))
                matrix_buffers(idx, jdx) = SDFgraph.channels{idx,jdx}.initialTokens;
            end
        end  
    end
end

function runable_actor = runable_actors(SDFgraph, matrix_buffers, actor_occ)
    runable_actor = [];
    for ractor_idx = 1:size(SDFgraph.channels,2)
        buffer_col = matrix_buffers(:, ractor_idx);
        valid = 1;
        for jdx = 1:size(SDFgraph.channels,1)
           if(~isempty(SDFgraph.channels{jdx, ractor_idx}))
               buffer_col(jdx) = buffer_col(jdx) - SDFgraph.channels{jdx, ractor_idx}.rate_out;
                if (buffer_col(jdx) < 0)
                    valid = 0;
                end
           end
        end
        if (valid && (actor_occ(ractor_idx) > 0))
            runable_actor = [runable_actor; ractor_idx];
        end
    end
end

function actor_occ = cal_occurrence_of_actors(SDFgraph)
    actor_occ = ones(length(SDFgraph.actors), 1);
    unconverged = 1;
    while (unconverged)
       unconverged = 0;
       for idx = 1:size(SDFgraph.channels,1)
            for jdx = 1:size(SDFgraph.channels,2)
                if(~isempty(SDFgraph.channels{idx,jdx}))
                    s1 = lcm(actor_occ(idx), actor_occ(jdx));
                    s2 = lcm(SDFgraph.channels{idx,jdx}.rate_in, SDFgraph.channels{idx,jdx}.rate_out);
                    ss = lcm(s1,s2);
                    if(actor_occ(idx) ~= ss/SDFgraph.channels{idx,jdx}.rate_in)
                        actor_occ(idx) = ss/SDFgraph.channels{idx,jdx}.rate_in;
                        unconverged    = 1;
                    end
                    if(actor_occ(jdx) ~= ss/SDFgraph.channels{idx,jdx}.rate_out)
                        actor_occ(jdx) = ss/SDFgraph.channels{idx,jdx}.rate_out;
                        unconverged    = 1;
                    end
                end
            end
       end
    end
end

function procs = available_procs(pool, time)
    procs = find(time >= pool);
end

function scheduleGroups = add_task_to_schedule(scheduleGroups, proc_id, mActor, time)
    proc_idx = 0;
    for idx=1:length(scheduleGroups)
        schedule = scheduleGroups(:,idx);
        if (schedule.localId == proc_id -1)
            proc_idx = idx;
            break;
        end
    end
    clear idx schedule
    
    if(proc_idx == 0)
        schedule.localId = proc_id -1;
        schedule.name = 'sg0';
        schedule.poolName = 'p1';
        schedule.scheduleType = 'static';
        schedule.tasks = [];
        scheduleGroups = [scheduleGroups schedule];
        proc_idx = length(scheduleGroups);
    end
    
    task.name = mActor.name;
    task.repetition = 1;
    task.startTime = time;
    task.endTime   = time + mActor.execTime;
    scheduleGroups(proc_idx).tasks = [scheduleGroups(proc_idx).tasks task];
end
