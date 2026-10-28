return function(ctx)
    local StealthX = ctx.StealthX
    local RunService = ctx.RunService
    local TeleportService = ctx.TeleportService
    local LocalPlayer = ctx.LocalPlayer
    local Session = ctx.Session
    local Utility = ctx.Utility
    local stopAntiAfk = ctx.stopAntiAfk
    local stopAutoRejoin = ctx.stopAutoRejoin
    local startAutoRejoin = ctx.startAutoRejoin
    local stopAntiLag = ctx.stopAntiLag
    local startAntiLag = ctx.startAntiLag
    local Connection = ctx.Connection
    local Performance = ctx.Performance

Connection:AddDivider()
Connection:AddToggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(enabled)
        stopAntiAfk()
        if enabled then
            Utility.AfkConnection = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    local virtualUser = game:GetService("VirtualUser")
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.zero)
                end)
            end)
        end
    end,
})

Connection:AddToggle({
    Title = "Auto Rejoin / Reconnect",
    Default = false,
    Callback = function(enabled)
        if enabled then startAutoRejoin() else stopAutoRejoin() end
    end,
})

Connection:AddButton({
    Title = "Rejoin",
    Callback = function()
        task.spawn(function()
            if Session.Closed then return end
            local ok, err = pcall(function()
                if game.JobId ~= "" then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                else
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end)
            if not ok and not Session.Closed then
                StealthX:MakeNotify({ Title = "Rejoin Failed", Content = tostring(err) })
            end
        end)
    end,
})

do
    local hopping = false
    Connection:AddButton({
        Title = "Hop Server",
        Callback = function()
            if hopping or Session.Closed then return end
            hopping = true
            task.spawn(function()
                local ok, reason = pcall(function()
                    local httpService = game:GetService("HttpService")
                    local cursor
                    for _ = 1, 3 do
                        local url = string.format(
                            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true",
                            game.PlaceId)
                        if cursor then url = url .. "&cursor=" .. httpService:UrlEncode(cursor) end
                        local data = httpService:JSONDecode(game:HttpGet(url))
                        if type(data) ~= "table" or type(data.data) ~= "table" then
                            error("Invalid public server list")
                        end
                        local available = {}
                        for _, server in ipairs(data.data) do
                            if type(server) == "table" and type(server.id) == "string"
                                and server.id ~= game.JobId
                                and (tonumber(server.playing) or 0) < (tonumber(server.maxPlayers) or 0) then
                                available[#available + 1] = server.id
                            end
                        end
                        if #available > 0 then
                            if Session.Closed then return end
                            TeleportService:TeleportToPlaceInstance(game.PlaceId,
                                available[math.random(#available)], LocalPlayer)
                            return
                        end
                        cursor = data.nextPageCursor
                        if type(cursor) ~= "string" or cursor == "" then break end
                    end
                    error("No other available public server found")
                end)
                hopping = false
                if not ok and not Session.Closed then
                    StealthX:MakeNotify({ Title = "Hop Server Failed", Content = tostring(reason) })
                end
            end)
        end,
    })
end

Performance:AddDivider()
local normalLagToggle
local superLagToggle
normalLagToggle = Performance:AddToggle({
    Title = "Anti Lag Normal",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if superLagToggle then superLagToggle:Set(false) end
            startAntiLag("normal")
        elseif Utility.LagMode == "normal" then
            stopAntiLag()
        end
    end,
})

superLagToggle = Performance:AddToggle({
    Title = "Anti Lag Super",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if normalLagToggle then normalLagToggle:Set(false) end
            startAntiLag("super")
        elseif Utility.LagMode == "super" then
            stopAntiLag()
        end
    end,
})

Performance:AddToggle({
    Title = "Disable 3D Render",
    Default = false,
    Callback = function(enabled)
        local ok = pcall(function() RunService:Set3dRenderingEnabled(not enabled) end)
        if ok then Utility.RenderDisabled = enabled end
    end,
})
end
