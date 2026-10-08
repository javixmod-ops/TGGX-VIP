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
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local DEFAULT_ACCENT = Color3.fromRGB(70, 199, 255)

local CONFIG = {
	MaxFovRadius = 360,
	MinFovRadius = 70,
	TargetTeammates = false,
	RequireLineOfSight = true,
	AimSmoothness = 0.12,
	AimDirectness = 0.55,
	AimLeadSeconds = 0.02,
	AimRetargetCooldown = 0.30,
	MinCameraFov = 40,
	MaxCameraFov = 120,
	HitboxMinSize = 5,
	HitboxMaxSize = 50,
	HitboxDefaultSize = 10,
}

local state = {
	page = "AIMBOT",
	language = "ES",
	aimEnabled = false,
	aimNotifications = true,
	smoothAim = true,
	cameraFov = 70,
	cameraFovSet = false,
	showFov = true,
	fovRadius = 175,
	epsLines = false,
	epsBoxes = false,
	epsSkeleton = false,
	epsHealth = false,
	epsDistance = false,
	epsNearestLine = false,
	selectedTarget = nil,
	accentColor = DEFAULT_ACCENT,
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
	musicVolume = 0.5,
	currentMusicId = "",
	currentMusicName = "",
}

-- El Sound se crea desde este LocalScript y vive en SoundService solo en este cliente.
local previousMusic = SoundService:FindFirstChild("TwinGGXPT_LocalMusic")
if previousMusic then
	if previousMusic:IsA("Sound") then previousMusic:Stop() end
	previousMusic:Destroy()
end
local localMusicSound = Instance.new("Sound")
localMusicSound.Name = "TwinGGXPT_LocalMusic"
localMusicSound.Volume = state.musicVolume
localMusicSound.Looped = false
localMusicSound.Parent = SoundService
local musicPlayButton
local function updateMusicPlayButton()
	if musicPlayButton and musicPlayButton.Parent then
		musicPlayButton.Text = localMusicSound.IsPlaying and "DETENER MÚSICA" or "PONER MÚSICA"
	end
end
localMusicSound.Ended:Connect(updateMusicPlayButton)

-- Variables del expansor LocalScript aportado. La pestaña HITBOX las controla directamente.
local isHitboxActive = true
local hitboxSize = 10
local showVisualBox = true
local LOCAL_HITBOX_MODE = true
local restoreLocalHitboxExpander

local translations = {
	ES = {
		title = "TWIN GG XPT",
		pageAim = "AIMBOT", pageEps = "EPS", pageFov = "FOV", pageHitbox = "HITBOX", pagePlayer = "PLAYER", pageMisc = "MISC", pageMusic = "MÚSICA", pageColors = "COLORES",
		aimAssist = "AIMBOT ÚNICO", notifications = "NOTIFI UI", smoothAim = "SEGUIMIENTO SUAVE",
		line = "LÍNEAS EPS", box = "CUADRADO EPS", skeleton = "EPS ESQUELETO",
		nearestLine = "LÍNEA CUERPO A CUERPO",
		health = "EPS VIDA", distance = "EPS METROS", counter = "CONTADOR DE JUGADORES",
		visible = "FOV VISIBLE", radius = "RADIO DEL FOV", cameraFov = "FOV CÁMARA", language = "IDIOMA",
		made = "HECHO POR EL DESARROLLADOR: JXVI", mode = "GUI MOD: ACTIVADO ✅",
		noTarget = "SIN OBJETIVO", target = "OBJETIVO", aimLocked = "BLOQUEO A UN OBJETIVO", aimLostWall = "SE DEJÓ DE SEGUIR: DETRÁS DE UNA PARED", aimHint = "OBJETIVO MÁS CERCANO · DENTRO DEL FOV · SIN PAREDES",
		hitbox = "HITBOX EXPANDER", showHitbox = "MOSTRAR HITBOX", smallOwnHitbox = "HITBOX MÍNIMA", ownHitboxSize = "TAMAÑO PROPIO", showOwnHitbox = "VER MI HITBOX", hitboxSize = "TAMAÑO DE HITBOX",
		speed = "VELOCIDAD", resetSpeed = "RESET VELOCIDAD", superJump = "SUPER SALTO", resetJump = "RESET SUPER SALTO", noclip = "NOCLIP", antiLag = "ANTI LAG",
	},
	EN = {
		title = "TWIN GG XPT",
		pageAim = "AIM ASSIST", pageEps = "ESP", pageFov = "FOV", pageHitbox = "HITBOX", pagePlayer = "PLAYER", pageMisc = "MISC", pageMusic = "MUSIC", pageColors = "COLORS",
		aimAssist = "SINGLE AIM ASSIST", notifications = "UI NOTIFICATIONS", smoothAim = "SMOOTH AIM",
		line = "ESP LINES", box = "ESP BOX", skeleton = "ESP SKELETON",
		nearestLine = "LINE TO NEAREST TARGET",
		health = "ESP HEALTH", distance = "ESP DISTANCE", counter = "PLAYER COUNTER",
		visible = "SHOW FOV", radius = "FOV RADIUS", cameraFov = "CAMERA FOV", language = "LANGUAGE",
		made = "MADE BY THE DEVELOPER: JXVI", mode = "GUI MODE: ENABLED ✅",
		noTarget = "NO TARGET", target = "TARGET", aimLocked = "LOCKED ON TARGET", aimLostWall = "STOPPED: TARGET BEHIND WALL", aimHint = "NEAREST TARGET · INSIDE FOV · NO WALLS",
		hitbox = "HITBOX EXPANDER", showHitbox = "SHOW HITBOX", smallOwnHitbox = "TINY SELF HITBOX", ownHitboxSize = "OWN HITBOX SIZE", showOwnHitbox = "SHOW MY HITBOX", hitboxSize = "HITBOX SIZE",
		speed = "SPEED", resetSpeed = "RESET SPEED", superJump = "SUPER JUMP", resetJump = "RESET JUMP", noclip = "NOCLIP", antiLag = "LOW GRAPHICS",
	},
	PT = {
		title = "TWIN GG XPT",
		pageAim = "MIRA", pageEps = "ESP", pageFov = "FOV", pageHitbox = "HITBOX", pagePlayer = "PLAYER", pageMisc = "MISC", pageMusic = "MÚSICA", pageColors = "CORES",
		aimAssist = "MIRA ASSISTIDA ÚNICA", notifications = "NOTIFICAÇÕES UI", smoothAim = "RASTREAMENTO SUAVE",
		line = "LINHAS ESP", box = "QUADRO ESP", skeleton = "ESQUELETO ESP",
		nearestLine = "LINHA AO ALVO MAIS PRÓXIMO",
		health = "VIDA ESP", distance = "DISTÂNCIA ESP", counter = "CONTADOR DE JOGADORES",
		visible = "FOV VISÍVEL", radius = "RAIO DO FOV", cameraFov = "FOV DA CÂMERA", language = "IDIOMA",
		made = "FEITO PELO DESENVOLVEDOR: JXVI", mode = "MODO GUI: ATIVADO ✅",
		noTarget = "SEM ALVO", target = "ALVO", aimLocked = "ALVO BLOQUEADO", aimLostWall = "PAROU: ALVO ATRÁS DE UMA PAREDE", aimHint = "ALVO VISÍVEL MAIS PRÓXIMO DENTRO DO FOV",
		hitbox = "EXPANSOR DE HITBOX", showHitbox = "MOSTRAR HITBOX", smallOwnHitbox = "HITBOX MÍNIMA", ownHitboxSize = "TAMANHO PRÓPRIO", showOwnHitbox = "VER MINHA HITBOX", hitboxSize = "TAMANHO DA HITBOX",
		speed = "VELOCIDADE", resetSpeed = "RESET VELOCIDADE", superJump = "SUPER PULO", resetJump = "RESET PULO", noclip = "NOCLIP", antiLag = "ANTI LAG",
	},
}

