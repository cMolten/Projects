local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },

    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },

    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
})

local Tab = Window:CreateTab("mm2", 4483362458) -- Title


--dropdown
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerDropdown -- Global değişken

-- Dropdown yaratıcı fonksiyon
local function CreatePlayerDropdown()
    -- Oyuncu listesi
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end

    -- Eğer PlayerDropdown var ise, seçenekleri güncelle
    if PlayerDropdown then
        PlayerDropdown:SetOptions(names)  -- Dropdown içeriğini güncelle
    else
        -- Eğer dropdown yoksa, yeni bir tane oluştur
        PlayerDropdown = Tab:CreateDropdown({
            Name = "teleport to player (beta)",
            Options = names,
            CurrentOption = {},
            MultipleOptions = false,
            Flag = "PlayerList",
            Callback = function(Selected)
                local target = Players:FindFirstChild(Selected[1])
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(2, 0, 0))
                    end
                end
            end,
        })
    end
end

-- Başlangıçta, UI'nin tam olarak yüklenmesini bekleyelim
task.wait(1)  -- 1 saniye bekle, UI'nin tam yüklenmesini sağla
CreatePlayerDropdown()  -- Dropdown'u oluştur

-- Oyuncular girince veya çıkınca dropdown'u güncelle
Players.PlayerAdded:Connect(function()
    task.wait(0.5)  -- Oyuncu eklenince biraz bekleyip sonra dropdown'u güncelle
    CreatePlayerDropdown()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)  -- Oyuncu çıkınca biraz bekleyip sonra dropdown'u güncelle
    CreatePlayerDropdown()
end)

-- Başlangıçta dropdown'u oluşturduktan sonra her saniye güncelle
task.spawn(function()
    while true do
        task.wait(1)  -- Her 1 saniyede bir dropdown'u güncelle
        CreatePlayerDropdown()  -- Dropdown içeriğini güncelle
    end
end)









local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local espEnabled = false

-- Her oyuncunun highlight'ını burada saklayacağız
local playerHighlights = {}
local gunDropHighlights = {}

-- Highlight oluştur veya güncelle
local function updateHighlight(player, color)
    local character = player.Character
    if not character then return end

    local highlight = playerHighlights[player]

    -- Highlight yoksa oluştur
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = game.CoreGui
        playerHighlights[player] = highlight
    end

    if highlight.FillColor ~= color then
        highlight.FillColor = color
    end

    if highlight.Adornee ~= character then
        highlight.Adornee = character
    end
end

-- Knife kontrolü
local function hasKnife(player)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    return (backpack and backpack:FindFirstChild("Knife")) or (character and character:FindFirstChild("Knife"))
end

-- Gun kontrolü
local function hasGun(player)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    return (backpack and backpack:FindFirstChild("Gun")) or (character and character:FindFirstChild("Gun"))
end

-- ESP güncelleme fonksiyonu
local function checkAllPlayers()
    if not espEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local color

            if hasKnife(player) then
                color = Color3.fromRGB(255, 0, 0)
            elseif hasGun(player) then
                color = Color3.fromRGB(0, 0, 255)
            else
                color = Color3.fromRGB(0, 255, 0)
            end

            updateHighlight(player, color)
        end
    end
end

-- Oyuncular karakter değiştirince yeniden bağla
local function setupPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then
            checkAllPlayers()
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupPlayer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        setupPlayer(player)
    end
end)

-- GunDrop ESP için Highlight (şerifin düşürdüğü silah)
local function highlightGunDrop(part)
    if part:IsA("Part") and part.Name == "GunDrop" and not gunDropHighlights[part] then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(0, 0, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Adornee = part
        highlight.Parent = part
        gunDropHighlights[part] = highlight
    end
end

local function removeAllGunDropHighlights()
    for part, hl in pairs(gunDropHighlights) do
        if hl and hl.Parent then
            hl:Destroy()
        end
    end
    gunDropHighlights = {}
end

local function checkAllGunDrops()
    if not espEnabled then return end
    for _, descendant in ipairs(workspace:GetDescendants()) do
        highlightGunDrop(descendant)
    end
end

workspace.DescendantAdded:Connect(function(descendant)
    if espEnabled then
        highlightGunDrop(descendant)
    end
end)

-- Toggle ESP sistemi (Oyuncu + GunDrop senkron)
local Toggle = Tab:CreateToggle({
    Name = "All Players Esp",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            checkAllPlayers()
            checkAllGunDrops()
        else
            -- Oyuncu ESP'lerini temizle
            for _, hl in pairs(playerHighlights) do
                hl:Destroy()
            end
            playerHighlights = {}

            -- GunDrop ESP'lerini temizle
            removeAllGunDropHighlights()
        end
    end,
})

-- Sürekli güncelleme (anlık değişiklik için)
task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then
            checkAllPlayers()
            checkAllGunDrops()
        end
    end
end)

