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
        local isCurrent = (currentJob and data.jobName == currentJob) and " (Current)" or ""
        local title = (data.jobLabel or data.jobName) .. isCurrent

        local description = ("Grade: %s \n Salary: $%s"):format(
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
        title = 'Multijob Menu',
        options = options
    })

    lib.showContext('multijob_menu')
end)

function SeeDetails(data)
    local displayChoices = {
        id = 'job_actions',
        title = 'Job Actions',
        menu = 'multijob_menu',
        options = {
            {
                title = 'Switch Job',
                description = ('Switch your job to: %s'):format(data.jobLabel),
                icon = 'fa-solid fa-circle-check',
                onSelect = function()
                    TriggerServerEvent('wn_jobmenu:changeJob', data.jobName, data.jobGrade)
                    ExecuteCommand('multijob')
                end,
            },
            {
                title = 'Delete Job',
                description = ('Delete the selected job: %s'):format(data.jobLabel),
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