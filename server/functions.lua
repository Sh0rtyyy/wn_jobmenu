local webhook = "https://discord.com/api/webhooks/"

if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
    RegisterUsable = ESX.RegisterUsableItem
    Wait(5000)
    AllJobs = ESX.GetJobs()
elseif Config.Framework == "qbcore" then
    QBCore = nil
    QBCore = exports['qb-core']:GetCoreObject()
    RegisterUsable = QBCore.Functions.CreateUseableItem
elseif Config.Framework == "qbox" then
    AllJobs = exports.qbx_core:GetJobs()
end

function RequestJobData(job)
    return AllJobs[job]
end

function CheckJob(source, job)
    local src = source
    local jobToCheck = job

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.job.name == jobToCheck then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayerData()
        if xPlayer.job.name == jobToCheck then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if xPlayer.PlayerData.job.name == jobToCheck then
            return true
        else
            return false
        end
    end
end

function GetJob(source)
    local src = source

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getJob().name
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayerData()
        return xPlayer.job.name
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayer(src)
        return xPlayer.PlayerData.job.name
    end
end

function GetJobGrade(source)
    local src = source

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getJob().grade_name
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayerData()
        return xPlayer.job.grade_name
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayer(src)
        return xPlayer.PlayerData.job.grade_name
    end
end

function GetJobLabel(job)
    if Config.Framework == "ESX" then
        if AllJobs[job] ~= nil then
            return AllJobs[job].label
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Shared.Jobs[job] then
            return QBCore.Shared.Jobs[job].label
        end
    elseif Config.Framework == "qbox" then
        if AllJobs[job] ~= nil then
            return AllJobs[job].label
        end
    end
end

function GetJobGradeLabel(job, grade)
    if Config.Framework == "ESX" then
        if AllJobs[job] ~= nil and AllJobs[job].grades[tostring(grade)] then
            return AllJobs[job].grades[tostring(grade)].label
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Shared.Jobs[job] then
            local rank = tostring(grade)
            if Config.UseQBox then
                rank = tonumber(grade)
            end

            if QBCore.Shared.Jobs[job].grades[rank] then
                return QBCore.Shared.Jobs[job].grades[rank].name
            end
        end
    elseif Config.Framework == "qbox" then
        if AllJobs[job] ~= nil and AllJobs[job].grades[tonumber(grade)] then
            return AllJobs[job].grades[tonumber(grade)].label
        end
    end
end

function GetJobGradeSalary(job, grade)
    if Config.Framework == "ESX" then
        if AllJobs[job] ~= nil and AllJobs[job].grades[tostring(grade)] then
            return AllJobs[job].grades[tostring(grade)].salary
        end
    elseif Config.Framework == "qbcore" then
        if QBCore.Shared.Jobs[job] then
            local rank = tostring(grade)
            if Config.UseQBox then
                rank = tonumber(grade)
            end

            if QBCore.Shared.Jobs[job].grades[rank] then
                return QBCore.Shared.Jobs[job].grades[rank].salary
            end
        end
    elseif Config.Framework == "qbox" then
        if AllJobs[job] ~= nil and AllJobs[job].grades[tonumber(grade)] then
            return AllJobs[job].grades[tonumber(grade)].salary
        end
    end
end

function GetPlayerNameFromIdentifier(identifier)
    if Config.Framework == "ESX" then
        local result = MySQL.query.await('SELECT firstname, lastname FROM users WHERE identifier = ? LIMIT 1', { identifier })
        if result and #result > 0 then
            return result[1].firstname .. " " .. result[1].lastname
        end
    elseif Config.Framework == "qbcore" then
        local charinfoJson = MySQL.scalar.await('SELECT charinfo FROM players WHERE citizenid = ? LIMIT 1', { identifier })
        if charinfoJson then
            local charinfo = json.decode(charinfoJson)
            if charinfo then
                return charinfo.firstname .. " " .. charinfo.lastname
            end
        end
    end
end

