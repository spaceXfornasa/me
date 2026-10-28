return function(ctx)
    local Window = ctx.Window
    local Players = ctx.Players
    local RunService = ctx.RunService
    local UserInputService = ctx.UserInputService
    local LocalPlayer = ctx.LocalPlayer
    local Session = ctx.Session
    local Utility = ctx.Utility
    local stopWalkSpeed = ctx.stopWalkSpeed
    local applyWalkSpeed = ctx.applyWalkSpeed
    local stopNoclip = ctx.stopNoclip
    local Identity = ctx.Identity
    local Movement = ctx.Movement

Identity:AddDivider()
local identityStatus = Identity:AddParagraph({
    Title = "User ID",
    Content = "Anonymous",
    Icon = "user",
})
local pendingUsername = "Anonymous"
local identityRequest = 0
local userContainer = Window.Main and Window.Main:FindFirstChild("UserContainer", true)
local userNameLabel = userContainer and userContainer:FindFirstChild("UserNameLabel")
local avatarImage = userContainer and userContainer:FindFirstChild("AvatarImage")
local anonymousAvatar = "rbxassetid://108483430622128"
local selectedAvatar = anonymousAvatar
local selectedUsername = "Anonymous"
local selectedUserId = "Anonymous"
local originalUsername = LocalPlayer.Name
local originalDisplayName = LocalPlayer.DisplayName
Session.IdentityOriginalDisplayName = originalDisplayName
local originalUserId = tostring(LocalPlayer.UserId)
local originalAvatar
local identityEntries = {}
local identityConnections = {}
local observedGuiObjects = {}
local identityHumanoids = setmetatable({}, { __mode = "k" })
Session.IdentityEntries = identityEntries
Session.IdentityConnections = identityConnections
Session.IdentityHumanoids = identityHumanoids

