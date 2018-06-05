function Schedule = Schedule_read (infile)
addpath('ultilities/');
DOMnode     = xmlread(infile);
theStruct   = xml2struct(DOMnode);

Schedule.type       = theStruct.CIC_Schedule.Attributes.type;
Schedule.xmlns      = theStruct.CIC_Schedule.Attributes.xmlns;
taskGroup.name      = theStruct.CIC_Schedule.taskGroups.taskGroup.Attributes.name;
taskGroup.buffer    = str2num(theStruct.CIC_Schedule.taskGroups.taskGroup.Attributes.buffer);
clear infile DOMnode

%read schedule groups
groups      = theStruct.CIC_Schedule.taskGroups.taskGroup.scheduleGroup;
ngroups     = length(groups);
allgroups   = [];
for idx     = 1:ngroups
    group                   = groups{idx};
    nelement                = length(group.scheduleElement);
    allelements             = [];
    for jdx = 1:nelement
        if nelement == 1
            element         = group.scheduleElement;
        else
            element         = group.scheduleElement{jdx};
        end
        melement.name       = element.task.Attributes.name;
        melement.repetition = element.task.Attributes.repetition;
        melement.startTime  = element.task.Attributes.startTime;
        melement.endTime    = element.task.Attributes.endTime;
        allelements         = [allelements melement];
    end
    mgroup.localId          = group.Attributes.localId;
    mgroup.name             = group.Attributes.name;
    mgroup.poolName         = group.Attributes.poolName;
    mgroup.scheduleType     = group.Attributes.scheduleType;
    mgroup.tasks            = allelements;
    allgroups = [allgroups mgroup];
end
taskGroup.scheduleGroups    = allgroups;
Schedule.taskGroup          = taskGroup;
clear nelement allelements melement mgroup group idx jdx element groups allgroups ngroups taskGroup theStruct
end
