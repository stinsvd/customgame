-- overriding valve-broken functions
CDOTA_Ability_Lua.GetCastRangeBonus = function(self, hTarget)
	if not self or self:IsNull() then return 0 end
	if not self:GetCaster() or self:GetCaster():IsNull() then return 0 end
	return self:GetCaster():GetCastRangeBonus()
end
CDOTABaseAbility.GetCastRangeBonus = function(self, hTarget)
	if not self or self:IsNull() then return 0 end
	if not self:GetCaster() or self:GetCaster():IsNull() then return 0 end
	return self:GetCaster():GetCastRangeBonus()
end

-- CustomGameEventManager
if not inited then
local valve_customgameventmanager_sendservertoplayer = CCustomGameEventManager.Send_ServerToPlayer
CCustomGameEventManager.Send_ServerToPlayer = function(self, player, eventName, eventData)
	local secret_key = EncryptionManager:get_secret_key("nettable")
	local data = table.copy(eventData)
	data["encrypted_key"] = secret_key
	data["encrypted_type"] = "player"
	CustomNetTables:SetTableValue("encrypted", tostring("player_"..player:GetPlayerID()), {key = secret_key})
	valve_customgameventmanager_sendservertoplayer(self, player, eventName, data)
end
local valve_customgameventmanager_sendservertoteam = CCustomGameEventManager.Send_ServerToTeam
CCustomGameEventManager.Send_ServerToTeam = function(self, team, eventName, eventData)
	local secret_key = EncryptionManager:get_secret_key("nettable")
	local data = table.copy(eventData)
	data["encrypted_key"] = secret_key
	data["encrypted_type"] = "team"
	CustomNetTables:SetTableValue("encrypted", tostring("team_"..team), {key = secret_key})
	valve_customgameventmanager_sendservertoteam(self, team, eventName, data)
end
local valve_customgameventmanager_sendservertoclients = CCustomGameEventManager.Send_ServerToAllClients
CCustomGameEventManager.Send_ServerToAllClients = function(self, eventName, eventData)
	local secret_key = EncryptionManager:get_secret_key("nettable")
	local data = table.copy(eventData)
	data["encrypted_key"] = secret_key
	data["encrypted_type"] = "all"
	CustomNetTables:SetTableValue("encrypted", "all", {key = secret_key})
	valve_customgameventmanager_sendservertoclients(self, eventName, data)
end
end

-- PlayerResource
function CDOTA_PlayerResource:DisplayError(pId, msg)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pId), "CreateIngameErrorMessage", {message = msg})
end
function CDOTA_PlayerResource:GetPlayerIDs()
	local players = {}
	for i=0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(i) then
			table.insert(players, i)
		end
	end
	return players
end
function CDOTA_PlayerResource:GetPlayerIDsInTeam(team)
	return table.values(table.filter(PlayerResource:GetPlayerIDs(), function(k, v)
		return PlayerResource:GetTeam(v) == team
	end))
end
function CDOTA_PlayerResource:GetNetWorthInTeam(team)
	local gold = {}
	for _, playerID in pairs(PlayerResource:GetPlayerIDsInTeam(team)) do
		gold[playerID] = PlayerResource:GetNetWorth(playerID)
	end
	return gold
end
function CDOTA_PlayerResource:GetTeams()
	return table.values(table.filter(TEAMS, function(_, team)
		return #PlayerResource:GetPlayerIDsInTeam(team) > 0
	end))
end
function CDOTA_PlayerResource:Kick(playerID)
	SendToServerConsole("kickid "..tostring(GetUserID(playerID)))
end
function CDOTA_PlayerResource:KickID(userID)
	SendToServerConsole("kickid "..tostring(userID))
end
function CDOTA_PlayerResource:PingAtMinimap(player, point)
	CustomGameEventManager:Send_ServerToPlayer(type(player) == "number" and PlayerResource:GetPlayer(player) or player, "MinimapPing", {location=point})
end
function CDOTA_PlayerResource:PingAtMinimapTeam(team, point)
	CustomGameEventManager:Send_ServerToTeam(team, "MinimapPing", {location=point})
end
function CDOTA_PlayerResource:PingAtMinimapAll(point)
	CustomGameEventManager:Send_ServerToAllClients("MinimapPing", {location = point})
end
function CDOTA_PlayerResource:GetRespawnPositions(team)
	local info_player_starts = table.values(table.filter(Entities:FindAllByClassname("info_player_start_dota"), function(_, spawn)
		return spawn:GetTeamNumber() == team
	end))
	if team == DOTA_TEAM_GOODGUYS then
		info_player_starts = table.combine(info_player_starts, Entities:FindAllByClassname("info_player_start_goodguys"))
	elseif team == DOTA_TEAM_BADGUYS then
		info_player_starts = table.combine(info_player_starts, Entities:FindAllByClassname("info_player_start_badguys"))
	end
	return table.values(table.map(info_player_starts, function(_, spawn)
		return spawn:GetAbsOrigin()
	end))
