ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('staff:menu:get:group')
AddEventHandler('staff:menu:get:group', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local spelerGroup = xPlayer.getGroup()
    if spelerGroup ~= 'user' then
        TriggerClientEvent('staff:menu:open:menu', source, spelerGroup)
    end
end)

RegisterCommand("spelerinfo", function(source, args)
    if args[1] then 
        local target = tonumber(args[1])
        if args[1]:lower() == "me" then 
            target = tonumber(source)
        end
        if target ~= nil and GetPlayerName(target) ~= nil then
            local xTarget = ESX.GetPlayerFromId(target)

            local accounts = xTarget.getAccounts()
            local accountsText = ""
            for i = 1, #accounts do
                accountsText = accountsText .. accounts[i].label .. ": " .. accounts[i].money .. "<br>"
            end

            local job = xTarget.getJob()
            local job_label = job.label or "unemployed"
            local job_grade_label = job.grade_label or "unemployed"
            local job_salary = ESX.Math.GroupDigits(job.grade_salary) or 0.0

            local msg = "<b>Name:</b> " .. GetPlayerName(target) .. " ( " .. target .. " )<br><b>Job:</b> " .. job_label .. " ( " .. job_grade_label .. " )<br><b>Salary:</b> " .. job_salary .. "<br><b>Accounts:</b><br>" .. accountsText

            TriggerClientEvent('chat:addMessage', source, {
                template = '<div class="bubble-message"<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0,0,0, 0.4); border-radius: 8px;"><i class="fas fa-user"></i> {0}:<br> ' .. msg .. '</div>',
                args = { "Info " .. target }
            })

        else
            TriggerClientEvent("esx:showNotification", source, "Speler niet gevonden")
        end
    else
        TriggerClientEvent("esx:showNotification", source, "Geen speler ID opgegeven")
    end
end, true)

RegisterCommand("inventory", function(source, args)
    if args[1] then 
        local target = tonumber(args[1])
        if args[1]:lower() == "me" then 
            target = tonumber(source)
        end
        if target ~= nil and GetPlayerName(target) ~= nil then
            local xTarget = ESX.GetPlayerFromId(target)

            local inventory = xTarget.getInventory(false)
            local inventoryText = ""
            for i = 1, #inventory do
                if inventory[i].count > 0 then
                    inventoryText = inventoryText .. inventory[i].label .. ": " .. inventory[i].count .. "<br>"
                end
            end

            local msg = "<b>Name:</b> " .. GetPlayerName(target) .. " ( " .. target .. " )<br><b>Inventory:</b><br>" .. inventoryText

            TriggerClientEvent('chat:addMessage', source, {
                template = '<div class="bubble-message"<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0,0,0, 0.4); border-radius: 8px;"><i class="fas fa-user"></i> {0}:<br> ' .. msg .. '</div>',
                args = { "Info " .. target }
            })
        else
            TriggerClientEvent("esx:showNotification", source, "Speler niet gevonden")
        end
    else
        TriggerClientEvent("esx:showNotification", source, "Geen speler ID opgegeven")
    end
end, true)

RegisterCommand("loadout", function(source, args)
    if args[1] then 
        local target = tonumber(args[1])
        if args[1]:lower() == "me" then 
            target = tonumber(source)
        end
        if target ~= nil and GetPlayerName(target) ~= nil then
            local xTarget = ESX.GetPlayerFromId(target)

            local loadout = xTarget.getLoadout()
            local loadoutText = ""
            for i = 1, #loadout do
                loadoutText = loadoutText .. loadout[i].label .. ": " .. loadout[i].ammo .. "<br>"
            end

            local msg = "<b>Name:</b> " .. GetPlayerName(target) .. " ( " .. target .. " )<br><b>Loadout:</b><br>" .. loadoutText

            TriggerClientEvent('chat:addMessage', source, {
                template = '<div class="bubble-message"<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0,0,0, 0.4); border-radius: 8px;"><i class="fas fa-user"></i> {0}:<br> ' .. msg .. '</div>',
                args = { "Loadout " .. target }
            })
        else
            TriggerClientEvent("esx:showNotification", source, "Speler niet gevonden")
        end
    else
        TriggerClientEvent("esx:showNotification", source, "Geen speler ID opgegeven")
    end
end, true)
