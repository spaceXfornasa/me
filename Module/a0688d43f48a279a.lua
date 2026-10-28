return function(ctx)
    local StealthX = ctx.StealthX
    local Window = ctx.Window
    local Players = ctx.Players
    local RunService = ctx.RunService
    local TweenService = ctx.TweenService
    local LocalPlayer = ctx.LocalPlayer
    local genv = ctx.genv
    local Session = ctx.Session
    local releaseCoreLock = ctx.releaseCoreLock
    local stopCoreProbe = ctx.stopCoreProbe
    local State = ctx.State
    local bridge = ctx.bridge
    local installBiteObserver = ctx.installBiteObserver
    local clearMinigameGuiCache = ctx.clearMinigameGuiCache
    local disconnectCatch = ctx.disconnectCatch
    local updateStatus = ctx.updateStatus
    local stopFishing = ctx.stopFishing
    local endSummitVisual = ctx.endSummitVisual
    local beginSummitVisual = ctx.beginSummitVisual
    local stopSummit = ctx.stopSummit
    local returnFromSell = ctx.returnFromSell
    local stopSelling = ctx.stopSelling
    local Fishing = ctx.Fishing
    local Selling = ctx.Selling
    local Summit = ctx.Summit
    local Webhook = ctx.Webhook


Fishing:AddDivider()
local statusParagraph = Fishing:AddParagraph({
    Title = "Fishing Status",
    Content = "Idle\nCaught: 0 | Failed: 0",
    Icon = "document-text-bold",
})
ctx.SetStatusParagraph(statusParagraph)

local CORE_SPOT = {
    CFrame.lookAt(Vector3.new(-9004, 1250, -6538), Vector3.new(-9010, 1250, -6538)),
    CFrame.lookAt(Vector3.new(-9062, 1251, -6503), Vector3.new(-9062, 1251, -6507)),
    CFrame.lookAt(Vector3.new(-9146, 1251, -6502), Vector3.new(-9146, 1251, -6506)),
    CFrame.lookAt(Vector3.new(-9180, 1251, -6559), Vector3.new(-9176, 1251, -6559)),
    CFrame.lookAt(Vector3.new(-9097, 1253, -6590), Vector3.new(-9181, 1251, -6592)),
}
local FISHING_SPOT = {
    CFrame.lookAt(Vector3.new(-8164, 1239, -6287), Vector3.new(-8164, 1239, -6278)),
    CFrame.lookAt(Vector3.new(-8208, 1240, -6283), Vector3.new(-8208, 1239, -6279)),
    CFrame.lookAt(Vector3.new(-8232, 1240, -6243), Vector3.new(-8227, 1240, -6243)),
    CFrame.lookAt(Vector3.new(-8187, 1232, -6332), Vector3.new(-8187, 1230, -6325)),
}

