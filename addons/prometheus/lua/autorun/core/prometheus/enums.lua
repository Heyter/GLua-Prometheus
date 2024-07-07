-- This Script is Part of the Prometheus Obfuscator by Levno_710
--
-- enums.lua
-- This file Provides some enums used by the Obfuscator

local Enums = {};

local chararray = include("util.lua").chararray;

Enums.Conventions = {
	Keywords = {
		"and",    "break",  "do",    "else",     "elseif", "continue",
		"end",    "false",  "for",   "function", "if",   
		"in",     "local",  "nil",   "not",      "or",
		"repeat", "return", "then",  "true",     "until",    "while",
		"||", "&&", "goto"
	},
	
	SymbolChars = chararray("+-*/%^#=~!<>(){}[];:,."),
	MaxSymbolLength = 3,
	Symbols = {
		"+",  "-",  "*",  "/",  "%",  "^",  "#",
		"==", "~=", "!=", "<=", ">=", "<",  ">",  "=",
		"(",  ")",  "{",  "}",  "[",  "]",
		";",  ":", "::",  ",",  ".",  "..", "..."
	},

	IdentChars          = chararray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789&|"),
	NumberChars         = chararray("0123456789"),
	HexNumberChars      = chararray("0123456789abcdefABCDEF"),
	BinaryNumberChars   = {"0", "1"},
	DecimalExponent     = {"e", "E"},
	HexadecimalNums     = {"x", "X"},
	BinaryNums          = {"b", "B"},
	DecimalSeperators   = false,
	
	EscapeSequences     = {
		["a"] = "\a";
		["b"] = "\b";
		["f"] = "\f";
		["n"] = "\n";
		["r"] = "\r";
		["t"] = "\t";
		["v"] = "\v";
		["\\"] = "\\";
		["\""] = "\"";
		["\'"] = "\'";
	},

	NumericalEscapes = true,
	EscapeZIgnoreNextWhitespace = true,
	HexEscapes = true,
	UnicodeEscapes = true,
}

return Enums;