local old = playerGui:FindFirstChild("TwinGGXPT")
if old then old:Destroy() end

local function t(key)
	return translations[state.language][key] or key
end

local npcCharacterCache = setmetatable({}, {__mode = "k"})
local npcCatalogReady = false
local npcCatalogScanning = false
local function registerNpcHumanoid(humanoid)
	if not humanoid:IsA("Humanoid") then return end
	local model = humanoid.Parent
	if model and model:IsA("Model") then npcCharacterCache[model] = true end
end
workspace.DescendantAdded:Connect(function(instance)
	if instance:IsA("Humanoid") then task.defer(registerNpcHumanoid, instance) end
end)
workspace.DescendantRemoving:Connect(function(instance)
	if instance:IsA("Model") then npcCharacterCache[instance] = nil end
end)
local function ensureNpcCatalog()
	if npcCatalogReady or npcCatalogScanning then return end
	npcCatalogScanning = true
	task.spawn(function()
		local descendants = workspace:GetDescendants()
		for index, instance in ipairs(descendants) do
			if instance:IsA("Humanoid") then registerNpcHumanoid(instance) end
			if index % 500 == 0 then task.wait() end
		end
		npcCatalogReady = true
		npcCatalogScanning = false
	end)
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
local ACCENT = state.accentColor
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
local worldVisuals
local colorPickerRoot
local hitboxAdjustOverlay
local hitboxAdjustText
local hitboxAdjustSpinner
local hitboxAdjustToken = 0
local beginHitboxAdjustment
local finishHitboxAdjustment

local function getAccentTextColor(color)
	local luminance = color.R * 0.299 + color.G * 0.587 + color.B * 0.114
	return luminance > 0.58 and Color3.fromRGB(8, 17, 28) or WHITE
end

