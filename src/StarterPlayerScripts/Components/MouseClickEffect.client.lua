-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Constants
local PLAYER = Players.LocalPlayer
local MOUSE = PLAYER:GetMouse()
local SCREEN_GUI: ScreenGui = PLAYER.PlayerGui:WaitForChild("MouseEffect")
local TWEEN_INFO = TweenInfo.new(
    .5,
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)

-- Variables
local framesPool = {} :: {Frame}

-- Functions
local function createFrame(): Frame
	-- Create a frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0.05, 0.05)
    frame.BackgroundColor3 = Color3.new(1,1,1)
    frame.BackgroundTransparency = .5
    frame.AnchorPoint = Vector2.one / 2

	-- Create a uiaspectratio constraint
	local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
	uiAspectRatio.Parent = frame

	-- Create a uicorner constraint
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame

    return frame
end

local function mousePressed()
    local mousePos = Vector2.new(MOUSE.X, MOUSE.Y)

    local frame = framesPool[1] or createFrame()
    if table.find(framesPool, frame) then
        table.remove(framesPool, 1)
    end
	frame.Parent = SCREEN_GUI

    frame.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)

    local tween = TweenService:Create(frame, TWEEN_INFO, {Size = UDim2.fromScale(0, 0), BackgroundTransparency = 1})
    tween:Play()

    tween.Completed:Once(function()  
        frame.Size = UDim2.fromScale(0.05, 0.05)
        frame.BackgroundTransparency = .5
        frame.Parent = nil
        table.insert(framesPool, frame)
    end)
end

MOUSE.Button1Down:Connect(function()
    task.spawn(mousePressed)
end)

-- Preload with 10 frames
task.spawn(function()
    for _ = 1, 10 do
        local frame = createFrame()
		table.insert(framesPool, frame)
        task.wait()
    end
end)