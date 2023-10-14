function GetObjects()
	return GetGamePool('CObject')
end

function GetPeds()
	local peds, myPed, pool = {}, PlayerPedId(), GetGamePool('CPed')

	for i,v in ipairs(pool) do
        if v ~= myPed then
            table.insert(peds, v)
        end
    end

	return peds
end

function GetVehicles()
	return GetGamePool('CVehicle')
end