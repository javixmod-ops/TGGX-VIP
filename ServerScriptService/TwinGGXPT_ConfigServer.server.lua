-- Instalar este archivo en ServerScriptService.
-- La interfaz solo envía su configuración; el servidor valida los campos y accede al DataStore.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local STORE = DataStoreService:GetDataStore("TwinGGXPT_Config_v1")
local REMOTE_NAME = "TwinGGXPT_ConfigRemote"
local SAVE_INTERVAL = 8
local MAX_FOV_RADIUS = 360
local MIN_FOV_RADIUS = 70
local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
	remote = Instance.new("RemoteFunction")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
end

local booleanDefaults = {
	 aimEnabled = false, aimNotifications = true, smoothAim = true,
	 cameraFovSet = false, showFov = true, epsLines = false, epsBoxes = false,
	 epsSkeleton = false, epsHealth = false, epsDistance = false, epsNearestLine = false,
	 hitboxEnabled = true, hitboxVisible = true, smallOwnHitbox = false,
	 showOwnHitbox = false, noclip = false, antiLag = false,
}
local numberLimits = {
	cameraFov = {40, 120}, fovRadius = {MIN_FOV_RADIUS, MAX_FOV_RADIUS},
	smallOwnHitboxSize = {0.1, 3}, hitboxSize = {5, 50},
	playerSpeed = {8, 80}, playerJump = {50, 200}, musicVolume = {0, 1},
}
local validStrings = {
	page = {AIMBOT = true, EPS = true, FOV = true, HITBOX = true, PLAYER = true, MISC = true, MUSIC = true, COLORS = true},
	language = {ES = true, EN = true, PT = true},
	fovShape = {Circle = true, Square = true, Triangle = true, Diamond = true, Pentagon = true, Hexagon = true},
}
local stringLimits = {currentMusicId = 20, currentMusicName = 100}
local cache = {}
local lastWrite = {}

local function sanitize(data)
	if type(data) ~= "table" then return nil end
	local clean = {}
	for key in pairs(booleanDefaults) do
		if type(data[key]) == "boolean" then clean[key] = data[key] end
	end
	for key, bounds in pairs(numberLimits) do
		local value = tonumber(data[key])
		if value and value == value then clean[key] = math.clamp(value, bounds[1], bounds[2]) end
	end
	for key, options in pairs(validStrings) do
		if type(data[key]) == "string" and options[data[key]] then clean[key] = data[key] end
	end
	for key, maxLength in pairs(stringLimits) do
		if type(data[key]) == "string" then clean[key] = string.sub(data[key], 1, maxLength) end
	end
	local color = data.accentColor
	if type(color) == "table" and #color == 3 then
		clean.accentColor = {}
		for i = 1, 3 do
			local component = tonumber(color[i])
			if not component or component ~= component then return nil end
			clean.accentColor[i] = math.clamp(component, 0, 1)
		end
	end
	return clean
end

local function persist(userId, data, force)
	local now = os.clock()
	if not force and now - (lastWrite[userId] or 0) < SAVE_INTERVAL then return true end
	local ok = pcall(function()
		STORE:UpdateAsync("player_" .. tostring(userId), function()
			return data
		end)
	end)
	if ok then lastWrite[userId] = now end
	return ok
end

remote.OnServerInvoke = function(player, action, payload)
	if action == "load" then
		local ok, data = pcall(function()
			return STORE:GetAsync("player_" .. tostring(player.UserId))
		end)
		local cleaned = ok and sanitize(data) or nil
		cache[player.UserId] = cleaned or {}
		return cache[player.UserId]
	elseif action == "save" then
		local cleaned = sanitize(payload)
		if not cleaned then return false end
		cache[player.UserId] = cleaned
		return persist(player.UserId, cleaned, false)
	end
	return false
end

Players.PlayerRemoving:Connect(function(player)
	local data = cache[player.UserId]
	if data then
		persist(player.UserId, data, true)
		cache[player.UserId] = nil
		lastWrite[player.UserId] = nil
	end
end)
