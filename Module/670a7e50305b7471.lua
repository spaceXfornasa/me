return function(ctx)
    local StealthX = ctx.StealthX
    local Session = ctx.Session
    local stopCoreProbe = ctx.stopCoreProbe
    local TeleportPlace = ctx.TeleportPlace
    local teleportToSpot = ctx.Main.teleportToSpot
    local CORE_SPOT = ctx.Main.CORE_SPOT
    local FISHING_SPOT = ctx.Main.FISHING_SPOT
    local SELL_POSITION = ctx.Main.SELL_POSITION
    local RETURN_POSITION = ctx.Main.RETURN_POSITION
    local teleportDirect = ctx.Main.teleportDirect
    local summitToggle = ctx.Main.summitToggle
    local autoCoreToggle = ctx.Main.autoCoreToggle

TeleportPlace:AddDivider()
local placeDropdown = TeleportPlace:AddDropdown({
    Title = "Place",
    Options = { "Withering Core Spot", "Fishing Spot", "Sell Spot", "Basecamp" },
    Default = "Withering Core Spot",
})

TeleportPlace:AddButton({
    Title = "Continue",
    Callback = function()
        if Session.Closed then return end
        local place = placeDropdown.Value
        if place ~= "Withering Core Spot" and place ~= "Fishing Spot"
            and place ~= "Sell Spot" and place ~= "Basecamp" then
            StealthX:MakeNotify({ Title = "Teleport", Content = "Select a valid place" })
            return
        end
        if Session.SummitEnabled then
            summitToggle.Value = false
            summitToggle:Set(false)
        end
        if Session.AutoCoreEnabled then
            autoCoreToggle.Value = false
            autoCoreToggle:Set(false)
        end
        if place == "Withering Core Spot" then
            stopCoreProbe()
            teleportToSpot(CORE_SPOT)
        elseif place == "Fishing Spot" then
            stopCoreProbe()
            teleportToSpot(FISHING_SPOT)
        elseif place == "Sell Spot" then
            teleportDirect(SELL_POSITION)
        elseif place == "Basecamp" then
            teleportDirect(RETURN_POSITION)
        end
    end,
})

end
