#pragma semicolon 1
#pragma newdecls required

static Handle MarketTimer[MAXTF2PLAYERS] = {null, ...};
static float MarketHUDDelay[MAXTF2PLAYERS];
static float Weapon_Energy[MAXTF2PLAYERS];
static float Weapon_Energy_Max[MAXTF2PLAYERS];
static float Temp_Launch_Power[3];
static float Power_Nerf[MAXENTITIES];
static int Market_WeaponPap[MAXTF2PLAYERS];
static bool Market_OnAttack[MAXTF2PLAYERS];
static int Market_AltAttackUse[MAXTF2PLAYERS];
static int Market_Perk[MAXTF2PLAYERS];

public void Market_Garden_OnMapStart()
{
	Zero(Weapon_Energy);
	Zero(Weapon_Energy_Max);
	Zero(Market_WeaponPap);
	Zero(Market_Perk);
	Zero(MarketHUDDelay);
	Zero(Market_OnAttack);
	Zero(Market_AltAttackUse);
	PrecacheSound("player/doubledonk.wav");
	PrecacheScriptSound("Passtime.BallSmack");
	PrecacheScriptSound("TFPlayer.AirBlastImpact");
}

public void Market_Gardener_Attack(int client, int weapon, bool &result, int slot)
{
	if(!Market_OnAttack[client]) Market_OnAttack[client]=true;
}

public void Market_Gardener_AltAttack(int client, int weapon, bool &result, int slot)
{
	int MaxCharger = (Market_Perk[client] == 3 ? 2 : 1);
	if(Market_AltAttackUse[client]<MaxCharger || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(client, weapon);
		if(!CvarInfiniteCash.BoolValue)Market_AltAttackUse[client]++;
		if(Market_AltAttackUse[client] > MaxCharger)Market_AltAttackUse[client]=MaxCharger;
		Temp_Launch_Power[0]=1000.0,Temp_Launch_Power[1]=800.0,Temp_Launch_Power[2]=1.0;
		FakeClientCommandEx(client, "voicemenu 2 1");
		RequestFrame(LaunchPlayer, client);
		TF2_AddCondition(client, TFCond_BlastJumping, 60.0, 0);
		EmitGameSoundToAll("Passtime.BallSmack", client);
		EmitGameSoundToAll("TFPlayer.AirBlastImpact", client);
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
	}
}

void LaunchPlayer(int client)
{
	float vVel[3], vVel2[3];
	float flMaxSpeed = GetEntPropFloat(client, Prop_Send, "m_flMaxspeed");
	float flJumpSpeed = Temp_Launch_Power[0];
	float flJumpHeight = Temp_Launch_Power[1];
	float flRatio = flJumpSpeed / flMaxSpeed;
	static float EntLoc[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
	SpawnSmallExplosion(EntLoc);
	
	ScaleVector(vVel, flRatio);  //This ensures all classes will have the same launch distance.
	
	/* Get the horizontal vectors */
	vVel2[0] = vVel[0];
	vVel2[1] = vVel[1];
	
	float flHorizontalSpeed = GetVectorLength(vVel2);
	if(flHorizontalSpeed > flJumpSpeed)
		ScaleVector(vVel, flJumpSpeed / flHorizontalSpeed);
	
	vVel[2] = flJumpHeight;
	if(GetEntityFlags(client) & FL_DUCKING)
	{
		ScaleVector(vVel, Temp_Launch_Power[2]);
		vVel[2] = flJumpHeight * Temp_Launch_Power[2];
	}
	
	if(vVel[2] < 300.0)	//Teleport the player up slightly to allow 'flJumpHeight' values lower than 300.0.
	{
		float vPos[3];
		GetClientAbsOrigin(client, vPos);
		vPos[2] += 20.0;
		SetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vPos);
	}
	
	SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);
}

public void MarketGardener_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(MarketTimer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_MARKET_GARDENER)
		{
			Market_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			Market_Perk[client]=i_CurrentEquippedPerk[client];
			delete MarketTimer[client];
			MarketTimer[client] = null;
			DataPack pack;
			MarketTimer[client] = CreateDataTimer(0.1, Timer_MarketGardener, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MARKET_GARDENER)
	{
		Market_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		Market_Perk[client]=i_CurrentEquippedPerk[client];
		DataPack pack;
		MarketTimer[client] = CreateDataTimer(0.1, Timer_MarketGardener, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_MarketGardener(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		MarketTimer[client] = null;
		return Plugin_Stop;
	}
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_MARKET_GARDENER)
	{
		float CoolDown = Attributes_Get(weapon, 249, 120.0);
		if(Market_Perk[client] == 4)
			CoolDown -= 10.0;
		else if(Market_Perk[client] == 3)
			CoolDown += 10.0;
		if(Market_AltAttackUse[client] <= 0)
		{
			Market_AltAttackUse[client]=0;
			Ability_Apply_Cooldown(client, 2, CoolDown);
		}
		else if(Ability_Check_Cooldown(client, 2) < 0.0)
		{
			--Market_AltAttackUse[client];
			Ability_Apply_Cooldown(client, 2, CoolDown);
		}
		Weapon_Energy_Max[client] = Attributes_Get(weapon, 171, 15.0);
		if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon && Market_WeaponPap[client]>=3)
		{
			if(Weapon_Energy[client] < Weapon_Energy_Max[client])Weapon_Energy[client] += 0.25;
			if(Weapon_Energy[client] > Weapon_Energy_Max[client])Weapon_Energy[client] = Weapon_Energy_Max[client];
			if(MarketHUDDelay[client] < GetGameTime())
			{
				PrintHintText(client, "Wind Burst [%i％]", RoundToFloor(Weapon_Energy[client]/Weapon_Energy_Max[client]*100.0));
				StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
				MarketHUDDelay[client] = GetGameTime() + 0.5;
			}
		}
	}
	return Plugin_Continue;
}

