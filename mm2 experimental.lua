local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Rayfield Example Window",
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


-- Button örneği
local Button = Tab:CreateButton({
   Name = "Button Example",
   Callback = function()
      -- LocalPlayer'ın karakterini verilen CFrame'e taşı
      local targetCFrame = CFrame.new(
          -88.1816788, 153.099915, 107.587769,  -- Pozisyon (X, Y, Z)
          0.594115794, 6.93327493e-08, 0.804379523,  -- Rotation (X, Y, Z)
          -4.84397269e-08, 1, -5.04164284e-08,  -- Rotation (X, Y, Z)
          -0.804379523, -9.01072905e-09, 0.594115794   -- Rotation (X, Y, Z)
      )
      
      -- Eğer LocalPlayer'ın karakteri varsa, taşı
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
          LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
      end
   end,
})

-- ESP fonksiyonu
local espEnabled = false -- ESP'nin aktif olup olmadığı

-- Highlight ESP fonksiyonu (Mavi Highlight için)
local function createHighlightESP(player, color)
    local character = player.Character
    if not character then return end

    -- Zaten highlight varsa tekrar ekleme
    if character:FindFirstChild("ESP_Highlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = color  -- Renk parametre olarak alır
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)  -- Beyaz outline
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Parent = character
end

-- Knife'ı kontrol et (hem Backpack, hem Character'da)
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

-- Gun'ı kontrol et (hem Backpack, hem Character'da)
local function hasGun(player)
    -- Backpack'te Gun var mı?
    local backpack = player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("Gun") then
        return true
    end

    -- Character'da Gun var mı? (Elinde olmalı)
    local character = player.Character
    if character and character:FindFirstChild("Gun") then
        return true
    end

    return false
end

-- Serverdaki tüm oyuncuları kontrol et
local function checkAllPlayers()
    if not espEnabled then return end  -- Eğer ESP kapalıysa, işlemi durdur

    for _, player in ipairs(Players:GetPlayers()) do
        if hasKnife(player) then
            createHighlightESP(player, Color3.fromRGB(255, 0, 0))  -- Knife için kırmızı highlight
        end
        if hasGun(player) then
            createHighlightESP(player, Color3.fromRGB(0, 0, 255))  -- Gun için mavi highlight
        end
    end
end

-- Toggle fonksiyonu (Aç/Kapa)
local Toggle = Tab:CreateToggle({
    Name = "Toggle ESP",
    CurrentValue = false,
    Flag = "Toggle1",  -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        espEnabled = Value  -- Eğer toggle açılırsa, ESP aktif edilir, kapanırsa devre dışı bırakılır
        if espEnabled then
            checkAllPlayers()  -- ESP aktif ise, tüm oyuncuları kontrol et
        end
    end,
})

-- Toggle'ı her saniye güncelle
task.spawn(function()
    while true do
        task.wait(1)  -- 1 saniye bekle
        Toggle:Set(espEnabled)  -- Toggle'ı güncelle (açık/kapalı)
        if espEnabled then
            checkAllPlayers()  -- Eğer ESP aktifse, tüm oyuncuları kontrol et
        end
    end
end)

-- Anchor Toggle fonksiyonu
local AnchorToggle = Tab:CreateToggle({
    Name = "Anchor Toggle",
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




















local aimbotActive = false
local buttonClicked = false

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
   Name = "Enable Aimbot",
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
end)

-- Kamera kitlenmesi (2 stud yanına kitlenmesi)
RunService.RenderStepped:Connect(function()
    if aimbotActive then
        local target = GetClosestMurderer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPosition = target.Character.Head.Position
            local cameraPosition = Camera.CFrame.Position
            local direction = (headPosition - cameraPosition).unit

            -- Kamerayı sadece 2 stud sağa kaydıracak şekilde ayarla
            local targetPosition = headPosition + Vector3.new(2, 0, 0)  -- **2 stud** sağa kaydırma

            -- Kamera kitlenmesi
            Camera.CFrame = CFrame.new(cameraPosition, targetPosition)
        end
    end
end)









