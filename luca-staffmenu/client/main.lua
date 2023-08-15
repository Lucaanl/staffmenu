ESX = exports["es_extended"]:getSharedObject()

--[Variables]
local isMenuOpen = false
local isInDienst = false
local spelerGroup = nil
local inDienstCoords = nil
local inDienstHeading = nil



RegisterNetEvent('staff:menu:open:menu')
AddEventHandler('staff:menu:open:menu', function(spelerGroup)

    local options = {}

    if not isInDienst then
        table.insert(options, {label = 'In Dienst', value = 'in_dienst'})
    else
        table.insert(options, {label = 'Uit Dienst', value = 'uit_dienst'})
    end

    if isInDienst then
        if Config.perms[spelerGroup].noclip then
            table.insert(options, {label = 'Noclip', value = 'noclip'})
        end
        if Config.perms[spelerGroup].voertuigOpties.enabled then
            table.insert(options, {label = 'Voertuig opties', value = 'voertuig_options'})
        end
        if Config.perms[spelerGroup].spelerOpties.enabled then
            table.insert(options, {label = 'Speler opties', value = 'player_options'})
        end
    end

    isMenuOpen = true

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'general_menu', {
        title = Config.serverNaam .. " Staff Menu",
        align = Config.align,
        elements = options
    }, function(data, menu)

        if data.current.value == 'in_dienst' then
            inDienst()
        end

        if data.current.value == 'uit_dienst' then
            if not isInNoclip then
                uitDienst()
            end
        end

        if data.current.value == 'noclip' then
            noclipMenu()
        end        
        
        if data.current.value == 'voertuig_options' then
            voertuigMenu(spelerGroup)
        end

        if data.current.value == 'player_options' then
            spelerOpties(spelerGroup)
        end
        
        if data.current.value == 'all_players' then
            TriggerServerEvent('staff:menu:get:all:players')
        end

    end,
    function(data, menu)
        menu.close()
        isMenuOpen = false
    end)
end)

function noclipMenu()

    isMenuOpen = true

    local noclipOptions = {}

    table.insert(noclipOptions, {label = 'Noclip', value = 'enable_noclip'})
    table.insert(noclipOptions, {label = 'Noclip speed', value = 'noclip_speed'})

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'noclip_menu', {
        title = Config.serverNaam .. " Staff Menu | Noclip",
        align = Config.align,
        elements = noclipOptions
    }, function(data, menu)

        if data.current.value == 'enable_noclip' then
            if not isInNoclip then
                isInNoclip = true
                noclip()
            else
                isInNoclip = false
                noclip()
            end
        end

        if data.current.value == 'noclip_speed' then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'noclip_speed', {
                title = "Noclip speed"
            }, function(data, menu)
                ExecuteCommand('noclipspeed ' .. data.value)
                exports['okokNotify']:Alert("SUCCESS", "Je hebt je noclip speed ingesteld op " .. data.value, 3000, 'success')
                menu.close()
            end, function(data, menu)
                menu.close()
                TriggerServerEvent('staff:menu:get:group')
            end)
        end

    end,
    function(data, menu)
        menu.close()
        isMenuOpen = false
    end)
end

function noclip()
    local dict = "des_shipwreck"
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(10)
    end
    UseParticleFxAssetNextCall(dict) -- Prepare the Particle FX for the next upcomming Particle FX call
    SetParticleFxNonLoopedColour(1.0, 0.0, 0.0) -- Setting the color to Red (R, G, B)
    StartNetworkedParticleFxNonLoopedAtCoord("ent_ray_shipwreck_exp", GetEntityCoords(GetPlayerPed(-1)), 0.0, 0.0, 0.0, 0.05, false, false, false, false) -- Start the animation itself
    RemoveNamedPtfxAsset(dict)
    TriggerEvent('gitta:noclip')
end

