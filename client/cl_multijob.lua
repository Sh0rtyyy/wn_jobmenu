lib.locale()

-- DB STRUCTURA
-- ID   INDEX DAT
-- identifier - indentifier hráča
-- jobName = job name
-- jobGrade = job grade

RegisterCommand("multijob", function()
    local multijobData = lib.callback.await('wn_jobmenu:requestMultijobData')
    local options = {}
    local currentJob = GetJob()

    print("multijobData", json.encode(multijobData))

    for index, data in ipairs(multijobData) do
        local isCurrent = (currentJob and data.jobName == currentJob) and locale('current_job') or ""
        local title = (data.jobLabel or data.jobName) .. isCurrent

        local description = (locale('job_desc')):format(
            data.jobGradeLabel .. " [" .. data.jobGrade .. "]" or ("Grade " .. data.jobGrade .. " [" .. data.grade .. "]"),
            data.jobGradeSalary or 0
        )

        table.insert(options, {
            title = title,
            description = description,
            onSelect = function()
                SeeDetails(data)
            end
        })
    end

    lib.registerContext({
        id = 'multijob_menu',
        title = locale('multijob_menu_title'),
        options = options
    })

    lib.showContext('multijob_menu')
end)

function SeeDetails(data)
    local displayChoices = {
        id = 'job_actions',
        title = locale('job_actions_title'),
        menu = 'multijob_menu',
        options = {
            {
                title = locale('switch_job_title'),
                description = (locale('switch_job_desc')):format(data.jobLabel),
                icon = 'fa-solid fa-circle-check',
                onSelect = function()
                    TriggerServerEvent('wn_jobmenu:changeJob', data.jobName, data.jobGrade)
                    ExecuteCommand('multijob')
                end,
            },
            {
                title = locale('delete_job_title'),
                description = (locale('delete_job_desc')):format(data.jobLabel),
                icon = 'fa-solid fa-trash-can',
                onSelect = function()
                    TriggerServerEvent('wn_jobmenu:deleteJob', data.jobName, data.jobGrade)
                    ExecuteCommand('multijob')
                end,
            },
        }
    }
    lib.registerContext(displayChoices)
    lib.showContext('job_actions')
end