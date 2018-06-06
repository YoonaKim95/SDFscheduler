function Schedule_write(SDFgraph, Schedule, filepath)
outpath = fullfile(filepath, [SDFgraph.filename '_' num2str(length(Schedule.taskGroup.scheduleGroups)) '_schedule.xml']);

docNode = com.mathworks.xml.XMLUtils.createDocument('CIC_Schedule');
CIC_Schedule = docNode.getDocumentElement;
CIC_Schedule.setAttribute('xmlns',Schedule.xmlns);
CIC_Schedule.setAttribute('type',Schedule.type);

mTaskGroups = docNode.createElement('taskGroups');
mTaskGroup = docNode.createElement('taskGroup');

mTaskGroup.setAttribute('name', Schedule.taskGroup.name);
mTaskGroup.setAttribute('buffer', num2str(Schedule.taskGroup.buffer));

nschel = length(Schedule.taskGroup.scheduleGroups);
for idx = 1:nschel
    scheduleGroup   = Schedule.taskGroup.scheduleGroups(idx);
    mscheduleGroup  = docNode.createElement('scheduleGroup');
    mscheduleGroup.setAttribute('scheduleType', scheduleGroup.scheduleType);
    mscheduleGroup.setAttribute('poolName', scheduleGroup.poolName);
    mscheduleGroup.setAttribute('name', scheduleGroup.name);
    mscheduleGroup.setAttribute('localId', num2str(idx-1));
    
    scheduleGroup.tasks = refactor_task(scheduleGroup.tasks);
    ntask = length(scheduleGroup.tasks);
    for jdx = 1:ntask
        task  = scheduleGroup.tasks(jdx);
        mScheduleElement = docNode.createElement('scheduleElement');
        mTask = docNode.createElement('task');
        mTask.setAttribute('startTime', num2str(task.startTime));
        mTask.setAttribute('repetition', num2str(task.repetition));
        mTask.setAttribute('name', task.name);
        mTask.setAttribute('endTime', num2str(task.endTime));
        mScheduleElement.appendChild(mTask);
        mscheduleGroup.appendChild(mScheduleElement);
    end
    mTaskGroup.appendChild(mscheduleGroup);
end

mTaskGroups.appendChild(mTaskGroup);
CIC_Schedule.appendChild(mTaskGroups);
xmlwrite(outpath,docNode);
end

function ntasks = refactor_task(tasks)
    ntasks = [];
	num_tasks = length(tasks);
    for jdx = 1:num_tasks
        task  = tasks(jdx);
        if(~isempty(ntasks))
            ntask = ntasks(end);
            if(strcmp(task.name,ntask.name) && (task.startTime == ntask.endTime))
                ntasks(end).repetition = ntasks(end).repetition + 1;
                ntasks(end).endTime    = task.endTime;
            else
                ntasks = [ntasks task];
            end
        else
            ntasks = [ntasks task];
        end
    end
end