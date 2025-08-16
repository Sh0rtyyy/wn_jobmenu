lib.locale()

lib.callback.register('wn_jobmenu:requestMultijobData', function(source)
    local playerIdentifier = GetIdentifier(source)
    local result = MySQL.query.await(
        'SELECT jobName, jobGrade FROM wn_multijob WHERE identifier = ?',
        { playerIdentifier }
    )

    for i, row in ipairs(result) do
        row.jobLabel = GetJobLabel(row.jobName)
        row.jobGradeLabel = GetJobGradeLabel(row.jobName, row.jobGrade)
        row.jobGradeSalary = GetJobGradeSalary(row.jobName, row.jobGrade)
    end

    return result
end)

RegisterNetEvent('wn_jobmenu:changeJob', function(job, grade)
    local src = source
    local jobChange = job
    local jobChangeGrade = grade
    local playerIdentifier = GetIdentifier(src)

    local hasJob = MySQL.scalar.await(
        'SELECT 1 FROM wn_multijob WHERE identifier = ? AND jobName = ? AND jobGrade = ? LIMIT 1',
        { playerIdentifier, jobChange, jobChangeGrade }
    )

    if not hasJob then
        print(("Player %s tried to change to a job they don’t have: %s"):format(playerIdentifier, jobChange))
        return
    end

    SetJob(src, jobChange, jobChangeGrade)
end)

RegisterNetEvent('wn_jobmenu:deleteJob', function(job, grade)
    local src = source
    local jobChange = job
    local jobChangeGrade = grade
    local playerIdentifier = GetIdentifier(src)

    MySQL.query.await(
        'DELETE FROM wn_multijob WHERE identifier = ? AND jobName = ? AND jobGrade = ?',
        { playerIdentifier, jobChange, jobChangeGrade }
    )

    SetJob(src, Config.UnemployedJob, 0)
end)

RegisterNetEvent('wn_jobmenu:addJob', function(source, job, grade)
    local src = source
    local playerIdentifier = GetIdentifier(src)

    local hasJob = MySQL.scalar.await(
        'SELECT 1 FROM wn_multijob WHERE identifier = ? AND jobName = ? LIMIT 1',
        { playerIdentifier, job }
    )

    if hasJob then
        MySQL.update.await(
            'UPDATE wn_multijob SET jobGrade = ? WHERE identifier = ? AND jobName = ?',
            { grade, playerIdentifier, job }
        )
    else
        MySQL.insert.await(
            'INSERT INTO wn_multijob (identifier, jobName, jobGrade) VALUES (?, ?, ?)',
            { playerIdentifier, job, grade }
        )
    end
end)