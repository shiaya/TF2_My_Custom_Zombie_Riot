#pragma semicolon 1
#pragma newdecls required

<<<<<<< HEAD
static Handle MarketTimer[MAXTF2PLAYERS] = {null, ...};
static float MarketHUDDelay[MAXTF2PLAYERS];
static int Market_WeaponPap[MAXTF2PLAYERS];
static int Market_Perk[MAXTF2PLAYERS];
static int i_MarketParticleOne[MAXTF2PLAYERS];
static int i_MarketParticleTwo[MAXTF2PLAYERS];
static int i_RocketJump_AirboneTime[MAXTF2PLAYERS];
int i_RocketJump_Count[MAXTF2PLAYERS];

static float i_SoldinAmmoSet[MAXTF2PLAYERS];
static float i_SoldinFierRateSet[MAXTF2PLAYERS];
static float i_SoldinReloadRateSet[MAXTF2PLAYERS];
static int i_SoldinCharging[MAXTF2PLAYERS];
static int i_SoldinChargingMAX[MAXTF2PLAYERS];
static bool b_SoldinPowerHit[MAXTF2PLAYERS];
static bool b_SoldinLastMann_Buff;

static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";

bool Wkit_Soldin_BvB(int client)
{
	return MarketTimer[client] != null;
=======
#define SOLDINE_MAX_MELEE_CHARGE 35.0
#define SOLDINE_MAX_ROCKETJUMP_CHARGE 65.0
#define SOLDINE_ROCKET_JUMP_DURATION_MAX 2.0

static Handle Soldine_Timer[MAXTF2PLAYERS] = {null, ...};
static bool Precached;
float Soldine_HudDelay[MAXPLAYERS+1];
static int ParticleRef[MAXPLAYERS+1];
static int i_PaPLevel[MAXPLAYERS+1];
static float i_SoldineMeleeCharge[MAXPLAYERS+1];
static float i_SoldineRocketjumpCharge[MAXPLAYERS+1];
static float f_SoldineRocketJumpDuration[MAXPLAYERS+1];
static int i_ParticleMeleeHit[MAXPLAYERS+1];


/*
	Pap 1: Unlocks melee charge
	Pap 2: Unlocks Rocket Jump Charge
	Pap 3: Makes both chrage faster, Melee Heals
	Pap 4: Makes both charge faster, 
	rest is just more stats
*/
public void Wkit_Soldin_OnMapStart()
{
	Precached = false;
	Zero(i_SoldineMeleeCharge);
	Zero(i_SoldineRocketjumpCharge);
	Zero(f_SoldineRocketJumpDuration);
	Zero(Soldine_HudDelay);
}

void ChargeSoldineMeleeHit(int client, bool Melee, float Multi = 1.0)
{
	if(i_PaPLevel[client] < 1)
	{
		return;
	}
	float MeleeChargeDo = 1.0;
	
	if(Melee)
		MeleeChargeDo *= 2.0;
	else
		MeleeChargeDo *= 0.75;

	if(i_PaPLevel[client] >= 3)
		MeleeChargeDo *= 1.1;

	if(i_PaPLevel[client] >= 4)
		MeleeChargeDo *= 1.1;

	if(LastMann)
	{
		MeleeChargeDo *= 1.5;
	}

	MeleeChargeDo *= Multi;

	i_SoldineMeleeCharge[client] += MeleeChargeDo;

	if(i_SoldineMeleeCharge[client] > SOLDINE_MAX_MELEE_CHARGE)
		i_SoldineMeleeCharge[client] = SOLDINE_MAX_MELEE_CHARGE;
>>>>>>> upstream/master
}

bool Wkit_Soldin_LastMann(int client)
{
	bool SoldinTHEME=false;
<<<<<<< HEAD
	switch(Market_WeaponPap[client])
	{
		case 0, 1:
		{
		}
		case 2, 3, 4, 5, 6, 7, 8:
		{
			if(MarketTimer[client] != null)SoldinTHEME=true;
		}
=======
	if(Soldine_Timer[client] != null)
	{
		if(i_PaPLevel[client] >= 1)
			SoldinTHEME = true;
>>>>>>> upstream/master
	}
	return SoldinTHEME;
}

<<<<<<< HEAD
void Wkit_Soldin_LastMann_buff(int client, bool b_On)
{
	b_SoldinLastMann_Buff=b_On;
	if(b_On)
	{
		switch(Market_WeaponPap[client])
		{
			case 0, 1:
			{
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(MarketTimer[client] != null)
				{
					i_SoldinCharging[client]=i_SoldinChargingMAX[client];
				}
			}
		}
	}
}

public void Wkit_Soldin_OnMapStart()
{
	Zero(Market_WeaponPap);
	Zero(Market_Perk);
	Zero(MarketHUDDelay);
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3",_,1);
}

public void Wkit_Soldin_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(MarketTimer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_PROTOTYPE)
		{
			Market_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			Market_Perk[client]=i_CurrentEquippedPerk[client];
			int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			if(IsValidEntity(getweapon))
			{
				i_SoldinAmmoSet[client] = Attributes_Get(getweapon, 4, 1.0);
				i_SoldinFierRateSet[client] = Attributes_Get(getweapon, 6, 2.0);
				i_SoldinReloadRateSet[client] = Attributes_Get(getweapon, 97, 2.0);
			}
			int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
			delete MarketTimer[client];
			MarketTimer[client] = null;
			DataPack pack;
			MarketTimer[client] = CreateDataTimer(0.1, Timer_Wkit_Soldin, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteCell(EntIndexToEntRef(melee));
		}
		return;
	}
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PROTOTYPE)
	{
		Market_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		Market_Perk[client]=i_CurrentEquippedPerk[client];
		int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		if(IsValidEntity(getweapon))
		{
			i_SoldinAmmoSet[client] = Attributes_Get(getweapon, 4, 1.0);
			i_SoldinFierRateSet[client] = Attributes_Get(getweapon, 6, 2.0);
			i_SoldinReloadRateSet[client] = Attributes_Get(getweapon, 97, 2.0);
		}
		int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		DataPack pack;
		MarketTimer[client] = CreateDataTimer(0.1, Timer_Wkit_Soldin, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(EntIndexToEntRef(melee));
	}
}

static Action Timer_Wkit_Soldin(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int primary = EntRefToEntIndex(pack.ReadCell());
	int melee = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(primary) || !IsValidEntity(melee))
	{
		MarketTimer[client] = null;
		b_On_Self_Damage[client] = false;
		return Plugin_Stop;
	}	
	
	bool IsMelee=false;
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == primary)
	{
		
	}
	else if(weapon_holding == melee)
	{
		IsMelee=true;
	}
	else
	{
		//wtf???
	}
	Wkit_Soldin_HUD(client, IsMelee);
	Wkit_Soldin_Effect(client, IsMelee);

	return Plugin_Continue;
}

