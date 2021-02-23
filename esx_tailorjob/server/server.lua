ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("npc:cotton:giveItem", function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local inventory = xPlayer.inventory
	local count = 0
	for i = 1, #inventory do
		if inventory[i].name == Config.item_name1 and inventory[i].count > 0 then
			count = inventory[i].count
		end
	end
	
	if count < Config.CottonMaxCount then
		xPlayer.addInventoryItem(Config.item_name1, 1)
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback("npc:cotton:isConvertible", function(source, cb, convertVal, itemType)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local inventory = xPlayer.inventory
	local count = 0
	if itemType == Config.item_name1 then
		for i = 1, #inventory do
			if inventory[i].name == itemType and inventory[i].count > 0 then
				count = inventory[i].count
			end
		end

		local max = convertVal * 2
		if max > count then
			cb(false)
		else
			cb(true)
		end
	elseif itemType == Config.item_name2 then
		for i = 1, #inventory do
			if inventory[i].name == itemType and inventory[i].count > 0 then
				count = inventory[i].count
			end
		end
		if count > 0 and convertVal <= count then
			cb(true)
		else
			cb(false)
		end
	elseif itemType == Config.item_name3 then
		for i = 1, #inventory do
			if inventory[i].name == itemType and inventory[i].count > 0 then
				count = inventory[i].count
			end
		end
		if count > 0 and convertVal <= count then
			cb(true)
		else
			cb(false)
		end
	end
	
end)

ESX.RegisterServerCallback("npc:cotton:convertCotton", function(source, cb, convertVal)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local inventory = xPlayer.inventory
	local max = convertVal * 2
	xPlayer.removeInventoryItem(Config.item_name1, max)
	xPlayer.addInventoryItem(Config.item_name2, convertVal)
	cb(true)
end)

ESX.RegisterServerCallback("npc:cotton:convertCloth", function(source, cb, convertVal)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local inventory = xPlayer.inventory
	local max = convertVal * 2
	xPlayer.removeInventoryItem(Config.item_name2, convertVal)
	xPlayer.addInventoryItem(Config.item_name3, max)
	cb(true)
end)

ESX.RegisterServerCallback("npc:cotton:sellClothes", function(source, cb, convertVal)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local inventory = xPlayer.inventory
	local max = convertVal * Config.GivenMoney
	xPlayer.removeInventoryItem(Config.item_name3, convertVal)
	xPlayer.addMoney(max)
	cb(true)
end)