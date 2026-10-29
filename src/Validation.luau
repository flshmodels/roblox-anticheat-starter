--!strict
local Validation = {}
function Validation.numberInRange(value: any, minimum: number, maximum: number): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
		and value >= minimum and value <= maximum
end
function Validation.shortString(value: any, maxBytes: number): boolean
	return type(value) == "string" and #value > 0 and #value <= maxBytes
end
return Validation
