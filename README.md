# Mapping and Scheduling Challenge

Input: an SDF graph with the execution time information of actors and a given target architecture   
Output: a parallel schedule of the SDF graph  
Objective: Minimize the resource requirement under a given throughput constraint 
- number of processing elements first
- buffer size next.

## How to run
The main function is  
	Mapping_Schedule_Challenge(inputfile, outputfolder)

There are two parameter:  
- inputfile: the input SDF graph
- outputfolder: which folder the output schedule should be saved.
	if empty. it will be save in the main folder.

Example:  
Mapping_Schedule_Challenge('Example_ETL\toy1.xml')  
Mapping_Schedule_Challenge('Example_ETL\toy1.xml', 'output')  
