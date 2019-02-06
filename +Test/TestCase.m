classdef TestCase
	methods(Access = public, Static)
		function AssertBetween(testCase, value, lowerLimit,...
				upperLimit, lowerLimitMessage, upperLimitMessage)
			if(~exist('upperLimitMessage','var'))
				upperLimitMessage = lowerLimitMessage;
			end
			testCase.assertGreaterThan(value, lowerLimit,...
				lowerLimitMessage);
			testCase.assertLessThan(value, upperLimit,...
				upperLimitMessage);
		end
		function VerifyBetween(testCase, value, lowerLimit,...
				upperLimit, lowerLimitMessage, upperLimitMessage)
			if(~exist('upperLimitMessage','var'))
				upperLimitMessage = lowerLimitMessage;
			end
			testCase.verifyGreaterThan(value, lowerLimit,...
				lowerLimitMessage);
			testCase.verifyLessThan(value, upperLimit,...
				upperLimitMessage);
		end
	end
end
