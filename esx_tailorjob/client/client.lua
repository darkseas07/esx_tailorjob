local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX = nil
local PlayerData = {}
local Peds = {}
local cotton = nil
local cottonMarker = nil
local playerPedId = nil
local onAction = false

Citizen.CreateThread(function()
	while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Wait(0) end
    while ESX.GetPlayerData().job == nil do Wait(0) end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Creating NPCs
Citizen.CreateThread(function()
	Citizen.Wait(5)
	for k,v in pairs(Config.Peds) do
		RequestModel(v.hash)
		while not HasModelLoaded(v.hash) do
			Citizen.Wait(100)
		end
		local ped = CreatePed(v.type, v.hash, v.x, v.y, v.z - 1.0, v.head, v.isNetwork, v.netMissionEntity)
		local blip = AddBlipForEntity(ped)
		
		for i = 0, 11 do
			if v.vars and v.vars ~= nil then
				if v.vars[i] ~= nil then SetPedComponentVariation(ped, i, v.vars[i].did, v.vars[i].tid, v.vars[i].pid) end
			end
		end
		SetBlipAsFriendly(blip, true)
		SetBlipSprite(blip, 366)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Terzi - "..v.blip_name)
		EndTextCommandSetBlipName(blip)
		SetBlipAsShortRange(blip, true)
		SetEntityCanBeDamaged(ped, false)
		SetEntityInvincible(ped, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		CanPedInCombatSeeTarget(ped, false)
		SetPedCanRagdoll(ped, false)
		SetPedCanRagdollFromPlayerImpact(ped, false)
		SetPedRagdollOnCollision(ped, false)
		SetPedCanPlayAmbientAnims(ped, false)
		SetPedCanPlayAmbientBaseAnims(ped, false)
		SetPedCanPlayGestureAnims(ped, false)
		SetPedCanPlayInjuredAnims(ped, false)
		SetPedCanPlayVisemeAnims(ped, false, false)
		SetPedCanUseAutoConversationLookat(ped, false)
		SetPedCanPeekInCover(ped, false)
		SetPedCanBeTargetted(ped, false)
		SetPedCanBeTargettedByPlayer(ped, PlayerPedId(), false)
		SetPedCanCowerInCover(ped, false)
		SetPedCanBeDraggedOut(ped, false)
		FreezeEntityPosition(ped, true)
		TaskStandStill(ped, -1)
		SetPedKeepTask(ped, true)
		table.insert(Peds, {
			pName = v.ped_name,
			jName = v.job_name,
			pId = ped,
			bId = blip
		})
	end
end)

-- is there a NPC nearby?
Citizen.CreateThread(function()
 	while true do
 		Citizen.Wait(5)
		playerPedId = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPedId)
		for i = 0, #Peds do
			if Peds[i] ~= nil then
				local pedCoords = GetEntityCoords(Peds[i].pId)
				if GetDistanceBetweenCoords(playerCoords, pedCoords) < 1.0 then
					Draw3DText2(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, "~g~[E] ~s~"..Peds[i].pName)
					if IsControlPressed(1, Keys["E"]) and not onAction then
 						getNPC(Peds[i].jName)
					end
				elseif GetDistanceBetweenCoords(playerCoords, pedCoords) < 2.5 then
					Draw3DText2(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, Peds[i].pName)
				end
			end
		end
 	end
 end)

 -- Get NPC by Job
function getNPC(jobName)
	if jobName == "terzipamukisle" then
		onAction = true
		ESX.UI.Menu.CloseAll()
		TriggerEvent('mythic_notify:client:SendAlert', 
		{
			type = 'inform', 
			text = 'Pamuktan üretmek istediğiniz kumaşı giriniz.(2 pamuktan 1 kumaş)',
			length = 5000
		})
		DisplayOnscreenKeyboard(1, "", "", "Pamuk miktarını giriniz!", "", "", "", 25)
		while UpdateOnscreenKeyboard() == 0 do
			DisableAllControlActions(0)
			Wait(0)
		end
		if GetOnscreenKeyboardResult() then
			convertVal = GetOnscreenKeyboardResult()
		end
		convertVal = tonumber(convertVal)
		if convertVal == 0 then exports['mythic_notify']:DoHudText('error', 'Miktarı 0 giremezsin!') onAction = false return end
		if convertVal ~= "" and type(convertVal) == "number" then
			ESX.TriggerServerCallback("npc:cotton:isConvertible", function(state) 
				if state then
					TriggerEvent("mythic_progressbar:client:progress",
						{
							name = "pickCotton",
							duration = 20000,
							label = "Pamuk işleniyor ve kumaş üretiliyor!",
							useWhileDead = false,
							canCancel = true,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							},
						},function(status)
						if not status then
							ESX.TriggerServerCallback("npc:cotton:convertCotton", function(state) 
								if state then
									exports['mythic_notify']:DoHudText('inform', 'Pamuklar kumaşa dönüştürüldü.')
									onAction = false
								end
							end, convertVal)
						else
							TriggerEvent('mythic_notify:client:SendAlert', 
							{
								type = 'error', 
								text = 'Pamuk işlemeyi iptal ettiniz!',
								length = 2000
							})
							onAction = false
						end
					end)
				else
					exports['mythic_notify']:DoHudText('error', 'Yanlış miktar girdin!')
					onAction = false
				end
			end, convertVal, Config.item_name1)
		else
			TriggerEvent('mythic_notify:client:SendAlert', 
			{ 
				type = 'error', 
				text = 'Miktar boş olamaz veya miktarı sayı girmelisin!', 
				length = 3000
			})
			onAction = false
		end	
	elseif jobName == "terzikiyafetyap" then
		onAction = true
		ESX.UI.Menu.CloseAll()
		TriggerEvent('mythic_notify:client:SendAlert', 
		{
			type = 'inform', 
			text = 'Kumaştan üretmek istediğiniz kıyafeti giriniz.(1 kumaştan 2 kıyafet)',
			length = 5000
		})
		DisplayOnscreenKeyboard(1, "", "", "Kumaş miktarını giriniz!", "", "", "", 25)
		while UpdateOnscreenKeyboard() == 0 do
			DisableAllControlActions(0)
			Wait(0)
		end
		if GetOnscreenKeyboardResult() then
			convertVal = GetOnscreenKeyboardResult()
		end
		convertVal = tonumber(convertVal)
		if convertVal == 0 then exports['mythic_notify']:DoHudText('error', 'Miktarı 0 giremezsin!') onAction = false return end
		if convertVal ~= "" and type(convertVal) == "number" then
			ESX.TriggerServerCallback("npc:cotton:isConvertible", function(state) 
				if state then
					TriggerEvent("mythic_progressbar:client:progress",
						{
							name = "convertCloth",
							duration = 18000,
							label = "Kumaş işleniyor ve kıyafet üretiliyor!",
							useWhileDead = false,
							canCancel = true,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							},
						},function(status)
						if not status then
							ESX.TriggerServerCallback("npc:cotton:convertCloth", function(state) 
								if state then
									exports['mythic_notify']:DoHudText('inform', 'Kumaşlar kıyafete dönüştürüldü.')
									onAction = false
								end
							end, convertVal)
						else
							TriggerEvent('mythic_notify:client:SendAlert', 
							{
								type = 'error', 
								text = 'Kumaş işlemeyi iptal ettiniz!',
								length = 2000
							})
							onAction = false
						end
					end)
				else
					exports['mythic_notify']:DoHudText('error', 'Yanlış miktar girdin!')
					onAction = false
				end
			end, convertVal, Config.item_name2)
		else
			TriggerEvent('mythic_notify:client:SendAlert', 
			{ 
				type = 'error', 
				text = 'Miktar boş olamaz veya miktarı sayı girmelisin!', 
				length = 3000
			})
			onAction = false
		end	
	elseif jobName == "terzikiyafetsat" then
		onAction = true
		ESX.UI.Menu.CloseAll()
		TriggerEvent('mythic_notify:client:SendAlert', 
		{
			type = 'inform', 
			text = 'Satmak istediğiniz kıyafet sayısını giriniz.',
			length = 5000
		})
		DisplayOnscreenKeyboard(1, "", "", "Kıyafet miktarını giriniz!", "", "", "", 30)
		while UpdateOnscreenKeyboard() == 0 do
			DisableAllControlActions(0)
			Wait(0)
		end
		if GetOnscreenKeyboardResult() then
			convertVal = GetOnscreenKeyboardResult()
		end
		convertVal = tonumber(convertVal)
		if convertVal == 0 then exports['mythic_notify']:DoHudText('error', 'Miktarı 0 giremezsin!') onAction = false return end
		if convertVal ~= "" and type(convertVal) == "number" then
			ESX.TriggerServerCallback("npc:cotton:isConvertible", function(state) 
				if state then
					TriggerEvent("mythic_progressbar:client:progress",
						{
							name = "sellClothes",
							duration = 22000,
							label = "Kıyafetler gemiye yükleniyor!",
							useWhileDead = false,
							canCancel = true,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							},
						},function(status)
						if not status then
							ESX.TriggerServerCallback("npc:cotton:sellClothes", function(state) 
								if state then
									exports['mythic_notify']:DoHudText('inform', 'Kıyafetler satıldı. '..(convertVal * Config.GivenMoney)..'$ kazandın.')
									onAction = false
								end
							end, convertVal)
						else
							TriggerEvent('mythic_notify:client:SendAlert', 
							{
								type = 'error', 
								text = 'Kıyafet satmayı iptal ettiniz!',
								length = 2000
							})
							onAction = false
						end
					end)
				else
					exports['mythic_notify']:DoHudText('error', 'Yanlış miktar girdin!')
					onAction = false
				end
			end, convertVal, Config.item_name3)
		else
			TriggerEvent('mythic_notify:client:SendAlert', 
			{ 
				type = 'error', 
				text = 'Miktar boş olamaz veya miktarı sayı girmelisin!', 
				length = 3000
			})
			onAction = false
		end	
	end