end
function CDOTA_PlayerResource:GetRespawnPosition(team)
	return table.choice(PlayerResource:GetRespawnPositions(team))
end

-- Sounds
function EmitSoundOnLocationForTeam(sound, pos, team)
	local dummy = CreateUnitByName("npc_dummy_unit", pos, false, nil, nil, team)
	Timers:CreateTimer(60, function() UTIL_Remove(dummy) end)
	EmitSoundOnLocationForAllies(pos, sound, dummy)
end
function CDOTAPlayerController:EmitSoundOnClient(sound)
	CustomGameEventManager:Send_ServerToPlayer(self, "EmitSoundOnClient", {sound = sound})
end
function CDOTA_BaseNPC:EmitSoundOnClient(sound)
	local player = self:GetPlayerOwner()
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "EmitSoundOnClient", {sound = sound})
	end
end
function EmitSoundWithCooldown(sound, cooldown, soundData)
	if SOUNDS_COOLDOWN[soundData["id"] or sound] == nil or (GameRules:GetDOTATime(false, false) - SOUNDS_COOLDOWN[soundData["id"] or sound]) > cooldown then
		SOUNDS_COOLDOWN[soundData["id"] or sound] = GameRules:GetDOTATime(false, false)
		if soundData["soundType"] == "unit" then
			soundData["unit"]:EmitSound(sound)
		elseif soundData["soundType"] == "unit_on" then
			EmitSoundOn(sound, soundData["unit"])
		elseif soundData["soundType"] == "unit_params" then
			soundData["unit"]:EmitSoundParams(sound, soundData["pitch"], soundData["volume"], soundData["delay"])
		elseif soundData["soundType"] == "player" then
			soundData["unit"]:EmitSoundOnClient(sound)
		elseif soundData["soundType"] == "location" then
			EmitSoundOnLocationWithCaster(soundData["location"], sound, soundData["unit"])
		elseif soundData["soundType"] == "location_team" then
			EmitSoundOnLocationForTeam(sound, soundData["location"], soundData["team"])
		elseif soundData["soundType"] == "global" then
			EmitGlobalSound(sound)
		elseif soundData["soundType"] == "anoouncer_team" then
			EmitAnnouncerSoundForTeam(sound, soundData["team"])
		end
	end
end
function CDOTABaseAbility:EmitResponseSound(sound, range, random, cooldown)
	if self:IsStolen() then return end
	if random then if not RollPercentage(random) then return end end
	if cooldown then
		id = tostring(self:entindex()..sound..self:GetCaster():entindex())
		if SOUNDS_COOLDOWN[id] ~= nil and (GameRules:GetDOTATime(false, false) - SOUNDS_COOLDOWN[id]) <= cooldown then
			return
		end
		SOUNDS_COOLDOWN[id] = GameRules:GetDOTATime(false, false)
	end
	local nums = {}
	for _, _rn in pairs(range) do
		if string.find(_rn, "-") ~= nil then
			local rn = string.split(_rn, "-")
			for i=tonumber(rn[1]), tonumber(rn[2]) do
				table.insert(nums, i)
			end
		else
			table.insert(nums, tonumber(_rn))
		end
	end
	self:GetCaster():EmitSoundOnClient(sound..string.format("%02d", table.choice(nums)))
end

-- Entities
function CBaseEntity:IsMonkey() return false end
function CDOTA_BaseNPC:IsMonkey()
	return self:HasModifier("modifier_monkey_king_wukongs_command_clone_lua") or self:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") or self:HasModifier("modifier_monkey_king_fur_army_soldier") or self:HasModifier("modifier_monkey_king_fur_army_soldier_in_position") or self:HasModifier("modifier_monkey_king_fur_army_soldier_inactive")
end
if not inited then
	local valve_isclone = CDOTA_BaseNPC.IsClone
	CDOTA_BaseNPC.IsClone = function(self)
		if valve_isclone(self) then return true end
		if IsValidEntity(self) and self.GetPlayerOwnerID then
			local owner = PlayerResource:GetSelectedHeroEntity(self:GetPlayerOwnerID())
			return owner ~= nil and self ~= owner and self:IsRealHero() and self:GetUnitName() == owner:GetUnitName() and not self:IsTempestDouble() and not self:IsMonkey() and not self:HasModifier("modifier_vengefulspirit_command_aura_illusion")
		end
	end