local function applyAccentColor(color)
	if typeof(color) ~= "Color3" then return end
	local previousAccent = ACCENT
	ACCENT = color
	state.accentColor = color
	local function updateRoot(rootObject)
		if not rootObject then return end
		for _, item in ipairs(rootObject:GetDescendants()) do
			local isPickerItem = colorPickerRoot and (item == colorPickerRoot or item:IsDescendantOf(colorPickerRoot))
			if not isPickerItem then
				if item:IsA("UIStroke") then
					if item.Color == previousAccent then item.Color = color end
				elseif item:IsA("GuiObject") then
					local hadAccentBackground = item.BackgroundColor3 == previousAccent
					if hadAccentBackground then item.BackgroundColor3 = color end
					if item.BorderColor3 == previousAccent then item.BorderColor3 = color end
					if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
						if item.TextColor3 == previousAccent then item.TextColor3 = color end
						if hadAccentBackground and item:IsA("TextButton") then item.TextColor3 = getAccentTextColor(color) end
					end
					if item:IsA("ImageLabel") or item:IsA("ImageButton") then
						if item.ImageColor3 == previousAccent then item.ImageColor3 = color end
					end
				elseif item:IsA("Highlight") then
					if item.OutlineColor == previousAccent then item.OutlineColor = color end
					if item.FillColor == previousAccent then item.FillColor = color end
				elseif item:IsA("BoxHandleAdornment") then
					if item.Color3 == previousAccent then item.Color3 = color end
				elseif item:IsA("UIGradient") then
					local points, changed = {}, false
					for _, point in ipairs(item.Color.Keypoints) do
						local pointColor = point.Value
						if pointColor == previousAccent then pointColor = color; changed = true end
						points[#points + 1] = ColorSequenceKeypoint.new(point.Time, pointColor)
					end
					if changed then item.Color = ColorSequence.new(points) end
				end
			end
		end
	end
	updateRoot(gui)
	updateRoot(worldVisuals)
end

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

local aimToast = create("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = SURFACE_2,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -16, 0, 16),
	Size = UDim2.fromOffset(300, 54),
	Visible = false,
	ZIndex = 230,
}, gui)
corner(aimToast, 10)
local aimToastStroke = stroke(aimToast, ACCENT, 1.2, 1)
local aimToastText = create("TextLabel", {
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Position = UDim2.fromOffset(12, 5),
	Size = UDim2.new(1, -24, 1, -10),
	Text = "",
	TextColor3 = WHITE,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
	TextTransparency = 1,
	ZIndex = 231,
}, aimToast)
local aimToastToken = 0
local function showAimNotification(message, color)
	if not state.aimNotifications then return end
	aimToastToken += 1
	local token = aimToastToken
	aimToastText.Text = message
	aimToastStroke.Color = color or ACCENT
	aimToast.Visible = true
	aimToast.BackgroundTransparency = 1
	aimToastText.TextTransparency = 1
	aimToastStroke.Transparency = 1
	TweenService:Create(aimToast, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.10}):Play()
	TweenService:Create(aimToastText, TweenInfo.new(0.16), {TextTransparency = 0}):Play()
	TweenService:Create(aimToastStroke, TweenInfo.new(0.16), {Transparency = 0.1}):Play()
	task.delay(2.2, function()
		if token ~= aimToastToken or not aimToast.Parent then return end
		local fade = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local frameTween = TweenService:Create(aimToast, fade, {BackgroundTransparency = 1})
		TweenService:Create(aimToastText, fade, {TextTransparency = 1}):Play()
		TweenService:Create(aimToastStroke, fade, {Transparency = 1}):Play()
		frameTween.Completed:Connect(function()
			if token == aimToastToken then aimToast.Visible = false end
		end)
		frameTween:Play()
	end)
end

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
create("Frame", {
	Name = "MenuBackground",
	Active = false,
	BackgroundColor3 = SURFACE,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0, 0),
	Size = UDim2.fromScale(1, 1),
	ZIndex = 11,
}, root)

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
	if not camera or not targetPlayer then return nil, nil, nil, nil, "invalid" end
	-- No usar `targetPlayer and getPlayerParts(...)`: el operador `and` colapsa
	-- los retornos múltiples y dejaba rootPart/head en nil, rompiendo todo el selector.
	local character, _, rootPart, head = getPlayerParts(targetPlayer)
	if not character or not rootPart or not head or not isValidTarget(targetPlayer) then
		return nil, nil, nil, nil, "invalid"
	end
	local projected, onScreen = camera:WorldToViewportPoint(head.Position)
	if not onScreen or projected.Z <= 0 then return nil, nil, nil, nil, "offscreen" end
	local guiPoint = viewportToGuiPoint(camera, projected)
	if (guiPoint - fovCenter(camera)).Magnitude > state.fovRadius then
		return nil, nil, nil, nil, "outside_fov"
	end
	if not lineOfSight(character, head.Position) then return nil, nil, nil, nil, "occluded" end
	return character, rootPart, head, guiPoint, nil
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

local nextAimAcquireAt = 0

local function renderAimPage()
	local page = makePage("AIMBOT")
	sectionTitle(page, t("pageAim"), "ASISTENCIA DE MIRA · UN OBJETIVO VISIBLE")
	toggle(page, 72, t("aimAssist"), function() return state.aimEnabled end, function(value)
		state.aimEnabled = value
		state.selectedTarget = nil
		nextAimAcquireAt = 0
		if value then
			local target = findClosestTarget(false)
			if target then
				state.selectedTarget = target
				showAimNotification(t("aimLocked") .. ": " .. target.DisplayName, GREEN)
			end
		end
	end)
	toggle(page, 109, t("notifications"), function() return state.aimNotifications end, function(value)
		state.aimNotifications = value
		if not value then aimToast.Visible = false end
	end)
	toggle(page, 146, t("smoothAim"), function() return state.smoothAim end, function(value)
		state.smoothAim = value
	end)

	local targetPanel = create("Frame", {
		BackgroundColor3 = SURFACE_2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 186),
		Size = UDim2.new(1, -32, 0, 80),
		ZIndex = 12,
	}, page)
	corner(targetPanel, 11)
	stroke(targetPanel, ACCENT, 1, 0.65)
	local targetName = label(targetPanel, t("noTarget"), UDim2.fromOffset(12, 10), UDim2.new(1, -24, 0, 21), Enum.Font.GothamBold, WHITE, 12)
	targetName.Name = "TargetName"
	label(targetPanel, t("aimHint"), UDim2.fromOffset(12, 37), UDim2.new(1, -24, 0, 28), Enum.Font.RobotoMono, MUTED, 7)
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
	toggle(page, 264, t("nearestLine"), function() return state.epsNearestLine end, function(value)
		state.epsNearestLine = value
		if value then ensureNpcCatalog() end
	end)
	label(page, "TRAZA DESDE TU CUERPO AL JUGADOR/BOT MÁS CERCANO.", UDim2.fromOffset(16, 297), UDim2.new(1, -32, 0, 20), Enum.Font.RobotoMono, MUTED, 7)
