-- TWIN GG XPT · LOCAL SOLO · HITBOX INTEGRADA
-- Colócalo en StarterPlayer > StarterPlayerScripts.
-- Diseñado como mecánica de tu propio shooter. No modifica impactos ni contiene Silent Aimbot.
-- Sin compras, claves ni GUI externa de Hitbox.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG = {
	MaxFovRadius = 360,
	MinFovRadius = 70,
	TargetTeammates = false,
	RequireLineOfSight = true,
	AimBetaSmoothness = 0.38,
	AimLockSmoothness = 0.82,
	AimLeadSeconds = 0.02,
	AimRetargetCooldown = 0.05,
	HitboxMinSize = 5,
	HitboxMaxSize = 50,
	HitboxDefaultSize = 10,
}

local state = {
	page = "AIMBOT",
	language = "ES",
	aimBeta = false,
	aimLock = false,
	showFov = true,
	fovRadius = 175,
	epsLines = false,
	epsBoxes = false,
	epsSkeleton = false,
	epsHealth = false,
	epsDistance = false,
	selectedTarget = nil,
	betaTarget = nil,
	hitboxEnabled = true,
	hitboxVisible = true,
	smallOwnHitbox = false,
	smallOwnHitboxSize = 0.1,
	showOwnHitbox = false,
	hitboxSize = 10,
	hitboxServerConfirmed = false,
	playerSpeed = 16,
	playerJump = 50,
	noclip = false,
	antiLag = false,
}

-- Variables del expansor LocalScript aportado. La pestaña HITBOX las controla directamente.
local isHitboxActive = true
local hitboxSize = 10
local showVisualBox = true
local LOCAL_HITBOX_MODE = true
local restoreLocalHitboxExpander

local translations = {
	ES = {
		title = "TWIN GG XPT",
		pageAim = "AIMBOT", pageEps = "EPS", pageFov = "FOV", pageHitbox = "HITBOX", pagePlayer = "PLAYER", pageMisc = "MISC",
		beta = "AIMBOT (BETA)", lock = "AIMBOT LOCK", choose = "CAMBIAR OBJETIVO",
		line = "LÍNEAS EPS", box = "CUADRADO EPS", skeleton = "EPS ESQUELETO",
		health = "EPS VIDA", distance = "EPS METROS", counter = "CONTADOR DE JUGADORES",
		visible = "FOV VISIBLE", radius = "RADIO DEL FOV", language = "IDIOMA",
		made = "HECHO POR EL DESARROLLADOR: JXVI", mode = "GUI MOD: ACTIVADO ✅",
		noTarget = "SIN OBJETIVO", target = "OBJETIVO",
		hitbox = "HITBOX EXPANDER", showHitbox = "MOSTRAR HITBOX", smallOwnHitbox = "HITBOX MÍNIMA", ownHitboxSize = "TAMAÑO PROPIO", showOwnHitbox = "VER MI HITBOX", hitboxSize = "TAMAÑO DE HITBOX",
		speed = "VELOCIDAD", resetSpeed = "RESET VELOCIDAD", superJump = "SUPER SALTO", resetJump = "RESET SUPER SALTO", noclip = "NOCLIP", antiLag = "ANTI LAG",
	},
	EN = {
		title = "TWIN GG XPT",
		pageAim = "AIM ASSIST", pageEps = "ESP", pageFov = "FOV", pageHitbox = "HITBOX", pagePlayer = "PLAYER", pageMisc = "MISC",
		beta = "AIM ASSIST (BETA)", lock = "AIM LOCK", choose = "CHANGE TARGET",
		line = "ESP LINES", box = "ESP BOX", skeleton = "ESP SKELETON",
		health = "ESP HEALTH", distance = "ESP DISTANCE", counter = "PLAYER COUNTER",
		visible = "SHOW FOV", radius = "FOV RADIUS", language = "LANGUAGE",
		made = "MADE BY THE DEVELOPER: JXVI", mode = "GUI MODE: ENABLED ✅",
		noTarget = "NO TARGET", target = "TARGET",
		hitbox = "HITBOX EXPANDER", showHitbox = "SHOW HITBOX", smallOwnHitbox = "TINY SELF HITBOX", ownHitboxSize = "OWN HITBOX SIZE", showOwnHitbox = "SHOW MY HITBOX", hitboxSize = "HITBOX SIZE",
		speed = "SPEED", resetSpeed = "RESET SPEED", superJump = "SUPER JUMP", resetJump = "RESET JUMP", noclip = "NOCLIP", antiLag = "LOW GRAPHICS",
	},
	PT = {
		title = "TWIN GG XPT",
		pageAim = "MIRA", pageEps = "ESP", pageFov = "FOV", pageHitbox = "HITBOX", pagePlayer = "PLAYER", pageMisc = "MISC",
		beta = "MIRA ASSISTIDA (BETA)", lock = "TRAVAR MIRA", choose = "MUDAR ALVO",
		line = "LINHAS ESP", box = "QUADRO ESP", skeleton = "ESQUELETO ESP",
		health = "VIDA ESP", distance = "DISTÂNCIA ESP", counter = "CONTADOR DE JOGADORES",
		visible = "FOV VISÍVEL", radius = "RAIO DO FOV", language = "IDIOMA",
		made = "FEITO PELO DESENVOLVEDOR: JXVI", mode = "MODO GUI: ATIVADO ✅",
		noTarget = "SEM ALVO", target = "ALVO",
		hitbox = "EXPANSOR DE HITBOX", showHitbox = "MOSTRAR HITBOX", smallOwnHitbox = "HITBOX MÍNIMA", ownHitboxSize = "TAMANHO PRÓPRIO", showOwnHitbox = "VER MINHA HITBOX", hitboxSize = "TAMANHO DA HITBOX",
		speed = "VELOCIDADE", resetSpeed = "RESET VELOCIDADE", superJump = "SUPER PULO", resetJump = "RESET PULO", noclip = "NOCLIP", antiLag = "ANTI LAG",
	},
}

local old = playerGui:FindFirstChild("TwinGGXPT")
if old then old:Destroy() end

local function t(key)
	return translations[state.language][key] or key
end

local function create(className, props, parent)
	local item = Instance.new(className)
	for key, value in pairs(props) do item[key] = value end
	item.Parent = parent
	return item
end

local function corner(parent, radius)
	return create("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
	}, parent)
end

local function gradient(parent, first, second, rotation)
	return create("UIGradient", {
		Color = ColorSequence.new(first, second),
		Rotation = rotation or 0,
	}, parent)
end

local WHITE = Color3.fromRGB(242, 248, 255)
local MUTED = Color3.fromRGB(152, 171, 191)
local ACCENT = Color3.fromRGB(70, 199, 255)
local SURFACE = Color3.fromRGB(16, 23, 35)
local SURFACE_2 = Color3.fromRGB(26, 38, 56)
local GREEN = Color3.fromRGB(59, 199, 137)
local RED = Color3.fromRGB(216, 75, 94)

local hitboxRemote = nil
local updateOwnHitboxVisual
local smallOwnHitboxSizeLabel
local hitboxStatusLabel = nil
local hitboxStatus = "HITBOX EXPANDER ACTIVADA"
local hitboxStatusColor = MUTED
local hitboxSyncQueued = false
local hitboxRequestId = 0
local hitboxResponseId = 0
local hitboxServerReady = false
local gui
local hitboxAdjustOverlay
local hitboxAdjustText
local hitboxAdjustSpinner
local hitboxAdjustToken = 0
local beginHitboxAdjustment
local finishHitboxAdjustment

local MIN_OWN_HITBOX_SIZE = 0.1
local MAX_OWN_HITBOX_SIZE = 3.0
local OWN_HITBOX_SIZE_STEP = 0.1
local localOwnHitboxOriginalSizes = setmetatable({}, {__mode = "k"})

local function updateLocalOwnHitbox(enabled)
	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart or not rootPart:IsA("BasePart") then return end

	if enabled then
		if localOwnHitboxOriginalSizes[character] == nil then
			localOwnHitboxOriginalSizes[character] = rootPart.Size
		end
		local size = state.smallOwnHitboxSize
		rootPart.Size = Vector3.new(size, size, size)
	else
		local originalSize = localOwnHitboxOriginalSizes[character]
		if originalSize then
			rootPart.Size = originalSize
			localOwnHitboxOriginalSizes[character] = nil
		end
	end
end

local function setHitboxStatus(message, color)
	hitboxStatus = message
	hitboxStatusColor = color or MUTED
	if hitboxStatusLabel then
		hitboxStatusLabel.Text = hitboxStatus
		hitboxStatusLabel.TextColor3 = hitboxStatusColor
	end
end