function spawnVehicle()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'spawn_vehicle', {
        title = "Spawn voertuig"
    }, function(data, menu)
        local ped = PlayerPedId()
        ESX.Game.SpawnVehicle(data.value, GetEntityCoords(ped), GetEntityHeading(ped), function(vehicle)
            TaskWarpPedIntoVehicle(ped, vehicle, -1)
            exports['okokNotify']:Alert("VOERTUIG", "Je hebt een " .. data.value .. " ingespawned", 3000, 'success') -- exports['okokNotify']:Alert("Title", "Message", Time, 'type')
        end)
        menu.close()
    end, function(data, menu)
        menu.close()
        TriggerServerEvent('staff:menu:get:group')
    end)
end

function voertuigMenu(spelerGroup)
    
    local voertuigOpties = {}

    if isInDienst then
        if Config.perms[spelerGroup].voertuigOpties.spawn then
            table.insert(voertuigOpties, {label = 'Spawn voertuig', value = 'spawn_voertuig'})
        end
        if Config.perms[spelerGroup].voertuigOpties.repareer then
            table.insert(voertuigOpties, {label = 'Repareer voertuig', value = 'repareer_voertuig'})
        end
        if Config.perms[spelerGroup].voertuigOpties.verwijder then
            table.insert(voertuigOpties, {label = 'Verwijder voertuig', value = 'verwijder_voertuig'})
        end

        if Config.perms[spelerGroup].voertuigOpties.carwipe then
            table.insert(voertuigOpties, {label = 'Verwijder alle voertuigen', value = 'car_wipe'})
        end
    end

    isMenuOpen = true

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'voertuig_options', {
        title = Config.serverNaam .. " Staff Menu | Voertuig opties",
        align = Config.align,
        elements = voertuigOpties
    }, function(data, menu)

        if data.current.value == 'spawn_voertuig' then
            spawnVehicle()
        end

        if data.current.value == 'repareer_voertuig' then
            repareerVoertuig()
        end
        
        if data.current.value == 'verwijder_voertuig' then
            verwijderVoertuig()
        end
        
        if data.current.value == 'car_wipe' then
            carWipe()
        end

    end,
    function(data, menu)
        menu.close()
        isMenuOpen = false
    end)
end

function spelerOpties(spelerGroup)
    
    local spelerOptions = {}

    if isInDienst then
        if Config.perms[spelerGroup].spelerOpties.bring then
            table.insert(spelerOptions, {label = 'Breng speler', value = 'bring_player'})
        end
        if Config.perms[spelerGroup].spelerOpties.ganaar then
            table.insert(spelerOptions, {label = 'Ga naar speler', value = 'goto_player'})
        end
        if Config.perms[spelerGroup].spelerOpties.freeze then
            table.insert(spelerOptions, {label = 'Freeze speler', value = 'freeze_player'})
        end
        if Config.perms[spelerGroup].spelerOpties.unfreeze then
            table.insert(spelerOptions, {label = 'Unfreeze speler', value = 'unfreeze_player'})
        end
        if Config.perms[spelerGroup].spelerOpties.revive then
            table.insert(spelerOptions, {label = 'Revive speler', value = 'revive_player'})
        end

        if Config.perms[spelerGroup].spelerOpties.policeMenu then
            table.insert(spelerOptions, {label = 'Extra Opties', value = 'police_menu'})
        end
    end

    isMenuOpen = true

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'speler_options', {
        title = Config.serverNaam .. " Staff Menu | Speler opties",
        align = Config.align,
        elements = spelerOptions
    }, function(data, menu)

        if data.current.value == 'bring_player' then
            bringPlayer()
        end

        if data.current.value == 'goto_player' then
            gotoPlayer()
        end

        if data.current.value == 'freeze_player' then
            freezePlayer()
        end

        if data.current.value == 'unfreeze_player' then
            unFreezePlayer()
        end

        if data.current.value == 'revive_player' then
            reviveSpeler()
        end

        if data.current.value == 'police_menu' then
            TriggerEvent('staff:menu:open:police:menu')
        end

    end,
    function(data, menu)
        menu.close()
        isMenuOpen = false
    end)
end