end

local function setFovRadius(radius)
	state.fovRadius = math.clamp(math.floor(radius), CONFIG.MinFovRadius, CONFIG.MaxFovRadius)
	fovCircle.Size = UDim2.fromOffset(state.fovRadius * 2, state.fovRadius * 2)
end

local function renderFovPage()
	local page = makePage("FOV")
	sectionTitle(page, "FOV", "CÍRCULO DE ASISTENCIA Y ÁNGULO DE CÁMARA")
	toggle(page, 70, t("visible"), function() return state.showFov end, function(value)
		state.showFov = value
		fovCircle.Visible = value
	end)

	local function addSlider(titleY, barY, titleText, minValue, maxValue, currentValue, suffix, onChanged)
		label(page, titleText, UDim2.fromOffset(16, titleY), UDim2.new(1, -88, 0, 19), Enum.Font.GothamMedium, WHITE, 10)
		local valueText = label(page, tostring(currentValue) .. suffix, UDim2.new(1, -72, 0, titleY), UDim2.fromOffset(56, 19), Enum.Font.RobotoMono, ACCENT, 9)
		valueText.TextXAlignment = Enum.TextXAlignment.Right
		local bar = create("Frame", {
			Active = true,
			BackgroundColor3 = Color3.fromRGB(56, 70, 92),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(16, barY),
			Size = UDim2.new(1, -32, 0, 8),
			ZIndex = 12,
		}, page)
		corner(bar, 8)
		local initialRatio = math.clamp((currentValue - minValue) / (maxValue - minValue), 0, 1)
		local fill = create("Frame", {
			BackgroundColor3 = ACCENT,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(initialRatio, 1),
			ZIndex = 13,
		}, bar)
		corner(fill, 8)
		local handle = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(initialRatio, 0.5),
			Size = UDim2.fromOffset(16, 16),
			ZIndex = 14,
		}, bar)
		corner(handle, 16)
		local changing = false
		local function setFromInput(input)
			if bar.AbsoluteSize.X <= 0 then return end
			local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			local value = math.floor(minValue + (maxValue - minValue) * ratio + 0.5)
			value = math.clamp(value, minValue, maxValue)
			local normalized = (value - minValue) / (maxValue - minValue)
			onChanged(value)
			fill.Size = UDim2.fromScale(normalized, 1)
			handle.Position = UDim2.fromScale(normalized, 0.5)
			valueText.Text = tostring(value) .. suffix
		end
		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				changing = true
				setFromInput(input)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if changing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				setFromInput(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then changing = false end
		end)
	end

	addSlider(112, 143, t("radius"), CONFIG.MinFovRadius, CONFIG.MaxFovRadius, state.fovRadius, " px", setFovRadius)
	label(page, "SOLO ADQUIERE UN OBJETIVO DENTRO DEL CÍRCULO Y CON LÍNEA DE VISIÓN.", UDim2.fromOffset(16, 162), UDim2.new(1, -32, 0, 26), Enum.Font.RobotoMono, MUTED, 7)

	local camera = workspace.CurrentCamera
	if camera then
		state.cameraFov = math.clamp(math.floor(camera.FieldOfView + 0.5), CONFIG.MinCameraFov, CONFIG.MaxCameraFov)
	end
	addSlider(198, 229, t("cameraFov"), CONFIG.MinCameraFov, CONFIG.MaxCameraFov, state.cameraFov, "°", function(value)
		state.cameraFov = value
		state.cameraFovSet = true
		local currentCamera = workspace.CurrentCamera
		if currentCamera then currentCamera.FieldOfView = value end
	end)
	label(page, "FOV DE CÁMARA CAMBIA EL ÁNGULO DE VISTA, NO LA DISTANCIA MÁXIMA DEL MAPA.", UDim2.fromOffset(16, 247), UDim2.new(1, -32, 0, 34), Enum.Font.RobotoMono, MUTED, 7)
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

-- IDs de audio del Creator Store mostrados gratuitos/publicados por el API oficial
-- el 2026-10-08; permisos, moderación o disponibilidad pueden cambiar después.
-- Títulos abreviados para que quepan en la lista.
local MUSIC_PRESETS = {
	{title = "Relaxed Scene", id = "1848354536"},
	{title = "Raining Tacos", id = "142376088"},
	{title = "Life in an Elevator", id = "1841647093"},
	{title = "Scary Background Music", id = "134959834418523"},
	{title = "Tender Static · Rhodes y bajo", id = "139132289200391"},
	{title = "Morning Mood · Peer Gynt", id = "1846088038"},
	{title = "Ghost Protocol", id = "140658568629873"},
	{title = "Scary Horror Cinematic", id = "138890398994853"},
	{title = "Town Talk", id = "1845756489"},
	{title = "Winding Down · LoFi", id = "140722099430139"},
}

