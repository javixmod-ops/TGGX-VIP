-- Coloca este Script en ServerScriptService.
-- El gamepass se valida fuera de este archivo: marca al VIP con
-- player:SetAttribute("CanUseImmortalityHitbox", true) tras validar la compra.
-- El arma/daño del juego debe consultar TestSafeHitbox para que la parte de prueba
-- tenga efecto; crearla por sí solo no vuelve invulnerable al Humanoid.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "TGX_ImmortalityHitbox"
local SAFE_POSITION = Vector3.new(0, 500, 0)
local lastRequest = {}

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if remote and not remote:IsA("RemoteEvent") then
	error(REMOTE_NAME .. " existe, pero no es RemoteEvent")
end
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
end

local function setHitbox(character, enabled)
	local previous = character:FindFirstChild("TestSafeHitbox")
	if not enabled then
		if previous then previous:Destroy() end
		return
	end
	if previous then previous:Destroy() end

	local hitbox = Instance.new("Part")
	hitbox.Name = "TestSafeHitbox"
	hitbox.Size = Vector3.new(4, 6, 4)
	hitbox.CFrame = CFrame.new(SAFE_POSITION)
	hitbox.Transparency = 1
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.CanTouch = false
	hitbox.CanQuery = true
	hitbox.Parent = character
end

local function bindPlayer(player)
	player.CharacterAdded:Connect(function(character)
		if player:GetAttribute("ImmortalityHitboxEnabled") == true
			and player:GetAttribute("CanUseImmortalityHitbox") == true then
			setHitbox(character, true)
		end
	end)
end

Players.PlayerAdded:Connect(bindPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	bindPlayer(player)
end

remote.OnServerEvent:Connect(function(player, enabled)
	if typeof(enabled) ~= "boolean" then return end
	if player:GetAttribute("CanUseImmortalityHitbox") ~= true then return end

	local now = os.clock()
	if now - (lastRequest[player] or 0) < 0.25 then return end
	lastRequest[player] = now
	player:SetAttribute("ImmortalityHitboxEnabled", enabled)
	local character = player.Character
	if character then setHitbox(character, enabled) end
end)

Players.PlayerRemoving:Connect(function(player)
	lastRequest[player] = nil
end)