function bringPlayer()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'bring_player', {
        title = "Breng speler (id)"
    }, function(data, menu)
        ExecuteCommand('bring ' .. data.value)
        exports['okokNotify']:Alert("SUCCESS", "ID" .. data.value .. " is gebracht", 3000, 'success')
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function gotoPlayer()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'goto_player', {
        title = "Ga naar speler (id)"
    }, function(data, menu)
        ExecuteCommand('goto ' .. data.value)
        exports['notify']:Alert("SUCCESS", "Je bent nu bij ID " .. data.value, 3000, 'success')
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function reviveSpeler()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'revive_player', {
        title = "Revive speler (id)"
    }, function(data, menu)
        ExecuteCommand('revive ' .. data.value)
        exports['notify']:Alert("SUCCESS", "ID " .. data.value .. " is gerevived", 3000, 'success')
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function freezePlayer()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_player', {
        title = "Freeze speler (id)"
    }, function(data, menu)
        ExecuteCommand('freeze ' .. data.value)
        exports['notify']:Alert("SUCCESS", "ID " .. data.value .. " is gefreezed", 3000, 'success')
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function unFreezePlayer()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'unfreeze_player', {
        title = "Unfreeze speler (id)"
    }, function(data, menu)
        ExecuteCommand('unfreeze ' .. data.value)
        exports['notify']:Alert("SUCCESS", "ID" .. data.value .. " is geunfreezed", 3000, 'success')
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function repareerVoertuig()
    local vehicle
    if IsPedInAnyVehicle(PlayerPedId()) then
        vehicle = GetVehiclePedIsIn(PlayerPedId())
    else
        vehicle = ESX.Game.GetClosestVehicle()
    end
    if DoesEntityExist(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local timeout = 0
        while not NetworkHasControlOfEntity(vehicle) and timeout < 20 do
            Citizen.Wait(100)
            NetworkRequestControlOfEntity(vehicle)
            timeout = timeout + 1
        end
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleFixed(vehicle)
    
        SetEntityRotation(vehicle, 0.0, 0.0, GetEntityHeading(vehicle))
        SetVehicleOnGroundProperly(vehicle)
        exports['notify']:Alert("SUCCESS", "Voertuig is gemaakt", 3000, 'success')
    else
        exports['notify']:Alert("ERROR", "Er is geen voertuig in de buurt", 3000, 'error')
    end
end

function verwijderVoertuig()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        DeleteVehicle(vehicle)
        exports['notify']:Alert("SUCCESS", "Voertuig is verwijdert", 3000, 'success')
    else
        local vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped))
        DeleteVehicle(vehicle)
        exports['notify']:Alert("SUCCESS", "Voertuig is verwijdert", 3000, 'success')
    end
end

function carWipe()
    local allVehicles = GetGamePool('CVehicle')
    for k, v in pairs(allVehicles) do
        local vehicleCoords = GetEntityCoords(v)
        if not IsAnyPedNearPoint(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 10.0) then
            DeleteVehicle(v)
        end
    end
    exports['notify']:Alert("SUCCESS", "Carwipe voltooid!", 3000, 'success')
end
































































































local noclip = false
local noclip_speed = 1.0
local allowed = true
local noclipRunning = false

function startnoclip()
    noclipRunning = true
    Citizen.CreateThread(function()
		while noclipRunning do
			Citizen.Wait(1)
			if(noclip)then
			local ped = GetPlayerPed(-1)
			local x,y,z = getPosition()
			local dx,dy,dz = getCamDirection()
			local speed = noclip_speed
			SetEntityVisible(GetPlayerPed(-1), false, false)
			SetEntityInvincible(GetPlayerPed(-1), true)
			Citizen.CreateThread(function()
				while noclip do
					Wait(500)
					DisableActions()
				end
			end)
	
		  -- reset velocity
		  SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)
		  if IsControlPressed(0, 21) then
			  speed = speed + 3
			  end
		  if IsControlPressed(0, 19) then
			  speed = speed - 0.5
		  end
		  -- forward
				 if IsControlPressed(0,32) then -- MOVE UP
				  x = x+speed*dx
				  y = y+speed*dy
				  z = z+speed*dz
				   end
	
		  -- backward
				   if IsControlPressed(0,269) then -- MOVE DOWN
				  x = x-speed*dx
				  y = y-speed*dy
				  z = z-speed*dz
				   end
			SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
				else
				SetEntityVisible(GetPlayerPed(-1), true, false)
				SetEntityInvincible(GetPlayerPed(-1), false)
				noclipRunning = false
			end
		end
	end)