public void MarketGardener_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	if(!Market_OnAttack[attacker])
		return;
	Market_OnAttack[attacker]=false;
	if(GetEntityFlags(attacker)&FL_ONGROUND)
	{
		if(Market_Perk[attacker] == 5)
			damage *= 0.5;
		return;
	}
	float Attackerpos[3], VictimPos[3];
	float gametime = GetGameTime();
	GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", Attackerpos);
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", VictimPos);
	float Speed = MoveSpeed(attacker, _, true);
	bool minicrit=true;
	float DMGBuff = damage;
	bool GetMarket=false;
	float JUMPDMGSCALE = Attributes_Get(weapon, 19);
	float BOSSHEALTHPER = Attributes_Get(weapon, 399, 0.0);
	float BOSSDMGSCALE = Attributes_Get(weapon, 425);
	float NONBOSSDMGSCALE = Attributes_Get(weapon, 426);
	float HEALONJUMPATTACK = Attributes_Get(weapon, 401, 0.0);
	DMGBuff+=Speed;
	DMGBuff*=JUMPDMGSCALE;
	float MAXSpeed = 520.0;
	if(Market_Perk[attacker] == 2)
		MAXSpeed = 480.0;
	if(b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim] || (Market_WeaponPap[attacker]>=5 && Market_WeaponPap[attacker]<=7))
	{
		float BOSSHEALTH = float(ReturnEntityMaxHealth(victim));
		if(Speed >= MAXSpeed && Market_WeaponPap[attacker]>=1)
		{
			GetMarket=true;
			minicrit=false;
			DMGBuff*=BOSSDMGSCALE;
			DMGBuff+=(BOSSHEALTH*BOSSHEALTHPER);
		}
	}
	else
	{
		if(Speed >= MAXSpeed && Market_WeaponPap[attacker]>=1)
		{
			GetMarket=true;
			minicrit=false;
			DMGBuff*=NONBOSSDMGSCALE;
		}
	}
	if(GetMarket)EmitSoundToAll("player/doubledonk.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, Attackerpos);
	if(Market_WeaponPap[attacker]>=3)
	{
		if(GetMarket)
		{
			int maxhealth = SDKCall_GetMaxHealth(attacker);
			int health = GetClientHealth(attacker);
			int newhealth = health+RoundToNearest(maxhealth*HEALONJUMPATTACK);
			if(health < maxhealth)
			{
				if(newhealth > maxhealth)
					newhealth=maxhealth;
				SetEntityHealth(attacker, newhealth);
				ApplySelfHealEvent(attacker, newhealth - health);
			}
		}
		if(Weapon_Energy[attacker] >= Weapon_Energy_Max[attacker])
		{
			float fVelocity[3];
			GetEntPropVector(attacker, Prop_Data, "m_vecVelocity", fVelocity);
			fVelocity[2] = 750.0;
			TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, fVelocity);
			Weapon_Energy[attacker]=0.0;
		}
		if(Market_WeaponPap[attacker]>=8 && Market_WeaponPap[attacker]<=10)
		{
			int GetTarget;
			float position[3], position2[3], distance;
			float AoERanged = Attributes_Get(weapon, 101, 0.0);
			float AoEDMGSCALE = Attributes_Get(weapon, 118, 0.0);
			int AoEMAXTARGET = RoundToFloor(Attributes_Get(weapon, 397, 0.0));
			int AoEMAXTARGET_Over = GetMarket ? RoundToFloor(Attributes_Get(weapon, 389, 0.0)) : 0;
			float AoEDMG = DMGBuff*AoEDMGSCALE;
			bool OnHIT;
			GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", position);
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red && victim!=entity)
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position2);
					distance = GetVectorDistance(position, position2);
					if(distance<AoERanged)
					{
						SDKHooks_TakeDamage(entity, attacker, attacker, AoEDMG, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
						GetTarget++;
						OnHIT=true;
					}
					if(GetTarget>(AoEMAXTARGET+AoEMAXTARGET_Over))break;
				}
			}
			if(OnHIT) Market_OnAttack[attacker]=false;
			//PrintToChat(attacker, "AoE");
		}
	}
	if(!minicrit)
	{
		float DMGNerf = Market_Perk[attacker] == 5 ? 5.0 : 10.0;
		if(Power_Nerf[victim] < gametime)
			Power_Nerf[victim] = gametime + DMGNerf;
		else
		{
			DMGBuff*=0.75;
			//PrintToChat(attacker, "Nerf");
		}
		
		if(Market_Perk[attacker] == 5)
			DMGBuff*=1.25;
		//PrintToChat(attacker, "Crit");
	}
	if(Market_Perk[attacker] == 2)
		DMGBuff*=0.95;
	damage=DMGBuff;
	DisplayCritAboveNpc(victim, attacker, true, _, _, minicrit);
	//PrintToChat(attacker, "Speed: %.1f", Speed);
}

stock void ApplySelfHealEvent(int entindex, int amount)
{
	Event event = CreateEvent("player_healonhit", true);

	event.SetInt("entindex", entindex);
	event.SetInt("amount", amount);

	event.Fire();
}

stock float MoveSpeed(int client, bool maxspeed = false, bool upspeed = false)
{
	float Fvel[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", Fvel);

	float Speed;
	if(upspeed)
		Speed = SquareRoot(Pow(Fvel[0],2.0)+Pow(Fvel[1],2.0)+Pow(Fvel[2],2.0));
	else
		Speed = SquareRoot(Pow(Fvel[0],2.0)+Pow(Fvel[1],2.0));

	if(maxspeed && Speed > 520.0)
		Speed = 520.0;

	return Speed;
}