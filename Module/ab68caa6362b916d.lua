return function(ctx)
    local StealthX = ctx.StealthX
    local Session = ctx.Session
    local BuySkin = ctx.BuySkin
    local BuyRod = ctx.BuyRod


do
    local skinOptions = {
        { Label = "Blazing Fire | 300K Coin", Value = "Blazing Fire" },
        { Label = "Overlord's Trident | 600K Coin", Value = "Overlord's Trident" },
        { Label = "Empyrean Staff | 1M Coin", Value = "Empyrean Staff" },
        { Label = "Overdrive | 2.5M Coin", Value = "Overdrive" },
        { Label = "Dragonmaster Scythe | 2.5M Coin", Value = "Dragonmaster Scythe" },
    }
    local rodOptions = {
        { Label = "Ares Rod | 15K Coin", Value = "Ares Rod" },
        { Label = "Bamboo Rod | 120K Coin", Value = "Bamboo Rod" },
        { Label = "Element Rod | 400K Coin", Value = "Element Rod" },
        { Label = "Diamond Rod | 1M Coin", Value = "Diamond Rod" },
        { Label = "Withering Rod | 1.5M Coin", Value = "Withering Rod" },
    }

    local function selectedItem(dropdown, options)
        for _, option in ipairs(options) do
            if option.Value == dropdown.Value then return option.Value end
        end
    end

    local pendingPurchase = {}
    local function purchase(shopName, remoteName, itemName, itemType)
        if Session.Closed then return end
        if not itemName then
            StealthX:MakeNotify({ Title = "Shop", Content = "Select an item first" })
            return
        end
        local root = game:GetService("ReplicatedStorage"):FindFirstChild("Remote")
        local shop = root and root:FindFirstChild(shopName)
        local remote = shop and shop:FindFirstChild(remoteName)
        if not remote or not remote:IsA("RemoteFunction") then
            StealthX:MakeNotify({ Title = "Shop", Content = "Purchase remote unavailable" })
            return
        end
        if pendingPurchase[shopName] then return end
        pendingPurchase[shopName] = true
        local ok, result = pcall(function()
            if itemType then return remote:InvokeServer(itemType, itemName) end
            return remote:InvokeServer(itemName)
        end)
        pendingPurchase[shopName] = nil
        if Session.Closed then return end
        local message = not ok and ("Purchase failed: " .. tostring(result))
            or result == false and "Purchase rejected"
            or ("Purchase request sent: " .. itemName)
        StealthX:MakeNotify({ Title = "Shop", Content = message })
    end

    BuySkin:AddDivider()
    local skinDropdown = BuySkin:AddDropdown({
        Title = "Skin",
        Options = skinOptions,
        Default = skinOptions[1].Value,
    })
    BuySkin:AddButton({
        Title = "Buy Skin",
        Callback = function()
            local item = selectedItem(skinDropdown, skinOptions)
            task.spawn(purchase, "SkinShop", "MintaBeli", item)
        end,
    })

    BuyRod:AddDivider()
    local rodDropdown = BuyRod:AddDropdown({
        Title = "Rod",
        Options = rodOptions,
        Default = rodOptions[1].Value,
    })
    BuyRod:AddButton({
        Title = "Buy Rod",
        Callback = function()
            local item = selectedItem(rodDropdown, rodOptions)
            task.spawn(purchase, "KoinShop", "Beli", item, "rod")
        end,
    })
end
end