public void Wkit_Soldin_NPCTakeDamage(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	int melee = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee);
	float Attackerpos[3]; GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", Attackerpos);
	if(weapon==melee && (damagetype & DMG_CLUB) && !(damagetype & DMG_BLAST))
	{
		switch(Market_WeaponPap[attacker])
		{
			case 0, 1:
			{
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(!b_SoldinPowerHit[attacker])
				{
					i_SoldinCharging[attacker]+=1+i_RocketJump_Count[attacker];
					if(i_SoldinCharging[attacker]>i_SoldinChargingMAX[attacker])
						i_SoldinCharging[attacker]=i_SoldinChargingMAX[attacker];
				}
				else
				{
					Rogue_OnAbilityUse(attacker, weapon);
					float position[3]; WorldSpaceCenter(victim, position);
					position[2]+=35.0;
					ParticleEffectAt(position, "hightower_explosion", 1.0);
					EmitSoundToAll(g_BoomSounds, victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					if(RaidbossIgnoreBuildingsLogic(1))damage *= 2.0;
=======
bool Wkit_Soldin_BvB(int client)
{
	return Soldine_Timer[client] != null;
}

bool CanSelfHurtAndJump(int client)
{
	if(i_SoldineRocketjumpCharge[client] >= SOLDINE_MAX_ROCKETJUMP_CHARGE)
	{
		return true;
	}
	return false;
}

void ChargeSoldineRocketJump(int client, bool Melee, float Multi = 1.0)
{
	if(i_PaPLevel[client] < 2)
	{
		return;
	}
	float MeleeChargeDo = 1.0;
	
	if(Melee)
		MeleeChargeDo *= 2.0;
	else
		MeleeChargeDo *= 0.75;

	if(i_PaPLevel[client] >= 3)
		MeleeChargeDo *= 1.1;

	if(i_PaPLevel[client] >= 4)
		MeleeChargeDo *= 1.1;

	if(LastMann)
	{
		MeleeChargeDo *= 1.5;
	}

	MeleeChargeDo *= Multi;

	i_SoldineRocketjumpCharge[client] += MeleeChargeDo;

	if(i_SoldineRocketjumpCharge[client] > SOLDINE_MAX_ROCKETJUMP_CHARGE)
		i_SoldineRocketjumpCharge[client] = SOLDINE_MAX_ROCKETJUMP_CHARGE;
}


public void Wkit_Soldin_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KIT_PROTOTYPE) //
	{
		if (Soldine_Timer[client] != null)
		{
			delete Soldine_Timer[client];
			Soldine_Timer[client] = null;
		}
		i_PaPLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		DataPack pack;
		Soldine_Timer[client] = CreateDataTimer(0.1, Timer_Soldine_Kit, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));

		Soldine_EyeHandler(client);

		if(!Precached)
		{
			// MASS REPLACE THIS IN ALL FILES
			PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3",_,1);
			Precached = true;
		}
	}
}

static void Delete_Halo(int client)
{
	int halo_particle = EntRefToEntIndex(ParticleRef[client]);
	
	if(IsValidEntity(halo_particle))
	{
		TeleportEntity(halo_particle, OFF_THE_MAP);
		RemoveEntity(halo_particle);
		ParticleRef[client] = INVALID_ENT_REFERENCE;
	}
}

static void Soldine_EyeHandler(int client)
{
	int halo_particle = EntRefToEntIndex(ParticleRef[client]);
	
	if(IsValidEntity(halo_particle))
		return;

	if(AtEdictLimit(EDICT_PLAYER))
	{
		Delete_Halo(client);
		return;
	}

	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		float flPos[3];
		GetAttachment(viewmodelModel, "eyeglow_L", flPos, NULL_VECTOR);
		int particle = ParticleEffectAt(flPos, "eye_powerup_red_lvl_3", 0.0);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(viewmodelModel, particle, "eyeglow_L");
		ParticleRef[client] = EntIndexToEntRef(particle);
		return;
	}
}
static void Delete_Hand(int client)
{
	int halo_particle = EntRefToEntIndex(i_ParticleMeleeHit[client]);
	
	if(IsValidEntity(halo_particle))
	{
		TeleportEntity(halo_particle, OFF_THE_MAP);
		RemoveEntity(halo_particle);
		i_ParticleMeleeHit[client] = INVALID_ENT_REFERENCE;
	}
}

static void Soldine_HandShowMegaBoom(int client)
{
	int halo_particle = EntRefToEntIndex(i_ParticleMeleeHit[client]);
	
	if(IsValidEntity(halo_particle))
		return;

	if(AtEdictLimit(EDICT_PLAYER))
	{
		Delete_Halo(client);
		return;
	}

	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		float flPos[3];
		GetAttachment(viewmodelModel, "effect_hand_r", flPos, NULL_VECTOR);
		int particle = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.0);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(viewmodelModel, particle, "effect_hand_r");
		i_ParticleMeleeHit[client] = EntIndexToEntRef(particle);
		return;
	}
}
public Action Timer_Soldine_Kit(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Soldine_Timer[client] = null;
		Delete_Halo(client);
		Delete_Hand(client);
		return Plugin_Stop;
	}	
		
	if(i_PaPLevel[client] >= 1)
	{
		if(i_SoldineMeleeCharge[client] >= SOLDINE_MAX_MELEE_CHARGE)
		{
			Soldine_HandShowMegaBoom(client);
		}
		else
		{
			Delete_Hand(client);
		}
	}
	else
	{
		Delete_Hand(client);
	}
	Soldine_EyeHandler(client);
	Soldine_Hud_Logic(client, weapon, false);
	Wkit_Soldin_Effect(client);
		
	return Plugin_Continue;
}

