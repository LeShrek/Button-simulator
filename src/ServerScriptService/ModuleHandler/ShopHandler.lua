local ModuleHandler = require(script.Parent)
local ShopHandler = ModuleHandler:CreateModule({
    Name = "ShopHandler",
    Client = {
        InitShop = ModuleHandler:CreateRemoteEvent(),
        ItemPurchased = ModuleHandler:CreateRemoteEvent()
    }
})

function ShopHandler:Init()
    self.Client.InitShop.OnServerEvent:Connect(function(player: Player)
        self.Client.InitShop:FireClient(player, self.Config.ShopConfig)
    end)

    self.Client.ItemPurchased.OnServerEvent:Connect(function(player: Player, categoryIndex: number, itemIndex: number)
        local item = self.Config.ShopConfig.Shop[categoryIndex].Items[itemIndex]

        local canPurchase = false
        if item.Currency == "Robux" then

        else
            local amount = ModuleHandler:GetModule("DataHandler"):CheckData(player, item.Currency)
            if amount then
                canPurchase = amount >= item.Price
                
                local message = canPurchase and `{item.Name} purchased` or `You are missing {item.Price - amount} {item.Currency}`
                warn(message)
            end
        end

        if not canPurchase then return end

        ModuleHandler:GetModule("DataHandler"):RemoveFromData(player, item.Currency, item.Price)
        item.Func(player, ModuleHandler, item.FuncValues)
    end)
end

return ShopHandler