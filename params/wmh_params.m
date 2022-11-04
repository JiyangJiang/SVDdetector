global params

params.wmh.success.pairedT1Flair = cell (params.global.numbers.pairedT1Flair, 2);
params.wmh.success.t1ButNotFlair = cell (params.global.numbers.t1ButNotFlair, 2);
params.wmh.success.flairButNotT1 = cell (params.global.numbers.flairButNotT1, 2);

for i = 1 : params.global.numbers.pairedT1Flair
	params.wmh.success.pairedT1Flair{i,1} = params.global.subjID.pairedT1Flair {i,1};
end
for i = 1 : params.global.numbers.t1ButNotFlair
	params.wmh.success.t1ButNotFlair{i,1} = params.global.subjID.t1ButNotFlair {i,1};
end
for i = 1 : params.global.numbers.flairButNotT1
	params.wmh.success.flairButNotT1{i,1} = params.global.subjID.flairButNotT1 {i,1};
end