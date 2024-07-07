-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- pipeline.lua
--
-- This Script Provides a Configurable Obfuscation Pipeline that can obfuscate code using different Modules
-- These Modules can simply be added to the pipeline

local config = include("../config.lua");
local Ast    = include("ast.lua");
local Enums  = include("enums.lua");
local util = include("util.lua");
local Parser = include("parser.lua");
local Unparser = include("unparser.lua");
local logger = include("../logger.lua")

local NameGenerators = include("namegenerators.lua")

local Steps = include("steps.lua")

local lookupify = util.lookupify;
local AstKind = Ast.AstKind;

local Pipeline = {
	NameGenerators = NameGenerators;
	Steps = Steps;
	DefaultSettings = {
		PrettyPrint = false; -- Note that Pretty Print is currently not producing Pretty results
		Seed = 0; -- The Seed. 0 or below uses the current time as a seed
		VarNamePrefix = ""; -- The Prefix that every variable will start with
	}
}


function Pipeline:new(settings)
	local conventions = Enums.Conventions
	
	local prettyPrint = settings.PrettyPrint or Pipeline.DefaultSettings.PrettyPrint;
	local prefix = settings.VarNamePrefix or Pipeline.DefaultSettings.VarNamePrefix;
	local seed = settings.Seed or 0;
	
	local pipeline = {
		PrettyPrint = prettyPrint;
		VarNamePrefix = prefix;
		Seed = seed;
		parser = Parser:new({});
		unparser = Unparser:new({
			PrettyPrint = prettyPrint;
			Highlight = settings.Highlight;
		});
		namegenerator = Pipeline.NameGenerators.MangledShuffled;
		conventions = conventions;
		steps = {};
	}
	
	setmetatable(pipeline, self);
	self.__index = self;
	
	return pipeline;
end

function Pipeline:fromConfig(config)
	config = config or {};
	local pipeline = Pipeline:new({
		PrettyPrint   = config.PrettyPrint or false;
		VarNamePrefix = config.VarNamePrefix or "";
		Seed          = config.Seed or 0;
	});

	pipeline:setNameGenerator(config.NameGenerator or "MangledShuffled")

	-- Add all Steps defined in Config
	local steps = config.Steps or {};
	for i, step in ipairs(steps) do
		if type(step.Name) ~= "string" then
			logger:error("Step.Name must be a String");
		end
		local constructor = pipeline.Steps[step.Name];
		if not constructor then
			logger:error(string.format("The Step \"%s\" was not found!", step.Name));
		end
		pipeline:addStep(constructor:new(step.Settings or {}));
	end

	return pipeline;
end

function Pipeline:addStep(step)
	table.insert(self.steps, step);
end

function Pipeline:resetSteps(step)
	self.steps = {};
end

function Pipeline:getSteps()
	return self.steps;
end

function Pipeline:setOption(name, value)
	assert(false, "TODO");
	if(Pipeline.DefaultSettings[name] ~= nil) then
		
	else
		logger:error(string.format("\"%s\" is not a valid setting"));
	end
end

function Pipeline:setLuaVersion()
	self.parser = Parser:new({});
	self.unparser = Unparser:new({});
	self.conventions = Enums.Conventions;
end

function Pipeline:setNameGenerator(nameGenerator)
	if(type(nameGenerator) == "string") then
		nameGenerator = Pipeline.NameGenerators[nameGenerator];
	end
	
	if(type(nameGenerator) == "function" or type(nameGenerator) == "table") then
		self.namegenerator = nameGenerator;
		return;
	else
		logger:error("The Argument to Pipeline:setNameGenerator must be a valid NameGenerator function or function name e.g: \"mangled\"")
	end
end

function Pipeline:apply(code, filename)
	local startTime = SysTime()
	filename = filename or "Anonymus Script";
	logger:info(string.format("Applying Obfuscation Pipeline to %s ...", filename));
	-- Seed the Random Generator
	if(self.Seed > 0) then
		math.randomseed(self.Seed);
	else
		math.randomseed(os.time())
	end
	
	logger:info("Parsing ...");
	local parserStartTime = SysTime()

	local sourceLen = string.len(code);
	local ast = self.parser:parse(code);

	local parserTimeDiff = SysTime() - parserStartTime;
	logger:info(string.format("Parsing Done in %.2f seconds", parserTimeDiff));
	
	-- User Defined Steps
	for i, step in ipairs(self.steps) do
		local stepStartTime = SysTime()
		logger:info(string.format("Applying Step \"%s\" ...", step.Name or "Unnamed"));
		local newAst = step:apply(ast, self);
		if type(newAst) == "table" then
			ast = newAst;
		end
		logger:info(string.format("Step \"%s\" Done in %.2f seconds", step.Name or "Unnamed", SysTime() - stepStartTime));
	end
	
	-- Rename Variables Step
	self:renameVariables(ast);
	
	code = self:unparse(ast);
	
	local timeDiff = SysTime() - startTime;
	logger:info(string.format("Obfuscation Done in %.2f seconds", timeDiff));
	
	logger:info(string.format("Generated Code size is %.2f%% of the Source Code size", (string.len(code) / sourceLen)*100))
	
	return code;
end

function Pipeline:unparse(ast)
	local startTime = SysTime()
	logger:info("Generating Code ...");
	
	local unparsed = self.unparser:unparse(ast);
	
	local timeDiff = SysTime() - startTime;
	logger:info(string.format("Code Generation Done in %.2f seconds", timeDiff));
	
	return unparsed;
end

function Pipeline:renameVariables(ast)
	local startTime = SysTime()
	logger:info("Renaming Variables ...");

	local generatorFunction = self.namegenerator or Pipeline.NameGenerators.mangled;
	if(type(generatorFunction) == "table") then
		if (type(generatorFunction.prepare) == "function") then
			generatorFunction.prepare(ast);
		end
		generatorFunction = generatorFunction.generateName;
	end
	
	if not self.unparser:isValidIdentifier(self.VarNamePrefix) and #self.VarNamePrefix ~= 0 then
		logger:error(string.format("The Prefix \"%s\" is not a valid Identifier", self.VarNamePrefix));
	end

	local globalScope = ast.globalScope;
	globalScope:renameVariables({
		Keywords = self.conventions.Keywords;
		generateName = generatorFunction;
		prefix = self.VarNamePrefix;
	});
	
	local timeDiff = SysTime() - startTime;
	logger:info(string.format("Renaming Done in %.2f seconds", timeDiff));
end




return Pipeline;