-- CFrame taşıma butonu (senin verdiğin)
local Button = Tab:CreateButton({
   Name = "Go lobby",
   Callback = function()
      local targetCFrame = CFrame.new(
          -88.1816788, 153.099915, 107.587769,
          0.594115794, 6.93327493e-08, 0.804379523,
          -4.84397269e-08, 1, -5.04164284e-08,
          -0.804379523, -9.01072905e-09, 0.594115794
      )
      
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
          LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
      end
   end,
})







-- Anchor Toggle fonksiyonu
local AnchorToggle = Tab:CreateToggle({
    Name = "Tp players in front of you",
    CurrentValue = false,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
       -- Eğer toggle açık ise, anchor fonksiyonunu tetikle
       if Value then
          -- Anchor'la ve oyuncuları ışınla
          for _, player in ipairs(Players:GetPlayers()) do
             if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
                 -- LocalPlayer'ın HumanoidRootPart'ını al
                 local localHumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                 if localHumanoidRootPart then
                     -- Oyuncuyu LocalPlayer'ın önüne ışınla
                     local targetPosition = localHumanoidRootPart.Position + localHumanoidRootPart.CFrame.LookVector * 5  -- LocalPlayer'ın önüne 5 birim mesafede
                     player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)  -- Oyuncuyu ışınla
                     -- Anchor'la
                     player.Character.HumanoidRootPart.Anchored = true
                 end
             end
          end
       else
          -- Eğer toggle kapalıysa, anchor'ı kaldır
          for _, player in ipairs(Players:GetPlayers()) do
             if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
                 -- HumanoidRootPart'ı unanchorla
                 local humanoidRootPart = player.Character.HumanoidRootPart
                 humanoidRootPart.Anchored = false
             end
          end
       end
    end,
 })



--aimbot




local aimbotActive = false
local buttonClicked = false
local rightClickActive = false  -- Sağ tıklama durumu

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- FOV Circle (Ekran ortasında)
local FOV_RADIUS = 150  -- FOV yarıçapı
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = false  -- Başlangıçta gizli, butona tıklanmadığı sürece görünmeyecek
FOV_Circle.Radius = FOV_RADIUS
FOV_Circle.Thickness = 1
FOV_Circle.Color = Color3.fromRGB(255, 255, 255)
FOV_Circle.Filled = false
FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Knife kontrolü (katilin olup olmadığını kontrol et)
local function hasKnife(player)
    -- Backpack'te Knife var mı?
    local backpack = player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("Knife") then
        return true
    end

    -- Character'da Knife var mı? (Elinde olmalı)
    local character = player.Character
    if character and character:FindFirstChild("Knife") then
        return true
    end

    return false
end

-- En yakın katili bul
local function GetClosestMurderer()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS -- FOV_radius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and hasKnife(player) then
            local character = player.Character
            if character and character:FindFirstChild("Head") then
                local screenPos, onScreen = Camera:WorldToScreenPoint(character.Head.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

                if onScreen and distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Buton oluşturma
local Button = Tab:CreateButton({
   Name = "Enable Aimbot with V bind",
   Callback = function()
      -- Butona basıldığında V tuşunu aktif et
      buttonClicked = true
      print("Butona basıldı, V tuşu aktif!")
   end,
})

-- V tuşu ile aimbot açma ve kapama
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if buttonClicked and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.V then
        aimbotActive = not aimbotActive  -- Aimbot durumu değiştirilir
        if aimbotActive then
            FOV_Circle.Visible = true  -- Aimbot açıldığında FOV da görünür olacak
            print("Aimbot açıldı!")
        else
            FOV_Circle.Visible = false  -- Aimbot kapatıldığında FOV gizlenecek
            print("Aimbot kapatıldı!")
        end
    end

    -- Sağ tık basıldığında aimbot aktif olmalı
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightClickActive = true  -- Sağ tık aktif
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightClickActive = false  -- Sağ tık bırakıldığında kitlenme duracak
    end
end)

-- Kamera kitlenmesi (2 stud sağa veya sola kaydırma)
RunService.RenderStepped:Connect(function()
    if aimbotActive and rightClickActive then
        local target = GetClosestMurderer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPosition = target.Character.Head.Position
            local cameraPosition = Camera.CFrame.Position

            -- Hedefin pozisyonunu ve yönünü hesapla
            local directionToTarget = (headPosition - cameraPosition).unit
            local forwardDirection = Camera.CFrame.LookVector
            local rightDirection = Camera.CFrame.RightVector

            -- Hedefin sağında mı solunda mı olduğunu kontrol et
            local dotProduct = directionToTarget:Dot(forwardDirection) -- Hedefin bakış yönünü kontrol et

            local targetPosition
            if dotProduct > 0 then
                -- Hedef kameranın önündeyse, sağa kaydır
                targetPosition = headPosition + rightDirection * 2  -- **2 stud** sağa kaydırma
            else
                -- Hedef kameranın arkasındaysa, sola kaydır
                targetPosition = headPosition - rightDirection * 2  -- **2 stud** sola kaydırma
            end

            -- Kamerayı kitlenmesi
            Camera.CFrame = CFrame.new(cameraPosition, targetPosition)
        end
    end
end)




