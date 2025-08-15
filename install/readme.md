Set Job Interfration 

ESX: 
Go to es_extended/server/classes/player.lua and find setJob function
Put this trigger at the bottom of the function
TriggerEvent("wn_jobmenu:addJob", self.source, self.job.name, self.job.grade)

QBCore:
Go to qb-core/server/player.lua and find setJob function
Put this trigger at the bottom of the function, but above return true
TriggerEvent("wn_jobmenu:addJob", self.source, self.job.name, self.job.grade)

QBX:
Go to qb-core/server/player.lua and find SetPlayerPrimaryJob function
Put this trigger at the bottom of the function, but above return true
TriggerEvent("wn_jobmenu:addJob", self.source, self.job.name, self.job.grade)
