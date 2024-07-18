local throwed = {}

local function translocate(itemstack, player)
	if not (itemstack and player) then return end
	local name = player:get_player_name()
	local creative = minetest.check_player_privs(name, {creative = true})
	if throwed[name] then
		local obj = throwed[name]
		local pos = obj:get_pos()
		if pos then
			player:set_pos(pos)
		end
		obj:remove()
		throwed[name] = nil
		if not creative then
			itemstack:add_wear(655.35)
		end
		if minetest.get_modpath("tpr") then
			minetest.sound_play("tpr_warp",{to_player = name})
		end
		return itemstack
	end
end

minetest.register_tool("translocator:translocator", {
  wield_scale = {x=1.5,y=1.5,z=0.8},
  description = "Translocator",
  inventory_image = "translocator.png",
  on_use = function(itemstack, player, pointed_thing)
	local name = player:get_player_name()
	local creative = minetest.check_player_privs(name, {creative = true})
	local pos = player:get_pos()
	local dir = player:get_look_dir()
	if pos and dir then
		if throwed[name] then
			throwed[name]:remove()
		end
		pos.y = pos.y + 1.5
		local obj = minetest.add_entity(pos, "translocator:disk", name)
		if obj then
			obj:set_velocity({x=dir.x * 15, y=dir.y * 15, z=dir.z * 15})
			obj:set_acceleration({x=0,z=0,y=-9.81})
			throwed[name] = obj
			if not creative then
				itemstack:add_wear(220)
			end
		end
	end
	return itemstack
  end,
  on_place = function(itemstack, player)
	return translocate(itemstack, player)
  end,
  on_secondary_use = function(itemstack, player)
	return translocate(itemstack, player)
  end
})

minetest.register_entity("translocator:disk",{
	armor_groups = {immortal = true},
	physical = true,
	timer = 0,
	visual = "mesh",
	mesh = "translocator_disk.obj",
	visual_size = {x=2.5, y=2.5,},
	textures = {"translocator_disk.png"},
	pointable = false,
	collisionbox = {-0.24,-0.05,-0.24,0.24,0.05,0.24},
	collide_with_objects = false,
	on_activate = function(self, staticdata)
		self.owner = staticdata
	end,
	on_step = function(self, dtime, moveresult)
		if not self.owner or not minetest.get_player_by_name(self.owner) then
			self.object:remove()
			return
		end
		self.timer = self.timer + dtime
		local vel = self.object:get_velocity()
		if self.timer >= 6 then
			self.object:remove()
			return
		end
		if moveresult.touching_ground == true then
			self.object:set_velocity({x=0.3^dtime*vel.x,y=vel.y,z=0.3^dtime*vel.z})
		end
	end,
})

minetest.register_craft({
	output = "translocator:translocator",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","dye:red"},
		{"","default:mese_crystal","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","dye:red"}
	}
})
