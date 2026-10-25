-- Services shared by the UI, assets, and configuration code.
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse() or nil
local viewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
local genv = (typeof(getgenv) == "function" and getgenv()) or _G

-- Shared typography settings. Change these values to restyle all text.
local TextStyle = {
  WindowTitle = Enum.Font.GothamBold,
  WindowSubtitle = Enum.Font.GothamMedium,
  Tab = Enum.Font.GothamBold,
  Section = Enum.Font.GothamBold,
  CardTitle = Enum.Font.GothamBold,
  CardContent = Enum.Font.Gotham,
  Button = Enum.Font.GothamMedium,
}
local TextSize = {
  WindowTitle = 14,
  WindowSubtitle = 13,
  Tab = 13,
  Section = 15,
  CardTitle = 13,
  CardContent = 12,
  Button = 13,
}
local CardContentColor = Color3.fromRGB(185, 185, 190)

-- Paths and window defaults live here so a new release can change them in one place.
local LibrarySettings = {
  RootFolder = "StealthX",
  ConfigFolder = "StealthX/Config",
  AssetFolder = "StealthX/Assets",
  ProfileFolder = "StealthX/Config/Profiles",
  DefaultTitle = "Stealth-X Project",
  DefaultFooter = "Developed by naell",
  DefaultIcon = "87395407706954",
  DefaultImage = "137459328873840",
  DefaultBackground = "https://raw.getstealthx.site/img/pict2.jpg",
  DefaultVersion = "1.2",
  LegacyVersion = "1.2",
  DefaultTabWidth = 160,
  DefaultFeatureSpacing = 3,
  DefaultSectionSpacing = 6,
  CardColor = Color3.fromRGB(40, 40, 40),
  CardTransparency = 0.30,
  ButtonColor = Color3.fromRGB(60, 60, 60),
  ButtonTransparency = 0.30,
  ControlColor = Color3.fromRGB(20, 20, 20),
  ControlTransparency = 0.30,
}

if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
  pcall(function()
    if not isfolder(LibrarySettings.RootFolder) then makefolder(LibrarySettings.RootFolder) end
    if not isfolder(LibrarySettings.ConfigFolder) then makefolder(LibrarySettings.ConfigFolder) end
  end)
end
local gameName = "Unknown"
pcall(function()
  local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
  if info and info.Name then gameName = tostring(info.Name) end
end)
local displayGameName = gameName
gameName = gameName:gsub("[^%w_ ]", "")
gameName = gameName:gsub("%s+", "_")
if gameName == "" then gameName = "Unknown" end
-- One private state object owns saved values and registered controls.
local configState = {
  file = LibrarySettings.ConfigFolder .. "/StealthX_" .. gameName .. ".json",
  data = {},
  elements = {},
  version = nil,
  activeProfile = nil,
}

local function saveConfig()
  if typeof(writefile) == "function" then
    pcall(function()
      configState.data._version = configState.version
      writefile(configState.file, HttpService:JSONEncode(configState.data))
    end)
  end
end
local function loadConfigFromFile()
  if not configState.version then return end
  if typeof(isfile) == "function" and typeof(readfile) == "function" then
    local okExists, exists = pcall(isfile, configState.file)
    local success, result = false, nil
    if okExists and exists then
      success, result = pcall(function()
        return HttpService:JSONDecode(readfile(configState.file))
      end)
    end
    if success and type(result) == "table" then
      if result._version == configState.version or (configState.version == LibrarySettings.LegacyVersion and result._version == 1) then
        configState.data = result
        configState.data._version = configState.version
      else
        configState.data = { _version = configState.version }
      end
    else
      configState.data = { _version = configState.version }
    end
  else
    configState.data = { _version = configState.version }
  end
end
-- Built-in icons; RegisterIcons can extend this table at runtime.
local Icons = {
  player    = "rbxassetid://12120698352",
  web       = "rbxassetid://137601480983962",
  bag       = "rbxassetid://8601111810",
  shop      = "rbxassetid://4985385964",
  cart      = "rbxassetid://128874923961846",
  plug      = "rbxassetid://137601480983962",
  settings  = "rbxassetid://70386228443175",
  loop      = "rbxassetid://122032243989747",
  gps       = "rbxassetid://17824309485",
  compas    = "rbxassetid://125300760963399",
  gamepad   = "rbxassetid://84173963561612",
  boss      = "rbxassetid://13132186360",
  scroll    = "rbxassetid://114127804740858",
  menu      = "rbxassetid://6340513838",
  crosshair = "rbxassetid://12614416478",
  user      = "rbxassetid://108483430622128",
  stat      = "rbxassetid://12094445329",
  eyes      = "rbxassetid://14321059114",
  sword     = "rbxassetid://82472368671405",
  discord   = "rbxassetid://94434236999817",
  star      = "rbxassetid://107005941750079",
  skeleton  = "rbxassetid://17313330026",
  payment   = "rbxassetid://18747025078",
  scan      = "rbxassetid://109869955247116",
  alert     = "rbxassetid://73186275216515",
  question  = "rbxassetid://17510196486",
  idea      = "rbxassetid://16833255748",
  strom     = "rbxassetid://13321880293",
  water     = "rbxassetid://100076212630732",
  dcs       = "rbxassetid://15310731934",
  start     = "rbxassetid://108886429866687",
  next      = "rbxassetid://12662718374",
  rod       = "rbxassetid://103247953194129",
  fish      = "rbxassetid://97167558235554",
  bell      = "rbxassetid://90010061712906",
  check     = "rbxassetid://82820801644879",
  success   = "rbxassetid://82820801644879",
  info      = "rbxassetid://94529541997278",
  copy      = "rbxassetid://107485544510830",
  shield    = "rbxassetid://105619007041452",
  danger    = "rbxassetid://112161288264181",
  warning   = "rbxassetid://112161288264181",
  error     = "rbxassetid://103154043386406",
  close     = "rbxassetid://103154043386406",
  link      = "rbxassetid://71038734318580",
  heart     = "rbxassetid://134542484641582",
  chat      = "rbxassetid://133686914253815",
  message   = "rbxassetid://133686914253815",
}
local RAW_BASE_URL = "https://raw.getstealthx.site"
local ICON_URL = RAW_BASE_URL .. "/lib/Icon.lua"
local ICON_FALLBACK_URL = "https://raw.githubusercontent.com/naells/NaellUI/main/lib/Icon.lua"
local function tryLoadIcons(source)
  if type(source) == "table" then
    return source
  end
  if type(source) == "string" and source ~= "" then
    if source:match("^https?://") then
      local success, content = pcall(function()
        return game:HttpGet(source)
      end)
      if not success or type(content) ~= "string" or #content == 0 then
        local fetchUrl = source .. (source:find("%?") and "&t=" or "?t=") .. tostring(tick())
        success, content = pcall(function()
          return game:HttpGet(fetchUrl)
        end)
      end
      if success and type(content) == "string" and #content > 0 then
        local fn = loadstring(content)
        if fn then
          local ok, res = pcall(fn)
          if ok and type(res) == "table" then
            return res
          end
        end
      end
    end
    if isfile and readfile then
      local success, exists = pcall(isfile, source)
      if success and exists then
        local content = readfile(source)
        local fn = loadstring(content)
        if fn then
          local ok, res = pcall(fn)
          if ok and type(res) == "table" then
            return res
          end
        end
      end
    end
  end
  return nil
end
local function loadExternalIcons()
  local candidatePaths = {
    "lib/Icon.lua",
    "StealthUI/lib/Icon.lua",
    "Icon.lua",
  }
  for _, path in ipairs(candidatePaths) do
    local data = tryLoadIcons(path)
    if data then
      for k, v in pairs(data) do
        Icons[k] = v
      end
      return
    end
  end
  if typeof(script) == "Instance" then
    pcall(function()
      local iconModule = (script.Parent and script.Parent:FindFirstChild("Icon")) or script:FindFirstChild("Icon")
      if iconModule and iconModule:IsA("ModuleScript") then
        local res = require(iconModule)
        if type(res) == "table" then
          for k, v in pairs(res) do
            Icons[k] = v
          end
        end
      end
    end)
  end
  local remote = nil
  if ICON_URL and ICON_URL ~= "" then
    remote = tryLoadIcons(ICON_URL)
  end
  if not remote and ICON_FALLBACK_URL and ICON_FALLBACK_URL ~= "" then
    pcall(function()
      local atomFeed = game:HttpGet("https://github.com/naells/NaellUI/commits/main.atom")
      local sha = atomFeed:match("Commit/([0-9a-fA-F]+)") or atomFeed:match("<id>tag:github%.com,2008:Grit::Commit/([a-f0-9]+)</id>")
      if sha then
        remote = tryLoadIcons("https://raw.githubusercontent.com/naells/NaellUI/" .. sha .. "/lib/Icon.lua")
      end
    end)
    if not remote then
      remote = tryLoadIcons(ICON_FALLBACK_URL)
    end
  end
  if remote then
    for k, v in pairs(remote) do
      Icons[k] = v
    end
  end
end
pcall(loadExternalIcons)

-- UI helpers
local function _playSound(id, vol)
  pcall(function()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. id
    s.Volume = vol or 0.5
    s.RollOffMaxDistance = 0
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 3)
  end)
end
local function PlayUISound()   _playSound("5852470908", 1) end  -- click
local function PlayNotifSound() _playSound("4590662766", 1) end -- notif
local function getGuiContainer()
  if typeof(gethui) == "function" then
    local ok, result = pcall(gethui)
    if ok and typeof(result) == "Instance" then
      return result
    end
  end
  if LocalPlayer then
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
      return playerGui
    end
    local ok, pg = pcall(function()
      return LocalPlayer:WaitForChild("PlayerGui", 5)
    end)
    if ok and pg then
      return pg
    end
  end
  return game:GetService("CoreGui")
end
local function isMobileDevice()
  return UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled
    and not UserInputService.MouseEnabled
end
local isMobile = isMobileDevice()
local function safeSize(pxWidth, pxHeight)
  local scaleX = pxWidth / viewport.X
  local scaleY = pxHeight / viewport.Y
  if isMobile then
    if scaleX > 0.5 then scaleX = 0.5 end
    if scaleY > 0.3 then scaleY = 0.3 end
  end
  return UDim2.new(scaleX, 0, scaleY, 0)
end
local function MakeDraggable(topbarobject, object)
  local connections = {}
  local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
  end
  local function CustomPos(topbarobject, object)
    local Dragging, DragStart, StartPosition, activeInput
    local function UpdatePos(input)
      local Delta = input.Position - DragStart
      local pos = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
      )
      if object.Position ~= pos then object.Position = pos end
    end
    connect(topbarobject.InputBegan, function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = object.Position
        activeInput = input
      end
    end)
    connect(UserInputService.InputChanged, function(input)
      if Dragging and (input == activeInput or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement)) then
        UpdatePos(input)
      end
    end)
    connect(UserInputService.InputEnded, function(input)
      if input == activeInput or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseButton1) then
        Dragging = false
        activeInput = nil
      end
    end)
  end
  local function CustomSize(object)
    local Dragging, DragStart, StartSize, activeInput
    local defSizeX, defSizeY
    if isMobile then
      defSizeX, defSizeY = 520, 300 -- same as the initial mobile window size
    else
      defSizeX, defSizeY = 640, 412
    end
    local function getLimits()
      local cam = workspace.CurrentCamera
      local vp = cam and cam.ViewportSize or viewport
      local margin = isMobile and 16 or 40
      local maxX = math.max(math.min(vp.X - margin, isMobile and 700 or 1000), 200)
      local maxY = math.max(math.min(vp.Y - margin, isMobile and 380 or 720), 160)
      local minX = math.min(480, maxX)
      local minY = math.min(280, maxY)
      return minX, minY, maxX, maxY
    end
    local function clampSize(w, h)
      local minX, minY, maxX, maxY = getLimits()
      return math.clamp(w, minX, maxX), math.clamp(h, minY, maxY)
    end
    do
      local w, h = clampSize(defSizeX, defSizeY)
      object.Size = UDim2.new(0, w, 0, h)
    end
    local cam = workspace.CurrentCamera
    if cam then
      connect(cam:GetPropertyChangedSignal("ViewportSize"), function()
        local w, h = clampSize(object.AbsoluteSize.X, object.AbsoluteSize.Y)
        local size = UDim2.new(0, w, 0, h)
        if object.Size ~= size then object.Size = size end
      end)
    end
    local changesizeobject = Instance.new("Frame")
    changesizeobject.AnchorPoint = Vector2.new(1, 1)
    changesizeobject.BackgroundTransparency = 1
    changesizeobject.Size = UDim2.new(0, 40, 0, 40)
    changesizeobject.Position = UDim2.new(1, 20, 1, 20)
    changesizeobject.Name = "changesizeobject"
    changesizeobject.Parent = object
    local function UpdateSize(input)
      local Delta = input.Position - DragStart
      local newWidth = StartSize.X.Offset + Delta.X
      local newHeight = StartSize.Y.Offset + Delta.Y
      newWidth, newHeight = clampSize(newWidth, newHeight)
      local size = UDim2.new(0, newWidth, 0, newHeight)
      if object.Size ~= size then object.Size = size end
    end
    connect(changesizeobject.InputBegan, function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartSize = object.Size
        activeInput = input
      end
    end)
    connect(UserInputService.InputChanged, function(input)
      if Dragging and (input == activeInput or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement)) then
        UpdateSize(input)
      end
    end)
    connect(UserInputService.InputEnded, function(input)
      if input == activeInput or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseButton1) then
        Dragging = false
        activeInput = nil
      end
    end)
  end
  CustomSize(object)
  CustomPos(topbarobject, object)
  return function()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
  end
end
local function circleClick(Button, X, Y)
  spawn(function()
    Button.ClipsDescendants = true
    local Circle = Instance.new("ImageLabel")
    Circle.Image = "rbxassetid://266543268"
    Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
    Circle.ImageTransparency = 0.8999999761581421
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BackgroundTransparency = 1
    Circle.ZIndex = 10
    Circle.Name = "Circle"
    Circle.Parent = Button
    local NewX = X - Circle.AbsolutePosition.X
    local NewY = Y - Circle.AbsolutePosition.Y
    Circle.Position = UDim2.new(0, NewX, 0, NewY)
    local Size = 0
    if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
      Size = Button.AbsoluteSize.X * 1.5
    elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
      Size = Button.AbsoluteSize.Y * 1.5
    elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
      Size = Button.AbsoluteSize.X * 1.5
    end
    local Time = 0.5
    Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size / 2, 0.5, -Size / 2), "Out", "Quad",
      Time, false, nil)
    for i = 1, 10 do
      Circle.ImageTransparency = Circle.ImageTransparency + 0.01
      wait(Time / 10)
    end
    Circle:Destroy()
  end)
end
-- Public library object (including standalone loader components).
local StealthX = {}
StealthX.CurrentTransparency = 0.05
StealthX.Icons = Icons
StealthX.GameName = displayGameName
StealthX.SupportsAnimatedFooter = true
-- Named config profiles
local ConfigProfileFolder = LibrarySettings.ProfileFolder
local ConfigProfileGameFolder = ConfigProfileFolder .. "/" .. gameName
if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
  pcall(function()
    if not isfolder(ConfigProfileFolder) then makefolder(ConfigProfileFolder) end
    if not isfolder(ConfigProfileGameFolder) then makefolder(ConfigProfileGameFolder) end
  end)
end
local function configProfile_SanitizeName(name)
  name = tostring(name or "")
  name = name:gsub("[^%w_%- ]", "")
  name = name:gsub("^%s+", ""):gsub("%s+$", "")
  return name
end
local function configProfile_Path(name)
  return ConfigProfileGameFolder .. "/" .. name .. ".json"
end
local ConfigManager = {}
function ConfigManager:Names()
  local names = {}
  if typeof(listfiles) ~= "function" then
    return names
  end
  local ok, files = pcall(listfiles, ConfigProfileGameFolder)
  if not ok or type(files) ~= "table" then
    return names
  end
  for _, filePath in ipairs(files) do
    local fileName = tostring(filePath):match("([^/\\]+)%.json$")
    if fileName then
      table.insert(names, fileName)
    end
  end
  table.sort(names)
  return names
end
function ConfigManager:Save(name)
  name = configProfile_SanitizeName(name)
  if name == "" then
    return false, "Nama config tidak boleh kosong."
  end
  if typeof(writefile) ~= "function" then
    return false, "Executor tidak mendukung writefile."
  end
  local snapshot = {}
  for key, element in pairs(configState.elements) do
    if element.Value ~= nil then
      snapshot[key] = element.Value
    elseif configState.data[key] ~= nil then
      snapshot[key] = configState.data[key]
    end
  end
  for key, value in pairs(configState.data) do
    if snapshot[key] == nil and key ~= "_version" then
      snapshot[key] = value
    end
  end
  snapshot._version = configState.version
  local ok, err = pcall(function()
    writefile(configProfile_Path(name), HttpService:JSONEncode(snapshot))
  end)
  if not ok then
    return false, tostring(err)
  end
  configState.activeProfile = name
  return true, name
end
function ConfigManager:Load(name)
  name = configProfile_SanitizeName(name)
  if name == "" then
    return false, "Nama config tidak boleh kosong."
  end
  if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
    return false, "Executor tidak mendukung readfile."
  end
  local path = configProfile_Path(name)
  local okExists, exists = pcall(isfile, path)
  if not okExists or not exists then
    return false, "Config '" .. name .. "' tidak ditemukan."
  end
  local okRead, result = pcall(function()
    return HttpService:JSONDecode(readfile(path))
  end)
  if not okRead or type(result) ~= "table" then
    return false, "Gagal membaca config '" .. name .. "'."
  end
  for key, value in pairs(result) do
    if key ~= "_version" then
      configState.data[key] = value
    end
  end
  for key, element in pairs(configState.elements) do
    if result[key] ~= nil and element.Set then
      pcall(function() element:Set(result[key], true) end)
    end
  end
  configState.activeProfile = name
  return true, name
end
function ConfigManager:Delete(name)
  name = configProfile_SanitizeName(name)
  if name == "" then
    return false, "Nama config tidak boleh kosong."
  end
  if typeof(isfile) ~= "function" or typeof(delfile) ~= "function" then
    return false, "Executor tidak mendukung delfile."
  end
  local path = configProfile_Path(name)
  local okExists, exists = pcall(isfile, path)
  if not okExists or not exists then
    return false, "Config '" .. name .. "' tidak ditemukan."
  end
  local okDel, err = pcall(delfile, path)
  if not okDel then
    return false, tostring(err)
  end
  if configState.activeProfile == name then
    configState.activeProfile = nil
  end
  return true, name
end
function ConfigManager:GetActive()
  return configState.activeProfile
end
StealthX.Config = ConfigManager
function StealthX:RegisterIcons(iconSource)
  local data = tryLoadIcons(iconSource)
  if data and type(data) == "table" then
    for k, v in pairs(data) do
      Icons[k] = v
    end
    return true
  end
  return false
end
local function isAssetFileValid(path)
  if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
    return false
  end
  local okE, exists = pcall(isfile, path)
  if not okE or not exists then return false end
  local okR, data = pcall(readfile, path)
  if not okR or not data or #data < 64 then return false end
  local prefix = data:sub(1, 25):lower()
  if prefix:find("404") or prefix:find("<html") or prefix:find("<!doctype") then
    return false
  end
  return true
end
local function resolveAsset(val, fallbackName)
  if not val or val == "" then return "" end
  local str = tostring(val)
  if str:match("^https?://") then
    local getAsset = (typeof(getcustomasset) == "function" and getcustomasset)
      or (typeof(getsynasset) == "function" and getsynasset)
    if typeof(writefile) == "function" and getAsset then
      local rawName = str:match("([^/?#]+)$") or fallbackName or "asset.png"
      rawName = rawName:gsub("[^%w_%.]", "")
      if not rawName:find("%.") then rawName = rawName .. ".png" end
      local hash = 0
      for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 1000000007
      end
      local localPath = LibrarySettings.AssetFolder .. "/" .. string.format("stx_%d_%s", hash, rawName)
      if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
        pcall(function()
          if not isfolder(LibrarySettings.RootFolder) then makefolder(LibrarySettings.RootFolder) end
          if not isfolder(LibrarySettings.AssetFolder) then makefolder(LibrarySettings.AssetFolder) end
        end)
      end
      if not isAssetFileValid(localPath) then
        if typeof(delfile) == "function" then
          pcall(delfile, localPath)
        end
        local localCandidates = {
          rawName,
          "img/" .. rawName,
          "StealthUI/img/" .. rawName,
          "StealthUI/" .. rawName,
        }
        local foundLocal = false
        if typeof(isfile) == "function" and typeof(readfile) == "function" then
          for _, cand in ipairs(localCandidates) do
            local okC, exC = pcall(isfile, cand)
            if okC and exC then
              local okRead, data = pcall(readfile, cand)
              if okRead and data and #data >= 64 and not data:sub(1, 25):lower():find("404") then
                pcall(writefile, localPath, data)
                foundLocal = true
                break
              end
            end
          end
        end
        if not foundLocal then
          local okGet, content = pcall(game.HttpGet, game, str)
          if okGet and content and #content >= 64 and not content:sub(1, 25):lower():find("404") and not content:sub(1, 25):lower():find("<html") then
            pcall(writefile, localPath, content)
          end
        end
      end
      if isAssetFileValid(localPath) then
        local okAsset, assetUri = pcall(getAsset, localPath)
        if okAsset and assetUri then
          return assetUri
        end
      end
    end
    return str
  end
  if typeof(isfile) == "function" and (typeof(getcustomasset) == "function" or typeof(getsynasset) == "function") then
    local getAsset = getcustomasset or getsynasset
    local okExists, exists = pcall(isfile, str)
    if okExists and exists then
      local okAsset, assetUri = pcall(getAsset, str)
      if okAsset and assetUri then
        return assetUri
      end
    end
  end
  if str:find("://") then
    return str
  end
  if str:match("^%d+$") then
    return "rbxassetid://" .. str
  end
  return "rbxassetid://" .. str
end
StealthX.ResolveAsset = resolveAsset
function StealthX:GetIcon(name)
  if not name or name == "" then return "" end
  local str = tostring(name)
  if str:find("://") then
    return str
  end
  if str:match("^%d+$") then
    return "rbxassetid://" .. str
  end
  if Icons[str] then
    return Icons[str]
  end
  local lower = string.lower(str)
  if Icons[lower] then
    return Icons[lower]
  end
  local commonAliases = {
    bell    = "rbxassetid://90010061712906",
    check   = "rbxassetid://82820801644879",
    success = "rbxassetid://82820801644879",
    info    = "rbxassetid://94529541997278",
    copy    = "rbxassetid://107485544510830",
    shield  = "rbxassetid://105619007041452",
    danger  = "rbxassetid://112161288264181",
    warning = "rbxassetid://112161288264181",
    error   = "rbxassetid://103154043386406",
    close   = "rbxassetid://103154043386406",
    link    = "rbxassetid://71038734318580",
    discord = "rbxassetid://94434236999817",
    ["programming-bold"]  = "rbxassetid://71466343335951",
    ["chart-square-bold"] = "rbxassetid://73897886601288",
  }
  if commonAliases[lower] then
    return commonAliases[lower]
  end
  local candidates = {
    lower .. "-bold",
    lower .. "-linear",
    lower .. "-bing-bold",
    lower .. "-circle-bold",
    lower .. "-line-duotone",
    lower .. "-bold-duotone",
  }
  for _, cand in ipairs(candidates) do
    if Icons[cand] then
      return Icons[cand]
    end
  end
  return ""
