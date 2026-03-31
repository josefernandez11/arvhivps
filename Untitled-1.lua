repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

-- 🔗 WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/1485119599610564609/Bi3AMAKqmgd-gBYl2RixwIeXjwtcAHaPAFsa9fF3fVGU11Mr7xBTNezSV0k72J2FrPDY"

local request = request or http_request or syn and syn.request

-- 🎮 INFO
local placeId = 109983668079237
local jobId = game.JobId

-- 📍 RUTAS
local rutaBases = workspace:FindFirstChild("Plots")
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

--------------------------------------------------
-- 🛑 ANTI-AFK
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--------------------------------------------------
-- 📢 DISCORD
local function enviarDiscord(texto)
    if not request then return end

    local linkDirecto = "https://www.roblox.com/games/start?placeId=109983668079237&gameInstanceId="..jobId

    local data = {
        ["embeds"] = {{
            ["title"] = "🔥 Brainrots Detectados",
            ["description"] = listaEnumerada,
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "🤖 Bot", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "🆔 JobId", ["value"] = jobId, ["inline"] = true},
                {["name"] = "🚀 Unirse", ["value"] = "[Click para entrar](https://www.roblox.com/games/start?placeId=109983668079237&gameInstanceId="..jobId..")", ["inline"] = false}
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
    end

    task.wait(3)
end

                for _, v in ipairs(lbuscar) do
                    if base:FindFirstChild(v, true) then
                        table.insert(encontrados, v)
                    end
                end

                if #encontrados > 0 then
                    table.sort(encontrados)
                    local key = base.Name .. "_" .. table.concat(encontrados, ",")

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
-- 🚀 LOOP
task.wait(3)

while true do
    print("🔍 Escaneando...")

    local actuales = detectar()

    -- ✅ NOTIFICAR SOLO NUEVOS
    for key, data in pairs(actuales) do
        if not yaNotificado[key] then
            local texto = "📍 Base: "..data.base.."\n\n"

            for _, v in ipairs(data.lista) do
                texto = texto .. "• "..v.."\n"
            end

            print("🔥 NUEVO:", data.base)
            enviarDiscord(texto)

            yaNotificado[key] = true
        end
    end

    -- 🧹 LIMPIAR LOS QUE YA NO EXISTEN
    for key, _ in pairs(yaNotificado) do
        if not actuales[key] then
            yaNotificado[key] = nil
        end
    end

    task.wait(3)
end