local function bindHitboxRemote()
	local candidate = ReplicatedStorage:FindFirstChild("TGX_HitboxControl")
	local readyMarker = ReplicatedStorage:FindFirstChild("TGX_HitboxServerReady")
	hitboxServerReady = readyMarker and readyMarker:IsA("BoolValue") and readyMarker.Value == true or false
	if candidate and candidate:IsA("RemoteEvent") and candidate ~= hitboxRemote then
		hitboxRemote = candidate
		candidate.OnClientEvent:Connect(function(payload)
			if type(payload) ~= "table" then return end
			local responseId = tonumber(payload.requestId)
			if responseId and responseId < hitboxRequestId then return end
			hitboxResponseId = responseId or hitboxRequestId
			local confirmed = payload.ok == true and payload.realActive == true and state.hitboxEnabled
			state.hitboxServerConfirmed = confirmed
				if confirmed then
					local realSize = tonumber(payload.size) or state.hitboxSize
					state.hitboxSize = math.clamp(realSize, CONFIG.HitboxMinSize, CONFIG.HitboxMaxSize)
					local detail = type(payload.message) == "string" and payload.message or ("VOLUMEN REAL " .. string.format("%.1f", state.hitboxSize) .. " STUDS")
					setHitboxStatus("ACTIVADO CORRECTAMENTE · " .. detail, GREEN)
					if finishHitboxAdjustment then finishHitboxAdjustment(true, "HITBOX APLICADA · " .. detail) end
				elseif state.hitboxEnabled then
					setHitboxStatus("MODO LOCAL · HITBOX EXPANDER ACTIVA", GREEN)
					if finishHitboxAdjustment then finishHitboxAdjustment(false, "NO SE PUDO APLICAR LA HITBOX") end
				else
					setHitboxStatus("HITBOX DESACTIVADA", MUTED)
					if finishHitboxAdjustment then finishHitboxAdjustment(false, "HITBOX DESACTIVADA") end
			end
		end)
	end
	return hitboxServerReady and hitboxRemote or nil
end
local function syncHitboxSettings()
	if LOCAL_HITBOX_MODE then return end
	local remote = bindHitboxRemote()
	if remote then
		hitboxRequestId += 1
			local requestId = hitboxRequestId
			state.hitboxServerConfirmed = false
			setHitboxStatus("SINCRONIZANDO VOLUMEN REAL...", ACCENT)
			if state.hitboxEnabled and beginHitboxAdjustment then
				beginHitboxAdjustment("DETECTANDO JUGADORES Y AJUSTANDO ROOT...")
			end
			remote:FireServer({
			enabled = state.hitboxEnabled,
			showDebug = state.hitboxVisible,
			size = state.hitboxSize,
			requestId = requestId,
		})
		task.delay(1.5, function()
				if state.hitboxEnabled and hitboxRequestId == requestId and hitboxResponseId < requestId then
					state.hitboxServerConfirmed = false
					setHitboxStatus("MODO LOCAL · HITBOX EXPANDER ACTIVA", GREEN)
					if finishHitboxAdjustment then finishHitboxAdjustment(false, "TIEMPO DE ESPERA DEL SERVIDOR") end
			end
		end)
	elseif state.hitboxEnabled then
		state.hitboxServerConfirmed = false
		setHitboxStatus("MODO LOCAL · HITBOX EXPANDER ACTIVA", GREEN)
		if finishHitboxAdjustment then finishHitboxAdjustment(false, "CONTROLADOR DE SERVIDOR NO DETECTADO") end
	else
		state.hitboxServerConfirmed = false
		setHitboxStatus(state.hitboxVisible and "CUBO VISUAL ACTIVO" or "MODO VISUAL LISTO", ACCENT)
		if finishHitboxAdjustment then finishHitboxAdjustment(false, "HITBOX DESACTIVADA") end
	end
end

local function queueHitboxSync()
	if hitboxSyncQueued then return end
	hitboxSyncQueued = true
	task.delay(0.14, function()
		hitboxSyncQueued = false
		syncHitboxSettings()
	end)
end

local function setSmallOwnHitboxSize(delta)
	state.smallOwnHitboxSize = math.clamp(
		math.round((state.smallOwnHitboxSize + delta) * 10) / 10,
		MIN_OWN_HITBOX_SIZE,
		MAX_OWN_HITBOX_SIZE
	)
	if state.smallOwnHitbox then updateLocalOwnHitbox(true) end
	if smallOwnHitboxSizeLabel then
		smallOwnHitboxSizeLabel.Text = t("ownHitboxSize") .. ": " .. string.format("%.1f studs", state.smallOwnHitboxSize)
	end
end

-- El Script de servidor puede iniciarse después de la GUI. Esperar el RemoteEvent
-- evita que una carga lenta quede permanentemente en “servidor no detectado”.
task.spawn(function()
	if LOCAL_HITBOX_MODE then return end
	while not gui do task.wait() end
	while gui.Parent and not bindHitboxRemote() do
		if state.hitboxEnabled then setHitboxStatus("ESPERANDO SCRIPT DE SERVIDOR HITBOX...", ACCENT) end
		task.wait(0.4)
	end
	if hitboxRemote and state.hitboxEnabled then queueHitboxSync() end
end)

ReplicatedStorage.ChildAdded:Connect(function(child)
	if LOCAL_HITBOX_MODE then return end
	if child.Name == "TGX_HitboxControl" or child.Name == "TGX_HitboxServerReady" then
		if bindHitboxRemote() and state.hitboxEnabled then queueHitboxSync() end
	end
end)

local noclipOriginalCollision = setmetatable({}, {__mode = "k"})
local lowDetailEnabledCache = setmetatable({}, {__mode = "k"})
local originalGlobalShadows = Lighting.GlobalShadows

local function getLocalHumanoid()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function applyPlayerMovement()
	local humanoid = getLocalHumanoid()
	if not humanoid then return end
	humanoid.UseJumpPower = true
	humanoid.WalkSpeed = state.playerSpeed
	humanoid.JumpPower = state.playerJump
end

local function applyNoclip()
	local character = player.Character
	if not character then return end
	for _, instance in ipairs(character:GetDescendants()) do
		if instance:IsA("BasePart") then
			if noclipOriginalCollision[instance] == nil then noclipOriginalCollision[instance] = instance.CanCollide end
			instance.CanCollide = false
		end
	end
end

local function restoreNoclip()
	for part, canCollide in pairs(noclipOriginalCollision) do
		if part.Parent then part.CanCollide = canCollide end
		noclipOriginalCollision[part] = nil
	end
end

local function setAntiLag(enabled)
	Lighting.GlobalShadows = enabled and false or originalGlobalShadows
	for _, instance in ipairs(workspace:GetDescendants()) do
		if instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") then
			if lowDetailEnabledCache[instance] == nil then lowDetailEnabledCache[instance] = instance.Enabled end
			instance.Enabled = enabled and false or lowDetailEnabledCache[instance]
		end
	end
	if not enabled then
		for instance, wasEnabled in pairs(lowDetailEnabledCache) do
			if instance.Parent then instance.Enabled = wasEnabled end
			lowDetailEnabledCache[instance] = nil
		end
	end
end

gui = create("ScreenGui", {
	Name = "TwinGGXPT",
	Enabled = false,
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

-- Círculo FOV. Solo es una ayuda visual: no altera los impactos del arma.
local fovCircle = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(state.fovRadius * 2, state.fovRadius * 2),
	Visible = state.showFov,
	ZIndex = 25,
}, gui)
corner(fovCircle, 999)
stroke(fovCircle, ACCENT, 1.4, 0.15)

local fovAdjustOverlay = create("Frame", {
	BackgroundColor3 = Color3.fromRGB(4, 19, 49),
	BackgroundTransparency = 0.03,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Visible = false,
	ZIndex = 200,
}, gui)
local fovSpinner = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.46),
	Size = UDim2.fromOffset(54, 54),
	ZIndex = 201,
}, fovAdjustOverlay)
corner(fovSpinner, 99)
stroke(fovSpinner, ACCENT, 3, 0)
local fovLoadingText = create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Position = UDim2.fromScale(0.5, 0.54),
	Size = UDim2.fromOffset(260, 24),
	Text = "AJUSTANDO FOV...",
	TextColor3 = WHITE,
	TextSize = 14,
	ZIndex = 202,
}, fovAdjustOverlay)

-- Capa exclusiva de HITBOX: bloquea visualmente la pantalla mientras el servidor
-- detecta jugadores y aplica el HumanoidRootPart del tamaño elegido.
hitboxAdjustOverlay = create("Frame", {
	Active = true,
	BackgroundColor3 = Color3.fromRGB(3, 14, 39),
	BackgroundTransparency = 0.02,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Visible = false,
	ZIndex = 220,
}, gui)
local hitboxSpinner = create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack,
	Position = UDim2.fromScale(0.5, 0.45),
	Size = UDim2.fromOffset(68, 68),
	Text = "◔",
	TextColor3 = ACCENT,
	TextSize = 56,
	ZIndex = 221,
}, hitboxAdjustOverlay)
hitboxAdjustSpinner = hitboxSpinner
hitboxAdjustText = create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Position = UDim2.fromScale(0.5, 0.53),
	Size = UDim2.fromOffset(380, 28),
	Text = "AJUSTANDO HITBOX...",
	TextColor3 = WHITE,
	TextSize = 15,
	ZIndex = 222,
}, hitboxAdjustOverlay)
hitboxAdjustText.TextXAlignment = Enum.TextXAlignment.Center
local hitboxAdjustSubtext = create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.RobotoMono,
	Position = UDim2.fromScale(0.5, 0.57),
	Size = UDim2.fromOffset(440, 20),
	Text = "HITBOX 5–50 STUDS · VOLUMEN REAL DE SERVIDOR",
	TextColor3 = ACCENT,
	TextSize = 8,
	ZIndex = 222,
}, hitboxAdjustOverlay)
hitboxAdjustSubtext.TextXAlignment = Enum.TextXAlignment.Center

