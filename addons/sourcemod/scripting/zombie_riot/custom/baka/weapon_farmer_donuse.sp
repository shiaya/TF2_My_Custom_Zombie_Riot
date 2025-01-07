#pragma semicolon 1
#pragma newdecls required

static int Farmer_Stack[MAXTF2PLAYERS];
static int SDrain_Stack[MAXTF2PLAYERS];
static int Farmer_MaxStack[MAXTF2PLAYERS];
static int Farmer_UseStack[MAXTF2PLAYERS];
static int Farmer_WeaponPap[MAXTF2PLAYERS];
static float Farmer_StacktoDMG[MAXTF2PLAYERS];
static float Farmer_StacktoResist[MAXTF2PLAYERS];
static Handle FarmerTimer[MAXTF2PLAYERS];
static float FarmerHUDDelay[MAXTF2PLAYERS];
static float SDrain_Delay[MAXTF2PLAYERS];
static bool FarmerActivate[MAXTF2PLAYERS];
static bool FarmerAoEActivate[MAXTF2PLAYERS];
static int FarmerWeaponDelete[MAXTF2PLAYERS];
static float Farmer_Raged[MAXTF2PLAYERS];
static float Farmer_Melee[MAXTF2PLAYERS];
static float Farmer_DMG[MAXTF2PLAYERS];
static float Farmer_AoEDelay[MAXTF2PLAYERS];
static bool Farmer_AoEOn[MAXTF2PLAYERS];

