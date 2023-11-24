RegisterNetEvent("exp_target_menu:AddTypeMenuItem", function(event, type, desc, stay, arguments)
    AddTypeMenuItem({
        event = event,
        type = type,
        desc = desc,
        stay = stay,
        arguments = arguments
    })
end)

RegisterNetEvent("exp_target_menu:RemoveTypeMenuItem", function(event, type)
    RemoveTypeMenuItem({
        type = type,
        event = event
    })
end)

RegisterNetEvent("exp_target_menu:AddEntityMenuItem", function(entity, event, desc, stay, arguments)
    AddEntityMenuItem({
        entity = entity,
        event = event,
        desc = desc,
        stay = stay,
        arguments = arguments
    })
end)

RegisterNetEvent("exp_target_menu:RemoveEntityMenuItem", function(entity, event)
    RemoveEntityMenuItem({
        entity = entity,
        event = event
    })
end)

RegisterNetEvent("exp_target_menu:AddModelMenuItem", function(model, event, desc, stay, arguments)
    AddModelMenuItem({
        model = model,
        event = event,
        desc = desc,
        stay = stay,
        arguments = arguments
    })
end)

RegisterNetEvent("exp_target_menu:RemoveModelMenuItem", function(model, event)
    RemoveModelMenuItem({
        model = model,
        event = event
    })
end)

RegisterNetEvent("exp_target_menu:PauseMenu", function(pause)
    PauseMenu({
        pause = pause
    })
end)

RegisterNetEvent("exp_target_menu:OpenMainMenu", function(name, options)
    OpenMainMenu({
        name = name,
        options = options
    })
end)

RegisterNetEvent("exp_target_menu:SetEntityName", function(entity, name)
    SetEntityName({
        entity = entity,
        name = name
    })
end)

RegisterNetEvent("exp_target_menu:SetModelName", function(model, name)
    SetModelName({
        model = model,
        name = name
    })
end)

RegisterNetEvent("exp_target_menu:SetModelOffset", function(model, offset)
    SetModelOffset({
        model = model,
        offset = offset
    })
end)

RegisterNetEvent("exp_target_menu:model", function(cb)
    cb(rc_entity)
end)