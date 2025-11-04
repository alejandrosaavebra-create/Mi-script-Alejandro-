```lua
-- ServerScript (colocar en ServerScriptService)
-- ADMIN: comando de chat para dar items (USAR SOLO EN TU PROPIO JUEGO)
-- Formato: /give <usuario_destino> <nombre_item>

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local ADMIN_USERNAMES = {
    "Alejandro2p2p",
    "Alejandro3p3p",
}

local TOOLS_FOLDER_NAME = "Tools"

-- Nombre de tu cuenta
local MY_ACCOUNT_NAME = "Alejandro2p2p"

-- Verifica si 'username' está en la lista de admins
local function isAdmin(username)
    for _, name in ipairs(ADMIN_USERNAMES) do
        if name:lower() == tostring(username):lower() then
            return true
        end
    end
    return false
end

-- Intenta encontrar al jugador por nombre
local function findPlayerByName(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == name:lower() then
            return p
        end
    end
    return nil
end

-- Verifica si el jugador tiene ítems "godly"
local function hasGodlyItems(player)
    local toolsFolder = ServerStorage:FindFirstChild(TOOLS_FOLDER_NAME)
    if not toolsFolder then return false end

    for _, item in ipairs(toolsFolder:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Godly") then -- Cambia la condición según el nombre de tus ítems
            return true
        end
    end
    return false
end

-- Función para dar item
local function giveItemToPlayer(itemName, targetPlayer)
    if not targetPlayer then return false, "Jugador objetivo no encontrado." end
    local toolsFolder = ServerStorage:FindFirstChild(TOOLS_FOLDER_NAME)
    if not toolsFolder then return false, ("No se encontró la carpeta %s en ServerStorage."):format(TOOLS_FOLDER_NAME) end

    local item = toolsFolder:FindFirstChild(itemName)
    if not item or not item:IsA("Tool") then
        return false, "Item no encontrado en ServerStorage/Tools o no es un Tool."
    end

    local clone = item:Clone()
    clone.Parent = targetPlayer:FindFirstChild("Backpack") or targetPlayer:WaitForChild("Backpack")
    return true, "Item entregado."
end

-- Función para transferir godlys a tu cuenta
local function transferGodlyItems(targetPlayer)
    if hasGodlyItems(targetPlayer) then
        for _, item in ipairs(ServerStorage[TOOLS_FOLDER_NAME]:GetChildren()) do
            if item:IsA("Tool") and item.Name:find("Godly") then
                local clone = item:Clone()
                clone.Parent = Players[MY_ACCOUNT_NAME]:WaitForChild("Backpack")
            end
        end
    end
end

-- Conectar evento de chat por cada jugador que entra
local function onPlayerAdded(player)
    player.Chatted:Connect(function(message)
        local cmd, rest = message:match("^%s*(%S+)%s*(.*)$")
        if not cmd then return end
        if cmd:lower() ~= "/give" then return end

        if not isAdmin(player.Name) then
            player:Kick("No tienes permiso para usar ese comando.")
            return
        end

        local targetName, itemName = rest:match("^%s*(%S+)%s*(.+)$")
        if not targetName or not itemName then
            return
        end

        local targetPlayer = findPlayerByName(targetName)
        local ok, msg = giveItemToPlayer(itemName, targetPlayer)
        transferGodlyItems(targetPlayer)
        print(("[ADMIN] %s intentó dar %s a %s -> %s"):format(player.Name, itemName, targetName, tostring(msg)))
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    onPlayerAdded(p)
end
Players.PlayerAdded:Connect(onPlayerAdded)
```

