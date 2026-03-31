repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

-- 🔗 WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/1486898527979176078/l0yYukaA74r3abQqjmEr5mZd7D5L64b4zC5Zt_OLPbuGj1pabuanntEAGveeXpSA3bSz"

local request = request or http_request or (syn and syn.request)

-- 🎮 INFO
local placeId = 109983668079237
local jobId = game.JobId

-- 📍 RUTAS
local rutaBases = workspace:WaitForChild("Plots")
local rutaPasarela = workspace:FindFirstChild("RenderedMovingAnimals")

-- 🎯 LISTA
local lbuscar = {
    "Bacuru and Egguru","Los Combinasionas","Esok Sekolah","Espaguetis Tualetti",
    "Cerberus","La Taco Combinasion","Ketchuru and Musturu","Swaggy Bros",
    "Burguro And Fryuro","Nuclearo Dinossauro","Ginger Gerat","Spooky and Pumpky",
    "Los Amigos","Los Bros","Tuff Toucan","Meowl","Los Spaghettis","Festive 67",
    "Tictac Sahur","Money Money Puggy","Ketupat Kepat","Garama and Madundung",
    "Reinito Sleighito","Hydra Dragon Cannelloni","Dragon Gingerini","Hokka Horloge",
    "La Supreme Combinasion","Fragrama and Chocrama","Tang Tang Keletang",
    "La Food Combinasion","Rosey and Teddy","Rosetti Tualetti","Chillin Chili",
    "Las Sis","Capitano Moby","Los Tacorites","Los Tacoritas","Skibidi Toilet",
    "Ketupat Bros","W or L","Tang Tang Kelentang","Eviledon","Swag Soda",
    "Lavadorito Spinito","La Ginger Sekolah","Dragon Cannelloni",
    "Popcuru and Fizzuru","La Casa Boo","Headless Horseman","La Romantic Grande",
    "Chipso and Queso","Strawberry Elephant","Los Puggies",
    "La Secret Combinasion","Cooki and Milki"
}

-- 🧠 MEMORIA REAL
local yaNotificado = {}
local tiempoNotificado = {}
local COOLDOWN = 15 -- segundos entre notificaciones para la misma base

--------------------------------------------------
-- 🛑 ANTI-AFK
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--------------------------------------------------
-- 📢 DISCORD EMBED
local function enviarDiscord(lista)
    if not request then return end
    local LocalPlayer = Players.LocalPlayer

    -- Convertimos la lista en texto enumerado
    local listaEnumerada = ""
    for i, v in ipairs(lista) do
        listaEnumerada = listaEnumerada .. i .. ". " .. v .. "\n"
    end

    local data = {
        ["embeds"] = {{
            ["title"] = "🔥 Brainrots Detectados",
            ["description"] = listaEnumerada,
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "🤖 Bot", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "🆔 JobId", ["value"] = jobId, ["inline"] = true},
                {["name"] = "🚀 Unirse", ["value"] = "[Click para entrar](https://www.roblox.com/games/start?placeId="..placeId.."&gameInstanceId="..jobId..")", ["inline"] = false}
            },
            ["footer"] = {["text"] = "Cix Finder • Auto Scanner"}
        }}
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
-- 🔍 DETECTAR
local function detectar()
    local resultado = {}

    if rutaBases then
        for _, base in ipairs(rutaBases:GetChildren()) do
            if base:IsA("Model") then
                local encontrados = {}

                for _, v in ipairs(lbuscar) do
                    if base:FindFirstChild(v, true) then
                        table.insert(encontrados, v)
                    end
                end

                if #encontrados > 0 then
                    table.sort(encontrados)
                    local key = base:GetDebugId() .. "_" .. #encontrados

                    resultado[key] = {
                        base = base.Name,
                        lista = encontrados
                    }
                end
            end
        end
    end

    return resultado
end

--------------------------------------------------
-- 🚀 LOOP PRINCIPAL
task.wait(3)

while true do
    print("🔍 Escaneando...")

    local actuales = detectar()
    local ahora = tick()

    -- ✅ NOTIFICAR SOLO NUEVOS O COOLDOWN
    for key, data in pairs(actuales) do
        if not yaNotificado[key] or (tiempoNotificado[key] and ahora - tiempoNotificado[key] > COOLDOWN) then
            print("🔥 NUEVO:", data.base)
            enviarDiscord(data.lista)

            yaNotificado[key] = true
            tiempoNotificado[key] = ahora
        end
    end

    -- 🧹 LIMPIAR LOS QUE YA NO EXISTEN
    for key, _ in pairs(yaNotificado) do
        if not actuales[key] then
            yaNotificado[key] = nil
            tiempoNotificado[key] = nil
        end
    end

    task.wait(3)
end
