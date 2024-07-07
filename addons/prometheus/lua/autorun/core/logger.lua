-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- logger.lua

local logger = {}
local config = include("config.lua");

logger.LogLevel = {
	Error = 0,
	Warn = 1,
	Log = 2,
	Info = 2,
	Debug = 3,
}

logger.logLevel = logger.LogLevel.Log;

logger.debugCallback = function(...)
	MsgC(color_white, config.NameUpper .. ": " ..  ...)
	Msg('\n')
end;
function logger:debug(...)
	if self.logLevel >= self.LogLevel.Debug then
		self.debugCallback(...);
	end
end

local green = Color(0,255,0)
logger.logCallback = function(...)
	MsgC(green, config.NameUpper .. ": " .. ...)
	Msg('\n')
end;
function logger:log(...)
	if self.logLevel >= self.LogLevel.Log then
		self.logCallback(...);
	end
end

function logger:info(...)
	if self.logLevel >= self.LogLevel.Log then
		self.logCallback(...);
	end
end

local yellow = Color(255,255,100)

logger.warnCallback = function(...)
	MsgC(yellow, config.NameUpper .. ": " .. ...)
	Msg("\n")
end;
function logger:warn(...)
	if self.logLevel >= self.LogLevel.Warn then
		self.warnCallback(...);
	end
end

local red = Color(240,128,128)

logger.errorCallback = function(...)
	MsgC(red, config.NameUpper .. ": " .. ...)
	Msg("\n")
end;
function logger:error(...)
	self.errorCallback(...);
end


return logger;