beginHitboxAdjustment = function(message)
	hitboxAdjustToken += 1
	hitboxAdjustOverlay.Visible = true
	hitboxAdjustText.Text = message or "AJUSTANDO HITBOX..."
	hitboxAdjustText.TextColor3 = WHITE
	hitboxAdjustSpinner.Rotation = 0
	TweenService:Create(hitboxAdjustSpinner, TweenInfo.new(0.48, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()
end

finishHitboxAdjustment = function(ok, message)
	local token = hitboxAdjustToken
	if not hitboxAdjustOverlay.Visible then return end
	hitboxAdjustText.Text = message or (ok and "HITBOX AJUSTADA ✓" or "HITBOX DESACTIVADA")
	hitboxAdjustText.TextColor3 = ok and GREEN or (message and RED or MUTED)
	task.delay(ok and 0.65 or 0.9, function()
		if hitboxAdjustToken == token and hitboxAdjustOverlay.Parent then
			hitboxAdjustOverlay.Visible = false
		end
	end)
end

local root = create("Frame", {
	Active = true,
	BackgroundColor3 = SURFACE,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Position = UDim2.new(0.5, -228, 0.5, -190),
	Size = UDim2.fromOffset(456, 380),
	ZIndex = 10,
}, gui)
corner(root, 20)
stroke(root, ACCENT, 1.4, 0.12)
local menuBackground = create("ImageLabel", {
	Name = "MenuBackground",
	Active = false,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0, 0),
	Size = UDim2.fromScale(1, 1),
	Image = "rbxassetid://105104843236302",
	ImageTransparency = 0,
	ScaleType = Enum.ScaleType.Crop,
	ZIndex = 11,
}, root)

task.delay(8, function()
	if menuBackground.Parent and not menuBackground.IsLoaded then
		warn("El fondo 105104843236302 no cargó. Revisa en Output si la experiencia tiene permiso para usar la imagen.")
	end
end)

local rootGlow = create("Frame", {
	BackgroundColor3 = Color3.fromRGB(43, 139, 211),
	BackgroundTransparency = 0.86,
	BorderSizePixel = 0,
	Position = UDim2.new(0.48, 0, -0.4, 0),
	Size = UDim2.fromOffset(290, 220),
	ZIndex = 10,
}, root)
corner(rootGlow, 999)

local topbar = create("Frame", {
	Active = true,
	BackgroundColor3 = SURFACE_2,
	BackgroundTransparency = 0.62,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 48),
	ZIndex = 12,
}, root)
corner(topbar, 18)
gradient(topbar, Color3.fromRGB(31, 52, 80), Color3.fromRGB(16, 26, 44), 0)
create("Frame", {
	BackgroundColor3 = SURFACE_2,
	BackgroundTransparency = 0.62,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -18),
	Size = UDim2.new(1, 0, 0, 18),
	ZIndex = 11,
}, topbar)

local logo = create("TextButton", {
	Active = true,
	AutoButtonColor = false,
	BackgroundColor3 = ACCENT,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBlack,
	Position = UDim2.fromOffset(13, 10),
	Size = UDim2.fromOffset(28, 28),
	Text = "TGX",
	TextColor3 = Color3.fromRGB(8, 17, 28),
	TextSize = 9,
	ZIndex = 12,
}, topbar)
corner(logo, 8)

local title = create("TextLabel", {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Position = UDim2.fromOffset(51, 0),
	Size = UDim2.new(1, -170, 1, 0),
	Text = t("title"),
	TextColor3 = WHITE,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 12,
}, topbar)

local onlineStatus = create("TextLabel", {
	BackgroundColor3 = Color3.fromRGB(13, 45, 54),
	BorderSizePixel = 0,
	Font = Enum.Font.RobotoMono,
	Position = UDim2.new(1, -105, 0, 15),
	Size = UDim2.fromOffset(91, 18),
	Text = "● ONLINE",
	TextColor3 = Color3.fromRGB(94, 239, 184),
	TextSize = 7,
	ZIndex = 12,
}, topbar)
corner(onlineStatus, 9)
stroke(onlineStatus, Color3.fromRGB(94, 239, 184), 1, 0.68)

local side = create("Frame", {
	BackgroundColor3 = Color3.fromRGB(12, 18, 28),
	BackgroundTransparency = 0.82,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(0, 48),
	Size = UDim2.new(0, 116, 1, -48),
	ZIndex = 12,
}, root)
gradient(side, Color3.fromRGB(15, 25, 42), Color3.fromRGB(8, 13, 23), 90)

local content = create("Frame", {
	BackgroundColor3 = Color3.fromRGB(10, 17, 29),
	BackgroundTransparency = 0.88,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Position = UDim2.fromOffset(116, 48),
	Size = UDim2.new(1, -116, 1, -48),
	ZIndex = 12,
}, root)

local hud = create("Frame", {
	Active = true,
	BackgroundColor3 = Color3.fromRGB(10, 17, 27),
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, -82, 0, 9),
	Size = UDim2.fromOffset(164, 30),
	ZIndex = 8,
}, gui)
corner(hud, 10)
stroke(hud, ACCENT, 1, 0.35)
local hudText = create("TextLabel", {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Size = UDim2.fromScale(1, 1),
	Text = "JUGADORES: 1",
	TextColor3 = WHITE,
	TextSize = 11,
	ZIndex = 9,
}, hud)

local minimizedButton = create("TextButton", {
	Active = true,
	AutoButtonColor = false,
	BackgroundColor3 = ACCENT,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBlack,
	Position = root.Position,
	Size = UDim2.fromOffset(46, 46),
	Text = "TGX",
	TextColor3 = Color3.fromRGB(8, 17, 28),
	TextSize = 10,
	Visible = false,
	ZIndex = 15,
}, gui)
corner(minimizedButton, 12)
stroke(minimizedButton, WHITE, 1, 0.45)

local navButtons = {}
local pageFrames = {}
local refreshPage

local function cleanContent()
	for _, child in ipairs(content:GetChildren()) do child:Destroy() end
	pageFrames = {}
end

local function label(parent, text, pos, size, font, color, textSize)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Font = font or Enum.Font.Gotham,
		Position = pos,
		Size = size,
		Text = text,
		TextColor3 = color or WHITE,
		TextSize = textSize or 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 12,
	}, parent)
end

local function toggle(parent, y, text, getValue, setValue)
	label(parent, text, UDim2.fromOffset(16, y), UDim2.new(1, -95, 0, 30), Enum.Font.GothamMedium, WHITE, 11)
	local knob = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = getValue() and GREEN or Color3.fromRGB(67, 81, 101),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -62, 0, y + 3),
		Size = UDim2.fromOffset(46, 24),
		Text = "",
		ZIndex = 13,
	}, parent)
	corner(knob, 12)
	stroke(knob, getValue() and Color3.fromRGB(119, 244, 187) or Color3.fromRGB(131, 153, 183), 1, 0.65)
	local circle = create("Frame", {
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Position = getValue() and UDim2.fromOffset(26, 3) or UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(18, 18),
		ZIndex = 14,
	}, knob)
	corner(circle, 12)
	knob.Activated:Connect(function()
		setValue(not getValue())
		knob.BackgroundColor3 = getValue() and GREEN or Color3.fromRGB(67, 81, 101)
		local knobStroke = knob:FindFirstChildOfClass("UIStroke")
		if knobStroke then knobStroke.Color = getValue() and Color3.fromRGB(119, 244, 187) or Color3.fromRGB(131, 153, 183) end
		circle.Position = getValue() and UDim2.fromOffset(26, 3) or UDim2.fromOffset(3, 3)
	end)
	return knob
end

local function sectionTitle(parent, titleText, subtitle)
	label(parent, subtitle, UDim2.fromOffset(16, 13), UDim2.new(1, -32, 0, 14), Enum.Font.RobotoMono, ACCENT, 8)
	label(parent, titleText, UDim2.fromOffset(16, 29), UDim2.new(1, -32, 0, 28), Enum.Font.GothamBold, WHITE, 18)
end

local function makePage(name)
	local page = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 12,
	}, content)
	pageFrames[name] = page
	return page
end

