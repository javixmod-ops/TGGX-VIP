-- Coloca este Script en ServerScriptService.
-- El gamepass se valida fuera de este archivo: marca al VIP con
-- player:SetAttribute("CanUseImmortalityHitbox", true) tras validar la compra.
-- Reduce y restaura el HumanoidRootPart propio; no modifica los demás jugadores.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "TGX_SmallOwnHitbox"
local MIN_HITBOX_SIZE = Vector3.new(0.1, 0.1, 0.1)
local REQUEST_COOLDOWN = 0.25

local lastRequest = {}
local originalSizes = setmetatable({}, {__mode = "k"})

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if remote and not remote:IsA("RemoteEvent") then
	error(REMOTE_NAME .. " existe, pero no es RemoteEvent")
end
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
end

local function setOwnHitbox(player, enabled)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart or not rootPart:IsA("BasePart") then return false end

	if enabled then
		if originalSizes[character] == nil then
			originalSizes[character] = rootPart.Size
		end
		rootPart.Size = MIN_HITBOX_SIZE
	else
		local originalSize = originalSizes[character]
		if originalSize then
			rootPart.Size = originalSize
			originalSizes[character] = nil
		end
	end
	return true
end

local function bindPlayer(player)
	player.CharacterAdded:Connect(function(character)
		local rootPart = character:WaitForChild("HumanoidRootPart", 10)
		if rootPart and player:GetAttribute("SmallOwnHitboxEnabled") == true
			and player:GetAttribute("CanUseImmortalityHitbox") == true then
			setOwnHitbox(player, true)
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
	if now - (lastRequest[player] or 0) < REQUEST_COOLDOWN then return end
	lastRequest[player] = now
	player:SetAttribute("SmallOwnHitboxEnabled", enabled)
	setOwnHitbox(player, enabled)
end)

Players.PlayerRemoving:Connect(function(player)
	lastRequest[player] = nil
end)