end
function CBaseEntity:IsTrueHero(ignore_clones)
	return not self:IsNull() and self:IsRealHero() and not self:IsIllusion() and not self:IsMonkey() and not self:IsSpiritBear() and not self:HasModifier("modifier_vengefulspirit_command_aura_illusion") and (ignore_clones or (not self:IsClone() and not self:IsTempestDouble()))
end
function CBaseEntity:HandleData()
	local unit_data = GetUnitKeyValuesByName(self:GetUnitName())
	if unit_data and unit_data["CustomData"] ~= nil then
		unit_data = unit_data["CustomData"]
		if unit_data["Invulnerable"] ~= nil then
			if unit_data["Invulnerable"] == 1 then
				if unit_data["FakeInvulnerable"] ~= nil and (unit_data["FakeInvulnerable"] == 1 or unit_data["FakeInvulnerable"] == 2) then
					self:RemoveModifierByName("modifier_invulnerable")
					if unit_data["FakeInvulnerable"] == 1 then
						self:AddNewModifier(nil, nil, "modifier_fake_invulnerable", {})
					else
						self:AddNewModifier(nil, nil, "modifier_fake_invulnerable_both", {})
					end
				else
					self:AddNewModifier(nil, nil, "modifier_invulnerable_lua", {})
				end
			elseif unit_data["Invulnerable"] == 0 then
				self:RemoveModifierByName("modifier_invulnerable")
			end
		end
		if unit_data["CantMove"] ~= nil and unit_data["CantMove"] == 1 then
			self:AddNewModifier(nil, nil, "modifier_rooted", {})
		end
		if unit_data["Unselectable"] ~= nil and unit_data["Unselectable"] == 1 then
			self:AddNewModifier(nil, nil, "modifier_unselectable_lua", {})
		end
		if unit_data["Phased"] ~= nil and unit_data["Phased"] == 1 then
			self:AddNewModifier(nil, nil, "modifier_phased", {})
		end
		if unit_data["FlyingVision"] ~= nil and unit_data["FlyingVision"] == 1 then
			self:AddNewModifier(nil, nil, "modifier_flying_vision_lua", {})
		end
		if unit_data["Dummy"] ~= nil and table.contains({1, 2}, unit_data["Dummy"]) then
			self:MakeDummy(false, unit_data["Dummy"] == 1, unit_data["Dummy"] == 1)
		end
		if unit_data["DireModel"] ~= nil and self:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			self:SetModel(unit_data["DireModel"])
			if self:IsBaseNPC() then
				self:SetOriginalModel(unit_data["DireModel"])
			end
		end
		if unit_data["Attachments"] ~= nil then
			for model, _ in pairs(unit_data["Attachments"]) do
				self:SpawnAttachment(model)
			end
		end
	end
end
function CDOTA_BaseNPC:GetCastingAbility()
	for i=0, self:GetAbilityCount()-1 do
		local ability = self:GetAbilityByIndex(i)
		if ability and ability:IsInAbilityPhase() then return ability end
	end
	return nil
end
function CDOTA_BaseNPC:SpawnAttachment(model)
	local attachment = SpawnEntityFromTableSynchronous("prop_dynamic", {model=model})
	attachment:FollowEntity(self, true)
	return attachment
end
function CDOTA_BaseNPC:Dispell(caster, strong)
	local modifiers = table.values(table.map(table.filter(self:FindAllModifiers(), function(_, mod)
		return (self:GetTeamNumber() == caster:GetTeamNumber() and {mod:IsDebuff()} or {not mod:IsDebuff()})[1]
	end), function(_, mod)
		return {mod, mod:GetName()}
	end))
	local dispelled = {}
	self:Purge(self:GetTeamNumber() ~= caster:GetTeamNumber(), self:GetTeamNumber() == caster:GetTeamNumber(), false, self:GetTeamNumber() == caster:GetTeamNumber() and strong, strong)
	local new_modifiers = table.values(table.filter(self:FindAllModifiers(), function(_, mod)
		return (self:GetTeamNumber() == caster:GetTeamNumber() and {mod:IsDebuff()} or {not mod:IsDebuff()})[1]
	end))
	for _, mod in pairs(modifiers) do
		if mod[1]:IsNull() or not table.contains(new_modifiers, mod[1]) then
			table.insert(dispelled, mod[2])
		end
	end
	return dispelled
end
function CDOTA_BaseNPC:Disarm(caster, ability, duration, particle)
	local disarm = self:AddNewModifier(caster, ability, "modifier_disarmed", {duration=duration})
	if disarm then
		local fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_disarm.vpcf", PATTACH_OVERHEAD_FOLLOW, self)
		disarm:AddParticle(fx, false, false, -1, false, true)
		if particle then
			local fxx = ParticleManager:CreateParticle(particle["fx"], particle["pattach"], self)
			disarm:AddParticle(fxx, false, false, 1, false, particle["pattach"]==PATTACH_OVERHEAD_FOLLOW)
		end
	end
	return disarm
