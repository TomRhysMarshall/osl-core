function D = osl_resample_meeg(D,input_nii,output_nii,weighting)
	% Take in a MEEG object, a NIFTI file specifying the voxels for the MEEG channels
	% and an output NII. A new online montage will be computed where the 
	% weight of each output voxel is a linear combination of the input voxels, weighted by
	% a function of distance (default - 1/d)
	%
	% INPUTS
	% D - MEEG object in source space
	% input_nii - NIFTI file with as many nonzero voxels as channels in D
	% output_nii - NIFTI file with new voxel locations
	% weighting - Function handle to convert distance to weight (default - 1/d)
	%
	% Romesh Abeysuriya 2017
	
	if nargin < 4 || isempty(weighting) 
		weighting = @(d) 1./d;
	end

	fprintf(2,'Output has not been validated yet\n')

	our_coordinates = osl_mnimask2mnicoords(input_nii);
	ft_coordinates = osl_mnimask2mnicoords(output_nii);

	for j = 1:size(our_coordinates,1)
		a = our_coordinates(j,:);
		dx = bsxfun(@minus,ft_coordinates,a);
		d = sqrt(sum(dx.^2,2));
		w(:,j) = weighting(d);
	end

	w = bsxfun(@rdivide,w,sum(w));
	D = add_montage(D,w',sprintf('Converted %s to %s',input_nii,output_nii))


	