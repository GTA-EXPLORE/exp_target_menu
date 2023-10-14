player = {}
local rc_hit, rc_entity, rc_coords
local show_cursor, paused, interacting, cursor_active = false, false, false, false
local reg_entities, reg_models, reg_names, reg_model_names, reg_model_offsets = {}, {}, {}, {}, {}
local TYPE_TO_OPTION = {all = 0, ped = 1, vehicle = 2, object = 3, player = "player", in_vehicle = "in_vehicle"}

local options = {
    [0] = { -- all
    },
    [1] = { -- peds
    },
    [2] = { -- vehicle
    },
    [3] = { -- object
    },
    ["player"] = {
    },
    ["in_vehicle"] = {
    }
}

local entity_options = options[0]

Citizen.CreateThread(function()
    RequestStreamedTextureDict("mpfclone_common")
end)

RegisterCommand("+track", function()
    if show_cursor or interacting or paused then return end
    show_cursor = true
    
    player.Ped = PlayerPedId()

    SendNUIMessage({
        action = "SHOW_CURSOR",
        toggle = true
    })
    StartTracker()

    Citizen.CreateThread(function()
        while show_cursor do Wait(0)
            DisableControlAction(0, 24, true) -- INPUT_ATTACK (LEFT CLICK)
            -- DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT (R)
            -- DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY (Q)
            DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE LEFT MOUSE BUTTON)
            DisablePlayerFiring(PlayerId(), true)
            if IsDisabledControlJustReleased(0, 24) then
                OnClick()
            end
        end
    end)
    
    while (show_cursor or interacting) and not IsPlayerFreeAiming(PlayerId()) do
        ShowEntities()
        Wait(5)
    end
    show_cursor, interacting = false, false
    SendNUIMessage({
        action = "SHOW_CURSOR",
        toggle = false
    })
    SetNuiFocus(false, false)
end)
RegisterCommand("-track", function()
    show_cursor = false
end)
RegisterKeyMapping('+track', _("main_menu"), "keyboard", DEFAULTKEY_CURSOR)


function OnClick()
    local target = rc_entity
    local ent_options = {}
    local name = reg_names[target] or reg_model_names[GetEntityModel(target)] or _("entity_type_name_"..GetEntityType(target))

    if not cursor_active then
        if not DoesEntityExist(target) then
            if IsPedInAnyVehicle(player.Ped) then
                ent_options = options["in_vehicle"]
                name = _("entity_type_name_in_vehicle")
            else
                ent_options = options[0]
            end
        else
            return
        end
    else
        if IsPedAPlayer(target) then
            ent_options = options["player"]
        else
            if options[GetEntityType(target)] then ent_options = MergeDict(ent_options, options[GetEntityType(target)]) end
            -- if GetEntityType(target) == 1 and not IsEntityPositionFrozen(target) then ent_options["turfwars:SellDrug"] = {desc = "Sell Drugs"} end
            if reg_models[GetEntityModel(target)] then ent_options = MergeDict(ent_options, reg_models[GetEntityModel(target)]) end
            if reg_entities[target] then ent_options = MergeDict(ent_options, reg_entities[target]) end
        end
    end

    SendNUIMessage({
        action = "OPEN_MENU",
        title = name,
        options = ent_options
    })
    interacting = true
    SetNuiFocus(true, true)
    
    Citizen.CreateThread(function()
        if IsEntityAPed(target) and not IsPedAPlayer(target) then
            PlayPedAmbientSpeechNative(target, "GENERIC_HI", "SPEECH_PARAMS_STANDARD")
            if not reg_entities[target] then
                TaskTurnPedToFaceEntity(target, player.Ped, 1000)
                while interacting do Wait(1000)
                    TaskStandStill(target, 1000)
                end
            end
        end
    end)
end

function ShowEntities()
    player.Coords = GetEntityCoords(player.Ped)
    local entities = {}
    cursor_active = false

    for _, ent in ipairs(GetObjects()) do
        local ent_model = GetEntityModel(ent)
        if (reg_entities[ent] or reg_models[ent_model]) and #(player.Coords - GetEntityCoords(ent)) < 10 then
            local ent_coords = GetOffsetFromEntityInWorldCoords(ent, reg_model_offsets[ent_model] or vector3(0,0,0))
            if ent == rc_entity then
                
                DrawSpriteAtCoords(ENTITY_SPRITE_HOVER, ent_coords)
                cursor_active = cursor_active or AreCoordsCentered(ent_coords)
            else
                DrawSpriteAtCoords(ENTITY_SPRITE, ent_coords)
            end
        end
    end
    for _, ent in ipairs(GetPeds()) do
        local ent_coords = GetOffsetFromEntityInWorldCoords(ent, reg_model_offsets[GetEntityModel(ent)] or vector3(0,0,0))
        if #(player.Coords - ent_coords) < 10 then
            if ent == rc_entity then
                DrawSpriteAtCoords(ENTITY_SPRITE_HOVER, vector3(ent_coords.x, ent_coords.y, ent_coords.z+0.3))
                cursor_active = cursor_active or AreCoordsCentered(vector3(ent_coords.x, ent_coords.y, ent_coords.z+0.3))
            else
                DrawSpriteAtCoords(ENTITY_SPRITE, vector3(ent_coords.x, ent_coords.y, ent_coords.z+0.3))
            end
        end
    end    
    for _, ent in ipairs(GetVehicles()) do
        if GetVehicleClass(ent) ~= 21 and #(player.Coords - GetEntityCoords(ent)) < 10 then
            local ent_coords = GetOffsetFromEntityInWorldCoords(ent, reg_model_offsets[GetEntityModel(ent)] or vector3(0,0,0))
            if ent == rc_entity then
                DrawSpriteAtCoords(ENTITY_SPRITE_HOVER, ent_coords)
                cursor_active = cursor_active or AreCoordsCentered(ent_coords)
            else
                DrawSpriteAtCoords(ENTITY_SPRITE, ent_coords)
            end
        end
    end
    
    if not interacting then
        SendNUIMessage({
            action = "SET_CURSOR_ACTIVE",
            toggle = cursor_active
        })
    end
