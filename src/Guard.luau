--!strict
local Players = game:GetService("Players")
local Guard = {}
function Guard.watchHoneypot(remote: RemoteEvent, options: { action: string, banSeconds: number?, onDetection: ((Player, string) -> ())? }): RBXScriptConnection
	assert(options.action == "log" or options.action == "kick" or options.action == "ban", "invalid action")
	if options.action == "ban" then
		assert(type(options.banSeconds) == "number" and options.banSeconds > 0 and options.banSeconds < math.huge and options.banSeconds % 1 == 0, "banSeconds must be a positive integer")
	end
	return remote.OnServerEvent:Connect(function(player: Player)
		if options.onDetection then
			local ok, err = pcall(options.onDetection, player, "honeypot_remote")
			if not ok then warn("[Guard] detection callback failed:", err) end
		end
		if options.action == "kick" then
			player:Kick("This session was closed by the game's security system.")
		elseif options.action == "ban" then
			local ok, err = pcall(function()
				Players:BanAsync({ UserIds = { player.UserId }, ApplyToUniverse = true,
					Duration = options.banSeconds, DisplayReason = "Suspicious activity detected. Contact the game team to appeal.",
					PrivateReason = "Anti-cheat honeypot remote triggered", ExcludeAltAccounts = true })
			end)
			if not ok then warn("[Guard] ban failed:", err) end
		end
	end)
end
return Guard
