repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

-- 🔗 WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/1486898527979176078/l0yYukaA74r3abQqjmEr5mZd7D5L64b4zC5Zt_OLPbuGj1pabuanntEAGveeXpSA3bSz"

local request = request or http_request or syn and syn.request

-- 🎮 INFO
local jobId = game.JobId

-- 📍 RUTA BASES
local rutaBases = workspace:FindFirstChild("Plots")

--------------------------------------------------
-- 🧠 LISTA (SOLO LOS QUE QUIERES)

local INCLUDE = {
["Cerberus"]=true,["Headless Horseman"]=true,["Ketchuru and Musturu"]=true,
["Swaggy Bros"]=true,["Fragrama and Chocrama"]=true,["Ginger Gerat"]=true,
["Spooky and Pumpky"]=true,["Hydra Dragon Cannelloni"]=true,["Meowl"]=true,
["Los Spaghettis"]=true,["Los Sekolahs"]=true,["Cooki and Milki"]=true,
["Festive 67"]=true,["Garama and Madundung"]=true,["Dragon Gingerini"]=true,
["Tang Tang Keletang"]=true,["La Food Combinasion"]=true,["Rosey and Teddy"]=true,
["Capitano Moby"]=true,["Tang Tang Kelentang"]=true,["Tralaledon"]=true,
["La Supreme Combinasion"]=true,["Ketupat Kepat"]=true,["Skibidi Toilet"]=true,
["Ketupat Bros"]=true,["Eviledon"]=true,["Tictac Sahur"]=true,
["Lavadorito Spinito"]=true,["Chillin Chili"]=true,["Dragon Cannelloni"]=true,
["Popcuru and Fizzuru"]=true,["La Casa Boo"]=true,["La Taco Combinasion"]=true,
["Orcaledon"]=true,["Chipso and Queso"]=true,["Strawberry Elephant"]=true,
["W or L"]=true,["La Secret Combinasion"]=true,["La Romantic Grande"]=true
}

--------------------------------------------------
-- 🧠 MEMORIA
local estado = {}

--------------------------------------------------
-- 🛑 ANTI-AFK COMPLETO

-- 🖱️ CLIC
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ⌨️ MOVIMIENTO REAL (W automático)
task.spawn(function()
    while true do
        task.wait(300) -- 5 minutos

        print("🛑 Anti-AFK movimiento iniciado")

        -- caminar
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        task.wait(1.5)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)

        task.wait(0.5)

        -- segunda caminata
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        task.wait(1.5)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)

        print("🛑 Anti-AFK movimiento terminado")
    end
end)

--------------------------------------------------
-- 📢 DISCORD
local function enviarDiscord(base, nombre)
    if not request then return end

    local link = "https://www.roblox.com/games/start?placeId=109983668079237&gameInstanceId="..jobId

    local data = {
        ["content"] =
        "🔥 **DETECTADO**\n\n"..
        "📍 Base: "..base.."\n"..
        "🧠 Brainrot: "..nombre.."\n\n"..
        "👉 [🚀 JOIN](<"..link..">)"
    }

    local json = HttpService:JSONEncode(data)

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end)
end

--------------------------------------------------
-- 🔍 ESCANEO
local function escanear()
    local actual = {}

    if not rutaBases then return actual end

    for _, base in ipairs(rutaBases:GetChildren()) do
        if base:IsA("Model") then

            for nombre, _ in pairs(INCLUDE) do
                if base:FindFirstChild(nombre, true) then

                    local key = base.Name .. "_" .. nombre
                    actual[key] = true

                    if not estado[key] then
                        print("🔥 Detectado:", base.Name, nombre)
                        enviarDiscord(base.Name, nombre)
                        estado[key] = true
                    end
                end
            end

        end
    end

    return actual
end

--------------------------------------------------
-- 🚀 LOOP INFINITO
while true do
    local actuales = escanear()

    for key, _ in pairs(estado) do
        if not actuales[key] then
            print("❌ Desapareció:", key)
            estado[key] = nil
        end
    end

    task.wait(2)
end