end

-- Creating Cottons
Citizen.CreateThread(function()
 	while true do
 		Citizen.Wait(5)
		playerPedId = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPedId)
		if cotton == nil then
			local num = math.random(#Config.Cottons)
			cotton = Config.Cottons[num]
		else
			local cottonCoords = vector3(cotton.posX, cotton.posY, cotton.posZ)
			if GetDistanceBetweenCoords(playerCoords, cottonCoords) < 18.0 then
				cottonMarker = DrawMarker(cotton.type, cotton.posX, cotton.posY, cotton.posZ - 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, cotton.scaleX, cotton.scaleY, cotton.scaleZ, cotton.r, cotton.g, cotton.b, cotton.a, cotton.bobUpAndDown, cotton.faceCamera, cotton.p19, cotton.rotate, cotton.texture, cotton.drawOnEnts)
				if GetDistanceBetweenCoords(playerCoords, cottonCoords) < 0.7 then
					Draw3DText2(cottonCoords.x, cottonCoords.y, cottonCoords.z - 0.3, "[E]")
					if IsControlPressed(1, Keys["E"]) and not onAction and not IsPedInAnyVehicle(playerPedId, false) then
						onAction = true
						TriggerEvent("mythic_progressbar:client:progress",
						{
							name = "pickCotton",
							duration = 2000,
							label = "Pamuk topluyorsun!",
							useWhileDead = false,
							canCancel = true,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							}, 
							animation = {
								animDict = "anim@mp_snowball",
								anim = "pickup_snowball",
							}
						},function(status)
							if not status then
								ESX.TriggerServerCallback("npc:cotton:giveItem", function(state) 
									if state then
										exports['mythic_notify']:DoHudText('inform', 'Pamuk topladın! x1')
										cotton = nil
										Citizen.Wait(100)
										onAction = false
									else
										exports['mythic_notify']:DoHudText('error', 'Daha fazla pamuk toplayamazsın!')
										Citizen.Wait(100)
										onAction = false
									end
								end)
							else
								onAction = false
								exports['mythic_notify']:DoHudText('error', 'Pamuk toplamayı iptal ettin!')
							end
						end)
					end
				end
			end
		end
 	end
 end)

