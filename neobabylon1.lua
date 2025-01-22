local sound = require('play_sound')

local neobabylon1 = {
    identifier = "Neo Babylon-1",
    title = "Neo Babylon-1: Brain Freeze",
    theme = THEME.NEO_BABYLON,
    width = 4,
    height = 4,
    file_name = "Neo Babylon-1.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

neobabylon1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_BABYLON)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR)
	
	--Freeze Ray
	define_tile_code("freezeray")
	local freeze_ray
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_FREEZERAY, x, y, layer, 0, 0)
		return true
	end, "freezeray")
	
	--Horizontal Laser
	define_tile_code("horizontal_laser")
	local laser
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn(ENT_TYPE.FLOOR_HORIZONTAL_FORCEFIELD, x, y, layer, 0, 0)		
		laser = get_entity(block_id)
		return true
	end, "horizontal_laser")
	
	--Dead Olmite
	define_tile_code("olmite_dead")
	local olmite_dead
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.MONS_OLMITE_NAKED, x, y, layer, 0, 0)
		olmite_dead = get_entity(block_id)
		kill_entity(block_id, false)
		return true
	end, "olmite_dead")
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)
	
	local frames = 0
	local laser_on = false
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
	
		if laser ~= nil and laser.timer > 0 and laser_on == false then
			laser_on = true
		end
		
		if laser_on == true then
			laser.timer = 2 -- Keep forcefield on
		end
		
        frames = frames + 1
    end, ON.FRAME)
	
	toast(neobabylon1.title)
end

neobabylon1.unload_level = function()
    if not level_state.loaded then return end
    
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon1