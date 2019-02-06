classdef Audit
	methods(Access = public, Static)
		function result = UnitTests()
			runner = matlab.unittest.TestRunner.withTextOutput;
			suite = matlab.unittest.TestSuite.fromPackage(...
				'Test','IncludingSubpackages',true);
			result = runner.run(suite);
		end
		function result = ComparisonTests()
			runner = matlab.unittest.TestRunner.withTextOutput;
			suite = matlab.unittest.TestSuite.fromPackage(...
				'Comparison','IncludingSubpackages',true);
			result = runner.runInParallel(suite);
		end
		function result = RunPerformanceTests()
			result = runperf('Performance', 'IncludingSubpackages', true);
			fullTable = vertcat(result.Samples);
			varfun(@mean,fullTable,...
				'InputVariables','MeasuredTime','GroupingVariables','Name')
		end
		function result = GetCodeCoverage()
			suite = matlab.unittest.TestSuite.fromPackage(...
				'Test', 'IncludingSubpackages', true);
			runner = matlab.unittest.TestRunner.withTextOutput;
			runner.addPlugin(...
				matlab.unittest.plugins.CodeCoveragePlugin.forPackage('Source',...
				'IncludingSubpackages', true));
			result = runner.run(suite);
		end
		function PrintResult(result)
			resultTable = table(result);
			sortrows(resultTable,{'Passed','Duration'},{'descend','ascend'})
			External.cprintf.cprintf('*green', 'pass');
			fprintf('/');
			External.cprintf.cprintf('*red', 'fail');
			fprintf('\\total ');
			External.cprintf.cprintf('*green', num2str(sum(resultTable.Passed)));
			fprintf('/');
			External.cprintf.cprintf('*red', num2str(sum(resultTable.Failed)));
			fprintf('\\%i\n', size(resultTable,1));
		end
	end
end
