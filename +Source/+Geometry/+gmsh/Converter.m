classdef Converter
	properties(Constant)
		ERROR_CODE_PREFIX = 'Source:Geometry:gmsh:Converter:'
		CLASS_NAME = 'Source.Geometry.gmsh.Converter'
	end
	
	methods(Static)
		function MSHToSurface(mshPath, outPath, media)
			Source.Helper.Assert.IsOfType(media,...
				Source.Physics.Media.CLASS_NAME, 'media');
			gmshReaderOptions = Source.Geometry.gmsh.GMSHReaderOptions.New(...
			Source.Physics.OutsideBoundaries...
				.MARKOIL_HAS_NO_OUTSIDE_BOUNDARIES_FN);
			logger = Source.Logging.Logger.Default();
			gmshReader = Source.Geometry.gmsh.GMSHReader.New(mshPath, logger,...
				gmshReaderOptions);
			logger.Log(sprintf('Reading mesh from: "%s".', mshPath));
			gmshReader.Read();
			[meshes, ~] = gmshReader.ExportMeshes(media);
			topo = Source.Geometry.Topology.New();
			topo.Meshes = meshes;
			logger.Log(sprintf('Writing to file: "%s".', outPath));
			Source.IO.JSON.Write(...
				Source.Helper.StructParser.RemoveEmptyFields(topo.ToDTO()),...
				outPath);
		end
	end
end

