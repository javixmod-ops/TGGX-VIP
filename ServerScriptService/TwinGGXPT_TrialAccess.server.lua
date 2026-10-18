-- Instalar este Script en ServerScriptService.
-- La key está incluida deliberadamente en el código del repositorio público.
-- Cualquier persona puede verla y canjearla una vez por su UserId de Roblox.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local TRIAL_SECONDS = 60 * 60
local TRIAL_KEY = "TGX-TRIAL-1H-2EE5A350D9774CA673C2586B"
local STORE = DataStoreService:GetDataStore("TwinGGXPT_TrialRedemptions_v1")
local REMOTE_NAME = "TwinGGXPT_TrialAccess"
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if remote and not remote:IsA("RemoteFunction") then
	error(REMOTE_NAME .. " existe pero no es RemoteFunction")
end
if not remote then
	remote = Instance.new("RemoteFunction")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
end

local lastAttempt = {}

remote.OnServerInvoke = function(player, action, suppliedKey)
	if action ~= "redeemTrial" or type(suppliedKey) ~= "string" then
		return {status = "invalid"}
	end
	if suppliedKey ~= TRIAL_KEY then return {status = "invalid"} end

	local userId = player.UserId
	local now = os.time()
	if now - (lastAttempt[userId] or 0) < 2 then
		return {status = "cooldown"}
	end
	lastAttempt[userId] = now

	local datastoreKey = "user_" .. tostring(userId)
	local readOk, saved = pcall(function()
		return STORE:GetAsync(datastoreKey)
	end)
	if not readOk then
		warn("[TwinGGXPT Trial] DataStore GetAsync falló para UserId " .. tostring(userId) .. ": " .. tostring(saved))
		return {status = "unavailable"}
	end
	if type(saved) == "table" then
		local expiresAt = tonumber(saved.expiresAt)
		if expiresAt and now < expiresAt then
			return {status = "active", expiresAt = expiresAt}
		end
		return {status = "used"}
	end

	local newRedemption = {
		activatedAt = now,
		expiresAt = now + TRIAL_SECONDS,
	}
	local writeOk, result = pcall(function()
		return STORE:UpdateAsync(datastoreKey, function(current)
			if current ~= nil then return current end
			return newRedemption
		end)
	end)
	if not writeOk or type(result) ~= "table" then
		warn("[TwinGGXPT Trial] DataStore UpdateAsync falló para UserId " .. tostring(userId) .. ": " .. tostring(result))
		return {status = "unavailable"}
	end

	local expiresAt = tonumber(result.expiresAt)
	if not expiresAt then return {status = "unavailable"} end
	if now >= expiresAt then return {status = "used"} end
	return {status = "activated", expiresAt = expiresAt}
end

Players.PlayerRemoving:Connect(function(player)
	lastAttempt[player.UserId] = nil
end)
