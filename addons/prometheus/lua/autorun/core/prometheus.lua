-- Math.random Fix for Lua5.1
-- Check if fix is needed
if not pcall(function()
    return math.random(1, 2^40);
end) then
    local oldMathRandom = math.random;
    math.random = function(a, b)
        if not a and b then
            return oldMathRandom();
        end
        if not b then
            return math.random(1, a);
        end
        if a > b then
            a, b = b, a;
        end
        local diff = b - a;
        assert(diff >= 0);
        if diff > 2 ^ 31 - 1 then
            return math.floor(oldMathRandom() * diff + a);
        else
            return oldMathRandom(a, b);
        end
    end
end

-- newproxy polyfill
_G.newproxy = _G.newproxy or function(arg)
    if arg then
        return setmetatable({}, {});
    end
    return {};
end


-- Require Prometheus Submodules
local Pipeline  = include("prometheus/pipeline.lua");
local highlight = include("highlightlua.lua");
local Logger    = include("logger.lua");
local Presets   = include("presets.lua");
local Config    = include("config.lua")
local util      = include("prometheus/util.lua")

-- Export
return {
    Pipeline  = Pipeline;
    Config    = util.readonly(Config); -- Readonly
    Logger    = Logger;
    highlight = highlight;
    Presets   = Presets;
}

