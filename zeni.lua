if not game:IsLoaded() then game.Loaded:Wait() task.wait(1) end

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TeleportService = game:GetService('TeleportService')
local GuiService = game:GetService('GuiService')
local Client = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Network = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('Library'):WaitForChild('Network'))

local HiddenFlags, Connections = {
    WorldData = {
        ['Time Chamber'] = {
            PlaceId = 1362482151,
        },
        ['Gravity Chamber'] = {
            PlaceId = 3371469539,
        },
        ['Hell'] = {
            PlaceId = 15669378828,
        },
        ['Beerus Planet'] = {
            PlaceId = 3336119605,
        },
        ['Earth'] = {
            PlaceId = 71315343,
        }
    }
}, {}

local GetRoot; do
    GetRoot = function(Character) return Character and Character:FindFirstChild('HumanoidRootPart') end

    GetDragonBallData = function()
        local Stats = Client:FindFirstChild('Stats')
        local DragonBalls = Stats and Stats:FindFirstChild('DragonBalls')
        if not DragonBalls then return end

        local DragonBallsString = DragonBalls.Value
        local DragonBalls, IsFull = {}, true

        for Index, BallData in DragonBallsString:split(';') do
            local Ball = BallData:split('=')
            local BallNumber = Ball and tonumber(Ball[1])
            if not BallNumber then continue end
            DragonBalls[BallNumber] = true
        end

        for Number = 1, 7 do
            if not DragonBalls[Number] then
                IsFull = false
            end
        end

        return DragonBalls, IsFull
    end

    GetDragonBall = function(DragonBalls)
        for Index, Model in workspace.Map:GetChildren() do
            local SpawnPos = Model:GetAttribute('SpawnPos')
            local BallNumber = Model:GetAttribute('BallNum')

            if SpawnPos and BallNumber then
                if DragonBalls[BallNumber] then continue end

                return Model
            end
        end
    end

    DragonBallFinder = function()
        local EarthId = HiddenFlags.WorldData.Earth.PlaceId
        if game.PlaceId ~= EarthId then TeleportService:Teleport(EarthId) task.wait(5) end

        local Character = Client.Character
        local Root = GetRoot(Character)
        if not Root then return end

        local DragonBalls, IsFull, BallFound = GetDragonBallData()
        if IsFull then return end

        local DragonBall = GetDragonBall(DragonBalls)

        if DragonBall then
            HiddenFlags.DataStoreDelay = true
            BallFound = true
            Root.CFrame = DragonBall:GetPivot() + vector.create(0, -5, 0)

            if not HiddenFlags.ProximityPrompt then
                HiddenFlags.ProximityPrompt = true

                task.delay(0.5, function()
                    local Prox = DragonBall:FindFirstChild('ProximityPrompt', true)

                    if Prox then
                        fireproximityprompt(Prox)
                    end

                    task.wait(0.5)
                    HiddenFlags.ProximityPrompt = false
                end)
            end
        end

        if not BallFound then
            if HiddenFlags.DataStoreDelay then task.wait(1) end
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Cesare0328/my-scripts/refs/heads/main/CachedServerhop.lua'))()
        end
    end
end

for Index, Connection in getconnections(Client.Idled) do
    Connection:Disconnect()
end

table.insert(Connections, Client.OnTeleport:Connect(function()
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/virrrus67-ui/DBR/main/zeni.lua"))()
    ]])
end))

table.insert(Connections, TeleportService.TeleportInitFailed:Connect(function()
    task.wait(5)
    TeleportService:Teleport(game.PlaceId)
end))

table.insert(Connections, GuiService.ErrorMessageChanged:Connect(function()
    task.wait(2)
    TeleportService:Teleport(game.PlaceId)
end))

while task.wait() do
    local _, IsDragonBallFull = GetDragonBallData()
  
    if not IsDragonBallFull then
        DragonBallFinder()
        continue
    end

    local EarthId = HiddenFlags.WorldData.Earth.PlaceId

    if game.PlaceId ~= EarthId then
        TeleportService:Teleport(EarthId)
        task.wait(5)
        continue
    end
  
    local Character = Client.Character
    local Root = GetRoot(Character)
    if not Root then
        continue
    end
  
    local CenterPedestial = workspace.Map.Pedestal.Center
    local Tick = tick()
  
    while Root and tick() - Tick < 0.5 and task.wait() do
        Root.CFrame = CenterPedestial.CFrame + vector.create(0,-5,0)
    end
  
    fireproximityprompt(CenterPedestial.Attachment.ProximityPrompt)
    Network:FireServer('SelectWish', 'Zeni')
    task.wait(5)
end
