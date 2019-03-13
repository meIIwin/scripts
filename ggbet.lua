local Nyx = {}

Nyx.Enabled = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Enabled", false)
Nyx.Key = Menu.AddKeyOption({"Hero Specific", "Nyx Assassin"}, "Combo Key", Enum.ButtonCode.KEY_V)
Nyx.Dagon = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Dagon", false)
Nyx.Urn = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Urn or Spirit Vessel", false)
Nyx.EtherealBlade = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Ethereal Blade", false)
Nyx.ShivaGuard = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Shivas Guard", false)
Nyx.Impale = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Impale")
Nyx.ManaBurn = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Mana Burn")
Nyx.SpikedCarapace = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Spiked Carapace")
Nyx.Vendetta = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Vendetta")
Nyx.autoImpale = Menu.AddOptionBool({"Hero Specific", "Nyx Assassin"}, "Auto Impale")

local enemy = nil
local myHero = nil

local dagon
local urn
local etherealblade
local shivaguard

Nyx.lastTick = 0

local impale
local manaburn
local spikedcarapace
local vendetta

local sleep_after_cast = 0
local sleep_after_attack = 0 



function Nyx.OnUpdate()
    if not Menu.IsEnabled(Nyx.Enabled) or not Engine.IsInGame() or not Heroes.GetLocal() then return end
	    myHero = Heroes.GetLocal()
		if NPC.GetUnitName(myHero) ~= "npc_dota_hero_nyx_assassin" then return end
	    if not Entity.IsAlive(myHero) or NPC.ISstunned(myHero) or NPC.IsSilenced(myHero) then return end
		if Menu.IsKeyDown(Nyx.Key) then
		         enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
	             if enemy and enemy~= 0 then
				         Nyx.Combo(myHero, enemy)
						 return
			     end
		end
end

function Nyx.Combo(myHero, enemy)

     impale = NPC.GetAbility(myHero, "nyx_assassin_impale")
     burn = NPC.GetAbility(myHero, "nyx_assassin_mana_burn")
     spiked = NPC.GetAbility(myHero, "nyx_assassin_spiked_carapace")
	 
	 dagon = NPC.GetItem(myHero,"item_dagon") 
	 urn = NPC.GetItem(myHero,"item_urn_of_shadows")
    if not urn then
        urn = NPC.GetItem(myHero, "item_spirit_vessel")
    end
	 blade = NPC.GetItem(myHero, "item_ethereal_blade")
	 shiva = NPC.GetItem(myHero, "item_shivas_guard")
	 
	 local myMana = NPC.GetMana(myHero)
	 
	 
	 if Menu.IsKeyDown(Nyx.Key) and Entity.GetHealth(enemy) > 0 then  
	     if not NPC.IsEntityInRange(myHero, enemy, 1500) then return end
		 local enemy_origin = Entity.GetAbsOrigin(enemy)
		 local cursor_pos = Input.GetWorldCursorPos()
	     if (cursor_pos - enemy_origin):Length2D() > Menu.GetValue(Nyx.NearestTarget) then enemy = nil return end
	     
		 if impale and Ability.IsCastable(impale, myMana) and Menu.IsEnabled(Nyx.Impale) then
		     Ability.CastPosition(impale, enemy_origin)
			 Nyx.lastTick = os.clock()
	     end
			 
		 if urn and Ability.IsReady(urn) and Menu.IsEnabled(Nyx.Urn) then
            Ability.CastTarget(urn, enemy)
         end
		 
		 if blade and Ability.IsReady(blade, myMana) and Menu.IsEnabled(Nyx.Blade) then
            Ability.CastTarget(blade, enemy)
         end
		 
		 if dagon and Ability.IsReady(dagon, myMana) and Menu.IsEnabled(Nyx.Dagon) then
		     Ability.CastTarget(dagon, enemy)
		 end
		 
		  if shiva and Ability.IsReady(shiva, myMana) and Menu.IsEnabled(Nyx.Shiva) then
            Ability.CastNoTarget(shiva)
        end
    end
end


function Nyx.Impale()
    local myHero = Heroes.GetLocal()
    if not myHero or not Nyx.IsSuitableToCastSpell(myHero) then return end

    local spell = NPC.GetAbility(myHero, "nyx_assassin_impale")
    if not spell or not Ability.IsCastable(spell, NPC.GetMana(myHero)) then return end
    local range = Ability.GetCastRange(spell)
    local speed = 1600

    for i = 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        if enemy and not NPC.IsIllusion(enemy) and not Entity.IsSameTeam(myHero, enemy)
        and Utility.CanCastSpellOn(enemy) and NPC.IsEntityInRange(myHero, enemy, range) then

            -- spike the enemy who is channelling a spell or TPing
            if Utility.IsChannellingAbility(enemy) then
                Ability.CastPosition(spell, Entity.GetAbsOrigin(enemy))
                return
            end

            -- spike the enemy who is being stunned or hexed with proper timing
            local dis = (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Length()
            local delay = 0.3 + dis/speed
            if (Utility.GetHexTimeLeft(enemy) - 0.1 < delay and delay < Utility.GetHexTimeLeft(enemy) + 0.1)
            or (Utility.GetStunTimeLeft(enemy) - 0.1 < delay and delay < Utility.GetStunTimeLeft(enemy) + 0.1) then
                Ability.CastPosition(spell, Utility.GetPredictedPosition(enemy, delay))
                return
            end
        end
    end
end



return Nyx



