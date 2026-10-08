-- Instalar este archivo como Script en ServerScriptService.
-- Registra qué clientes tienen el menú cargado y expira su presencia si dejan de enviar heartbeat.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "TGGX_MenuPresence"
local PRESENCE_TIMEOUT = 35
local HEARTBEAT_MIN_INTERVAL = 4

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if remote and not remote:IsA("RemoteEvent") then
	remote:Destroy()
	remote = nil
end
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
end

local activeSince = {}
local lastHeartbeat = {}

local function collectPresence(now)
	local users = {}
	local removed = false
	for userId, lastSeen in pairs(activeSince) do
		local player = Players:GetPlayerByUserId(userId)
		if not player or now - lastSeen > PRESENCE_TIMEOUT then
			activeSince[userId] = nil
			lastHeartbeat[userId] = nil
			removed = true
		else
			table.insert(users, {
				userId = player.UserId,
				name = player.Name,
				displayName = player.DisplayName,
			})
		end
	end
	table.sort(users, function(a, b)
		return string.lower(a.displayName) < string.lower(b.displayName)
	end)
	return users, removed
end

local function broadcastPresence()
	local users = collectPresence(os.clock())
	for _, recipient in ipairs(Players:GetPlayers()) do
		remote:FireClient(recipient, users)
	end
end

remote.OnServerEvent:Connect(function(player, action)
	if action == "Heartbeat" then
		local now = os.clock()
		local previous = lastHeartbeat[player.UserId]
		if previous and now - previous < HEARTBEAT_MIN_INTERVAL then return end
		lastHeartbeat[player.UserId] = now
		local wasActive = activeSince[player.UserId] ~= nil and now - activeSince[player.UserId] <= PRESENCE_TIMEOUT
		activeSince[player.UserId] = now
		if not wasActive then broadcastPresence() end
	elseif action == "Refresh" then
		local users, removed = collectPresence(os.clock())
		if removed then
			broadcastPresence()
		else
			remote:FireClient(player, users)
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	activeSince[player.UserId] = nil
	lastHeartbeat[player.UserId] = nil
	broadcastPresence()
end)

task.spawn(function()
	while true do
		task.wait(5)
		local _, removed = collectPresence(os.clock())
		if removed then broadcastPresence() end
	end
end)