local function renderMusicPage()
	local page = makePage("MUSIC")
	sectionTitle(page, t("pageMusic"), "AUDIO LOCAL · SOLO TÚ LO ESCUCHAS")

	local playButton = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(39, 119, 91),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(16, 61),
		Size = UDim2.new(1, -32, 0, 27),
		Text = "PONER MÚSICA",
		TextColor3 = WHITE,
		TextSize = 9,
		ZIndex = 13,
	}, page)
	corner(playButton, 8)
	musicPlayButton = playButton

	local status = label(page, "ELIGE UNA PISTA · SI NO CARGA, REVISA PERMISOS", UDim2.fromOffset(16, 91), UDim2.new(1, -32, 0, 14), Enum.Font.RobotoMono, MUTED, 7)
	status.Name = "MusicStatus"
	local playbackRequest = 0
	local function playMusicNow(displayName)
		playbackRequest += 1
		local thisRequest = playbackRequest
		localMusicSound.Volume = state.musicVolume
		local ok = pcall(function() localMusicSound:Play() end)
		if not ok then
			status.Text = "NO SE PUDO INICIAR · REVISA ID/PERMISOS"
			status.TextColor3 = RED
			updateMusicPlayButton()
			return
		end
		status.Text = "CARGANDO: " .. displayName
		status.TextColor3 = ACCENT
		updateMusicPlayButton()
		task.spawn(function()
			local deadline = os.clock() + 8
			while playbackRequest == thisRequest and not localMusicSound.IsLoaded and os.clock() < deadline do
				task.wait(0.1)
			end
			if playbackRequest ~= thisRequest or not status.Parent then return end
			if localMusicSound.IsLoaded and localMusicSound.IsPlaying then
				status.Text = "REPRODUCIENDO: " .. displayName
				status.TextColor3 = GREEN
			else
				if localMusicSound.IsPlaying then localMusicSound:Stop() end
				status.Text = "NO CARGÓ · REVISA ID, PERMISOS O DISPONIBILIDAD"
				status.TextColor3 = RED
				updateMusicPlayButton()
			end
		end)
	end
	local volumeText = label(page, "VOLUMEN: " .. math.floor(state.musicVolume * 100 + 0.5) .. "%", UDim2.fromOffset(16, 106), UDim2.new(1, -32, 0, 14), Enum.Font.GothamMedium, WHITE, 9)
	local volumeBar = create("Frame", {
		Active = true,
		BackgroundColor3 = Color3.fromRGB(56, 70, 92),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 123),
		Size = UDim2.new(1, -32, 0, 8),
		ZIndex = 12,
	}, page)
	corner(volumeBar, 8)
	local volumeFill = create("Frame", {
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(state.musicVolume, 1),
		ZIndex = 13,
	}, volumeBar)
	corner(volumeFill, 8)
	local volumeKnob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(state.musicVolume, 0.5),
		Size = UDim2.fromOffset(16, 16),
		ZIndex = 14,
	}, volumeBar)
	corner(volumeKnob, 16)
	local draggingVolume = false
	local function setVolumeFromX(x)
		if volumeBar.AbsoluteSize.X <= 0 then return end
		local volume = math.clamp((x - volumeBar.AbsolutePosition.X) / volumeBar.AbsoluteSize.X, 0, 1)
		state.musicVolume = volume
		localMusicSound.Volume = volume
		volumeFill.Size = UDim2.fromScale(volume, 1)
		volumeKnob.Position = UDim2.fromScale(volume, 0.5)
		volumeText.Text = "VOLUMEN: " .. math.floor(volume * 100 + 0.5) .. "%"
	end
	volumeBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingVolume = true
			setVolumeFromX(input.Position.X)
		end
	end)
	local volumeChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if draggingVolume and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setVolumeFromX(input.Position.X)
		end
	end)
	local volumeEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingVolume = false
		end
	end)
	page.Destroying:Connect(function()
		volumeChangedConnection:Disconnect()
		volumeEndedConnection:Disconnect()
	end)

	local idInput = create("TextBox", {
		BackgroundColor3 = SURFACE_2,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.RobotoMono,
		PlaceholderColor3 = MUTED,
		PlaceholderText = "ID numérico del audio de Roblox",
		Position = UDim2.fromOffset(16, 139),
		Size = UDim2.new(1, -32, 0, 24),
		Text = "",
		TextColor3 = WHITE,
		TextSize = 8,
		ZIndex = 13,
	}, page)
	corner(idInput, 7)
	local prepareIdButton = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = SURFACE_2,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(16, 166),
		Size = UDim2.fromOffset(104, 22),
		Text = "REPRODUCIR",
		TextColor3 = WHITE,
		TextSize = 8,
		ZIndex = 13,
	}, page)
	corner(prepareIdButton, 7)
	prepareIdButton.Activated:Connect(function()
		local assetId = idInput.Text:match("^%s*(%d+)%s*$")
		if not assetId or assetId == "0" then
			status.Text = "ESCRIBE UN ID NUMÉRICO VÁLIDO"
			status.TextColor3 = RED
			return
		end
		playbackRequest += 1
		if localMusicSound.IsPlaying then localMusicSound:Stop() end
		state.currentMusicId = assetId
		state.currentMusicName = "AUDIO PERSONALIZADO"
		localMusicSound.SoundId = "rbxassetid://" .. assetId
		localMusicSound.Volume = state.musicVolume
		status.Text = "ID PREPARADO · PULSA PONER MÚSICA PARA OÍRLO"
		status.TextColor3 = ACCENT
		updateMusicPlayButton()
	end)
	label(page, "EL ID SE PREPARA AQUÍ; EL BOTÓN SUPERIOR INICIA O DETIENE EL AUDIO.", UDim2.fromOffset(128, 166), UDim2.new(1, -144, 0, 23), Enum.Font.RobotoMono, MUTED, 6)

	local presetTitle = label(page, "LISTA · TOCA UNA PISTA PARA INICIARLA", UDim2.fromOffset(16, 193), UDim2.new(1, -32, 0, 14), Enum.Font.RobotoMono, ACCENT, 7)
	local presetList = create("ScrollingFrame", {
		Active = true,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		Position = UDim2.fromOffset(16, 210),
		ScrollBarImageColor3 = ACCENT,
		ScrollBarThickness = 4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Size = UDim2.new(1, -32, 0, 110),
		ZIndex = 12,
	}, page)
	local presetLayout = create("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, presetList)
	presetLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		presetList.CanvasSize = UDim2.fromOffset(0, presetLayout.AbsoluteContentSize.Y + 3)
	end)
	for index, track in ipairs(MUSIC_PRESETS) do
		local trackButton = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = SURFACE_2,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			LayoutOrder = index,
			Size = UDim2.new(1, -4, 0, 27),
			Text = "▶  " .. track.title,
			TextColor3 = WHITE,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextSize = 8,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 13,
		}, presetList)
		corner(trackButton, 7)
		trackButton.Activated:Connect(function()
			if localMusicSound.IsPlaying then localMusicSound:Stop() end
			state.currentMusicId = tostring(track.id)
			state.currentMusicName = track.title
			localMusicSound.SoundId = "rbxassetid://" .. state.currentMusicId
			playMusicNow(track.title)
		end)
	end
	if #MUSIC_PRESETS == 0 then
		presetTitle.Text = "LISTA DE MÚSICA NO DISPONIBLE"
	end

	playButton.Activated:Connect(function()
		if localMusicSound.IsPlaying then
			playbackRequest += 1
			localMusicSound:Stop()
			status.Text = "MÚSICA DETENIDA"
			status.TextColor3 = MUTED
		elseif state.currentMusicId ~= "" then
			playMusicNow(state.currentMusicName)
		else
			status.Text = "ELIGE UNA PISTA O CARGA UN ID"
			status.TextColor3 = RED
		end
		updateMusicPlayButton()
	end)
	updateMusicPlayButton()