function SetJob(source, job, grade, player)
    local src = source

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.setJob(job, grade or 0)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        xPlayer.Functions.SetJob(job, grade or 0)
    elseif Config.Framework == "qbox" then
        exports.qbx_core:SetJob(src, job, grade)
    end
end

function GetIdentifier(source)
    local src = source
    
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getIdentifier(src)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetIdentifier(src)
        return xPlayer.PlayerData.citizenid
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayer(src)
        return xPlayer.PlayerData.citizenid
    end
end

function GetPlayerFromIdentifier(identifier)
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
        print("xPlayer", json.encode(xPlayer))
        print("identifier", identifier)
        return xPlayer
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
        return xPlayer
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayerByCitizenId(identifier)
        return xPlayer
    end
end

function GetName(source)
    local src = source
    
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getName()
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetIdentifier(src)
        return xPlayer.PlayerData.firstname .. " " .. xPlayer.PlayerData.lastname
    elseif Config.Framework == "qbox" then
        local xPlayer = exports.qbx_core:GetPlayer(src)
        return xPlayer.PlayerData.firstname .. " " .. xPlayer.PlayerData.lastname
    end
end

function AddSocietyMoney(job, amount)
    local societyJob = job
    local giveAmount = amount

    if Config.Framework == "ESX" then
        TriggerEvent('esx_society:getSociety', societyJob, function(society)
            TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
                if account then
                    account.addMoney(giveAmount)
                end
            end)
        end)
    elseif Config.Framework == "qbcore" then
        exports['qb-management']:AddMoney(societyJob, giveAmount)
    elseif Config.Framework == "qbox" then
        exports['Renewed-Banking']:addAccountMoney(societyJob, giveAmount)
    end
end

function RemoveSocietyMoney(job, amount)
    local societyJob = job
    local removeAmount = amount

    if Config.Framework == "ESX" then
        TriggerEvent("esx_society:getSociety", societyJob, function(society)
            if society ~= nil then
                TriggerEvent("esx_addonaccount:getSharedAccount", society.account, function(account)
                    if account then
                        account.removeMoney(removeAmount)
                    end
                end)
            end
        end)
    elseif Config.Framework == "qbcore" then
        exports['qb-management']:RemoveMoney(societyJob, removeAmount)
    elseif Config.Framework == "qbox" then
        exports['Renewed-Banking']:RemoveMoney(societyJob, removeAmount)
    end
end

function GetCops()
    local cops = 0

    if Config.Framework == "ESX" then
        for _, src in pairs(ESX.GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(src)
            for _, job in pairs(Config.PoliceJobs) do
                if xPlayer and xPlayer.getJob() and xPlayer.getJob().name == job then
                    cops = cops + 1
                end
            end
        end
        return cops
    elseif Config.Framework == "qbcore" then
        local Player = QBCore.Functions.GetPlayers()
        for i = 1, #Player do
            local Player = QBCore.Functions.GetPlayer(Player[i])
            for _, job in pairs(Config.PoliceJobs) do
                if Player.PlayerData.job.name == job then
                    cops = cops + 1
                end
            end
        end
        return cops
    end
end

function GetPlayerGroup(source)
    local src = source
    local player_group = "user"

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        player_group = xPlayer.getGroup()
    elseif Config.Framwork == "qbcore" then
        player_group = QBCore.Functions.GetPermission(src)
    elseif Config.Framework == "qbox" then
        local player_group = exports.qbx_core:GetPermission(src)
    end

    return player_group
end

function CheckDistance(source, TargetCoords)
    local src = source

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
	    local coords = xPlayer.getCoords(true)
        local distance = #(coords - TargetCoords)
        if distance < 10 then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local coords = GetEntityCoords(GetPlayerPed(src))
        local distance = #(coords - TargetCoords)
        if distance < 10 then
            return true
        else
            return false
        end
    end
end

function CheckDistancePlayers(source, TargetSource)
    local src = source
    local tSrc = TargetSource

    local coords = GetEntityCoords(GetPlayerPed(src))
    local tCoords = GetEntityCoords(GetPlayerPed(TargetSource))
    local distance = #(coords - tCoords)
    if distance < 10 then
        return true
    else
        return false
    end
end

function GetItem(name, count, source)
    local src = source
    local itemName = name
    local itemCount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.getInventoryItem(itemName).count >= itemCount then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if xPlayer.Functions.GetItemByName(itemName) ~= nil then
            if xPlayer.Functions.GetItemByName(itemName).amount >= itemCount then
                return true
            else
                return false
            end
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        local amount = exports.ox_inventory:Search(source, 'count', itemName)
        if amount >= itemCount then
            return true
        else
            return false
        end
    end
end

function AddItem(name, count, source)
    local src = source
    local itemName = name
    local itemCount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addInventoryItem(itemName, itemCount)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        xPlayer.Functions.AddItem(itemName, itemCount, nil, nil)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[itemName], "add", itemCount)
    elseif Config.Framework == "qbox" then
        exports.ox_inventory:AddItem(src, itemName, itemCount)
    end
