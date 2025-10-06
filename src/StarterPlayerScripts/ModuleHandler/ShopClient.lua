local ModuleHandler = require(script.Parent)
local ShopClient = ModuleHandler:CreateModule({
    Name = "ShopClient"
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

-- Modules
local TopbarPlus = require(ReplicatedStorage.Packages.topbarplus)

-- Constants
local PLAYER = Players.LocalPlayer
local SHOP_GUI = PLAYER.PlayerGui:WaitForChild("ShopGui") :: ScreenGui
local EXIT_BUTTON = SHOP_GUI:WaitForChild("ExitButton") :: GuiButton
local MAIN_FRAME = SHOP_GUI:WaitForChild("Frame") :: CanvasGroup
local CATEGORY_FRAME = MAIN_FRAME:WaitForChild("CategoryFrame") :: ScrollingFrame
local ITEMS_FRAME_PREFAB = MAIN_FRAME:WaitForChild("ItemsFrame") :: ScrollingFrame
local ITEM_PREFAB = ITEMS_FRAME_PREFAB:WaitForChild("ItemsPrefab") :: TextButton?
local CATEGORY_PREFAB = CATEGORY_FRAME:WaitForChild("CategoryPrefab") :: ScrollingFrame?

local MAIN_FRAME_OUTLINE = SHOP_GUI:WaitForChild("Outline") :: Frame
local ITEM_PREVIEW = SHOP_GUI:WaitForChild("ItemPreview") :: Frame

local PURCHASE_BUTTON = ITEM_PREVIEW:WaitForChild("Frame"):WaitForChild("PurchaseButton") :: TextButton
local PREVIEW_PRICE = PURCHASE_BUTTON:WaitForChild("Frame"):WaitForChild("Price") :: TextLabel
local PREVIEW_CURRENCY_ICON = PURCHASE_BUTTON.Frame:WaitForChild("CurrencyIcon") :: ImageLabel
local PREVIEW_EXIT_BUTTON = ITEM_PREVIEW.Frame:WaitForChild("Exit") :: TextButton
local PREVIEW_IMAGE = ITEM_PREVIEW.Frame:WaitForChild("Image") :: ImageLabel
local PREVIEW_ITEM_NAME = ITEM_PREVIEW.Frame:WaitForChild("ItemName") :: TextLabel
local PREVIEW_DESCRIPTION = ITEM_PREVIEW.Frame:WaitForChild("Description") :: TextLabel
local PREVIEW_PURCHASE = ITEM_PREVIEW.Frame:WaitForChild("PurchaseButton") :: GuiButton

-- Variables
local currentSelectedCategory = nil :: Frame?
local purchaseItemConnection = nil :: RBXScriptConnection?

-- Local functions
local function initShop(config)
    task.spawn(function()
        for _, currencyIcon in config.Config.Icons do
            ContentProvider:PreloadAsync({currencyIcon})
        end
    end)

	PREVIEW_EXIT_BUTTON.Activated:Connect(function() 
		EXIT_BUTTON.Visible = true
		MAIN_FRAME_OUTLINE.Visible = true
		MAIN_FRAME.Visible = true

        if purchaseItemConnection then
            purchaseItemConnection:Disconnect()
            purchaseItemConnection = nil
        end

		ITEM_PREVIEW.Visible = false
    end)

    for categoryIndex, categoryInfo in config.Shop do
        do
            local categoryButton = CATEGORY_PREFAB:Clone()
            categoryButton.Name = categoryInfo.Name
            local button = categoryButton:FindFirstChild("Button") :: GuiButton
            button.BackgroundColor3 = categoryInfo.BackgroundColor
            
            local textLabel = button:FindFirstChild("TextLabel") :: TextLabel
            textLabel.Text = categoryInfo.Name
            
            button.Activated:Connect(function()
                local targetFrame = MAIN_FRAME:FindFirstChild(categoryInfo.Name.."-Items")

                if currentSelectedCategory == targetFrame then return end

                currentSelectedCategory.Visible = false
                currentSelectedCategory = targetFrame
                currentSelectedCategory.Visible = true
            end)
            categoryButton.Parent = CATEGORY_FRAME
        end

        local itemsFrame = ITEMS_FRAME_PREFAB:Clone()
        itemsFrame.Name = categoryInfo.Name.."-Items"
        itemsFrame.Visible = false
        itemsFrame.Parent = MAIN_FRAME

        if not currentSelectedCategory then
            currentSelectedCategory = itemsFrame
            currentSelectedCategory.Visible = true
        end

        for itemIndex, itemInfo in categoryInfo.Items do
            local item = ITEM_PREFAB:Clone()
            item.Name = itemInfo.Name
            item:FindFirstChild("ItemName").Text = itemInfo.Name
            item:FindFirstChild("Icon").Image = itemInfo.ImageId
            item:FindFirstChild("CurrencyIcon").Image = config.Config.Icons[itemInfo.Currency]

            local priceLabel = item:FindFirstChild("PriceLabel")
            priceLabel.Text = itemInfo.Price
            priceLabel.TextColor3 = config.Config.Colors[itemInfo.Currency]
            
            item.Activated:Connect(function()

                PREVIEW_PRICE.Text = itemInfo.Price
                PREVIEW_PRICE.TextColor3 = config.Config.Colors[itemInfo.Currency]
                PREVIEW_CURRENCY_ICON.Image = config.Config.Icons[itemInfo.Currency]

                PREVIEW_IMAGE.Image = itemInfo.ImageId
                PREVIEW_ITEM_NAME.Text = itemInfo.Name
                PREVIEW_DESCRIPTION.Text = itemInfo.Description

                EXIT_BUTTON.Visible = false
                MAIN_FRAME_OUTLINE.Visible = false
                MAIN_FRAME.Visible = false

                ITEM_PREVIEW.Visible = true

                if purchaseItemConnection then
                    purchaseItemConnection:Disconnect()
                    purchaseItemConnection = nil
                end

                purchaseItemConnection = PREVIEW_PURCHASE.Activated:Connect(function()
                    ShopClient.Server.ShopHandler.ItemPurchased:FireServer(categoryIndex, itemIndex)
                end)

            end)

            item.Parent = itemsFrame
        end
    end
end

local function openShop()
    SHOP_GUI.Enabled = true
end

local function closeShop()
    SHOP_GUI.Enabled = false
end

local function createShopButton()
	local shopButton = TopbarPlus.new()
    shopButton:setName("ShopButton")

	shopButton:oneClick(true)
	shopButton:setCaption("Open the shop")
    shopButton:setImage("rbxassetid://106834296028572")
    shopButton:setImageScale(.9)
    shopButton:getInstance("IconImage").ResampleMode = Enum.ResamplerMode.Pixelated
	shopButton:bindEvent("selected", openShop)
end

-- Public functions
function ShopClient:Init()
    CATEGORY_PREFAB.Parent = nil
    ITEM_PREFAB.Parent = nil
    ITEMS_FRAME_PREFAB.Parent = nil

    EXIT_BUTTON.Activated:Connect(closeShop)

	ShopClient.Server.ShopHandler.InitShop.OnClientEvent:Once(initShop)
	ShopClient.Server.ShopHandler.InitShop:FireServer()

    warn("Robux icon missing")
end

function ShopClient:Start()
    createShopButton()
end

return ShopClient