public void Farmer_OnMapStart()
{
	Zero(Farmer_Stack);
	Zero(SDrain_Stack);
	Zero(Farmer_MaxStack);
	Zero(Farmer_UseStack);
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
	if(!FarmerActivate[client] && !FarmerAoEActivate[client] && Farmer_Stack[client])
	{
		float Pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", Pos);
		Farmer_UseStack[client]=Farmer_Stack[client];
		FakeClientCommandEx(client, "voicemenu 2 1");
		EmitSoundToAll("items/powerup_pickup_strength.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, Pos);
		int weapon_new = Store_GiveSpecificItem(client, "Soul Drain");
		FarmerWeaponDelete[client] = EntIndexToEntRef(weapon_new);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon_new);
		ViewChange_Switch(client, weapon_new, "tf_weapon_sword");
		if(Farmer_WeaponPap[client]>0)
			Attributes_SetMulti(weapon_new, 8, 1.0+(float(Farmer_WeaponPap[client])*0.8));
		Attributes_SetMulti(weapon_new, 8, 1.0+(float(Farmer_Stack[client])*Farmer_StacktoDMG[client]));
		if(IsValidEntity(weapon))
		{
			Farmer_Raged[client]=Attributes_Get(weapon, 205, 1.0);
			Farmer_Melee[client]=Attributes_Get(weapon, 206, 1.0);
			Farmer_DMG[client]=Attributes_Get(weapon, 2, 1.0);
			Attributes_SetMulti(weapon_new, 205, Farmer_Raged[client]);
			Attributes_SetMulti(weapon_new, 206, Farmer_Melee[client]);
			Attributes_SetMulti(weapon, 205, 1.0-(float(Farmer_Stack[client])*Farmer_StacktoResist[client]));
			Attributes_SetMulti(weapon, 206, 1.0-(float(Farmer_Stack[client])*Farmer_StacktoResist[client]));
			Attributes_SetMulti(weapon, 2, 1.0+(float(Farmer_Stack[client])*Farmer_StacktoDMG[client]));
		}
		Attributes_SetMulti(weapon_new, 205, 1.0-(float(Farmer_Stack[client])*Farmer_StacktoResist[client]));
		Attributes_SetMulti(weapon_new, 206, 1.0-(float(Farmer_Stack[client])*Farmer_StacktoResist[client]));
		SetAmmo(client, 22, 99999);
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
	if(!FarmerActivate[client] && Farmer_Stack[client])
	{
		FarmerAoEActivate[client] = !FarmerAoEActivate[client];
		if(FarmerAoEActivate[client])
		{
			float Pos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Pos);
			EmitSoundToAll("weapons/bumper_car_hit_ghost.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, Pos);
			Farmer_UseStack[client]=0;
			Farmer_Stack[client]--;
			int color[4];
			color = {47, 145, 134, 200};
			TE_SetupBeamRingPoint(Pos, 0.5, 500.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
			TE_SendToAll();
			Farmer_AoEDelay[client]=GetGameTime() + 1.0;
			CreateTimer(0.1, Timer_Farmer_AoE_Activated, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		else
		{
			Rogue_OnAbilityUse(client, weapon);
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
		if(FarmerActivate[client] || !FarmerAoEActivate[client] || Farmer_Stack[client]<0)
		{
			Farmer_Stack[client]=0;
			Farmer_UseStack[client]=0;
			Farmer_AoEOn[client]=false;
			FarmerAoEActivate[client]=false;
			return Plugin_Stop;
		}
		float clientpos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientpos);
		if(Farmer_AoEDelay[client] < GetGameTime())
		{
			Farmer_AoEOn[client]=true;
			Farmer_UseStack[client]++;
			Farmer_Stack[client]-=Farmer_UseStack[client];
			float entitypos[3], distance;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(clientpos, entitypos);
					if(distance<500.0)
					{
						float MaxHealth = float(ReturnEntityMaxHealth(entity));
						float damage=(b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] ? 0.1 : 1.0)*((MaxHealth*0.05)+(float(Farmer_WeaponPap[client])*1000.0));
						SDKHooks_TakeDamage(entity, client, client, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
					}
				}
			}
			Farmer_AoEDelay[client]=GetGameTime() + 1.0;
		}
		if(Farmer_AoEOn[client])
		{
			int color[4];
			color = {47, 145, 134, 200};
			TE_SetupBeamRingPoint(clientpos, 500.0, 500.5, g_BeamIndex_heal, -1, 0, 5, 0.1, 5.0, 1.0, color, 0, 0);
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
			Store_RemoveSpecificItem(client, "Soul Drain");
			int WaveEndUrWeaponIsGone = EntRefToEntIndex(FarmerWeaponDelete[client]);
			if(IsValidEntity(WaveEndUrWeaponIsGone))
				TF2_RemoveItem(client, WaveEndUrWeaponIsGone);
			FakeClientCommand(client, "use tf_weapon_sword");
			Store_ApplyAttribs(client);
			Store_GiveAll(client, GetClientHealth(client));
			FakeClientCommand(client, "use tf_weapon_sword");
			int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
			if(IsValidEntity(melee))
			{
				Attributes_Set(melee, 205, Farmer_Raged[client]);
				Attributes_Set(melee, 206, Farmer_Melee[client]);
				Attributes_Set(melee, 2, Farmer_DMG[client]);
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
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon) && (i_CustomWeaponEquipLogic[weapon]!=WEAPON_FARMER && GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary)!=weapon && GetPlayerWeaponSlot(client, TFWeaponSlot_Melee)!=weapon))
	{
		FarmerTimer[client] = null;
		return Plugin_Stop;
	}
	//425: 스택당 피해량 / 426: 스택당 저항 / 401: 최대 스택 저장량 / 391: 팩업 진행상황
	int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(IsValidEntity(melee) && i_CustomWeaponEquipLogic[weapon]==WEAPON_FARMER)
	{
		Farmer_WeaponPap[client] = RoundToFloor(Attributes_Get(melee, 391, 0.0));
		Farmer_StacktoDMG[client] = Attributes_Get(melee, 425, 0.0);
		Farmer_StacktoResist[client] = Attributes_Get(melee, 426, 0.0);
		Farmer_MaxStack[client] = RoundToFloor(Attributes_Get(melee, 401, 0.0));
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
	if(!FarmerActivate[attacker] && Farmer_UseStack[attacker]<1)
		return;
	/*float DMGBuff=damage;
	DMGBuff*=1.0+(float(Farmer_UseStack[attacker])*Farmer_StacktoDMG[attacker]);
	damage=DMGBuff;*/
	float StackDelay = Attributes_Get(weapon, 249, 0.0);
	if(SDrain_Delay[attacker] < GetGameTime() && FarmerActivate[attacker] && StackDelay > 0.0)
	{
		SDrain_Stack[attacker]++;
		SDrain_Delay[attacker] = GetGameTime() + StackDelay;
	}
}

public void Famrmer_PlayerTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(attacker) || GetTeam(attacker) == TFTeam_Red)
		return;
	if(!IsValidClient(victim))
		return;
	if(!FarmerActivate[victim] && Farmer_UseStack[victim]<1)
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
		Farmer_Stack[attacker]+=2;
}