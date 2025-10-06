local ModuleHandler = require(script.Parent)
local DataHandler = ModuleHandler:CreateModule({
    Name = "DataHandler",
    Client = {
        MoneyButtonPressed = ModuleHandler:CreateRemoteEvent(),
        UpdateMoneyButtonText = ModuleHandler:CreateRemoteEvent()
    }
})

-- Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Constants
local REBIRTH_MULTIPLIER = 1
local MONEY_BUTTON_DEFAULT_PRICE = 1

-- Local functions
local function calculateMoneyButtonPrice(amount, rebirthsValue): number
    return amount * (1 + (REBIRTH_MULTIPLIER * rebirthsValue.Value))
end

local function playerAdded(player: Player)
    local rebirthsValue = nil

    for folderName, folderData in DataHandler.Config.PlayersData do
        local folder = Instance.new("Folder")
        folder.Name = folderName
        folder.Parent = player

        for _, valueInfo in folderData do
            local instance = Instance.new(valueInfo.Type)
            instance.Name = valueInfo.Name
            instance.Value = valueInfo.StartingValue
            instance.Parent = folder

            if valueInfo.Name == "Rebirths" then
                rebirthsValue = instance
            end

            if not valueInfo.DoSave then continue end
            local datastore = valueInfo.IsOrderedDataStore and DataStoreService:GetOrderedDataStore(valueInfo.DataStoreName) or DataStoreService:GetDataStore(valueInfo.DataStoreName)
            pcall(function()
                local data = datastore:GetAsync(valueInfo.Name.."-"..player.UserId)
                if not data then return end

                instance.Value = data
            end)
        end
    end

    local amount = calculateMoneyButtonPrice(MONEY_BUTTON_DEFAULT_PRICE, rebirthsValue)
    DataHandler.Client.UpdateMoneyButtonText:FireClient(player, amount)
end

local function playerRemoving(player: Player)
    for folderName, folderData in DataHandler.Config.PlayersData do
        local folder = player:FindFirstChild(folderName)
        if not folder then continue end

        for _, valueInfo in folderData do
            if not valueInfo.DoSave then continue end
            local valueInstance = folder:FindFirstChild(valueInfo.Name)
            if not valueInstance then continue end

			local datastore = valueInfo.IsOrderedDataStore and DataStoreService:GetOrderedDataStore(valueInfo.DataStoreName) or DataStoreService:GetDataStore(valueInfo.DataStoreName)
            pcall(function()
                datastore:SetAsync(valueInfo.Name.."-"..player.UserId, valueInstance.Value)
            end)
        end
    end
end

local function getDataInstance(player: Player, dataName: string): Instance?
	local value = nil
	for folder, values in DataHandler.Config.PlayersData do
		for _, valueData in values do
			if valueData.Name ~= dataName then
				continue
			end

			local folderInstance = player:FindFirstChild(folder)
			if not folderInstance then
				return
			end

			local valueInstance = folderInstance:FindFirstChild(dataName)
			if not valueInstance then
				return
			end

			value = valueInstance
			break
		end
	end
	return value
end

-- Public functions
function DataHandler:Init()
    Players.PlayerAdded:Connect(playerAdded)
    Players.PlayerRemoving:Connect(playerRemoving)
end

function DataHandler:Start()
    self.Client.MoneyButtonPressed.OnServerEvent:Connect(function(...)
        self:MoneyButtonPressed(..., 1)
    end)
end

function DataHandler:MoneyButtonPressed(player: Player, amount: number)
	local moneyValue = player:FindFirstChild("Money", true)
	local rebirthsValue = player:FindFirstChild("Rebirths", true)

	if not moneyValue then
		return
	end
	if not rebirthsValue then
		return
	end

    moneyValue.Value += calculateMoneyButtonPrice(amount, rebirthsValue)
end

function DataHandler:AddToData(player, dataName: string, amount: number)
    local instance = getDataInstance(player, dataName)
    if not instance then return end
    instance.Value += amount
end

function DataHandler:RemoveFromData(player, dataName: string, amount: number)
	local instance = getDataInstance(player, dataName)
	if not instance then return end
	instance.Value -= amount
end

function DataHandler:CheckData(player: Player, dataName: string): any
    local instance = getDataInstance(player, dataName)
    return instance and instance.Value
end

return DataHandler