#define SOLDINE_JUMPDURATIONUFF 2.0
static void Wkit_Soldin_Effect(int client)
{
	if(!TF2_IsPlayerInCondition(client, TFCond_BlastJumping))
	{
		return;
	}
	if(i_SoldineRocketjumpCharge[client] < SOLDINE_MAX_ROCKETJUMP_CHARGE)
	{
		return;
	}
	if(i_PaPLevel[client] < 2)
	{
		return;
	}
	i_SoldineRocketjumpCharge[client] = 0.0;

	TF2_AddCondition(client, TFCond_HalloweenCritCandy, SOLDINE_JUMPDURATIONUFF);
	TF2_AddCondition(client, TFCond_RunePrecision, SOLDINE_JUMPDURATIONUFF);
	f_SoldineRocketJumpDuration[client] = GetGameTime() + (SOLDINE_JUMPDURATIONUFF + 1.0);
	float velocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
	velocity[2] += 650.0;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	if(IsValidEntity(getweapon))
	{
		ApplyTempAttrib(getweapon, 6, 0.35, SOLDINE_JUMPDURATIONUFF);
		ApplyTempAttrib(getweapon, 178, 0.25, SOLDINE_JUMPDURATIONUFF);
		Rogue_OnAbilityUse(client, getweapon);
	}

	if(IsValidEntity(getweapon))
	{
		int RocketLoad = GetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
		int RockeyAmmo=	GetAmmo(client, 8);
		int RocketAmmoMAX=RoundToCeil(8.0* Attributes_Get(getweapon, 4, 1.0));
		SetAmmo(client, 8, RockeyAmmo-RocketAmmoMAX);
		SetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), RocketLoad+RocketAmmoMAX);
	}
	int entity;
	entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(entity))
	{
		float flPos[3];
		float flAng[3];
		GetAttachment(entity, "foot_L", flPos, flAng);
		int particle = ParticleEffectAt(flPos, "rockettrail", SOLDINE_JUMPDURATIONUFF);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(entity, particle, "foot_L");
		
		GetAttachment(entity, "foot_R", flPos, flAng);
		particle = ParticleEffectAt(flPos, "rockettrail", SOLDINE_JUMPDURATIONUFF);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(entity, particle, "foot_R");
	}
}