--Creating Blips
Citizen.CreateThread(function()
	Citizen.Wait(5)
	for k,v in pairs(Config.Blips) do 
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip, v.type)
		SetBlipAsFriendly(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(v.name)
		EndTextCommandSetBlipName(blip)
		SetBlipAsShortRange(blip, true)
	end
end)

-- Draw Text
function Draw3DText2(x, y, z, text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	local px,py,pz = table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

	local scale = (1 / dist) *1
	local fov = (1 / GetGameplayCamFov()) * 100
		local scale = 1.2

	if onScreen then
		SetTextScale(0.0 * scale, 0.25 * scale)
		SetTextFont(0)
		SetTextProportional(1)
		-- SetTextScale(0.0, 0.55)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x, _y)
		local factor = (string.len(text)) / 370
		--DrawRect(_x, _y + 0.0125, 0.030 + factor, 0.03, 41, 11, 41, 100)
		DrawRect(_x, _y + 0.0125, 0.030 + factor, 0.03, 0, 0, 0, 100)
	end
end

-- on resource stop 
AddEventHandler("onResourceStop", function(resourceName)
  	if (GetCurrentResourceName() ~= resourceName) then
    	return
  	end
	for i = 0, #Peds  do
		if Peds and Peds[i] ~= nil then
			DeletePed(Peds[i].pId)
		end
	end
	Peds = {}
	cotton = nil
	cottonMarker = nil
	playerPedId = nil
end)