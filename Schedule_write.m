function Schedule_write(SDFgraph, Schedule, filepath)
outpath = [filepath '/' SDFgraph.filename '_' length(Schedule.taskGroup.scheduleGroups) '_schedule.xml'];

docNode = com.mathworks.xml.XMLUtils.createDocument('CIC_Schedule');
CIC_Schedule = docNode.getDocumentElement;
CIC_Schedule.setAttribute('xmlns',Schedule.xmlns);
CIC_Schedule.setAttribute('type',Schedule.type);

mTaskGroups = docNode.createElement('taskGroups');
mTaskGroup = docNode.createElement('taskGroup');

mTaskGroup.setAttribute('name', Schedule.taskGroup.name);
mTaskGroup.setAttribute('buffer', Schedule.taskGroup.buffer);

nschel = length(Schedule.taskGroup.scheduleGroups);
for idx = 1:nschel
    scheduleGroup   = Schedule.taskGroup.scheduleGroups(idx);
    mscheduleGroup  = docNode.createElement('scheduleGroup');
    mscheduleGroup.setAttribute('scheduleType', scheduleGroup.scheduleType);
    mscheduleGroup.setAttribute('poolName', scheduleGroup.poolName);
    mscheduleGroup.setAttribute('name', scheduleGroup.name);
    mscheduleGroup.setAttribute('localId', scheduleGroup.localId);
    
    ntask = length(scheduleGroup.tasks);
    for jdx = 1:ntask
        task  = scheduleGroup.tasks(jdx);
        mScheduleElement = docNode.createElement('scheduleElement');
        mTask = docNode.createElement('task');
        mTask.setAttribute('startTime', task.startTime);
        mTask.setAttribute('repetition', task.repetition);
        mTask.setAttribute('name', task.name);
        mTask.setAttribute('endTime', task.endTime);
        mScheduleElement.appendChild(mTask);
        mscheduleGroup.appendChild(mScheduleElement);
    end
    mTaskGroup.appendChild(mscheduleGroup);
end

mTaskGroups.appendChild(mTaskGroup);
CIC_Schedule.appendChild(mTaskGroups);
xmlwrite(outpath,docNode);
end