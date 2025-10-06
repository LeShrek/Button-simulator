export type Category = {
    Name: string,
    BackgroundColor: Color3,
    Items: {[string]: Item}
}

export type Item = {
    Name: string,
    Price: number,
    Currency: "Money" | "Gems" | "Robux",
    ImageId: string,
    Description: string,
    Func: (player: Player, API: {}, values: {any}) -> boolean,
    FuncValues: {any}
}

-- Local functions 
-- IMPORTANT: This will be fired from the server
local function AddMoney(player: Player, API, values: {number})
    API:GetModule("DataHandler"):AddToData(player, "Money", values[1])
end

local function AddGems(player: Player, API, values: {number})
	API:GetModule("DataHandler"):AddToData(player, "Gems", values[1])
end

return {
    ["Config"] = {
        Colors = {
            Money = Color3.fromRGB(241, 147, 16),
            Gems = Color3.fromRGB(0, 157, 241),
            Robux = Color3.fromRGB(1, 167, 15)
        },

        Icons = {
            Money = "rbxassetid://110700777881144",
            Gems = "rbxassetid://109316434578031",
            Robux = "rbxassetid://110652555784913"
        }
    },

    ["Shop"] = {
        {
            Name = "Item Shop",
            BackgroundColor = Color3.fromRGB(241, 147, 16),
            Items = {
                {
                    Name = "Test purchase",
                    Price = 1,
                    Currency = "Money",
                    ImageId = "rbxassetid://106834296028572",
                    Description = "This is a test purchase, only for admin",
                    Func = AddGems,
                    FuncValues = {10}
                },

                {
                    Name = "+ 10 Gems",
                    Price = 5000,
                    Currency = "Money",
                    ImageId = "rbxassetid://106834296028572",
                    Description = "You will receive 10 gems",
                    Func = AddGems,
                    FuncValues = {10}
                }
            }
        },
        
        {
            Name = "Gems Shop",
            BackgroundColor = Color3.fromRGB(0, 157, 241),
            Items = {
                {
                    Name = "+ $500",
                    Price = 100,
                    Currency = "Gems",
                    ImageId = "rbxassetid://106834296028572",
                    Description = "You will receive $500",
                    Func = AddMoney,
                    FuncValues = {500}
                }
            }
        },
        
        {
            Name = "Robux Shop",
            BackgroundColor = Color3.fromRGB(1, 167, 15),
            Items = {
                {
                    Name = "+ 50 Gems",
                    Price = 500,
                    Currency = "Robux",
                    ImageId = "rbxassetid://106834296028572",
                    Description = "You will receive 50 gems",
                    Func = AddGems,
                    FuncValues = {50}
                },

                {
                    Name = "+ 500 Gems",
                    Price = 4000,
                    Currency = "Robux",
                    ImageId = "rbxassetid://106834296028572",
                    Description = "You will receive 500 gems",
                    Func = AddGems,
                    FuncValues = {500}
                }
            }
        }
    } :: {{Category}}
}
