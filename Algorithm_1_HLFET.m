function nSchedule = Algorithm_1_HLFET
clc
clear
SDFgraph    = SDFgraph_read('scheduling_example1/toy2.xml');
Schedule    = Schedule_read('scheduling_example1/toy2_3_schedule.xml');
nProcessors = 2;

nSchedule.type = 'PaSTA';
nSchedule.xmlns = 'http://peace.snu.ac.kr/CICXMLSchema';
nSchedule.taskGroup.name = 'task';
nSchedule.taskGroup.buffer = 0;
scheduleGroups = [];

%number of buffer
matrix_buffers = gen_init_buffers(SDFgraph);
init_buffers   = matrix_buffers;

%begin of the algorithm
pool = ones(nProcessors, 1);


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




