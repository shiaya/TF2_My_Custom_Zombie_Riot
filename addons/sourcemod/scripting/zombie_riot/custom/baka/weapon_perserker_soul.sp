#pragma semicolon 1
#pragma newdecls required

static Handle PerserkerTimer[MAXTF2PLAYERS];
static float Perserker_HUDelay[MAXTF2PLAYERS];
static float Perserker_Energy[MAXTF2PLAYERS];
static float Perserker_Energy_Max[MAXTF2PLAYERS];
static float Perserker_Ash_Time[MAXTF2PLAYERS];
static float Perserker_Add_Time[MAXTF2PLAYERS];
static int Perserker_WeaponPap[MAXTF2PLAYERS];
static bool Perserker_Ash[MAXTF2PLAYERS];
static bool Perserker_Manual[MAXTF2PLAYERS];
static float Perserker_Rage_Attack[MAXTF2PLAYERS];

static int ScrapMiner_CurrencyBonus[MAXTF2PLAYERS];
static int ScrapMiner_MetalBonus[MAXTF2PLAYERS];
static int ScrapMiner_Backpack[MAXTF2PLAYERS];
static int ScrapMiner_BackpackMax[MAXTF2PLAYERS];
static float ScrapMiner_Delay[MAXTF2PLAYERS];

static char gLaser1;
static char gRedPoint;

public void Perserker_OnMapStart()
{
	Zero(Perserker_Energy);
	Zero(Perserker_Energy_Max);
	Zero(Perserker_HUDelay);
	Zero(PerserkerTimer);
	Zero(Perserker_WeaponPap);
	Zero(Perserker_Ash);
	Zero(Perserker_Manual);
	Zero(Perserker_Rage_Attack);
	Zero(ScrapMiner_CurrencyBonus);
	Zero(ScrapMiner_MetalBonus);
	Zero(ScrapMiner_Backpack);
	Zero(ScrapMiner_BackpackMax);
	Zero(ScrapMiner_Delay);
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gRedPoint = PrecacheModel("sprites/redglow1.vmt");
}

public void Perserker_AltAttack(int client, int weapon, bool &result, int slot)
{
	if(Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		if(dieingstate[client] > 0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Alive");
			return;
		}
		if(!Perserker_Ash[client] && Perserker_Energy[client] >= Perserker_Energy_Max[client])
		{
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, Attributes_Get(weapon, 249, 120.0));
			Perserker_Energy[client]=0.0;
			Perserker_Ash[client]=true;
			Perserker_Manual[client]=true;
			FakeClientCommandEx(client, "voicemenu 2 1");
			static float EntLoc[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
			SpawnSmallExplosion(EntLoc);	
			int particle_power = ParticleEffectAt(EntLoc, "utaunt_poweraura_teamcolor_red", Perserker_Add_Time[client]);
			SetParent(client, particle_power);
			Perserker_Ash_Time[client]=GetGameTime() + Perserker_Add_Time[client];
			ApplyTempAttrib(weapon, 6, 0.8, Perserker_Add_Time[client]);
			ApplyTempAttrib(weapon, 2, 2.0, Perserker_Add_Time[client]);
			ApplyTempAttrib(weapon, 134, 2.0, Perserker_Add_Time[client]);
			TF2_RemoveCondition(client, TFCond_CritCanteen);
			TF2_AddCondition(client, TFCond_CritCanteen, Perserker_Add_Time[client]);
			TF2_RemoveCondition(client, TFCond_SpeedBuffAlly);
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, Perserker_Add_Time[client]);
			CreateTimer(0.1, Timer_Ash_Activated, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Not enough energy");
			return;
		}
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

public void ScrapMiner_AltAttack(int client, int weapon, bool &result, int slot)
{
	if(Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		if(dieingstate[client] > 0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Alive");
			return;
		}
		if(ScrapMiner_Backpack[client]>0)
		{
			int target = GetAimPlayer(client, 150.0, 20.0);
			if(!IsValidClient(target))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Player not detected");
				return;
			}
			if(dieingstate[target] > 0 || target==client || GetTeam(target) != TFTeam_Red)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Alive");
				return;
			}
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, Perserker_WeaponPap[client]>=5 ? 45.0 : 30.0);
			char name[32];
			GetClientName(target, name, sizeof(name));
			ClientCommand(target, "playgamesound ui/item_metal_scrap_pickup.wav");
			ClientCommand(client, "playgamesound mvm/mvm_money_pickup.wav");
			if(Perserker_WeaponPap[client]>=6)
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "\"%s\" used the Ender Pouch on .", name);
				GetClientName(client, name, sizeof(name));
				SetDefaultHudPosition(target);
				SetGlobalTransTarget(target);
				ShowSyncHudText(target,  SyncHud_Notifaction, "\"%s\" used an Ender Pouch on you.", name);
				ScrapMiner_BackpackMax[client]=target;
				return;
			}
			else
			{
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "Gave Scrap to \"%s\".", name);
				GetClientName(client, name, sizeof(name));
				SetDefaultHudPosition(target);
				SetGlobalTransTarget(target);
				ShowSyncHudText(target,  SyncHud_Notifaction, "\"%s\" Gave you a Scrap.", name);
			}
			int cash = RoundToFloor(((float(ScrapMiner_Backpack[client])/2)*float(ScrapMiner_CurrencyBonus[client])));
			CashRecievedNonWave[client] += cash;
			CashSpent[client] -= cash;
			SetEntProp(target, Prop_Data, "m_iAmmo", GetEntProp(target, Prop_Data, "m_iAmmo", 4, 3)+ScrapMiner_Backpack[client], 4, 3);
			ScrapUsed(target, RoundToFloor(float(ScrapMiner_Backpack[client])/2.0), ScrapMiner_MetalBonus[client]);
			ScrapMiner_Backpack[client]=0;
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Not enough energy");
			return;
		}
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

