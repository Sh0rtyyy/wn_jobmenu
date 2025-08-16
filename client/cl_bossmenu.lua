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
                label = locale('open_boss_menu_label'),
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
            title = locale('manage_players_title'),
            description = locale('manage_players_desc'),
            onSelect = function()
                TriggerEvent('bossmenu:managePlayers', job)
            end
        },
        {
            title = locale('manage_finances_title'),
            description = locale('manage_finances_desc'),
            onSelect = function()
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

    for grade in pairs(jobData.grades) do
        table.insert(gradesList, grade)
    end
    table.sort(gradesList)

    for _, grade in ipairs(gradesList) do
        local gradeInfo = jobData.grades[grade]
        table.insert(gradeOptions, {
            value = tostring(gradeInfo.grade),
            label = gradeInfo.label
        })
    end

    local input = lib.inputDialog(locale('choose_grade_title'), {
        {
            type = 'select',
            label = locale('choose_grade_label'),
            required = true,
            options = gradeOptions
        }
    })

    return input[1]
end

function FirePlayer()
    local input = lib.inputDialog(locale('fire_employee_confirm'), {
        {type = 'checkbox', label = locale('fire_employee_label')}
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
            description = (locale('salary_desc')):format(salaryAmount),
            onSelect = function()
                lib.registerContext({
                    id = 'boss_fire_player_' .. emp.identifier,
                    title = (locale('manage_player_title')):format(playerName),
                    options = {
                        {
                            title = locale('fire_player_title'),
                            description = locale('fire_player_desc'),
                            onSelect = function()
                                local fire = FirePlayer()
                                if not fire then return end
                                TriggerServerEvent("wn_multijob:firePlayer", emp.identifier, jobName)
                                lib.showContext('boss_menu') -- Return to boss menu
                            end
                        },
                        {
                            title = locale('manage_grade_title'),
                            description = locale('manage_grade_desc'),
                            onSelect = function()
                                local newGrade = ManageGrade(emp.jobData)
                                TriggerServerEvent("wn_multijob:updateGrade", emp.identifier, jobName, newGrade)
                            end
                        },
                        {
                            title = locale('back_title'),
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
        title = locale('back_title'),
        onSelect = function()
            lib.showContext('boss_menu')
        end
    })

    lib.registerContext({
        id = 'bossmenu_managePlayers',
        title = locale('manage_players_title'),
        options = options
    })

    lib.showContext('bossmenu_managePlayers')
end)

-- Manage Finances Event
RegisterNetEvent('bossmenu:manageFinances', function(job)
    local money = lib.callback.await('wn_multijob:getJobMoney', false, job)

    local options = {
        {
            title = (locale('company_money_title')):format(money),
        },
        {
            title = locale('withdraw_money_title'),
            description = locale('withdraw_money_desc'),
            onSelect = function()
                local amount = WithdrawMoney()
                lib.callback.await('wn_multijob:manageMoney', false, "remove", job, amount)
            end
        },
        {
            title = locale('deposit_money_title'),
            description = locale('deposit_money_desc'),
            onSelect = function()
                local amount = WithdrawMoney()
                lib.callback.await('wn_multijob:manageMoney', false, "add", job, amount)
            end
        },
        {
            title = locale('back_title'),
            onSelect = function()
                lib.showContext('boss_menu')
            end
        }
    }

    lib.registerContext({
        id = 'bossmenu_manageFinances',
         title = locale('manage_finances_title'),
        options = options
    })

    lib.showContext('bossmenu_manageFinances')
end)

function WithdrawMoney()
    local input = lib.inputDialog(locale('withdraw_money_title'), {
        { type = 'number', label = locale('amount_label'), min = 1 }
    }, function(values, canceled)
        if canceled then return end
    end)

    return input[1]
end