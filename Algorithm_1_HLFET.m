function nSchedule = Algorithm_1_HLFET
clc
clear
%SDFgraph    = SDFgraph_read('scheduling_example1/toy1.xml');
%Schedule    = Schedule_read('scheduling_example1/toy1_4_schedule.xml');
%SDFgraph    = SDFgraph_read('scheduling_example1/toy2.xml');
%Schedule    = Schedule_read('scheduling_example1/toy2_3_schedule.xml');
SDFgraph    = SDFgraph_read('scheduling_example2/toy_cap.xml');
%Schedule    = Schedule_read('scheduling_example2/task_default_2_schedule.xml');
%Schedule    = Schedule_read('scheduling_example2/task_default_3_schedule.xml');
nProcessors = 2;

nSchedule.type = 'PaSTA';
nSchedule.xmlns = 'http://peace.snu.ac.kr/CICXMLSchema';
nSchedule.taskGroup.name = 'task';
nSchedule.taskGroup.buffer = 0;
scheduleGroups = [];

%number of buffer
matrix_buffers = gen_init_buffers(SDFgraph);
init_buffers   = matrix_buffers;

%occurence of each actor
actor_occ = cal_occurrence_of_actors(SDFgraph);

%begin of the algorithm
pool = ones(nProcessors, 1);
runable_actor = list_runable_actors(SDFgraph, matrix_buffers);

nSchedule.taskGroup.scheduleGroups = scheduleGroups;
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

function runable_actor = list_runable_actors(SDFgraph, matrix_buffers)
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
        if valid
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
                        actor_occ(jdx) = ss/SDFgraph.channels{idx,jdx}.rate_in;
                        unconverged    = 1;
                    end
                    if(actor_occ(jdx) ~= ss/SDFgraph.channels{idx,jdx}.rate_out)
                        actor_occ(jdx) = ss/SDFgraph.channels{idx,jdx}.rate_out;
                        unconverged    = 1;
                    end
                end
            end
       end
    end %end while
end


