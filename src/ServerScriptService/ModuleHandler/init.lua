local ModuleHandler = {}
local modules = {}
local config = {}

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function ModuleHandler:Init()
    local remoteFolder = Instance.new("Folder", ReplicatedStorage.Source)
    remoteFolder.Name = "RemoteEvents"

    local configFolder = script.Parent.Config
    for _, configModule in configFolder:GetChildren() do
        config[configModule.Name] = require(configModule)
    end

    for _, module in script:GetDescendants() do
        module = require(module)
        pcall(function()
            module:Init()
        end)
    end

    local mainRemote = Instance.new("RemoteEvent")
    mainRemote.Name = HttpService:GenerateGUID(false)
    mainRemote.Parent = remoteFolder

    remoteFolder:SetAttribute("MainRemote", mainRemote.Name)

    local function sendRemotesToClient(player: Player)
        local toClient = {}
        for moduleName, moduleInfo in modules do
            if not moduleInfo.Client then continue end

            toClient[moduleName] = moduleInfo.Client
        end

        mainRemote:FireClient(player, toClient)
    end

    mainRemote.OnServerEvent:Connect(sendRemotesToClient)
end

function ModuleHandler:Start()
	for _, module in modules do
		pcall(function()
			module:Start()
		end)
	end
end

function ModuleHandler:CreateRemoteEvent() : RemoteEvent
    local remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Parent = ReplicatedStorage.Source.RemoteEvents
    remoteEvent.Name = HttpService:GenerateGUID(false)
    return remoteEvent
end

function ModuleHandler:CreateModule(moduleInfo: {Name: string, Client: {[string]: RemoteEvent?}?}): {}
    assert(not modules[moduleInfo.Name], `Module with name {moduleInfo.Name} already exists!`)
    
    local newModule = {}
    if moduleInfo.Client then newModule.Client = moduleInfo.Client end
    newModule.Config = config

    modules[moduleInfo.Name] = newModule

    return newModule
end

function ModuleHandler:GetModule(moduleName: string)
    return modules[moduleName]
end

return ModuleHandler