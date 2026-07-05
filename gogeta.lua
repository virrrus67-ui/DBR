local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = Players.LocalPlayer or Players.PlayerAdded:Wait()

local character = Client.Character or Client.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local bossSpawns = workspace.Map.bossSpawns

local Network = require(
    ReplicatedStorage:WaitForChild("Modules")
        :WaitForChild("Library")
        :WaitForChild("Network")
)

local function GetTransformInfo()
    local Character = Client.Character
    if not Character then return end

    local Stats = Client:FindFirstChild("Stats")
    local State = Character:FindFirstChild("State")

    if Stats and State then
        local selected = Stats:FindFirstChild("SelectedMode")
        local active = State:FindFirstChild("ActiveMode")

        if selected and active then
            return selected.Value, active.Value
        end
    end
end

local function Transform()
    local EquippedMode, EnabledMode = GetTransformInfo()

    if EquippedMode and (not EnabledMode or EnabledMode == "") then
        pcall(function()
            Network:InvokeServer("Transform", "Quick")
        end)
        return true
    end
end

local function GetBoss(name)
    for _, obj in ipairs(bossSpawns:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == name then
            if obj:GetAttribute("Spawned") == true then
                return obj
            end
        end
    end
end

local boss = GetBoss("Piccolo")

if boss then
    Transform()
    task.wait(0.2)

    root.CFrame = CFrame.new(
        boss:GetPivot().Position + Vector3.new(0, -5, 0)
    )
else
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Cesare0328/my-scripts/refs/heads/main/CachedServerhop.lua"
    ))()
end
