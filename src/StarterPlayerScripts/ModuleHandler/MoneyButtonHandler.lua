local ModuleHandler = require(script.Parent)
local MoneyButtonHandler = ModuleHandler:CreateModule({
    Name = "MoneyButtonHandler"
})

-- Services
local Players = game:GetService("Players")

-- Constants
local PLAYER = Players.LocalPlayer
local GAIN_MONEY_BUTTON: TextButton = PLAYER.PlayerGui:WaitForChild("ButtonUI"):WaitForChild("Frame"):WaitForChild("GainMoneyButton")
local DEBOUNCE_DURATION = .2

-- Variables
local isDebounce = false

-- Local functions
local function fireMoneyButtonPressed()
    if isDebounce then return end

    isDebounce = true    
    task.delay(DEBOUNCE_DURATION, function()
        isDebounce = false
    end)

	MoneyButtonHandler.Server.DataHandler.MoneyButtonPressed:FireServer()
end

local function updateMoneyText(amount: number)
    GAIN_MONEY_BUTTON.Text = "+ $"..amount
end

-- Public functions
function MoneyButtonHandler:Init()
    self.Server.DataHandler.UpdateMoneyButtonText.OnClientEvent:Connect(updateMoneyText)
end

function MoneyButtonHandler:Start()
    GAIN_MONEY_BUTTON.Activated:Connect(fireMoneyButtonPressed)

    warn("Add effect: Coin spawn from button and head towards player, the same kinda effect of the german xolbor game")
    warn("Change some coloring so it fits with the money, gems and robux coloring of the shop")
end

return MoneyButtonHandler