local function applyCharacterName(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid", 5)
    if Session.Closed or character ~= LocalPlayer.Character or not humanoid then return end
    if identityHumanoids[humanoid] == nil then
        identityHumanoids[humanoid] = humanoid.DisplayName
        identityConnections[#identityConnections + 1] = humanoid:GetPropertyChangedSignal("DisplayName"):Connect(function()
            if not Session.Closed and humanoid.DisplayName ~= selectedUsername then
                humanoid.DisplayName = selectedUsername
            end
        end)
    end
    humanoid.DisplayName = selectedUsername
end

local function replaceName(text, original)
    if not original or original == "" then return text end
    local pattern = original:gsub("([^%w])", "%%%1")
    return text:gsub("%f[%w_]" .. pattern .. "%f[^%w_]", function()
        return selectedUsername
    end)
end

local function maskedText(raw)
    if raw == originalUsername or raw == originalDisplayName then return selectedUsername end
    if raw == originalUserId then return selectedUserId end
    if not raw:find(originalUsername, 1, true)
        and not raw:find(originalDisplayName, 1, true)
        and (LocalPlayer.UserId <= 0 or not raw:find(originalUserId, 1, true)) then
        return raw
    end
    if originalDisplayName ~= originalUsername then
        raw = replaceName(raw, originalDisplayName)
    end
    raw = replaceName(raw, originalUsername)
    if LocalPlayer.UserId > 0 then
        raw = raw:gsub("%f[%d]" .. originalUserId .. "%f[^%d]", function()
            return selectedUserId
        end)
    end
    return raw
end

local function maskedImage(raw)
    if originalAvatar and raw == originalAvatar then return selectedAvatar end
    local lower = raw:lower()
    if lower:find("thumb", 1, true) then
        local imageUserId = lower:match("[?&]id=(%d+)") or lower:match("[?&]userid=(%d+)")
        if imageUserId == originalUserId then return selectedAvatar end
    end
    return raw
end

local function refreshIdentityEntry(entry)
    local object = entry.Object
    if not object.Parent then return end
    local current = object[entry.Property]
    if current ~= entry.Masked then entry.Raw = current end
    local masked = entry.Property == "Text" and maskedText(entry.Raw) or maskedImage(entry.Raw)
    entry.Masked = masked
    if current ~= masked then object[entry.Property] = masked end
end

local function refreshGameIdentity()
    for _, entry in ipairs(identityEntries) do
        refreshIdentityEntry(entry)
    end
end

local function applyIdentityVisual()
    Session.IdentityName = selectedUsername
    pcall(function() LocalPlayer.DisplayName = selectedUsername end)
    refreshGameIdentity()
    if LocalPlayer.Character then task.spawn(applyCharacterName, LocalPlayer.Character) end
    if Session.VisualClone then
        local humanoid = Session.VisualClone:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.DisplayName = selectedUsername end
    end
end

local function watchGameGuiObject(object)
    if observedGuiObjects[object] then return end
    if Window.ScreenGui and object:IsDescendantOf(Window.ScreenGui) then return end
    local property
    if object:IsA("TextLabel") or object:IsA("TextButton") then
        property = "Text"
    elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
        property = "Image"
    else
        return
    end
    local entry = { Object = object, Property = property, Raw = object[property] }
    observedGuiObjects[object] = true
    identityEntries[#identityEntries + 1] = entry
    identityConnections[#identityConnections + 1] = object:GetPropertyChangedSignal(property):Connect(function()
        if object[property] ~= entry.Masked then refreshIdentityEntry(entry) end
    end)
    refreshIdentityEntry(entry)
end

local function watchGameGui(playerGui)
    if Session.Closed then return end
    for _, object in ipairs(playerGui:GetDescendants()) do
        watchGameGuiObject(object)
    end
    identityConnections[#identityConnections + 1] = playerGui.DescendantAdded:Connect(watchGameGuiObject)
end

local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if playerGui then
    watchGameGui(playerGui)
else
    task.spawn(function()
        local gui = LocalPlayer:WaitForChild("PlayerGui", 10)
        if gui then watchGameGui(gui) end
    end)
end
if LocalPlayer.Character then
    watchGameGui(LocalPlayer.Character)
end
Session.IdentityCharacterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    task.spawn(applyCharacterName, character)
    watchGameGui(character)
end)
local okCoreGui, coreGui = pcall(function() return game:GetService("CoreGui") end)
if okCoreGui and coreGui then
    pcall(watchGameGui, coreGui)
end
task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    if ok and not Session.Closed then
        originalAvatar = image
        refreshGameIdentity()
    end
end)

if avatarImage then
    Session.IdentityConnection = avatarImage:GetPropertyChangedSignal("Image"):Connect(function()
        if avatarImage.Image ~= selectedAvatar then avatarImage.Image = selectedAvatar end
    end)
    avatarImage.Image = selectedAvatar
end
applyIdentityVisual()

Identity:AddInput({
    Title = "Username",
    Placeholder = "Anonymous",
    Default = "Anonymous",
    Callback = function(value)
        pendingUsername = tostring(value or "")
    end,
})

Identity:AddButton({
    Title = "Continue",
    Callback = function()
        local username = pendingUsername:gsub("^%s+", ""):gsub("%s+$", "")
        identityRequest = identityRequest + 1
        local request = identityRequest
        if username == "" or username:lower() == "anonymous" then
            selectedUsername = "Anonymous"
            selectedUserId = "Anonymous"
            selectedAvatar = anonymousAvatar
            applyIdentityVisual()
            if userNameLabel then userNameLabel.Text = "Welcome, Anonymous" end
            if avatarImage then avatarImage.Image = selectedAvatar end
            identityStatus:SetContent("Anonymous")
            return
        end
        task.spawn(function()
            local ok, userId = pcall(function()
                return Players:GetUserIdFromNameAsync(username)
            end)
            if Session.Closed or request ~= identityRequest then return end
            if not ok then
                identityStatus:SetContent("Username tidak ditemukan")
                return
            end
            local thumbnailOk, thumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if Session.Closed or request ~= identityRequest then return end
            selectedUsername = username
            selectedUserId = tostring(userId)
            selectedAvatar = thumbnailOk and thumbnail ~= "" and thumbnail or anonymousAvatar
            applyIdentityVisual()
            if userNameLabel then userNameLabel.Text = "Welcome, " .. username end
            if avatarImage then avatarImage.Image = selectedAvatar end
            identityStatus:SetContent("ID: " .. tostring(userId))
        end)
    end,
})

Movement:AddDivider()
Movement:AddInput({
    Title = "Walkspeed Value",
    Placeholder = "50",
    Default = "50",
    Callback = function(value)
        local speed = tonumber(value)
        if speed and speed == speed and speed >= 0 and speed <= 500 then
            Utility.WalkSpeed = speed
            if Utility.SpeedEnabled and Utility.SpeedHumanoid then
                Utility.SpeedHumanoid.WalkSpeed = speed
            end
        end
    end,
})

Movement:AddToggle({
    Title = "Enable Walkspeed",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if Utility.SpeedEnabled then return end
            Utility.SpeedEnabled = true
            local generation = Utility.SpeedGeneration
            Utility.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
                task.spawn(applyWalkSpeed, character, generation)
            end)
            if LocalPlayer.Character then task.spawn(applyWalkSpeed, LocalPlayer.Character, generation) end
        else
            stopWalkSpeed()
        end
    end,
})

Movement:AddToggle({
    Title = "Inf Jump",
    Default = false,
    Callback = function(enabled)
        if Utility.JumpConnection then Utility.JumpConnection:Disconnect() end
        Utility.JumpConnection = nil
        if enabled then
            Utility.JumpConnection = UserInputService.JumpRequest:Connect(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end,
})

Movement:AddToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(enabled)
        stopNoclip()
        if enabled then
            Utility.NoclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if not character then return end
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        if Utility.Collision[part] == nil then
                            Utility.Collision[part] = true
                        end
                        part.CanCollide = false
                    end
                end
            end)
        end
    end,
})

end
