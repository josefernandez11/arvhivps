repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- 🔗 WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/1486898527979176078/l0yYukaA74r3abQqjmEr5mZd7D5L64b4zC5Zt_OLPbuGj1pabuanntEAGveeXpSA3bSz"

-- 🔗 GITHUB CONFIG
local GITHUB_TOKEN = "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"
local GITHUB_USER = "josefernandez11"
local REPO = "NOTIFICADOR"
local FILE = "brainrot.json"

local request = request or http_request or syn and syn.request or fluxus and fluxus.request

-- 🎮 INFO
local jobId = game.JobId
local LocalPlayer = Players.LocalPlayer

-- 📍 RUTA BASES
local rutaBases = workspace:WaitForChild("Plots", 10)

--------------------------------------------------
-- 🔐 BASE64
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function base64Encode(data)
    return ((data:gsub('.', function(x) 
        local r,binary='',x:byte()
        for i=8,1,-1 do r=r..(binary%2^i-binary%2^(i-1)>0 and '1' or '0') end
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

--------------------------------------------------
-- 🔎 SHA
local function getSHA()
    local url = "https://api.github.com/repos/"..GITHUB_USER.."/"..REPO.."/contents/"..FILE
    local response = game:HttpGet(url)
    local data = HttpService:JSONDecode(response)
    return data.sha
end

--------------------------------------------------
-- 📤 GITHUB
local function updateGitHub(base, nombre)
    if not request then return end

    local sha = getSHA()
    local url = "https://api.github.com/repos/"..GITHUB_USER.."/"..REPO.."/contents/"..FILE

    local jsonData = HttpService:JSONEncode({
        base = base,
        name = nombre,
        value = 0, -- (puedes mejorar esto luego)
        jobId = jobId
    })

    local data = {
        message = "brainrot detectado",
        content = base64Encode(jsonData),
        sha = sha
    }

    pcall(function()
        request({
            Url = url,
            Method = "PUT",
            Headers = {
                ["Authorization"] = "token "..GITHUB_TOKEN,
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

--------------------------------------------------
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
["Cloverat Clapat"]=true,["Foxini Lanternini"]=true,
["Los Spooky Combinasionas"]=true,["Fortunu and Cashuru"]=true
}

--------------------------------------------------
-- 🧠 MEMORIA
local estado = {}

--------------------------------------------------
-- 🔄 AUTO REJOIN
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        task.wait(3)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
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
        "🧠 Brainrot: "..nombre.."\n"..
        "🆔 JobId: "..jobId.."\n"..
        "🤖 Bot: "..LocalPlayer.Name.."\n\n"..
        "👉 [🚀 JOIN](<"..link..">)"
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
                        updateGitHub(base.Name, nombre) -- 🔥 AQUÍ SE AGREGA

                        estado[key] = true
                    end
                end
            end

        end
    end

    return actual
end

--------------------------------------------------
-- 🚀 LOOP
while true do
    local actuales = escanear()

    for key, _ in pairs(estado) do
        if not actuales[key] then
            estado[key] = nil
        end
    end

    task.wait(4 + math.random())
end
