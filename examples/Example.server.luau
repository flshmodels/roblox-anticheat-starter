-- Example only: implement game-specific authorization before using this action.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = game:GetService("ServerScriptService"):WaitForChild("AntiCheat")
local RateLimiter = require(modules.RateLimiter)
local Validation = require(modules.Validation)
local Guard = require(modules.Guard)
local limiter = RateLimiter.new(5, 2)
local action = ReplicatedStorage:WaitForChild("ExampleAction") :: RemoteEvent
local decoy = ReplicatedStorage:WaitForChild("DecoyRemote") :: RemoteEvent
Guard.watchHoneypot(decoy, {
	action = "log", -- Kick or ban only after testing; ban requires banSeconds.
	onDetection = function(player, reason)
		print(HttpService:JSONEncode({ kind = "anticheat_detection", userId = player.UserId,
			reason = reason, timestamp = os.time() }))
	end,
})
action.OnServerEvent:Connect(function(player, itemId)
	if not limiter:allow(player.UserId) then return end
	if not Validation.shortString(itemId, 40) then return end
	-- Check a server-owned allowlist, permissions, price, and distance here.
	-- This example does not grant anything.
end)
Players.PlayerRemoving:Connect(function(player) limiter:remove(player.UserId) end)
