function Runs=findRuns(project)

	Runs=table;
	for i=1:length(project.solidsRuns.labels)
		Runs.runType(i)={'NONE'};
		Runs.Number(i)=project.solidsRuns.numbers(i);
		Runs.Label(i)=project.solidsRuns.labels(i);
	end
	for j=1:length(project.EmBZRuns.labels)
		Runs.runType(i+j)={'EmBZ'};
		Runs.Number(i+j)=project.EmBZRuns.numbers(j);
		Runs.Label(i+j)=project.EmBZRuns.labels(j);
	end
	for k=1:length(project.TFBZRuns.labels)
		Runs.runType(i+j+k)={'TFBZ'};
		Runs.Number(i+j+k)=project.TFBZRuns.numbers(k);
		Runs.Label(i+j+k)=project.TFBZRuns.labels(k);
	end
	Runs=sortrows(Runs);
end