local function getPlayerParts(targetPlayer)
	local character = targetPlayer and targetPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character.PrimaryPart)
	local head = character and (character:FindFirstChild("Head") or rootPart)
	if humanoid and humanoid.Health > 0 and rootPart and head then
		return character, humanoid, rootPart, head
	end
	return nil
end

local function isValidTarget(targetPlayer)
	if targetPlayer == player then return false end
	if not CONFIG.TargetTeammates and player.Team ~= nil and targetPlayer.Team == player.Team then return false end
	return getPlayerParts(targetPlayer) ~= nil
end

local function detectDevice()
	if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then return "CONSOLE" end
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "MOBILE" end
	return "PC"
end

local function fovCenter(camera)
	-- Camera y la ScreenGui pueden tener tamaños distintos. Se usa el mismo espacio
	-- de GUI para el círculo y para la selección de AIMBOT.
	local viewport = camera.ViewportSize
	local guiSize = gui.AbsoluteSize
	local scaleX = guiSize.X > 0 and guiSize.X / math.max(viewport.X, 1) or 1
	local scaleY = guiSize.Y > 0 and guiSize.Y / math.max(viewport.Y, 1) or 1
	return Vector2.new(viewport.X * 0.5 * scaleX, viewport.Y * 0.5 * scaleY)
end

local function viewportToGuiPoint(camera, projected)
	local viewport = camera.ViewportSize
	local guiSize = gui.AbsoluteSize
	return Vector2.new(
		projected.X * (guiSize.X > 0 and guiSize.X / math.max(viewport.X, 1) or 1),
		projected.Y * (guiSize.Y > 0 and guiSize.Y / math.max(viewport.Y, 1) or 1)
	)
end

local fovAdjusting = false
local function adjustFovToDevice()
	if fovAdjusting then return end
	fovAdjusting = true
	fovAdjustOverlay.Visible = true
	fovLoadingText.Text = "AJUSTANDO FOV..."
	fovSpinner.Rotation = 0
	local spin = TweenService:Create(fovSpinner, TweenInfo.new(0.42, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 2), {Rotation = 720})
	spin:Play()
	task.wait(0.9)
	local camera = workspace.CurrentCamera
	if camera then
		local center = fovCenter(camera)
		fovCircle.Position = UDim2.fromOffset(center.X, center.Y)
	end
	local device = detectDevice()
	local icon = device == "MOBILE" and "📱" or (device == "CONSOLE" and "🎮" or "💻")
	fovLoadingText.Text = "AJUSTADO FOV ✓  " .. icon
	task.wait(0.55)
	fovAdjustOverlay.Visible = false
	fovAdjusting = false
end

local function lineOfSight(character, point)
	if not CONFIG.RequireLineOfSight then return true end
	local camera = workspace.CurrentCamera
	if not camera then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}
	params.IgnoreWater = true
	local result = workspace:Raycast(camera.CFrame.Position, point - camera.CFrame.Position, params)
	if result and result.Instance then
		return result.Instance:IsDescendantOf(character)
	end
	-- Algunos shooters desactivan CanQuery en los personajes. En ese caso,
	-- Camera:GetPartsObscuringTarget detecta paredes sin exigir un impacto en el rig.
	local blockers = camera:GetPartsObscuringTarget({point}, {player.Character, character})
	return #blockers == 0
end

local function getAimCandidate(camera, targetPlayer)
	local character, _, rootPart, head = targetPlayer and getPlayerParts(targetPlayer)
	if not character or not rootPart or not head or not isValidTarget(targetPlayer) then return nil end
	local projected, onScreen = camera:WorldToViewportPoint(head.Position)
	if not onScreen or projected.Z <= 0 then return nil end
	local guiPoint = viewportToGuiPoint(camera, projected)
	if (guiPoint - fovCenter(camera)).Magnitude > state.fovRadius then return nil end
	if not lineOfSight(character, head.Position) then return nil end
	return character, rootPart, head, guiPoint
end

local function findClosestTarget(ignoreFov)
	local camera = workspace.CurrentCamera
	if not camera then return nil end
	local viewportCenter = fovCenter(camera)
	local best, bestDistance = nil, ignoreFov and math.huge or state.fovRadius
	for _, candidate in ipairs(Players:GetPlayers()) do
		local _, _, _, screenPoint = getAimCandidate(camera, candidate)
		if screenPoint then
			local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - viewportCenter).Magnitude
			if distance <= bestDistance then
				best = candidate
				bestDistance = distance
			end
		end
	end
	return best
end

local function cycleTarget()
	local available = {}
	local camera = workspace.CurrentCamera
	if not camera then return end
	for _, candidate in ipairs(Players:GetPlayers()) do
		if getAimCandidate(camera, candidate) then table.insert(available, candidate) end
	end
	if #available == 0 then
		if state.aimBeta then state.betaTarget = nil else state.selectedTarget = nil end
		return
	end
	table.sort(available, function(a, b) return a.Name < b.Name end)
	local current = state.aimBeta and state.betaTarget or state.selectedTarget
	local currentIndex = table.find(available, current)
	local nextTarget = available[(currentIndex or 0) % #available + 1]
	if state.aimBeta then
		state.betaTarget = nextTarget
	else
		state.selectedTarget = nextTarget
	end
end

local function renderAimPage()
	local page = makePage("AIMBOT")
	sectionTitle(page, t("pageAim"), "ASISTENCIA OFICIAL · SIN SILENT AIM")
	toggle(page, 73, t("beta"), function() return state.aimBeta end, function(value)
		state.aimBeta = value
		if value then
			state.aimLock = false
			state.selectedTarget = nil
			state.betaTarget = findClosestTarget(false)
		else
			state.betaTarget = nil
		end
	end)
	toggle(page, 112, t("lock"), function() return state.aimLock end, function(value)
		state.aimLock = value
		if value then
			state.aimBeta = false
			state.betaTarget = nil
			state.selectedTarget = findClosestTarget(false)
		end
		if not value then state.selectedTarget = nil end
	end)

	local targetPanel = create("Frame", {
		BackgroundColor3 = SURFACE_2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 158),
		Size = UDim2.new(1, -32, 0, 80),
		ZIndex = 12,
	}, page)
	corner(targetPanel, 11)
	stroke(targetPanel, ACCENT, 1, 0.65)
	local targetName = label(targetPanel, t("noTarget"), UDim2.fromOffset(12, 10), UDim2.new(1, -24, 0, 21), Enum.Font.GothamBold, WHITE, 12)
	targetName.Name = "TargetName"
	label(targetPanel, "LA ASISTENCIA SOLO SIGUE OBJETIVOS VISIBLES DENTRO DEL FOV.", UDim2.fromOffset(12, 33), UDim2.new(1, -24, 0, 17), Enum.Font.RobotoMono, MUTED, 7)
	local nextButton = create("TextButton", {
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -115, 1, -25),
		Size = UDim2.fromOffset(103, 18),
		Text = t("choose"),
		TextColor3 = Color3.fromRGB(6, 17, 27),
		TextSize = 7,
		ZIndex = 13,
	}, targetPanel)
	corner(nextButton, 6)
	nextButton.Activated:Connect(function()
		cycleTarget()
		local activeTarget = state.aimBeta and state.betaTarget or state.selectedTarget
		targetName.Text = activeTarget and (t("target") .. ": " .. activeTarget.DisplayName) or t("noTarget")
	end)
end

