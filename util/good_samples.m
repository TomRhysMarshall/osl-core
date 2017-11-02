function res = good_samples(D,chanind, sampind, trialind)
	% This is a convenience function equivalent to
	%
	% ~any(D.badsamples(chanind, sampind, trialind))
	%
	% i.e. the outputs should match exactly. Behaviours do differ
	% slightly though if bad channels are included in 
	% chanind because they are ignored by D function. Similarly,
	% bad channel types are excluded when finding good samples. Basically
	% D function should do what you expect if you are not using the
	% data from bad channels.
	%
	% However, as a modified copy of badsamples(), it is faster
	% because it aggregates over all channels
	%
	% Romesh Abeysuriya 2017

	if nargin < 4 || isempty(trialind) 
		trialind = ':';
	end

	if nargin < 3 || isempty(sampind) 
		sampind = ':';
	end

	if nargin < 2 || isempty(chanind) 
		chanind = indchantype(D,'ALL','GOOD'); % By default, check all good channels
	end

	if ischar(sampind) && isequal(sampind, ':')
	    sampind = 1:nsamples(D);
	end

	if ischar(trialind) && isequal(trialind, ':')
	    trialind = 1:ntrials(D);
	end
	

	res = true(1, nsamples(D), length(trialind));
	chantypes = unique(D.chantype(chanind)); % Channel types to check

	% If online montage, we also need to check the constituent channels
	if D.montage('getindex') > 0 
		m = D.montage('getmontage');
		Dtemp = D.montage('switch',0);
		chantypes = union(chantypes,unique(Dtemp.chantype(find(any(m.tra,1)))));
	end

	for i = 1:length(trialind)

		% Retrieve all events associated with D trial
	    ev = events(D, trialind(i), 'samples');
	    if iscell(ev)
	        ev = ev{1};
	    end

	    ev = ev(cellfun(@(x) strmatch('artefact',x),{ev.type}) & ismember({ev.value},chantypes)); % These are all the artefact events that apply to the channel types we are inspecting

	    if ~isempty(ev)
	        for k = 1:numel(ev)
	            res(1, ev(k).sample+(0:(ev(k).duration-1)), i) = false;
	        end
	    end
	end

	res = res(:, sampind, :);
	res(:, :, badtrials(D, trialind))  = false;