end

local function renderColorsPage()
	local page = makePage("COLORS")
	sectionTitle(page, t("pageColors"), "PERSONALIZA EL ACENTO DEL GUI · ESP · FOV")

	local wheelSize = 190
	local center = wheelSize * 0.5
	local hueRadius = 81
	local ringThickness = 18
	local hue, saturation, value = state.accentColor:ToHSV()
	local wheelRoot = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 64),
		Size = UDim2.fromOffset(wheelSize, wheelSize),
		ZIndex = 13,
	}, page)
	colorPickerRoot = wheelRoot

	local hueSegments = 72
	local segmentWidth = 2 * math.pi * hueRadius / hueSegments + 1
	for index = 0, hueSegments - 1 do
		local angle = index / hueSegments * 2 * math.pi - math.pi * 0.5
		local segment = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHSV(index / hueSegments, 1, 1),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(center + math.cos(angle) * hueRadius, center + math.sin(angle) * hueRadius),
			Rotation = math.deg(angle) + 90,
			Size = UDim2.fromOffset(segmentWidth, ringThickness),
			ZIndex = 14,
		}, wheelRoot)
		corner(segment, 3)
	end

	local svSize = 76
	local svOffset = (wheelSize - svSize) * 0.5
	local svPanel = create("Frame", {
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(svOffset, svOffset),
		Size = UDim2.fromOffset(svSize, svSize),
		ZIndex = 15,
	}, wheelRoot)
	corner(svPanel, 4)
	stroke(svPanel, Color3.fromRGB(238, 246, 255), 1, 0.15)
	local colorGrid = {}
	local gridCount = 12
	local cellSize = svSize / gridCount
	for row = 0, gridCount - 1 do
		colorGrid[row + 1] = {}
		for column = 0, gridCount - 1 do
			colorGrid[row + 1][column + 1] = create("Frame", {
				BackgroundColor3 = Color3.fromHSV(hue, column / (gridCount - 1), 1 - row / (gridCount - 1)),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(column * cellSize, row * cellSize),
				Size = UDim2.fromOffset(cellSize + 0.15, cellSize + 0.15),
				ZIndex = 16,
			}, svPanel)
		end
	end

	local hueMarker = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(13, 13),
		ZIndex = 19,
	}, wheelRoot)
	corner(hueMarker, 13)
	stroke(hueMarker, Color3.fromRGB(10, 17, 28), 2, 0)
	local svMarker = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(11, 11),
		ZIndex = 19,
	}, wheelRoot)
	corner(svMarker, 11)
	stroke(svMarker, WHITE, 2, 0)
	local wheelInput = create("TextButton", {
		Active = true,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 30,
	}, wheelRoot)

	local preview = create("Frame", {
		BackgroundColor3 = state.accentColor,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(218, 82),
		Size = UDim2.fromOffset(104, 54),
		ZIndex = 13,
	}, page)
	corner(preview, 10)
	stroke(preview, ACCENT, 1, 0.08)
	local hexLabel = label(page, "#46C7FF", UDim2.fromOffset(218, 143), UDim2.fromOffset(104, 18), Enum.Font.RobotoMono, WHITE, 9)
	hexLabel.TextXAlignment = Enum.TextXAlignment.Center
	label(page, "APLICA ESTE COLOR AL GUI, A LAS LÍNEAS ESP Y AL CÍRCULO FOV.", UDim2.fromOffset(218, 166), UDim2.fromOffset(104, 52), Enum.Font.RobotoMono, MUTED, 7)
	local resetColor = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = SURFACE_2,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(218, 229),
		Size = UDim2.fromOffset(104, 25),
		Text = "RESTABLECER",
		TextColor3 = WHITE,
		TextSize = 8,
		ZIndex = 13,
	}, page)
	corner(resetColor, 7)
	label(page, "ANILLO: TONO · CUADRO: SATURACIÓN Y BRILLO", UDim2.fromOffset(16, 264), UDim2.new(1, -32, 0, 26), Enum.Font.RobotoMono, MUTED, 7)

	local function updatePaletteHue()
		svPanel.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		for row = 0, gridCount - 1 do
			for column = 0, gridCount - 1 do
				colorGrid[row + 1][column + 1].BackgroundColor3 = Color3.fromHSV(hue, column / (gridCount - 1), 1 - row / (gridCount - 1))
			end
		end
	end
	local lastThemeApply = 0
	local function refreshSelection(applyTheme, forceTheme)
		local selectedColor = Color3.fromHSV(hue, saturation, value)
		state.accentColor = selectedColor
		preview.BackgroundColor3 = selectedColor
		local red = math.floor(selectedColor.R * 255 + 0.5)
		local green = math.floor(selectedColor.G * 255 + 0.5)
		local blue = math.floor(selectedColor.B * 255 + 0.5)
		hexLabel.Text = string.format("#%02X%02X%02X", red, green, blue)
		local angle = hue * 2 * math.pi - math.pi * 0.5
		hueMarker.Position = UDim2.fromOffset(center + math.cos(angle) * hueRadius, center + math.sin(angle) * hueRadius)
		svMarker.Position = UDim2.fromOffset(svOffset + saturation * svSize, svOffset + (1 - value) * svSize)
		if applyTheme then
			local now = os.clock()
			if forceTheme or now - lastThemeApply >= 0.05 then
				applyAccentColor(selectedColor)
				lastThemeApply = now
			end
		end
	end
	local lastPaletteHue = hue
	local function setFromPosition(position)
		local x = position.X - wheelInput.AbsolutePosition.X
		local y = position.Y - wheelInput.AbsolutePosition.Y
		local dx, dy = x - center, y - center
		local radius = math.sqrt(dx * dx + dy * dy)
		local outer = hueRadius + ringThickness * 0.5 + 2
		local inner = hueRadius - ringThickness * 0.5 - 2
		if radius >= inner and radius <= outer then
			hue = (math.atan2(dy, dx) / (2 * math.pi) + 1.25) % 1
			if math.abs(hue - lastPaletteHue) > 0.0001 then
				updatePaletteHue()
				lastPaletteHue = hue
			end
		elseif x >= svOffset and x <= svOffset + svSize and y >= svOffset and y <= svOffset + svSize then
			saturation = math.clamp((x - svOffset) / svSize, 0, 1)
			value = 1 - math.clamp((y - svOffset) / svSize, 0, 1)
		else
			return
		end
		refreshSelection(true, false)
	end
	local draggingWheel = false
	wheelInput.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingWheel = true
			setFromPosition(input.Position)
		end
	end)
	local changedConnection = UserInputService.InputChanged:Connect(function(input)
		if draggingWheel and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromPosition(input.Position)
		end
	end)
	local endedConnection = UserInputService.InputEnded:Connect(function(input)
		if draggingWheel and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			draggingWheel = false
			refreshSelection(true, true)
		end
	end)
	page.Destroying:Connect(function()
		changedConnection:Disconnect()
		endedConnection:Disconnect()
		if colorPickerRoot == wheelRoot then colorPickerRoot = nil end
	end)
	resetColor.Activated:Connect(function()
		hue, saturation, value = DEFAULT_ACCENT:ToHSV()
		lastPaletteHue = hue
		updatePaletteHue()
		refreshSelection(true, true)
	end)
	refreshSelection(false, false)