local function renderHitboxPage()
	local page = makePage("HITBOX")
	sectionTitle(page, t("pageHitbox"), "EXPANDER LOCAL 5–50 STUDS")
	toggle(page, 65, t("hitbox"), function() return state.hitboxEnabled end, function(value)
		state.hitboxEnabled = value
		isHitboxActive = value
		if not value and restoreLocalHitboxExpander then restoreLocalHitboxExpander() end
		setHitboxStatus(value and "HITBOX EXPANDER ACTIVADA" or "HITBOX EXPANDER DESACTIVADA", value and GREEN or MUTED)
	end)
	toggle(page, 100, t("showHitbox"), function() return state.hitboxVisible end, function(value)
		state.hitboxVisible = value
		showVisualBox = value
		setHitboxStatus(value and "CUADRADO DE HITBOX VISIBLE" or "CUADRADO DE HITBOX OCULTO", value and ACCENT or MUTED)
	end)
	toggle(page, 133, t("smallOwnHitbox"), function() return state.smallOwnHitbox end, function(value)
		state.smallOwnHitbox = value == true
		updateLocalOwnHitbox(state.smallOwnHitbox)
		setHitboxStatus(state.smallOwnHitbox and "HITBOX MÍNIMA LOCAL ACTIVA" or "HITBOX MÍNIMA DESACTIVADA", state.smallOwnHitbox and GREEN or MUTED)
	end)
	toggle(page, 166, t("showOwnHitbox"), function() return state.showOwnHitbox end, function(value)
		state.showOwnHitbox = value
		updateOwnHitboxVisual()
		setHitboxStatus(value and "MOSTRANDO SOLO TU HITBOX" or "VISTA DE TU HITBOX DESACTIVADA", value and ACCENT or MUTED)
	end)

	smallOwnHitboxSizeLabel = label(page, t("ownHitboxSize") .. ": " .. string.format("%.1f studs", state.smallOwnHitboxSize), UDim2.fromOffset(16, 201), UDim2.new(1, -112, 0, 24), Enum.Font.GothamMedium, WHITE, 10)
	local function makeOwnSizeButton(text, xOffset, delta)
		local button = create("TextButton", {
			Active = true, AutoButtonColor = false, BackgroundColor3 = SURFACE_2, BorderSizePixel = 0,
			Position = UDim2.new(1, xOffset, 0, 199), Size = UDim2.fromOffset(34, 26),
			Font = Enum.Font.GothamBold, Text = text, TextColor3 = WHITE, TextSize = 14, ZIndex = 13,
		}, page)
		corner(button, 7)
		button.Activated:Connect(function() setSmallOwnHitboxSize(delta) end)
	end
	makeOwnSizeButton("−", -96, -OWN_HITBOX_SIZE_STEP)
	makeOwnSizeButton("+", -52, OWN_HITBOX_SIZE_STEP)

	label(page, t("hitboxSize"), UDim2.fromOffset(16, 235), UDim2.new(1, -32, 0, 18), Enum.Font.GothamMedium, WHITE, 11)
	local valueText = label(page, string.format("%.1f studs", state.hitboxSize), UDim2.new(1, -108, 0, 235), UDim2.fromOffset(92, 18), Enum.Font.RobotoMono, ACCENT, 9)
	valueText.TextXAlignment = Enum.TextXAlignment.Right
	local bar = create("Frame", {
		Active = true,
		BackgroundColor3 = Color3.fromRGB(56, 70, 92),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 265),
		Size = UDim2.new(1, -32, 0, 8),
		ZIndex = 12,
	}, page)
	corner(bar, 8)
	local range = CONFIG.HitboxMaxSize - CONFIG.HitboxMinSize
	local sizeRatio = (state.hitboxSize - CONFIG.HitboxMinSize) / range
	local fill = create("Frame", {BackgroundColor3 = ACCENT, BorderSizePixel = 0, Size = UDim2.fromScale(sizeRatio, 1), ZIndex = 13}, bar)
	corner(fill, 8)
	local handle = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, BorderSizePixel = 0,
		Position = UDim2.fromScale(sizeRatio, 0.5), Size = UDim2.fromOffset(16, 16), ZIndex = 14,
	}, bar)
	corner(handle, 16)
	local changing = false
	local function updateSlider(input)
		local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		state.hitboxSize = math.round((CONFIG.HitboxMinSize + range * ratio) * 10) / 10
		hitboxSize = state.hitboxSize
		fill.Size = UDim2.fromScale(ratio, 1)
		handle.Position = UDim2.fromScale(ratio, 0.5)
		valueText.Text = string.format("%.1f studs", state.hitboxSize)
		setHitboxStatus("TAMAÑO DE HITBOX: " .. string.format("%.1f", hitboxSize) .. " STUDS", ACCENT)
	end
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			changing = true
			updateSlider(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if changing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then changing = false end
	end)

	local statusPanel = create("Frame", {BackgroundColor3 = SURFACE_2, BorderSizePixel = 0, Position = UDim2.fromOffset(16, 283), Size = UDim2.new(1, -32, 0, 39), ZIndex = 12}, page)
	corner(statusPanel, 9)
	label(statusPanel, "ESTADO DE HITBOX", UDim2.fromOffset(10, 7), UDim2.new(1, -20, 0, 12), Enum.Font.RobotoMono, MUTED, 7)
	hitboxStatusLabel = label(statusPanel, hitboxStatus, UDim2.fromOffset(10, 19), UDim2.new(1, -20, 0, 16), Enum.Font.GothamBold, hitboxStatusColor, 8)
	setHitboxStatus(isHitboxActive and "HITBOX EXPANDER ACTIVADA" or "HITBOX EXPANDER DESACTIVADA", isHitboxActive and GREEN or MUTED)
end

local function renderEpsPage()
	local page = makePage("EPS")
	sectionTitle(page, t("pageEps"), "MARCADORES VISUALES DEL SHOOTER")
	toggle(page, 66, t("line"), function() return state.epsLines end, function(value) state.epsLines = value end)
	toggle(page, 99, t("box"), function() return state.epsBoxes end, function(value) state.epsBoxes = value end)
	toggle(page, 132, t("skeleton"), function() return state.epsSkeleton end, function(value) state.epsSkeleton = value end)
	toggle(page, 165, t("health"), function() return state.epsHealth end, function(value) state.epsHealth = value end)
	toggle(page, 198, t("distance"), function() return state.epsDistance end, function(value) state.epsDistance = value end)
	toggle(page, 231, t("counter"), function() return hud.Visible end, function(value) hud.Visible = value end)
end

local function setFovRadius(radius)
	state.fovRadius = math.clamp(math.floor(radius), CONFIG.MinFovRadius, CONFIG.MaxFovRadius)
	fovCircle.Size = UDim2.fromOffset(state.fovRadius * 2, state.fovRadius * 2)
end

local function renderFovPage()
	local page = makePage("FOV")
	sectionTitle(page, "FOV", "CAMPO DE VISIÓN PARA LA ASISTENCIA")
	toggle(page, 72, t("visible"), function() return state.showFov end, function(value)
		state.showFov = value
		fovCircle.Visible = value
	end)
	label(page, t("radius"), UDim2.fromOffset(16, 123), UDim2.new(1, -32, 0, 20), Enum.Font.GothamMedium, WHITE, 11)
	local valueText = label(page, tostring(state.fovRadius) .. " px", UDim2.new(1, -72, 0, 123), UDim2.fromOffset(56, 20), Enum.Font.RobotoMono, ACCENT, 9)
	valueText.TextXAlignment = Enum.TextXAlignment.Right
	local bar = create("Frame", {
		Active = true,
		BackgroundColor3 = Color3.fromRGB(56, 70, 92),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 157),
		Size = UDim2.new(1, -32, 0, 8),
		ZIndex = 12,
	}, page)
	corner(bar, 8)
	local fill = create("Frame", {
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Size = UDim2.fromScale((state.fovRadius - CONFIG.MinFovRadius) / (CONFIG.MaxFovRadius - CONFIG.MinFovRadius), 1),
		ZIndex = 13,
	}, bar)
	corner(fill, 8)
	local handle = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Position = UDim2.fromScale((state.fovRadius - CONFIG.MinFovRadius) / (CONFIG.MaxFovRadius - CONFIG.MinFovRadius), 0.5),
		Size = UDim2.fromOffset(16, 16),
		ZIndex = 14,
	}, bar)
	corner(handle, 16)

	local changing = false
	local function updateSlider(input)
		local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		setFovRadius(CONFIG.MinFovRadius + (CONFIG.MaxFovRadius - CONFIG.MinFovRadius) * ratio)
		fill.Size = UDim2.fromScale(ratio, 1)
		handle.Position = UDim2.fromScale(ratio, 0.5)
		valueText.Text = tostring(state.fovRadius) .. " px"
	end
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			changing = true
			updateSlider(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if changing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then changing = false end
	end)
	label(page, "UN OBJETIVO DEBE ESTAR DENTRO DEL CÍRCULO Y TENER LÍNEA DE VISIÓN.", UDim2.fromOffset(16, 185), UDim2.new(1, -32, 0, 30), Enum.Font.RobotoMono, MUTED, 8)
	local adjust = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(16, 226),
		Size = UDim2.new(1, -32, 0, 28),
		Text = "AJUSTAR FOV",
		TextColor3 = Color3.fromRGB(6, 17, 28),
		TextSize = 9,
		ZIndex = 14,
	}, page)
	corner(adjust, 8)
	adjust.Activated:Connect(adjustFovToDevice)
end

local function deviceIcon()
	local device = detectDevice()
	if device == "MOBILE" then return "📱" end
	if device == "CONSOLE" then return "🎮" end
	return "💻"
end