public Action Timer_Ash_Activated(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		int color[4];
		float clientpos[3], position[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientpos);
		color = {145, 47, 47, 200};
		position[0] = clientpos[0];
		position[1] = clientpos[1];
		position[2] = clientpos[2] + 1500.0;
		TE_SetupBeamPoints(clientpos, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3);
		TE_SendToAll();
		position[2] -= 1490.0;
		TE_SetupGlowSprite(clientpos, gRedPoint, 1.0, 1.0, 255);
		TE_SendToAll();
		if(Perserker_Ash_Time[client] < GetGameTime())
		{
			Perserker_Ash[client]=false;
			Perserker_Manual[client]=false;
			SDKHooks_TakeDamage(client, 0, 0, float(GetClientHealth(client))*3.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			if(dieingstate[client] > 0 || !IsPlayerAlive(client))
				return Plugin_Stop;
		}
		return Plugin_Continue;	
	}
	else
	{
		return Plugin_Stop;	
	}
}

public void Perserker_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_PERSERKER)
	{
		delete PerserkerTimer[client];
		PerserkerTimer[client] = null;
		DataPack pack;
		PerserkerTimer[client] = CreateDataTimer(0.25, Timer_Perserker, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Perserker(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		PerserkerTimer[client] = null;
		return Plugin_Stop;
	}
	int Active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(Active) && Active==weapon && i_CustomWeaponEquipLogic[weapon]==WEAPON_PERSERKER)
	{
		Perserker_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		if(Perserker_WeaponPap[client]>1 && Perserker_WeaponPap[client]<=3)
		{
			Perserker_Energy_Max[client]=Attributes_Get(weapon, 171, 1000.0);
			Perserker_Add_Time[client]=Attributes_Get(weapon, 73, 5.0);
			if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
			{
				if(Perserker_Energy[client] < Perserker_Energy_Max[client] && Perserker_WeaponPap[client]>=3)Perserker_Energy[client] += 0.2;
				if(Perserker_Energy[client] > Perserker_Energy_Max[client])Perserker_Energy[client] = Perserker_Energy_Max[client];
				if(Perserker_HUDelay[client] < GetGameTime())
				{
					PrintHintText(client, "Rage [%i％]", RoundToFloor(Perserker_Energy[client]/Perserker_Energy_Max[client]*100.0));
					StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
					Perserker_HUDelay[client] = GetGameTime() + 0.5;
				}
			}
			else Perserker_Energy[client]=0.0;
			ScrapMiner_BackpackMax[client]=0;
			ScrapMiner_Backpack[client]=0;
		}
		else if(Perserker_WeaponPap[client]>=6)
		{
			ScrapMiner_CurrencyBonus[client]=RoundToFloor(Attributes_Get(weapon, 325, 1.0));
			ScrapMiner_MetalBonus[client]=RoundToFloor(Attributes_Get(weapon, 425, 15.0));
			ScrapMiner_Backpack[client]=6;
			int target = ScrapMiner_BackpackMax[client];
			if(IsValidClient(target))
			{
				if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
				{
					char name[32];
					GetClientName(target, name, sizeof(name));
					if(Perserker_HUDelay[client] < GetGameTime())
					{
						PrintHintText(client, "Ender Pouch [%s]", name);
						StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
						Perserker_HUDelay[client] = GetGameTime() + 0.5;
					}
				}
			}
			Perserker_Energy[client]=0.0;
		}
		else if(Perserker_WeaponPap[client]>=4 && Perserker_WeaponPap[client]<=5)
		{
			ScrapMiner_CurrencyBonus[client]=RoundToFloor(Attributes_Get(weapon, 325, 1.0));
			ScrapMiner_MetalBonus[client]=RoundToFloor(Attributes_Get(weapon, 425, 15.0));
			ScrapMiner_BackpackMax[client]=RoundToFloor(Attributes_Get(weapon, 429, 300.0));
			if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
			{
				if(ScrapMiner_Backpack[client] > ScrapMiner_BackpackMax[client])ScrapMiner_Backpack[client] = ScrapMiner_BackpackMax[client];
				if(ScrapMiner_Backpack[client] < 0)ScrapMiner_Backpack[client] = 0;
				if(Perserker_HUDelay[client] < GetGameTime())
				{
					PrintHintText(client, "Scrap [%i / %i]\n Cash [+%i]", ScrapMiner_Backpack[client], ScrapMiner_BackpackMax[client], RoundToFloor((float(ScrapMiner_Backpack[client])/2.0)*float(ScrapMiner_CurrencyBonus[client])));
					StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
					Perserker_HUDelay[client] = GetGameTime() + 0.5;
				}
			}
			Perserker_Energy[client]=0.0;
		}
	}
	return Plugin_Continue;
}

