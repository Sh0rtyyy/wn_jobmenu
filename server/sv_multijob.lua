lib.callback.register('wn_jobmenu:requestMultijobData', function(source)
    local playerIdentifier = GetIdentifier(source)
    local result = MySQL.query.await(
        'SELECT jobName, jobGrade FROM wn_multijob WHERE identifier = ?',
        { playerIdentifier }
    )

    print("result1", json.encode(result))

    for i, row in ipairs(result) do
        row.jobLabel = GetJobLabel(row.jobName)
        row.jobGradeLabel = GetJobGradeLabel(row.jobName, row.jobGrade)
        row.jobGradeSalary = GetJobGradeSalary(row.jobName, row.jobGrade)
    end

    print("result2", json.encode(result))
    return result
end)

RegisterNetEvent('wn_jobmenu:changeJob', function(job, grade)
    local src = source
    local jobChange = job
    local jobChangeGrade = grade
    local playerIdentifier = GetIdentifier(src)

    -- Check if player has the given job
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

RegisterNetEvent('wn_jobmenu:addJob', function(source, job, grade)
    local src = source
    local playerIdentifier = GetIdentifier(src)

    MySQL.insert.await(
        'INSERT INTO wn_multijob (identifier, jobName, jobGrade) VALUES (?, ?, ?)',
        { playerIdentifier, job, grade }
    )
    print(("Added new job %s (grade %s) for %s"):format(job, grade, playerIdentifier))
    
end)