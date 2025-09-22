local ModuleHandler = {}
local modules = {}
local server = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")

function ModuleHandler:Init()
    local remotesFolder = ReplicatedStorage.Source.RemoteEvents
    local tempEvent = remotesFolder:GetAttribute("MainRemote")
    tempEvent = remotesFolder[tempEvent]

    tempEvent.OnClientEvent:Connect(function(p_server: {})
        server = p_server

        tempEvent:Destroy()
        remotesFolder:SetAttribute("MainRemote", nil)
    end)
    tempEvent:FireServer()

    repeat task.wait() until server ~= nil
	for _, module in script:GetDescendants() do
		module = require(module)
		pcall(function()
			module:Init()
		end)
	end
end

function ModuleHandler:Start()
	for _, module in modules do
		pcall(function()
			module:Start()
		end)
	end
end

function ModuleHandler:CreateModule(moduleInfo: { Name: string }): {}
	assert(not modules[moduleInfo.Name], `Module with name {moduleInfo.Name} already exists!`)

	local newModule = {}
	modules[moduleInfo.Name] = newModule
    newModule.Server = server

	return newModule
end

function ModuleHandler:GetModule(moduleName: string)
	return modules[moduleName]
end

return ModuleHandler