end
function CDOTA_BaseNPC:CreateCreepIllusions(owner, modifierKeys, numIllusions, padding, findClearSpace, issuperillusion)
	local illusions = {}
	modifierKeys["bounty_base"] = modifierKeys["bounty_base"] or self:GetLevel() * 2
	for i=1, numIllusions do
		local illusion = CreateUnitByName(self:GetUnitName(), self:GetAbsOrigin() + RandomVector(padding), findClearSpace, owner, owner, owner:GetTeamNumber())
		illusion:AddNewModifier(owner, nil, "modifier_illusion", modifierKeys)
		illusion:MakeIllusion()
		illusion:CreatureLevelUp(self:GetLevel() - illusion:GetLevel())
		for ability_slot = 0, self:GetAbilityCount()-1 do
			local ability = self:GetAbilityByIndex(ability_slot)
			if ability ~= nil then
				local illusion_ability = illusion:FindAbilityByName(ability:GetAbilityName())
				if illusion_ability ~= nil then
					illusion_ability:SetLevel(ability:GetLevel())
					if not issuperillusion then
						illusion_ability:SetActivated(false)
					end
				end
			end
		end
		for _, item_slot in pairs(table.combine(INVENTORY_SLOTS, BACKPACK_SLOTS)) do
			local illusion_item = illusion:GetItemInSlot(item_slot)
			if illusion_item ~= nil then illusion:RemoveItem(illusion_item) end
			local item = self:GetItemInSlot(item_slot)
			if item ~= nil then
				illusion:AddItemByName(item:GetName())
			end
		end
		for _, mod in pairs(self:FindAllModifiers()) do
			if mod.AllowIllusionDuplicate and mod:AllowIllusionDuplicate() then
				illusion:AddNewModifier(illusion, mod:GetAbility(), mod:GetName(), {duration=mod:GetRemainingTime()})
			end
		end
		illusion:SetHealth(self:GetHealth())
		illusion:SetMana(self:GetMana())
		illusion:SetControllableByPlayer(owner:GetMainControllingPlayer(), true)
		table.insert(illusions, illusion)
	end
    return illusions
end
function CDOTA_BaseNPC:LearnSpells()
	for i=0, self:GetAbilityCount()-1 do
		local ability = self:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(ability:GetMaxLevel())
		end
	end
end
function CDOTA_BaseNPC:GetSpells()
	local t = {}
	for i=0, self:GetAbilityCount()-1 do
		local ability = self:GetAbilityByIndex(i)
		if ability then
			t[i] = ability
		end
	end
	return t
end
function CDOTA_BaseNPC:Root(caster, ability, duration, info)
	local root = self:AddNewModifier(caster, ability, "modifier_rooted", {duration = duration})
	if info then
		if info["particle"] then
			local fx = ParticleManager:CreateParticle(info["particle"]["name"], info["particle"]["attach"] or PATTACH_ABSORIGIN_FOLLOW, self)
			root:AddParticle(fx, false, false, -1, false, info["particle"]["attach"] == PATTACH_OVERHEAD_FOLLOW)
		end
	end
end
function CDOTA_BaseNPC:IsTaunted()
	for _, mod in pairs(self:FindAllModifiers()) do
		local states = {} mod:CheckStateToTable(states)
		if states[tostring(MODIFIER_STATE_TAUNTED)] ~= nil then return true end
	end
	return false
