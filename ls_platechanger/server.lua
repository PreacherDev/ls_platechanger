RegisterNetEvent('ls_platechanger:server:checkPlate', function(newPlate, oldPlate)
    print(newPlate)
    local source = source; local xPlayer = ESX.GetPlayerFromId(source)
    local count = MySQL.prepare.await('SELECT COUNT(*) FROM owned_vehicles WHERE plate = ?', {newPlate})
    if count == 0 then 
        xPlayer.triggerEvent('ls_platechanger:client:changePlate', true, newPlate)
        local query = MySQL.query.await('SELECT vehicle FROM owned_vehicles WHERE plate = ? AND owner = ?', {oldPlate, xPlayer.identifier})
        if query[1].vehicle then 
            local vehicleProps = json.decode(query[1].vehicle)
            vehicleProps.plate = newPlate
            vehicleProps = json.encode(vehicleProps)
            MySQL.update('UPDATE owned_vehicles SET plate = ?, vehicle = ?', {newPlate, vehicleProps})
            xPlayer.removeInventoryItem(Config.Itemname, 1)
        end
    else 
        xPlayer.triggerEvent('ls_platechanger:client:changePlate', false)
    end
end)

ESX.RegisterServerCallback('ls_platechanger:server:getIsOwned', function(source, cb, oldPlate)
    local source = source; local xPlayer = ESX.GetPlayerFromId(source)
    local count = MySQL.prepare.await('SELECT COUNT(*) FROM owned_vehicles WHERE plate = ? AND owner = ?', {oldPlate, xPlayer.identifier})
    if count ~= 0 then 
        cb(true) 
    else 
        cb(false)
    end
end)

ESX.RegisterUsableItem(Config.Itemname, function(source)
   local xPlayer = ESX.GetPlayerFromId(source)
   xPlayer.triggerEvent('ls_platechanger:client:beginChanging')
end)