local function renderPlayerPage()
	local page = makePage("PLAYER")
	sectionTitle(page, t("pagePlayer"), "CONTROLES DE PRUEBA DEL PERSONAJE")

	local function stepper(y, titleText, getValue, setValue, minValue, maxValue, step, suffix)
		label(page, titleText, UDim2.fromOffset(16, y), UDim2.new(1, -32, 0, 18), Enum.Font.GothamMedium, WHITE, 11)
		local value = label(page, tostring(getValue()) .. suffix, UDim2.new(1, -147, 0, y), UDim2.fromOffset(68, 18), Enum.Font.RobotoMono, ACCENT, 9)
		value.TextXAlignment = Enum.TextXAlignment.Center
		local function makeStepButton(x, text, delta)
			local button = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = SURFACE_2, BorderSizePixel = 0, Font = Enum.Font.GothamBold, Position = UDim2.new(1, x, 0, y - 2), Size = UDim2.fromOffset(28, 22), Text = text, TextColor3 = WHITE, TextSize = 12, ZIndex = 13}, page)
			corner(button, 7)
			button.Activated:Connect(function()
				setValue(math.clamp(getValue() + delta, minValue, maxValue))
				value.Text = tostring(getValue()) .. suffix
				applyPlayerMovement()
			end)
		end
		makeStepButton(-76, "−", -step)
		makeStepButton(-40, "+", step)
	end

	stepper(63, t("speed"), function() return state.playerSpeed end, function(v) state.playerSpeed = v end, 8, 80, 4, "")
	local resetSpeed = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(48, 81, 112), BorderSizePixel = 0, Font = Enum.Font.GothamBold, Position = UDim2.fromOffset(16, 91), Size = UDim2.new(1, -32, 0, 20), Text = t("resetSpeed"), TextColor3 = WHITE, TextSize = 8, ZIndex = 13}, page)
	corner(resetSpeed, 7)
	resetSpeed.Activated:Connect(function() state.playerSpeed = 16; applyPlayerMovement(); refreshPage() end)

	stepper(123, t("superJump"), function() return state.playerJump end, function(v) state.playerJump = v end, 50, 200, 10, "")
	local resetJump = create("TextButton", {AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(48, 81, 112), BorderSizePixel = 0, Font = Enum.Font.GothamBold, Position = UDim2.fromOffset(16, 151), Size = UDim2.new(1, -32, 0, 20), Text = t("resetJump"), TextColor3 = WHITE, TextSize = 8, ZIndex = 13}, page)
	corner(resetJump, 7)
	resetJump.Activated:Connect(function() state.playerJump = 50; applyPlayerMovement(); refreshPage() end)

	toggle(page, 186, t("noclip"), function() return state.noclip end, function(value)
		state.noclip = value
		if value then applyNoclip() else restoreNoclip() end
	end)
	toggle(page, 222, t("antiLag"), function() return state.antiLag end, function(value)
		state.antiLag = value
		setAntiLag(value)
	end)
	label(page, "VELOCIDAD Y SALTO: 8–80 / 50–200 · ANTI LAG OCULTA EFECTOS LOCALES.", UDim2.fromOffset(16, 260), UDim2.new(1, -32, 0, 17), Enum.Font.RobotoMono, MUTED, 7)
end

local function renderMiscPage()
	local page = makePage("MISC")
	sectionTitle(page, t("pageMisc"), "AJUSTES Y ESTADO DEL CLIENTE")
	label(page, t("language"), UDim2.fromOffset(16, 62), UDim2.new(1, -32, 0, 18), Enum.Font.GothamMedium, WHITE, 11)
	local options = {{"ES", "ESPAÑOL"}, {"EN", "ENGLISH"}, {"PT", "PORTUGUÊS"}}
	for index, option in ipairs(options) do
		local languageButton = create("TextButton", {
			BackgroundColor3 = state.language == option[1] and ACCENT or SURFACE_2,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(16 + (index - 1) * 76, 84),
			Size = UDim2.fromOffset(68, 23),
			Text = option[2],
			TextColor3 = state.language == option[1] and Color3.fromRGB(5, 17, 27) or WHITE,
			TextSize = 7,
			ZIndex = 13,
		}, page)
		corner(languageButton, 7)
		languageButton.Activated:Connect(function()
			state.language = option[1]
			refreshPage()
		end)
	end

	local profile = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(20, 38, 61),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 119),
		Size = UDim2.new(1, -32, 0, 52),
		ZIndex = 12,
	}, page)
	corner(profile, 10)
	stroke(profile, ACCENT, 1, 0.6)
	local avatar = create("ImageLabel", {
		BackgroundColor3 = Color3.fromRGB(8, 17, 28),
		BorderSizePixel = 0,
		Image = "",
		Position = UDim2.fromOffset(7, 7),
		Size = UDim2.fromOffset(38, 38),
		ZIndex = 13,
	}, profile)
	corner(avatar, 19)
	stroke(avatar, ACCENT, 1, 0.2)
	label(profile, player.DisplayName, UDim2.fromOffset(54, 7), UDim2.new(1, -65, 0, 17), Enum.Font.GothamBold, WHITE, 11)
	label(profile, "@" .. player.Name, UDim2.fromOffset(54, 25), UDim2.new(1, -65, 0, 14), Enum.Font.RobotoMono, ACCENT, 8)
	task.spawn(function()
		local ok, thumbnail = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok and avatar.Parent then avatar.Image = thumbnail end
	end)

	local info = create("Frame", {
		BackgroundColor3 = SURFACE_2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 180),
		Size = UDim2.new(1, -32, 0, 76),
		ZIndex = 12,
	}, page)
	corner(info, 11)
	label(info, t("made"), UDim2.fromOffset(11, 7), UDim2.new(1, -22, 0, 13), Enum.Font.GothamBold, WHITE, 8)
	label(info, t("mode"), UDim2.fromOffset(11, 22), UDim2.new(1, -22, 0, 13), Enum.Font.GothamMedium, GREEN, 8)
	label(info, "DISPOSITIVO: " .. deviceIcon(), UDim2.fromOffset(11, 38), UDim2.new(1, -22, 0, 13), Enum.Font.RobotoMono, MUTED, 8)
	label(info, "FPS: --   ·   PING: --", UDim2.fromOffset(11, 54), UDim2.new(1, -22, 0, 13), Enum.Font.RobotoMono, ACCENT, 8).Name = "Performance"
	local discord = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(88, 101, 242),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -111, 0, 7),
		Size = UDim2.fromOffset(100, 14),
		Text = "discord.gg/hqcNXBbet",
		TextColor3 = WHITE,
		TextSize = 7,
		ZIndex = 13,
	}, page)
	corner(discord, 5)
	discord.Activated:Connect(function()
		discord.Text = "DISCORD: hqcNXBbet"
	end)
end

local function showPage(pageName)
	state.page = pageName
	for name, frame in pairs(pageFrames) do frame.Visible = name == pageName end
	for name, nav in pairs(navButtons) do
		nav.BackgroundColor3 = name == pageName and ACCENT or Color3.fromRGB(12, 18, 28)
		nav.TextColor3 = name == pageName and Color3.fromRGB(7, 19, 29) or MUTED
	end
end

refreshPage = function()
	cleanContent()
	renderAimPage()
	renderEpsPage()
	renderFovPage()
	renderHitboxPage()
	renderPlayerPage()
	renderMiscPage()
	showPage(state.page)
	title.Text = t("title")
	local navKeys = {AIMBOT = "pageAim", EPS = "pageEps", FOV = "pageFov", HITBOX = "pageHitbox", PLAYER = "pagePlayer", MISC = "pageMisc"}
	for key, button in pairs(navButtons) do button.Text = t(navKeys[key]) end
end

local navOrder = {"AIMBOT", "EPS", "FOV", "HITBOX", "PLAYER", "MISC"}
for index, name in ipairs(navOrder) do
	local nav = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(12, 18, 28),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(8, 13 + (index - 1) * 46),
		Size = UDim2.new(1, -16, 0, 36),
		Text = name,
		TextColor3 = MUTED,
		TextSize = 9,
		ZIndex = 12,
	}, side)
	corner(nav, 9)
	stroke(nav, Color3.fromRGB(100, 138, 181), 1, 0.8)
	navButtons[name] = nav
	nav.Activated:Connect(function() showPage(name) end)
end

-- Ventana principal y contador arrastrables.
local function makeDraggable(handle, frame)
	local dragging, dragInput, startInput, startPosition = false, nil, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = input.Position
			startPosition = frame.Position
			dragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false; dragInput = nil end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput and startInput and startPosition then
			local delta = input.Position - startInput
			frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)
end

makeDraggable(topbar, root)
makeDraggable(hud, hud)

local fullPanelSize = UDim2.fromOffset(456, 380)
local miniPanelSize = UDim2.fromOffset(46, 46)
local panelAnimating = false
local panelMinimized = false
local panelTweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function minimizePanel()
	if panelAnimating or panelMinimized then return end
	panelAnimating = true
	panelMinimized = true
	minimizedButton.Position = root.Position
	local tween = TweenService:Create(root, panelTweenInfo, {Size = miniPanelSize})
	tween:Play()
	tween.Completed:Connect(function()
		root.Visible = false
		minimizedButton.Visible = true
		panelAnimating = false
	end)
end

local function restorePanel()
	if panelAnimating or not panelMinimized then return end
	panelAnimating = true
	panelMinimized = false
	root.Position = minimizedButton.Position
	root.Size = miniPanelSize
	root.Visible = true
	minimizedButton.Visible = false
	local tween = TweenService:Create(root, panelTweenInfo, {Size = fullPanelSize})
	tween:Play()
	tween.Completed:Connect(function()
		panelAnimating = false
	end)
end

logo.Activated:Connect(minimizePanel)
minimizedButton.Activated:Connect(restorePanel)
makeDraggable(minimizedButton, minimizedButton)