local function teleportToSpot(destination)
    if Session.Closed then return nil end
    releaseCoreLock()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    if type(destination) == "table" then destination = destination[math.random(#destination)] end
    root.CFrame = destination
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local token = Session.CoreLockToken
    RunService.Heartbeat:Wait()
    if Session.Closed or token ~= Session.CoreLockToken
        or LocalPlayer.Character ~= character or root.Parent ~= character then return nil end
    Session.CoreLockedRoot = root
    Session.CoreWasAnchored = root.Anchored
    root.Anchored = true
    task.delay(1, function()
        if token == Session.CoreLockToken then releaseCoreLock() end
    end)
    return character
end

local coreParagraph = Fishing:AddParagraph({
    Title = "Withering Core",
    Content = "Checking board...",
    Icon = "document-text-bold",
})
local nextStreamAt = 0
local forceCoreRefresh = false
local unavailableSince
local nextProbeAt = 0
task.spawn(function()
    local previousContent
    local boardPosition = Vector3.new(-9204.7421875, 1280.22265625, -6602.20556640625)
    local streaming = false
    local streamFailed = false
    local lastStatus = "unknown"
    local notifiedActive = false
    local statusDeadline
    while not Session.Closed do
        local now = os.clock()
        local eventCore = workspace:FindFirstChild("EventCore")
        local board = eventCore and eventCore:FindFirstChild("Main")
        local countdown = board and board:FindFirstChild("Countdown", true)
        local header = countdown and countdown:FindFirstChild("Header")
        local timer = countdown and countdown:FindFirstChild("Label")
        local title = header and header:IsA("TextLabel") and header.Text or ""
        local remaining = timer and timer:IsA("TextLabel") and timer.Text or ""

        if board then
            local ok, pivot = pcall(function() return board:GetPivot() end)
            if ok then boardPosition = pivot.Position end
        end
        local status = "unknown"
        if title == "SEDANG BERLANGSUNG" then
            status = "active"
        elseif title == "MUNCUL DALAM:" then
            status = "waiting"
        end
        if status == "waiting" then
            notifiedActive = false
        elseif status == "active" and Session.AutoCoreEnabled and not notifiedActive then
            notifiedActive = true
            pcall(function()
                StealthX:MakeNotify({ Title = "Withering Core", Content = "Event has started" })
            end)
        end
        if status ~= "unknown" then
            forceCoreRefresh = false
            streamFailed = false
            unavailableSince = nil
            lastStatus = status
            local minutes, seconds = remaining:match("(%d+)%s*m%s*(%d+)%s*d")
            statusDeadline = minutes and seconds
                and now + tonumber(minutes) * 60 + tonumber(seconds) or nil
            nextStreamAt = statusDeadline and math.max(now, statusDeadline - 2) or 0
            if Session.CoreProbe and statusDeadline then nextProbeAt = statusDeadline end
        elseif title == "" and Session.AutoCoreEnabled
            and not streaming and (forceCoreRefresh or now >= nextStreamAt) then
            forceCoreRefresh = false
            nextStreamAt = statusDeadline and statusDeadline > now + 2
                and statusDeadline - 2 or now + 15
            streaming = true
            task.spawn(function()
                local ok = pcall(function()
                    LocalPlayer:RequestStreamAroundAsync(boardPosition, 8)
                end)
                streamFailed = not ok
                streaming = false
            end)
        end
        if title == "" and Session.AutoCoreEnabled then
            unavailableSince = unavailableSince or now
        elseif not Session.AutoCoreEnabled then
            unavailableSince = nil
        end

        local missing = not eventCore and "EventCore"
            or not board and "Main"
            or not countdown and "Countdown"
            or not header and "Header"
            or not timer and "Timer"
            or "Header text"
        local content = streaming and "Loading core board (" .. missing .. ")..."
            or streamFailed and "Board stream request failed"
            or "Board unavailable (" .. missing .. ")"
        if status == "active" then
            content = "Active | " .. remaining
        elseif status == "waiting" then
            content = "Starts in " .. remaining
        elseif title == "" and statusDeadline and now < statusDeadline then
            status = lastStatus
            local secondsLeft = math.ceil(statusDeadline - now)
            local estimate = string.format("%dm %dd", math.floor(secondsLeft / 60), secondsLeft % 60)
            content = (status == "active" and "Active | " or "Starts in ")
                .. estimate .. " (estimated)"
        elseif title == "" and statusDeadline then
            content = "Waiting for board confirmation..."
        elseif title ~= "" then
            content = "Unknown | " .. title
        end
        if Session.CoreProbe and title == "" then
            content = "Checking core board at Core Spot..."
        end
        Session.CoreStatus = status

        if content ~= previousContent then
            coreParagraph:SetContent(content)
            previousContent = content
        end
        local target = Session.CoreStatus == "active" and CORE_SPOT
            or Session.CoreStatus == "waiting" and FISHING_SPOT
        if Session.AutoCoreEnabled and target and not Session.CoreProbe and not Session.SellReturn
            and not Session.SummitEnabled
            and (Session.AutoCoreLastStatus ~= Session.CoreStatus
                or Session.AutoCoreCharacter ~= LocalPlayer.Character) then
            local character = teleportToSpot(target)
            if character then
                Session.AutoCoreLastStatus = Session.CoreStatus
                Session.AutoCoreCharacter = character
            end
        end
        -- Probe only when the board is missing and the cached timer has expired.
        if Session.AutoCoreEnabled and title == "" and not Session.CoreProbe and not streaming
            and not Session.SellReturn and not Session.SummitEnabled
            and unavailableSince and now - unavailableSince >= 10
            and (not statusDeadline or now >= statusDeadline)
            and now >= nextProbeAt then
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local probe = { Character = character, Root = root, CFrame = root.CFrame }
                Session.CoreProbe = probe
                nextProbeAt = statusDeadline and statusDeadline > now
                    and statusDeadline or now + 60
                forceCoreRefresh = true
                task.spawn(function()
                    local ok, moved = pcall(teleportToSpot, CORE_SPOT)
                    if not ok or not moved then
                        stopCoreProbe()
                        return
                    end
                    local deadline = os.clock() + 1
                    while Session.CoreProbe == probe and Session.AutoCoreEnabled
                        and not Session.Closed and LocalPlayer.Character == character
                        and os.clock() < deadline do
                        task.wait(0.1)
                    end
                    if Session.CoreProbe ~= probe then return end
                    Session.CoreProbe = nil
                    if LocalPlayer.Character ~= character or root.Parent ~= character then return end
                    if Session.AutoCoreEnabled and Session.CoreStatus == "active" then
                        Session.AutoCoreLastStatus = "active"
                        Session.AutoCoreCharacter = character
                    elseif Session.AutoCoreEnabled and Session.CoreStatus == "waiting" then
                        local moved = teleportToSpot(FISHING_SPOT)
                        if moved then
                            Session.AutoCoreLastStatus = "waiting"
                            Session.AutoCoreCharacter = moved
                        end
                    else
                        teleportToSpot(probe.CFrame)
                    end
                end)
            end
        end
        task.wait(1)
    end
end)

-- Recalculate the cast direction from the character every time we cast.
-- The third CastEvent argument is a *direction* (unit Vector3), not a
-- world-space destination. The 10-stud point defines our aim; actual
-- line/cast distance is still controlled by the game's cast mechanics.
local CAST_AIM_DISTANCE = 5
local CAST_POWER_VALUES = { Low = 10, Good = 50, Perfect = 100 }
local CAST_POWER = CAST_POWER_VALUES.Perfect

local function getForwardCastDirection(character)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    -- Ignore camera pitch; always aim in front of the character on XZ.
    local facing = root.CFrame.LookVector
    local flat = Vector3.new(facing.X, 0, facing.Z)
    if flat.Magnitude < 0.001 then return nil end

    local targetPosition = root.Position + flat.Unit * CAST_AIM_DISTANCE
    return (targetPosition - root.Position).Unit
end

-- Never fire MiniGame based on a timer after casting.
-- A successful bite or an actually-visible minigame is required first.
local MIN_BITE_AGE = 0.65      -- Ignore signals from the initial cast animation.
local CATCH_INTERVAL = 0.25   -- Only tap after Catch Delay, max 4/s.
local CATCH_TIMEOUT = 5     -- Max duration of one active catching attempt.
local BITE_TIMEOUT = 5      -- If a bite never appears, recover and cast again.
local UI_END_GRACE = 1.3     -- Wait for GotFish after minigame UI disappears.
local MIN_RETRY_WAIT = 0.3 -- Give the server time to reset before the next cast.

local function isMinigameName(name)
    name = string.lower(name)
    local hasFish = name:find("fish", 1, true) ~= nil
    local hasReel = name:find("reel", 1, true) ~= nil
    return name:find("minigame", 1, true) ~= nil
        or name:find("mini_game", 1, true) ~= nil
        or (hasFish and (name:find("progress", 1, true) ~= nil
                         or name:find("reel", 1, true) ~= nil
                         or name:find("game", 1, true) ~= nil))
        or (hasReel and (name:find("bar", 1, true) ~= nil
                         or name:find("progress", 1, true) ~= nil))
end

local function guiActuallyVisible(object, parentGui)
    local current = object
    while current and current ~= parentGui do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("ScreenGui") and not current.Enabled then return false end
        current = current.Parent
    end
    return current == parentGui
end

-- UI fallback if executor lacks a namecall hook or the game never fires
-- TandaSeruBersama. Only a NEW visibility transition counts (not a
-- permanently-visible fishing icon or equipment HUD).
local function findActiveMinigame()
    local cache = Session.MinigameGuiCache
    local gui = cache and cache.Gui
    if not gui or gui.Parent ~= LocalPlayer then
        gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    if not gui then
        clearMinigameGuiCache()
        return false
    end
    if not cache or cache.Gui ~= gui then
        clearMinigameGuiCache()
        cache = { Gui = gui, Candidates = {} }
        local function addCandidate(object)
            if (object:IsA("GuiObject") or object:IsA("ScreenGui"))
                and isMinigameName(object.Name) then
                cache.Candidates[object] = true
            end
        end
        cache.Added = gui.DescendantAdded:Connect(addCandidate)
        cache.Removing = gui.DescendantRemoving:Connect(function(object)
            cache.Candidates[object] = nil
        end)
        for _, object in ipairs(gui:GetDescendants()) do
            addCandidate(object)
        end
        Session.MinigameGuiCache = cache
    end
    for object in pairs(cache.Candidates) do
        if isMinigameName(object.Name) and guiActuallyVisible(object, gui) then
            return true
        end
    end
    return false
end

local function rodRemotes(rod)
    if not rod:IsA("Tool") then return nil end
    local mechanics = rod:FindFirstChild("Mechanics")
    local remotes = mechanics and mechanics:FindFirstChild("Remotes")
    if not remotes then return nil end

    local cast = remotes:FindFirstChild("CastEvent")
    local mini = remotes:FindFirstChild("MiniGame")
    local notify = remotes:FindFirstChild("NotifyClient")
    if not cast or not cast:IsA("RemoteEvent")
        or not mini or not mini:IsA("RemoteEvent")
        or not notify or not notify:IsA("RemoteEvent") then
        return nil
    end
    return { Rod = rod, Cast = cast, Mini = mini, Notify = notify }
end

local function currentRemotes()
    local char = LocalPlayer.Character
    if not char then return nil end

    for _, tool in ipairs(char:GetChildren()) do
        local remotes = rodRemotes(tool)
        if remotes then
            remotes.Character = char
            return remotes
        end
    end

    -- Re-equip a fishing rod left in Backpack after a failed cycle.
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not backpack or not humanoid then return nil end
    for _, tool in ipairs(backpack:GetChildren()) do
        local remotes = rodRemotes(tool)
        if remotes then
            pcall(function() humanoid:EquipTool(tool) end)
            task.wait(0.18)
            if tool.Parent == char then
                remotes.Character = char
                return remotes
            end
        end
    end
    return nil
end

local webhookUrl = ""
local webhookEnabled = false
local knownRarities = {
    Epic = true, Forgotten = true, Legendary = true, Mythical = true,
    Rare = true, Secret = true, UnCommon = true,
}
local rarityOrder = {
    Forgotten = 1, Secret = 2, Mythical = 3, Legendary = 4,
    Epic = 5, Rare = 6, UnCommon = 7,
}
local rarityColors = {
    UnCommon = 0x22C55E, Rare = 0x3B82F6, Epic = 0xA855F7,
    Legendary = 0xF59E0B, Mythical = 0x8B0000,
    Secret = 0x2DD4BF, Forgotten = 0xC0C0C0,
}
local knownMutations = {
    Abyssal = true, Albino = true, Corrupt = true, Cosmic = true,
    ["Fairy Dust"] = true, Frozen = true, Galaxy = true, Gemstone = true,
    Ghost = true, Lightning = true, Midnight = true, Normal = true,
    Radioactive = true, Sandy = true, Stone = true,
}
local rarityDropdown, mutationDropdown

local function filterOptions(field, known)
    local options = {}
    local scanned = genv._StealthXFishingValues
    for value in pairs(type(scanned) == "table" and type(scanned[field]) == "table"
        and scanned[field] or {}) do
        if type(value) == "string" and value ~= "" then known[value] = true end
    end
    for value in pairs(known) do options[#options + 1] = value end
    table.sort(options, function(a, b)
        if field ~= "rarities" then return a < b end
        local first, second = rarityOrder[a] or math.huge, rarityOrder[b] or math.huge
        return first == second and a < b or first < second
    end)
    return options
end

local function addFilterOption(dropdown, known, value)
    if type(value) ~= "string" or value == "" or known[value] then return end
    known[value] = true
    dropdown:AddOption(value)
    table.insert(dropdown.Options, value)
    dropdown:Set(dropdown.Value)
end

local function selectedFilterAllows(dropdown, value)
    local selected = dropdown.Value
    return type(selected) ~= "table" or #selected == 0 or table.find(selected, value) ~= nil
end

local function validWebhookUrl(url)
    return url:match("^https://discord%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil
end

-- Resolve the actual inventory icon. Never show an unrelated stock fish photo
-- when a species cannot be resolved; the webhook can still send without media.
local thumbnailUrlCache = {}
local thumbnailInFlight = {}
local loggedFishImageFailures = {}
local missedFishRetryUntil = {}

local function normalizeFishName(value)
    if type(value) ~= "string" then return "" end
    return value:gsub("%s*%[[^%]]+%]%s*$", "")
        :gsub("^%s+", ""):gsub("%s+$", "")
        :gsub("%s+", " "):lower()
end

-- Index names once, then track additions/removals. Keep Instances (rather than
-- copied IDs) so late Icon attribute / Vector.Image updates remain visible.
local fishIconIndexes = {
    catalog = { folder = nil, names = {} },
    mastery = { folder = nil, names = {} },
}

local function indexFishFolder(index, folder)
    if index.folder == folder then return end
    if index.added then index.added:Disconnect(); index.added = nil end
    if index.removed then index.removed:Disconnect(); index.removed = nil end
    index.folder = folder
    index.names = {}
    if not folder then return end

    local function remember(child)
        index.names[normalizeFishName(child.Name)] = child
    end
    for _, child in ipairs(folder:GetChildren()) do remember(child) end
    index.added = folder.ChildAdded:Connect(remember)
    index.removed = folder.ChildRemoved:Connect(function(child)
        local key = normalizeFishName(child.Name)
        if index.names[key] == child then index.names[key] = nil end
    end)
end

Session.FishIconCacheCleanup = function()
    for _, index in pairs(fishIconIndexes) do
        if index.added then index.added:Disconnect(); index.added = nil end
        if index.removed then index.removed:Disconnect(); index.removed = nil end
        index.folder = nil
        table.clear(index.names)
    end
end

local function fishIconAssetId(data)
    local root = game:GetService("ReplicatedStorage"):FindFirstChild("AsetKenyal")
    local catalog = root and root:FindFirstChild("IkanTampil")
    local wanted = {}
    local function addName(value)
        local name = normalizeFishName(value)
        if name == "" then return end
        wanted[name] = true
        -- "Albino Big ..." and "Big Albino ..." both reduce to the species.
        for _ = 1, 4 do
            local reduced = name
            if name:sub(1, 4) == "big " then
                reduced = name:sub(5)
            else
                for mutationName in pairs(knownMutations) do
                    local prefix = mutationName:lower() .. " "
                    if name:sub(1, #prefix) == prefix then
                        reduced = name:sub(#prefix + 1)
                        break
                    end
                end
            end
            if reduced == name then break end
            wanted[reduced] = true
            name = reduced
        end
    end
    for _, field in ipairs({ "originalName", "baseName", "toolName", "fishName" }) do
        addName(data[field])
    end

    -- Catalog and Mastery use cached name indexes; inventory is examined only
    -- if neither index can supply an icon (replication may still be pending).
    local localPlayer = game:GetService("Players").LocalPlayer
    local backpack = localPlayer and localPlayer:FindFirstChildOfClass("Backpack")
    local function parseImageId(raw)
        local value = tostring(raw or "")
        return value:match("rbxassetid://(%d+)")
            or value:match("[?&]id=(%d+)")
            or value:match("^%s*(%d+)%s*$")
    end
    local nameWasFound = false
    local function matchIcon(object)
        if not wanted[normalizeFishName(object.Name)] then return nil end
        nameWasFound = true
        -- The catalog mixes Tool.TextureId and Instance attributes named Icon.
        local id = parseImageId(object:GetAttribute("Icon"))
            or parseImageId(object:GetAttribute("Image"))
            or parseImageId(object:GetAttribute("ImageId"))
        if not id and object:IsA("Tool") then
            id = parseImageId(object.TextureId)
        end
        if not id and (object:IsA("ImageLabel") or object:IsA("ImageButton")) then
            id = parseImageId(object.Image)
        end
        if not id then
            local child = object:FindFirstChild("Icon")
            if child and child:IsA("StringValue") then
                id = parseImageId(child.Value)
            elseif child and (child:IsA("ImageLabel") or child:IsA("ImageButton")) then
                id = parseImageId(child.Image)
            end
        end
        return id
    end

    indexFishFolder(fishIconIndexes.catalog, catalog)
    for key in pairs(wanted) do
        local object = fishIconIndexes.catalog.names[key]
        if object then
            local id = matchIcon(object)
            if id then return id end
        end
    end

    -- Some fish (e.g. Prismy Seahorse and Silly Easter Duck) have no icon
    -- on their Tool at all. Their species artwork is in the Mastery list's
    -- direct Vector ImageLabel, while Shape/Blank are shared UI decorations.
    local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
    local masteryIndex = fishIconIndexes.mastery
    local itemList = masteryIndex.folder
    if not (itemList and playerGui and itemList:IsDescendantOf(playerGui)) then
        local mastery = playerGui and playerGui:FindFirstChild("Mastery")
        itemList = mastery and mastery:FindFirstChild("ItemList", true)
    end
    indexFishFolder(masteryIndex, itemList)
    for key in pairs(wanted) do
        local entry = masteryIndex.names[key]
        if entry then
            nameWasFound = true
            local vector = entry:FindFirstChild("Vector")
            if vector and (vector:IsA("ImageLabel") or vector:IsA("ImageButton")) then
                local id = parseImageId(vector.Image)
                if id then return id end
            end
        end
    end

    -- Inventory is dynamic; scan it only after both indexed sources miss.
    local inventorySources = {}
    if backpack then inventorySources[#inventorySources + 1] = backpack end
    if localPlayer and localPlayer.Character then
        inventorySources[#inventorySources + 1] = localPlayer.Character
    end
    for _, container in ipairs(inventorySources) do
        for _, object in ipairs(container:GetChildren()) do
            local id = matchIcon(object)
            if id then return id end
        end
    end
    if nameWasFound then
        return nil, "species found without Icon, TextureId or Mastery Vector.Image"
    end
    return nil, catalog and "fish name not found in catalog or inventory"
        or "IkanTampil catalog unavailable; inventory has no matching fish"
end

local function fishImageUrl(data)
    local id, findReason = fishIconAssetId(data)
    if not id then
        -- Retry only once per species per cooldown window: GotFish can arrive
        -- before Backpack replication, but missing artwork should not cause
        -- repeated scans and delays on every catch.
        local key = normalizeFishName(data.originalName or data.baseName or data.toolName)
        if os.clock() >= (missedFishRetryUntil[key] or 0) then
            for _ = 1, 7 do
                if Session.Closed then return nil, "session closed" end
                task.wait(0.2)
                id, findReason = fishIconAssetId(data)
                if id then break end
            end
            if not id then missedFishRetryUntil[key] = os.clock() + 20 end
        end
    end
    if not id then return nil, findReason end

    local cached = thumbnailUrlCache[id]
    if cached and os.clock() < cached.expires then
        return cached.url, cached.reason
    end

    -- Only one request per asset may run at a time. Other catches wait for
    -- its result instead of issuing duplicate thumbnail API calls.
    if thumbnailInFlight[id] then
        local deadline = os.clock() + 10
        while thumbnailInFlight[id] and os.clock() < deadline and not Session.Closed do
            task.wait(0.1)
        end
        cached = thumbnailUrlCache[id]
        if cached and os.clock() < cached.expires then
            return cached.url, cached.reason
        end
        if thumbnailInFlight[id] then
            return nil, "thumbnail request already in progress [asset " .. id .. "]"
        end
    end
    thumbnailInFlight[id] = true

    local imageUrl = nil
    local failureReason = "thumbnail unavailable"
    local send = request or http_request or (syn and syn.request) or (http and http.request)
    if type(send) == "function" then
        -- Discord needs an HTTPS image URL, not rbxassetid://... .
        for attempt = 1, 2 do
            local ok, response = pcall(send, {
                Url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. id
                    .. "&size=420x420&format=Png&isCircular=false",
                Method = "GET",
                Headers = { ["Accept"] = "application/json" },
            })
            local status = ok and type(response) == "table" and tonumber(response.StatusCode)
            if status == 200 then
                local parsedOk, parsed = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(response.Body or "")
                end)
                local thumbnail = parsedOk and type(parsed) == "table"
                    and type(parsed.data) == "table" and parsed.data[1]
                if type(thumbnail) == "table" then
                    failureReason = "thumbnail state: " .. tostring(thumbnail.state)
                    if thumbnail.state == "Completed" then
                        local url = thumbnail.imageUrl
                        local host = type(url) == "string" and url:match("^https://([^/]+)")
                        if host and (host == "rbxcdn.com" or host:match("^[%w%-]+%.rbxcdn%.com$")) then
                            imageUrl = url
                            break
                        end
                        failureReason = "thumbnail URL is missing or invalid"
                    end
                    if thumbnail.state ~= "Pending" then break end
                else
                    failureReason = "invalid thumbnail response"
                    break
                end
            else
                failureReason = "thumbnail HTTP " .. tostring(status or "request failed")
                break
            end
            if attempt == 1 then task.wait(0.75) end
        end
    else
        failureReason = "HTTP request unavailable"
    end

    -- Only successful image URLs are sent to Discord. Retry failures later.
    thumbnailUrlCache[id] = {
        url = imageUrl,
        reason = imageUrl and nil or (failureReason .. " [asset " .. id .. "]"),
        expires = os.clock() + (imageUrl and 1800 or 20),
    }
    thumbnailInFlight[id] = nil
    return thumbnailUrlCache[id].url, thumbnailUrlCache[id].reason
end

local function warnFishImageFailure(name, reason)
    local key = tostring(name) .. "|" .. tostring(reason)
    if loggedFishImageFailures[key] then return end
    loggedFishImageFailures[key] = true
    warn("[Stealth-X Webhook] No fish image for " .. tostring(name)
        .. ": " .. tostring(reason or "unknown reason"))
end

local function postWebhook(content, imageUrl, footer, accentColor)
    local url = webhookUrl:match("^%s*(.-)%s*$")
    if not validWebhookUrl(url) then return false, "Invalid Discord webhook URL" end
    local send = request or http_request or (syn and syn.request) or (http and http.request)
    if type(send) ~= "function" then return false, "HTTP request is unavailable" end
    local card = {}
    if type(imageUrl) == "string" and imageUrl ~= "" then
        card[#card + 1] = { type = 12, items = {{ media = { url = imageUrl } }} }
        card[#card + 1] = { type = 14, spacing = 2 }
    end
    card[#card + 1] = { type = 10, content = content }
    if footer then
        card[#card + 1] = { type = 14, spacing = 2 }
        card[#card + 1] = { type = 10, content = footer }
    end
    local ok, response = pcall(send, {
        Url = url .. "?wait=true&with_components=true",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode({
            username = "Stealth-X Notify",
            avatar_url = "https://raw.githubusercontent.com/naells/NaellUI/refs/heads/main/img/pitc.jpg",
            flags = 32768,
            allowed_mentions = { parse = {} },
            components = {
                { type = 17, accent_color = accentColor or 0xFFFFFF, components = card },
                { type = 1, components = {{
                    type = 2,
                    style = 5,
                    label = "Stealth-X Discord",
                    emoji = { id = "1554112347658911804", name = "unknown", animated = false },
                    url = "https://discord.gg/NvKWVjwgGX",
                }} },
            },
        }),
    })
    if not ok then return false, "Network request failed" end
    local status = type(response) == "table" and tonumber(response.StatusCode)
    return status and status >= 200 and status < 300 and response.Success ~= false,
        "HTTP " .. tostring(status or "unknown")
end

Webhook:AddDivider()
Webhook:AddInput({
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Callback = function(value) webhookUrl = tostring(value or "") end,
})
rarityDropdown = Webhook:AddDropdown({
    Title = "Rarity Filter",
    Content = "Empty selection sends every rarity",
    Multi = true,
    Options = filterOptions("rarities", knownRarities),
    Default = {},
})
mutationDropdown = Webhook:AddDropdown({
    Title = "Mutation Filter",
    Content = "Empty selection sends every mutation",
    Multi = true,
    Options = filterOptions("mutations", knownMutations),
    Default = {},
})
Session.WebhookFilterUpdate = function(field, value)
    if Session.Closed then return end
    if field == "rarities" then
        addFilterOption(rarityDropdown, knownRarities, value)
    elseif field == "mutations" then
        addFilterOption(mutationDropdown, knownMutations, value)
    end
end
genv._StealthXFishingFilterUpdate = Session.WebhookFilterUpdate
Webhook:AddToggle({
    Title = "Enable Webhook",
    Default = false,
    Callback = function(value) webhookEnabled = value end,
})
Webhook:AddButton({
    Title = "Test Connection",
    Callback = function()
        task.spawn(function()
            local ok, reason = postWebhook(
                "# Stealth-X fishing webhook connected.\nJoin our discord for get update,\n\nBuy premium in here: https://getstealthx.site/",
                "https://i.pinimg.com/736x/bb/3a/fb/bb3afbf1f7c31bb2f893e8a7adc0a0c4.jpg")
            if not Session.Closed then
                StealthX:MakeNotify({
                    Title = "Webhook",
                    Content = ok and "Test message sent" or reason,
                })
            end
        end)
    end,
})

local function onWebhookCatch(kind, data)
    if kind ~= "GotFish" or type(data) ~= "table" or Session.Closed then return end
    local rarity = tostring(data.rarity or data.grade or "Unknown")
    local mutation = tostring(data.mutation or "Normal")
    addFilterOption(rarityDropdown, knownRarities, rarity)
    addFilterOption(mutationDropdown, knownMutations, mutation)
    if not webhookEnabled or not selectedFilterAllows(rarityDropdown, rarity)
        or not selectedFilterAllows(mutationDropdown, mutation) then return end
    local name = tostring(data.originalName or data.baseName or data.toolName or "Fish")
    local weight = tonumber(data.weight)
    local content = string.format(
        "# Fish Caught\n**Name:** %s\n**Rarity:** %s\n**Mutation:** %s\n**Big:** %s\n**Weight:** %s",
        name:sub(1, 200), rarity:sub(1, 80), mutation:sub(1, 80),
        data.big == true and "Yes" or "No",
        weight and string.format("%.2f kg", weight) or "Unknown")
    task.spawn(function()
        local imageUrl, imageReason = fishImageUrl(data)
        if not imageUrl then warnFishImageFailure(name, imageReason) end
        local ok, reason = postWebhook(content, imageUrl,
            "**Buy premium in here:** https://getstealthx.site/\nJoin our discord for get update.",
            rarityColors[rarity])
        if not ok and not Session.Closed then warn("[Stealth-X Webhook] " .. reason) end
    end)
end

local function watchWebhookCharacter(character)
    if Session.Closed then return end
    for _, connection in ipairs(Session.WebhookConnections) do connection:Disconnect() end
    for _, connection in pairs(Session.WebhookRemotes) do connection:Disconnect() end
    table.clear(Session.WebhookConnections)
    table.clear(Session.WebhookRemotes)
    local function bind(object)
        if not object:IsA("RemoteEvent") or object.Name ~= "NotifyClient" then return end
        local tool = object:FindFirstAncestorOfClass("Tool")
        if not tool or tool.Parent ~= character or Session.WebhookRemotes[object] then return end
        Session.WebhookRemotes[object] = object.OnClientEvent:Connect(onWebhookCatch)
    end
    for _, object in ipairs(character:GetDescendants()) do bind(object) end
    Session.WebhookConnections[1] = character.DescendantAdded:Connect(bind)
    Session.WebhookConnections[2] = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            for _, object in ipairs(child:GetDescendants()) do bind(object) end
        end
    end)
    Session.WebhookConnections[3] = character.ChildRemoved:Connect(function(child)
        if not child:IsA("Tool") then return end
        for remote, connection in pairs(Session.WebhookRemotes) do
            if remote:IsDescendantOf(child) then
                connection:Disconnect()
                Session.WebhookRemotes[remote] = nil
            end
        end
    end)
end

Session.WebhookCharacterConnection = LocalPlayer.CharacterAdded:Connect(watchWebhookCharacter)
if LocalPlayer.Character then watchWebhookCharacter(LocalPlayer.Character) end

local function stillRunning(token)
    return not Session.Closed and State.Enabled and State.Token == token
end

local function cutsceneActive()
    local camera = workspace.CurrentCamera
    return LocalPlayer:GetAttribute("DalamCutscene") == true
        or (camera and camera.CameraType == Enum.CameraType.Scriptable)
end

local function interruptibleWait(token, duration)
    local deadline = os.clock() + duration
    while stillRunning(token) and os.clock() < deadline do
        task.wait(math.min(0.1, math.max(0.01, deadline - os.clock())))
    end
    return stillRunning(token)
end

-- All waits are interruptible so Auto Fish OFF takes effect immediately.
-- This function performs ONE cast attempt. The outer worker always starts
-- another cycle after a success, failure, timeout or unexpected error.
local function fishCycle(token)
    State.CycleId = State.CycleId + 1
    local thisCycle = State.CycleId
    local remotes = currentRemotes()
    if not stillRunning(token) then return end
    if not remotes then
        updateStatus("Waiting for fishing rod")
        interruptibleWait(token, 0.8)
        return
    end

    local mechanics = remotes.Rod:FindFirstChild("Mechanics")
    local status = mechanics and mechanics:FindFirstChild("Status")
    local fishingActive = status and status:FindFirstChild("FishingActive")
    while stillRunning(token) and remotes.Rod.Parent == remotes.Character do
        local inCutscene = cutsceneActive()
        local rodBusy = fishingActive and fishingActive:IsA("BoolValue") and fishingActive.Value
        if not inCutscene and not rodBusy then break end
        local message = inCutscene and "Waiting for cutscene" or "Waiting for rod to reset"
        if State.Phase ~= message then updateStatus(message) end
        task.wait(0.05)
    end
    if not stillRunning(token) or remotes.Rod.Parent ~= remotes.Character then return end

    local caught = false
    local failed = false
    local failureReason = nil
    local catchName
    local biteTime
    local biteSource
    local castTime
    local wasMinigameVisible = findActiveMinigame()
    local seenMinigame = false
    local lastVisibleTime
    local cycleActive = true

    local function signalBite(source)
        if not cycleActive or State.CycleId ~= thisCycle or not stillRunning(token)
            or not State.WaitingForBite or biteTime then return end
        if not castTime or os.clock() - castTime < MIN_BITE_AGE then return end
        biteTime = os.clock()
        biteSource = source
        State.BiteTime = biteTime
        State.BiteSource = source
        updateStatus(string.format("Bite detected (%s); catch delay %.2fs", source, State.CatchDelay))
    end

    local function signalFailure(reason)
        if not caught then
            failed = true
            failureReason = reason
        end
    end

    -- Only server-sent GotFish counts as a confirmed catch. A local
    -- firesignal() would not prove that an item was awarded by the server.
    Session.CatchConnection = remotes.Notify.OnClientEvent:Connect(function(kind, data)
        if not cycleActive or State.CycleId ~= thisCycle or not stillRunning(token) then return end
        if kind == "GotFish" then
            caught = true
            if type(data) == "table" then
                catchName = tostring(data.originalName or data.baseName or data.toolName or "Fish")
            end
        elseif type(kind) == "string" then
            local eventName = kind:lower():gsub("[%s_%-]", "")
            if eventName == "bite" or eventName == "fishbite"
                or eventName == "gotbite" or eventName == "fishonhook" then
                signalBite("NotifyClient")
            elseif eventName == "fishescaped" or eventName == "linebroke"
                or eventName == "fishfailed" or eventName == "fishcancelled"
                or eventName == "fishlost" or eventName == "lostfish"
                or eventName == "fishmissed" or eventName == "missedfish"
                or eventName == "cancelled" or eventName == "failed" then
                signalFailure("Server reported " .. tostring(kind))
            end
        end
    end)

    Session.BiteListener = signalBite
    bridge.Listener = signalBite
    local biteRemote = game:GetService("ReplicatedStorage"):FindFirstChild("TandaSeruBersama")
    if biteRemote and biteRemote:IsA("RemoteEvent") then
        Session.BiteConnection = biteRemote.OnClientEvent:Connect(function()
            signalBite("Bite event")
        end)
    end

    local function rodUsable()
        return LocalPlayer.Character == remotes.Character
            and remotes.Cast.Parent ~= nil
            and remotes.Mini.Parent ~= nil
            and remotes.Notify.Parent ~= nil
            and remotes.Rod.Parent == remotes.Character
    end

    local direction = getForwardCastDirection(remotes.Character)
    if not direction then
        updateStatus("Waiting for character root")
        cycleActive = false
        disconnectCatch()
        interruptibleWait(token, 0.8)
        return
    end

    State.BiteTime = nil
    State.BiteSource = nil
    State.WaitingForBite = false
    updateStatus("Casting forward (10-stud aiming point)")
    local castOK = pcall(function()
        -- Press -> release in deterministic order, no parallel requests.
        remotes.Cast:FireServer(true)
        remotes.Cast:FireServer(false, CAST_POWER, direction)
    end)
    if not castOK then
        signalFailure("Cast error")
    else
        castTime = os.clock()
        State.CastTime = castTime
        State.WaitingForBite = true
        updateStatus("Waiting for bite (no early MiniGame calls)")
    end

    -- Phase 1: absolutely no MiniGame calls before bite is detected.
    while stillRunning(token) and not caught and not failed and not biteTime do
        if cutsceneActive() then
            cycleActive = false
            disconnectCatch()
            return
        end
        if not rodUsable() then
            signalFailure("Rod changed or unequipped")
            break
        end
        local visible = findActiveMinigame()
        if visible and not wasMinigameVisible then
            signalBite("Minigame UI")
        end
        if os.clock() - castTime >= BITE_TIMEOUT then
            signalFailure("Bite timeout")
            break
        end
        task.wait(0.12)
    end
    State.WaitingForBite = false

    -- Phase 2: delay begins at the bite signal, NOT at cast time or GotFish.
    if stillRunning(token) and biteTime and not caught and not failed then
        updateStatus(string.format("Bite confirmed - waiting %.2fs to catch", State.CatchDelay))
        while stillRunning(token) and not caught and not failed do
            local remaining = State.CatchDelay - (os.clock() - biteTime)
            if remaining <= 0 then break end
            if not rodUsable() then
                signalFailure("Rod changed or unequipped")
                break
            end
            -- Stop early if an observed minigame disappears while delaying.
            local visible = findActiveMinigame()
            if visible then
                seenMinigame = true
                lastVisibleTime = os.clock()
            elseif seenMinigame and lastVisibleTime
                and os.clock() - lastVisibleTime >= UI_END_GRACE then
                signalFailure("Minigame ended during catch delay")
                break
            end
            task.wait(math.min(0.1, remaining))
        end
    end

    -- Phase 3: only after the configured Catch Delay has elapsed.
    if stillRunning(token) and biteTime and not caught and not failed then
        updateStatus("Catching fish")
        local started = os.clock()
        local nextAttempt = started
        local attempts = 0

        while stillRunning(token) and not caught and not failed do
            local now = os.clock()
            if not rodUsable() then
                signalFailure("Rod changed or unequipped")
                break
            end
            if now - started >= CATCH_TIMEOUT then
                signalFailure("Catch timeout (no GotFish)")
                break
            end

            local visible = findActiveMinigame()
            if visible then
                seenMinigame = true
                lastVisibleTime = now
            elseif seenMinigame and lastVisibleTime
                and (now - lastVisibleTime >= UI_END_GRACE) then
                -- Minigame disappeared and server didn't confirm a catch.
                signalFailure("Minigame ended without GotFish")
                break
            end

            if now >= nextAttempt then
                attempts = attempts + 1
                local ok = pcall(function()
                    remotes.Mini:FireServer(true)
                end)
                if not ok then
                    signalFailure("MiniGame remote error")
                    break
                end
                nextAttempt = now + CATCH_INTERVAL
            end
            task.wait(0.05)
        end
    end

    cycleActive = false
    disconnectCatch()
    if not stillRunning(token) then return end

    if caught then
        State.TotalCaught = State.TotalCaught + 1
        if not biteTime then
            updateStatus("GotFish received before bite detection (server-confirmed)")
        else
            updateStatus("Caught " .. (catchName or "fish"))
        end
    else
        State.TotalFailed = State.TotalFailed + 1
        updateStatus((failureReason or "Catch not confirmed") .. " - preparing recast")
    end

    -- A near-zero requested delay can make the server ignore the next cast.
    -- Keep the recovery floor on both confirmed catches and failed cycles.
    interruptibleWait(token, math.max(MIN_RETRY_WAIT, State.RecastDelay))
end

local function startFishing()
    if Session.Closed or State.Enabled then return end
    State.Enabled = true
    State.Token = State.Token + 1
    local token = State.Token
    updateStatus("Starting")
    installBiteObserver()
    Session.Worker = task.spawn(function()
        while stillRunning(token) do
            local ok = pcall(fishCycle, token)
            if not ok then
                disconnectCatch()
                updateStatus("Cycle error; retrying")
                if not interruptibleWait(token, math.max(MIN_RETRY_WAIT, State.RecastDelay)) then break end
            end
        end
    end)
end

local SELL_POSITION = Vector3.new(-6667, 1313, -9963)

local function carriedFishCount()
    local count = 0
    for _, container in ipairs({ LocalPlayer:FindFirstChildOfClass("Backpack") or false, LocalPlayer.Character or false }) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and item:GetAttribute("UidIkan") then
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function sellOnce(token)
    if Session.Closed or Session.SellReturn then return end
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
    local mancing = remote and remote:FindFirstChild("Mancing")
    local sell = mancing and mancing:FindFirstChild("JualSemua")
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not sell or not sell:IsA("RemoteFunction") or not root then return end

    stopCoreProbe()
    releaseCoreLock()
    local saved = { Character = character, Root = root, CFrame = root.CFrame }
    Session.SellReturn = saved
    if not Session.SummitEnabled and not Session.VisualClone then
        local ok, ready = pcall(beginSummitVisual, true)
        saved.Visual = ok and ready
        if not saved.Visual then endSummitVisual() end
    end
    if saved.Cancelled or Session.SellReturn ~= saved or Session.Closed
        or Session.SummitEnabled or (token and (not Session.SellEnabled or Session.SellToken ~= token)) then
        if saved.Visual and not Session.SummitEnabled then endSummitVisual() end
        if Session.SellReturn == saved then Session.SellReturn = nil end
        return
    end
    local startPosition = saved.CFrame.Position
    local rotation = saved.CFrame.Rotation
    for step = 1, 30 do
        if saved.Cancelled or Session.SellReturn ~= saved or Session.Closed or Session.SummitEnabled
            or LocalPlayer.Character ~= character or root.Parent ~= character
            or (token and (not Session.SellEnabled or Session.SellToken ~= token)) then
            returnFromSell(saved)
            return
        end
        root.CFrame = CFrame.new(startPosition:Lerp(SELL_POSITION, step / 30)) * rotation
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.1)
    end
    task.wait(1)
    if not saved.Cancelled and Session.SellReturn == saved and not Session.Closed
        and not Session.SummitEnabled
        and LocalPlayer.Character == character and root.Parent == character
        and (not token or (Session.SellEnabled and Session.SellToken == token)) then
        task.spawn(function()
            pcall(function() sell:InvokeServer() end)
        end)
        task.wait(1)
    end
    returnFromSell(saved)
end

local function startSelling()
    if Session.Closed or Session.SellEnabled then return end
    Session.SellEnabled = true
    Session.SellToken = Session.SellToken + 1
    local token = Session.SellToken
    Session.SellWorker = task.spawn(function()
        while not Session.Closed and Session.SellEnabled and Session.SellToken == token do
            while Session.SellReturn and Session.SellEnabled and Session.SellToken == token do
                task.wait(0.05)
            end
            if not Session.SellEnabled or Session.SellToken ~= token then break end
            if Session.SellCount == 0 or carriedFishCount() >= Session.SellCount then
                sellOnce(token)
                local deadline = os.clock() + Session.SellDelay
                while not Session.Closed and Session.SellEnabled and Session.SellToken == token
                    and os.clock() < deadline do
                    if Session.SellCount > 0 and carriedFishCount() < Session.SellCount then break end
                    task.wait(math.min(0.1, math.max(0.01, deadline - os.clock())))
                end
            else
                task.wait(0.25)
            end
        end
    end)
end

local SUMMIT_ROUTE = {
    { From = Vector3.new(463, 444, -8935), To = Vector3.new(463, 444, -8953) },
    { From = Vector3.new(451, 489, -9556), To = Vector3.new(450, 489, -9576) },
    { From = Vector3.new(393, 629, -10105), To = Vector3.new(393, 628, -10127) },
    { From = Vector3.new(478, 637, -10683), To = Vector3.new(496, 637, -10685) },
    { From = Vector3.new(1084, 725, -11142), To = Vector3.new(1083, 723, -11167) },
    { From = Vector3.new(990, 733, -11811), To = Vector3.new(968, 732, -11813) },
    { From = Vector3.new(407, 885, -11835), To = Vector3.new(384, 884, -11838) },
    { From = Vector3.new(-313, 849, -11733), To = Vector3.new(-337, 847, -11736) },
    { From = Vector3.new(-856, 853, -11734), To = Vector3.new(-878, 852, -11732) },
    { From = Vector3.new(-1286, 857, -12081), To = Vector3.new(-1281, 856, -12113) },
    { From = Vector3.new(-1299, 889, -12834), To = Vector3.new(-1331, 889, -12833) },
    { From = Vector3.new(-2317, 913, -12687), To = Vector3.new(-2317, 910, -12650) },
    { From = Vector3.new(-2310, 917, -11869), To = Vector3.new(-2313, 914, -11839) },
    { From = Vector3.new(-2432, 961, -11053), To = Vector3.new(-2465, 960, -11050) },
    { From = Vector3.new(-3466, 980, -11024), To = Vector3.new(-3489, 980, -11025) },
    { From = Vector3.new(-4209, 1001, -11012), To = Vector3.new(-4237, 1000, -11012) },
    { From = Vector3.new(-4635, 1081, -11669), To = Vector3.new(-4678, 1082, -11665) },
    { From = Vector3.new(-5528, 1101, -11650), To = Vector3.new(-5557, 1100, -11650) },
    { From = Vector3.new(-6764, 1097, -11521), To = Vector3.new(-6763, 1096, -11496) },
    { From = Vector3.new(-6758, 1101, -10813), To = Vector3.new(-6759, 1102, -10788) },
    { From = Vector3.new(-6763, 1313, -10096), To = Vector3.new(-6765, 1313, -10069) },
}

local function moveCheckpoint(checkpoint)
    stopCoreProbe()
    releaseCoreLock()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    if Session.SummitTween then Session.SummitTween:Cancel() end
    root.CFrame = CFrame.new(checkpoint.From)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local tween = TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(checkpoint.To),
    })
    Session.SummitTween = tween
    tween:Play()
    local playback = tween.Completed:Wait()
    if Session.SummitTween == tween then Session.SummitTween = nil end
    return playback == Enum.PlaybackState.Completed and LocalPlayer.Character == character
end

local RETURN_POSITION = Vector3.new(-6836, 1326, -9904)

local function teleportDirect(position)
    if Session.Closed then return end
    stopCoreProbe()
    releaseCoreLock()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = CFrame.new(position) * root.CFrame.Rotation
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function checkpointProgress()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local checkpoint = leaderstats and leaderstats:FindFirstChild("Checkpoint")
    return checkpoint and checkpoint:IsA("ValueBase") and tostring(checkpoint.Value) or nil
end

local function waitForBasecampReturn(token)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false
    end
    root.CFrame = CFrame.new(RETURN_POSITION)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local deadline = os.clock() + 4
    while not Session.Closed and Session.SummitEnabled and Session.SummitToken == token
        and os.clock() < deadline do
        if checkpointProgress() == "BC" then return true end
        task.wait(0.1)
    end
    return false
end

local function startSummit()
    if Session.Closed or Session.SummitEnabled then return end
    stopCoreProbe()
    releaseCoreLock()
    Session.SummitEnabled = true
    Session.SummitToken = Session.SummitToken + 1
    local token = Session.SummitToken
    local currentIndex = 0
    local skippedIndex
    local confirmed = false
    local function progressConfirms(index)
        local progress = checkpointProgress()
        return progress == tostring(index)
            or (index == #SUMMIT_ROUTE and progress == "Summit")
    end
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
    local checkpointRemote = remote and remote:FindFirstChild("Checkpoint")
    local skippedEvent = checkpointRemote and checkpointRemote:FindFirstChild("CheckpointSkipped")
    local reachedEvent = checkpointRemote and checkpointRemote:FindFirstChild("CheckpointReached")
    local summitEvent = checkpointRemote and checkpointRemote:FindFirstChild("SummitReached")
    local teleportEvent = checkpointRemote and checkpointRemote:FindFirstChild("TpToCheckpoint")
    if not teleportEvent or not teleportEvent:IsA("RemoteEvent")
        or not skippedEvent or not skippedEvent:IsA("RemoteEvent")
        or not reachedEvent or not reachedEvent:IsA("RemoteEvent")
        or not summitEvent or not summitEvent:IsA("RemoteEvent") then
        stopSummit()
        return
    end
    Session.SummitConnections = {
        skippedEvent.OnClientEvent:Connect(function(reached, skipped)
            reached, skipped = tonumber(reached), tonumber(skipped)
            if not Session.SummitEnabled or Session.SummitToken ~= token
                or not reached or not skipped or skipped % 1 ~= 0
                or skipped < 1 or skipped >= reached or reached > currentIndex
                or skipped > #SUMMIT_ROUTE then return end
            if not skippedIndex or skipped < skippedIndex then
                skippedIndex = skipped
            end
        end),
        reachedEvent.OnClientEvent:Connect(function(index)
            if Session.SummitEnabled and Session.SummitToken == token
                and currentIndex < #SUMMIT_ROUTE and tonumber(index) == currentIndex then
                confirmed = true
            end
        end),
        summitEvent.OnClientEvent:Connect(function()
            if Session.SummitEnabled and Session.SummitToken == token
                and currentIndex == #SUMMIT_ROUTE then
                confirmed = true
            end
        end),
    }
    Session.SummitWorker = task.spawn(function()
        local workerOK = pcall(function()
            while not Session.Closed and Session.SummitEnabled and Session.SummitToken == token do
                if checkpointProgress() == "Summit" then
                    if not waitForBasecampReturn(token) then
                        task.wait(0.5)
                        continue
                    end
                end
                local resetOK = pcall(function()
                    teleportEvent:FireServer(0)
                end)
                if not resetOK then
                    task.wait(0.5)
                    continue
                end
                task.wait(0.2)
                local resetDeadline = os.clock() + 5
                local progress = checkpointProgress()
                while not Session.Closed and Session.SummitEnabled and Session.SummitToken == token
                    and progress ~= "BC" and progress ~= "0"
                    and os.clock() < resetDeadline do
                    task.wait(0.1)
                    progress = checkpointProgress()
                end
                if Session.Closed or not Session.SummitEnabled or Session.SummitToken ~= token then return end
                if progress ~= "BC" and progress ~= "0" then
                    task.wait(0.5)
                    continue
                end
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root then
                    task.wait(0.25)
                    continue
                end
                root.CFrame = CFrame.new(460, 445, -8837)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if Session.SummitDesyncEnabled then
                    local visualOK, visualReady = pcall(beginSummitVisual)
                    if not visualOK or not visualReady then
                        endSummitVisual()
                        if Session.SummitDesyncEnabled then
                            task.wait(0.25)
                            continue
                        end
                    end
                end
                local completed = true
                currentIndex = 1
                skippedIndex = nil
                confirmed = false
                local checkpointDeadline = os.clock() + 90
                while currentIndex <= #SUMMIT_ROUTE do
                    if Session.Closed or not Session.SummitEnabled or Session.SummitToken ~= token then return end
                    if os.clock() >= checkpointDeadline then
                        completed = false
                        break
                    end
                    if Session.SummitDesyncEnabled and not Session.VisualClone then
                        local visualOK, visualReady = pcall(beginSummitVisual)
                        if not visualOK or not visualReady then
                            endSummitVisual()
                            if Session.SummitDesyncEnabled then
                                task.wait(0.25)
                                continue
                            end
                        end
                    end
                    if not confirmed and not skippedIndex and not progressConfirms(currentIndex) then
                        local moved = moveCheckpoint(SUMMIT_ROUTE[currentIndex])
                        if not moved then
                            completed = false
                            break
                        end
                        local deadline = os.clock() + 0.25
                        while not confirmed and not skippedIndex
                            and not progressConfirms(currentIndex)
                            and not Session.Closed and Session.SummitEnabled and Session.SummitToken == token
                            and os.clock() < deadline do
                            task.wait(0.05)
                        end
                    end
                    if skippedIndex then
                        currentIndex = skippedIndex
                        skippedIndex = nil
                        confirmed = false
                    elseif confirmed or progressConfirms(currentIndex) then
                        currentIndex = currentIndex + 1
                        confirmed = false
                        checkpointDeadline = os.clock() + 90
                    else
                        task.wait(0.05)
                    end
                end
                currentIndex = 0
                endSummitVisual()
                if completed or checkpointProgress() == "Summit" then
                    if waitForBasecampReturn(token) then task.wait(0.1) end
                else
                    task.wait(0.25)
                end
            end
        end)
        if not workerOK and Session.SummitEnabled and Session.SummitToken == token then
            stopSummit()
        end
    end)
end

Fishing:AddInput({
    Title = "Catch Delay",
    Placeholder = "1.25",
    Default = "1.25",
    Callback = function(value)
        local number = tonumber(value)
        if number and number == number and number >= 0 and number <= 30 then
            State.CatchDelay = number
            updateStatus(State.Phase)
        end
    end,
})

Fishing:AddInput({
    Title = "Recast Delay",
    Placeholder = "0.01",
    Default = "0.01",
    Callback = function(value)
        local number = tonumber(value)
        if number and number == number and number >= 0 and number <= 30 then
            State.RecastDelay = number
            updateStatus(State.Phase)
        end
    end,
})

Fishing:AddDropdown({
    Title = "Power",
    Options = { "Low", "Good", "Perfect" },
    Default = "Perfect",
    Callback = function(value)
        CAST_POWER = CAST_POWER_VALUES[value] or CAST_POWER
    end,
})

Fishing:AddToggle({
    Title = "Auto Fish",
    Default = false,
    Callback = function(enabled)
        if enabled then
            startFishing()
        else
            stopFishing()
        end
    end,
})

local autoCoreToggle = Fishing:AddToggle({
    Title = "Auto Withering Core",
    Default = false,
    Callback = function(enabled)
        Session.AutoCoreEnabled = enabled and not Session.Closed
        Session.AutoCoreLastStatus = nil
        Session.AutoCoreCharacter = nil
        forceCoreRefresh = Session.AutoCoreEnabled
        unavailableSince = nil
        nextProbeAt = 0
        if not Session.AutoCoreEnabled then
            stopCoreProbe()
            releaseCoreLock()
        end
    end,
})

Fishing:AddButton({
    Title = "Withering Core Spot",
    Callback = function()
        stopCoreProbe()
        teleportToSpot(CORE_SPOT)
    end,
})

Fishing:AddButton({
    Title = "Fishing Spot",
    Callback = function()
        stopCoreProbe()
        teleportToSpot(FISHING_SPOT)
    end,
})

Selling:AddDivider()
Selling:AddInput({
    Title = "Sell Delay (Minutes)",
    Placeholder = "1",
    Default = "1",
    Callback = function(value)
        local minutes = tonumber(value)
        if minutes and minutes == minutes and minutes > 0 and minutes < math.huge / 60 then
            Session.SellDelay = minutes * 60
        end
    end,
})

Selling:AddInput({
    Title = "Sell By Count (0 = Timer)",
    Placeholder = "0",
    Default = "0",
    Callback = function(value)
        local count = tonumber(value)
        if count and count >= 0 and count < math.huge and count % 1 == 0 then
            Session.SellCount = count
        end
    end,
})

Selling:AddToggle({
    Title = "Auto Sell",
    Default = false,
    Callback = function(enabled)
        if enabled then
            startSelling()
        else
            stopSelling()
        end
    end,
})

Selling:AddButton({
    Title = "Sell All At Once",
    Callback = function()
        task.spawn(sellOnce)
    end,
})

Selling:AddButton({
    Title = "TP to Sell Spot",
    Callback = function()
        teleportDirect(SELL_POSITION)
    end,
})


Summit:AddDivider()
Summit:AddDropdown({
    Title = "Summit Mode",
    Options = { "Solo", "Carry Player" },
    Default = "Solo",
    Callback = function(value)
        Session.SummitDesyncEnabled = value == "Solo"
        if not Session.SummitDesyncEnabled then endSummitVisual() end
    end,
})

local summitToggle = Summit:AddToggle({
    Title = "Auto Summit",
    Default = false,
    Callback = function(enabled)
        if enabled then
            startSummit()
        else
            stopSummit()
        end
    end,
})

local checkpointOptions = {}
for index = 1, #SUMMIT_ROUTE do
    checkpointOptions[index] = "CP " .. index
end
local selectedCheckpoint = 1

Summit:AddDropdown({
    Title = "Checkpoint",
    Options = checkpointOptions,
    Default = checkpointOptions[1],
    Callback = function(value)
        local index = tonumber(tostring(value):match("^CP (%d+)$"))
        selectedCheckpoint = index and SUMMIT_ROUTE[index] and index or 1
    end,
})

Summit:AddButton({
    Title = "Go to Checkpoint",
    Callback = function()
        if Session.SummitEnabled then summitToggle:Set(false) end
        local checkpoint = SUMMIT_ROUTE[selectedCheckpoint]
        task.spawn(function()
            if Session.Closed then return end
            if Session.SummitDesyncEnabled and not beginSummitVisual() then
                return
            end
            moveCheckpoint(checkpoint)
            endSummitVisual()
        end)
    end,
})

return {
    teleportToSpot = teleportToSpot,
    CORE_SPOT = CORE_SPOT,
    FISHING_SPOT = FISHING_SPOT,
    SELL_POSITION = SELL_POSITION,
    RETURN_POSITION = RETURN_POSITION,
    teleportDirect = teleportDirect,
    summitToggle = summitToggle,
    autoCoreToggle = autoCoreToggle,
}
end
