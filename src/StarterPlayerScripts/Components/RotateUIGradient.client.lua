-- Services
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

-- Constants
local TAG = "RotateUIGradient"
local TWEEN_INFO = TweenInfo.new(
    4,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.In,
    0,
    false,
    0
)

-- Variables
local tagged = {}

local function addInstance(instance: UIGradient)
    if tagged[instance] then
        task.cancel(tagged[instance].task)
        tagged[instance] = nil
        return
    end

    tagged[instance] = {}
    tagged[instance].start = instance.Rotation
    tagged[instance].finish = instance.Rotation + 360

    tagged[instance].task = task.spawn(function()
        local tween = TweenService:Create(instance, TWEEN_INFO, {Rotation = tagged[instance].finish})

        local function doTween()
            tween:Play()
            tween.Completed:Wait()
            instance.Rotation = tagged[instance].start
            doTween()
        end

        doTween()
    end)
end

for _, instance in CollectionService:GetTagged(TAG) do
    addInstance(instance)
end

CollectionService:GetInstanceAddedSignal(TAG):Connect(addInstance)
CollectionService:GetInstanceRemovedSignal(TAG):Connect(addInstance)

