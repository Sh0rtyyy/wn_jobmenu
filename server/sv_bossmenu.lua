lib.locale()

lib.callback.register('wn_multijob:getEmployeesWithJob', function(source, jobName)
    local allPlayers = MySQL.query.await('SELECT identifier, job, job_grade FROM users WHERE job = ?', { jobName })

    for i, row in ipairs(allPlayers) do
        row.jobData = RequestJobData(jobName)
        row.playerName = GetPlayerNameFromIdentifier(row.identifier)
        row.jobGradeLabel = GetJobGradeLabel(row.job, row.job_grade)
        row.jobGradeSalary = GetJobGradeSalary(row.job, row.job_grade)
    end

    return allPlayers
end)

lib.callback.register('wn_multijob:getJobData', function(source, jobName)
    local jobData = RequestJobData(jobName)
    return jobData
end)

lib.callback.register('wn_multijob:getJobMoney', function(source, jobName)
    local money = 0

    if Config.Framework == "ESX" then
        TriggerEvent("esx_society:getSociety", jobName, function(society)
        if society ~= nil then
            TriggerEvent("esx_addonaccount:getSharedAccount", society.account, function(account)
                if account then
                money = account.money
                end
            end)
            end
        end)
    elseif Config.Framework == "qbcore" then
        money = exports["qb-management"]:GetAccount(jobName)
    elseif Config.Framework == "qbox" then
        money = exports["Renewed-Banking"]:getAccountMoney(jobName)
    end

    return money
end)

lib.callback.register('wn_multijob:manageMoney', function(source, type, jobName, amount)
    if type == "remove" then
        RemoveSocietyMoney(jobName, amount)
        AddMoney("money", amount, source)
    elseif type == "add" then
        local playerMoney = GetMoney("bank", amount, source)
        if playerMoney ~= true then return end
        RemoveMoney("bank", amount, source)
        AddSocietyMoney(jobName, amount)
    end
end)

RegisterNetEvent('wn_multijob:updateGrade', function(identifier, job, grade)
    local hasJob = MySQL.scalar.await(
        'SELECT 1 FROM wn_multijob WHERE identifier = ? AND jobName = ? LIMIT 1',
        { identifier, job }
    )

    if not hasJob then
        print(("Player %s tried to change to a job they don’t have: %s"):format(identifier, job))
        return
    end

    MySQL.update.await(
        'UPDATE wn_multijob SET jobGrade = ? WHERE identifier = ? AND jobName = ?',
        { grade, identifier, job }
    )

end)

RegisterNetEvent('wn_multijob:firePlayer', function(identifier, job)
    local hasJob = MySQL.scalar.await(
        'SELECT 1 FROM wn_multijob WHERE identifier = ? AND jobName = ? LIMIT 1',
        { identifier, job }
    )

    if not hasJob then
        print(("Player %s tried to change to a job they don’t have: %s"):format(identifier, job))
        return
    end

    MySQL.update.await(
        'DELETE FROM wn_multijob WHERE identifier = ? AND jobName = ?',
        { identifier, job }
    )


    local player = GetPlayerFromIdentifier(identifier)
    if player ~= nil then
        if Config.Framework == "ESX" then
            player.setJob("unemployed", 0)
        elseif Config.Framework == "qbcore" then
            player.Functions.SetJob("unemployed", 0)
        elseif Config.Framework == "qbox" then
            exports.qbx_core:SetJob(player, "unemployed", 0)
        end
    end
end)