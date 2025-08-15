for jobName, bossData in pairs(Config.BossMenu) do
    local grades = bossData.grades or {}
    local coords = bossData.coords

    exports.ox_target:addSphereZone({
        name = jobName .. "_bossmenu",
        coords = coords,
        radius = 1,
        debug = true,
        options = {
            {
                icon = 'fas fa-briefcase', 
                label = "Open Boss Menu", 
                targeticon = 'fas fa-sign-in-alt',
                onSelect = function()
                    local playerGrade = GetJobGradeLabel()
                    for _, grade in ipairs(grades) do
                        if grade ~= playerGrade then return end
                        OpenBossMenu(jobName)
                    end
                end,
            },
        },
    })
end

function OpenBossMenu(job)
    local options = {
        {
            title = "Manage Players",
            description = "View employees, their grades, salary, and fire them",
            onSelect = function()
                -- Open Manage Players submenu or trigger event
                TriggerEvent('bossmenu:managePlayers', job)
            end
        },
        {
            title = "Manage Job Finances",
            description = "Withdraw and deposit job money",
            onSelect = function()
                -- Open Job Finances submenu or trigger event
                TriggerEvent('bossmenu:manageFinances', job)
            end
        },
    }

    lib.registerContext({
        id = 'boss_menu',
        title = 'Boss Menu',
        options = options
    })

    lib.showContext('boss_menu')
end

function ManageGrade(jobData)
    local gradeOptions = {}
    local gradesList = {}

    -- Collect grade keys so we can sort them
    for grade in pairs(jobData.grades) do
        table.insert(gradesList, grade)
    end
    table.sort(gradesList)

    -- Build options from sorted grades
    for _, grade in ipairs(gradesList) do
        local gradeInfo = jobData.grades[grade]
        table.insert(gradeOptions, {
            value = tostring(gradeInfo.grade),
            label = gradeInfo.label
        })
    end

    local input = lib.inputDialog("Choose grade", {
        {
            type = 'select',
            label = "Choose grade",
            required = true,
            options = gradeOptions
        }
    })

    return input[1]
end

function FirePlayer()
    local input = lib.inputDialog('Fire this employee ?', {
        {type = 'checkbox', label = "Fire employee", required = true}
    })

    return input[1]
end

-- Manage Players Event
RegisterNetEvent('bossmenu:managePlayers', function(job)
    local jobName = job -- Replace with current boss's job
    local employees = lib.callback.await('wn_multijob:getEmployeesWithJob', false, jobName)
    local options = {}

    for _, emp in ipairs(employees) do
        local playerName = emp.playerName
        local gradeLabel = emp.jobGradeLabel
        local salaryAmount = emp.jobGradeSalary

        table.insert(options, {
            title = ("%s (%s)"):format(playerName, gradeLabel),
            description = ("Salary: $%d"):format(salaryAmount),
            onSelect = function()
                lib.registerContext({
                    id = 'boss_fire_player_' .. emp.identifier,
                    title = "Manage " .. playerName,
                    options = {
                        {
                            title = "Fire Player",
                            description = "Remove this player from the job",
                            onSelect = function()
                                local fire = FirePlayer()
                                if not fire then return end
                                TriggerServerEvent("wn_multijob:firePlayer", emp.identifier, jobName)
                                lib.showContext('boss_menu') -- Return to boss menu
                            end
                        },
                        {
                            title = "Manage Grade",
                            description = "Manage this player grade",
                            onSelect = function()
                                local newGrade = ManageGrade(emp.jobData)
                                TriggerServerEvent("wn_multijob:updateGrade", emp.identifier, jobName, newGrade)
                            end
                        },
                        {
                            title = "Back",
                            onSelect = function()
                                lib.showContext('bossmenu_managePlayers')
                            end
                        }
                    }
                })
                lib.showContext('boss_fire_player_' .. emp.identifier)
            end
        })
    end

    table.insert(options, {
        title = "Back",
        onSelect = function()
            lib.showContext('boss_menu')
        end
    })

    lib.registerContext({
        id = 'bossmenu_managePlayers',
        title = "Manage Players",
        options = options
    })

    lib.showContext('bossmenu_managePlayers')
end)

-- Manage Finances Event
RegisterNetEvent('bossmenu:manageFinances', function(job)
    local money = lib.callback.await('wn_multijob:getJobMoney', false, job)
    print(money)

    local options = {
        {
            title = "You have " .. money .. "$ in your company",
        },
        {
            title = "Withdraw Money",
            description = "Withdraw money from the job account",
            onSelect = function()
                -- Open UI or prompt for withdraw amount
                local amount = WithdrawMoney()
                print(amount)
                lib.callback.await('wn_multijob:manageMoney', false, "remove", job, amount)
            end
        },
        {
            title = "Deposit Money",
            description = "Deposit money to the job account",
            onSelect = function()
                -- Open UI or prompt for deposit amount
                local amount = WithdrawMoney()
                print(amount)
                lib.callback.await('wn_multijob:manageMoney', false, "add", job, amount)
            end
        },
        {
            title = "Back",
            onSelect = function()
                lib.showContext('boss_menu')
            end
        }
    }

    lib.registerContext({
        id = 'bossmenu_manageFinances',
        title = "Manage Job Finances",
        options = options
    })

    lib.showContext('bossmenu_manageFinances')
end)

-- Placeholder withdraw money event
function WithdrawMoney()
    -- Show input dialog for amount (replace with your UI method)
    local input = lib.inputDialog('Withdraw Money', {
        { type = 'number', label = 'Amount', min = 1 }
    }, function(values, canceled)
        if canceled then return end
    end)

    return input[1]
end