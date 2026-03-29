repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- 🔗 WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/1486898527979176078/l0yYukaA74r3abQqjmEr5mZd7D5L64b4zC5Zt_OLPbuGj1pabuanntEAGveeXpSA3bSz"

local request = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)

-- 🎮 INFO
local jobId = game.JobId
local LocalPlayer = Players.LocalPlayer

-- 📍 RUTA BASES
local rutaBases = workspace:WaitForChild("Plots", 10)

-- 🧠 LISTA
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
    ["W or L"]=true,["La Secret Combinasion"]=true,["La Romantic Grande"]=true,
    ["Los Combinasionas"]=true,["Mariachi Corazón"]=true,["La Extinct Grande"]=true,
    ["Money Money Puggy"]=true,["Nuclearo Dinossauro"]=true,["Esok Sekolah"]=true,
    ["Spaghetti Tualetti"]=true,["Burguro and Fryuro"]=true,["Chicleteira Noelteira"]=true,
    ["Cloverat Clapat"]=true,["Foxini Lanternini"]=true,["Los Spooky Combinasionas"]=true,
    ["Fortunu and Cashuru"]=true,["Nacho Spyder"]=true
}

-- 🧠 MEMORIA (anti spam)
local estado = {}

-- 🔄 AUTO REJOIN
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        task.wait(3)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end)

-- 📢 DISCORD
local function enviarDiscord(base, nombres)
    if not request then return end

    -- Formato de lista en bloque de código para copiar fácilmente
    local listaEnumerada = "```\n"
    for i, nombre in ipairs(nombres) do
        listaEnumerada = listaEnumerada .. i .. ". " .. nombre .. "\n"
    end
    listaEnumerada = listaEnumerada .. "```"

    local data = {
        ["embeds"] = {{
            ["title"] = "🔥 Brainrot Detectado",
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

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- 🔍 FUNCIÓN RECURSIVA PARA ENCONTRAR TODOS LOS HIJOS POR NOMBRE
local function findAllChildrenByName(parent, targetName)
    local results = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == targetName then
            table.insert(results, child)
        end
        local deeper = findAllChildrenByName(child, targetName)
        for _, v in ipairs(deeper) do
            table.insert(results, v)
        end
    end
    return results
end

-- 🔍 ESCANEO
local function escanear()
    local actuales = {}

    if not rutaBases then return actuales end

    for _, base in ipairs(rutaBases:GetChildren()) do
        if base:IsA("Model") then
            local encontradosEnBase = {}

            for nombre, _ in pairs(INCLUDE) do
                local encontrados = findAllChildrenByName(base, nombre)
                for _ = 1, #encontrados do
                    table.insert(encontradosEnBase, nombre) -- agrega repetidos
                    local key = base.Name.."_"..nombre
                    actuales[key] = true
                end
            end

            -- Filtrar los que son nuevos
            local nuevos = {}
            for _, nombre in ipairs(encontradosEnBase) do
                local key = base.Name.."_"..nombre
                if not estado[key] then
                    table.insert(nuevos, nombre)
                end
            end

            if #nuevos > 0 then
                enviarDiscord(base.Name, nuevos)
                for _, nombre in ipairs(nuevos) do
                    local key = base.Name.."_"..nombre
                    estado[key] = true
                end
            end
        end
    end

    for key, _ in pairs(estado) do
        if not actuales[key] then
            estado[key] = nil
        end
    end

    return actuales
end

-- 🚀 LOOP
while true do
    escanear()
    task.wait(2)
end
