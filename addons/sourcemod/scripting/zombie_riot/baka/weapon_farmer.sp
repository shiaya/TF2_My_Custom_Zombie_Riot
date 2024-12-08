#pragma semicolon 1
#pragma newdecls required

static int Farmer_Stack[MAXTF2PLAYERS];
static int SDrain_Stack[MAXTF2PLAYERS];
static int Farmer_MaxStack[MAXTF2PLAYERS];
static int Farmer_UseStack[MAXTF2PLAYERS];
static int Farmer_AddStack[MAXTF2PLAYERS];
static int Farmer_WeaponPap[MAXTF2PLAYERS];
static float Farmer_StacktoDMG[MAXTF2PLAYERS];
static float Farmer_StacktoResist[MAXTF2PLAYERS];
static Handle FarmerTimer[MAXTF2PLAYERS];
static float FarmerHUDDelay[MAXTF2PLAYERS];
static float SDrain_Delay[MAXTF2PLAYERS];
static bool FarmerActivate[MAXTF2PLAYERS];
static bool FarmerAoEActivate[MAXTF2PLAYERS];

static float Farmer_Raged[MAXTF2PLAYERS];
static float Farmer_Melee[MAXTF2PLAYERS];
static float Farmer_DMG[MAXTF2PLAYERS];

static float SDrain_Raged[MAXTF2PLAYERS];
static float SDrain_Melee[MAXTF2PLAYERS];
static float SDrain_DMG[MAXTF2PLAYERS];

static float Farmer_AoEDelay[MAXTF2PLAYERS];
static bool Farmer_AoEOn[MAXTF2PLAYERS];

public void Farmer_OnMapStart()
{
	Zero(Farmer_Stack);
	Zero(SDrain_Stack);
	Zero(Farmer_MaxStack);
	Zero(Farmer_UseStack);
	Zero(Farmer_AddStack);
	Zero(Farmer_StacktoDMG);
	Zero(Farmer_StacktoResist);
	Zero(Farmer_WeaponPap);
	Zero(FarmerHUDDelay);
	Zero(SDrain_Delay);
	Zero(FarmerActivate);
	Zero(FarmerAoEActivate);
	Zero(Farmer_Raged);
	Zero(Farmer_Melee);
	Zero(Farmer_DMG);
	Zero(SDrain_Raged);
	Zero(SDrain_Melee);
	Zero(SDrain_DMG);
	Zero(Farmer_AoEDelay);
	Zero(Farmer_AoEOn);
	PrecacheSound("items/powerup_pickup_strength.wav");
	PrecacheSound("weapons/bumper_car_hit_ghost.wav");
}

void Farmer_WaveEnd()
{
	Zero(FarmerActivate);
	Zero(Farmer_UseStack);
}