end

--RegisterNetEvent("es_admin:noclip")
--AddEventHandler("es_admin:noclip", function(t)
local msg = "disabled"
local cannoclip = true

function startdelay()
	cannoclip = false
	Wait(3000)
	cannoclip = true
end

RegisterNetEvent('gitta:noclip')
AddEventHandler('gitta:noclip', function(source)
	if(noclip == false)then
	end

	noclip = not noclip

	if(noclip)then
		msg = "enabled"
		startnoclip()
	end
end)

RegisterCommand("noclipspeed", function(source, args, raw)
	noclip_speed = args[1]
end)

function getPosition()
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
  return x,y,z
end

function getCamDirection()
  local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading*math.pi/180.0)
  local y = math.cos(heading*math.pi/180.0)
  local z = math.sin(pitch*math.pi/180.0)

  -- normalize
  local len = math.sqrt(x*x+y*y+z*z)
  if len ~= 0 then
    x = x/len
    y = y/len
    z = z/len
  end

  return x,y,z
end

function DisableActions()

	local playerPed = PlayerPedId()

	DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
	DisablePlayerFiring(playerPed,true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
    DisableControlAction(0, 106, true) -- Disable in-game mouse controls
    DisableControlAction(0, 140, true)
	DisableControlAction(0, 141, true)
	DisableControlAction(0, 142, true)

	if IsDisabledControlJustPressed(2, 37) then --if Tab is pressed, send error message
		SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true) -- if tab is pressed it will set them to unarmed (this is to cover the vehicle glitch until I sort that all out)
	end

	if IsDisabledControlJustPressed(0, 106) then --if LeftClick is pressed, send error message
		SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true) -- If they click it will set them to unarmed
	end
end

































function inDienst()
    local ped = PlayerPedId()
    isInDienst = true
    ESX.UI.Menu.CloseAll()
    TriggerServerEvent('staff:menu:get:group')
    if Config.antiAbuse then
        inDienstCoords = GetEntityCoords(ped)
        inDienstHeading = GetEntityHeading(ped)
    end
    TriggerEvent('skinchanger:loadSkin', {sex = 0, bproof_1 = 10, bproof_2 = 0})
    exports['notify']:Alert("SUCCESS", "Je bent in dienst", 3000, 'success')
end

function uitDienst()
    local ped = PlayerPedId()
    isInDienst = false
    ESX.UI.Menu.CloseAll()
    if Config.antiAbuse then
        DoScreenFadeOut(500)
        Wait(510)
        SetEntityCoords(ped, inDienstCoords.x, inDienstCoords.y, inDienstCoords.z)
        SetEntityHeading(ped, inDienstHeading)
        FreezeEntityPosition(ped, true)
        Wait(2000)
        FreezeEntityPosition(ped, false)
        Wait(1000)
        DoScreenFadeIn(500)
        inDienstCoords = vector3(0.0, 0.0, 0.0)
        inDienstHeading = 0
    end
    TriggerEvent('skinchanger:loadSkin', {sex = 0, bproof_1 = 0, bproof_2 = 0})
    exports['okokNotify']:Alert("SUCCESS", "Je bent uit dienst", 3000, 'success')
end

Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 166) then
            TriggerServerEvent('staff:menu:get:group')
        end
        Citizen.Wait(0)
    end
end)

RegisterCommand('staffmenu', function()
    TriggerServerEvent('staff:menu:get:group')
end)