-- Visualización EPS en pantallas: no interviene en el sistema de daño del juego.
local visualFolder = create("Frame", {
	Name = "TwinGGXPT_Visuals",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 40,
}, gui)

local oldWorldVisuals = workspace:FindFirstChild("TwinGGXPT_WorldVisuals")
if oldWorldVisuals then oldWorldVisuals:Destroy() end
local worldVisuals = Instance.new("Folder")
worldVisuals.Name = "TwinGGXPT_WorldVisuals"
worldVisuals.Parent = workspace

local visuals = {}
local localHitboxBoxes = {}

local function destroyLocalHitboxBox(targetPlayer)
	local box = localHitboxBoxes[targetPlayer]
	if box then box:Destroy() end
	localHitboxBoxes[targetPlayer] = nil
end

local function updateLocalHitboxBox(targetPlayer, rootPart, visible)
	if not visible or not rootPart then
		destroyLocalHitboxBox(targetPlayer)
		return
	end
	local box = localHitboxBoxes[targetPlayer]
	if not box then
		box = Instance.new("BoxHandleAdornment")
		box.Name = "TGX_LocalHitbox_" .. targetPlayer.UserId
		box.AlwaysOnTop = true
		box.Color3 = ACCENT
		box.Transparency = 0.64
		box.ZIndex = 9
		box.Parent = worldVisuals
		localHitboxBoxes[targetPlayer] = box
	end
	box.Adornee = rootPart
	box.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
end

local ownHitboxAdornment
updateOwnHitboxVisual = function()
	local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not state.showOwnHitbox or not rootPart then
		if ownHitboxAdornment then
			ownHitboxAdornment:Destroy()
			ownHitboxAdornment = nil
		end
		return
	end
	if not ownHitboxAdornment then
		ownHitboxAdornment = Instance.new("BoxHandleAdornment")
		ownHitboxAdornment.Name = "TGX_MyHitboxVisual"
		ownHitboxAdornment.AlwaysOnTop = true
		ownHitboxAdornment.Color3 = Color3.fromRGB(255, 190, 72)
		ownHitboxAdornment.Transparency = 0.35
		ownHitboxAdornment.ZIndex = 10
		ownHitboxAdornment.Parent = worldVisuals
	end
	ownHitboxAdornment.Adornee = rootPart
	ownHitboxAdornment.Size = rootPart.Size
end

local function newLine(parent, thickness)
	local frame = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Size = UDim2.fromOffset(thickness, 0), Visible = false, ZIndex = 41}, parent)
	return frame
end

local function visualFor(targetPlayer)
	if visuals[targetPlayer] then return visuals[targetPlayer] end
	local container = create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 40}, visualFolder)
	local box = create("Frame", {BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 41}, container)
	stroke(box, ACCENT, 1.2, 0)
	local highlight = Instance.new("Highlight")
	highlight.Name = "TGX_Box_" .. targetPlayer.UserId
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 1
	highlight.OutlineColor = ACCENT
	highlight.OutlineTransparency = 0
	highlight.Enabled = false
	highlight.Parent = worldVisuals
	local tag = create("BillboardGui", {
		Name = "TGX_Tag_" .. targetPlayer.UserId,
		AlwaysOnTop = true,
		Enabled = false,
		LightInfluence = 0,
		MaxDistance = 10000,
		Size = UDim2.fromOffset(110, 30),
		StudsOffsetWorldSpace = Vector3.new(0, 2.7, 0),
	}, gui)
	local tagText = create("TextLabel", {
		BackgroundColor3 = Color3.fromRGB(8, 14, 23),
		BackgroundTransparency = 0.22,
		BorderSizePixel = 0,
		Font = Enum.Font.RobotoMono,
		Size = UDim2.fromScale(1, 1),
		TextColor3 = WHITE,
		TextScaled = false,
		TextSize = 10,
		TextWrapped = true,
		ZIndex = 44,
	}, tag)
	corner(tagText, 6)
	stroke(tagText, ACCENT, 1, 0.2)
	local healthBarGui = create("BillboardGui", {
		Name = "TGX_Health_" .. targetPlayer.UserId,
		AlwaysOnTop = true,
		Enabled = false,
		LightInfluence = 0,
		MaxDistance = 10000,
		Size = UDim2.fromOffset(13, 56),
		StudsOffsetWorldSpace = Vector3.new(1.25, 0, 0),
	}, gui)
	local healthBarBack = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(22, 26, 34),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(7, 49),
		ZIndex = 44,
	}, healthBarGui)
	corner(healthBarBack, 4)
	local healthBarFill = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = GREEN,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 45,
	}, healthBarBack)
	corner(healthBarFill, 4)
	local healthNumber = create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.RobotoMono,
		Position = UDim2.new(0.5, 0, 1, 1),
		Size = UDim2.fromOffset(38, 10),
		TextColor3 = WHITE,
		TextSize = 8,
		ZIndex = 45,
	}, healthBarGui)
	local distanceGui = create("BillboardGui", {
		Name = "TGX_Distance_" .. targetPlayer.UserId,
		AlwaysOnTop = true,
		Enabled = false,
		LightInfluence = 0,
		MaxDistance = 10000,
		Size = UDim2.fromOffset(104, 18),
		StudsOffsetWorldSpace = Vector3.new(0, -3.15, 0),
	}, gui)
	local distanceLabel = create("TextLabel", {
		BackgroundColor3 = Color3.fromRGB(8, 14, 23),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Font = Enum.Font.RobotoMono,
		Size = UDim2.fromScale(1, 1),
		TextColor3 = WHITE,
		TextSize = 9,
		ZIndex = 44,
	}, distanceGui)
	corner(distanceLabel, 6)
	local healthBack = create("Frame", {BackgroundColor3 = Color3.fromRGB(38, 42, 50), BorderSizePixel = 0, Visible = false, ZIndex = 42}, container)
	local healthFill = create("Frame", {BackgroundColor3 = GREEN, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 43}, healthBack)
	local healthText = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.RobotoMono, TextColor3 = WHITE, TextSize = 8, Visible = false, ZIndex = 43}, container)
	local distanceText = create("TextLabel", {BackgroundTransparency = 1, Font = Enum.Font.RobotoMono, TextColor3 = WHITE, TextSize = 9, Visible = false, ZIndex = 43}, container)
	local topLine = newLine(container, 1)
	local skeleton = {}
	for i = 1, 10 do skeleton[i] = newLine(container, 2) end
	visuals[targetPlayer] = {container = container, box = box, highlight = highlight, tag = tag, tagText = tagText, healthBarGui = healthBarGui, healthBarFill = healthBarFill, healthNumber = healthNumber, distanceGui = distanceGui, distanceLabel = distanceLabel, healthBack = healthBack, healthFill = healthFill, healthText = healthText, distanceText = distanceText, topLine = topLine, skeleton = skeleton}
	return visuals[targetPlayer]
end

local function setLine(frame, from, to, visible)
	if not visible then frame.Visible = false return end
	local delta = to - from
	if delta.Magnitude < 1 then frame.Visible = false return end
	frame.Visible = true
	frame.Position = UDim2.fromOffset(from.X + delta.X * 0.5, from.Y + delta.Y * 0.5)
	frame.Size = UDim2.fromOffset(frame.Size.X.Offset, delta.Magnitude)
	frame.Rotation = math.deg(math.atan2(delta.Y, delta.X)) - 90
end

local r15SkeletonLinks = {
	{{"Head"}, {"UpperTorso"}}, {{"UpperTorso"}, {"LowerTorso"}},
	{{"UpperTorso"}, {"LeftUpperArm"}}, {{"LeftUpperArm"}, {"LeftLowerArm"}},
	{{"UpperTorso"}, {"RightUpperArm"}}, {{"RightUpperArm"}, {"RightLowerArm"}},
	{{"LowerTorso"}, {"LeftUpperLeg"}}, {{"LeftUpperLeg"}, {"LeftLowerLeg"}},
	{{"LowerTorso"}, {"RightUpperLeg"}}, {{"RightUpperLeg"}, {"RightLowerLeg"}},
}

local r6SkeletonLinks = {
	{{"Head"}, {"Torso"}}, {{"Torso"}, {"Left Arm"}}, {{"Torso"}, {"Right Arm"}},
	{{"Torso"}, {"Left Leg"}}, {{"Torso"}, {"Right Leg"}},
}

local function findRigPart(character, names)
	for _, name in ipairs(names) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then return part end
	end
	return nil
end

local function getSkeletonLinks(character)
	return character:FindFirstChild("UpperTorso") and r15SkeletonLinks or r6SkeletonLinks
end

local fpsFrames, fpsLast, fps = 0, os.clock(), 0
local lastAimRetargetAt = 0

local function targetCanReceiveAssist(camera, targetPlayer)
	return getAimCandidate(camera, targetPlayer)
end

