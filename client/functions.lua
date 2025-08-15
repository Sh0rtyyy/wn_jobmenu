local PlayerData = {}
local PlayerJob = nil
local CurrentShopBlips = {}
lib.locale()

if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()

    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        PlayerJob = PlayerData.job
        Wait(2000)
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
        PlayerJob = job
        Wait(500)
    end)

elseif Config.Framework == "qbcore" then
    QBCore = exports['qb-core']:GetCoreObject()

    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        PlayerData = {}
    end)

elseif Config.Framework == "qbox" then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
    end)

end

RegisterNetEvent('wn_billing:sendNotify')
AddEventHandler('wn_billing:sendNotify', function(type, title, text, icon, time)
    Notify(type, title, text, icon, time)
end)

function Notify(type, title, text, icon, time)
    if Config.Notify == "ESX" then
        ESX.ShowNotification(text)
    elseif Config.Notify == "ox_lib" then
        if type == "success" then
            lib.notify({
                title = title,
                duration = time,
                description = text,
                icon = "fas fa-receipt",
                type = "success"
            })
        elseif type == "inform" then
            lib.notify({
                title = title,
                duration = time,
                description = text,
                icon = "fas fa-receipt",
                type = "inform"
            })
        elseif type == "error" then
            lib.notify({
                title = title,
                duration = time,
                description = text,
                icon = "fas fa-receipt",
                type = "error"
            })
        end
    elseif Config.Notify == "qbcore" then
        if type == "success" then
            QBCore.Functions.Notify(text, "success")
        elseif type == "info" then
            QBCore.Functions.Notify(text, "primary")
        elseif type == "error" then
            QBCore.Functions.Notify(text, "error")
        end
    end
end

function GetJob()
    if Config.Framework == "ESX" then
        if ESX.GetPlayerData().job then
            return ESX.GetPlayerData().job.name
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Functions.GetPlayerData().job then
            return QBCore.Functions.GetPlayerData().job.name
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        if QBX.PlayerData.job then
            return QBX.PlayerData.job.name
        else
            return false
        end
    end
end

function GetJobLabel()
    if Config.Framework == "ESX" then
        if ESX.GetPlayerData().job then
            return ESX.GetPlayerData().job.label
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Functions.GetPlayerData().job then
            return QBCore.Functions.GetPlayerData().job.label
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        if QBX.PlayerData.job then
            return QBX.PlayerData.job.label
        else
            return false
        end
    end
end

function GetJobGrade()
    if Config.Framework == "ESX" then
        if ESX.GetPlayerData().job then
            return ESX.GetPlayerData().job.grade
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Functions.GetPlayerData().job then
            return QBCore.Functions.GetPlayerData().job.grade
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        if QBX.PlayerData.job then
            return QBX.PlayerData.job.grade
        else
            return false
        end
    end
end

function GetJobGradeLabel()
    if Config.Framework == "ESX" then
        if ESX.GetPlayerData().job then
            return ESX.GetPlayerData().job.grade_name
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Functions.GetPlayerData().job then
            return QBCore.Functions.GetPlayerData().job.grade.label
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        if QBX.PlayerData.job then
            return QBX.PlayerData.job.grade.label
        else
            return false
        end
    end
end

function SelectPlayer(returnmenu)
    local choosenPlayer = nil
    local players = GetActivePlayers()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closePlayers = {}
    local title = "Select player"
    if newTitle then
        title = newTitle
    end
    for k, v in pairs(players) do
        if v ~= PlayerId() then -- Check if v is not the same as the local player's ID
            local dist = #(GetEntityCoords(GetPlayerPed(v)) - pedCoords)
            if dist < 4 and dist > -1 then
                table.insert(closePlayers, {label = 'Player '..k, args = {id = v}})
            end
        end
    end
	if not closePlayers[1] then
        Notify("error", "Billing", "Nobody is near")
    return nil end

    local currentlyHoveredPlayer = closePlayers[1].args.id

    local id = math.random(1, 99999)
    lib.registerMenu({
        id = 'chose_player'..id,
        title = title,
        position = 'top-right',
        onSideScroll = function(selected, scrollIndex, args)
            --print("onSideScroll", closePlayers[1].args.id)
            currentlyHoveredPlayer = args.id
        end,
        onSelected = function(selected, scrollIndex, args)
            --print("onSelected", closePlayers[1].args.id)
            currentlyHoveredPlayer = args.id
        end,
        onClose = function()
            choosenPlayer = false
        end,
        options = closePlayers
    }, function(selected, scrollIndex, args)
        choosenPlayer = args.id
    end)

    lib.showMenu('chose_player'..id)
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            DrawMarker(21, GetEntityCoords(GetPlayerPed(currentlyHoveredPlayer)) + vector3(0.0, 0.0, 1.0), 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255,255,255, 100, false, false, 2, true, false, false, false)
            if choosenPlayer ~= nil then return end
        end
    end)
    while choosenPlayer == nil do
        Wait(500)
    end
    if returnmenu ~= nil then
        lib.showContext(returnmenu)
    end
    local returnId = GetPlayerServerId(choosenPlayer)
    return returnId
end

function giveInput(dialog_name, title, rownames, default, type, returnmenu)
    local input = lib.inputDialog(dialog_name, {
        {type = type, label = title, description = rownames, default = default, format = "DD/MM/YYYY", returnString = true},
    })
 
    if not input then return end
    --print(json.encode(input[1]))
    if returnmenu ~= nil then
        lib.showContext(returnmenu)
    end
    return input[1]
end

function table.contains(table, value)
    for _, v in ipairs(table) do
        --print("v", v)
        --print("value", value)
        if v == value then
            return true
        end
    end
    return false
end