public void Farmer_AltAttack(int client, int weapon, bool &result, int slot)
{
	if(dieingstate[client] <= 0 &&!FarmerActivate[client] && !FarmerAoEActivate[client] && Farmer_Stack[client])
	{
		float Pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", Pos);
		Farmer_UseStack[client]=Farmer_Stack[client];
		bool MAXSTACK;
		if(Farmer_UseStack[client] >= Farmer_MaxStack[client]) MAXSTACK=true;
		FakeClientCommandEx(client, "voicemenu 2 1");
		EmitSoundToAll("items/powerup_pickup_strength.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, Pos);
		int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if(IsValidEntity(melee) && IsValidEntity(secondary))
		{
			Farmer_Raged[client]=Attributes_Get(melee, 205, 1.0);
			Farmer_Melee[client]=Attributes_Get(melee, 206, 1.0);
			Farmer_DMG[client]=Attributes_Get(melee, 2, 1.0);
			
			SDrain_Raged[client]=Attributes_Get(secondary, 205, 1.0);
			SDrain_Melee[client]=Attributes_Get(secondary, 206, 1.0);
			SDrain_DMG[client]=Attributes_Get(secondary, 8, 1.0);
			
			Attributes_SetMulti(secondary, 8, (MAXSTACK ? 3.0 : 2.0)+(float(Farmer_WeaponPap[client])*0.5)+(float(Farmer_Stack[client])*Farmer_StacktoDMG[client]));
			Attributes_Set(secondary, 205, Farmer_Raged[client]);
			Attributes_Set(secondary, 206, Farmer_Melee[client]);
			Attributes_SetMulti(secondary, 205, 1.0-(float(Farmer_Stack[client])*Farmer_StacktoResist[client]));
			Attributes_SetMulti(secondary, 206, 1.0-(float(Farmer_Stack[client])*Farmer_StacktoResist[client]));
			
			Attributes_SetMulti(melee, 205, 1.0-(float(Farmer_Stack[client])*Farmer_StacktoResist[client]));
			Attributes_SetMulti(melee, 206, 1.0-(float(Farmer_Stack[client])*Farmer_StacktoResist[client]));
			Attributes_SetMulti(melee, 2, (MAXSTACK ? 3.0 : 2.0)+(float(Farmer_WeaponPap[client])*0.5)+(float(Farmer_Stack[client])*Farmer_StacktoDMG[client]));
		}
		FarmerActivate[client]=true;
		Farmer_Stack[client]=0;
		CreateTimer(0.1, Timer_Farmer_Activated, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability No Use");	
	}
}

public void Farmer_Reload(int client, int weapon, bool &result, int slot)
{
	if((Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue) && dieingstate[client] <= 0 && !FarmerActivate[client] && Farmer_Stack[client])
	{
		FarmerAoEActivate[client] = !FarmerAoEActivate[client];
		if(FarmerAoEActivate[client])
		{
			float Pos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Pos);
			EmitSoundToAll("weapons/bumper_car_hit_ghost.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, Pos);
			Farmer_UseStack[client]=0;
			Farmer_Stack[client]--;
			Farmer_AoEDelay[client]=GetGameTime() + 1.0;
			CreateTimer(0.1, Timer_Farmer_AoE_Activated, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		else
		{
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, 10.0);
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability No Use");	
	}
}

public Action Timer_Farmer_AoE_Activated(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		if(FarmerActivate[client] || !FarmerAoEActivate[client] || Farmer_Stack[client]<0 || dieingstate[client] > 0)
		{
			Farmer_UseStack[client]=0;
			Farmer_AoEOn[client]=false;
			FarmerAoEActivate[client]=false;
			return Plugin_Stop;
		}
		int color[4] = {47, 145, 134, 200};
		float clientpos[3], Range=1000.0;
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientpos);
		if(Farmer_AoEDelay[client] < GetGameTime())
		{
			Farmer_AoEOn[client]=true;
			Farmer_UseStack[client]++;
			Farmer_Stack[client]-=RoundToFloor(float(Farmer_UseStack[client])/3.0);
			float entitypos[3], distance;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(clientpos, entitypos);
					if(distance<(Range/2.0))
					{
						float MaxHealth = float(ReturnEntityMaxHealth(entity));
						float damage=(b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] ? 0.1 : 1.0)*((MaxHealth*0.05)+(500.0+(float(Farmer_WeaponPap[client])*1000.0)));
						NpcStats_SpeedModifyEnemy(entity, 1.0, 0.7, true);
						SDKHooks_TakeDamage(entity, client, client, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
					}
				}
			}
			Farmer_AoEDelay[client]=GetGameTime() + 1.0;
		}
		if(Farmer_AoEOn[client])
		{
			TE_SetupBeamRingPoint(clientpos, Range, Range+0.5, g_BeamIndex_heal, -1, 0, 5, 0.1, 5.0, 1.0, color, 0, 0);
			TE_SendToAll();
		}
		else
		{
			TE_SetupBeamRingPoint(clientpos, Range-(Range*(Farmer_AoEDelay[client]-GetGameTime())), Range-((Range*(Farmer_AoEDelay[client]-GetGameTime())))+0.5, g_BeamIndex_heal, -1, 0, 5, 0.1, 5.0, 1.0, color, 0, 0);
			TE_SendToAll();
		}
		return Plugin_Continue;
	}
	else return Plugin_Stop;
}

public Action Timer_Farmer_Activated(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		if(!FarmerActivate[client])
		{
			Farmer_Stack[client]=SDrain_Stack[client];
			int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
			int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			if(IsValidEntity(melee) && IsValidEntity(secondary))
			{
				Attributes_Set(melee, 205, Farmer_Raged[client]);
				Attributes_Set(melee, 206, Farmer_Melee[client]);
				Attributes_Set(melee, 2, Farmer_DMG[client]);
				
				Attributes_Set(secondary, 205, SDrain_Raged[client]);
				Attributes_Set(secondary, 206, SDrain_Melee[client]);
				Attributes_Set(secondary, 8, SDrain_DMG[client]);
			}
			SDrain_Stack[client]=0;
			return Plugin_Stop;	
		}
		return Plugin_Continue;
	}
	else return Plugin_Stop;
}

