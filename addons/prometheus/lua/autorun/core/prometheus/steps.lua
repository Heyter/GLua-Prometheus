return {
	WrapInFunction       = include("steps/WrapInFunction.lua");
	SplitStrings         = include("steps/SplitStrings.lua");
	Vmify                = include("steps/Vmify.lua");
	ConstantArray        = include("steps/ConstantArray.lua");
	ProxifyLocals  			 = include("steps/ProxifyLocals.lua");
	AntiTamper  				 = include("steps/AntiTamper.lua");
	EncryptStrings 			 = include("steps/EncryptStrings.lua");
	NumbersToExpressions = include("steps/NumbersToExpressions.lua");
	AddVararg 					 = include("steps/AddVararg.lua");
	WatermarkCheck		   = include("steps/WatermarkCheck.lua");
}