end

function StartTracker()
    Citizen.CreateThread(function()
        while show_cursor or interacting do 
            rc_hit, rc_coords, rc_entity = RayCastGamePlayCamera(10)
            Wait(100)
        end
    end)
end

function AreCoordsCentered(coords)
    local _, screen_x, screen_y = GetScreenCoordFromWorldCoord(table.unpack(coords))
    return math.abs(screen_x-0.5) < 0.01 and math.abs(screen_y-0.5) < 0.01
end

RegisterNUICallback("Trigger", function(data, cb)
    TriggerEvent(data.event, rc_entity)
end)

RegisterNUICallback("Close", function()
    Close()
end)

function Close()
    interacting = false
end

-- API

-- TYPE MENU
RegisterNetEvent("exp_target_menu:AddTypeMenuItem")
AddEventHandler("exp_target_menu:AddTypeMenuItem", function(event, type, desc, stay)
    desc = desc or _("no_desc")
    options[TYPE_TO_OPTION[type]][event] = {
        desc = desc,
        stay = stay
    }
end)

RegisterNetEvent("exp_target_menu:RemoveTypeMenuItem")
AddEventHandler("exp_target_menu:RemoveTypeMenuItem", function(event, type)
    options[TYPE_TO_OPTION[type]][event] = nil
end)

-- ENTITY MENU
RegisterNetEvent("exp_target_menu:AddEntityMenuItem")
AddEventHandler("exp_target_menu:AddEntityMenuItem", function(entity, event, desc, stay)
    reg_entities[entity] = reg_entities[entity] or {}
    reg_entities[entity][event] = {
        desc = desc,
        stay = stay
    }
end)

RegisterNetEvent("exp_target_menu:RemoveEntityMenuItem")
AddEventHandler("exp_target_menu:RemoveEntityMenuItem", function(entity, event)
    if not reg_entities[entity] then return end
    
    reg_entities[entity][event] = nil

    local is_empty = true
    for k, v in pairs(reg_entities[entity]) do
        is_empty = false
        break
    end
    if is_empty then
        reg_entities[entity] = nil
    end
end)

-- MODEL MENU
RegisterNetEvent("exp_target_menu:AddModelMenuItem")
AddEventHandler("exp_target_menu:AddModelMenuItem", function(model, event, desc, stay)
    reg_models[model] = reg_models[model] or {}
    reg_models[model][event] = {
        desc = desc,
        stay = stay
    }
end)

RegisterNetEvent("exp_target_menu:RemoveModelMenuItem")
AddEventHandler("exp_target_menu:RemoveModelMenuItem", function(model, event)
    if not reg_models[model] then return end

    reg_models[model][event] = nil

    local is_empty = true
    for k, v in pairs(reg_models[model]) do
        is_empty = false
        break
    end
    if is_empty then
        reg_models[model] = nil
    end
end)

RegisterNetEvent("exp_target_menu:PauseMenu")
AddEventHandler("exp_target_menu:PauseMenu", function(pause)
    paused = pause
    SendNUIMessage({
        action = "FORCE_CLOSE"
    })
end)

RegisterNetEvent("exp_target_menu:OpenMainMenu")
AddEventHandler("exp_target_menu:OpenMainMenu", function(name, options)
    interacting = true
    SendNUIMessage({
        action = "OPEN_MENU",
        title = name,
        options = options or entity_options
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent("exp_target_menu:SetEntityName")
AddEventHandler("exp_target_menu:SetEntityName", function(entity, name)
    reg_names[entity] = name
end)

RegisterNetEvent("exp_target_menu:SetModelName")
AddEventHandler("exp_target_menu:SetModelName", function(model, name)
    reg_model_names[model] = name
end)

RegisterNetEvent("exp_target_menu:SetModelOffset")
AddEventHandler("exp_target_menu:SetModelOffset", function(model, offset)
    reg_model_offsets[model] = offset
end)

RegisterNetEvent("exp_target_menu:model")
AddEventHandler("exp_target_menu:model", function(cb)
    cb(rc_entity)
end)