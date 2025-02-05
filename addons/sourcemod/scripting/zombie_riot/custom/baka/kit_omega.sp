#pragma semicolon 1
#pragma newdecls required

static Handle h_KitOmega_Timer[MAXTF2PLAYERS] = {null, ...};
static float f_KitOmega_HUDDelay[MAXTF2PLAYERS];
static int i_KitOmega_GunType[MAXTF2PLAYERS];
static int i_KitOmega_GunIndex[MAXTF2PLAYERS];
static int i_KitOmega_WeaponPap[MAXTF2PLAYERS];
static bool b_KitOmega_Toggle[MAXTF2PLAYERS];

public void KitOmega_OnMapStart()
{
	Zero(f_KitOmega_HUDDelay);
	Zero(i_KitOmega_WeaponPap);
	Zero(i_KitOmega_GunType);
	Zero(i_KitOmega_GunIndex);
	Zero(b_KitOmega_Toggle);
	PrecacheModel("models/entropyzero2/weapons/w_pulsepistol.mdl");
}

public void Enable_KitOmega(int client, int weapon)
{
	if(h_KitOmega_Timer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_OMEGA)
		{
			i_KitOmega_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			b_KitOmega_Toggle[client] = false;
			delete h_KitOmega_Timer[client];
			h_KitOmega_Timer[client] = null;
			DataPack pack;
			h_KitOmega_Timer[client] = CreateDataTimer(0.1, Timer_KitOmega, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_OMEGA)
		{
			i_KitOmega_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			b_KitOmega_Toggle[client] = false;
			DataPack pack;
			h_KitOmega_Timer[client] = CreateDataTimer(0.1, Timer_KitOmega, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
}

static Action Timer_KitOmega(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		int DeleteThisGun = EntRefToEntIndex(i_KitOmega_GunIndex[client]);
		if(IsValidEntity(DeleteThisGun))
			TF2_RemoveItem(client, DeleteThisGun);
		h_KitOmega_Timer[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	bool holding;
	if(weapon_holding == weapon)
	{
		holding=true;
	}
	else
		holding=false;
	KitOmega_Function(client, weapon, holding);
	KitOmega_HUD(client);

	return Plugin_Continue;
}

public void KitOmega_NPCTakeDamage(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if(i_KitOmega_WeaponPap[attacker]==1)
	{
		if(Items_HasNamedItem(attacker, "Major Steam's Rocket"))
		{
			ApplyStatusEffect(attacker, victim, "Cryo", 1.0);
			Elemental_AddCyroDamage(victim, attacker, RoundFloat(damage*0.65), 1);
		}
		else
		{
			ApplyStatusEffect(attacker, victim, "Freeze", 1.0);
			Elemental_AddCyroDamage(victim, attacker, RoundFloat(damage*0.5), 0);
		}
		if(NpcStats_IsEnemyTrueFrozen(victim) && f_TimeFrozenStill[victim] > GetGameTime(victim))
		{
			damage*=1.25;
			DisplayCritAboveNpc(victim, attacker, true, _, _, false);
		}
	}
}

static void KitOmega_Function(int client, int weapon, bool holding)
{

}

public void KitOmega_RKey(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		KitOmega_GUN_Selector_Function(client);
		Ability_Apply_Cooldown(client, slot, 0.6);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		return;
	}
}

static void KitOmega_GUN_Selector_Function(int client, int OverrideGunType=-1)
{
	int weapon_new=-1;
	float Time = GetGameTime(client);
	bool WeaponSwap=false;
	if(OverrideGunType<1)
		i_KitOmega_GunType[client]++;
	else
		i_KitOmega_GunType[client]=OverrideGunType;
	if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")!=GetPlayerWeaponSlot(client, TFWeaponSlot_Melee))
		WeaponSwap=true;
	switch(i_KitOmega_GunType[client])
	{
		case 1:
		{
			weapon_new=Store_GiveSpecificItem(client, "KitArsenals Gauss Pistol Default");
		}
		case 2:
		{
			weapon_new=Store_GiveSpecificItem(client, "KitArsenals Shotgun Default");
		}
		case 3:
		{
			weapon_new=Store_GiveSpecificItem(client, "KitArsenals AssaultRifle Default");
		}
		case 4:
		{
			weapon_new=Store_GiveSpecificItem(client, "KitArsenals MiniGun Default");
		}
		case 5:
		{
			weapon_new=Store_GiveSpecificItem(client, "KitArsenals GrenadeLauncher Default");
		}
		case 6:
		{
			weapon_new=Store_GiveSpecificItem(client, "KitArsenals Gauss Pistol Default");
			i_KitOmega_GunType[client]=1;
		}
	}
	int DeleteThisGun = EntRefToEntIndex(i_KitOmega_GunIndex[client]);
	if(IsValidEntity(DeleteThisGun))
		TF2_RemoveItem(client, DeleteThisGun);
	if(IsValidEntity(weapon_new))
	{
		if(WeaponSwap)
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon_new);
		SetEntPropFloat(weapon_new, Prop_Send, "m_flNextPrimaryAttack", Time+1.5);
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", Time+1.5);
		i_KitOmega_GunIndex[client] = EntIndexToEntRef(weapon_new);
	}
}

static void KitOmega_HUD(int client)
{
	if(f_KitOmega_HUDDelay[client] < GetGameTime())
	{
		/*char C_point_hints[512]="";
		
		Format(C_point_hints, sizeof(C_point_hints),
		"Shield: %1.f％", (float(i_KitOmega_Resistance[client])/1000.0)*100.0);
		if(Armor_Charge[client] < 1)
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor startup requires Armor!]", C_point_hints);
		}
		else if(Waves_InSetup() || i_KitOmega_Resistance[client]>=1000)
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor Idle Mode]", C_point_hints);
		}
		else if(f_KitOmega_Delay[client] > GetGameTime())
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor Restarting in %1.fs]", C_point_hints, (f_KitOmega_Delay[client]-GetGameTime()));
		else
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[", C_point_hints);
			for(int i=1; i<20; i++)
			{
				if(float(i_KitOmega_Recharging[client]) >= 30.0*(float(i)*0.05))
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_FULL);
				}
				else if(float(i_KitOmega_Recharging[client]) > 30.0*(float(i)*0.05 - 1.0/60.0))
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_PARTFULL);
				}
				else if(float(i_KitOmega_Recharging[client]) > 30.0*(float(i)*0.05 - 1.0/30.0))
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_PARTEMPTY);
				}
				else
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_EMPTY);
				}
			}
			Format(C_point_hints, sizeof(C_point_hints),
			"%s]", C_point_hints);
		}

		if(C_point_hints[0] != '\0')
		{
			PrintHintText(client,"%s", C_point_hints);
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			f_KitOmega_HUDDelay[client] = GetGameTime() + 0.5;
		}*/
	}
}
/*
static void Add_Chaos_ParticleEffect(int client)
{
	int entity = EntRefToEntIndex(Chaos_ParticleEffect_I[client]);
	if(!IsValidEntity(entity))
	{
		entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(IsValidEntity(entity))
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(entity, "eyes", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "unusual_smoking", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(entity, particle, "eyes", {5.0,0.0,0.0});
			Chaos_ParticleEffect_I[client] = EntIndexToEntRef(particle);
		}
	}
	entity = EntRefToEntIndex(Chaos_ParticleEffect_II[client]);
	if(!IsValidEntity(entity))
	{
		entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(IsValidEntity(entity))
		{
			float flPos[3];
			float flAng[3];
			GetAttachment(entity, "eyes", flPos, flAng);
			int particle = ParticleEffectAt(flPos, "unusual_psychic_eye_white_glow", 0.0);
			AddEntityToThirdPersonTransitMode(client, particle);
			SetParent(entity, particle, "eyes", {5.0,0.0,-20.0});
			Chaos_ParticleEffect_II[client] = EntIndexToEntRef(particle);
		}
	}
}

static void DestroyChaos_ParticleEffect(int client)
{
	int entity = EntRefToEntIndex(Chaos_ParticleEffect_I[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	Chaos_ParticleEffect_I[client] = INVALID_ENT_REFERENCE;
	entity = EntRefToEntIndex(Chaos_ParticleEffect_II[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	Chaos_ParticleEffect_II[client] = INVALID_ENT_REFERENCE;
}*/