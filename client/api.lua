function AddTypeMenuItem(options)
    Options[TYPE_TO_OPTION[options.type]][options.event] = {
        desc = options.desc or _("no_desc"),
        stay = options.stay,
        arguments = options.arguments
    }
end
exports("AddTypeMenuItem", AddTypeMenuItem)

function RemoveTypeMenuItem(options)
    Options[TYPE_TO_OPTION[options.type]][options.event] = nil
end
exports("RemoveTypeMenuItem", RemoveTypeMenuItem)

function AddEntityMenuItem(options)
    reg_entities[options.entity] = reg_entities[options.entity] or {}
    reg_entities[options.entity][options.event] = {
        desc = options.desc,
        stay = options.stay,
        arguments = options.arguments
    }

    if options.name then
        SetEntityName(options)
    end
end
exports("AddEntityMenuItem", AddEntityMenuItem)

function RemoveEntityMenuItem(options)
    if not reg_entities[options.entity] then return end
    
    reg_entities[options.entity][options.event] = nil

    local is_empty = true
    for k, v in pairs(reg_entities[options.entity]) do
        is_empty = false
        break
    end
    if is_empty then
        reg_entities[options.entity] = nil
    end
end
exports("RemoveEntityMenuItem", RemoveEntityMenuItem)

function AddModelMenuItem(options)
    reg_models[options.model] = reg_models[options.model] or {}
    reg_models[options.model][options.event] = {
        desc = options.desc,
        stay = options.stay,
        arguments = options.arguments
    }

    if options.name then
        SetModelName(options)
    end

    if options.offset then
        SetModelOffset(options)
    end
end
exports("AddModelMenuItem", AddModelMenuItem)

function RemoveModelMenuItem(options)
    if not reg_models[options.model] then return end

    reg_models[options.model][options.event] = nil

    local is_empty = true
    for k, v in pairs(reg_models[options.model]) do
        is_empty = false
        break
    end
    if is_empty then
        reg_models[options.model] = nil
    end
end
exports("RemoveModelMenuItem", RemoveEntityMenuItem)

function PauseMenu(options)
    paused = options.pause
    SendNUIMessage({
        action = "FORCE_CLOSE"
    })
end
exports("PauseMenu", PauseMenu)

function OpenMainMenu(options)
    interacting = true
    SendNUIMessage({
        action = "OPEN_MENU",
        title = options.name,
        options = options.options or entity_options
    })
    SetNuiFocus(true, true)
end
exports("OpenMainMenu", OpenMainMenu)

function SetEntityName(options)
    reg_names[options.entity] = options.name
end
exports("SetEntityName", SetEntityName)

function SetModelName(options)
    reg_model_names[options.model] = options.name
end
exports("SetModelName", SetModelName)

function SetModelOffset(options)
    reg_model_offsets[options.model] = options.offset
end
exports("SetModelOffset", SetModelOffset)