local function updateFrame(deltaTime)
	applyPlayerMovement()
	if state.noclip then applyNoclip() end
	fpsFrames = fpsFrames + 1
	local now = os.clock()
	if now - fpsLast >= 0.5 then fps = math.floor(fpsFrames / (now - fpsLast)); fpsFrames = 0; fpsLast = now end

	local camera = workspace.CurrentCamera
	if not camera then return end
	local center = fovCenter(camera)
	fovCircle.Position = UDim2.fromOffset(center.X, center.Y)
	hudText.Text = (state.language == "ES" and "JUGADORES: " or state.language == "PT" and "JOGADORES: " or "PLAYERS: ") .. #Players:GetPlayers()
	local performance = content:FindFirstChild("Performance", true)
	local targetStatus = content:FindFirstChild("TargetName", true)
	if targetStatus then
		targetStatus.Text = state.selectedTarget and (t("target") .. ": " .. state.selectedTarget.DisplayName) or t("noTarget")
	end
	if performance then
		local ping = "--"
		pcall(function() ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms" end)
		performance.Text = "FPS: " .. fps .. "   ·   PING: " .. ping
	end

	updateOwnHitboxVisual()
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			local visual = visualFor(targetPlayer)
			local character, humanoid, rootPart, head = getPlayerParts(targetPlayer)
			local visible = character and isValidTarget(targetPlayer)
			updateLocalHitboxBox(targetPlayer, rootPart, visible and state.hitboxVisible)
			visual.highlight.Adornee = character
			visual.highlight.Enabled = visible and state.epsBoxes
			visual.tag.Enabled = false
			visual.healthBarGui.Adornee = rootPart
			visual.healthBarGui.Enabled = visible and state.epsHealth
			if visual.healthBarGui.Enabled then
				local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
				visual.healthBarFill.Size = UDim2.new(1, 0, ratio, 0)
				visual.healthBarFill.BackgroundColor3 = ratio > 0.55 and GREEN or (ratio > 0.25 and Color3.fromRGB(246, 183, 65) or RED)
				visual.healthNumber.Text = math.floor(humanoid.Health) .. " HP"
			end
			visual.distanceGui.Adornee = rootPart
			visual.distanceGui.Enabled = visible and state.epsDistance
			if visual.distanceGui.Enabled then
				local ownRoot = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart)
				visual.distanceLabel.Text = (ownRoot and math.floor((ownRoot.Position - rootPart.Position).Magnitude) or 0) .. " m"
			end
			local headScreen, headOn = visible and camera:WorldToViewportPoint(head.Position) or nil, false
			if visible then _, headOn = camera:WorldToViewportPoint(head.Position) end
			local rootScreen, rootOn = visible and camera:WorldToViewportPoint(rootPart.Position) or nil, false
			if visible then _, rootOn = camera:WorldToViewportPoint(rootPart.Position) end
			local active = visible and headOn and rootOn
			local width, height = 0, 0
			if active then
				height = math.abs(rootScreen.Y - headScreen.Y) * 1.35
				width = height * 0.52
			end
			-- El Highlight es el recuadro persistente. Este recuadro 2D se conserva como refuerzo cuando está en pantalla.
			visual.box.Visible = active and state.epsBoxes
			if visual.box.Visible then
				visual.box.Position = UDim2.fromOffset(rootScreen.X - width * 0.5, headScreen.Y - height * 0.08)
				visual.box.Size = UDim2.fromOffset(width, height)
			end
			setLine(visual.topLine, Vector2.new(camera.ViewportSize.X * 0.5, 0), active and Vector2.new(headScreen.X, headScreen.Y) or Vector2.zero, active and state.epsLines)
			visual.healthBack.Visible = false
			visual.healthText.Visible = false
			if visual.healthBack.Visible then
				local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
				visual.healthBack.Position = UDim2.fromOffset(rootScreen.X + width * 0.5 + 5, headScreen.Y - height * 0.08)
				visual.healthBack.Size = UDim2.fromOffset(4, height)
				visual.healthFill.Size = UDim2.new(1, 0, ratio, 0)
				visual.healthFill.Position = UDim2.new(0, 0, 1 - ratio, 0)
				visual.healthText.Position = UDim2.fromOffset(rootScreen.X + width * 0.5 + 12, headScreen.Y - height * 0.08)
				visual.healthText.Size = UDim2.fromOffset(32, 12)
				visual.healthText.Text = math.floor(humanoid.Health) .. " HP"
			end
			visual.distanceText.Visible = false
			if visual.distanceText.Visible then
				local ownRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local meters = ownRoot and math.floor((ownRoot.Position - rootPart.Position).Magnitude) or 0
				visual.distanceText.Position = UDim2.fromOffset(rootScreen.X - 43, rootScreen.Y + 5)
				visual.distanceText.Size = UDim2.fromOffset(86, 13)
				visual.distanceText.Text = meters .. " m"
			end
			local activeSkeletonLinks = character and getSkeletonLinks(character) or {}
			for index, link in ipairs(activeSkeletonLinks) do
				local a, b = character and findRigPart(character, link[1]), character and findRigPart(character, link[2])
				if active and state.epsSkeleton and a and b then
					local aScreen, aOn = camera:WorldToViewportPoint(a.Position)
					local bScreen, bOn = camera:WorldToViewportPoint(b.Position)
					setLine(visual.skeleton[index], Vector2.new(aScreen.X, aScreen.Y), Vector2.new(bScreen.X, bScreen.Y), aOn and bOn)
				else
					visual.skeleton[index].Visible = false
				end
			end
			for index = #activeSkeletonLinks + 1, #visual.skeleton do visual.skeleton[index].Visible = false end
		end
	end

	-- La asistencia solo mueve suavemente la cámara hacia un objetivo visible dentro del FOV.
	if state.aimBeta or state.aimLock then
		local target
		if state.aimLock then
			-- LOCK persigue de forma continua al objetivo visible más cercano dentro del FOV.
			if os.clock() - lastAimRetargetAt >= CONFIG.AimRetargetCooldown then
				state.selectedTarget = findClosestTarget(false)
				lastAimRetargetAt = os.clock()
			end
			target = state.selectedTarget
		else
			-- BETA conserva el objetivo elegido con CAMBIAR OBJETIVO;
			-- sin objetivo elegido, asiste al más cercano visible dentro del FOV.
			local chosen = state.betaTarget
			target = targetCanReceiveAssist(camera, chosen) and chosen or findClosestTarget(false)
			if not targetCanReceiveAssist(camera, chosen) then state.betaTarget = nil end
		end
		local character, rootPart, head = targetCanReceiveAssist(camera, target)
		if not target or not character then
			if state.aimLock then state.selectedTarget = nil else state.betaTarget = nil end
		else
			local predictedPoint = head.Position + rootPart.AssemblyLinearVelocity * CONFIG.AimLeadSeconds
			local desired = CFrame.lookAt(camera.CFrame.Position, predictedPoint)
			local baseSmoothness = state.aimLock and CONFIG.AimLockSmoothness or CONFIG.AimBetaSmoothness
			local smoothness = 1 - (1 - baseSmoothness) ^ math.clamp((deltaTime or 1 / 60) * 60, 0.25, 2)
			camera.CFrame = camera.CFrame:Lerp(desired, smoothness)
		end
	end
end

RunService:UnbindFromRenderStep("TwinGGXPT_AimAssist")
RunService:BindToRenderStep("TwinGGXPT_AimAssist", Enum.RenderPriority.Camera.Value + 1, updateFrame)

Players.PlayerRemoving:Connect(function(leaving)
	if visuals[leaving] then
		visuals[leaving].container:Destroy()
		visuals[leaving].highlight:Destroy()
		visuals[leaving].tag:Destroy()
		visuals[leaving].healthBarGui:Destroy()
		visuals[leaving].distanceGui:Destroy()
		visuals[leaving] = nil
	end
	destroyLocalHitboxBox(leaving)
	if state.selectedTarget == leaving then state.selectedTarget = nil end
end)

refreshPage()


-- Inicio directo de Twin GG XPT, sin pantalla ni validación de key.
gui.Enabled = true

-- Bucle principal del expansor de Hitbox aportado por el usuario.
-- La GUI solo actualiza isHitboxActive, hitboxSize y showVisualBox.
restoreLocalHitboxExpander = function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Size = Vector3.new(2, 2, 1)
				hrp.Transparency = 1
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	-- Aplicar únicamente al jugador local; conservar la actualización del expansor remoto aparte.
	updateLocalOwnHitbox(state.smallOwnHitbox)
	if not isHitboxActive then return end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			
			if hrp then
				-- Modificar el tamaño y evitar que cause colisiones molestas al caminar
				hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
				hrp.CanCollide = false
				
				-- Control visual de la hitbox
				if showVisualBox then
					hrp.Transparency = 0.6
					hrp.Color = Color3.fromRGB(255, 0, 0)
					hrp.Material = Enum.Material.Neon
				else
					hrp.Transparency = 1
				end
			end
		end
	end
end)