--hide mode



local Button = Tab:CreateButton({
    Name = "Hide mode With X bind",
    Callback = function()
        print("Hide Mode script loaded! Press X to use.")

        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local camera = workspace.CurrentCamera

        local isAnchored = false
        local humanoidRootPart
        local originalCFrame
        local originalCameraCFrame

        -- Karakter setup
        local function setupCharacter(character)
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        end

        setupCharacter(player.Character or player.CharacterAdded:Wait())

        player.CharacterAdded:Connect(function(newCharacter)
            -- Eğer hide mode aktifken ölürsen sıfırla
            if isAnchored then
                RunService:UnbindFromRenderStep("KeepCameraHeight")
                isAnchored = false
            end
            setupCharacter(newCharacter)
        end)

        -- X tuşuna basınca anchor işlemleri
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.X then
                if not humanoidRootPart then
                    warn("HumanoidRootPart bulunamadı!")
                    return
                end

                if not isAnchored then
                    -- GERÇEK doğru pozisyonu kaydet
                    originalCFrame = humanoidRootPart.CFrame
                    originalCameraCFrame = camera.CFrame

                    -- Karakteri aşağı kaydır
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -30, 0)
                    task.wait(0.1)

                    -- Anchor aktif et
                    humanoidRootPart.Anchored = true

                    -- Kamerayı sabit tut
                    RunService:BindToRenderStep("KeepCameraHeight", Enum.RenderPriority.Camera.Value, function()
                        local camCFrame = camera.CFrame
                        camera.CFrame = CFrame.new(camCFrame.Position.X, originalCameraCFrame.Position.Y, camCFrame.Position.Z) * camCFrame.Rotation
                    end)
                else
                    -- Anchor kaldır
                    humanoidRootPart.Anchored = false

                    -- Doğrudan eski pozisyona ışınla
                    humanoidRootPart.CFrame = originalCFrame
                    camera.CFrame = originalCameraCFrame

                    -- Kamera sabitlemeyi bırak
                    RunService:UnbindFromRenderStep("KeepCameraHeight")
                end

                -- Durumu ters çevir
                isAnchored = not isAnchored
            end
        end)
    end,
})






local Button = Tab:CreateButton({
    Name = "Noclip with N bind",
    Callback = function()
        print("Button pressed, now waiting for N key press to toggle CanCollide.")

        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        -- Başlangıçta karakter verileri
        local character
        local lowerTorso
        local upperTorso
        local humanoidRootPart
        local canCollideDisabled = false
        local renderStepConnection

        local function setupCharacter(char)
            character = char
            lowerTorso = character:WaitForChild("LowerTorso")
            upperTorso = character:WaitForChild("UpperTorso")
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")

            if canCollideDisabled then
                lowerTorso.CanCollide = false
                upperTorso.CanCollide = false
                humanoidRootPart.CanCollide = false
            end
        end

        -- İlk karakter ayarlaması
        setupCharacter(player.Character or player.CharacterAdded:Wait())

        -- Ölünce yeni karakter gelince setup
        player.CharacterAdded:Connect(function(newCharacter)
            -- Karakter değiştiğinde tekrar ayarla
            if renderStepConnection then
                renderStepConnection:Disconnect()
            end
            canCollideDisabled = false
            setupCharacter(newCharacter)
        end)

        -- N tuşuna basınca NoClip aç/kapat
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.N then
                if not (lowerTorso and upperTorso and humanoidRootPart) then
                    warn("Parts not ready!")
                    return
                end

                canCollideDisabled = not canCollideDisabled

                if canCollideDisabled then
                    print("Noclip ENABLED")

                    -- Sürekli her frame CanCollide = false yap
                    renderStepConnection = RunService.RenderStepped:Connect(function()
                        if lowerTorso then lowerTorso.CanCollide = false end
                        if upperTorso then upperTorso.CanCollide = false end
                        if humanoidRootPart then humanoidRootPart.CanCollide = false end
                    end)
                else
                    print("Noclip DISABLED")

                    -- Render connection'ı kapat
                    if renderStepConnection then
                        renderStepConnection:Disconnect()
                        renderStepConnection = nil
                    end

                    -- CanCollide = true yap
                    lowerTorso.CanCollide = true
                    upperTorso.CanCollide = true
                    humanoidRootPart.CanCollide = true
                end
            end
        end)
    end,
})
