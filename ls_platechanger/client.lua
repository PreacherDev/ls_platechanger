local cam
local changing = false
local noneAffectedPlate = ''
local letters = {' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}

RegisterNetEvent('ls_platechanger:client:beginChanging', function()
-- RegisterCommand('plate', function()
    changing = true
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    noneAffectedPlate = tostring(GetVehicleNumberPlateText(vehicle))
    local platetext = tostring(GetVehicleNumberPlateText(vehicle))
    ESX.TriggerServerCallback('ls_platechanger:server:getIsOwned', function(isOwned)
        if isOwned then 
            createCam(vehicle)
            FreezeEntityPosition(vehicle, true)
            local letterindecies = {}
            for i = 1, #platetext do 
                local ind = string.sub(platetext, i, i)
                for res = 1, #letters do 
                    if letters[res] == ind then 
                        letterindecies[i] = res
                    end
                end
            end
            local index = 1
            CreateThread(function()
                while changing do
                    Wait(1)
                    if IsControlJustPressed(0, 174) then 
                        index = index > 1 and index-1 or 8
                        CreateThread(function()
                            Wait(25)
                            platetext = replaceAt(platetext, index, ' ')
                            SetVehicleNumberPlateText(vehicle, platetext) 
                            Wait(25)
                            platetext = replaceAt(platetext, index, letters[letterindecies[index]])
                            SetVehicleNumberPlateText(vehicle, platetext) 
                        end)
                    end 
                    if IsControlJustPressed(0, 175) then
                        index = index < 8 and index+1 or 1
                        CreateThread(function()
                            Wait(25)
                            platetext = replaceAt(platetext, index, ' ')
                            SetVehicleNumberPlateText(vehicle, platetext) 
                            Wait(25)
                            platetext = replaceAt(platetext, index, letters[letterindecies[index]])
                            SetVehicleNumberPlateText(vehicle, platetext) 
                        end)
                    end
                    if IsControlJustPressed(0, 172) then
                        if letterindecies[index] < #letters then
                            letterindecies[index] += 1
                        else 
                            letterindecies[index] = 1
                        end
        
                        platetext = replaceAt(platetext, index, letters[letterindecies[index]]) 
                        SetVehicleNumberPlateText(vehicle, platetext)
                    end 
                    
                    if IsControlJustPressed(0, 173) then -- arrow down
                        if letterindecies[index] > 1 then
                            letterindecies[index] -= 1
                        else 
                            letterindecies[index] = #letters
                        end
                        platetext = replaceAt(platetext, index, letters[letterindecies[index]]) 
                        SetVehicleNumberPlateText(vehicle, platetext)
                    end
                    if IsControlJustPressed(0, 177) then
                        SetVehicleNumberPlateText(vehicle, noneAffectedPlate)
                        deleteCam()
                        changing = false
                        FreezeEntityPosition(vehicle, false)
                    end
                    if IsControlJustPressed(0, 191) then
                        TriggerServerEvent('ls_platechanger:server:checkPlate', platetext, noneAffectedPlate)
                    end
                    if not IsPedSittingInAnyVehicle(playerPed) then
                        SetVehicleNumberPlateText(vehicle, noneAffectedPlate)
                        deleteCam()
                        changing = false
                        FreezeEntityPosition(vehicle, false)
                    end
                end
            end)
        else 
            ESX.ShowNotification('You are not allowed to change this plate!')
        end
    end, platetext)    
end)

RegisterNetEvent('ls_platechanger:client:changePlate', function(allowed, platetext)
    if allowed then 
        changing = false
        deleteCam()
        FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), false)
        ESX.ShowNotification('Successfully changed plate to '.. platetext)
    else 
        ESX.ShowNotification('Tried to attach a plate that is already taken!')
    end
end)

function replaceAt(str, at, with) 
    return string.sub(str, 1, at-1 )..with..(string.sub(str, at+1, string.len(str))) 
end

function createCam(vehicle)
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', false) 
    SetCamFov(cam, GetCamFov(cam)-35.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, true)
    AttachCamToVehicleBone(cam, vehicle, GetEntityBoneIndexByName(vehicle, 'chassis_dummy'), true, 0.0, 0.0, 0.0, 0.0, -5.0, -0.1, true)
end

function deleteCam()
    if cam then 
        SetCamActive(cam, false)
        RenderScriptCams(false, true, 1000, true, false) 
        DestroyCam(cam)
    end
end
