-- https://github.com/brentN5/bt-target/blob/main/bt-target/client/main.lua
function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, hit, coords, d, entity = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    if #(coords - GetEntityCoords(PlayerPedId())) < RANGE then
        return hit, coords, entity
    else
        return 0, vector3(0, 0, 0), 0
    end
end

function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

---@param dict1 table
---@param dict2 table
---@return table merged_dict
function MergeDict(dict1, dict2)
    local new_dict = {}
    for k, v in pairs(dict1 or {}) do
        new_dict[k] = v
    end
    for k, v in pairs(dict2 or {}) do
        new_dict[k] = v
    end

    return new_dict
end

---@param sprite table Must contain the followings: DICT, NAME, WIDTH, HEIGHT, ROT, COLOR_R, COLOR_G, COLOR_B, COLOR_A
---@param coords vector3
function DrawSpriteAtCoords(sprite, coords)
    SetDrawOrigin(coords.x, coords.y, coords.z)
    DrawSprite(sprite.DICT, sprite.NAME, 0, 0, sprite.WIDTH, sprite.HEIGHT, sprite.ROT, sprite.COLOR_R, sprite.COLOR_G, sprite.COLOR_B, sprite.COLOR_A)
    ClearDrawOrigin()
end