end
local MAX_NOTIFICATIONS = 5
function StealthX:MakeNotify(NotifyConfig)
  local NotifyConfig = NotifyConfig or {}
  local rawTitle = NotifyConfig.Title or "StealthX"
  local rawDesc = NotifyConfig.Description
  local rawContent = NotifyConfig.Content
  if rawDesc == "Notification" and rawContent and rawContent ~= "" then
    rawDesc = nil
  end
  if rawDesc == rawContent or rawDesc == "" then
    rawDesc = nil
  end
  local rawDelay = tonumber(NotifyConfig.Delay or NotifyConfig.Duration)
  local rawTime = tonumber(NotifyConfig.Time or NotifyConfig.AnimDuration or NotifyConfig.AnimTime)
  local animDuration = 0.35
  local displayDelay = rawDelay or (rawTime and rawTime > 1 and rawTime) or 4
  if rawTime and rawTime <= 1 and rawTime > 0.05 then
    animDuration = rawTime
  end
  local accentColor = NotifyConfig.Color or Color3.fromRGB(0, 208, 255)
  local NotifyFunction = {}
  function NotifyFunction:Close() end
  task.spawn(function()
    local guiTarget = getGuiContainer()
    local NotifyGui = guiTarget:FindFirstChild("NotifyGui")
    if not NotifyGui then
      NotifyGui = Instance.new("ScreenGui")
      NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
      NotifyGui.DisplayOrder = 99999
      NotifyGui.Name = "NotifyGui"
      NotifyGui.ResetOnSpawn = false
      NotifyGui.Parent = guiTarget
    end
    NotifyGui.DisplayOrder = 99999
    local NotifyLayout = NotifyGui:FindFirstChild("NotifyLayout")
    if not NotifyLayout then
      local screenW = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 600
      local maxNotifW = isMobile and 260 or 300
      local notifW = math.min(maxNotifW, screenW - 20)
      NotifyLayout = Instance.new("Frame")
      NotifyLayout.AnchorPoint = Vector2.new(1, 1)
      NotifyLayout.BackgroundTransparency = 1
      NotifyLayout.BorderSizePixel = 0
      NotifyLayout.Position = UDim2.new(1, -10, 1, -25)
      NotifyLayout.Size = UDim2.fromOffset(notifW, workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 800)
      NotifyLayout.Name = "NotifyLayout"
      NotifyLayout.Parent = NotifyGui
      local reflowPending = false
      local function reflowNotifications()
        if reflowPending then return end
        reflowPending = true
        task.defer(function()
          reflowPending = false
          if not NotifyLayout.Parent then return end
          local frames = {}
          for index, child in ipairs(NotifyLayout:GetChildren()) do
            if child:IsA("GuiObject") and child.Name == "NotifyFrame" then
              table.insert(frames, {
                Frame = child,
                Order = child:GetAttribute("NotificationOrder") or 0,
                Index = index,
              })
            end
          end
          table.sort(frames, function(a, b)
            if a.Order == b.Order then return a.Index < b.Index end
            return a.Order < b.Order
          end)
          local currentBottom = 0
          for _, entry in ipairs(frames) do
            local v = entry.Frame
            local position = UDim2.new(0, 0, 1, -currentBottom)
            if v.Position ~= position then
              TweenService:Create(
                v,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Position = position }
              ):Play()
            end
            currentBottom = currentBottom + v.Size.Y.Offset + 8
          end
        end)
      end
      NotifyLayout.ChildRemoved:Connect(reflowNotifications)
    end
    local notificationKey = tostring(rawTitle) .. "\n" .. tostring(rawDesc or "") .. "\n" .. tostring(rawContent or "")
    local activeFrames = {}
    for index, child in ipairs(NotifyLayout:GetChildren()) do
      if child:IsA("GuiObject") and child.Name == "NotifyFrame" then
        table.insert(activeFrames, {
          Frame = child,
          Order = child:GetAttribute("NotificationOrder") or 0,
          Index = index,
        })
      end
    end
    table.sort(activeFrames, function(a, b)
      if a.Order == b.Order then return a.Index < b.Index end
      return a.Order < b.Order
    end)
    while #activeFrames > MAX_NOTIFICATIONS do
      local oldest = table.remove(activeFrames, 1)
      oldest.Frame:Destroy()
    end
    for _, entry in ipairs(activeFrames) do
      local frame = entry.Frame
      if frame:GetAttribute("NotificationKey") == notificationKey
        and not frame:GetAttribute("Closing") then
        NotifyFunction.Close = function()
          if frame.Parent then frame:Destroy() end
        end
        return
      end
    end
    while #activeFrames >= MAX_NOTIFICATIONS do
      local oldest = table.remove(activeFrames, 1)
      oldest.Frame:Destroy()
    end
    local notificationOrder = (NotifyLayout:GetAttribute("NextNotificationOrder") or 0) + 1
    NotifyLayout:SetAttribute("NextNotificationOrder", notificationOrder)
    local notifyPosHeight = 0
    for _, entry in ipairs(activeFrames) do
      notifyPosHeight = notifyPosHeight + entry.Frame.Size.Y.Offset + 8
    end
    local NotifyFrame = Instance.new("Frame")
    local NotifyFrameReal = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local RealStroke = Instance.new("UIStroke")
    local Top = Instance.new("Frame")
    local TextLabel = Instance.new("TextLabel")
    local TextLabel1 = Instance.new("TextLabel")
    local Close = Instance.new("TextButton")
    local ImageLabel = Instance.new("ImageLabel")
    local TextLabel2 = Instance.new("TextLabel")
    NotifyFrame.BackgroundTransparency = 1
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Size = UDim2.new(1, 0, 0, 60)
    NotifyFrame.Name = "NotifyFrame"
    NotifyFrame:SetAttribute("NotificationKey", notificationKey)
    NotifyFrame:SetAttribute("NotificationOrder", notificationOrder)
    NotifyFrame.AnchorPoint = Vector2.new(0, 1)
    NotifyFrame.Position = UDim2.new(0, 0, 1, -notifyPosHeight)
    NotifyFrame.Parent = NotifyLayout
    local notifyTransparency = NotifyConfig.Transparency or NotifyConfig.BackgroundTransparency or StealthX.CurrentTransparency or 0.05
    if type(notifyTransparency) == "number" and notifyTransparency > 1 then
      notifyTransparency = notifyTransparency / 100
    end
    NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    NotifyFrameReal.BackgroundTransparency = notifyTransparency
    NotifyFrameReal.BorderSizePixel = 0
    NotifyFrameReal.Position = UDim2.new(0, 380, 0, 0)
    NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
    NotifyFrameReal.Name = "NotifyFrameReal"
    NotifyFrameReal.ClipsDescendants = true
    NotifyFrameReal.Parent = NotifyFrame
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = NotifyFrameReal
    RealStroke.Color = Color3.fromRGB(45, 45, 52)
    RealStroke.Thickness = 1
    RealStroke.Parent = NotifyFrameReal
    Top.BackgroundTransparency = 1
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 32)
    Top.Name = "Top"
    Top.ClipsDescendants = true
    Top.Parent = NotifyFrameReal
    local TitleOffset = 10
    local rawNotifyIcon = NotifyConfig.Icon or NotifyConfig.Image
    local iconSrc = ""
    if rawNotifyIcon and tostring(rawNotifyIcon) ~= "" then
      iconSrc = StealthX:GetIcon(tostring(rawNotifyIcon))
    end
    if iconSrc and iconSrc ~= "" then
      local NotifyIcon = Instance.new("ImageLabel")
      NotifyIcon.Name = "NotifyIcon"
      NotifyIcon.Image = iconSrc
      NotifyIcon.ImageColor3 = NotifyConfig.IconColor or Color3.fromRGB(255, 255, 255)
      NotifyIcon.BackgroundTransparency = 1
      NotifyIcon.BorderSizePixel = 0
      NotifyIcon.ScaleType = Enum.ScaleType.Fit
      NotifyIcon.AnchorPoint = Vector2.new(0, 0.5)
      NotifyIcon.Position = UDim2.new(0, 10, 0.5, 0)
      NotifyIcon.Size = UDim2.fromOffset(16, 16)
      NotifyIcon.Parent = Top
      local iconCorner = Instance.new("UICorner")
      iconCorner.CornerRadius = UDim.new(0, 4)
      iconCorner.Parent = NotifyIcon
      TitleOffset = 10 + 16 + 8
    end
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundTransparency = 1
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -6, 0.5, 0)
    Close.Size = UDim2.new(0, 22, 0, 22)
    Close.Name = "Close"
    Close.Parent = Top
    ImageLabel.Image = "rbxassetid://9886659671"
    ImageLabel.ImageColor3 = Color3.fromRGB(180, 180, 185)
    ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel.Size = UDim2.new(1, -8, 1, -8)
    ImageLabel.Parent = Close
    TextLabel.Font = TextStyle.CardTitle
    TextLabel.Text = rawTitle
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = TextSize.CardTitle
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Center
    TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
    TextLabel.BackgroundTransparency = 1
    TextLabel.BorderSizePixel = 0
    TextLabel.Parent = Top
    if rawDesc and rawDesc ~= "" then
      TextLabel.AutomaticSize = Enum.AutomaticSize.X
      TextLabel.Size = UDim2.new(0, 0, 1, 0)
      TextLabel.Position = UDim2.new(0, TitleOffset, 0, 0)
      TextLabel1.Font = TextStyle.CardContent
      TextLabel1.Text = rawDesc
      TextLabel1.TextColor3 = accentColor
      TextLabel1.TextSize = TextSize.CardContent
      TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
      TextLabel1.TextYAlignment = Enum.TextYAlignment.Center
      TextLabel1.TextTruncate = Enum.TextTruncate.AtEnd
      TextLabel1.BackgroundTransparency = 1
      TextLabel1.BorderSizePixel = 0
      TextLabel1.Parent = Top
      local function updateDescPos()
        local fallbackScreenW = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 600
        local fallbackMaxW = isMobile and 260 or 300
        local frameW = NotifyFrameReal.AbsoluteSize.X > 0 and NotifyFrameReal.AbsoluteSize.X or math.min(fallbackMaxW, fallbackScreenW - 20)
        local tWidth = TextLabel.TextBounds.X
        local startX = TitleOffset + tWidth + 8
        local maxDescW = math.max(0, frameW - startX - 35)
        TextLabel1.Position = UDim2.new(0, startX, 0, 0)
        TextLabel1.Size = UDim2.new(0, maxDescW, 1, 0)
      end
      updateDescPos()
      TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateDescPos)
    else
      TextLabel1.Visible = false
      TextLabel.AutomaticSize = Enum.AutomaticSize.None
      TextLabel.Position = UDim2.new(0, TitleOffset, 0, 0)
      TextLabel.Size = UDim2.new(1, -(TitleOffset + 35), 1, 0)
    end
    local contentText = rawContent or ""
    local contentH = 0
    if contentText ~= "" then
      local availW = 320 - 20
      local plainText = contentText:gsub("<[^>]->", "")
      local sz = TextService:GetTextSize(plainText, TextSize.CardContent, TextStyle.CardContent, Vector2.new(availW, 10000))
      contentH = math.max(14, sz.Y)
      TextLabel2.Font = TextStyle.CardContent
      TextLabel2.TextColor3 = Color3.fromRGB(160, 160, 165)
      TextLabel2.TextSize = TextSize.CardContent
      TextLabel2.Text = contentText
      TextLabel2.TextWrapped = true
      TextLabel2.RichText = true
      TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
      TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
      TextLabel2.BackgroundTransparency = 1
      TextLabel2.BorderSizePixel = 0
      TextLabel2.Position = UDim2.new(0, 10, 0, 30)
      TextLabel2.Size = UDim2.new(1, -20, 0, contentH)
      TextLabel2.Parent = NotifyFrameReal
      NotifyFrame.Size = UDim2.new(1, 0, 0, math.max(52, 34 + contentH + 10))
    else
      TextLabel2.Visible = false
      NotifyFrame.Size = UDim2.new(1, 0, 0, 38)
    end
    local closed = false
    function NotifyFunction:Close()
      if closed then return end
      closed = true
      if not NotifyFrame.Parent then return end
      NotifyFrame:SetAttribute("Closing", true)
      local tween = TweenService:Create(
        NotifyFrameReal,
        TweenInfo.new(animDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0, 380, 0, 0) }
      )
      tween:Play()
      tween.Completed:Connect(function()
        if NotifyFrame.Parent then NotifyFrame:Destroy() end
      end)
    end
    Close.Activated:Connect(function()
      PlayUISound()
      NotifyFunction:Close()
    end)
    PlayNotifSound()
    TweenService:Create(
      NotifyFrameReal,
      TweenInfo.new(animDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
      { Position = UDim2.new(0, 0, 0, 0) }
    ):Play()
    task.delay(displayDelay, function()
      NotifyFunction:Close()
    end)
  end)
  return NotifyFunction
end
StealthX.Notify = function(self, NotifyConfig)
  if type(self) == "table" and not NotifyConfig then
    return StealthX:MakeNotify(self)
  end
  return StealthX:MakeNotify(NotifyConfig)
end
-- Standalone status dialogs for the loader and direct execution guard.
-- These work without creating a StealthX Window.
local standaloneStatus
local STATUS_ACCENTS = {
  error = Color3.fromRGB(233, 99, 99),
  ban = Color3.fromRGB(233, 99, 99),
  warning = Color3.fromRGB(222, 175, 96),
  limit = Color3.fromRGB(222, 175, 96),
  success = Color3.fromRGB(117, 211, 155),
  info = Color3.fromRGB(230, 230, 230),
}
local function statusElement(className, parent, properties)
  local object = Instance.new(className)
  for key, value in pairs(properties or {}) do object[key] = value end
  object.Parent = parent
  return object
end

function StealthX:ShowStatus(config)
  config = type(config) == "table" and config or {}
  if standaloneStatus and standaloneStatus.Parent then standaloneStatus:Destroy() end
  local guiParent = getGuiContainer()
  local previous = guiParent:FindFirstChild("StealthXStatusDialog")
  if previous then previous:Destroy() end
  local kind = tostring(config.Kind or "info"):lower()
  local accent = STATUS_ACCENTS[kind] or STATUS_ACCENTS.info
  local title = tostring(config.Title or "Stealth-X")
  local content = tostring(config.Content or config.Message or "")
  local footer = tostring(config.Footer or "")
  local expiry = tonumber(config.ExpiresAt)
  if expiry and expiry < 100000000000 then expiry = expiry * 1000 end
  local actions = type(config.Buttons) == "table" and config.Buttons or {{Title = "Close"}}
  local limits = {}
  if type(config.Daily) == "table" then table.insert(limits, config.Daily) end
  if type(config.Weekly) == "table" then table.insert(limits, config.Weekly) end
  for _, metric in ipairs(type(config.Metrics) == "table" and config.Metrics or {}) do
    if type(metric) == "table" then table.insert(limits, metric) end
  end
  local camera = workspace.CurrentCamera
  local view = camera and camera.ViewportSize or Vector2.new(800, 600)
  local width = math.min(420, math.max(260, view.X - 28))
  local bodyHeight = TextService:GetTextSize(content, 13, Enum.Font.Gotham,
    Vector2.new(width - 48, 2000)).Y
  local height = math.min(math.max(208, 142 + bodyHeight + (#limits * 45)
    + (expiry and 28 or 0) + (footer ~= "" and 36 or 0)), math.max(208, view.Y - 36))

  local gui = statusElement("ScreenGui", guiParent, {
    Name = "StealthXStatusDialog",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 99998,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
  })
  standaloneStatus = gui
  local overlay = statusElement("Frame", gui, {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Active = true,
  })
  local panel = statusElement("Frame", overlay, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 10),
    Size = UDim2.fromOffset(width, height),
    BackgroundColor3 = Color3.fromRGB(13, 13, 13),
    BorderSizePixel = 0,
    ClipsDescendants = true,
  })
  statusElement("UICorner", panel, {CornerRadius = UDim.new(0, 12)})
  statusElement("UIStroke", panel, {
    Color = Color3.fromRGB(47, 47, 47),
    Transparency = 0.1,
    Thickness = 1,
  })
  statusElement("Frame", panel, {
    Position = UDim2.fromOffset(20, 24),
    Size = UDim2.fromOffset(3, 19),
    BackgroundColor3 = accent,
    BorderSizePixel = 0,
  })
  statusElement("TextLabel", panel, {
    Position = UDim2.fromOffset(32, 19),
    Size = UDim2.new(1, -52, 0, 27),
    BackgroundTransparency = 1,
    Text = title,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(250, 250, 250),
    TextTruncate = Enum.TextTruncate.AtEnd,
    TextXAlignment = Enum.TextXAlignment.Left,
  })
  local scroll = statusElement("ScrollingFrame", panel, {
    Position = UDim2.fromOffset(22, 58),
    Size = UDim2.new(1, -44, 1, -122),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(85, 85, 85),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
  })
  statusElement("UIListLayout", scroll, {
    Padding = UDim.new(0, 11),
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
  })
  local order = 0
  local function addText(value, size, color, font)
    order = order + 1
    return statusElement("TextLabel", scroll, {
      LayoutOrder = order,
      Size = UDim2.new(1, -5, 0, 0),
      AutomaticSize = Enum.AutomaticSize.Y,
      BackgroundTransparency = 1,
      Text = value,
      TextWrapped = true,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
      TextSize = size,
      Font = font or Enum.Font.Gotham,
      TextColor3 = color,
    })
  end
  if content ~= "" then addText(content, 13, Color3.fromRGB(197, 197, 201)) end
  local countdown
  if expiry then
    countdown = addText("", 12, accent, Enum.Font.GothamMedium)
    task.spawn(function()
      while gui.Parent do
        local remain = math.max(0, math.ceil((expiry - os.time() * 1000) / 1000))
        countdown.Text = remain == 0 and "You can try again now." or
          string.format("Retry in %02d:%02d:%02d", math.floor(remain / 3600),
            math.floor(remain % 3600 / 60), remain % 60)
        if remain == 0 then break end
        task.wait(1)
      end
    end)
  end
  for _, metric in ipairs(limits) do
    order = order + 1
    local row = statusElement("Frame", scroll, {
      LayoutOrder = order,
      Size = UDim2.new(1, -5, 0, 34),
      BackgroundTransparency = 1,
    })
    local used, max = tonumber(metric.Used), tonumber(metric.Limit)
    local progress = tonumber(metric.Progress) or
      (used and max and max > 0 and used / max or 0)
    local value = metric.Value or (used and max and (tostring(used) .. " / " .. tostring(max))) or ""
    statusElement("TextLabel", row, {
      Size = UDim2.new(0.6, 0, 0, 18), BackgroundTransparency = 1,
      Text = tostring(metric.Label or "Usage"), TextSize = 11,
      Font = Enum.Font.GothamMedium,
      TextColor3 = Color3.fromRGB(190, 190, 195),
      TextXAlignment = Enum.TextXAlignment.Left,
    })
    statusElement("TextLabel", row, {
      Position = UDim2.new(0.6, 0, 0, 0),
      Size = UDim2.new(0.4, 0, 0, 18), BackgroundTransparency = 1,
      Text = tostring(value), TextSize = 11, Font = Enum.Font.GothamMedium,
      TextColor3 = Color3.fromRGB(230, 230, 230),
      TextXAlignment = Enum.TextXAlignment.Right,
    })
    local track = statusElement("Frame", row, {
      Position = UDim2.fromOffset(0, 25), Size = UDim2.new(1, 0, 0, 3),
      BackgroundColor3 = Color3.fromRGB(50, 50, 50), BorderSizePixel = 0,
    })
    statusElement("UICorner", track, {CornerRadius = UDim.new(1, 0)})
    local fill = statusElement("Frame", track, {
      Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1),
      BackgroundColor3 = accent, BorderSizePixel = 0,
    })
    statusElement("UICorner", fill, {CornerRadius = UDim.new(1, 0)})
  end
  if footer ~= "" then addText(footer, 11, Color3.fromRGB(130, 130, 137)) end

  local controller = {Closed = false, Screen = gui}
  function controller:Close(immediate)
    if self.Closed then return end
    self.Closed = true
    if immediate or not gui.Parent then
      gui:Destroy()
      return
    end
    TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
      {Position = UDim2.new(0.5, 0, 0.5, 12)}):Play()
    TweenService:Create(overlay, TweenInfo.new(0.18),
      {BackgroundTransparency = 1}):Play()
    task.delay(0.19, function()
      if gui.Parent then gui:Destroy() end
    end)
  end
  controller.close = controller.Close
  local count = math.max(1, #actions)
  local spacing = 8
  local buttonWidth = (width - 44 - (count - 1) * spacing) / count
  for index, actionConfig in ipairs(actions) do
    local primary = actionConfig.Primary
    if primary == nil then primary = index == 1 end
    local action = statusElement("TextButton", panel, {
      Position = UDim2.new(0, 22 + (index - 1) * (buttonWidth + spacing), 1, -48),
      Size = UDim2.fromOffset(buttonWidth, 34),
      BackgroundColor3 = primary and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(32, 32, 32),
      TextColor3 = primary and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(230, 230, 230),
      Text = tostring(actionConfig.Title or "Close"),
      TextSize = 12, Font = Enum.Font.GothamMedium, BorderSizePixel = 0,
      AutoButtonColor = true,
    })
    statusElement("UICorner", action, {CornerRadius = UDim.new(0, 50)})
    action.Activated:Connect(function()
      if type(actionConfig.Callback) == "function" then
        local ok, err = pcall(actionConfig.Callback)
        if not ok then warn("[Stealth-X UI] Status action failed: " .. tostring(err)) end
      end
      if actionConfig.Close ~= false then controller:Close() end
    end)
  end
  TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Position = UDim2.fromScale(0.5, 0.5)}):Play()
  return controller
end
function StealthX:ShowRateLimit(config)
  config = type(config) == "table" and config or {}
  config.Kind = "limit"
  config.Title = config.Title or "RATE LIMIT REACHED"
  return self:ShowStatus(config)
end
function StealthX:ShowAlert(config)
  return self:ShowStatus(config)
end
function StealthX:ShowWarning(config)
  config = type(config) == "table" and config or {}
  config.Kind = "warning"
  config.Title = config.Title or "WARNING"
  return self:ShowStatus(config)
end
function StealthX:ShowError(config)
  config = type(config) == "table" and config or {}
  config.Kind = "error"
  config.Title = config.Title or "ERROR"
  return self:ShowStatus(config)
end
function StealthX:ShowExecutionRejected(config)
  config = type(config) == "table" and config or {}
  config.Kind = "ban"
  config.Title = config.Title or "EXECUTION REJECTED"
  return self:ShowStatus(config)