end

function RemoveItem(name, count, source)
    local src = source

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.removeInventoryItem(name, count)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        xPlayer.Functions.RemoveItem(name, count, nil, nil)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[name], "remove", count)
    elseif Config.Framework == "qbox" then
        exports.ox_inventory:RemoveItem(src, itemName, itemCount)
    end
end

function AddMoney(type, count, source)
    local src = source
    local moneyType = type
    local moneyAmount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addAccountMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if moneyType == "money" then
            moneyType = "cash"
        end
        xPlayer.Functions.AddMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbox" then
        if moneyType == "money" then
            moneyType = "cash"
        end
        exports.qbx_core:AddMoney(src, moneyType, moneyAmount)
    end
end

function AddMoneyIdentifier(type, count, identifier)
    local ident = identifier
    local moneyType = type
    local moneyAmount = count

    if Config.Framework == "ESX" then
        ident.addAccountMoney(moneyType, tonumber(moneyAmount))
    elseif Config.Framework == "qbcore" then
        if moneyType == "money" then
            moneyType = "cash"
        end
        ident.Functions.AddMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbox" then
        if moneyType == "money" then
            moneyType = "cash"
        end
        exports.qbx_core:AddMoney(ident, moneyType, moneyAmount)
    end
end

function RemoveMoney(type, count, source)
    local src = source
    local moneyType = type
    local moneyAmount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.removeAccountMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if moneyType == "money" then
            moneyType = "cash"
        end
        xPlayer.Functions.RemoveMoney(moneyType, moneyAmount)
    elseif Config.Framework == "qbox" then
        if moneyType == "money" then
            moneyType = "cash"
        end
        exports.qbx_core:RemoveMoney(src, moneyType, moneyAmount)
    end
end

function GetMoney(type, count, source)
    local src = source
    local moneyType = type
    local moneyAmount = count

    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if moneyType == "money" then
            if xPlayer.getMoney() >= moneyAmount then
                return true
            else
                return false
            end
        elseif moneyType == "bank" then
            if xPlayer.getAccount('bank').money >= moneyAmount then
                return true
            else
                return false
            end
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if moneyType == "money" then
            moneyType = "cash"
        end
        local playerMoney = xPlayer.Functions.GetMoney(moneyType)
        if playerMoney >= moneyAmount then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbox" then
        local playerMoney = exports.qbx_core:GetMoney(src, moneyType)
        if playermoney >= moneyAmount then
            return true
        else
            return false
        end
    end
end

function KickCheater(src, message)
	print("Cheater ".. src .. " " .. message)
    DropPlayer(src, message)
end

function DiscordLog(title, message)
    local embeds = {
        {
            ["title"] = title,
            ["description"] = message,
            ["type"] = "rich",
            ["color"] = 56108,
            ["footer"] = {
                ["text"] = "wn_billing • " .. os.date('%H:%M - %d.%m.%Y'),
            },
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers)
        if err ~= 204 then
            print("Discord webhook error: " .. tostring(err))
        end
    end, 'POST', json.encode({ username = title, embeds = embeds }), { ['Content-Type'] = 'application/json' })
end