public void Perserker_NPCTakeDamage(int victim, int attacker, float &damage, int &damagetype, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	if(Perserker_WeaponPap[attacker]>=1 && Perserker_WeaponPap[attacker]<=3)
	{
		bool Crit=false, MiniCrit=false;
		int health = GetClientHealth(attacker), maxhealth = SDKCall_GetMaxHealth(attacker);
		float DMGBuff;
		DMGBuff = float(health-maxhealth);
		if(health<RoundToFloor(float(maxhealth)*0.75))
		{
			DMGBuff *= 1.25;
		}
		if(health<RoundToFloor(float(maxhealth)*0.5))
		{
			DMGBuff *= 1.5;
			MiniCrit=true;
		}
		if(health<RoundToFloor(float(maxhealth)*0.25))
			DMGBuff *= 2.0;
		if(health<RoundToFloor(float(maxhealth)*0.1))
			DMGBuff *= 3.0;
		damage+=(DMGBuff+maxhealth);
		damage*=(Perserker_Manual[attacker] ? 1.25 : 1.0);
		if(Perserker_Rage_Attack[attacker]>0.0 && (damagetype | DMG_TRUEDAMAGE))
		{
			Handle AttackPack;
			CreateDataTimer(0.01, Timer_Delay_Attack, AttackPack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(AttackPack, Perserker_Rage_Attack[attacker]*0.5);
			WritePackCell(AttackPack, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			WritePackCell(AttackPack, victim);
			WritePackCell(AttackPack, attacker);
			Perserker_Rage_Attack[attacker]=0.0;
			Crit=true;
		}
		
		if(Crit || MiniCrit)
			DisplayCritAboveNpc(victim, attacker, true, _, _, Crit);
		return;
	}
	if(Perserker_WeaponPap[attacker]>=6 && TeutonType[attacker] == TEUTON_NONE)
	{
		float DMGNerf;
		DMGNerf = float(Waves_GetRound()+1);
		if(DMGNerf > 15)
			DMGNerf *= 25.0;
		else if(DMGNerf < 30)
			DMGNerf *= 50.0;
		else if(DMGNerf < 45)
			DMGNerf *= 75.0;
		else
			DMGNerf *= 100.0;
		int target = ScrapMiner_BackpackMax[attacker];
		if(!Waves_InSetup() && IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
		{
			float ScrapNerf = float(ScrapMiner_MetalBonus[attacker])/3.0;
			int cash = RoundToFloor(((ScrapNerf/2)*float(ScrapMiner_CurrencyBonus[attacker])));
			CashRecievedNonWave[attacker] += cash;
			CashSpent[attacker] -= cash;
			SetEntProp(target, Prop_Data, "m_iAmmo", GetEntProp(target, Prop_Data, "m_iAmmo", 4, 3)+ScrapNerf, 4, 3);
			ScrapUsed(target, RoundToFloor(ScrapNerf/2.0), ScrapMiner_MetalBonus[attacker]);
			if(b_Box_Office[attacker])
			{
				CashRecievedNonWave[attacker] += 1;
				CashSpent[attacker] -= 1;
			}
		}
		if(damage-DMGNerf > 2500.0 && Waves_GetRound()+1 > 15)
			damage-=DMGNerf;
		return;
	}
	else if(Perserker_WeaponPap[attacker]>=4 && Perserker_WeaponPap[attacker]<=5
	&& ScrapMiner_Backpack[attacker] < ScrapMiner_BackpackMax[attacker] && TeutonType[attacker] == TEUTON_NONE)
	{
		float DMGNerf;
		DMGNerf = float(Waves_GetRound()+1);
		if(DMGNerf > 15)
			DMGNerf *= 25.0;
		else if(DMGNerf < 30)
			DMGNerf *= 50.0;
		else if(DMGNerf < 45)
			DMGNerf *= 75.0;
		else
			DMGNerf *= 100.0;
		ScrapMiner_Backpack[attacker] += RoundToFloor(float(ScrapMiner_MetalBonus[attacker])/3.0);
		if(b_Box_Office[attacker] && !Waves_InSetup())
		{
			CashRecievedNonWave[attacker] += 1;
			CashSpent[attacker] -= 1;
		}
		if(damage-DMGNerf > 2500.0 && Waves_GetRound()+1 > 15)
			damage-=DMGNerf;
		return;
	}
}

public void Perserker_PlayerTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(attacker) || GetTeam(attacker) == TFTeam_Red)
		return;
	if(!IsValidClient(victim))
		return;
	if(Perserker_WeaponPap[victim]>1 && Perserker_WeaponPap[victim]<=3)
	{
		int health = GetClientHealth(victim);
		if(!Perserker_Ash[victim])Perserker_Energy[victim] += damage;
		if(damage>Perserker_Rage_Attack[victim])Perserker_Rage_Attack[victim] = damage;
		if(damage>health && ((!Perserker_Ash[victim] && Perserker_Energy[victim] >= Perserker_Energy_Max[victim]) ||(Perserker_Ash[victim])))
		{
			if(!Perserker_Ash[victim])
			{
				FakeClientCommandEx(victim, "voicemenu 2 1");
				static float EntLoc[3];
				GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", EntLoc);
				SpawnSmallExplosion(EntLoc);
				int particle_power = ParticleEffectAt(EntLoc, "utaunt_poweraura_teamcolor_red", Perserker_Add_Time[victim]);
				SetParent(victim, particle_power);
				Perserker_Ash_Time[victim]=GetGameTime() + Perserker_Add_Time[victim];
				ApplyTempAttrib(weapon, 134, 2.0, Perserker_Add_Time[victim]);
				TF2_RemoveCondition(victim, TFCond_CritCanteen);
				TF2_AddCondition(victim, TFCond_CritCanteen, Perserker_Add_Time[victim]);
				TF2_RemoveCondition(victim, TFCond_SpeedBuffAlly);
				TF2_AddCondition(victim, TFCond_SpeedBuffAlly, Perserker_Add_Time[victim]);
				Perserker_Energy[victim]=0.0;
				Perserker_Ash[victim]=true;
				CreateTimer(0.1, Timer_Ash_Activated, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			}
			damage=0.0;
			SetEntityHealth(victim, 1);
		}
	}
	else if(Perserker_WeaponPap[victim]>=4 && Perserker_WeaponPap[victim]<=5 && ScrapMiner_Backpack[victim] > 0
	&& ScrapMiner_Delay[victim] < GetGameTime())
	{
		float victimpos[3], attackerpos[3], distance;
		GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimpos);
		GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", attackerpos);
		distance = GetVectorDistance(victimpos, attackerpos);
		if(distance<100.0)
			ScrapMiner_Backpack[victim] -= RoundToFloor(float(ScrapMiner_MetalBonus[victim]));
		else
			ScrapMiner_Backpack[victim] -= RoundToFloor(float(ScrapMiner_MetalBonus[victim])/2.0);
		ScrapMiner_Delay[victim]=GetGameTime() + 5.0;
	}
}

public int GetAimPlayer(int client, float fldist, float fpos)
{
	if(!IsValidClient(client))
		return -1;

	float vecClientEyePos[3], vecClientEyeAng[3];
	GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
	GetClientEyeAngles(client, vecClientEyeAng);	   // Get the angle the player is looking
	if(fpos<0.0)
		vecClientEyePos[2]+=FloatAbs(fpos);
	else
		vecClientEyePos[2]-=fpos;

	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, FilterPlayer, client);

	if(!TR_DidHit(INVALID_HANDLE))
		return -1;

	int TRIndex = TR_GetEntityIndex(INVALID_HANDLE);

	float TargetPos[3];
	TR_GetEndPosition(TargetPos);
	float distance = GetVectorDistance(vecClientEyePos, TargetPos);

	if(distance >= fldist)
		return -1;
	return TRIndex;
}