end
function CDOTA_BaseNPC:Lifesteal(lifesteal, damage, ability, spell, alert)
	local heal = lifesteal * damage / 100
	self:HealWithParams(heal, ability, not spell, true, self, spell or false)
	if alert then
		SendOverheadEventMessage(self:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, self, heal, self:GetPlayerOwner())
	end
	if spell then
		local fx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		ParticleManager:ReleaseParticleIndex(fx)
	else
		local fx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
		ParticleManager:SetParticleControlEnt(fx, 0, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(fx, 61, self, PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(fx)
	end
	return heal
end
function CDOTA_BaseNPC:LearnAbilities(lvl)
	for i=0, self:GetAbilityCount()-1 do
		local ability = self:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(lvl or ability:GetMaxLevel())
		end
	end
end
function CBaseEntity:MakeDummy(phased, nodraw, hideminimap)
	if nodraw ~= false then
		self:AddNoDraw()
	end
	self:AddNewModifier(nil, nil, "modifier_dummy_unit", {not_on_minimap = hideminimap ~= false or nodraw ~= false})
	if phased or phased == nil then
		self:AddNewModifier(nil, nil, "modifier_phased", {})
	end
end
function CBaseEntity:UnDummy(unphase)
	self:RemoveNoDraw()
	self:RemoveModifierByName("modifier_dummy_unit")
	if unphase then
		self:RemoveModifierByName("modifier_phased")
	end
end
function CreateDummy(position, team, owner, phased, nodraw, hideminimap)
	local unit = CreateUnitByName("npc_dummy_unit", position, false, owner, owner, team)
	unit:UnDummy()
	unit:MakeDummy(phased, nodraw, hideminimap)
	return unit
end
function CBaseEntity:IsDummy()
	return self:HasModifier("modifier_dummy_unit")
end
function CreateTrueSight(position, team, radius)
	local unit = CreateDummy(position, team, nil)
	unit:AddNewModifier(unit, nil, "modifier_truesight_aura_lua", {radius = radius})
	return unit
end
function CDOTA_BaseNPC:Knockback(caster, ability, duration, knockback_info)
	local knockback = {
		should_stun = BoolToNum(knockback_info["stun"]) or 0,
		knockback_duration = knockback_info["duration"] or duration or 1,
		duration = duration or 1,
		knockback_distance = knockback_info["distance"] or 0,
		knockback_height = knockback_info["height"] or 0,
		center_x = knockback_info["center"] ~= nil and knockback_info["center"].x or self:GetAbsOrigin().x,
		center_y = knockback_info["center"] ~= nil and knockback_info["center"].y or self:GetAbsOrigin().y,
		center_z = knockback_info["center"] ~= nil and knockback_info["center"].z or self:GetAbsOrigin().z,
	}
	self:RemoveModifierByName("modifier_knockback")
	self:AddNewModifier(caster, ability, "modifier_knockback", knockback)
end
function CDOTA_BaseNPC:GetItemsByName(itemnames, in_backpack, in_stash)
	local search = table.copy(INVENTORY_SLOTS)
	if in_backpack then search = table.combine(search, BACKPACK_SLOTS) end
	if in_stash then search = table.combine(search, STASH_SLOTS) end
	local items = {}
	for _, slot in pairs(search) do
		local item = self:GetItemInSlot(slot)
		if item ~= nil and not item:IsNull() and item.GetName and table.contains(itemnames, item:GetName()) then
			items[slot] = item
		end
	end
	return items
end
function CDOTA_BaseNPC:TrueKill(inflictor, attacker)
	local exceptions = {
		"modifier_skeleton_king_reincarnation_scepter_active",
	}
	local additionals = {
		"modifier_item_aeon_disk_buff",
		"modifier_winter_wyvern_winters_curse_aura",
		"modifier_winter_wyvern_winters_curse",
		"winter_wyvern_winters_curse_kill_credit",
		"modifier_abaddon_aphotic_shield",
		"modifier_abaddon_borrowed_time",
		"modifier_monkey_king_transform",
		"modifier_nyx_assassin_spiked_carapace",
		"modifier_oracle_false_promise",
		"modifier_templar_assassin_refraction_absorb",
		"modifier_dazzle_shallow_grave",
		"modifier_troll_warlord_battle_trance",
		"modifier_fountain_aura_buff",
		"modifier_fountain_buff_lua",
	}
	for _, mod in pairs(self:FindAllModifiers()) do
		if (mod.GetMinHealth or mod.GetModifierIncomingDamage_Percentage or mod.GetModifierIncomingSpellDamageConstant or mod.GetModifierAvoidDamage or mod.GetModifierAvoidSpell or mod.GetModifierTotal_ConstantBlock or mod.GetAbsoluteNoDamagePure or table.contains(additionals, mod:GetName())) and not table.contains(exceptions, mod:GetName()) then
			mod:Destroy()
		else
			local states = {} mod:CheckStateToTable(states)
			for _, state in pairs({MODIFIER_STATE_INVULNERABLE}) do
				if table.contains(states, state) then
					mod:Destroy()
				end
			end
		end
	end
	self:Kill(inflictor, attacker)
end
function CDOTA_BaseNPC_Hero:ModifyAbilityPoints(modifier)
	self:SetAbilityPoints(self:GetAbilityPoints()+modifier)
end
function CDOTA_BaseNPC_Hero:GetAdditionalStrength()
	return self:GetStrength() - self:GetBaseStrength()
end
function CDOTA_BaseNPC_Hero:GetAdditionalAgility()
	return self:GetAgility() - self:GetBaseAgility()
end
function CDOTA_BaseNPC_Hero:GetAdditionalIntellect()
	return self:GetIntellect(false) - self:GetBaseIntellect()
end
function CDOTA_BaseNPC_Hero:GetRespawnTimeFormula()
	return math.min(self:GetLevel() * 0.1 + 5, 100)
end
function CDOTA_BaseNPC:CanSeeByEnemy()
	for _,enemy in pairs(FindUnitsInRadius(self:GetTeamNumber(), self:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)) do
		if enemy:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS and enemy:CanEntityBeSeenByMyTeam(self) then return true end
	end
	return false
end
function CDOTA_BaseNPC:GetIllusionSource()
	local illusion = self:FindModifierByName("modifier_illusion")
	return illusion ~= nil and illusion:GetCaster() or nil
end
function CDOTA_BaseNPC:GetSource()
	return self:GetIllusionSource() or (self:GetPlayerOwnerID() ~= nil and PlayerResource:GetSelectedHeroEntity(self:GetPlayerOwnerID()) or nil)
end
function CDOTA_BaseNPC:HasSpellAbsorb()
	for _, mod in pairs({"modifier_antimage_counterspell", "modifier_item_sphere_target", "modifier_special_bonus_spell_block"}) do
		if self:HasModifier(mod) then return true end
	end
	for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
		local item = self:GetItemInSlot(i)
		if item ~= nil and table.contains({"item_sphere", "item_mirror_shield"}, item:GetName()) and item:IsCooldownReady() then return true end
	end
	for _, name in pairs({"special_bonus_spell_block_15", "special_bonus_spell_block_18", "special_bonus_spell_block_20"}) do
		local ability = self:FindAbilityByName(name)
		if ability ~= nil and ability:IsTrained() then return true end
	end
	return false
end
function CDOTA_BaseNPC:FindModifierByNameAndAbility(name, ability)
	for _, mod in pairs(self:FindAllModifiersByName(name)) do
		if mod:GetAbility() == ability then return mod end
	end
	return nil
end
function CDOTA_BaseNPC:GetFountain()
	for _, ent in pairs(Entities:FindAllByClassname("ent_dota_fountain")) do
		if ent:GetTeamNumber() == self:GetTeamNumber() then
			return ent
		end
	end
end
function CDOTA_BaseNPC:ExecuteOrder(order, target, ability, position, queue)
	return ExecuteOrderFromTable({UnitIndex=self:entindex(), OrderType=order, TargetIndex=target ~= nil and target:entindex() or nil, AbilityIndex=ability ~= nil and ability:entindex() or nil, Position=position, Queue=queue})
end
function CDOTA_BaseNPC:AI()
	return self.hAI
end
function CDOTA_BaseNPC:GetBonusAttackDamage()
	return self:GetAverageTrueAttackDamage(nil) - self:GetAttackDamage()
end
function CDOTA_BaseNPC:TriggerAbilitiesCustomCallback(name, ...)
	for i=0, self:GetAbilityCount()-1 do
		local ability = self:GetAbilityByIndex(i)
		if ability and type(ability[name]) == "function" then
			ability[name](ability, ...)
		end
	end
	for _, i in pairs(table.combine(INVENTORY_SLOTS, BACKPACK_SLOTS)) do
		local item = self:GetItemInSlot(i)
		if item and type(item[name]) == "function" then
			if item[name](item, ...) == true then
				break
			end
		end
	end
end
local function swap_indexes(self)
	local playerOwnerEntity = self:GetSource()
	local index_difference = table.compare(table.map(self:GetSpells(), function(_, spell) return spell:GetAbilityName() end), table.map(playerOwnerEntity:GetSpells(), function(_, spell) return spell:GetAbilityName() end), true)
	local index_positions = {}
	local owner_spells = table.map(playerOwnerEntity:GetSpells(), function(_, spell) return spell:GetAbilityName() end)
	for i, v in pairs(self:GetSpells()) do
		local k = table.find(owner_spells, v:GetAbilityName())
		if k ~= i and k ~= nil then
			table.insert(index_positions, {old_value=i, new_value=k})
		end
	end
	if table.length(index_difference["edited"]) <= 0 then
		if table.length(index_positions) > 0 then
			for _, info in pairs(index_positions) do
				local old_ability = self:GetAbilityByIndex(info["new_value"])
				local new_ability = self:GetAbilityByIndex(info["old_value"])
				if old_ability ~= nil and new_ability ~= nil then
					self:SwapAbilities(old_ability:GetAbilityName(), new_ability:GetAbilityName(), not old_ability:IsHidden(), not new_ability:IsHidden())
				else
					local ability = self:AddAbility(new_ability:GetAbilityName())
					ability:SetAbilityIndex(info["new_value"])
					ability:SetLevel(new_ability:GetLevel())
					ability:SetActivated(new_ability:IsActivated())
					ability:SetHidden(new_ability:IsHidden())
					self:RemoveAbilityByHandle(new_ability)
				end
			end
			return swap_indexes(self)
		end
		return nil
	end
	local info = table.values(index_difference["edited"])[1]
	local old_ability = self:FindAbilityByName(info["new_value"])
	local new_ability = self:FindAbilityByName(info["old_value"])
	if old_ability == nil or new_ability == nil then return end
	self:SwapAbilities(old_ability:GetAbilityName(), new_ability:GetAbilityName(), not old_ability:IsHidden(), not new_ability:IsHidden())
	return swap_indexes(self)
end
function CDOTA_BaseNPC_Hero:CopyAbilities()
	local playerOwnerEntity = self:GetSource()
	local original_abilities = table.map(playerOwnerEntity:GetSpells(), function(_, spell) return spell:GetAbilityName() end)
	local npc_abilities = table.map(self:GetSpells(), function(_, spell) return spell:GetAbilityName() end)
	local difference = table.compare(table.values(npc_abilities), table.values(original_abilities))
	for _, info in pairs(difference["removed"]) do
		self:RemoveAbility(info["value"])
	end
	for _, info in pairs(difference["edited"]) do
		local original_ability = playerOwnerEntity:FindAbilityByName(info["new_value"])
		local npc_ability = self:FindAbilityByName(info["old_value"])
		self:RemoveAbilityByHandle(npc_ability)
		local ability = self:AddAbility(info["new_value"])
		ability:SetLevel(original_ability:GetLevel())
		if ((self:IsTempestDouble() or self:IsClone()) and table.contains({"arc_warden_tempest_double", "monkey_king_wukongs_command_lua", "meepo_megameepo", "meepo_megameepo_fling"}, info["new_value"])) or (self:IsMonkey() and info["new_value"] == "monkey_king_jingu_mastery") then
			ability:SetActivated(false)
		else
			ability:SetActivated(original_ability:IsActivated())
		end
		ability:SetHidden(original_ability:IsHidden())
	end
	for _, info in pairs(difference["added"]) do
		local original_ability = playerOwnerEntity:FindAbilityByName(info["value"])
		local ability = self:AddAbility(info["value"])
		ability:SetLevel(original_ability:GetLevel())
		if ((self:IsTempestDouble() or self:IsClone()) and table.contains({"arc_warden_tempest_double", "monkey_king_wukongs_command_lua", "meepo_megameepo", "meepo_megameepo_fling"}, info["value"])) or (self:IsMonkey() and info["value"] == "monkey_king_jingu_mastery") then
			ability:SetActivated(false)
		else
			ability:SetActivated(original_ability:IsActivated())
		end
		ability:SetHidden(original_ability:IsHidden())
	end
	-- swap_indexes(self)
	for i=0, self:GetAbilityCount()-1 do
		local original_ability = playerOwnerEntity:GetAbilityByIndex(i)
		local ability = self:GetAbilityByIndex(i)
		if original_ability ~= nil and ability ~= nil and original_ability:GetAbilityName() == ability:GetAbilityName() then
			if original_ability:GetLevel() ~= ability:GetLevel() then
				ability:SetLevel(original_ability:GetLevel())
			end
		end
	end
end
function CDOTA_BaseNPC:HasAnyAvailableInventorySlot(exclude_additional)
	if not self:IsHero() or exclude_additional then
		for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
			local item = self:GetItemInSlot(i)
			if item == nil then
				return true
			end
		end
		return false
	end
	for _, i in pairs(table.combine(INVENTORY_SLOTS, BACKPACK_SLOTS)) do
		if i ~= DOTA_ITEM_NEUTRAL_ACTIVE_SLOT and i ~= DOTA_ITEM_NEUTRAL_PASSIVE_SLOT then
			local item = self:GetItemInSlot(i)
			if item == nil then
				return true
			end
		end
	end
	return false
end
function CDOTA_BaseNPC:FindModifiersByAbility(ability)
	return table.values(table.filter(self:FindAllModifiers(), function(_, mod) return mod:GetAbility() == ability end))
end
function CDOTA_BaseNPC_Hero:UpdatePrimaryAttribute(attribute)
	self:AddNewModifier(self, nil, "modifier_primary_attribute_lua", {attribute=attribute})
end
function CDOTA_BaseNPC_Hero:ResetPrimaryAttribute()
	self:RemoveModifierByName("modifier_primary_attribute_lua")
end

-- Abilities
function CDOTABaseAbility:GetCastTime()
	return self:GetCastPoint() * self:GetCastPointModifier()
end
function CDOTABaseAbility:ModifyLevel(lvl)
	self:SetLevel(self:GetLevel()+lvl)
end
function CDOTABaseAbility:FindAllModifiers(name)
	return table.values(table.filter(name ~= nil and self:GetCaster():FindAllModifiersByName(name) or self:GetCaster():FindAllModifiers(), function(_, mod) return mod:GetAbility() == self end))
end
function CDOTABaseAbility:OrderAbilityNoTarget()
	return self:GetCaster():ExecuteOrder(DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, self, nil, false)
end
function CDOTABaseAbility:OrderAbilityOnPosition(position)
	return self:GetCaster():ExecuteOrder(DOTA_UNIT_ORDER_CAST_POSITION, nil, self, position, false)
end
function CDOTABaseAbility:OrderAbilityOnTarget(target)
	return self:GetCaster():ExecuteOrder(DOTA_UNIT_ORDER_CAST_TARGET, target, self, target:GetAbsOrigin(), false)
end
function CDOTABaseAbility:OrderAbilityToggle()
	return self:GetCaster():ExecuteOrder(DOTA_UNIT_ORDER_CAST_TOGGLE, nil, self, nil, false)
end
function CDOTABaseAbility:OrderAbility(target)
	return self:GetCaster():ExecuteOrder(BehaviorToOrder(self:GetMainBehavior()), target, self, target ~= nil and target:GetAbsOrigin(), false)
end
function CDOTABaseAbility:SetToggleState(enabled)
	if self:GetToggleState() then
		if not enabled then
			self:ToggleAbility()
		end
	else
		if enabled then
			self:ToggleAbility()
		end
	end
end
function CDOTABaseAbility:SetAutoCastState(enabled)
	if self:GetAutoCastState() then
		if not enabled then
			self:ToggleAutoCast()
		end
	else
		if enabled then
			self:ToggleAutoCast()
		end
	end
end

-- Modifiers
function CDOTA_Buff:LinkModifier(modifier, modifier_data)
	self.link = modifier
	self.linked = {caster = modifier:GetCaster(), ability = modifier:GetAbility(), name = modifier:GetName(), data = table.merge({duration = modifier:GetDuration()}, modifier_data)}
	Timers:CreateTimer({endTime = FrameTime(), callback = function()
		if not self or self:IsNull() then return end
		if self.linked ~= nil then
			self.link = self.link ~= nil and not self.link:IsNull() and self.link or self:GetParent():AddNewModifier(self.linked["caster"], self.linked["ability"], self.linked["name"], self.linked["data"])
			if self.link and not self.link:IsNull() and self.link:GetRemainingTime() ~= self:GetRemainingTime() then
				self.link:SetDuration(self:GetRemainingTime(), true)
			end
			return 0.05
		end
	end}, nil, self)
end
function CDOTA_Buff:UnlinkModifier(save)
	self.linked = nil
	if self.link and not self.link:IsNull() and not save then
		self.link:Destroy()
	end
	self.link = nil
end
function CDOTA_Buff:OnDestroyLink()
	self:UnlinkModifier()
end
function CDOTA_Buff:is_highest()
	local mods = self:GetParent():FindAllModifiersByName(self:GetName())
	table.sort(mods, function(a, b)
		return a:GetPriority() < b:GetPriority() or a:GetCreationTime() > b:GetCreationTime()
	end)
	return mods[1] == self or mods[1] == nil
end
function CDOTA_Buff:destroy_other_me()
	for _, mod in pairs(self:GetParent():FindAllModifiersByName(self:GetName())) do
		if mod ~= self and mod:GetAbility() == self:GetAbility() then
			mod:Destroy()
		end
	end
end

-- Global
function GetLocalPlayerID()
	return Entities:GetLocalPlayer():GetPlayerID()
end

-- GameRules
function CDOTAGameRules:PingAtMinimap(team, point, ping_type, color)
	local ping = ping_type or 0
	GameRules:ExecuteTeamPing(team, point.x, point.y, nil, ping)
	local fx
	if ping == 0 then
		fx = ParticleManager:CreateParticleForTeam("particles/ui_mouseactions/ping_world.vpcf", PATTACH_WORLDORIGIN, nil, team)
	end
	ParticleManager:SetParticleControl(fx, 0, point)
	if color then ParticleManager:SetParticleControl(fx, 1, Vector(color[1], color[2], color[3])) end
	ParticleManager:ReleaseParticleIndex(fx)
end
function CDOTAGameRules:PingAtMinimapAll(point, ping_type, color)
	for _, team in pairs(TEAMS) do
		GameRules:PingAtMinimap(team, point, ping_type, color)
	end
end
function CDOTAGameRules:StartDay()
	return GameRules:SetTimeOfDay(0.25)
end
function CDOTAGameRules:StartNight()
	return GameRules:SetTimeOfDay(0.75)
end

-- GridNav
function GridNav:IsLocationVisibleForAnyTeam(vLocation)
	for _, team in pairs(PlayerResource:GetTeams()) do
		if IsLocationVisible(team, vLocation) then
			return true
		end
	end
	return false
end