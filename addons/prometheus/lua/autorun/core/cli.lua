---@diagnostic disable-next-line: different-requires
local Prometheus = include("prometheus.lua");
Prometheus.Logger.logLevel = Prometheus.Logger.LogLevel.Info;

-- Check if the file exists
local function file_exists(f)
    return file.Exists(f, "GAME")
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
local function lines_from(path)
    if not file_exists(path) then return end
	return file.Read(path, 'GAME')
end

-- CLI
local config
local sourceFile
local outFile;
local prettyPrint;

local red = Color(220,20,60)

concommand.Add("prometheus", function(ply, _, arg)
	if #arg == 0 then return end
	sourceFile = nil
	prettyPrint = nil

	-- Parse Arguments
	local i = 1;
	while i <= #arg do
		local curr = arg[i];
		if curr:sub(1, 2) == "--" then
			if curr == "--preset" or curr == "--p" then
				if config then
					Prometheus.Logger:warn("The config was set multiple times")
				end

				i = i + 1;
				local preset = Prometheus.Presets[arg[i]];
				if not preset then
					Prometheus.Logger:error(string.format("A Preset with the name \"%s\" was not found!", tostring(arg[i])));
				end

				config = preset;
			elseif curr == "--config" or curr == "--c" then
				i = i + 1;
				local filename = tostring(arg[i]);
				if not file_exists(filename) then
					Prometheus.Logger:error(string.format("The config file \"%s\" was not found!", filename));
				end

				local content = lines_from(filename)

				if content then
					-- Load Config from File
					local func = RunString(content);
					-- Sandboxing
					setfenv(func, {});
					config = func();
				end
			elseif curr == "--out" or curr == "--o" then
				i = i + 1;
				if(outFile) then
					Prometheus.Logger:warn("The output file was specified multiple times!");
				end
				outFile = arg[i];
			elseif curr == "--pretty" then
				prettyPrint = true;
			elseif curr == "--saveerrors" then
				-- Override error callback
				Prometheus.Logger.errorCallback =  function(...)
					MsgC(red, Prometheus.Config.NameUpper .. ": " .. ...)
					
					local args = {...};
					local message = table.concat(args, " ");

					local fileName = sourceFile:sub(-4) == ".lua" and sourceFile:sub(0, -5) .. ".error.txt" or sourceFile .. ".error.txt";
					file.Write(fileName, message)
				end
			else
				Prometheus.Logger:warn(string.format("The option \"%s\" is not valid and therefore ignored", curr));
			end
		else
			if sourceFile then
				Prometheus.Logger:error(string.format("Unexpected argument \"%s\"", arg[i]));
			end
			sourceFile = tostring(arg[i]);
		end
		i = i + 1;
	end

	if not sourceFile then
		Prometheus.Logger:error("No input file was specified!")
	end

	if not config then
		Prometheus.Logger:warn("No config was specified, falling back to Minify preset");
		config = Prometheus.Presets.Minify
	end

	-- Add Option to override Lua Version
	config.PrettyPrint = prettyPrint ~= nil and prettyPrint or config.PrettyPrint

	if not file_exists(sourceFile) then
		Prometheus.Logger:error(string.format("The File \"%s\" was not found!", sourceFile))
		return
	end

	if not outFile then
		if sourceFile:sub(-4) == ".lua" then
			outFile = sourceFile:sub(0, -5) .. ".obfuscated.txt";
		else
			outFile = sourceFile .. ".obfuscated.txt";
		end
	end

	local source = lines_from(sourceFile)

	if source then
		local pipeline = Prometheus.Pipeline:fromConfig(config);
		local out = pipeline:apply(source, sourceFile);
		Prometheus.Logger:info(string.format("Writing output to \"%s\"", outFile));

		-- Write Output
		file.CreateDir('prometheus/' .. string.GetPathFromFilename( outFile ))
		file.Write('prometheus/' .. outFile, out)
	end
end)