public bool FilterPlayer(int entity, int contentsMask, any data)
{
	return entity != data;
}

static bool ScrapUsed(int client, int AmmoScrap, int BarracksAmmount)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	int ie, weapon1;
	Barracks_TryRegenIfBuilding(client, float(AmmoScrap)/float(BarracksAmmount));
	while(TF2_GetItem(client, weapon1, ie))
	{
		if(IsValidEntity(weapon1))
		{
			int Ammo_type = GetEntProp(weapon1, Prop_Send, "m_iPrimaryAmmoType");
			if(Ammo_type > 0 && Ammo_type != Ammo_Potion_Supply && Ammo_type != Ammo_Hand_Grenade)
			{
				//found a weapon that has ammo.
				if(GetAmmo(client, Ammo_type) <= 0)
				{
					weapon = weapon1;
					break;
				}
			}
		}
	}

	if(IsValidEntity(weapon))
	{
		int Ammo_type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
		int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		if (i_WeaponAmmoAdjustable[weapon])
		{
			AddAmmoClient(client, i_WeaponAmmoAdjustable[weapon], AmmoScrap);
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}
			return true;
		}
		else if(weaponindex == 211 || weaponindex == 998)
		{
			AddAmmoClient(client, 21, AmmoScrap);
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}
			return true;
		}
		else if(weaponindex == 411)
		{
			AddAmmoClient(client, 22, AmmoScrap);
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}
			return true;
		}
		else if(weaponindex == 441 || weaponindex == 35)
		{
			AddAmmoClient(client, 23, AmmoScrap);
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}
			return true;
		}
		else if(AmmoBlacklist(Ammo_type) && i_OverrideWeaponSlot[weapon] != 2)
		{
			AddAmmoClient(client, Ammo_type, AmmoScrap);
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[client][i] = GetAmmo(client, i);
			}
			return true;
		}
	}
	return false;
}