end
function StealthX:CreateLoadingScreen(config)
    config = type(config) == "table" and config or {}
    local stages = config.Stages or {
        { key = "license",  label = "Selecting access mode", icon = "rbxassetid://93569468678423" },
        { key = "session",  label = "Preparing access",       icon = "rbxassetid://138813829483190" },
        { key = "resolve",  label = "Resolving game script",  icon = "rbxassetid://132228762224767" },
        { key = "download", label = "Fetching build",         icon = "rbxassetid://95110638826999" },
        { key = "execute",  label = "Starting script",        icon = "rbxassetid://126174487049903" },
    }

    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local COLORS = {
        white = Color3.fromRGB(245, 245, 245),
        muted = Color3.fromRGB(153, 153, 153),
        track = Color3.fromRGB(68, 68, 68),
    }

    local function make(className, parent, properties)
        local object = Instance.new(className)
        for property, value in pairs(properties or {}) do
            object[property] = value
        end
        object.Parent = parent
        return object
    end

    local function corner(parent, radius)
        return make("UICorner", parent, { CornerRadius = UDim.new(0, radius) })
    end

    local function tween(object, duration, properties)
        if not object or not object.Parent then
            return nil
        end
        local ok, animation = pcall(function()
            return TweenService:Create(
                object,
                TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                properties
            )
        end)
        if ok and animation then
            animation:Play()
            return animation
        end
        return nil
    end

    local parent
    pcall(function()
        if type(gethui) == "function" then
            parent = gethui()
        end
    end)
    if not parent then
        pcall(function()
            local player = Players.LocalPlayer
            if player then
                parent = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5)
            end
        end)
    end
    if not parent then
        pcall(function() parent = CoreGui end)
    end
    if not parent then
        warn("[Stealth-X UI] Loading screen has no GUI parent")
        return {
            Closed = true,
            SetStep = function() end, SetDetail = function() end, SetTarget = function() end,
            set = function() end, setTarget = function() end, Close = function() end, close = function() end,
        }
    end

    pcall(function()
        local previous = parent:FindFirstChild("StealthXNativeLoader")
        if previous then previous:Destroy() end
    end)

    local screen = make("ScreenGui", parent, {
        Name = "StealthXNativeLoader",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- Transparent root keeps Roblox's game view visible around the UI.
    local root = make("Frame", screen, {
        Name = "Root",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = false,
        ZIndex = 1,
    })

    -- Only the loading phase gets a translucent black overlay. It stays fully
    -- transparent during the splash, then fades in behind the loading text.
    local loadingBackdrop = make("Frame", root, {
        Name = "LoadingBackdrop",
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = false,
        ZIndex = 2,
    })

    -- The splash is shown over the game without a halo or world blur.
    local splashImage = make("ImageLabel", root, {
        Name = "StealthXSplash",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.82, 0, 0, 150),
        BackgroundTransparency = 1,
        Image = "rbxassetid://132800388967463",
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 3,
    })
    make("UISizeConstraint", splashImage, {
        MinSize = Vector2.new(250, 90),
        MaxSize = Vector2.new(560, 170),
    })

    -- Minimal floating loader: no card, panel, full-screen overlay, or boxed rows.
    local brandIcon = make("ImageLabel", root, {
        Name = "BrandIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -82),
        Size = UDim2.fromOffset(23, 23),
        BackgroundTransparency = 1,
        Image = "rbxassetid://138813829483190", -- Solar shield-check-bold
        ImageColor3 = COLORS.white,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
    })
    local brandTitle = make("TextLabel", root, {
        Name = "BrandTitle",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -52),
        Size = UDim2.new(0.8, 0, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "STEALTH-X",
        TextColor3 = COLORS.white,
        TextTransparency = 1,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5,
    })
    local targetText = make("TextLabel", root, {
        Name = "Target",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -13),
        Size = UDim2.new(0.84, 0, 0, 29),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = tostring(config.Target or "Detecting game"),
        TextColor3 = COLORS.white,
        TextTransparency = 1,
        TextSize = 21,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5,
    })
    local detailText = make("TextLabel", root, {
        Name = "Detail",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 15),
        Size = UDim2.new(0.84, 0, 0, 30),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(config.Detail or "Preparing secure delivery"),
        TextColor3 = COLORS.muted,
        TextTransparency = 1,
        TextSize = 12,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 5,
    })
    local phaseIcon = make("ImageLabel", root, {
        Name = "PhaseIcon",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0.5, -82, 0.5, 57),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        Image = stages[1].icon,
        ImageColor3 = COLORS.white,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
    })
    local phaseText = make("TextLabel", root, {
        Name = "Phase",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0.5, -72, 0.5, 57),
        Size = UDim2.new(0.5, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = stages[1].label,
        TextColor3 = COLORS.white,
        TextTransparency = 1,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    })
    local progressTrack = make("Frame", root, {
        Name = "ProgressTrack",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 87),
        Size = UDim2.new(0.76, 0, 0, 3),
        BackgroundColor3 = COLORS.track,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 5,
    })
    make("UISizeConstraint", progressTrack, {
        MinSize = Vector2.new(210, 3),
        MaxSize = Vector2.new(360, 3),
    })
    corner(progressTrack, 2)
    local progressFill = make("Frame", progressTrack, {
        Name = "ProgressFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = COLORS.white,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    corner(progressFill, 2)
    local stepCounter = make("TextLabel", root, {
        Name = "StepCounter",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 99),
        Size = UDim2.new(0.76, 0, 0, 15),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "STEP 01 / 05",
        TextColor3 = COLORS.muted,
        TextTransparency = 1,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    })
    -- Match the progress track's constrained width, not the full viewport.
    make("UISizeConstraint", stepCounter, {
        MinSize = Vector2.new(210, 15),
        MaxSize = Vector2.new(360, 15),
    })
    local percentLabel = make("TextLabel", root, {
        Name = "Percent",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 99),
        Size = UDim2.new(0.76, 0, 0, 15),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "20%",
        TextColor3 = COLORS.white,
        TextTransparency = 1,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 5,
    })
    make("UISizeConstraint", percentLabel, {
        MinSize = Vector2.new(210, 15),
        MaxSize = Vector2.new(360, 15),
    })

    local controller = {
        stages = stages,
        stageKey = stages[1].key,
        stageIndex = 1,
        progress = 1 / #stages,
        targetName = tostring(config.Target or "Detecting game"),
        detail = tostring(config.Detail or "Preparing secure delivery"),
        Closed = false,
        Visible = false,
        Screen = screen,
    }

    local function updateProgress(animate)
        if controller.Closed then return end
        local fraction = math.clamp(controller.progress, 0, 1)
        percentLabel.Text = tostring(math.floor(fraction * 100 + 0.5)) .. "%"
        stepCounter.Text = ("STEP %02d / %02d"):format(controller.stageIndex, #stages)
        local size = UDim2.new(fraction, 0, 1, 0)
        if animate and controller.Visible then
            tween(progressFill, 0.3, { Size = size })
        else
            progressFill.Size = size
        end
    end

    function controller:SetDetail(value)
        if self.Closed then return end
        if type(value) == "string" and value ~= "" then
            self.detail = value
            detailText.Text = value
        end
    end

    function controller:SetStep(index, total, label)
        if self.Closed then return end
        local safeIndex = math.clamp(tonumber(index) or 1, 1, #self.stages)
        local stage = self.stages[safeIndex]
        self.stageIndex = safeIndex
        self.stageKey = stage.key
        self.progress = math.clamp(safeIndex / math.max(1, tonumber(total) or #self.stages), 0, 1)
        phaseText.Text = tostring(label or stage.label)
        phaseIcon.Image = stage.icon
        if self.Visible then
            phaseIcon.ImageTransparency = 1
            tween(phaseIcon, 0.2, { ImageTransparency = 0 })
        end
        updateProgress(true)
    end

    function controller:SetTarget(value)
        if self.Closed or type(value) ~= "string" or value == "" then return end
        self.targetName = value
        targetText.Text = value
        self:SetDetail(value .. " - Secure delivery in progress")
    end

    function controller:Close(immediate)
        if self.Closed then return end
        self.Closed = true
        if immediate or not screen.Parent then
            pcall(function() screen:Destroy() end)
            return
        end
        for _, object in ipairs(screen:GetDescendants()) do
            if object:IsA("TextLabel") then
                tween(object, 0.18, { TextTransparency = 1 })
            elseif object:IsA("ImageLabel") then
                tween(object, 0.18, { ImageTransparency = 1, BackgroundTransparency = 1 })
            elseif object:IsA("UIStroke") then
                tween(object, 0.18, { Transparency = 1 })
            elseif object:IsA("Frame") then
                tween(object, 0.18, { BackgroundTransparency = 1 })
            end
        end
        task.delay(0.23, function()
            pcall(function() screen:Destroy() end)
        end)
    end

    -- Keep compatibility with the original loader's controller contract.
    function controller:set(stageKey, detail)
        if self.Closed then return end
        if self.stageKey == stageKey and detail == nil then return end
        for index, stage in ipairs(self.stages) do
            if stage.key == stageKey then
                self:SetStep(index, #self.stages, stage.label)
                if type(detail) == "string" and detail ~= "" then self:SetDetail(detail) end
                return
            end
        end
    end
    function controller:setTarget(value) self:SetTarget(value) end
    function controller:close(immediate) self:Close(immediate) end

    updateProgress(false)

    task.spawn(function()
        tween(splashImage, 0.65, { ImageTransparency = 0 })
        task.wait(0.9)
        if controller.Closed or not screen.Parent then return end

        tween(splashImage, 0.48, { ImageTransparency = 1 })
        task.wait(0.52)
        if controller.Closed or not screen.Parent then return end
        splashImage.Visible = false
        controller.Visible = true

        -- Darken the gameplay only once the actual loading phase begins.
        tween(loadingBackdrop, 0.38, { BackgroundTransparency = 0.40 })

        local fadeObjects = {
            brandIcon, brandTitle, targetText, detailText, phaseIcon, phaseText,
            progressTrack, progressFill, stepCounter, percentLabel,
        }
        for _, object in ipairs(fadeObjects) do
            if object:IsA("ImageLabel") then
                tween(object, 0.32, { ImageTransparency = 0 })
            elseif object:IsA("TextLabel") then
                tween(object, 0.32, { TextTransparency = 0 })
            elseif object == progressTrack then
                tween(object, 0.32, { BackgroundTransparency = 0 })
            elseif object == progressFill then
                tween(object, 0.4, {
                    Size = UDim2.new(math.clamp(controller.progress, 0, 1), 0, 1, 0),
                    BackgroundTransparency = 0,
                })
            end
        end
    end)

    return controller
end

function StealthX:Window(GuiConfig)
  GuiConfig              = GuiConfig or {}
  GuiConfig.Title        = GuiConfig.Title or LibrarySettings.DefaultTitle
  GuiConfig.Footer       = GuiConfig.Footer or LibrarySettings.DefaultFooter
  local footerOptions = type(GuiConfig.Footer) == "table" and GuiConfig.Footer or nil
  local footerMessages = {}
  if footerOptions then
    local entries = footerOptions.Texts or footerOptions.Messages or footerOptions
    if type(entries) == "table" then
      for _, entry in ipairs(entries) do
        local message = tostring(entry)
        if message ~= "" then table.insert(footerMessages, message) end
      end
    end
  elseif tostring(GuiConfig.Footer) ~= "" then
    footerMessages[1] = tostring(GuiConfig.Footer)
  end
  GuiConfig.Icon         = GuiConfig.Icon or LibrarySettings.DefaultIcon
  GuiConfig.Image        = GuiConfig.Image or LibrarySettings.DefaultImage
  GuiConfig.Color        = GuiConfig.Color or Color3.fromRGB(255, 255, 255)
  GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or LibrarySettings.DefaultTabWidth
  if isMobile then
    GuiConfig["Tab Width"] = math.min(GuiConfig["Tab Width"], 110)
  end
  if GuiConfig.BackgroundImage == nil and GuiConfig.Theme == nil and GuiConfig.ThemeImage == nil then
    GuiConfig.BackgroundImage = LibrarySettings.DefaultBackground
  end
  if GuiConfig.ThemeTransparency == nil then GuiConfig.ThemeTransparency = 0 end
  if GuiConfig.Transparency == nil and GuiConfig.BackgroundTransparency == nil then
    GuiConfig.Transparency = 0.1
  end
  if GuiConfig.DisableDefaultToggleKey == nil then GuiConfig.DisableDefaultToggleKey = true end
  local userOptions = type(GuiConfig.User) == "table" and GuiConfig.User or {}
  local showUser = userOptions.Enabled ~= false
  local anonymousUser = userOptions.Anonymous == true
  GuiConfig.Version        = GuiConfig.Version or LibrarySettings.DefaultVersion
  GuiConfig.FloatingIcon   = GuiConfig.FloatingIcon or GuiConfig.Image or LibrarySettings.DefaultImage
  GuiConfig.FeatureSpacing = GuiConfig.FeatureSpacing or GuiConfig.ItemSpacing or LibrarySettings.DefaultFeatureSpacing
  GuiConfig.SectionSpacing = GuiConfig.SectionSpacing or LibrarySettings.DefaultSectionSpacing
  local cardColor = GuiConfig.CardColor or LibrarySettings.CardColor
  local cardTransparency = math.clamp(tonumber(GuiConfig.CardTransparency) or LibrarySettings.CardTransparency, 0, 1)
  local buttonColor = GuiConfig.ButtonColor or LibrarySettings.ButtonColor
  local buttonTransparency = math.clamp(tonumber(GuiConfig.ButtonTransparency) or LibrarySettings.ButtonTransparency, 0, 1)
  local controlColor = GuiConfig.ControlColor or LibrarySettings.ControlColor
  local controlTransparency = math.clamp(tonumber(GuiConfig.ControlTransparency) or LibrarySettings.ControlTransparency, 0, 1)
  local function styleCardSurface(frame, colorOverride, transparencyOverride)
    local surfaceTransparency = transparencyOverride
    if surfaceTransparency == nil then
      surfaceTransparency = cardTransparency
    else
      surfaceTransparency = math.clamp(tonumber(surfaceTransparency) or cardTransparency, 0, 1)
    end
    frame.BackgroundColor3 = colorOverride or cardColor
    frame.BackgroundTransparency = surfaceTransparency
    frame.BorderSizePixel = 0
    return frame
  end
  local function styleActionButton(button)
    button.BackgroundColor3 = buttonColor
    button.BackgroundTransparency = buttonTransparency
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(155, 155, 165)
    stroke.Transparency = 0.82
    stroke.Thickness = 1
    stroke.Parent = button
  end
  local function addActionButtonIcon(button, title, iconName)
    if iconName == nil or iconName == "" then return end
    local image = StealthX:GetIcon(iconName)
    if image == "" then return end
    button.Text = ""
    local content = Instance.new("Frame")
    content.Name = "ButtonContent"
    content.BackgroundTransparency = 1
    content.AnchorPoint = Vector2.new(0.5, 0.5)
    content.Position = UDim2.fromScale(0.5, 0.5)
    content.Size = UDim2.new(1, -12, 1, 0)
    content.ClipsDescendants = true
    content.Parent = button
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.BackgroundTransparency = 1
    icon.Image = image
    icon.ImageColor3 = button.TextColor3
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Size = UDim2.fromOffset(14, 14)
    icon.LayoutOrder = 1
    icon.Parent = content
    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.BackgroundTransparency = 1
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Size = UDim2.new(0, 0, 1, 0)
    label.Font = button.Font
    label.Text = title
    label.TextSize = button.TextSize
    label.TextColor3 = button.TextColor3
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.LayoutOrder = 2
    label.Parent = content
  end
  local function styleControlSurface(frame)
    frame.BackgroundColor3 = controlColor
    frame.BackgroundTransparency = controlTransparency
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(155, 155, 165)
    stroke.Transparency = 0.86
    stroke.Thickness = 1
    stroke.Parent = frame
  end
  local function animateActionButton(button, inputObject)
    local center = button.AbsolutePosition + button.AbsoluteSize / 2
    local x, y = center.X, center.Y
    if inputObject and (inputObject.UserInputType == Enum.UserInputType.MouseButton1
        or inputObject.UserInputType == Enum.UserInputType.Touch) then
      x, y = inputObject.Position.X, inputObject.Position.Y
    end
    circleClick(button, x, y)
  end
  configState.version        = GuiConfig.Version
  loadConfigFromFile()
  if GuiConfig.IconUrl then
    StealthX:RegisterIcons(GuiConfig.IconUrl)
  end
  if GuiConfig.Icons then
    StealthX:RegisterIcons(GuiConfig.Icons)
  end
  local GuiFunc = {}
  local StealthXGui = Instance.new("ScreenGui");
  local DropShadowHolder = Instance.new("Frame");
  local DropShadow = Instance.new("ImageLabel");
  local Main = Instance.new("Frame");
  local UICorner = Instance.new("UICorner");
  local Top = Instance.new("Frame");
  local TextLabel = Instance.new("TextLabel");
  local UICorner1 = Instance.new("UICorner");
  local TextLabel1 = Instance.new("TextLabel");
  local Close = Instance.new("TextButton");
  local ImageLabel1 = Instance.new("ImageLabel");
  local Min = Instance.new("TextButton");
  local ImageLabel2 = Instance.new("ImageLabel");
  local LayersTab = Instance.new("Frame");
  local UICorner2 = Instance.new("UICorner");
  local DecideFrame = Instance.new("Frame");
  local Layers = Instance.new("Frame");
  local UICorner6 = Instance.new("UICorner");
  local NameTab = Instance.new("TextLabel");
  local LayersReal = Instance.new("Frame");
  local LayersFolder = Instance.new("Folder");
  local LayersPageLayout = Instance.new("UIPageLayout");
  local DropdownSelect = nil
  StealthXGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  StealthXGui.Name = "StealthX"
  StealthXGui.ResetOnSpawn = false
  StealthXGui.Parent = game:GetService("CoreGui")
  DropShadowHolder.BackgroundTransparency = 1
  DropShadowHolder.BorderSizePixel = 0
  DropShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
  DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
  if isMobile then
    DropShadowHolder.Size = safeSize(520, 300)
  else
    DropShadowHolder.Size = safeSize(640, 412)
  end
  DropShadowHolder.ZIndex = 0
  DropShadowHolder.Name = "DropShadowHolder"
  DropShadowHolder.Parent = StealthXGui
  local spawnOffsetY = isMobile and math.floor(StealthXGui.AbsoluteSize.Y * 0.05) or 0
  DropShadowHolder.Position = UDim2.new(0.5, 0, 0.5, -spawnOffsetY)
  DropShadow.Image = "rbxassetid://6015897843"
  DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
  DropShadow.ImageTransparency = 1
  DropShadow.ScaleType = Enum.ScaleType.Slice
  DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
  DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
  DropShadow.BackgroundTransparency = 1
  DropShadow.BorderSizePixel = 0
  DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
  DropShadow.Size = UDim2.new(1, 47, 1, 47)
  DropShadow.ZIndex = 0
  DropShadow.Name = "DropShadow"
  DropShadow.Parent = DropShadowHolder
  local rawTransparency = GuiConfig.Transparency or GuiConfig.BackgroundTransparency or (not GuiConfig.Theme and GuiConfig.ThemeTransparency) or 0
  if type(rawTransparency) == "number" and rawTransparency > 1 then
    rawTransparency = rawTransparency / 100
  end
  rawTransparency = math.clamp(rawTransparency or 0, 0, 1)
  StealthX.CurrentTransparency = rawTransparency
  Main.AnchorPoint = Vector2.new(0.5, 0.5)
  Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  Main.BackgroundTransparency = 1
  Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
  Main.BorderSizePixel = 0
  Main.Position = UDim2.new(0.5, 0, 0.5, 0)
  Main.Size = UDim2.new(1, -47, 1, -47)
  Main.Name = "Main"
  Main.ZIndex = 1
  Main.Parent = DropShadow
  local MainRoundedBackground = Instance.new("Frame")
  MainRoundedBackground.Name = "MainRoundedBackground"
  MainRoundedBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  MainRoundedBackground.BackgroundTransparency = rawTransparency
  MainRoundedBackground.BorderSizePixel = 0
  MainRoundedBackground.ClipsDescendants = true
  MainRoundedBackground.AnchorPoint = Main.AnchorPoint
  MainRoundedBackground.Position = Main.Position
  MainRoundedBackground.Size = Main.Size
  MainRoundedBackground.ZIndex = 0
  MainRoundedBackground.Parent = DropShadow
  local MainRoundedCorner = Instance.new("UICorner")
  MainRoundedCorner.CornerRadius = UDim.new(0, 14)
  MainRoundedCorner.Parent = MainRoundedBackground
  local WindowBgImage = nil
  local DarkOverlay = nil
  local baseThemeTrans = GuiConfig.ThemeTransparency or GuiConfig.ImageTransparency or 0.15
  local baseOverlayTrans = GuiConfig.OverlayTransparency or 0.35
  local themeInput = GuiConfig.BackgroundImage or GuiConfig.Theme or GuiConfig.ThemeImage
  if themeInput and tostring(themeInput) ~= "" then
    WindowBgImage = Instance.new("ImageLabel")
    WindowBgImage.Name = "WindowBgImage"
    WindowBgImage.Image = resolveAsset(themeInput, "window_bg.jpg")
    WindowBgImage.ScaleType = Enum.ScaleType.Crop
    WindowBgImage.BackgroundTransparency = 1
    WindowBgImage.BorderSizePixel = 0
    WindowBgImage.Size = UDim2.new(1, 0, 1, 0)
    WindowBgImage.Position = UDim2.new(0, 0, 0, 0)
    WindowBgImage.ZIndex = 0
    WindowBgImage.ImageTransparency = math.clamp(rawTransparency + (1 - rawTransparency) * baseThemeTrans, 0, 1)
    WindowBgImage.Parent = MainRoundedBackground
    local BgImageCorner = Instance.new("UICorner")
    BgImageCorner.CornerRadius = UDim.new(0, 14)
    BgImageCorner.Parent = WindowBgImage
    DarkOverlay = Instance.new("Frame")
    DarkOverlay.Name = "DarkOverlay"
    DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DarkOverlay.BackgroundTransparency = math.clamp(rawTransparency + (1 - rawTransparency) * baseOverlayTrans, 0, 1)
    DarkOverlay.BorderSizePixel = 0
    DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
    DarkOverlay.Position = UDim2.new(0, 0, 0, 0)
    DarkOverlay.ZIndex = 1
    DarkOverlay.Parent = MainRoundedBackground
    local DarkCorner = Instance.new("UICorner")
    DarkCorner.CornerRadius = UDim.new(0, 14)
    DarkCorner.Parent = DarkOverlay
  end
  UICorner.CornerRadius = UDim.new(0, 14)
  UICorner.Parent = Main
  Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  Top.BackgroundTransparency = 0.9990000128746033
  Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
  Top.BorderSizePixel = 0
  Top.Size = UDim2.new(1, 0, 0, 42)
  Top.Name = "Top"
  Top.Parent = Main
  local TitleOffset = 12
  if GuiConfig.Icon and tostring(GuiConfig.Icon) ~= "" then
    local winIconSrc = StealthX:GetIcon(tostring(GuiConfig.Icon))
    if winIconSrc == "" then winIconSrc = tostring(GuiConfig.Icon) end
    if not tostring(winIconSrc):find("://") then
      winIconSrc = "rbxassetid://" .. tostring(winIconSrc)
    end
    local WinIcon = Instance.new("ImageLabel")
    WinIcon.Name = "WindowIcon"
    WinIcon.Image = winIconSrc
    WinIcon.BackgroundTransparency = 1
    WinIcon.ScaleType = Enum.ScaleType.Fit
    WinIcon.AnchorPoint = Vector2.new(0, 0.5)
    WinIcon.Position = UDim2.new(0, 12, 0.5, 0)
    WinIcon.Size = UDim2.fromOffset(20, 20)
    WinIcon.Parent = Top
    local WinIconCorner = Instance.new("UICorner")
    WinIconCorner.CornerRadius = UDim.new(0, 6)
    WinIconCorner.Parent = WinIcon
    TitleOffset = 12 + 20 + 8
  end
  local TitleHolder = Instance.new("Frame")
  TitleHolder.Name = "TitleHolder"
  TitleHolder.BackgroundTransparency = 1
  TitleHolder.BorderSizePixel = 0
  TitleHolder.AnchorPoint = Vector2.new(0, 0.5)
  TitleHolder.Position = UDim2.new(0, TitleOffset, 0.5, 0)
  TitleHolder.Size = UDim2.new(1, -(TitleOffset + 215), 0, 22)
  TitleHolder.ClipsDescendants = true
  TitleHolder.Parent = Top
  local TitleLayout = Instance.new("UIListLayout")
  TitleLayout.FillDirection = Enum.FillDirection.Horizontal
  TitleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
  TitleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
  TitleLayout.SortOrder = Enum.SortOrder.LayoutOrder
  TitleLayout.Padding = UDim.new(0, 6)
  TitleLayout.Parent = TitleHolder
  local function headerTextWidth(value, font, size)
    return math.ceil(TextService:GetTextSize(tostring(value), size, font, Vector2.new(10000, 22)).X) + 2
  end
  TextLabel.Name = "TitleText"
  TextLabel.LayoutOrder = 1
  TextLabel.Font = TextStyle.WindowTitle
  TextLabel.Text = GuiConfig.Title
  TextLabel.TextColor3 = GuiConfig.Color or Color3.fromRGB(255, 255, 255)
  TextLabel.TextSize = TextSize.WindowTitle
  TextLabel.Size = UDim2.new(0, headerTextWidth(GuiConfig.Title, TextStyle.WindowTitle, TextSize.WindowTitle), 1, 0)
  TextLabel.TextXAlignment = Enum.TextXAlignment.Left
  TextLabel.TextYAlignment = Enum.TextYAlignment.Center
  TextLabel.BackgroundTransparency = 1
  TextLabel.BorderSizePixel = 0
  TextLabel.Parent = TitleHolder
  UICorner1.Parent = Top
  local footerAnimationActive = false
  if #footerMessages > 0 and (#footerMessages > 1 or footerMessages[1] ~= tostring(GuiConfig.Title)) then
    local SepLabel = Instance.new("TextLabel")
    SepLabel.Name = "SepText"
    SepLabel.LayoutOrder = 2
    SepLabel.Font = TextStyle.WindowSubtitle
    SepLabel.Text = "|"
    SepLabel.TextColor3 = Color3.fromRGB(110, 110, 115)
    SepLabel.TextSize = TextSize.WindowSubtitle
    SepLabel.Size = UDim2.new(0, headerTextWidth("|", TextStyle.WindowSubtitle, TextSize.WindowSubtitle), 1, 0)
    SepLabel.TextXAlignment = Enum.TextXAlignment.Center
    SepLabel.TextYAlignment = Enum.TextYAlignment.Center
    SepLabel.BackgroundTransparency = 1
    SepLabel.BorderSizePixel = 0
    SepLabel.Parent = TitleHolder
    TextLabel1.Name = "FooterText"
    TextLabel1.LayoutOrder = 3
    TextLabel1.Font = TextStyle.WindowSubtitle
    TextLabel1.Text = #footerMessages > 1 and "" or footerMessages[1]
    TextLabel1.TextColor3 = Color3.fromRGB(185, 185, 190)
    TextLabel1.TextSize = TextSize.WindowSubtitle
    local footerWidth = 0
    for _, message in ipairs(footerMessages) do
      footerWidth = math.max(footerWidth, headerTextWidth(message, TextStyle.WindowSubtitle, TextSize.WindowSubtitle))
    end
    TextLabel1.Size = UDim2.new(0, footerWidth, 1, 0)
    TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel1.TextYAlignment = Enum.TextYAlignment.Center
    TextLabel1.BackgroundTransparency = 1
    TextLabel1.BorderSizePixel = 0
    TextLabel1.Parent = TitleHolder
    if #footerMessages > 1 then
      footerAnimationActive = true
      local typeSpeed = math.max(0.02, tonumber(footerOptions.TypeSpeed) or 0.055)
      local eraseSpeed = math.max(0.02, tonumber(footerOptions.EraseSpeed) or 0.03)
      local holdTime = math.max(0.1, tonumber(footerOptions.HoldTime) or 1.8)
      local prefixesByMessage = {}
      for index, message in ipairs(footerMessages) do
        local prefixes = {}
        local length = utf8.len(message)
        if length then
          for i = 1, length do
            local nextByte = utf8.offset(message, i + 1)
            prefixes[i] = message:sub(1, nextByte and nextByte - 1 or #message)
          end
        else
          for i = 1, #message do prefixes[i] = message:sub(1, i) end
        end
        prefixesByMessage[index] = prefixes
      end
      task.spawn(function()
        while footerAnimationActive do
          for _, prefixes in ipairs(prefixesByMessage) do
            for _, prefix in ipairs(prefixes) do
              if not footerAnimationActive then return end
              TextLabel1.Text = prefix
              task.wait(typeSpeed)
            end
            if not footerAnimationActive then return end
            task.wait(holdTime)
            for i = #prefixes - 1, 0, -1 do
              if not footerAnimationActive then return end
              TextLabel1.Text = prefixes[i] or ""
              task.wait(eraseSpeed)
            end
          end
        end
      end)
    end
  else
    TextLabel1.Visible = false
  end
  local SearchPill = Instance.new("Frame")
  SearchPill.Name = "SearchPill"
  SearchPill.AnchorPoint = Vector2.new(1, 0.5)
  SearchPill.Position = UDim2.new(1, -74, 0.5, 0)
  SearchPill.Size = UDim2.new(0, 120, 0, 26)
  styleCardSurface(SearchPill)
  SearchPill.Parent = Top
  local SearchCorner = Instance.new("UICorner")
  SearchCorner.CornerRadius = UDim.new(1, 0)
  SearchCorner.Parent = SearchPill
  local SearchStroke = Instance.new("UIStroke")
  SearchStroke.Name = "SearchStroke"
  SearchStroke.Color = Color3.fromRGB(175, 175, 185)
  SearchStroke.Thickness = 1
  SearchStroke.Transparency = 1
  SearchStroke.Parent = SearchPill
  local SearchIcon = Instance.new("ImageLabel")
  SearchIcon.Name = "SearchIcon"
  SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
  SearchIcon.Position = UDim2.new(0, 9, 0.5, 0)
  SearchIcon.Size = UDim2.new(0, 13, 0, 13)
  SearchIcon.BackgroundTransparency = 1
  SearchIcon.BorderSizePixel = 0
  SearchIcon.Image = "rbxassetid://6031154871"
  SearchIcon.ImageColor3 = Color3.fromRGB(160, 160, 165)
  SearchIcon.ScaleType = Enum.ScaleType.Fit
  SearchIcon.Parent = SearchPill
  local SearchBox = Instance.new("TextBox")
  SearchBox.Name = "SearchBox"
  SearchBox.Font = TextStyle.CardContent
  SearchBox.PlaceholderText = "Search"
  SearchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 145)
  SearchBox.Text = ""
  SearchBox.TextColor3 = Color3.fromRGB(240, 240, 245)
  SearchBox.TextSize = 12
  SearchBox.TextXAlignment = Enum.TextXAlignment.Left
  SearchBox.TextYAlignment = Enum.TextYAlignment.Center
  SearchBox.BackgroundTransparency = 1
  SearchBox.BorderSizePixel = 0
  SearchBox.ClearTextOnFocus = false
  SearchBox.AnchorPoint = Vector2.new(0, 0.5)
  SearchBox.Position = UDim2.new(0, 27, 0.5, -1)
  SearchBox.Size = UDim2.new(1, -52, 1, 0)
  SearchBox.Parent = SearchPill
  local SearchClear = Instance.new("TextButton")
  SearchClear.Name = "SearchClear"
  SearchClear.AnchorPoint = Vector2.new(1, 0.5)
  SearchClear.Position = UDim2.new(1, -5, 0.5, 0)
  SearchClear.Size = UDim2.new(0, 18, 0, 18)
  SearchClear.BackgroundTransparency = 1
  SearchClear.BorderSizePixel = 0
  SearchClear.AutoButtonColor = false
  SearchClear.Font = Enum.Font.GothamMedium
  SearchClear.Text = "×"
  SearchClear.TextColor3 = Color3.fromRGB(165, 165, 175)
  SearchClear.TextSize = 15
  SearchClear.TextXAlignment = Enum.TextXAlignment.Center
  SearchClear.TextYAlignment = Enum.TextYAlignment.Center
  SearchClear.Visible = false
  SearchClear.Parent = SearchPill
  local searchRestTransparency = cardTransparency
  local searchFocusTransparency = math.clamp(cardTransparency - 0.08, 0, 1)
  local searchFocusTweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  local function setSearchFocused(focused)
    TweenService:Create(SearchPill, searchFocusTweenInfo, {
      BackgroundTransparency = focused and searchFocusTransparency or searchRestTransparency,
    }):Play()
    TweenService:Create(SearchStroke, searchFocusTweenInfo, {
      Transparency = focused and 0.58 or 1,
    }):Play()
    TweenService:Create(SearchIcon, searchFocusTweenInfo, {
      ImageColor3 = focused and Color3.fromRGB(195, 195, 205) or Color3.fromRGB(160, 160, 165),
    }):Play()
  end
  SearchBox.Focused:Connect(function()
    setSearchFocused(true)
  end)
  SearchBox.FocusLost:Connect(function()
    setSearchFocused(false)
  end)
  SearchClear.Activated:Connect(function()
    if SearchBox.Text ~= "" then
      SearchBox.Text = ""
    end
    pcall(function()
      SearchBox:CaptureFocus()
    end)
  end)
  Close.Font = Enum.Font.SourceSans
  Close.Text = ""
  Close.TextColor3 = Color3.fromRGB(0, 0, 0)
  Close.TextSize = 14
  Close.AnchorPoint = Vector2.new(1, 0.5)
  Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  Close.BackgroundTransparency = 1
  Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
  Close.BorderSizePixel = 0
  Close.Position = UDim2.new(1, -8, 0.5, 0)
  Close.Size = UDim2.new(0, 25, 0, 25)
  Close.Name = "Close"
  Close.Parent = Top
  ImageLabel1.Image = "rbxassetid://9886659671"
  ImageLabel1.ImageColor3 = Color3.fromRGB(255, 255, 255)
  ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
  ImageLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  ImageLabel1.BackgroundTransparency = 1
  ImageLabel1.BorderSizePixel = 0
  ImageLabel1.Position = UDim2.new(0.49, 0, 0.5, 0)
  ImageLabel1.Size = UDim2.new(1, -8, 1, -8)
  ImageLabel1.ScaleType = Enum.ScaleType.Fit
  ImageLabel1.Parent = Close
  Min.Font = Enum.Font.SourceSans
  Min.Text = ""
  Min.TextColor3 = Color3.fromRGB(0, 0, 0)
  Min.TextSize = 14
  Min.AnchorPoint = Vector2.new(1, 0.5)
  Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  Min.BackgroundTransparency = 1
  Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
  Min.BorderSizePixel = 0
  Min.Position = UDim2.new(1, -38, 0.5, 0)
  Min.Size = UDim2.new(0, 25, 0, 25)
  Min.Name = "Min"
  Min.Parent = Top
  ImageLabel2.Image = "rbxassetid://9886659276"
  ImageLabel2.ImageColor3 = Color3.fromRGB(255, 255, 255)
  ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
  ImageLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  ImageLabel2.BackgroundTransparency = 1
  ImageLabel2.BorderSizePixel = 0
  ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
  ImageLabel2.Size = UDim2.new(1, -9, 1, -9)
  ImageLabel2.ImageTransparency = 0.2
  ImageLabel2.ScaleType = Enum.ScaleType.Fit
  ImageLabel2.Parent = Min
  local TopDivider = Instance.new("Frame")
  TopDivider.Name = "TopDivider"
  TopDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  TopDivider.BackgroundTransparency = 0.88
  TopDivider.BorderSizePixel = 0
  TopDivider.Position = UDim2.new(0, 0, 0, 42)
  TopDivider.Size = UDim2.new(1, 0, 0, 1)
  TopDivider.Parent = Main
  local TabWidth = GuiConfig["Tab Width"] or (isMobile and 110 or 140)
  LayersTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  LayersTab.BackgroundTransparency = 1
  LayersTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
  LayersTab.BorderSizePixel = 0
  LayersTab.Position = UDim2.new(0, isMobile and 4 or 8, 0, 43)
  LayersTab.Size = UDim2.new(0, TabWidth - (isMobile and 8 or 12), 1, -(43 + 40))
  LayersTab.Name = "LayersTab"
  LayersTab.Parent = Main
  UICorner2.CornerRadius = UDim.new(0, 8)
  UICorner2.Parent = LayersTab
  local SidebarDivider = Instance.new("Frame")
  SidebarDivider.Name = "SidebarDivider"
  SidebarDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  SidebarDivider.BackgroundTransparency = 0.90
  SidebarDivider.BorderSizePixel = 0
  SidebarDivider.Position = UDim2.new(0, TabWidth, 0, 43)
  SidebarDivider.Size = UDim2.new(0, 1, 1, -(43 + 40))
  SidebarDivider.Parent = Main
  Layers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  Layers.BackgroundTransparency = 1
  Layers.BorderColor3 = Color3.fromRGB(0, 0, 0)
  Layers.BorderSizePixel = 0
  Layers.Position = UDim2.new(0, TabWidth + 6, 0, 43)
  Layers.Size = UDim2.new(1, -(TabWidth + 12), 1, -(43 + 40))
  Layers.Name = "Layers"
  Layers.Parent = Main
  UICorner6.CornerRadius = UDim.new(0, 8)
  UICorner6.Parent = Layers
  NameTab.Font = Enum.Font.GothamBold
  NameTab.Text = ""
  NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
  NameTab.TextSize = 18
  NameTab.TextWrapped = true
  NameTab.TextXAlignment = Enum.TextXAlignment.Left
  NameTab.BackgroundTransparency = 1
  NameTab.BorderSizePixel = 0
  NameTab.Size = UDim2.new(1, 0, 0, 0)
  NameTab.Visible = false
  NameTab.Name = "NameTab"
  NameTab.Parent = Layers
  LayersReal.AnchorPoint = Vector2.new(0, 0)
  LayersReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  LayersReal.BackgroundTransparency = 1
  LayersReal.BorderSizePixel = 0
  LayersReal.ClipsDescendants = true
  LayersReal.Position = UDim2.new(0, 0, 0, 0)
  LayersReal.Size = UDim2.new(1, 0, 1, 0)
  LayersReal.Name = "LayersReal"
  LayersReal.Parent = Layers
  LayersFolder.Name = "LayersFolder"
  LayersFolder.Parent = LayersReal
  LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
  LayersPageLayout.Name = "LayersPageLayout"
  LayersPageLayout.Parent = LayersFolder
  LayersPageLayout.TweenTime = 0.5
  LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
  LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad
  local FooterDivider = Instance.new("Frame")
  FooterDivider.Name = "FooterDivider"
  FooterDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  FooterDivider.BackgroundTransparency = 0.88
  FooterDivider.BorderSizePixel = 0
  FooterDivider.Position = UDim2.new(0, 0, 1, -40)
  FooterDivider.Size = UDim2.new(1, 0, 0, 1)
  FooterDivider.Parent = Main
  local FooterFrame = Instance.new("Frame")
  FooterFrame.Name = "FooterFrame"
  FooterFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  FooterFrame.BackgroundTransparency = 1
  FooterFrame.BorderSizePixel = 0
  FooterFrame.Position = UDim2.new(0, 0, 1, -39)
  FooterFrame.Size = UDim2.new(1, 0, 0, 39)
  FooterFrame.Parent = Main
  local UserContainer = Instance.new("Frame")
  UserContainer.Name = "UserContainer"
  UserContainer.AnchorPoint = Vector2.new(0, 0.5)
  UserContainer.Position = UDim2.new(0, 12, 0.5, 0)
  UserContainer.Size = UDim2.new(0, 170, 0, 26)
  UserContainer.BackgroundTransparency = 1
  UserContainer.BorderSizePixel = 0
  UserContainer.Parent = FooterFrame
  UserContainer.Visible = showUser
  local AvatarImage = Instance.new("ImageLabel")
  AvatarImage.Name = "AvatarImage"
  AvatarImage.AnchorPoint = Vector2.new(0, 0.5)
  AvatarImage.Position = UDim2.new(0, 0, 0.5, 0)
  AvatarImage.Size = UDim2.new(0, 24, 0, 24)
  AvatarImage.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
  AvatarImage.BackgroundTransparency = 0
  AvatarImage.BorderSizePixel = 0
  AvatarImage.ScaleType = Enum.ScaleType.Fit
  AvatarImage.Image = "rbxassetid://108483430622128"
  AvatarImage.Parent = UserContainer
  local AvatarCorner = Instance.new("UICorner")
  AvatarCorner.CornerRadius = UDim.new(1, 0)
  AvatarCorner.Parent = AvatarImage
  spawn(function()
    pcall(function()
      if showUser and LocalPlayer and LocalPlayer.UserId and LocalPlayer.UserId > 0 then
        local thumb = game:GetService("Players"):GetUserThumbnailAsync(
          LocalPlayer.UserId,
          Enum.ThumbnailType.HeadShot,
          Enum.ThumbnailSize.Size48x48
        )
        if thumb and thumb ~= "" then
          AvatarImage.Image = thumb
        end
      end
    end)
  end)
  local UserNameLabel = Instance.new("TextLabel")
  UserNameLabel.Name = "UserNameLabel"
  UserNameLabel.Font = TextStyle.WindowSubtitle
  local playerName = (LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name)) or "User"
  UserNameLabel.Text = "Welcome, " .. (anonymousUser and "Anonymous" or playerName)
  UserNameLabel.TextColor3 = Color3.fromRGB(215, 215, 220)
  UserNameLabel.TextSize = 12
  UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left
  UserNameLabel.TextYAlignment = Enum.TextYAlignment.Center
  UserNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
  UserNameLabel.AnchorPoint = Vector2.new(0, 0.5)
  UserNameLabel.Position = UDim2.new(0, 32, 0.5, 0)
  UserNameLabel.Size = UDim2.new(1, -32, 1, 0)
  UserNameLabel.BackgroundTransparency = 1
  UserNameLabel.BorderSizePixel = 0
  UserNameLabel.Parent = UserContainer
  local BadgesContainer = Instance.new("Frame")
  BadgesContainer.Name = "BadgesContainer"
  BadgesContainer.AnchorPoint = Vector2.new(1, 0.5)
  BadgesContainer.Position = UDim2.new(1, -12, 0.5, 0)
  BadgesContainer.Size = UDim2.new(0, 340, 0, 24)
  BadgesContainer.BackgroundTransparency = 1
  BadgesContainer.BorderSizePixel = 0
  BadgesContainer.Parent = FooterFrame
  local BadgesLayout = Instance.new("UIListLayout")
  BadgesLayout.FillDirection = Enum.FillDirection.Horizontal
  BadgesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
  BadgesLayout.VerticalAlignment = Enum.VerticalAlignment.Center
  BadgesLayout.Padding = UDim.new(0, 6)
  BadgesLayout.SortOrder = Enum.SortOrder.LayoutOrder
  BadgesLayout.Parent = BadgesContainer
  local detectedExec = "Real"
  pcall(function()
    if typeof(identifyexecutor) == "function" then
      local n = identifyexecutor()
      if n and tostring(n) ~= "" then detectedExec = tostring(n) end
    end
  end)
  local ExecBadge = Instance.new("Frame")
  ExecBadge.Name = "ExecBadge"
  ExecBadge.LayoutOrder = 1
  styleCardSurface(ExecBadge)
  ExecBadge.AutomaticSize = Enum.AutomaticSize.X
  ExecBadge.Size = UDim2.new(0, 0, 0, 22)
  ExecBadge.Parent = BadgesContainer
  local ExecBadgeCorner = Instance.new("UICorner")
  ExecBadgeCorner.CornerRadius = UDim.new(0, 6)
  ExecBadgeCorner.Parent = ExecBadge
  local ExecBadgePadding = Instance.new("UIPadding")
  ExecBadgePadding.PaddingLeft = UDim.new(0, 8)
  ExecBadgePadding.PaddingRight = UDim.new(0, 8)
  ExecBadgePadding.Parent = ExecBadge
  local ExecBadgeLayout = Instance.new("UIListLayout")
  ExecBadgeLayout.FillDirection = Enum.FillDirection.Horizontal
  ExecBadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
  ExecBadgeLayout.Padding = UDim.new(0, 4)
  ExecBadgeLayout.SortOrder = Enum.SortOrder.LayoutOrder
  ExecBadgeLayout.Parent = ExecBadge
  local ExecIcon = Instance.new("ImageLabel")
  ExecIcon.Name = "ExecIcon"
  ExecIcon.LayoutOrder = 1
  ExecIcon.Size = UDim2.new(0, 12, 0, 12)
  ExecIcon.BackgroundTransparency = 1
  ExecIcon.BorderSizePixel = 0
  local execIconSrc = StealthX:GetIcon("programming-bold")
  if not execIconSrc or execIconSrc == "" then execIconSrc = "rbxassetid://71466343335951" end
  ExecIcon.Image = execIconSrc
  ExecIcon.ImageColor3 = Color3.fromRGB(195, 195, 200)
  ExecIcon.ScaleType = Enum.ScaleType.Fit
  ExecIcon.Parent = ExecBadge
  local ExecBadgeText = Instance.new("TextLabel")
  ExecBadgeText.Name = "ExecBadgeText"
  ExecBadgeText.LayoutOrder = 2
  ExecBadgeText.Font = TextStyle.WindowSubtitle
  ExecBadgeText.Text = "Executor : " .. detectedExec
  ExecBadgeText.TextColor3 = Color3.fromRGB(195, 195, 200)
  ExecBadgeText.TextSize = 11
  ExecBadgeText.AutomaticSize = Enum.AutomaticSize.X
  ExecBadgeText.Size = UDim2.new(0, 0, 1, 0)
  ExecBadgeText.TextXAlignment = Enum.TextXAlignment.Center
  ExecBadgeText.TextYAlignment = Enum.TextYAlignment.Center
  ExecBadgeText.BackgroundTransparency = 1
  ExecBadgeText.BorderSizePixel = 0
  ExecBadgeText.Parent = ExecBadge
  local FpsBadge = Instance.new("Frame")
  FpsBadge.Name = "FpsBadge"
  FpsBadge.LayoutOrder = 2
  styleCardSurface(FpsBadge)
  FpsBadge.AutomaticSize = Enum.AutomaticSize.X
  FpsBadge.Size = UDim2.new(0, 0, 0, 22)
  FpsBadge.Parent = BadgesContainer
  local FpsBadgeCorner = Instance.new("UICorner")
  FpsBadgeCorner.CornerRadius = UDim.new(0, 6)
  FpsBadgeCorner.Parent = FpsBadge
  local FpsBadgePadding = Instance.new("UIPadding")
  FpsBadgePadding.PaddingLeft = UDim.new(0, 8)
  FpsBadgePadding.PaddingRight = UDim.new(0, 8)
  FpsBadgePadding.Parent = FpsBadge
  local FpsBadgeLayout = Instance.new("UIListLayout")
  FpsBadgeLayout.FillDirection = Enum.FillDirection.Horizontal
  FpsBadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
  FpsBadgeLayout.Padding = UDim.new(0, 4)
  FpsBadgeLayout.SortOrder = Enum.SortOrder.LayoutOrder
  FpsBadgeLayout.Parent = FpsBadge
  local FpsIcon = Instance.new("ImageLabel")
  FpsIcon.Name = "FpsIcon"
  FpsIcon.LayoutOrder = 1
  FpsIcon.Size = UDim2.new(0, 12, 0, 12)
  FpsIcon.BackgroundTransparency = 1
  FpsIcon.BorderSizePixel = 0
  local fpsIconSrc = StealthX:GetIcon("chart-square-bold")
  if not fpsIconSrc or fpsIconSrc == "" then fpsIconSrc = "rbxassetid://73897886601288" end
  FpsIcon.Image = fpsIconSrc
  FpsIcon.ImageColor3 = Color3.fromRGB(195, 195, 200)
  FpsIcon.ScaleType = Enum.ScaleType.Fit
  FpsIcon.Parent = FpsBadge
  local FpsText = Instance.new("TextLabel")
  FpsText.Name = "FpsText"
  FpsText.LayoutOrder = 2
  FpsText.Font = TextStyle.WindowSubtitle
  FpsText.Text = "60 FPS"
  FpsText.TextColor3 = Color3.fromRGB(195, 195, 200)
  FpsText.TextSize = 11
  FpsText.AutomaticSize = Enum.AutomaticSize.X
  FpsText.Size = UDim2.new(0, 0, 1, 0)
  FpsText.TextXAlignment = Enum.TextXAlignment.Center
  FpsText.TextYAlignment = Enum.TextYAlignment.Center
  FpsText.BackgroundTransparency = 1
  FpsText.BorderSizePixel = 0
  FpsText.Parent = FpsBadge
  local frameCount = 0
  local lastFpsTime = tick()
  local fpsConnection = game:GetService("RunService").RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsTime >= 0.8 then
      local fps = math.floor(frameCount / (now - lastFpsTime))
      FpsText.Text = tostring(fps) .. " FPS"
      frameCount = 0
      lastFpsTime = now
    end
  end)
  if isMobile then
    ExecBadge.Visible = false
  end
  if GuiConfig.ExecutorBadge == false or GuiConfig.HideExecutor == true then
    ExecBadge.Visible = false
  end
  if GuiConfig.FpsBadge == false or GuiConfig.HideFps == true then
    FpsBadge.Visible = false
  end
  GuiFunc.ExecBadge = ExecBadge
  GuiFunc.FpsBadge = FpsBadge
  function GuiFunc:Badge(badgeConfig)
    badgeConfig = badgeConfig or {}
    local title = badgeConfig.Title or badgeConfig.Name or badgeConfig.Text or "Badge"
    local rawIcon = badgeConfig.Icon or badgeConfig.Image
    local color = badgeConfig.Color or badgeConfig.TextColor or Color3.fromRGB(195, 195, 200)
    local iconColor = badgeConfig.IconColor or color
    local bgColor = badgeConfig.BackgroundColor or cardColor
    local bgTrans = badgeConfig.BackgroundTransparency or badgeConfig.Transparency or cardTransparency
    local BadgeFrame = Instance.new("Frame")
    BadgeFrame.Name = "CustomBadge"
    BadgeFrame.LayoutOrder = badgeConfig.LayoutOrder or 0
    styleCardSurface(BadgeFrame, bgColor, bgTrans)
    BadgeFrame.AutomaticSize = Enum.AutomaticSize.X
    BadgeFrame.Size = UDim2.new(0, 0, 0, 22)
    BadgeFrame.Parent = BadgesContainer
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 6)
    BadgeCorner.Parent = BadgeFrame
    local BadgePadding = Instance.new("UIPadding")
    BadgePadding.PaddingLeft = UDim.new(0, 8)
    BadgePadding.PaddingRight = UDim.new(0, 8)
    BadgePadding.Parent = BadgeFrame
    local BadgeLayout = Instance.new("UIListLayout")
    BadgeLayout.FillDirection = Enum.FillDirection.Horizontal
    BadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BadgeLayout.Padding = UDim.new(0, 4)
    BadgeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    BadgeLayout.Parent = BadgeFrame
    local BadgeIcon = nil
    if rawIcon and tostring(rawIcon) ~= "" then
      BadgeIcon = Instance.new("ImageLabel")
      BadgeIcon.Name = "BadgeIcon"
      BadgeIcon.LayoutOrder = 1
      BadgeIcon.Size = UDim2.new(0, 12, 0, 12)
      BadgeIcon.BackgroundTransparency = 1
      BadgeIcon.BorderSizePixel = 0
      BadgeIcon.ScaleType = Enum.ScaleType.Fit
      local iconSrc = StealthX:GetIcon(tostring(rawIcon))
      if not iconSrc or iconSrc == "" then iconSrc = tostring(rawIcon) end
      if not iconSrc:find("://") and iconSrc:match("^%d+$") then
        iconSrc = "rbxassetid://" .. iconSrc
      end
      BadgeIcon.Image = iconSrc
      BadgeIcon.ImageColor3 = iconColor
      BadgeIcon.Parent = BadgeFrame
    end
    local BadgeText = Instance.new("TextLabel")
    BadgeText.Name = "BadgeText"
    BadgeText.LayoutOrder = 2
    BadgeText.Font = TextStyle.WindowSubtitle
    BadgeText.Text = title
    BadgeText.TextColor3 = color
    BadgeText.TextSize = 11
    BadgeText.AutomaticSize = Enum.AutomaticSize.X
    BadgeText.Size = UDim2.new(0, 0, 1, 0)
    BadgeText.TextXAlignment = Enum.TextXAlignment.Center
    BadgeText.TextYAlignment = Enum.TextYAlignment.Center
    BadgeText.BackgroundTransparency = 1
    BadgeText.BorderSizePixel = 0
    BadgeText.Parent = BadgeFrame
    local badgeObj = {
      Frame = BadgeFrame,
      TextLabel = BadgeText,
      Icon = BadgeIcon,
    }
    function badgeObj:SetTitle(newTitle)
      BadgeText.Text = tostring(newTitle)
    end
    badgeObj.SetText = badgeObj.SetTitle
    function badgeObj:SetIcon(newIcon)
      if not BadgeIcon then
        BadgeIcon = Instance.new("ImageLabel")
        BadgeIcon.Name = "BadgeIcon"
        BadgeIcon.Size = UDim2.new(0, 12, 0, 12)
        BadgeIcon.BackgroundTransparency = 1
        BadgeIcon.BorderSizePixel = 0
        BadgeIcon.ScaleType = Enum.ScaleType.Fit
        BadgeIcon.LayoutOrder = 0
        BadgeIcon.Parent = BadgeFrame
        BadgeText.LayoutOrder = 1
      end
      local iconSrc = StealthX:GetIcon(tostring(newIcon))
      if not iconSrc or iconSrc == "" then iconSrc = tostring(newIcon) end
      if not iconSrc:find("://") and iconSrc:match("^%d+$") then
        iconSrc = "rbxassetid://" .. iconSrc
      end
      BadgeIcon.Image = iconSrc
    end
    function badgeObj:Destroy()
      pcall(function() BadgeFrame:Destroy() end)
    end
    return badgeObj
  end
  GuiFunc.Tag = GuiFunc.Badge
  GuiFunc.AddBadge = GuiFunc.Badge
  SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    SearchClear.Visible = SearchBox.Text ~= ""
    local q = string.lower(SearchBox.Text)
    local curLayer = LayersPageLayout.CurrentPage
    if curLayer and curLayer:IsA("ScrollingFrame") then
      for _, sec in curLayer:GetChildren() do
        if sec.Name == "Section" and sec:FindFirstChild("SectionReal") then
          local secTitle = sec.SectionReal:FindFirstChild("SectionTitle")
          local secMatch = secTitle and string.find(string.lower(secTitle.Text), q, 1, true)
          local anyItemMatch = false
          local secAdd = sec:FindFirstChild("SectionAdd")
          if secAdd then
            for _, item in secAdd:GetChildren() do
              if item:IsA("GuiObject") and item.Name ~= "UIListLayout" and item.Name ~= "UICorner" then
                local itemTitle = item:FindFirstChildWhichIsA("TextLabel")
                local match = (q == "") or (itemTitle and string.find(string.lower(itemTitle.Text), q, 1, true))
                item.Visible = match and true or false
                if match then anyItemMatch = true end
              end
            end
          end
          sec.Visible = (q == "") or secMatch or anyItemMatch
        end
      end
    end
  end)
  LayersPageLayout.TweenTime = 0.5
  LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
  LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad
  local ScrollTab = Instance.new("ScrollingFrame");
  local UIListLayout = Instance.new("UIListLayout");
  ScrollTab.CanvasSize = UDim2.new(0, 0, 1.10000002, 0)
  ScrollTab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
  ScrollTab.ScrollBarThickness = 0
  ScrollTab.Active = true
  ScrollTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  ScrollTab.BackgroundTransparency = 1
  ScrollTab.BorderColor3 = Color3.fromRGB(0, 0, 0)
  ScrollTab.BorderSizePixel = 0
  ScrollTab.Size = UDim2.new(1, 0, 1, 0)
  ScrollTab.Name = "ScrollTab"
  ScrollTab.Parent = LayersTab
  local ScrollTabPadding = Instance.new("UIPadding")
  ScrollTabPadding.Name = "ScrollTabPadding"
  ScrollTabPadding.PaddingLeft = UDim.new(0, 4)
  ScrollTabPadding.PaddingRight = UDim.new(0, 4)
  ScrollTabPadding.PaddingTop = UDim.new(0, 8)
  ScrollTabPadding.PaddingBottom = UDim.new(0, 6)
  ScrollTabPadding.Parent = ScrollTab
  UIListLayout.Padding = UDim.new(0, 4)
  UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
  UIListLayout.Parent = ScrollTab
  local function UpdateSize1()
    local contentHeight = UIListLayout.AbsoluteContentSize.Y
    local canvasSize = UDim2.fromOffset(0, contentHeight + (contentHeight > 0 and 12 or 8))
    if ScrollTab.CanvasSize ~= canvasSize then ScrollTab.CanvasSize = canvasSize end
  end
  UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize1)
  UpdateSize1()
  local destroyCallbacks = {}
  local isDestroyed = false
  local function fireDestroyCallbacks()
    if isDestroyed then return end
    isDestroyed = true
    for _, cb in ipairs(destroyCallbacks) do
      pcall(cb)
    end
    table.clear(destroyCallbacks)
  end
  function GuiFunc:OnDestroy(callback)
    if type(callback) == "function" then
      if isDestroyed then
        task.spawn(callback)
      else
        table.insert(destroyCallbacks, callback)
      end
    end
  end
  GuiFunc.OnClose = GuiFunc.OnDestroy
  GuiFunc:OnDestroy(function() fpsConnection:Disconnect() end)
  GuiFunc:OnDestroy(function() footerAnimationActive = false end)
  if type(GuiConfig.OnClose) == "function" then
    GuiFunc:OnDestroy(GuiConfig.OnClose)
  end
  if type(GuiConfig.OnDestroy) == "function" then
    GuiFunc:OnDestroy(GuiConfig.OnDestroy)
  end
  pcall(function()
    StealthXGui.Destroying:Connect(fireDestroyCallbacks)
  end)
  function GuiFunc:DestroyGui()
    fireDestroyCallbacks()
    if GuiFunc._floatingGui then
      pcall(function() GuiFunc._floatingGui:Destroy() end)
      GuiFunc._floatingGui = nil
    end
    if genv._stealthxFloat then
      pcall(function() genv._stealthxFloat:Destroy() end)
      genv._stealthxFloat = nil
    end
    if genv._stxFloat then
      pcall(function() genv._stxFloat:Destroy() end)
      genv._stxFloat = nil
    end
    local container = getGuiContainer()
    for _, name in ipairs({ "codexAlphaIcon", "stealthxIcon", "ToggleUIButton" }) do
      local found = container:FindFirstChild(name) or CoreGui:FindFirstChild(name)
      if found then
        pcall(function() found:Destroy() end)
      end
    end
    if StealthXGui then
      StealthXGui:Destroy()
    elseif CoreGui:FindFirstChild("StealthX") then
      CoreGui.StealthX:Destroy()
    elseif CoreGui:FindFirstChild("Chloeex") then
      CoreGui.Chloeex:Destroy()
    end
  end
  function GuiFunc:Toggle()
    if DropShadowHolder then
      DropShadowHolder.Visible = not DropShadowHolder.Visible
    end
  end
  function GuiFunc:SetVisible(state)
    if DropShadowHolder then
      DropShadowHolder.Visible = state and true or false
    end
  end
  function GuiFunc:SetTransparency(transparency)
    if type(transparency) == "number" and transparency > 1 then
      transparency = transparency / 100
    end
    transparency = math.clamp(transparency or 0, 0, 1)
    StealthX.CurrentTransparency = transparency
    if MainRoundedBackground then
      MainRoundedBackground.BackgroundTransparency = transparency
    end
    local thTrans = GuiConfig.ThemeTransparency or GuiConfig.ImageTransparency or 0.15
    local ovTrans = GuiConfig.OverlayTransparency or 0.35
    if WindowBgImage then
      WindowBgImage.ImageTransparency = math.clamp(transparency + (1 - transparency) * thTrans, 0, 1)
    end
    if DarkOverlay then
      DarkOverlay.BackgroundTransparency = math.clamp(transparency + (1 - transparency) * ovTrans, 0, 1)
    end
    if DropdownSelect then
      DropdownSelect.BackgroundTransparency = transparency
    end
  end
  function GuiFunc:SetThemeTransparency(trans)
    if type(trans) == "number" and trans > 1 then trans = trans / 100 end
    trans = math.clamp(trans or 0, 0, 1)
    GuiConfig.ThemeTransparency = trans
    local curTrans = StealthX.CurrentTransparency or 0
    if WindowBgImage then
      WindowBgImage.ImageTransparency = math.clamp(curTrans + (1 - curTrans) * trans, 0, 1)
    end
  end
  function GuiFunc:SetOverlayTransparency(trans)
    if type(trans) == "number" and trans > 1 then trans = trans / 100 end
    trans = math.clamp(trans or 0, 0, 1)
    GuiConfig.OverlayTransparency = trans
    local curTrans = StealthX.CurrentTransparency or 0
    if DarkOverlay then
      DarkOverlay.BackgroundTransparency = math.clamp(curTrans + (1 - curTrans) * trans, 0, 1)
    end
  end
  function GuiFunc:SetBackgroundImage(assetInput, themeTrans, overlayTrans)
    if themeTrans then GuiConfig.ThemeTransparency = themeTrans end
    if overlayTrans then GuiConfig.OverlayTransparency = overlayTrans end
    if not assetInput or assetInput == "" then
      if WindowBgImage then WindowBgImage.Visible = false end
      if DarkOverlay then DarkOverlay.Visible = false end
      return
    end
    local resolved = resolveAsset(assetInput, "window_bg.jpg")
    if not WindowBgImage then
      WindowBgImage = Instance.new("ImageLabel")
      WindowBgImage.Name = "WindowBgImage"
      WindowBgImage.ScaleType = Enum.ScaleType.Crop
      WindowBgImage.BackgroundTransparency = 1
      WindowBgImage.BorderSizePixel = 0
      WindowBgImage.Size = UDim2.new(1, 0, 1, 0)
      WindowBgImage.Position = UDim2.new(0, 0, 0, 0)
      WindowBgImage.ZIndex = 0
      WindowBgImage.Parent = MainRoundedBackground
      local DynamicBgCorner = Instance.new("UICorner")
      DynamicBgCorner.CornerRadius = UDim.new(0, 14)
      DynamicBgCorner.Parent = WindowBgImage
    end
    if not DarkOverlay then
      DarkOverlay = Instance.new("Frame")
      DarkOverlay.Name = "DarkOverlay"
      DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
      DarkOverlay.BorderSizePixel = 0
      DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
      DarkOverlay.Position = UDim2.new(0, 0, 0, 0)
      DarkOverlay.ZIndex = 1
      DarkOverlay.Parent = MainRoundedBackground
      local DynamicDarkCorner = Instance.new("UICorner")
      DynamicDarkCorner.CornerRadius = UDim.new(0, 14)
      DynamicDarkCorner.Parent = DarkOverlay
    end
    WindowBgImage.Image = resolved
    WindowBgImage.Visible = true
    DarkOverlay.Visible = true
    GuiFunc:SetTransparency(StealthX.CurrentTransparency or 0)
  end
  GuiFunc.Main = Main
  GuiFunc.Background = MainRoundedBackground
  GuiFunc.BackgroundImage = WindowBgImage
  GuiFunc.DarkOverlay = DarkOverlay
  Min.Activated:Connect(function()
    PlayUISound()
    DropShadowHolder.Visible = false
  end)
  Close.Activated:Connect(function()
    PlayUISound()
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.3
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 50
    Overlay.Parent = DropShadowHolder
    local OverlayCorner = Instance.new("UICorner")
    OverlayCorner.CornerRadius = UDim.new(0, 14)
    OverlayCorner.Parent = Overlay
    local Dialog = Instance.new("Frame")
    Dialog.Size = UDim2.new(0, 300, 0, 150)
    Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    Dialog.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    Dialog.BackgroundTransparency = 0
    Dialog.BorderSizePixel = 0
    Dialog.ZIndex = 51
    Dialog.ClipsDescendants = true
    Dialog.Parent = Overlay
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 9)
    UICorner.Parent = Dialog
    local DialogStroke = Instance.new("UIStroke")
    DialogStroke.Color = Color3.fromRGB(58, 58, 58)
    DialogStroke.Thickness = 1
    DialogStroke.Transparency = 0.15
    DialogStroke.Parent = Dialog
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 4)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "StealthX Window"
    Title.TextSize = 22
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.ZIndex = 52
    Title.Parent = Dialog
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -20, 0, 60)
    Message.Position = UDim2.new(0, 10, 0, 30)
    Message.BackgroundTransparency = 1
    Message.Font = Enum.Font.Gotham
    Message.Text = "Do you want to close this window?\nYou will not be able to open it again"
    Message.TextSize = 14
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextWrapped = true
    Message.ZIndex = 52
    Message.Parent = Dialog
    local Yes = Instance.new("TextButton")
    Yes.Size = UDim2.new(0.45, -10, 0, 35)
    Yes.Position = UDim2.new(0.05, 0, 1, -55)
    Yes.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Yes.BackgroundTransparency = 0
    Yes.Text = "Yes"
    Yes.Font = Enum.Font.GothamBold
    Yes.TextSize = 15
    Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
    Yes.TextTransparency = 0.3
    Yes.ZIndex = 52
    Yes.Name = "Yes"
    Yes.Parent = Dialog
    Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)
    local Cancel = Instance.new("TextButton")
    Cancel.Size = UDim2.new(0.45, -10, 0, 35)
    Cancel.Position = UDim2.new(0.5, 10, 1, -55)
    Cancel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Cancel.BackgroundTransparency = 0
    Cancel.Text = "Cancel"
    Cancel.Font = Enum.Font.GothamBold
    Cancel.TextSize = 15
    Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
    Cancel.TextTransparency = 0.3
    Cancel.ZIndex = 52
    Cancel.Name = "Cancel"
    Cancel.Parent = Dialog
    Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)
    Yes.MouseButton1Click:Connect(function()
      PlayUISound()
      GuiFunc:DestroyGui()
    end)
    Cancel.MouseButton1Click:Connect(function()
      PlayUISound()
      Overlay:Destroy()
    end)
  end)
  if not GuiConfig.DisableDefaultToggleKey then
    local defaultToggleConnection = UserInputService.InputBegan:Connect(function(input, gpe)
      if gpe then return end
      if input.KeyCode == Enum.KeyCode.F3 then
        GuiFunc:Toggle()
      end
    end)
    GuiFunc:OnDestroy(function() defaultToggleConnection:Disconnect() end)
  end
  function GuiFunc:ToggleUI()
    if GuiConfig.HideFloatingIcon then return end
    if genv._stealthxFloat then
      pcall(function()
        genv._stealthxFloat:Destroy()
      end)
      genv._stealthxFloat = nil
    end
    if genv._stxFloat then
      pcall(function()
        genv._stxFloat:Destroy()
      end)
      genv._stxFloat = nil
    end
    local container = getGuiContainer()
    local existing = container:FindFirstChild("codexAlphaIcon")
      or container:FindFirstChild("stealthxIcon")
      or container:FindFirstChild("ToggleUIButton")
      or CoreGui:FindFirstChild("ToggleUIButton")
    if existing then
      pcall(function()
        existing:Destroy()
      end)
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "codexAlphaIcon"
    ScreenGui.DisplayOrder = 9999
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame")
    frame.Name = "FloatingFrame"
    frame.Position = GuiConfig.FloatingIconPosition or UDim2.new(1, -55, 0, 55)
    frame.Size = UDim2.fromOffset(45, 45)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    frame.BorderSizePixel = 0
    frame.ZIndex = 9999
    frame.Parent = ScreenGui
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 1
    stroke.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    local icon = Instance.new("ImageLabel")
    local _rawFloatIcon = GuiConfig.FloatingIcon or GuiConfig.Image or "137459328873840"
    local _resolvedFloatIcon = StealthX:GetIcon(tostring(_rawFloatIcon))
    if not _resolvedFloatIcon or _resolvedFloatIcon == "" or _resolvedFloatIcon == tostring(_rawFloatIcon) then
      if not tostring(_rawFloatIcon):find("://") then
        _resolvedFloatIcon = "rbxassetid://" .. tostring(_rawFloatIcon)
      else
        _resolvedFloatIcon = tostring(_rawFloatIcon)
      end
    end
    icon.Image = _resolvedFloatIcon
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(1, -4, 1, -4)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Parent = frame
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 10)
    iconCorner.Parent = icon
    ScreenGui.Parent = container
    genv._stealthxFloat = ScreenGui
    GuiFunc._floatingGui = ScreenGui
    local origDestroy = GuiFunc.DestroyGui
    GuiFunc.DestroyGui = function(...)
      if genv._stealthxFloat then
        pcall(function()
          genv._stealthxFloat:Destroy()
        end)
        genv._stealthxFloat = nil
      end
      if origDestroy then
        return origDestroy(...)
      end
    end
    frame.InputBegan:Connect(function(input)
      local isTouch = input.UserInputType == Enum.UserInputType.Touch
      local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
      if not (isTouch or isMouse) then
        return
      end
      local dragStart = input.Position
      local startPos = frame.Position
      local moved = false
      local active = true
      local function move(position)
        if not active then
          return
        end
        if not moved and (position - dragStart).Magnitude > 6 then
          moved = true
        end
        if moved then
          local delta = position - dragStart
          frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
          )
        end
      end
      local function finish()
        if not active then
          return
        end
        active = false
        if not moved and GuiFunc and GuiFunc.Toggle then
          pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://5852470908"
            sound.Volume = 1
            sound.RollOffMaxDistance = 0
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 3)
          end)
          GuiFunc:Toggle()
        end
      end
      if isTouch then
        local moveConn, endConn
        moveConn = input.Changed:Connect(function()
          move(input.Position)
        end)
        endConn = input.Changed:Connect(function()
          if input.UserInputState == Enum.UserInputState.End then
            if moveConn then moveConn:Disconnect() end
            if endConn then endConn:Disconnect() end
            finish()
          end
        end)
      else
        local moveConn, endConn
        moveConn = UserInputService.InputChanged:Connect(function(changed)
          if changed.UserInputType == Enum.UserInputType.MouseMovement then
            move(changed.Position)
          end
        end)
        endConn = UserInputService.InputEnded:Connect(function(ended)
          if ended.UserInputType == Enum.UserInputType.MouseButton1 then
            if moveConn then moveConn:Disconnect() end
            if endConn then endConn:Disconnect() end
            finish()
          end
        end)
      end
    end)
    return ScreenGui
  end
  GuiFunc:ToggleUI()
  GuiFunc:OnDestroy(MakeDraggable(Top, DropShadowHolder))
  local MoreBlur = Instance.new("Frame");
  local DropShadowHolder1 = Instance.new("Frame");
  local DropShadow1 = Instance.new("ImageLabel");
  local UICorner28 = Instance.new("UICorner");
  local ConnectButton = Instance.new("TextButton");
  MoreBlur.AnchorPoint = Vector2.new(1, 1)
  MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  MoreBlur.BackgroundTransparency = 0.999
  MoreBlur.BorderColor3 = Color3.fromRGB(0, 0, 0)
  MoreBlur.BorderSizePixel = 0
  MoreBlur.ClipsDescendants = true
  MoreBlur.Position = UDim2.new(1, 8, 1, 8)
  MoreBlur.Size = UDim2.new(1, 154, 1, 54)
  MoreBlur.Visible = false
  MoreBlur.Name = "MoreBlur"
  MoreBlur.Parent = Layers
  DropShadowHolder1.BackgroundTransparency = 1
  DropShadowHolder1.BorderSizePixel = 0
  DropShadowHolder1.Size = UDim2.new(1, 0, 1, 0)
  DropShadowHolder1.ZIndex = 0
  DropShadowHolder1.Name = "DropShadowHolder"
  DropShadowHolder1.Parent = MoreBlur
  DropShadow1.Image = "rbxassetid://6015897843"
  DropShadow1.ImageColor3 = Color3.fromRGB(0, 0, 0)
  DropShadow1.ImageTransparency = 1
  DropShadow1.ScaleType = Enum.ScaleType.Slice
  DropShadow1.SliceCenter = Rect.new(49, 49, 450, 450)
  DropShadow1.AnchorPoint = Vector2.new(0.5, 0.5)
  DropShadow1.BackgroundTransparency = 1
  DropShadow1.BorderSizePixel = 0
  DropShadow1.Position = UDim2.new(0.5, 0, 0.5, 0)
  DropShadow1.Size = UDim2.new(1, 35, 1, 35)
  DropShadow1.ZIndex = 0
  DropShadow1.Name = "DropShadow"
  DropShadow1.Parent = DropShadowHolder1
  UICorner28.Parent = MoreBlur
  ConnectButton.Font = Enum.Font.SourceSans
  ConnectButton.Text = ""
  ConnectButton.TextColor3 = Color3.fromRGB(0, 0, 0)
  ConnectButton.TextSize = 14
  ConnectButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  ConnectButton.BackgroundTransparency = 0.999
  ConnectButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
  ConnectButton.BorderSizePixel = 0
  ConnectButton.Size = UDim2.new(1, 0, 1, 0)
  ConnectButton.Name = "ConnectButton"
  ConnectButton.Parent = MoreBlur
  DropdownSelect = Instance.new("Frame");
  local UICorner36 = Instance.new("UICorner");
  local UIStroke14 = Instance.new("UIStroke");
  local DropdownSelectReal = Instance.new("Frame");
  local DropdownFolder = Instance.new("Folder");
  local DropPageLayout = Instance.new("UIPageLayout");
  DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
  DropdownSelect.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  DropdownSelect.BackgroundTransparency = rawTransparency
  DropdownSelect.BorderColor3 = Color3.fromRGB(0, 0, 0)
  DropdownSelect.BorderSizePixel = 0
  DropdownSelect.LayoutOrder = 1
  DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
  DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
  DropdownSelect.Name = "DropdownSelect"
  DropdownSelect.ClipsDescendants = true
  DropdownSelect.Parent = MoreBlur
  ConnectButton.Activated:Connect(function()
    if MoreBlur.Visible then
      PlayUISound()
      TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.999 }):Play()
      TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
      task.wait(0.3)
      MoreBlur.Visible = false
    end
  end)
  UICorner36.CornerRadius = UDim.new(0, 8)
  UICorner36.Parent = DropdownSelect
  UIStroke14.Color = GuiConfig.Color
  UIStroke14.Thickness = 1.6
  UIStroke14.Transparency = 0.8
  UIStroke14.Parent = DropdownSelect
  DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
  DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  DropdownSelectReal.BackgroundTransparency = 1
  DropdownSelectReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
  DropdownSelectReal.BorderSizePixel = 0
  DropdownSelectReal.LayoutOrder = 1
  DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
  DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
  DropdownSelectReal.Name = "DropdownSelectReal"
  DropdownSelectReal.Parent = DropdownSelect
  DropdownFolder.Name = "DropdownFolder"
  DropdownFolder.Parent = DropdownSelectReal
  DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
  DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
  DropPageLayout.TweenTime = 0.009999999776482582
  DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
  DropPageLayout.FillDirection = Enum.FillDirection.Vertical
  DropPageLayout.Archivable = false
  DropPageLayout.Name = "DropPageLayout"
  DropPageLayout.Parent = DropdownFolder
  local Tabs = {}
  local CountTab = 0
  local CountDropdown = 0
  local activeSliderDrag = nil
  local sliderMoveConnection = UserInputService.InputChanged:Connect(function(input)
    local drag = activeSliderDrag
    if drag and (input == drag.Input or (drag.Input.UserInputType == Enum.UserInputType.MouseButton1
      and input.UserInputType == Enum.UserInputType.MouseMovement)) then
      drag.Move(input.Position)
    end
  end)
  local sliderEndConnection = UserInputService.InputEnded:Connect(function(input)
    local drag = activeSliderDrag
    if drag and (input == drag.Input or (drag.Input.UserInputType == Enum.UserInputType.MouseButton1
      and input.UserInputType == Enum.UserInputType.MouseButton1)) then
      activeSliderDrag = nil
      drag.Finish()
    end
  end)
  GuiFunc:OnDestroy(function()
    activeSliderDrag = nil
    sliderMoveConnection:Disconnect()
    sliderEndConnection:Disconnect()
  end)
  local _elementBuildCount = 0
  local _ELEMENTS_PER_YIELD = 8
  local function yieldIfNeeded()
    _elementBuildCount = _elementBuildCount + 1
    if _elementBuildCount % _ELEMENTS_PER_YIELD == 0 then
      task.wait()
    end
  end
  function Tabs:AddTab(TabConfig)
    yieldIfNeeded()
    local TabConfig = TabConfig or {}
    TabConfig.Name = TabConfig.Name or "Tab"
    TabConfig.Icon = TabConfig.Icon or ""
    local hasTabIcon = TabConfig.Icon ~= ""
    local tabNameLeft = isMobile and (hasTabIcon and 25 or 8) or 34
    local tabNameWidth = math.max(20, LayersTab.Size.X.Offset - 8 - tabNameLeft - 4)
    local ScrolLayers = Instance.new("ScrollingFrame");
    local UIListLayout1 = Instance.new("UIListLayout");
    ScrolLayers.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ScrolLayers.ScrollBarThickness = 0
    ScrolLayers.Active = true
    ScrolLayers.LayoutOrder = CountTab
    ScrolLayers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ScrolLayers.BackgroundTransparency = 1
    ScrolLayers.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrolLayers.BorderSizePixel = 0
    ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
    ScrolLayers.Name = "ScrolLayers"
    ScrolLayers.Parent = LayersFolder
    local ScrolLayersPadding = Instance.new("UIPadding")
    ScrolLayersPadding.Name = "ScrolLayersPadding"
    ScrolLayersPadding.PaddingLeft = UDim.new(0, 8)
    ScrolLayersPadding.PaddingRight = UDim.new(0, 8)
    ScrolLayersPadding.PaddingTop = UDim.new(0, 8)
    ScrolLayersPadding.PaddingBottom = UDim.new(0, 8)
    ScrolLayersPadding.Parent = ScrolLayers
    UIListLayout1.Padding = UDim.new(0, GuiConfig.SectionSpacing or 6)
    UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout1.Parent = ScrolLayers
    local function updateCanvasSize()
      local canvasSize = UDim2.fromOffset(0, UIListLayout1.AbsoluteContentSize.Y + 16)
      if ScrolLayers.CanvasSize ~= canvasSize then ScrolLayers.CanvasSize = canvasSize end
    end
    UIListLayout1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    updateCanvasSize()
    local responsiveCards = {}
    local layoutPending = false
    local measuredWidth = ScrolLayers.AbsoluteSize.X
    local function registerResponsiveCard(callback)
      table.insert(responsiveCards, callback)
    end
    local function scheduleResponsiveLayout(force)
      if ScrolLayers.AbsoluteSize.X == measuredWidth or layoutPending then return end
      if not force and LayersPageLayout.CurrentPage and LayersPageLayout.CurrentPage ~= ScrolLayers then return end
      layoutPending = true
      task.delay(1 / 30, function()
        layoutPending = false
        if isDestroyed then return end
        local width = ScrolLayers.AbsoluteSize.X
        if width == measuredWidth then return end
        measuredWidth = width
        for _, callback in ipairs(responsiveCards) do callback() end
      end)
    end
    ScrolLayers:GetPropertyChangedSignal("AbsoluteSize"):Connect(scheduleResponsiveLayout)
    local Tab = Instance.new("Frame");
    local UICorner3 = Instance.new("UICorner");
    local TabButton = Instance.new("TextButton");
    local TabName = Instance.new("TextLabel")
    local FeatureImg = Instance.new("ImageLabel");
    local TabIndicator = Instance.new("Frame");
    local TabIndicatorCorner = Instance.new("UICorner");
    Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    if CountTab == 0 then
      Tab.BackgroundTransparency = 0.92
    else
      Tab.BackgroundTransparency = 1
    end
    Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Tab.BorderSizePixel = 0
    Tab.LayoutOrder = CountTab
    local tabHeight = isMobile and math.max(32,
      TextService:GetTextSize(tostring(TabConfig.Name), TextSize.Tab, TextStyle.Tab, Vector2.new(tabNameWidth, 1000)).Y + 8
    ) or 32
    Tab.Size = UDim2.new(1, 0, 0, tabHeight)
    Tab.Name = "Tab"
    Tab.Parent = ScrollTab
    UICorner3.CornerRadius = UDim.new(0, 8)
    UICorner3.Parent = Tab
    TabIndicator.Name = "TabIndicator"
    TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
    TabIndicator.Position = UDim2.new(0, 3, 0.5, 0)
    TabIndicator.Size = UDim2.new(0, 3, 0, 16)
    TabIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabIndicator.BorderSizePixel = 0
    TabIndicator.Visible = (CountTab == 0)
    TabIndicator.Parent = Tab
    TabIndicatorCorner.CornerRadius = UDim.new(0, 2)
    TabIndicatorCorner.Parent = TabIndicator
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = ""
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextSize = 13
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.BackgroundTransparency = 1
    TabButton.BorderSizePixel = 0
    TabButton.Size = UDim2.new(1, 0, 1, 0)
    TabButton.Name = "TabButton"
    TabButton.Parent = Tab
    TabName.Font = TextStyle.Tab
    TabName.Text = tostring(TabConfig.Name)
    TabName.TextSize = TextSize.Tab
    TabName.TextXAlignment = Enum.TextXAlignment.Left
    TabName.TextYAlignment = Enum.TextYAlignment.Center
    TabName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabName.BackgroundTransparency = 1
    TabName.BorderSizePixel = 0
    TabName.TextWrapped = isMobile
    TabName.Size = UDim2.new(1, -(tabNameLeft + 4), 1, 0)
    TabName.Position = UDim2.new(0, tabNameLeft, 0, 0)
    TabName.Name = "TabName"
    TabName.Parent = Tab
    FeatureImg.AnchorPoint = Vector2.new(0, 0.5)
    FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FeatureImg.BackgroundTransparency = 1
    FeatureImg.BorderSizePixel = 0
    FeatureImg.Position = UDim2.new(0, isMobile and 7 or 12, 0.5, 0)
    FeatureImg.Size = UDim2.new(0, 14, 0, 14)
    FeatureImg.ScaleType = Enum.ScaleType.Fit
    FeatureImg.Visible = hasTabIcon
    FeatureImg.Name = "FeatureImg"
    FeatureImg.Parent = Tab
    if CountTab == 0 then
      LayersPageLayout:JumpToIndex(0)
      NameTab.Text = TabConfig.Name
      Tab.BackgroundTransparency = 0.92
      TabIndicator.Visible = true
      TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
      FeatureImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
      FeatureImg.ImageTransparency = 0
    else
      Tab.BackgroundTransparency = 1
      TabIndicator.Visible = false
      TabName.TextColor3 = Color3.fromRGB(160, 160, 165)
      FeatureImg.ImageColor3 = Color3.fromRGB(160, 160, 165)
      FeatureImg.ImageTransparency = 0.15
    end
    if TabConfig.Icon and TabConfig.Icon ~= "" then
      FeatureImg.Image = StealthX:GetIcon(TabConfig.Icon)
    end
    TabButton.Activated:Connect(function()
      PlayUISound()
      circleClick(TabButton, Mouse.X, Mouse.Y)
      if Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
        for _, TabFrame in ScrollTab:GetChildren() do
          if TabFrame.Name == "Tab" then
            TweenService:Create(
              TabFrame,
              TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
              { BackgroundTransparency = 1 }
            ):Play()
            local otherInd = TabFrame:FindFirstChild("TabIndicator")
            if otherInd then
              otherInd.Visible = false
            end
            local otherName = TabFrame:FindFirstChild("TabName")
            if otherName then
              TweenService:Create(
                otherName,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { TextColor3 = Color3.fromRGB(160, 160, 165) }
              ):Play()
            end
            local otherImg = TabFrame:FindFirstChild("FeatureImg")
            if otherImg then
              TweenService:Create(
                otherImg,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { ImageColor3 = Color3.fromRGB(160, 160, 165), ImageTransparency = 0.15 }
              ):Play()
            end
          end
        end
        TweenService:Create(
          Tab,
          TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
          { BackgroundTransparency = 0.92 }
        ):Play()
        TabIndicator.Visible = true
        TweenService:Create(
          TabName,
          TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
          { TextColor3 = Color3.fromRGB(255, 255, 255) }
        ):Play()
        TweenService:Create(
          FeatureImg,
          TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
          { ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0 }
        ):Play()
        LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
        NameTab.Text = TabConfig.Name
        scheduleResponsiveLayout(true)
      end
    end)
    local Sections = {}
    local CountSection = 0
    function Sections:Section(secOpts, AlwaysOpen)
      yieldIfNeeded()
      local title, alwaysOpenArg, sectionIcon, sectionIconColor, sectionFeatureSpacing
      if type(secOpts) == "string" then
        title = secOpts
        alwaysOpenArg = AlwaysOpen
      elseif type(secOpts) == "table" then
        title = secOpts.Title or secOpts.Name or "Section"
        sectionIcon = secOpts.Icon
        sectionIconColor = secOpts.IconColor
        sectionFeatureSpacing = secOpts.FeatureSpacing or secOpts.Spacing or secOpts.ItemSpacing
        if secOpts.AlwaysOpen == true then
          alwaysOpenArg = true
        elseif secOpts.Opened == true then
          alwaysOpenArg = false
        else
          alwaysOpenArg = nil
        end
      else
        title = "Section"
        alwaysOpenArg = AlwaysOpen
      end
      return self:AddSection(title, alwaysOpenArg, sectionIcon, sectionIconColor, sectionFeatureSpacing)
    end
    function Sections:AddSection(Title, AlwaysOpen, SectionIcon, SectionIconColor, SectionFeatureSpacing)
      local Title = Title or "Title"
      local sectionHeaderHeight = 32
      local Section = Instance.new("Frame");
      local SectionDecideFrame = Instance.new("Frame");
      local UICorner1 = Instance.new("UICorner");
      local UIGradient = Instance.new("UIGradient");
      Section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      Section.BackgroundTransparency = 1
      Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
      Section.BorderSizePixel = 0
      Section.LayoutOrder = CountSection
      Section.ClipsDescendants = false
      Section.Size = UDim2.new(1, 0, 0, sectionHeaderHeight)
      Section.Name = "Section"
      Section.Parent = ScrolLayers
      local SectionReal = Instance.new("Frame");
      local SectionButton = Instance.new("TextButton");
      local SectionTitle = Instance.new("TextLabel");
      local SectionArrow = Instance.new("ImageLabel");
      SectionReal.AnchorPoint = Vector2.new(0.5, 0)
      SectionReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      SectionReal.BackgroundTransparency = 1
      SectionReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
      SectionReal.BorderSizePixel = 0
      SectionReal.LayoutOrder = 1
      SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
      SectionReal.Size = UDim2.new(1, 0, 0, sectionHeaderHeight)
      SectionReal.Name = "SectionReal"
      SectionReal.Parent = Section
      SectionButton.Font = Enum.Font.SourceSans
      SectionButton.Text = ""
      SectionButton.TextColor3 = Color3.fromRGB(0, 0, 0)
      SectionButton.TextSize = 14
      SectionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      SectionButton.BackgroundTransparency = 1
      SectionButton.BorderSizePixel = 0
      SectionButton.Size = UDim2.new(1, 0, 1, 0)
      SectionButton.Name = "SectionButton"
      SectionButton.Parent = SectionReal
      SectionTitle.Font = TextStyle.Section
      SectionTitle.Text = Title
      SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
      SectionTitle.TextSize = TextSize.Section
      SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
      SectionTitle.TextYAlignment = Enum.TextYAlignment.Center
      SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
      SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      SectionTitle.BackgroundTransparency = 1
      SectionTitle.BorderSizePixel = 0
      SectionTitle.Position = UDim2.new(0, 8, 0.5, 0)
      SectionTitle.Size = UDim2.new(1, -46, 1, 0)
      SectionTitle.Name = "SectionTitle"
      SectionTitle.Parent = SectionReal
      SectionArrow.Name = "SectionArrow"
      SectionArrow.Image = "rbxassetid://16851841101"
      SectionArrow.ImageColor3 = Color3.fromRGB(220, 220, 225)
      SectionArrow.AnchorPoint = Vector2.new(1, 0.5)
      SectionArrow.Position = UDim2.new(1, -8, 0.5, 0)
      SectionArrow.Size = UDim2.new(0, 25, 0, 25)
      SectionArrow.ScaleType = Enum.ScaleType.Fit
      SectionArrow.Rotation = -90
      SectionArrow.BackgroundTransparency = 1
      SectionArrow.Parent = SectionReal
      if SectionIcon and SectionIcon ~= "" then
        local SECTION_ICON_SIZE = 16
        local SECTION_ICON_GAP = 8
        local SectionIconImg = Instance.new("ImageLabel")
        SectionIconImg.Name = "SectionIcon"
        SectionIconImg.AnchorPoint = Vector2.new(0, 0.5)
        SectionIconImg.BackgroundTransparency = 1
        SectionIconImg.BorderSizePixel = 0
        SectionIconImg.Position = UDim2.new(0, 8, 0.5, 0)
        SectionIconImg.Size = UDim2.new(0, SECTION_ICON_SIZE, 0, SECTION_ICON_SIZE)
        SectionIconImg.ScaleType = Enum.ScaleType.Fit
        local iconSource = SectionIcon and SectionIcon ~= "" and StealthX:GetIcon(SectionIcon) or ""
        SectionIconImg.Image = iconSource ~= "" and iconSource or "rbxassetid://84411265569462"
        SectionIconImg.ImageColor3 = SectionIconColor or Color3.fromRGB(255, 255, 255)
        SectionIconImg.Parent = SectionReal
        local textX = 8 + SECTION_ICON_SIZE + SECTION_ICON_GAP
        SectionTitle.Position = UDim2.new(0, textX, 0.5, 0)
        SectionTitle.Size = UDim2.new(1, -(textX + 38), 1, 0)
      end
      SectionDecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      SectionDecideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
      SectionDecideFrame.AnchorPoint = Vector2.new(0.5, 0)
      SectionDecideFrame.BorderSizePixel = 0
      SectionDecideFrame.Position = UDim2.new(0.5, 0, 0, sectionHeaderHeight)
      SectionDecideFrame.Size = UDim2.new(0, 0, 0, 1)
      SectionDecideFrame.Name = "SectionDecideFrame"
      SectionDecideFrame.Parent = Section
      SectionDecideFrame.Visible = false
      UICorner1.Parent = SectionDecideFrame
      UIGradient.Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
      }
      UIGradient.Parent = SectionDecideFrame
      local SectionAdd = Instance.new("Frame");
      local UICorner8 = Instance.new("UICorner");
      local UIListLayout2 = Instance.new("UIListLayout");
      local FeatureSpacing = SectionFeatureSpacing or GuiConfig.FeatureSpacing or 3
      local baseHeader = sectionHeaderHeight + FeatureSpacing
      SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
      SectionAdd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
      SectionAdd.BackgroundTransparency = 1
      SectionAdd.BorderColor3 = Color3.fromRGB(0, 0, 0)
      SectionAdd.BorderSizePixel = 0
      SectionAdd.ClipsDescendants = true
      SectionAdd.LayoutOrder = 1
      SectionAdd.Position = UDim2.new(0.5, 0, 0, baseHeader)
      SectionAdd.Size = UDim2.new(1, 0, 0, 0)
      SectionAdd.Name = "SectionAdd"
      SectionAdd.Parent = Section
      SectionAdd.Visible = false
      UICorner8.CornerRadius = UDim.new(0, 8)
      UICorner8.Parent = SectionAdd
      UIListLayout2.Padding = UDim.new(0, FeatureSpacing)
      UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
      UIListLayout2.Parent = SectionAdd
      local OpenSection = false
      local function UpdateSizeSection(instant)
        if OpenSection then
          local contentHeight = UIListLayout2.AbsoluteContentSize.Y
          if contentHeight > 0 then contentHeight = contentHeight + FeatureSpacing end
          local sectionHeight = baseHeader + contentHeight
          local sectionSize = UDim2.new(1, 0, 0, sectionHeight)
          local contentSize = UDim2.new(1, 0, 0, contentHeight)
          SectionAdd.Visible = true
          if instant then
            if AlwaysOpen ~= true then SectionArrow.Rotation = 0 end
            if Section.Size ~= sectionSize then Section.Size = sectionSize end
            if SectionAdd.Size ~= contentSize then SectionAdd.Size = contentSize end
          else
            TweenService:Create(SectionArrow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
            TweenService:Create(Section, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = sectionSize }):Play()
            TweenService:Create(SectionAdd, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = contentSize }):Play()
          end
        end
      end
      local function CollapseSection(instant)
        OpenSection = false
        if instant then
          SectionArrow.Rotation = -90
          Section.Size = UDim2.new(1, 0, 0, sectionHeaderHeight)
          SectionAdd.Size = UDim2.new(1, 0, 0, 0)
          SectionAdd.Visible = false
        else
          TweenService:Create(SectionArrow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = -90 }):Play()
          TweenService:Create(Section, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, sectionHeaderHeight) }):Play()
          TweenService:Create(SectionAdd, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 0) }):Play()
          task.delay(0.25, function()
            if not OpenSection then
              SectionAdd.Visible = false
            end
          end)
        end
      end
      if AlwaysOpen == true then
        SectionButton:Destroy()
        SectionArrow:Destroy()
        OpenSection = true
        UpdateSizeSection(true)
      elseif AlwaysOpen == false then
        OpenSection = true
        UpdateSizeSection(true)
      else
        CollapseSection(true)
      end
      if AlwaysOpen ~= true then
        SectionButton.Activated:Connect(function()
          PlayUISound()
          circleClick(SectionButton, Mouse.X, Mouse.Y)
          if OpenSection then
            CollapseSection(false)
          else
            OpenSection = true
            UpdateSizeSection(false)
          end
        end)
      end
      local sectionLayoutPending = false
      UIListLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if sectionLayoutPending then return end
        sectionLayoutPending = true
        task.defer(function()
          sectionLayoutPending = false
          if not isDestroyed then UpdateSizeSection(true) end
        end)
      end)
      local Items = {}
      local CountItem = 0
      function Items:AddParagraph(ParagraphConfig)
        yieldIfNeeded()
        local ParagraphConfig = ParagraphConfig or {}
        ParagraphConfig.Title = ParagraphConfig.Title or "Title"
        ParagraphConfig.Content = ParagraphConfig.Content or "Content"
        local ParagraphFunc = {}
        local Paragraph = Instance.new("Frame")
        local UICorner14 = Instance.new("UICorner")
        local ParagraphTitle = Instance.new("TextLabel")
        local ParagraphContent = Instance.new("TextLabel")
        styleCardSurface(Paragraph)
        Paragraph.LayoutOrder = CountItem
        Paragraph.Size = UDim2.new(1, 0, 0, 46)
        Paragraph.Name = "Paragraph"
        Paragraph.Parent = SectionAdd
        UICorner14.CornerRadius = UDim.new(0, 8)
        UICorner14.Parent = Paragraph
        local iconOffset = 10
        local iconSize = 0
        if ParagraphConfig.Icon and ParagraphConfig.Icon ~= "" then
          local PARAGRAPH_ICON_GAP = 10
          iconSize = math.clamp(tonumber(ParagraphConfig.ImageSize) or 20, 16, 56)
          local IconImg = Instance.new("ImageLabel")
          IconImg.Size = UDim2.new(0, iconSize, 0, iconSize)
          IconImg.Position = UDim2.new(0, 10, 0, 10)
          IconImg.BackgroundTransparency = 1
          IconImg.BorderSizePixel = 0
          IconImg.ScaleType = Enum.ScaleType.Fit
          IconImg.Name = "ParagraphIcon"
          IconImg.Parent = Paragraph
          IconImg.Image = StealthX:GetIcon(ParagraphConfig.Icon)
          iconOffset = 10 + iconSize + PARAGRAPH_ICON_GAP
        end
        ParagraphTitle.Font = TextStyle.CardTitle
        ParagraphTitle.Text = ParagraphConfig.Title
        ParagraphTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphTitle.TextSize = TextSize.CardTitle
        ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
        ParagraphTitle.BackgroundTransparency = 1
        ParagraphTitle.Position = UDim2.new(0, iconOffset, 0, 10)
        ParagraphTitle.Size = UDim2.new(1, -(iconOffset + 14), 0, 14)
        ParagraphTitle.Name = "ParagraphTitle"
        ParagraphTitle.Parent = Paragraph
        ParagraphContent.Font = TextStyle.CardContent
        ParagraphContent.Text = ParagraphConfig.Content
        ParagraphContent.TextColor3 = CardContentColor
        ParagraphContent.TextSize = TextSize.CardContent
        ParagraphContent.TextTransparency = 0
        ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
        ParagraphContent.BackgroundTransparency = 1
        ParagraphContent.Position = UDim2.new(0, iconOffset, 0, 26)
        ParagraphContent.Name = "ParagraphContent"
        ParagraphContent.TextWrapped = true
        ParagraphContent.RichText = true
        ParagraphContent.Parent = Paragraph
        local ParagraphButton
        if ParagraphConfig.ButtonText then
          ParagraphButton = Instance.new("TextButton")
          ParagraphButton.Size = UDim2.new(1, -20, 0, 28)
          styleActionButton(ParagraphButton)
          ParagraphButton.Font = TextStyle.Button
          ParagraphButton.TextSize = TextSize.Button
          ParagraphButton.TextTransparency = 0
          ParagraphButton.TextColor3 = Color3.fromRGB(255, 255, 255)
          ParagraphButton.Text = ParagraphConfig.ButtonText
          ParagraphButton.Parent = Paragraph
          local btnCorner = Instance.new("UICorner")
          btnCorner.CornerRadius = UDim.new(0, 6)
          btnCorner.Parent = ParagraphButton
          if ParagraphConfig.ButtonCallback then
            ParagraphButton.Activated:Connect(function(inputObject)
              animateActionButton(ParagraphButton, inputObject)
              PlayUISound()
              ParagraphConfig.ButtonCallback()
            end)
          end
        end
        local function CalculateContentHeight()
          local text = ParagraphContent.Text or ""
          if text == "" then return 0 end
          local availW = Paragraph.AbsoluteSize.X - (iconOffset + 14)
          if availW <= 30 then
            availW = (isMobile and 280 or 400) - (iconOffset + 14)
          end
          local plainText = text:gsub("<[^>]->", "")
          local sz = TextService:GetTextSize(plainText, TextSize.CardContent, TextStyle.CardContent, Vector2.new(math.max(20, availW), 10000))
          return math.max(14, sz.Y)
        end
        local function UpdateSize()
          local contentH = CalculateContentHeight()
          ParagraphContent.Size = UDim2.new(1, -(iconOffset + 14), 0, contentH)
          local totalHeight = 26 + contentH + 10
          if iconSize > 0 then
            totalHeight = math.max(totalHeight, iconSize + 20)
          end
          if ParagraphButton then
            ParagraphButton.Position = UDim2.new(0, 10, 0, totalHeight)
            totalHeight = totalHeight + ParagraphButton.Size.Y.Offset + 10
          end
          Paragraph.Size = UDim2.new(1, 0, 0, totalHeight)
        end
        UpdateSize()
        registerResponsiveCard(UpdateSize)
        function ParagraphFunc:SetContent(content)
          content = content or "Content"
          ParagraphContent.Text = content
          UpdateSize()
        end
        function ParagraphFunc:SetTitle(title)
          title = title or "Title"
          ParagraphTitle.Text = title
        end
        CountItem = CountItem + 1
        return ParagraphFunc
      end
      function Items:AddPanel(PanelConfig)
        yieldIfNeeded()
        PanelConfig = PanelConfig or {}
        PanelConfig.Title = PanelConfig.Title or "Title"
        PanelConfig.Content = PanelConfig.Content or ""
        PanelConfig.Placeholder = PanelConfig.Placeholder or nil
        PanelConfig.Default = PanelConfig.Default or ""
        PanelConfig.ButtonText = PanelConfig.Button or PanelConfig.ButtonText or "Confirm"
        PanelConfig.ButtonCallback = PanelConfig.Callback or PanelConfig.ButtonCallback or function() end
        PanelConfig.SubButtonText = PanelConfig.SubButton or PanelConfig.SubButtonText or nil
        PanelConfig.SubButtonCallback = PanelConfig.SubCallback or PanelConfig.SubButtonCallback or
          function() end
        local configKey = "Panel_" .. PanelConfig.Title
        if configState.data[configKey] ~= nil then
          PanelConfig.Default = configState.data[configKey]
        end
        local PanelFunc = { Value = PanelConfig.Default }
        local baseHeight = 50
        if PanelConfig.Placeholder then
          baseHeight = baseHeight + 40
        end
        if PanelConfig.SubButtonText then
          baseHeight = baseHeight + 40
        else
          baseHeight = baseHeight + 36
        end
        local Panel = Instance.new("Frame")
        styleCardSurface(Panel)
        Panel.Size = UDim2.new(1, 0, 0, baseHeight)
        Panel.LayoutOrder = CountItem
        Panel.Parent = SectionAdd
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = Panel
        local Title = Instance.new("TextLabel")
        Title.Font = TextStyle.CardTitle
        Title.Text = PanelConfig.Title
        Title.TextSize = TextSize.CardTitle
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 10)
        Title.Size = UDim2.new(1, -20, 0, 13)
        Title.Parent = Panel
        local Content = Instance.new("TextLabel")
        Content.Font = TextStyle.CardContent
        Content.Text = PanelConfig.Content
        Content.TextSize = TextSize.CardContent
        Content.TextColor3 = CardContentColor
        Content.TextTransparency = 0
        Content.TextXAlignment = Enum.TextXAlignment.Left
        Content.BackgroundTransparency = 1
        Content.RichText = true
        Content.TextWrapped = true
        Content.Position = UDim2.new(0, 10, 0, 28)
        Content.Size = UDim2.new(1, -20, 0, 14)
        Content.Parent = Panel
        local InputBox
        if PanelConfig.Placeholder then
          local InputFrame = Instance.new("Frame")
          InputFrame.AnchorPoint = Vector2.new(0.5, 0)
          styleControlSurface(InputFrame)
          InputFrame.Position = UDim2.new(0.5, 0, 0, 48)
          InputFrame.Size = UDim2.new(1, -20, 0, 30)
          InputFrame.Parent = Panel
          local inputCorner = Instance.new("UICorner")
          inputCorner.CornerRadius = UDim.new(0, 6)
          inputCorner.Parent = InputFrame
          InputBox = Instance.new("TextBox")
          InputBox.Font = TextStyle.CardContent
          InputBox.PlaceholderText = PanelConfig.Placeholder
          InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
          InputBox.Text = PanelConfig.Default
          InputBox.TextSize = 11
          InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
          InputBox.BackgroundTransparency = 1
          InputBox.TextXAlignment = Enum.TextXAlignment.Left
          InputBox.Size = UDim2.new(1, -10, 1, -6)
          InputBox.Position = UDim2.new(0, 5, 0, 3)
          InputBox.Parent = InputFrame
        end
        local yBtn = 0
        if PanelConfig.Placeholder then
          yBtn = 88
        else
          yBtn = 48
        end
        local ButtonMain = Instance.new("TextButton")
        ButtonMain.Font = TextStyle.Button
        ButtonMain.Text = PanelConfig.ButtonText
        ButtonMain.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonMain.TextSize = TextSize.Button
        ButtonMain.TextTransparency = 0
        styleActionButton(ButtonMain)
        ButtonMain.Size = PanelConfig.SubButtonText and UDim2.new(0.5, -12, 0, 30) or UDim2.new(1, -20, 0, 30)
        ButtonMain.Position = UDim2.new(0, 10, 0, yBtn)
        ButtonMain.Parent = Panel
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = ButtonMain
        ButtonMain.Activated:Connect(function(inputObject)
          animateActionButton(ButtonMain, inputObject)
          PlayUISound()
          PanelConfig.ButtonCallback(InputBox and InputBox.Text or "")
        end)
        if PanelConfig.SubButtonText then
          local SubButton = Instance.new("TextButton")
          SubButton.Font = TextStyle.Button
          SubButton.Text = PanelConfig.SubButtonText
          SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
          SubButton.TextSize = TextSize.Button
          SubButton.TextTransparency = 0
          styleActionButton(SubButton)
          SubButton.Size = UDim2.new(0.5, -12, 0, 30)
          SubButton.Position = UDim2.new(0.5, 2, 0, yBtn)
          SubButton.Parent = Panel
          local subCorner = Instance.new("UICorner")
          subCorner.CornerRadius = UDim.new(0, 6)
          subCorner.Parent = SubButton
          SubButton.Activated:Connect(function(inputObject)
            animateActionButton(SubButton, inputObject)
            PlayUISound()
            PanelConfig.SubButtonCallback(InputBox and InputBox.Text or "")
          end)
        end
        if InputBox then
          InputBox.FocusLost:Connect(function()
            PanelFunc.Value = InputBox.Text
            configState.data[configKey] = InputBox.Text
            saveConfig()
          end)
        end
        function PanelFunc:GetInput()
          return InputBox and InputBox.Text or ""
        end
        CountItem = CountItem + 1
        return PanelFunc
      end
      function Items:Button(ButtonConfig)
        return self:AddButton(ButtonConfig)
      end
      function Items:ButtonGroup(GroupConfig)
        return self:AddButtonGroup(GroupConfig)
      end
      local function addLockedCover(parent, compact)
        local cover = Instance.new("TextButton")
        cover.Name = "LockedCover"
        cover.Size = UDim2.fromScale(1, 1)
        cover.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        cover.BackgroundTransparency = 0.4
        cover.BorderSizePixel = 0
        cover.AutoButtonColor = false
        cover.Text = ""
        cover.ZIndex = 5
        cover.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, compact and 6 or 8)
        corner.Parent = cover

        local title = Instance.new("TextLabel")
        title.Name = "LockedTitle"
        title.Size = UDim2.new(1, -16, 0, 16)
        title.Position = UDim2.new(0, 8, 0.5, compact and -14 or -17)
        title.BackgroundTransparency = 1
        title.Text = "Locked Feature"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = TextStyle.CardTitle
        title.TextSize = TextSize.CardTitle
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.ZIndex = 6
        title.Parent = cover

        local content = Instance.new("TextLabel")
        content.Name = "LockedContent"
        content.Size = UDim2.new(1, -16, 0, 14)
        content.Position = UDim2.new(0, 8, 0.5, 1)
        content.BackgroundTransparency = 1
        content.Text = compact and "Premium only" or "This feature only for premium users"
        content.TextColor3 = CardContentColor
        content.Font = TextStyle.CardContent
        content.TextSize = TextSize.CardContent
        content.TextXAlignment = Enum.TextXAlignment.Center
        content.ZIndex = 6
        content.Parent = cover
      end
      function Items:AddButtonGroup(GroupConfig)
        yieldIfNeeded()
        GroupConfig = GroupConfig or {}
        local buttons = GroupConfig.Buttons or GroupConfig
        if type(buttons) ~= "table" or #buttons == 0 then return end
        local buttonCount = #buttons
        local gap = 4
        local widthScale = 1 / buttonCount
        local widthOffset = -(12 + gap * (buttonCount - 1)) / buttonCount
        local Button = Instance.new("Frame")
        styleCardSurface(Button)
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.LayoutOrder = CountItem
        Button.Parent = SectionAdd
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = Button
        for index, config in ipairs(buttons) do
          config = type(config) == "table" and config or {}
          local title = config.Title or "Confirm"
          local actionButton = Instance.new("TextButton")
          actionButton.Font = TextStyle.Button
          actionButton.Text = title
          actionButton.TextSize = TextSize.Button
          actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
          actionButton.TextTransparency = 0
          styleActionButton(actionButton)
          actionButton.Size = UDim2.new(widthScale, widthOffset, 1, -10)
          actionButton.Position = UDim2.new((index - 1) * widthScale,
            6 + (index - 1) * (widthOffset + gap), 0, 5)
          actionButton.Parent = Button
          addActionButtonIcon(actionButton, title, config.Icon)
          local corner = Instance.new("UICorner")
          corner.CornerRadius = UDim.new(0, 6)
          corner.Parent = actionButton
          local callback = config.Callback
          actionButton.Activated:Connect(function(inputObject)
            if config.Locked then return end
            animateActionButton(actionButton, inputObject)
            PlayUISound()
            if callback then pcall(callback) end
          end)
          if config.Locked then addLockedCover(actionButton, true) end
        end
        CountItem = CountItem + 1
        return Button
      end
      function Items:AddButton(ButtonConfig)
        ButtonConfig = ButtonConfig or {}
        local buttons = {{
          Title = ButtonConfig.Title or "Confirm",
          Icon = ButtonConfig.Icon,
          Callback = ButtonConfig.Callback,
          Locked = ButtonConfig.Locked,
        }}
        if ButtonConfig.SubTitle then
          buttons[2] = {
            Title = ButtonConfig.SubTitle,
            Icon = ButtonConfig.SubIcon,
            Callback = ButtonConfig.SubCallback,
            Locked = ButtonConfig.SubLocked,
          }
        end
        return self:AddButtonGroup({ Buttons = buttons })
      end
      function Items:Toggle(ToggleConfig)
        return self:AddToggle(ToggleConfig)
      end
      function Items:AddToggle(ToggleConfig)
        yieldIfNeeded()
        local ToggleConfig = ToggleConfig or {}
        ToggleConfig.Title = ToggleConfig.Title or "Title"
        ToggleConfig.Title2 = ToggleConfig.Title2 or ""
        ToggleConfig.Content = ToggleConfig.Content or ToggleConfig.Desc or ""
        ToggleConfig.Default = ToggleConfig.Default or false
        ToggleConfig.Callback = ToggleConfig.Callback or function() end
        local configKey = "Toggle_" .. ToggleConfig.Title
        if configState.data[configKey] ~= nil then
          ToggleConfig.Default = configState.data[configKey]
        end
        if ToggleConfig.Locked then ToggleConfig.Default = false end
        local ToggleFunc = { Value = ToggleConfig.Default }
        local Toggle = Instance.new("Frame")
        local UICorner20 = Instance.new("UICorner")
        local ToggleTitle = Instance.new("TextLabel")
        local ToggleContent = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
        local FeatureFrame2 = Instance.new("Frame")
        local UICorner22 = Instance.new("UICorner")
        local UIStroke8 = Instance.new("UIStroke")
        local ToggleCircle = Instance.new("Frame")
        local UICorner23 = Instance.new("UICorner")
        styleCardSurface(Toggle)
        Toggle.LayoutOrder = CountItem
        Toggle.Name = "Toggle"
        Toggle.Parent = SectionAdd
        UICorner20.CornerRadius = UDim.new(0, 8)
        UICorner20.Parent = Toggle
        ToggleTitle.Font = TextStyle.CardTitle
        ToggleTitle.Text = ToggleConfig.Title
        ToggleTitle.TextSize = TextSize.CardTitle
        ToggleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
        ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
        ToggleTitle.BackgroundTransparency = 1
        ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
        ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
        ToggleTitle.Name = "ToggleTitle"
        ToggleTitle.Parent = Toggle
        local ToggleTitle2 = Instance.new("TextLabel")
        ToggleTitle2.Font = TextStyle.CardContent
        ToggleTitle2.Text = ToggleConfig.Title2
        ToggleTitle2.TextSize = TextSize.CardContent
        ToggleTitle2.TextColor3 = CardContentColor
        ToggleTitle2.TextXAlignment = Enum.TextXAlignment.Left
        ToggleTitle2.TextYAlignment = Enum.TextYAlignment.Top
        ToggleTitle2.BackgroundTransparency = 1
        ToggleTitle2.Position = UDim2.new(0, 10, 0, 23)
        ToggleTitle2.Size = UDim2.new(1, -100, 0, 12)
        ToggleTitle2.Name = "ToggleTitle2"
        ToggleTitle2.Parent = Toggle
        ToggleContent.Font = TextStyle.CardContent
        ToggleContent.Text = ToggleConfig.Content
        ToggleContent.TextColor3 = CardContentColor
        ToggleContent.TextSize = TextSize.CardContent
        ToggleContent.TextTransparency = 0
        ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
        ToggleContent.TextYAlignment = Enum.TextYAlignment.Top
        ToggleContent.BackgroundTransparency = 1
        ToggleContent.TextWrapped = true
        ToggleContent.RichText = true
        ToggleContent.Name = "ToggleContent"
        ToggleContent.Parent = Toggle
        if ToggleConfig.Title2 ~= "" then
          ToggleContent.Position = UDim2.new(0, 10, 0, 36)
          ToggleTitle2.Visible = true
        else
          ToggleContent.Position = UDim2.new(0, 10, 0, 25)
          ToggleTitle2.Visible = false
        end
        local function CalculateToggleContentHeight()
          local text = ToggleContent.Text or ""
          if text == "" then return 0 end
          local availW = Toggle.AbsoluteSize.X - 75
          if availW <= 30 then
            availW = (isMobile and 280 or 400) - 75
          end
          local plainText = text:gsub("<[^>]->", "")
          local sz = TextService:GetTextSize(plainText, TextSize.CardContent, TextStyle.CardContent, Vector2.new(math.max(20, availW), 10000))
          return math.max(12, sz.Y)
        end
        local function UpdateToggleSize()
          local text = ToggleContent.Text or ""
          if text == "" then
            ToggleContent.Visible = false
            Toggle.Size = UDim2.new(1, 0, 0, (ToggleConfig.Title2 ~= "") and 46 or 40)
          else
            ToggleContent.Visible = true
            local contentH = CalculateToggleContentHeight()
            ToggleContent.Size = UDim2.new(1, -65, 0, contentH)
            local topOffset = (ToggleConfig.Title2 ~= "") and 36 or 25
            Toggle.Size = UDim2.new(1, 0, 0, topOffset + contentH + 9)
          end
        end
        UpdateToggleSize()
        registerResponsiveCard(UpdateToggleSize)
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.Size = UDim2.new(1, 0, 1, 0)
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = Toggle
        FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame2.BackgroundTransparency = 0.92
        FeatureFrame2.BorderSizePixel = 0
        FeatureFrame2.Position = UDim2.new(1, -15, 0.5, 0)
        FeatureFrame2.Size = UDim2.new(0, 30, 0, 15)
        FeatureFrame2.Name = "FeatureFrame"
        FeatureFrame2.Parent = Toggle
        UICorner22.Parent = FeatureFrame2
        UIStroke8.Color = Color3.fromRGB(255, 255, 255)
        UIStroke8.Thickness = 2
        UIStroke8.Transparency = 0.9
        UIStroke8.Parent = FeatureFrame2
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
        ToggleCircle.Name = "ToggleCircle"
        ToggleCircle.Parent = FeatureFrame2
        UICorner23.CornerRadius = UDim.new(0, 15)
        UICorner23.Parent = ToggleCircle
        if ToggleConfig.Locked then
          addLockedCover(Toggle)
        end
        ToggleButton.Activated:Connect(function()
          if ToggleConfig.Locked then return end
          PlayUISound()
          ToggleFunc.Value = not ToggleFunc.Value
          ToggleFunc:Set(ToggleFunc.Value)
        end)
        function ToggleFunc:Set(Value)
          if ToggleConfig.Locked then
            self.Value = false
            if configState.data[configKey] ~= nil and configState.data[configKey] ~= false then
              configState.data[configKey] = false
              saveConfig()
            end
            return
          end
          if typeof(ToggleConfig.Callback) == "function" then
            local ok, err = pcall(function()
              ToggleConfig.Callback(Value)
            end)
            if not ok then warn("Toggle Callback error:", err) end
          end
          configState.data[configKey] = Value
          saveConfig()
          if Value then
            local ON_GREEN = Color3.fromRGB(34, 197, 94)
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2),
              { Position = UDim2.new(0, 15, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
              :Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = ON_GREEN, Transparency = 0 })
              :Play()
            TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
              { BackgroundColor3 = ON_GREEN, BackgroundTransparency = 0 }):Play()
          else
            TweenService:Create(ToggleTitle, TweenInfo.new(0.2),
              { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            TweenService:Create(ToggleCircle, TweenInfo.new(0.2),
              { Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(230, 230, 230) }):Play()
            TweenService:Create(UIStroke8, TweenInfo.new(0.2),
              { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
            TweenService:Create(FeatureFrame2, TweenInfo.new(0.2),
              { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
          end
        end
        ToggleFunc:Set(ToggleFunc.Value)
        CountItem = CountItem + 1
        configState.elements[configKey] = ToggleFunc
        return ToggleFunc
      end
      function Items:Slider(SliderConfig)
        return self:AddSlider(SliderConfig)
      end
      function Items:AddSlider(SliderConfig)
        yieldIfNeeded()
        local SliderConfig = SliderConfig or {}
        SliderConfig.Title = SliderConfig.Title or "Slider"
        SliderConfig.Content = SliderConfig.Content or ""
        SliderConfig.Round = SliderConfig.Round or SliderConfig.Increment or 1
        SliderConfig.Increment = SliderConfig.Round
        SliderConfig.Min = SliderConfig.Min or 0
        SliderConfig.Max = SliderConfig.Max or 100
        SliderConfig.Default = SliderConfig.Default or 50
        SliderConfig.Callback = SliderConfig.Callback or function() end
        local configKey = "Slider_" .. SliderConfig.Title
        if configState.data[configKey] ~= nil then
          SliderConfig.Default = configState.data[configKey]
        end
        local SliderFunc = { Value = SliderConfig.Default }
        local Slider = Instance.new("Frame");
        local UICorner15 = Instance.new("UICorner");
        local SliderTitle = Instance.new("TextLabel");
        local SliderContent = Instance.new("TextLabel");
        local SliderInput = Instance.new("Frame");
        local UICorner16 = Instance.new("UICorner");
        local TextBox = Instance.new("TextBox");
        local SliderFrame = Instance.new("Frame");
        local UICorner17 = Instance.new("UICorner");
        local SliderDraggable = Instance.new("Frame");
        local UICorner18 = Instance.new("UICorner");
        local UIStroke5 = Instance.new("UIStroke");
        local SliderCircle = Instance.new("Frame");
        local UICorner19 = Instance.new("UICorner");
        local UIStroke6 = Instance.new("UIStroke");
        local UIStroke7 = Instance.new("UIStroke");
        styleCardSurface(Slider)
        Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Slider.BorderSizePixel = 0
        Slider.LayoutOrder = CountItem
        Slider.Size = UDim2.new(1, 0, 0, 46)
        Slider.Name = "Slider"
        Slider.Parent = SectionAdd
        UICorner15.CornerRadius = UDim.new(0, 8)
        UICorner15.Parent = Slider
        SliderTitle.Font = TextStyle.CardTitle
        SliderTitle.Text = SliderConfig.Title
        SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.TextSize = TextSize.CardTitle
        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
        SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
        SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.BackgroundTransparency = 0.9990000128746033
        SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderTitle.BorderSizePixel = 0
        SliderTitle.Position = UDim2.new(0, 10, 0, 10)
        SliderTitle.Size = UDim2.new(1, -180, 0, 13)
        SliderTitle.Name = "SliderTitle"
        SliderTitle.Parent = Slider
        SliderContent.Font = TextStyle.CardContent
        SliderContent.Text = SliderConfig.Content
        SliderContent.TextColor3 = CardContentColor
        SliderContent.TextSize = TextSize.CardContent
        SliderContent.TextTransparency = 0
        SliderContent.TextXAlignment = Enum.TextXAlignment.Left
        SliderContent.TextYAlignment = Enum.TextYAlignment.Top
        SliderContent.BackgroundTransparency = 1
        SliderContent.Position = UDim2.new(0, 10, 0, 25)
        SliderContent.Name = "SliderContent"
        SliderContent.TextWrapped = true
        SliderContent.RichText = true
        SliderContent.Parent = Slider
        local function CalculateSliderContentHeight()
          local text = SliderContent.Text or ""
          if text == "" then return 0 end
          local availW = Slider.AbsoluteSize.X - 185
          if availW <= 30 then
            availW = (isMobile and 280 or 400) - 185
          end
          local plainText = text:gsub("<[^>]->", "")
          local sz = TextService:GetTextSize(plainText, TextSize.CardContent, TextStyle.CardContent, Vector2.new(math.max(20, availW), 10000))
          return math.max(12, sz.Y)
        end
        local function UpdateSliderSize()
          local text = SliderContent.Text or ""
          if text == "" then
            SliderContent.Visible = false
            Slider.Size = UDim2.new(1, 0, 0, 42)
          else
            SliderContent.Visible = true
            local contentH = CalculateSliderContentHeight()
            SliderContent.Size = UDim2.new(1, -180, 0, contentH)
            Slider.Size = UDim2.new(1, 0, 0, 25 + contentH + 9)
          end
        end
        UpdateSliderSize()
        registerResponsiveCard(UpdateSliderSize)
        SliderInput.AnchorPoint = Vector2.new(0, 0.5)
        SliderInput.BackgroundColor3 = GuiConfig.Color
        SliderInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderInput.BackgroundTransparency = 1
        SliderInput.BorderSizePixel = 0
        SliderInput.Position = UDim2.new(1, -155, 0.5, 0)
        SliderInput.Size = UDim2.new(0, 28, 0, 20)
        SliderInput.Name = "SliderInput"
        SliderInput.Parent = Slider
        UICorner16.CornerRadius = UDim.new(0, 4)
        UICorner16.Parent = SliderInput
        TextBox.Font = TextStyle.Button
        TextBox.Text = "90"
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = TextSize.Button
        TextBox.TextWrapped = true
        TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TextBox.BackgroundTransparency = 0.9990000128746033
        TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextBox.BorderSizePixel = 0
        TextBox.Position = UDim2.new(0, -1, 0, 0)
        TextBox.Size = UDim2.new(1, 0, 1, 0)
        TextBox.Parent = SliderInput
        SliderFrame.AnchorPoint = Vector2.new(1, 0.5)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderFrame.BackgroundTransparency = 0.800000011920929
        SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Position = UDim2.new(1, -20, 0.5, 0)
        SliderFrame.Size = UDim2.new(0, 100, 0, 3)
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = Slider
        UICorner17.Parent = SliderFrame
        SliderDraggable.AnchorPoint = Vector2.new(0, 0.5)
        SliderDraggable.BackgroundColor3 = GuiConfig.Color
        SliderDraggable.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderDraggable.BorderSizePixel = 0
        SliderDraggable.Position = UDim2.new(0, 0, 0.5, 0)
        SliderDraggable.Size = UDim2.new(0.899999976, 0, 0, 1)
        SliderDraggable.Name = "SliderDraggable"
        SliderDraggable.Parent = SliderFrame
        UICorner18.Parent = SliderDraggable
        SliderCircle.AnchorPoint = Vector2.new(1, 0.5)
        SliderCircle.BackgroundColor3 = GuiConfig.Color
        SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderCircle.BorderSizePixel = 0
        SliderCircle.Position = UDim2.new(1, 4, 0.5, 0)
        SliderCircle.Size = UDim2.new(0, 8, 0, 8)
        SliderCircle.Name = "SliderCircle"
        SliderCircle.Parent = SliderDraggable
        UICorner19.Parent = SliderCircle
        UIStroke6.Color = GuiConfig.Color
        UIStroke6.Parent = SliderCircle
        local sliderInitialized = false
        local dragChanged = false
        local function Round(Number, Factor)
          local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
          if Result < 0 then
            Result = Result + Factor
          end
          return Result
        end
        function SliderFunc:Set(Value, skipSave, dragging)
          Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
          if sliderInitialized and SliderFunc.Value == Value then
            if TextBox.Text ~= tostring(Value) then TextBox.Text = tostring(Value) end
            return
          end
          sliderInitialized = true
          SliderFunc.Value = Value
          TextBox.Text = tostring(Value)
          local fillSize = UDim2.fromScale((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)
          if dragging then
            SliderDraggable.Size = fillSize
          else
            TweenService:Create(SliderDraggable, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
              { Size = fillSize }):Play()
          end
          SliderConfig.Callback(Value)
          configState.data[configKey] = Value
          if dragging then
            dragChanged = true
          elseif not skipSave then
            saveConfig()
          end
        end
        local function updateSliderFromPosition(position)
          local width = SliderFrame.AbsoluteSize.X
          if width <= 0 then return end
          local sizeScale = math.clamp((position.X - SliderFrame.AbsolutePosition.X) / width, 0, 1)
          SliderFunc:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * sizeScale), true, true)
        end
        SliderFrame.InputBegan:Connect(function(Input)
          if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if activeSliderDrag then activeSliderDrag.Finish() end
            TweenService:Create(
              SliderCircle,
              TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
              { Size = UDim2.new(0, 14, 0, 14) }
            ):Play()
            activeSliderDrag = {
              Input = Input,
              Move = updateSliderFromPosition,
              Finish = function()
                TweenService:Create(SliderCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                  { Size = UDim2.new(0, 8, 0, 8) }):Play()
                if dragChanged then
                  dragChanged = false
                  saveConfig()
                end
              end,
            }
            updateSliderFromPosition(Input.Position)
          end
        end)
        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
          local Valid = TextBox.Text:gsub("[^%d]", "")
          if Valid ~= "" then
            local ValidNumber = math.clamp(tonumber(Valid), SliderConfig.Min, SliderConfig.Max)
            SliderFunc:Set(ValidNumber)
          else
            SliderFunc:Set(SliderConfig.Min)
          end
        end)
        SliderFunc:Set(SliderConfig.Default)
        CountItem = CountItem + 1
        configState.elements[configKey] = SliderFunc
        return SliderFunc
      end
      function Items:Input(InputConfig)
        return self:AddInput(InputConfig)
      end
      function Items:AddInput(InputConfig)
        yieldIfNeeded()
        local InputConfig = InputConfig or {}
        InputConfig.Title = InputConfig.Title or "Title"
        InputConfig.Content = InputConfig.Content or ""
        InputConfig.Callback = InputConfig.Callback or function() end
        InputConfig.Default = InputConfig.Default or ""
        local configKey = "Input_" .. InputConfig.Title
        if not InputConfig.Locked and configState.data[configKey] ~= nil then
          InputConfig.Default = configState.data[configKey]
        end
        local InputFunc = { Value = InputConfig.Default }
        local Input = Instance.new("Frame");
        local UICorner12 = Instance.new("UICorner");
        local InputTitle = Instance.new("TextLabel");
        local InputContent = Instance.new("TextLabel");
        local InputFrame = Instance.new("Frame");
        local UICorner13 = Instance.new("UICorner");
        local InputTextBox = Instance.new("TextBox");
        styleCardSurface(Input)
        Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Input.BorderSizePixel = 0
        Input.LayoutOrder = CountItem
        Input.Size = UDim2.new(1, 0, 0, 46)
        Input.Name = "Input"
        Input.Parent = SectionAdd
        UICorner12.CornerRadius = UDim.new(0, 8)
        UICorner12.Parent = Input
        InputTitle.Font = TextStyle.CardTitle
        InputTitle.Text = InputConfig.Title or "TextBox"
        InputTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTitle.TextSize = TextSize.CardTitle
        InputTitle.TextXAlignment = Enum.TextXAlignment.Left
        InputTitle.TextYAlignment = Enum.TextYAlignment.Top
        InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTitle.BackgroundTransparency = 0.9990000128746033
        InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTitle.BorderSizePixel = 0
        InputTitle.Position = UDim2.new(0, 10, 0, 10)
        InputTitle.Size = UDim2.new(1, -180, 0, 13)
        InputTitle.Name = "InputTitle"
        InputTitle.Parent = Input
        InputContent.Font = TextStyle.CardContent
        InputContent.Text = InputConfig.Content or ""
        InputContent.TextColor3 = CardContentColor
        InputContent.TextSize = TextSize.CardContent
        InputContent.TextTransparency = 0
        InputContent.TextWrapped = true
        InputContent.RichText = true
        InputContent.TextXAlignment = Enum.TextXAlignment.Left
        InputContent.TextYAlignment = Enum.TextYAlignment.Top
        InputContent.BackgroundTransparency = 1
        InputContent.Position = UDim2.new(0, 10, 0, 25)
        InputContent.Name = "InputContent"
        InputContent.Parent = Input
        local function CalculateInputContentHeight()
          local text = InputContent.Text or ""
          if text == "" then return 0 end
          local availW = Input.AbsoluteSize.X - 185
          if availW <= 30 then
            availW = (isMobile and 280 or 400) - 185
          end
          local plainText = text:gsub("<[^>]->", "")
          local sz = TextService:GetTextSize(plainText, TextSize.CardContent, TextStyle.CardContent, Vector2.new(math.max(20, availW), 10000))
          return math.max(12, sz.Y)
        end
        local function UpdateInputSize()
          local text = InputContent.Text or ""
          if text == "" then
            InputContent.Visible = false
            Input.Size = UDim2.new(1, 0, 0, 44)
          else
            InputContent.Visible = true
            local contentH = CalculateInputContentHeight()
            InputContent.Size = UDim2.new(1, -180, 0, contentH)
            Input.Size = UDim2.new(1, 0, 0, 25 + contentH + 9)
          end
        end
        UpdateInputSize()
        registerResponsiveCard(UpdateInputSize)
        InputFrame.AnchorPoint = Vector2.new(1, 0.5)
        styleControlSurface(InputFrame)
        InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputFrame.BorderSizePixel = 0
        InputFrame.ClipsDescendants = true
        InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
        InputFrame.Size = UDim2.new(0, 148, 0, 30)
        InputFrame.Name = "InputFrame"
        InputFrame.Parent = Input
        UICorner13.CornerRadius = UDim.new(0, 6)
        UICorner13.Parent = InputFrame
        InputTextBox.CursorPosition = -1
        InputTextBox.Font = TextStyle.CardContent
        InputTextBox.PlaceholderColor3 = Color3.fromRGB(120.00000044703484, 120.00000044703484,
          120.00000044703484)
        InputTextBox.PlaceholderText = InputConfig.Placeholder or InputConfig.PlaceholderText or "Input Here"
        InputTextBox.Text = tostring(InputConfig.Default or "")
        InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.TextSize = 12
        InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
        InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
        InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.BackgroundTransparency = 0.9990000128746033
        InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTextBox.BorderSizePixel = 0
        InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
        InputTextBox.Size = UDim2.new(1, -10, 1, -8)
        InputTextBox.Name = "InputTextBox"
        InputTextBox.Parent = InputFrame
        if InputConfig.Locked then
          InputTextBox.TextEditable = false
          addLockedCover(Input)
        end
        function InputFunc:Set(Value)
          if InputConfig.Locked then
            InputFunc.Value = InputConfig.Default
            InputTextBox.Text = tostring(InputConfig.Default)
            if configState.data[configKey] ~= nil and configState.data[configKey] ~= InputConfig.Default then
              configState.data[configKey] = InputConfig.Default
              saveConfig()
            end
            return
          end
          InputTextBox.Text = Value
          InputFunc.Value = Value
          InputConfig.Callback(Value)
          configState.data[configKey] = Value
          saveConfig()
        end
        InputFunc:Set(InputFunc.Value)
        InputTextBox.FocusLost:Connect(function()
          InputFunc:Set(InputTextBox.Text)
        end)
        CountItem = CountItem + 1
        configState.elements[configKey] = InputFunc
        return InputFunc
      end
      function Items:Keybind(KeybindConfig)
        return self:AddKeybind(KeybindConfig)
      end
      function Items:AddKeybind(KeybindConfig)
        yieldIfNeeded()
        local KeybindConfig = KeybindConfig or {}
        KeybindConfig.Title = KeybindConfig.Title or "Keybind"
        KeybindConfig.Content = KeybindConfig.Content or ""
        KeybindConfig.Default = KeybindConfig.Default -- Enum.KeyCode / Enum.UserInputType / nil
        KeybindConfig.Mode = KeybindConfig.Mode or "Toggle" -- "Toggle" atau "Hold"
        KeybindConfig.Callback = KeybindConfig.Callback or function() end -- (Pressed: boolean)
        KeybindConfig.ChangedCallback = KeybindConfig.ChangedCallback or function() end -- (KeyName: string)
        local configKey = "Keybind_" .. KeybindConfig.Title
        local function keyObjectToName(keyObj)
          if keyObj == nil then return "None" end
          if typeof(keyObj) == "EnumItem" then
            if keyObj.EnumType == Enum.UserInputType then
              if keyObj == Enum.UserInputType.MouseButton1 then return "MB1" end
              if keyObj == Enum.UserInputType.MouseButton2 then return "MB2" end
              if keyObj == Enum.UserInputType.MouseButton3 then return "MB3" end
              return keyObj.Name
            elseif keyObj.EnumType == Enum.KeyCode then
              return keyObj.Name
            end
          end
          return tostring(keyObj)
        end
        local function nameToKeyObject(name)
          if not name or name == "" or name == "None" then return nil end
          if name == "MB1" then return Enum.UserInputType.MouseButton1 end
          if name == "MB2" then return Enum.UserInputType.MouseButton2 end
          if name == "MB3" then return Enum.UserInputType.MouseButton3 end
          local ok, keyCode = pcall(function() return Enum.KeyCode[name] end)
          if ok and keyCode then return keyCode end
          return nil
        end
        local defaultKeyObj = KeybindConfig.Default
        if type(defaultKeyObj) == "string" then
          defaultKeyObj = nameToKeyObject(defaultKeyObj)
        end
        if not KeybindConfig.IgnoreConfig and configState.data[configKey] ~= nil then
          defaultKeyObj = nameToKeyObject(configState.data[configKey])
        end
        local KeybindFunc = { Value = defaultKeyObj, Pressed = false }
        local Keybind = Instance.new("Frame")
        local UICorner14 = Instance.new("UICorner")
        local KeybindTitle = Instance.new("TextLabel")
        local KeybindContent = Instance.new("TextLabel")
        local KeybindFrame = Instance.new("Frame")
        local UICorner15 = Instance.new("UICorner")
        local KeybindButton = Instance.new("TextButton")
        styleCardSurface(Keybind)
        Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Keybind.BorderSizePixel = 0
        Keybind.LayoutOrder = CountItem
        Keybind.Size = UDim2.new(1, 0, 0, 46)
        Keybind.Name = "Keybind"
        Keybind.Parent = SectionAdd
        UICorner14.CornerRadius = UDim.new(0, 8)
        UICorner14.Parent = Keybind
        KeybindTitle.Font = TextStyle.CardTitle
        KeybindTitle.Text = KeybindConfig.Title
        KeybindTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindTitle.TextSize = TextSize.CardTitle
        KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
        KeybindTitle.TextYAlignment = Enum.TextYAlignment.Top
        KeybindTitle.BackgroundTransparency = 1
        KeybindTitle.Position = UDim2.new(0, 10, 0, 10)
        KeybindTitle.Size = UDim2.new(1, -100, 0, 13)
        KeybindTitle.Name = "KeybindTitle"
        KeybindTitle.Parent = Keybind
        KeybindContent.Font = TextStyle.CardContent
        KeybindContent.Text = KeybindConfig.Content
        KeybindContent.TextColor3 = CardContentColor
        KeybindContent.TextSize = TextSize.CardContent
        KeybindContent.TextWrapped = true
        KeybindContent.RichText = true
        KeybindContent.TextXAlignment = Enum.TextXAlignment.Left
        KeybindContent.TextYAlignment = Enum.TextYAlignment.Top
        KeybindContent.BackgroundTransparency = 1
        KeybindContent.Position = UDim2.new(0, 10, 0, 25)
        KeybindContent.Name = "KeybindContent"
        KeybindContent.Parent = Keybind
        local function CalculateKeybindContentHeight()
          local text = KeybindContent.Text or ""
          if text == "" then return 0 end
          local availW = Keybind.AbsoluteSize.X - 100
          if availW <= 30 then
            availW = (isMobile and 280 or 400) - 100
          end
          local plainText = text:gsub("<[^>]->", "")
          local sz = TextService:GetTextSize(plainText, TextSize.CardContent, TextStyle.CardContent, Vector2.new(math.max(20, availW), 10000))
          return math.max(12, sz.Y)
        end
        local function UpdateKeybindSize()
          local text = KeybindContent.Text or ""
          if text == "" then
            KeybindContent.Visible = false
            Keybind.Size = UDim2.new(1, 0, 0, 44)
          else
            KeybindContent.Visible = true
            local contentH = CalculateKeybindContentHeight()
            KeybindContent.Size = UDim2.new(1, -100, 0, contentH)
            Keybind.Size = UDim2.new(1, 0, 0, 25 + contentH + 9)
          end
        end
        UpdateKeybindSize()
        registerResponsiveCard(UpdateKeybindSize)
        KeybindFrame.AnchorPoint = Vector2.new(1, 0.5)
        styleControlSurface(KeybindFrame)
        KeybindFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindFrame.BorderSizePixel = 0
        KeybindFrame.ClipsDescendants = true
        KeybindFrame.Position = UDim2.new(1, -7, 0.5, 0)
        KeybindFrame.Size = UDim2.new(0, 68, 0, 26)
        KeybindFrame.Name = "KeybindFrame"
        KeybindFrame.Parent = Keybind
        UICorner15.CornerRadius = UDim.new(0, 6)
        UICorner15.Parent = KeybindFrame
        KeybindButton.Font = TextStyle.Button
        KeybindButton.Text = keyObjectToName(defaultKeyObj)
        KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindButton.TextSize = 12
        KeybindButton.AutoButtonColor = false
        KeybindButton.BackgroundTransparency = 1
        KeybindButton.BorderSizePixel = 0
        KeybindButton.Size = UDim2.new(1, 0, 1, 0)
        KeybindButton.Name = "KeybindButton"
        KeybindButton.Parent = KeybindFrame
        local listening = false
        local listenConn = nil
        local function stopListening()
          listening = false
          if listenConn then
            listenConn:Disconnect()
            listenConn = nil
          end
          TweenService:Create(KeybindFrame, TweenInfo.new(0.15),
            { BackgroundColor3 = controlColor, BackgroundTransparency = controlTransparency }):Play()
          KeybindButton.Text = keyObjectToName(KeybindFunc.Value)
        end
        function KeybindFunc:Set(keyObj, skipSave)
          if type(keyObj) == "string" then
            keyObj = nameToKeyObject(keyObj)
          end
          KeybindFunc.Value = keyObj
          KeybindButton.Text = keyObjectToName(keyObj)
          if not skipSave and not KeybindConfig.IgnoreConfig then
            configState.data[configKey] = keyObjectToName(keyObj)
            saveConfig()
          end
          pcall(function() KeybindConfig.ChangedCallback(keyObjectToName(keyObj)) end)
        end
        local function fireCallback(pressed)
          KeybindFunc.Pressed = pressed
          pcall(function() KeybindConfig.Callback(pressed) end)
        end
        local function startListening()
          if listening then return end
          listening = true
          KeybindButton.Text = "..."
          TweenService:Create(KeybindFrame, TweenInfo.new(0.15),
            { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0.8 }):Play()
          listenConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType == Enum.UserInputType.Keyboard then
              if input.KeyCode == Enum.KeyCode.Escape then
                KeybindFunc:Set(nil)
                stopListening()
                return
              end
              KeybindFunc:Set(input.KeyCode)
              stopListening()
            elseif not KeybindConfig.KeyboardOnly and (
              input.UserInputType == Enum.UserInputType.MouseButton1
              or input.UserInputType == Enum.UserInputType.MouseButton2
              or input.UserInputType == Enum.UserInputType.MouseButton3) then
              KeybindFunc:Set(input.UserInputType)
              stopListening()
            end
          end)
        end
        KeybindButton.Activated:Connect(function()
          PlayUISound()
          if listening then
            stopListening()
          else
            startListening()
          end
        end)
        local keyDownConnection = UserInputService.InputBegan:Connect(function(input, gpe)
          if listening then return end
          if gpe then return end
          local keyObj = KeybindFunc.Value
          if not keyObj then return end
          local matched = (input.KeyCode == keyObj) or (input.UserInputType == keyObj)
          if not matched then return end
          if KeybindConfig.Mode == "Hold" then
            fireCallback(true)
          else
            fireCallback(not KeybindFunc.Pressed)
          end
        end)
        local keyUpConnection = UserInputService.InputEnded:Connect(function(input, gpe)
          if KeybindConfig.Mode ~= "Hold" then return end
          local keyObj = KeybindFunc.Value
          if not keyObj then return end
          local matched = (input.KeyCode == keyObj) or (input.UserInputType == keyObj)
          if not matched then return end
          fireCallback(false)
        end)
        GuiFunc:OnDestroy(function()
          if listenConn then listenConn:Disconnect() end
          keyDownConnection:Disconnect()
          keyUpConnection:Disconnect()
        end)
        CountItem = CountItem + 1
        configState.elements[configKey] = KeybindFunc
        return KeybindFunc
      end
      function Items:Dropdown(DropdownConfig)
        return self:AddDropdown(DropdownConfig)
      end
      function Items:AddDropdown(DropdownConfig)
        yieldIfNeeded()
        local DropdownConfig = DropdownConfig or {}
        DropdownConfig.Title = DropdownConfig.Title or "Title"
        DropdownConfig.Content = DropdownConfig.Content or ""
        DropdownConfig.Multi = DropdownConfig.Multi or false
        DropdownConfig.Options = DropdownConfig.Options or DropdownConfig.Values or {}
        DropdownConfig.Default = DropdownConfig.Default or DropdownConfig.Value or (DropdownConfig.Multi and {} or nil)
        DropdownConfig.Callback = DropdownConfig.Callback or function() end
        local configKey = "Dropdown_" .. DropdownConfig.Title
        if not DropdownConfig.Locked and configState.data[configKey] ~= nil then
          DropdownConfig.Default = configState.data[configKey]
        end
        local DropdownFunc = { Value = DropdownConfig.Default, Options = DropdownConfig.Options }
        local Dropdown = Instance.new("Frame")
        local DropdownButton = Instance.new("TextButton")
        local UICorner10 = Instance.new("UICorner")
        local DropdownTitle = Instance.new("TextLabel")
        local DropdownContent = Instance.new("TextLabel")
        local SelectOptionsFrame = Instance.new("Frame")
        local UICorner11 = Instance.new("UICorner")
        local OptionSelecting = Instance.new("TextLabel")
        local OptionImg = Instance.new("ImageLabel")
        styleCardSurface(Dropdown)
        Dropdown.LayoutOrder = CountItem
        Dropdown.Size = UDim2.new(1, 0, 0, 46)
        Dropdown.Name = "Dropdown"
        Dropdown.Parent = SectionAdd
        DropdownButton.Text = ""
        DropdownButton.BackgroundTransparency = 1
        DropdownButton.Size = UDim2.new(1, 0, 1, 0)
        DropdownButton.Name = "ToggleButton"
        DropdownButton.Parent = Dropdown
        UICorner10.CornerRadius = UDim.new(0, 8)
        UICorner10.Parent = Dropdown
        DropdownTitle.Font = TextStyle.CardTitle
        DropdownTitle.Text = DropdownConfig.Title
        DropdownTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownTitle.TextSize = TextSize.CardTitle
        DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
        DropdownTitle.BackgroundTransparency = 1
        DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
        DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
        DropdownTitle.Name = "DropdownTitle"
        DropdownTitle.Parent = Dropdown
        DropdownContent.Font = TextStyle.CardContent
        DropdownContent.Text = DropdownConfig.Content or ""
        DropdownContent.TextColor3 = CardContentColor
        DropdownContent.TextSize = TextSize.CardContent
        DropdownContent.TextTransparency = 0
        DropdownContent.TextWrapped = true
        DropdownContent.RichText = true
        DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
        DropdownContent.TextYAlignment = Enum.TextYAlignment.Top
        DropdownContent.BackgroundTransparency = 1
        DropdownContent.Position = UDim2.new(0, 10, 0, 25)
        DropdownContent.Name = "DropdownContent"
        DropdownContent.Parent = Dropdown
        local function CalculateDropdownContentHeight()
          local text = DropdownContent.Text or ""
          if text == "" then return 0 end
          local availW = Dropdown.AbsoluteSize.X - 185
          if availW <= 30 then
            availW = (isMobile and 280 or 400) - 185
          end
          local plainText = text:gsub("<[^>]->", "")
          local sz = TextService:GetTextSize(plainText, TextSize.CardContent, TextStyle.CardContent, Vector2.new(math.max(20, availW), 10000))
          return math.max(12, sz.Y)
        end
        local function UpdateDropdownSize()
          local text = DropdownContent.Text or ""
          if text == "" then
            DropdownContent.Visible = false
            Dropdown.Size = UDim2.new(1, 0, 0, 44)
          else
            DropdownContent.Visible = true
            local contentH = CalculateDropdownContentHeight()
            DropdownContent.Size = UDim2.new(1, -180, 0, contentH)
            Dropdown.Size = UDim2.new(1, 0, 0, 25 + contentH + 9)
          end
        end
        UpdateDropdownSize()
        registerResponsiveCard(UpdateDropdownSize)
        SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
        styleControlSurface(SelectOptionsFrame)
        SelectOptionsFrame.BorderSizePixel = 0
        SelectOptionsFrame.ClipsDescendants = true
        SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
        SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
        SelectOptionsFrame.Name = "SelectOptionsFrame"
        SelectOptionsFrame.LayoutOrder = CountDropdown
        SelectOptionsFrame.Parent = Dropdown
        UICorner11.CornerRadius = UDim.new(0, 6)
        UICorner11.Parent = SelectOptionsFrame
        if DropdownConfig.Locked then addLockedCover(Dropdown) end
        DropdownButton.Activated:Connect(function()
          if DropdownConfig.Locked then return end
          if not MoreBlur.Visible then
            PlayUISound()
            MoreBlur.Visible = true
            DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, -11, 0.5, 0) })
              :Play()
          end
        end)
        OptionSelecting.Font = TextStyle.CardContent
        OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
        OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.TextSize = TextSize.CardTitle
        OptionSelecting.TextTransparency = 0.2
        OptionSelecting.TextTruncate = Enum.TextTruncate.AtEnd
        OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
        OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
        OptionSelecting.BackgroundTransparency = 1
        OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
        OptionSelecting.Size = UDim2.new(1, -34, 1, -8)
        OptionSelecting.Name = "OptionSelecting"
        OptionSelecting.Parent = SelectOptionsFrame
        OptionImg.Image = "rbxassetid://16851841101"
        OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
        OptionImg.AnchorPoint = Vector2.new(1, 0.5)
        OptionImg.BackgroundTransparency = 1
        OptionImg.Position = UDim2.new(1, -5, 0.5, 0)
        OptionImg.Size = UDim2.new(0, 20, 0, 20)
        OptionImg.Name = "OptionImg"
        OptionImg.Parent = SelectOptionsFrame
        local DropdownContainer = Instance.new("Frame")
        DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
        DropdownContainer.BackgroundTransparency = 1
        DropdownContainer.Parent = DropdownFolder
        local SearchBox = Instance.new("TextBox")
        SearchBox.PlaceholderText = "Search"
        SearchBox.Font = TextStyle.CardContent
        SearchBox.Text = ""
        SearchBox.TextSize = 12
        SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        SearchBox.BackgroundTransparency = 0.9
        SearchBox.BorderSizePixel = 0
        SearchBox.Size = UDim2.new(1, 0, 0, 25)
        SearchBox.Position = UDim2.new(0, 0, 0, 0)
        SearchBox.ClearTextOnFocus = false
        SearchBox.Name = "SearchBox"
        SearchBox.Parent = DropdownContainer
        local ScrollSelect = Instance.new("ScrollingFrame")
        ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
        ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
        ScrollSelect.ScrollBarImageTransparency = 1
        ScrollSelect.BorderSizePixel = 0
        ScrollSelect.BackgroundTransparency = 1
        ScrollSelect.ScrollBarThickness = 0
        ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
        ScrollSelect.Name = "ScrollSelect"
        ScrollSelect.Parent = DropdownContainer
        local UIListLayout4 = Instance.new("UIListLayout")
        UIListLayout4.Padding = UDim.new(0, 3)
        UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout4.Parent = ScrollSelect
        UIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
          ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
        end)
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
          local query = string.lower(SearchBox.Text)
          for _, option in pairs(ScrollSelect:GetChildren()) do
            if option.Name == "Option" and option:FindFirstChild("OptionText") then
              local text = string.lower(option.OptionText.Text)
              option.Visible = query == "" or string.find(text, query, 1, true)
            end
          end
          ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, UIListLayout4.AbsoluteContentSize.Y)
        end)
        local DropCount = 0
        function DropdownFunc:Clear()
          for _, DropFrame in ScrollSelect:GetChildren() do
            if DropFrame.Name == "Option" then
              DropFrame:Destroy()
            end
          end
          DropdownFunc.Value = DropdownConfig.Multi and {} or nil
          DropdownFunc.Options = {}
          OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
          DropCount = 0
        end
        function DropdownFunc:AddOption(option)
          local label, value
          if typeof(option) == "table" and option.Label and option.Value ~= nil then
            label = tostring(option.Label)
            value = option.Value
          else
            label = tostring(option)
            value = option
          end
          local Option = Instance.new("Frame")
          local OptionButton = Instance.new("TextButton")
          local OptionText = Instance.new("TextLabel")
          local ChooseFrame = Instance.new("Frame")
          local UIStroke15 = Instance.new("UIStroke")
          local UICorner38 = Instance.new("UICorner")
          local UICorner37 = Instance.new("UICorner")
          Option.BackgroundColor3 = cardColor
          Option.BackgroundTransparency = 1
          Option.BorderSizePixel = 0
          Option.Size = UDim2.new(1, 0, 0, 30)
          Option.Name = "Option"
          Option.Parent = ScrollSelect
          UICorner37.CornerRadius = UDim.new(0, 6)
          UICorner37.Parent = Option
          OptionButton.BackgroundTransparency = 1
          OptionButton.Size = UDim2.new(1, 0, 1, 0)
          OptionButton.Text = ""
          OptionButton.Name = "OptionButton"
          OptionButton.Parent = Option
          OptionText.Font = TextStyle.CardContent
          OptionText.Text = label
          OptionText.TextSize = TextSize.CardTitle
          OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
          OptionText.Position = UDim2.new(0, 8, 0, 8)
          OptionText.Size = UDim2.new(1, -100, 0, 13)
          OptionText.BackgroundTransparency = 1
          OptionText.TextXAlignment = Enum.TextXAlignment.Left
          OptionText.Name = "OptionText"
          OptionText.Parent = Option
          Option:SetAttribute("RealValue", value)
          ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
          ChooseFrame.BackgroundColor3 = GuiConfig.Color
          ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
          ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
          ChooseFrame.Name = "ChooseFrame"
          ChooseFrame.Parent = Option
          UIStroke15.Color = GuiConfig.Color
          UIStroke15.Thickness = 1.6
          UIStroke15.Transparency = 0.999
          UIStroke15.Parent = ChooseFrame
          UICorner38.Parent = ChooseFrame
          OptionButton.Activated:Connect(function()
            if DropdownConfig.Locked then return end
            PlayUISound()
            if DropdownConfig.Multi then
              if not table.find(DropdownFunc.Value, value) then
                table.insert(DropdownFunc.Value, value)
              else
                for i, v in pairs(DropdownFunc.Value) do
                  if v == value then
                    table.remove(DropdownFunc.Value, i)
                    break
                  end
                end
              end
            else
              DropdownFunc.Value = value
            end
            DropdownFunc:Set(DropdownFunc.Value)
          end)
        end
        function DropdownFunc:Set(Value)
          if DropdownConfig.Locked then Value = DropdownConfig.Default end
          if DropdownConfig.Multi then
            DropdownFunc.Value = type(Value) == "table" and Value or {}
          else
            DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
          end
          if DropdownConfig.Locked then
            if configState.data[configKey] ~= nil and configState.data[configKey] ~= DropdownFunc.Value then
              configState.data[configKey] = DropdownFunc.Value
              saveConfig()
            end
          else
            configState.data[configKey] = DropdownFunc.Value
            saveConfig()
          end
          local texts = {}
          for _, Drop in ScrollSelect:GetChildren() do
            if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
              local v = Drop:GetAttribute("RealValue")
              local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or
                DropdownFunc.Value == v
              if selected then
                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2),
                  { Size = UDim2.new(0, 1, 0, 12) }):Play()
                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), { Transparency = 0 })
                  :Play()
                TweenService:Create(Drop, TweenInfo.new(0.2), { BackgroundTransparency = cardTransparency }):Play()
                table.insert(texts, Drop.OptionText.Text)
              else
                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1),
                  { Size = UDim2.new(0, 0, 0, 0) }):Play()
                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1),
                  { Transparency = 0.999 }):Play()
                TweenService:Create(Drop, TweenInfo.new(0.1), { BackgroundTransparency = 0.999 }):Play()
              end
            end
          end
          OptionSelecting.Text = (#texts == 0)
            and (DropdownConfig.Multi and "Select Options" or "Select Option")
            or table.concat(texts, ", ")
          if not DropdownConfig.Locked and DropdownConfig.Callback then
            if DropdownConfig.Multi then
              DropdownConfig.Callback(DropdownFunc.Value)
            else
              local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
              DropdownConfig.Callback(str)
            end
          end
        end
        function DropdownFunc:SetValue(val)
          self:Set(val)
        end
        function DropdownFunc:GetValue()
          return self.Value
        end
        function DropdownFunc:SetValues(newList, selecting)
          newList = newList or {}
          selecting = selecting or (DropdownConfig.Multi and {} or nil)
          DropdownFunc:Clear()
          for _, v in ipairs(newList) do
            DropdownFunc:AddOption(v)
          end
          DropdownFunc.Options = newList
          DropdownFunc:Set(selecting)
        end
        DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)
        CountItem = CountItem + 1
        CountDropdown = CountDropdown + 1
        configState.elements[configKey] = DropdownFunc
        return DropdownFunc
      end
      function Items:AddDivider()
        local Divider = Instance.new("Frame")
        Divider.Name = "Divider"
        Divider.Parent = SectionAdd
        Divider.AnchorPoint = Vector2.new(0.5, 0)
        Divider.Position = UDim2.new(0.5, 0, 0, 0)
        Divider.Size = UDim2.new(1, 0, 0, 2)
        Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Divider.BackgroundTransparency = 0
        Divider.BorderSizePixel = 0
        Divider.LayoutOrder = CountItem
        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new {
          ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
          ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
          ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
        }
        UIGradient.Parent = Divider
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 2)
        UICorner.Parent = Divider
        CountItem = CountItem + 1
        return Divider
      end
      function Items:AddSubSection(title)
        title = title or "Sub Section"
        local SubSection = Instance.new("Frame")
        SubSection.Name = "SubSection"
        SubSection.Parent = SectionAdd
        SubSection.BackgroundTransparency = 1
        SubSection.Size = UDim2.new(1, 0, 0, 22)
        SubSection.LayoutOrder = CountItem
        local Background = Instance.new("Frame")
        Background.Parent = SubSection
        Background.Size = UDim2.new(1, 0, 1, 0)
        styleCardSurface(Background)
        Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)
        local Label = Instance.new("TextLabel")
        Label.Parent = SubSection
        Label.AnchorPoint = Vector2.new(0, 0.5)
        Label.Position = UDim2.new(0, 10, 0.5, 0)
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Font = TextStyle.Section
        Label.Text = "── [ " .. title .. " ] ──"
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        CountItem = CountItem + 1
        return SubSection
      end
      CountSection = CountSection + 1
      return Items
    end
    CountTab = CountTab + 1
    local safeName = TabConfig.Name:gsub("%s+", "_")
    if _G[safeName] == nil then
      _G[safeName] = Sections
    end
    return Sections
  end
  GuiFunc.Main = Main
  GuiFunc.ScreenGui = StealthXGui
  GuiFunc.DropShadow = DropShadow
  GuiFunc.DropShadowHolder = DropShadowHolder
  function GuiFunc:SetBackground(imageSrc, transparency, overlayTransparency)
    local asset = resolveAsset(imageSrc, "window_bg.jpg")
    if Main:IsA("ImageLabel") then
      Main.Image = asset
      if transparency then Main.ImageTransparency = transparency end
      local darkOverlay = Main:FindFirstChild("DarkOverlay")
      if darkOverlay and overlayTransparency then
        darkOverlay.BackgroundTransparency = overlayTransparency
      end
    else
      local bgImg = Main:FindFirstChild("CustomBackgroundImage")
      if not bgImg then
        bgImg = Instance.new("ImageLabel")
        bgImg.Name = "CustomBackgroundImage"
        bgImg.Size = UDim2.new(1, 0, 1, 0)
        bgImg.ScaleType = Enum.ScaleType.Crop
        bgImg.BackgroundTransparency = 1
        bgImg.ZIndex = 0
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 14)
        bgCorner.Parent = bgImg
        bgImg.Parent = Main
      end
      bgImg.Image = asset
      bgImg.ImageTransparency = transparency or 0.15
    end
  end
  for k, v in pairs(GuiFunc) do
    if Tabs[k] == nil then Tabs[k] = v end
  end
  Tabs.Destroy = Tabs.Destroy or GuiFunc.DestroyGui
  return Tabs
end
print([=[
          __                 __   __   __
  _______/  |_  ____ _____  |  |_/  |_|  |__ ___  ___
 /  ___/\   __\/ __ \\__  \ |  |\   __\  |  \\  \/  /
 \___ \  |  | \  ___/ / __ \|  |_|  | |   Y  \>    <
/____  > |__|  \___  >____  /____/__| |___|  /__/\_ \
     \/            \/     \/               \/      \/
          [Stealth-X] Loaded successfully.
]=])
return StealthX