public void Farmer_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_FARMER)
	{
		delete FarmerTimer[client];
		FarmerTimer[client] = null;
		DataPack pack;
		FarmerTimer[client] = CreateDataTimer(0.25, Timer_Farmer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Farmer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		FarmerTimer[client] = null;
		return Plugin_Stop;
	}
	//425: 스택당 피해량 / 426: 스택당 저항 / 401: 최대 스택 저장량 / 391: 팩업 진행상황
	int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(i_CustomWeaponEquipLogic[melee]!=WEAPON_FARMER || i_CustomWeaponEquipLogic[secondary]!=WEAPON_FARMER)
	{
		FarmerTimer[client] = null;
		return Plugin_Stop;
	}
	if(IsValidEntity(secondary) && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")==secondary)
		SetAmmo(client, 22, 99999);
	else
		SetAmmo(client, 22, 1000);
	if(IsValidEntity(melee) && i_CustomWeaponEquipLogic[weapon]==WEAPON_FARMER)
	{
		Farmer_WeaponPap[client] = RoundToFloor(Attributes_Get(melee, 391, 0.0));
		Farmer_StacktoDMG[client] = Attributes_Get(melee, 425, 0.0);
		Farmer_StacktoResist[client] = Attributes_Get(melee, 426, 0.0);
		Farmer_MaxStack[client] = RoundToFloor(Attributes_Get(melee, 401, 0.0));
		Farmer_AddStack[client] = RoundToFloor(Attributes_Get(melee, 158, 1.0));
	}
	else
		Farmer_WeaponPap[client]=0;
	if(FarmerActivate[client])
		Farmer_Stack[client]=0;
	if(Farmer_Stack[client] > Farmer_MaxStack[client])Farmer_Stack[client] = Farmer_MaxStack[client];
	if(SDrain_Stack[client] > Farmer_MaxStack[client])SDrain_Stack[client] = Farmer_MaxStack[client];
	if(Farmer_Stack[client] < 0)Farmer_Stack[client] = 0;
	if(SDrain_Stack[client] < 0)SDrain_Stack[client] = 0;
	if(FarmerHUDDelay[client] < GetGameTime() && i_CustomWeaponEquipLogic[weapon]==WEAPON_FARMER)
	{
		if(FarmerActivate[client])
			PrintHintText(client, "Activate\nSoul[%i / %i]\nBuff DMG [+%i％]\nBuff Resist [+%i％]", SDrain_Stack[client], Farmer_MaxStack[client], RoundToFloor((float(Farmer_UseStack[client])*Farmer_StacktoDMG[client])*100.0), RoundToFloor((float(Farmer_UseStack[client])*Farmer_StacktoResist[client])*100.0));
		else
			PrintHintText(client, "Soul [%i / %i]\nBuff DMG [+%i％]\nBuff Resist [+%i％]", Farmer_Stack[client], Farmer_MaxStack[client], RoundToFloor((float(Farmer_Stack[client])*Farmer_StacktoDMG[client])*100.0), RoundToFloor((float(Farmer_Stack[client])*Farmer_StacktoResist[client])*100.0));
		StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
		FarmerHUDDelay[client] = GetGameTime() + 0.5;
	}
	return Plugin_Continue;
}

public void Famrmer_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	if(FarmerAoEActivate[attacker] && Farmer_UseStack[attacker]<1)
		return;
	/*float DMGBuff=damage;
	DMGBuff*=1.0+(float(Farmer_UseStack[attacker])*Farmer_StacktoDMG[attacker]);
	damage=DMGBuff;*/
	float StackDelay = Attributes_Get(weapon, 249, 0.0);
	if(SDrain_Delay[attacker] < GetGameTime() && StackDelay > 0.0)
	{
		if(FarmerActivate[attacker])
			SDrain_Stack[attacker]++;
		else
			Farmer_Stack[attacker]++;
		SDrain_Delay[attacker] = GetGameTime() + StackDelay;
	}
}

public void Famrmer_PlayerTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(attacker) || GetTeam(attacker) == TFTeam_Red)
		return;
	if(!IsValidClient(victim))
		return;
	if(!FarmerActivate[victim] && FarmerAoEActivate[victim] && Farmer_UseStack[victim]<1)
		return;
	float ResistBuff=damage;
	/*ResistBuff*=1.0-(float(Farmer_UseStack[victim])*Farmer_StacktoResist[victim]);*/
	if(b_thisNpcIsARaid[attacker] || b_thisNpcIsABoss[attacker])
		ResistBuff*=0.8;
	damage=ResistBuff;
}

void Famrmer_OnKill(int attacker)
{
	if(!FarmerAoEActivate[attacker] && !FarmerActivate[attacker])
		Farmer_Stack[attacker]+=Farmer_AddStack[attacker];
}