public void Perserker_OnKill(int attacker)
{
	if(IsValidClient(attacker) && TeutonType[attacker] == TEUTON_NONE)
	{
		if(Perserker_WeaponPap[attacker]>=6)
		{
			int target = ScrapMiner_BackpackMax[attacker];
			if(!Waves_InSetup() && IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
			{
				float ScrapNerf = float(ScrapMiner_MetalBonus[attacker])/1.5;
				int cash = RoundToFloor(((ScrapNerf/2)*float(ScrapMiner_CurrencyBonus[attacker])));
				CashRecievedNonWave[attacker] += cash;
				CashSpent[attacker] -= cash;
				SetEntProp(target, Prop_Data, "m_iAmmo", GetEntProp(target, Prop_Data, "m_iAmmo", 4, 3)+ScrapNerf, 4, 3);
				ScrapUsed(target, RoundToFloor(ScrapNerf/2.0), ScrapMiner_MetalBonus[attacker]);
				if(b_Box_Office[attacker])
				{
					CashRecievedNonWave[attacker] += 1;
					CashSpent[attacker] -= 1;
				}
			}
			return;
		}
		else if(Perserker_WeaponPap[attacker]>=4 && Perserker_WeaponPap[attacker]<=5
		&& ScrapMiner_Backpack[attacker] < ScrapMiner_BackpackMax[attacker])
		{
			ScrapMiner_Backpack[attacker] += RoundToFloor(float(ScrapMiner_MetalBonus[attacker])/1.5);
			if(b_Box_Office[attacker] && !Waves_InSetup())
			{
				CashRecievedNonWave[attacker] += 1;
				CashSpent[attacker] -= 1;
			}
		}
	}
}