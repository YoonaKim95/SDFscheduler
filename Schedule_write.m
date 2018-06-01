clc
SDFgraph = SDFgraph_read('scheduling_example1/toy1.xml');
Schedule = Schedule_read('scheduling_example1/toy1_4_schedule.xml');

outpath = [SDFgraph.filepath '/' SDFgraph.filename '_schedule.xml'];

docNode = com.mathworks.xml.XMLUtils.createDocument('CIC_Schedule');
CIC_Schedule = docNode.getDocumentElement;
CIC_Schedule.setAttribute('type',Schedule.type);

mTaskGroups = docNode.createElement('taskGroups');
mTaskGroup = docNode.createElement('taskGroup');

mTaskGroup.setAttribute('name', Schedule.taskGroup.name);
mTaskGroup.setAttribute('buffer', Schedule.taskGroup.buffer);



mTaskGroups.appendChild(mTaskGroup);
CIC_Schedule.appendChild(mTaskGroups);
xmlwrite(outpath,docNode);
type(outpath)
