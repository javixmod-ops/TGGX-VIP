-- Instalar este Script en ServerScriptService.
-- Configuración privada: crear un StringValue llamado TwinGGXPT_TrialKey dentro de ServerStorage.
-- Pegar en su propiedad Value la clave de prueba entregada al propietario; no guardar esa Value en GitHub.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")

local TRIAL_SECONDS = 60 * 60
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
local function getConfiguredTrialKey()
	local valueObject = ServerStorage:FindFirstChild("TwinGGXPT_TrialKey")
	if valueObject and valueObject:IsA("StringValue") and valueObject.Value ~= "" then
		return valueObject.Value
	end
	return nil
end

remote.OnServerInvoke = function(player, action, suppliedKey)
	if action ~= "redeemTrial" or type(suppliedKey) ~= "string" then
		return {status = "invalid"}
	end
	local configuredKey = getConfiguredTrialKey()
	if not configuredKey then return {status = "unconfigured"} end
	if suppliedKey ~= configuredKey then return {status = "invalid"} end

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
	if not readOk then return {status = "unavailable"} end
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
	if not writeOk or type(result) ~= "table" then return {status = "unavailable"} end

	local expiresAt = tonumber(result.expiresAt)
	if not expiresAt then return {status = "unavailable"} end
	if now >= expiresAt then return {status = "used"} end
	return {status = "activated", expiresAt = expiresAt}
end

Players.PlayerRemoving:Connect(function(player)
	lastAttempt[player.UserId] = nil
end)
