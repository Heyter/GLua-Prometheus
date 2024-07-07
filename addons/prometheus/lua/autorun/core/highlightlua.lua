-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- This Script provides a simple Method for Syntax Highlighting of Lua code

local Tokenizer = include("prometheus/tokenizer.lua")
local TokenKind = Tokenizer.TokenKind;
local lookupify = include("prometheus/util.lua").lookupify;

return function(code)
    local out = "";
    local tokenizer = Tokenizer:new({});

    tokenizer:append(code);
    local tokens = tokenizer:scanAll();

    local currentPos = 1;
    for _, token in ipairs(tokens) do
        if token.startPos >= currentPos then
            out = out .. string.sub(code, currentPos, token.startPos);
        end
        if token.kind == TokenKind.Ident then
			out = out .. token.source;
        elseif token.kind == TokenKind.Keyword then
			out = out .. token.source
        elseif token.kind == TokenKind.Symbol then
			out = out .. token.source;
        elseif token.kind == TokenKind.String then
            out = out .. token.source
        elseif token.kind == TokenKind.Number then
            out = out .. token.source
        else
            out = out .. token.source;
        end

        currentPos = token.endPos + 1;
    end
    return out;
end