end

local function showPage(pageName)
	state.page = pageName
	for name, frame in pairs(pageFrames) do frame.Visible = name == pageName end
	for name, nav in pairs(navButtons) do
		nav.BackgroundColor3 = name == pageName and ACCENT or Color3.fromRGB(12, 18, 28)
		nav.TextColor3 = name == pageName and getAccentTextColor(ACCENT) or MUTED
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
	renderMusicPage()
	renderColorsPage()
	showPage(state.page)
	title.Text = t("title")
	local navKeys = {AIMBOT = "pageAim", EPS = "pageEps", FOV = "pageFov", HITBOX = "pageHitbox", PLAYER = "pagePlayer", MISC = "pageMisc", MUSIC = "pageMusic", COLORS = "pageColors"}
	for key, button in pairs(navButtons) do button.Text = t(navKeys[key]) end
end

local navOrder = {"AIMBOT", "EPS", "FOV", "HITBOX", "PLAYER", "MISC", "MUSIC", "COLORS"}
for index, name in ipairs(navOrder) do
	local nav = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(12, 18, 28),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(8, 13 + (index - 1) * 39),
		Size = UDim2.new(1, -16, 0, 34),
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
worldVisuals = Instance.new("Folder")
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

local nearestBodyLine = newLine(visualFolder, 3)
nearestBodyLine.ZIndex = 44
local nearestBodyTargetRoot = nil
local nextNearestBodySearchAt = 0
local function findNearestBodyTarget(ownRoot)
	local nearestRoot = nil
	local nearestDistance = math.huge
	local ownCharacter = player.Character
	local function consider(character)
		if not character or character == ownCharacter or not character:IsA("Model") or not character:IsDescendantOf(workspace) then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
		if not humanoid or humanoid.Health <= 0 or not rootPart or not rootPart:IsA("BasePart") then return end
		local distance = (rootPart.Position - ownRoot.Position).Magnitude
		if distance < nearestDistance then
			nearestDistance = distance
			nearestRoot = rootPart
		end
	end
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then consider(targetPlayer.Character) end
	end
	for model in pairs(npcCharacterCache) do
		if not Players:GetPlayerFromCharacter(model) then consider(model) end
	end
	return nearestRoot
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