public void Soldine_Hud_Logic(int client, int weapon, bool ignoreCD)
{
	//Do your code here :)
	if(Soldine_HudDelay[client] > GetGameTime() && !ignoreCD)
		return;

	char SoldineHud[255];

	if(i_PaPLevel[client] >= 1)
	{
		Format(SoldineHud, sizeof(SoldineHud), "%sExplosive Melee[%1.f％]", SoldineHud, (i_SoldineMeleeCharge[client] / SOLDINE_MAX_MELEE_CHARGE) * 100.0);
	}

	if(i_PaPLevel[client] >= 2)
	{
		Format(SoldineHud, sizeof(SoldineHud), "%s\nRobot Jump[%1.f％]", SoldineHud, (i_SoldineRocketjumpCharge[client] / SOLDINE_MAX_ROCKETJUMP_CHARGE) * 100.0);
	}

	Soldine_HudDelay[client] = GetGameTime() + 0.5;
	PrintHintText(client,"%s",SoldineHud);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
}



public void Wkit_Soldin_NPCTakeDamage_Melee(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if((damagetype & DMG_CLUB))
	{
		switch(i_PaPLevel[attacker])
		{
			case 1, 2, 3, 4, 5, 6, 7, 8:
			{
				if(i_SoldineMeleeCharge[attacker] >= SOLDINE_MAX_MELEE_CHARGE)
				{
					if(f_SoldineRocketJumpDuration[attacker] > GetGameTime())
					{
						damage *= 2.0;
						DisplayCritAboveNpc(victim, attacker, true, _, _, false);
					}
					Rogue_OnAbilityUse(attacker, weapon);
					float position[3]; WorldSpaceCenter(victim, position);
					position[2]+=35.0;
					DataPack pack_boom = new DataPack();
					pack_boom.WriteFloat(position[0]);
					pack_boom.WriteFloat(position[1]);
					pack_boom.WriteFloat(position[2]);
					pack_boom.WriteCell(0);
					RequestFrame(MakeExplosionFrameLater, pack_boom);

					//For client only cus too much fancy shit
					EmitSoundToClient(attacker, "mvm/mvm_tank_explode.wav", victim, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
					TE_Particle("hightower_explosion", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = attacker);

					TE_Particle("mvm_soldier_shockwave", position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
					if(RaidbossIgnoreBuildingsLogic(1))
						damage *= 2.0;

>>>>>>> upstream/master
					Explode_Logic_Custom(damage*2.0, attacker, attacker, weapon, position, 250.0, 0.75, _, _, _, _, _, Ground_Slam);
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime(weapon)+1.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime(attacker)+1.0);
					damage *= 3.0;
<<<<<<< HEAD
					GiveArmorViaPercentage(attacker, 0.25, 1.0);
					b_SoldinPowerHit[attacker]=false;
				}
			}
		}
	}
	else
	{
		switch(Market_WeaponPap[attacker])
		{
			case 0, 1:
			{
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(RaidbossIgnoreBuildingsLogic(1))damage *= 2.0;
				if(i_SoldinCharging[attacker])
					damage *= 1.0+(float(i_SoldinCharging[attacker])*(b_SoldinLastMann_Buff ? 0.1 : 0.05));
				if(i_RocketJump_Count[attacker]>0 && i_RocketJump_AirboneTime[attacker]>5)
				{
					damage *= 1.15;
					DisplayCritAboveNpc(victim, attacker, true, _, _, true);
				}
			}
		}
	}
}

static void Wkit_Soldin_Effect(int client, bool weapons)
{
	switch(Market_WeaponPap[client])
	{
		case 0, 1:
		{
		}
		case 2, 3, 4, 5, 6, 7, 8:
		{
			int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			if(IsValidEntity(getweapon))
			{
				if(i_SoldinCharging[client]>0 && !b_SoldinPowerHit[client])
				{
					float GetMaxCharging = float(i_SoldinCharging[client]);
					if(GetMaxCharging>10.0)GetMaxCharging=10.0;
					Attributes_Set(getweapon, 4, 1.0+(GetMaxCharging*0.2));
					Attributes_Set(getweapon, 6, 2.0-(GetMaxCharging*0.11));
					Attributes_Set(getweapon, 97, 2.0-(GetMaxCharging*0.15));
				}
			}
		}
	}
	if(GetEntityFlags(client)&FL_ONGROUND || !TF2_IsPlayerInCondition(client, TFCond_BlastJumping))
	{
		i_RocketJump_Count[client]=0;
		i_RocketJump_AirboneTime[client]=0;
		switch(Market_WeaponPap[client])
		{
			case 0, 1:
			{
				if(weapons)
				{
				}
				else
				{
				}
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(weapons)
				{
					if(b_SoldinPowerHit[client])TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.2);
				}
				else
				{
					if(i_SoldinCharging[client]>=i_SoldinChargingMAX[client] && !b_SoldinPowerHit[client])b_On_Self_Damage[client] = true;
				}
			}
		}
		if(b_SoldinPowerHit[client])
			i_SoldinCharging[client]=0;
		DestroyWkit_Soldin_Effect(client);
	}
	else if(i_RocketJump_Count[client])
	{
		i_RocketJump_AirboneTime[client]++;
		switch(Market_WeaponPap[client])
		{
			case 0, 1:
			{
				if(weapons)
				{
				}
				else
				{
				}
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				if(weapons)
				{
					if(b_SoldinPowerHit[client])TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.2);
				}
				else
				{
					if(i_SoldinCharging[client]>=i_SoldinChargingMAX[client])
					{
						TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.2);
						TF2_AddCondition(client, TFCond_RunePrecision, 0.2);
						if(!b_SoldinPowerHit[client])
						{
							TF2_AddCondition(client, TFCond_Parachute, 3.5);
							TF2_AddCondition(client, TFCond_ParachuteDeployed, 3.5);
							float velocity[3];
							GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
							velocity[2] += 650.0;
							TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
							int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
							if(IsValidEntity(getweapon))
							{
								Attributes_Set(getweapon, 4, i_SoldinAmmoSet[client]);
								Attributes_Set(getweapon, 6, i_SoldinFierRateSet[client]);
								Attributes_Set(getweapon, 97, i_SoldinReloadRateSet[client]);
								ApplyTempAttrib(getweapon, 6, 0.175, 3.5);
								ApplyTempAttrib(getweapon, 2, 3.0, 3.5);
								Rogue_OnAbilityUse(client, getweapon);
							}
							b_SoldinPowerHit[client]=true;
							b_On_Self_Damage[client] = false;
						}
						int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
						if(IsValidEntity(getweapon))
						{
							int RocketLoad = GetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
							int RockeyAmmo=GetAmmo(client, 8);
							int RocketAmmoMAX=RoundToCeil(4.0*i_SoldinAmmoSet[client]);
							if(RockeyAmmo>1 && RocketLoad<RocketAmmoMAX)
							{
								SetAmmo(client, 8, RockeyAmmo-1);
								SetEntData(getweapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), RocketLoad+1);
							}
						}
					}
				}
			}
		}
		int entity = EntRefToEntIndex(i_MarketParticleOne[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				float flAng[3];
				GetAttachment(entity, "foot_L", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "rockettrail", 0.0);
				AddEntityToThirdPersonTransitMode(client, particle);
				SetParent(entity, particle, "foot_L");
				i_MarketParticleOne[client] = EntIndexToEntRef(particle);
			}
		}
		entity = EntRefToEntIndex(i_MarketParticleTwo[client]);
		if(!IsValidEntity(entity))
		{
			entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
			if(IsValidEntity(entity))
			{
				float flPos[3];
				float flAng[3];
				GetAttachment(entity, "foot_R", flPos, flAng);
				int particle = ParticleEffectAt(flPos, "rockettrail", 0.0);
				AddEntityToThirdPersonTransitMode(client, particle);
				SetParent(entity, particle, "foot_R");
				i_MarketParticleTwo[client] = EntIndexToEntRef(particle);
			}
		}
	}
}
static void DestroyWkit_Soldin_Effect(int client)
{
	int entity = EntRefToEntIndex(i_MarketParticleOne[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_MarketParticleOne[client] = INVALID_ENT_REFERENCE;
	entity = EntRefToEntIndex(i_MarketParticleTwo[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_MarketParticleTwo[client] = INVALID_ENT_REFERENCE;
}

static void Wkit_Soldin_HUD(int client, bool weapons)
{
	if(MarketHUDDelay[client] < GetGameTime())
	{
		char C_point_hints[512]="";
		switch(Market_WeaponPap[client])
		{
			case 0, 1:
			{
				b_IsCannibal[client]=false;
				if(weapons)
				{
				
				}
				else
				{
				
				}
			}
			case 2, 3, 4, 5, 6, 7, 8:
			{
				b_IsCannibal[client]=true;
				i_SoldinChargingMAX[client]=(b_SoldinLastMann_Buff ? 13 : 15);
				if(i_RocketJump_Count[client] && b_SoldinPowerHit[client])
					Format(C_point_hints, sizeof(C_point_hints),
					"Rocket Barrage Online!");
				else if(i_SoldinCharging[client]<i_SoldinChargingMAX[client])
				{
					Format(C_point_hints, sizeof(C_point_hints),
					"Battery: %i％", RoundToCeil(float(i_SoldinCharging[client])/float(i_SoldinChargingMAX[client])*100.0));
				}
				else
					Format(C_point_hints, sizeof(C_point_hints),
					"Rocket Barrage Ready!");

				if(weapons)
				{
					if(!b_SoldinPowerHit[client])
					{
						if(i_SoldinCharging[client]<i_SoldinChargingMAX[client])
						{
							Format(C_point_hints, sizeof(C_point_hints),
							"%s\nMelee Hit To Battery Charge.", C_point_hints);
						}
					}
					else
						Format(C_point_hints, sizeof(C_point_hints),
						"%s\nMelee Power Hit Online!", C_point_hints);
				}
				else
				{
					Format(C_point_hints, sizeof(C_point_hints),
					"%s\nRocket DMG Bonus +%i％", C_point_hints, RoundToCeil(float(i_SoldinCharging[client])*2.5));
					if(i_SoldinCharging[client]>=i_SoldinChargingMAX[client] && !b_SoldinPowerHit[client] && i_RocketJump_Count[client]<1)
						Format(C_point_hints, sizeof(C_point_hints),
						"%s\nNow Rocket Jump!", C_point_hints);
				}
			}
		}

		if(C_point_hints[0] != '\0')
		{
			PrintHintText(client,"%s", C_point_hints);
			StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
			MarketHUDDelay[client] = GetGameTime() + 0.5;
=======
					if(i_PaPLevel[attacker] >= 3)
						GiveArmorViaPercentage(attacker, 999.9, 1.0);

					if(i_PaPLevel[attacker] >= 4)
						GiveArmorViaPercentage(attacker, 999.9, 1.25);
					i_SoldineMeleeCharge[attacker] = 0.0;
				}
				else
				{
					ChargeSoldineMeleeHit(attacker,true);
					ChargeSoldineRocketJump(attacker, true);
				}
			}
			default:
			{
				
			}
		}
	}
}


public void Wkit_Soldin_NPCTakeDamage_Ranged(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	if(f_SoldineRocketJumpDuration[attacker] > GetGameTime())
	{
		damage *= 1.15;
		if(!CheckInHud())
			DisplayCritAboveNpc(victim, attacker, true, _, _, true);

		ChargeSoldineMeleeHit(attacker,false);
	}
	else
	{
		if(!CheckInHud())
		{
			ChargeSoldineMeleeHit(attacker,false);
			ChargeSoldineRocketJump(attacker, false);
>>>>>>> upstream/master
		}
	}
}

static void Ground_Slam(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(entity) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim))
	{
		ApplyStatusEffect(entity, victim, "Silenced", (b_thisNpcIsARaid[victim] ? 1.0 : 1.5));
		if(b_thisNpcIsARaid[victim])
			FreezeNpcInTime(victim, 0.5);
		else
			FreezeNpcInTime(victim, 1.0);
<<<<<<< HEAD
=======

>>>>>>> upstream/master
		Custom_Knockback(entity, victim, 600.0, true, true, true);
	}
}