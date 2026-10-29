--!strict
local RateLimiter = {}
RateLimiter.__index = RateLimiter
local function finite(n: any): boolean
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
function RateLimiter.new(capacity: number, refillPerSecond: number, clock: (() -> number)?)
	assert(finite(capacity) and capacity >= 1, "capacity must be finite and at least 1")
	assert(finite(refillPerSecond) and refillPerSecond > 0, "refill rate must be positive and finite")
	return setmetatable({ capacity = capacity, refill = refillPerSecond, clock = clock or os.clock, buckets = {} }, RateLimiter)
end
function RateLimiter:allow(userId: number): boolean
	local now = self.clock()
	local bucket = self.buckets[userId]
	if not bucket then
		bucket = { tokens = self.capacity, time = now }
		self.buckets[userId] = bucket
	end
	bucket.tokens = math.min(self.capacity, bucket.tokens + math.max(0, now - bucket.time) * self.refill)
	bucket.time = math.max(bucket.time, now)
	if bucket.tokens < 1 then return false end
	bucket.tokens -= 1
	return true
end
function RateLimiter:remove(userId: number)
	self.buckets[userId] = nil
end
return RateLimiter