local function targetCanReceiveAssist(camera, targetPlayer)
	return getAimCandidate(camera, targetPlayer)
end

local cameraWithSetFov = nil

local function updateFrame(deltaTime)
	applyPlayerMovement()
	if state.noclip then applyNoclip() end
	fpsFrames = fpsFrames + 1
	local now = os.clock()
	if now - fpsLast >= 0.5 then fps = math.floor(fpsFrames / (now - fpsLast)); fpsFrames = 0; fpsLast = now end

	local camera = workspace.CurrentCamera
	if not camera then return end
	if state.cameraFovSet and camera ~= cameraWithSetFov then
		camera.FieldOfView = state.cameraFov
	end
	cameraWithSetFov = camera
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
	if state.epsNearestLine then
		local ownCharacter = player.Character
		local ownRoot = ownCharacter and (ownCharacter:FindFirstChild("HumanoidRootPart") or ownCharacter.PrimaryPart)
		if ownRoot and ownRoot:IsA("BasePart") then
			if now >= nextNearestBodySearchAt or not nearestBodyTargetRoot or not nearestBodyTargetRoot.Parent then
				nextNearestBodySearchAt = now + 0.12
				nearestBodyTargetRoot = findNearestBodyTarget(ownRoot)
			end
			if nearestBodyTargetRoot and nearestBodyTargetRoot.Parent then
				local ownScreen = camera:WorldToViewportPoint(ownRoot.Position)
				local targetScreen = camera:WorldToViewportPoint(nearestBodyTargetRoot.Position)
				local lineVisible = ownScreen.Z > 0 and targetScreen.Z > 0
				setLine(nearestBodyLine, Vector2.new(ownScreen.X, ownScreen.Y), Vector2.new(targetScreen.X, targetScreen.Y), lineVisible)
			else
				nearestBodyLine.Visible = false
			end
		else
			nearestBodyTargetRoot = nil
			nearestBodyLine.Visible = false
		end
	else
		nearestBodyTargetRoot = nil
		nextNearestBodySearchAt = 0
		nearestBodyLine.Visible = false
	end
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

	-- Asistencia de mira de un solo objetivo; solo candidatos visibles y dentro del FOV.
	if state.aimEnabled then
		local now = os.clock()
		local character, rootPart, head, _, failure
		if state.selectedTarget then
			character, rootPart, head, _, failure = getAimCandidate(camera, state.selectedTarget)
			if not character then
				local previousTarget = state.selectedTarget
				state.selectedTarget = nil
				nextAimAcquireAt = now + CONFIG.AimRetargetCooldown
				if failure == "occluded" then
					showAimNotification(t("aimLostWall") .. ": " .. previousTarget.DisplayName, RED)
				end
			end
		end
		if not state.selectedTarget and now >= nextAimAcquireAt then
			nextAimAcquireAt = now + CONFIG.AimRetargetCooldown
			local newTarget = findClosestTarget(false)
			if newTarget then
				state.selectedTarget = newTarget
				character, rootPart, head = getAimCandidate(camera, newTarget)
				if character then
					showAimNotification(t("aimLocked") .. ": " .. newTarget.DisplayName, GREEN)
				end
			end
		end
		if character and rootPart and head then
			local predictedPoint = head.Position + rootPart.AssemblyLinearVelocity * CONFIG.AimLeadSeconds
			local desired = CFrame.lookAt(camera.CFrame.Position, predictedPoint)
			local baseSmoothness = state.smoothAim and CONFIG.AimSmoothness or CONFIG.AimDirectness
			local smoothness = 1 - (1 - baseSmoothness) ^ math.clamp((deltaTime or 1 / 60) * 60, 0.25, 2)
			camera.CFrame = camera.CFrame:Lerp(desired, smoothness)
		end
	elseif state.selectedTarget then
		state.selectedTarget = nil
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
