#pragma semicolon 1
#pragma newdecls required

static Handle h_kitArsenals_Timer[MAXTF2PLAYERS] = {null, ...};
static float f_kitArsenals_HUDDelay[MAXTF2PLAYERS];
static int i_kitArsenals_GunType[MAXTF2PLAYERS];
static int i_kitArsenals_WeaponPap[MAXTF2PLAYERS];
static bool b_kitArsenals_Toggle[MAXTF2PLAYERS];

public void kitArsenals_OnMapStart()
{
	Zero(f_kitArsenals_HUDDelay);
	Zero(i_kitArsenals_WeaponPap);
	Zero(i_kitArsenals_GunType);
	Zero(b_kitArsenals_Toggle);
}

public void kitArsenals_WaveEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !b_IsPlayerABot[client])
			i_kitArsenals_Resistance[client]=1000;
	}
}

public void Enable_kitArsenals(int client, int weapon)
{
	if(h_TimerkitArsenals[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_kitArsenals)
		{
			i_kitArsenals_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			b_kitArsenals_Toggle[client] = false;
			delete h_TimerkitArsenals[client];
			h_TimerkitArsenals[client] = null;
			DataPack pack;
			h_TimerkitArsenals[client] = CreateDataTimer(0.1, Timer_kitArsenals, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_kitArsenals)
		{
			i_kitArsenals_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			b_kitArsenals_Toggle[client] = false;
			DataPack pack;
			h_TimerkitArsenals[client] = CreateDataTimer(0.1, Timer_kitArsenals, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
}

static Action Timer_kitArsenals(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerkitArsenals[client] = null;
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
	kitArsenals_Function(client, weapon, holding);
	kitArsenals_HUD(client, holding);

	return Plugin_Continue;
}

public void kitArsenals_NPCTakeDamage(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if(i_kitArsenals_WeaponPap[attacker]==1)
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

static void kitArsenals_Function(int client, int weapon, bool holding)
{
	if(Armor_Charge[client] < 1)
	{
		//none
	}
	else if(Waves_InSetup())
	{
		i_kitArsenals_Resistance[client]=1000;
	}
	else if(holding && f_kitArsenals_Delay[client] < GetGameTime())
	{
		i_kitArsenals_Recharging[client]+=(RaidbossIgnoreBuildingsLogic(1) ? 2 : 1);
		if(i_kitArsenals_Recharging[client]>30 && i_kitArsenals_Resistance[client]<1000)
		{
			i_kitArsenals_Recharging[client]=0;
			i_kitArsenals_Resistance[client]+=(i_kitArsenals_WeaponPap[client]==1 ? 50 : 25);
			if(i_kitArsenals_Resistance[client]>1000)
				i_kitArsenals_Resistance[client]=1000;
		}
	}
	else i_kitArsenals_Recharging[client]=0;
	
	if(IsValidEntity(weapon))
	{
		int RocketLoad = GetEntData(weapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
		if(holding && RocketLoad<=0 && !b_kitArsenals_Toggle[client] && (GetClientButtons(client) & IN_ATTACK))
		{
			if(!b_kitArsenals_Toggle[client])
			{
				b_kitArsenals_Toggle[client]=true;
				SDKUnhook(client, SDKHook_PreThink, kitArsenals_M1_PreThink);
				SDKHook(client, SDKHook_PreThink, kitArsenals_M1_PreThink);
			}
		}
	}
}

static void kitArsenals_M1_PreThink(int client)
{
	int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	if(h_TimerkitArsenals[client] != null && IsValidEntity(getweapon))
	{
		if(GetClientButtons(client) & IN_ATTACK)
		{
		}
		else
		{
			int RocketLoad = GetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
			int RockeyAmmo=GetAmmo(client, 8);
			int RocketAmmoMAX=(i_kitArsenals_WeaponPap[client]==1 ? 11 : 6);
			if(RocketLoad<RocketAmmoMAX)
			{
				SetAmmo(client, 8, RockeyAmmo+RocketLoad);
				SetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 0);
				Store_GiveAll(client, GetClientHealth(client));
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "You need to Reload by %i!", (i_kitArsenals_WeaponPap[client]==1 ? 11 : 6));
			}
			b_kitArsenals_Toggle[client]=false;
			SDKUnhook(client, SDKHook_PreThink, kitArsenals_M1_PreThink);
			return;
		}
	}
	else
	{
		b_kitArsenals_Toggle[client]=false;
		SDKUnhook(client, SDKHook_PreThink, kitArsenals_M1_PreThink);
		return;
	}
}

static void kitArsenals_HUD(int client)
{
	if(f_kitArsenals_HUDDelay[client] < GetGameTime())
	{
		char C_point_hints[512]="";
		
		Format(C_point_hints, sizeof(C_point_hints),
		"Shield: %1.f％", (float(i_kitArsenals_Resistance[client])/1000.0)*100.0);
		if(Armor_Charge[client] < 1)
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor startup requires Armor!]", C_point_hints);
		}
		else if(Waves_InSetup() || i_kitArsenals_Resistance[client]>=1000)
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor Idle Mode]", C_point_hints);
		}
		else if(f_kitArsenals_Delay[client] > GetGameTime())
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[Reactor Restarting in %1.fs]", C_point_hints, (f_kitArsenals_Delay[client]-GetGameTime()));
		else
		{
			Format(C_point_hints, sizeof(C_point_hints),
			"%s\n[", C_point_hints);
			for(int i=1; i<20; i++)
			{
				if(float(i_kitArsenals_Recharging[client]) >= 30.0*(float(i)*0.05))
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_FULL);
				}
				else if(float(i_kitArsenals_Recharging[client]) > 30.0*(float(i)*0.05 - 1.0/60.0))
				{
					Format(C_point_hints, sizeof(C_point_hints), "%s%s", C_point_hints, CHAR_PARTFULL);
				}
				else if(float(i_kitArsenals_Recharging[client]) > 30.0*(float(i)*0.05 - 1.0/30.0))
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
			f_kitArsenals_HUDDelay[client] = GetGameTime() + 0.5;
		}
	}
}

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
}