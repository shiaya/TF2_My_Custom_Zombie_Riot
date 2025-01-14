#pragma semicolon 1
#pragma newdecls required

static Handle MarketTimer[MAXTF2PLAYERS] = {null, ...};
static float MarketHUDDelay[MAXTF2PLAYERS];
static int Market_WeaponPap[MAXTF2PLAYERS];
static int Market_Perk[MAXTF2PLAYERS];
static int i_MarketParticleOne[MAXTF2PLAYERS];
static int i_MarketParticleTwo[MAXTF2PLAYERS];
static int i_RocketJump_AirboneTime[MAXTF2PLAYERS];
int RocketJump_Count[MAXTF2PLAYERS];

static float i_SoldinAmmoSet[MAXTF2PLAYERS];
static float i_SoldinFierRateSet[MAXTF2PLAYERS];
static float i_SoldinReloadRateSet[MAXTF2PLAYERS];
static int i_SoldinCharging[MAXTF2PLAYERS];
static int i_SoldinChargingMAX[MAXTF2PLAYERS];
static bool b_SoldinPowerHit[MAXTF2PLAYERS];
static bool b_SoldinLastMann_Buff;

static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";

bool Soldin_BvB(int client)
{
	return MarketTimer[client] != null;
}

bool Soldin_LastMann(int client)
{
	bool SoldinTHEME=false;
	switch(Market_WeaponPap[client])
	{
		case 0, 1, 2, 10, 11, 12, 13, 14, 15:
		{
		}
		case 3, 4, 5, 6, 7, 8, 9:
		{
			if(MarketTimer[client] != null)SoldinTHEME=true;
		}
	}
	return SoldinTHEME;
}

void Soldin_LastMann_buff(int client, bool b_On)
{
	b_SoldinLastMann_Buff=b_On;
	if(b_On)
	{
		switch(Market_WeaponPap[client])
		{
			case 0, 1, 2, 10, 11, 12, 13, 14, 15:
			{
			}
			case 3, 4, 5, 6, 7, 8, 9:
			{
				if(MarketTimer[client] != null)
				{
					i_SoldinCharging[client]=i_SoldinChargingMAX[client];
				}
			}
		}
	}
}

bool OldProtokit_CanSelfHurtAndJump(int client)
{
	switch(Market_WeaponPap[client])
	{
		case 0, 1, 2, 10, 11, 12, 13, 14, 15:
		{
			if(MarketTimer[client] != null)return true;
		}
		case 3, 4, 5, 6, 7, 8, 9:
		{
			if((Ability_Check_Cooldown(client, 1) < 0.0 || CvarInfiniteCash.BoolValue) && MarketTimer[client] != null)
			{
				Ability_Apply_Cooldown(client, 1, 30.0);
				return true;
			}
			else if(i_SoldinCharging[client]>=i_SoldinChargingMAX[client] && !b_SoldinPowerHit[client])
				return true;
		}
	}
	return false;
}

public void Trolldier_OnMapStart()
{
	Zero(Market_WeaponPap);
	Zero(Market_Perk);
	Zero(MarketHUDDelay);
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3",_,1);
	PrecacheSound("player/doubledonk.wav");
	PrecacheSound(g_BoomSounds);
}

public void Trolldier_RJCoolDown(int client, int weapon, bool &result, int slot)
{
	//none
}

public void Trolldier_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(MarketTimer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_TROLLDIER)
		{
			Market_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			Market_Perk[client]=i_CurrentEquippedPerk[client];
			b_On_Self_Damage[client] = true;
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
			MarketTimer[client] = CreateDataTimer(0.1, Timer_Trolldier, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteCell(EntIndexToEntRef(melee));
		}
		return;
	}
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_TROLLDIER)
	{
		Market_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		Market_Perk[client]=i_CurrentEquippedPerk[client];
		b_On_Self_Damage[client] = true;
		int getweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		if(IsValidEntity(getweapon))
		{
			i_SoldinAmmoSet[client] = Attributes_Get(getweapon, 4, 1.0);
			i_SoldinFierRateSet[client] = Attributes_Get(getweapon, 6, 2.0);
			i_SoldinReloadRateSet[client] = Attributes_Get(getweapon, 97, 2.0);
		}
		int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		DataPack pack;
		MarketTimer[client] = CreateDataTimer(0.1, Timer_Trolldier, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(EntIndexToEntRef(melee));
	}
}

static Action Timer_Trolldier(Handle timer, DataPack pack)
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
	Trolldier_HUD(client, IsMelee);
	Trolldier_Effect(client, IsMelee);

	return Plugin_Continue;
}

public void Trolldier_NPCTakeDamage(int attacker, int victim, float &damage, int weapon, int damagetype)
{
	int melee = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee);
	float Attackerpos[3]; GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", Attackerpos);
	if(weapon==melee && (damagetype & DMG_CLUB) && !(damagetype & DMG_BLAST))
	{
		switch(Market_WeaponPap[attacker])
		{
			case 0, 1, 2, 10, 11, 12, 13, 14, 15:
			{
				if(RocketJump_Count[attacker])
				{
					bool TrueDMG=false;
					if(Market_WeaponPap[attacker] == 2
						|| Market_WeaponPap[attacker] == 10
						|| Market_WeaponPap[attacker] == 11
						|| Market_WeaponPap[attacker] == 12
						|| Market_WeaponPap[attacker] == 13
						|| Market_WeaponPap[attacker] == 14
						|| Market_WeaponPap[attacker] == 15)
						TrueDMG=true;
					else if(RaidbossIgnoreBuildingsLogic(1))
						damage*=1.1;
					float DMGBuff = damage;
					float Speed = MoveSpeed(attacker, _, true);
					float f_AirboneScale = Attributes_Get(weapon, 19, 0.01);
					float f_RocketJumpScale = Attributes_Get(weapon, 426, 0.15);
					float f_SpeedScale = Attributes_Get(weapon, 401, 0.4);
					float f_DMGHealthPer_Scale = Attributes_Get(weapon, 399, 0.0);
					float f_HealHealthPer_Scale = Attributes_Get(weapon, 158, 0.0);
					
					bool minicrit=true;
					DMGBuff+=Speed*f_SpeedScale;
					DMGBuff*=1.0+(float(RocketJump_Count[attacker])*f_RocketJumpScale);
					DMGBuff*=1.0+(float(i_RocketJump_AirboneTime[attacker])*f_AirboneScale);
					if(RocketJump_Count[attacker]>1 || i_RocketJump_AirboneTime[attacker]>15)
					{
						if(f_DMGHealthPer_Scale>0.0)
						{
							float DMGBuff_TwoND;
							float NPCHEALTH = float(ReturnEntityMaxHealth(victim));
							DMGBuff_TwoND=(NPCHEALTH*f_DMGHealthPer_Scale);
							DMGBuff_TwoND*=1.0+(float(RocketJump_Count[attacker])*f_RocketJumpScale*0.5);
							DMGBuff_TwoND*=1.0+(float(i_RocketJump_AirboneTime[attacker])*f_AirboneScale*0.5);
							DMGBuff+=DMGBuff_TwoND;
						}
						if(f_HealHealthPer_Scale>0.0)
						{
							int maxhealth = SDKCall_GetMaxHealth(attacker);
							int health = GetClientHealth(attacker);
							int newhealth = RoundToNearest(maxhealth*f_HealHealthPer_Scale);
							if(health < maxhealth)
							{
								newhealth=RoundToNearest(float(newhealth)*(1.0+(float(RocketJump_Count[attacker])*f_RocketJumpScale*0.25)));
								newhealth=RoundToNearest(float(newhealth)*(1.0+(float(i_RocketJump_AirboneTime[attacker])*f_AirboneScale*0.9)));
								newhealth+=health;
								if(newhealth > maxhealth)
									newhealth=maxhealth;
								SetEntityHealth(attacker, newhealth);
								ApplySelfHealEvent(attacker, newhealth - health);
							}
						}
						minicrit=false;
						EmitSoundToAll("player/doubledonk.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, Attackerpos);
					}
					else if(TrueDMG)
					{
						if(f_DMGHealthPer_Scale>0.0)
						{
							float DMGBuff_TwoND;
							float NPCHEALTH = float(ReturnEntityMaxHealth(victim));
							DMGBuff_TwoND=(NPCHEALTH*f_DMGHealthPer_Scale);
							DMGBuff_TwoND*=1.0+(float(RocketJump_Count[attacker])*f_RocketJumpScale*0.5);
							DMGBuff_TwoND*=1.0+(float(i_RocketJump_AirboneTime[attacker])*f_AirboneScale*0.5);
							DMGBuff+=DMGBuff_TwoND*0.5;
						}
						if(f_HealHealthPer_Scale>0.0)
						{
							int maxhealth = SDKCall_GetMaxHealth(attacker);
							int health = GetClientHealth(attacker);
							int newhealth = RoundToNearest(maxhealth*f_HealHealthPer_Scale);
							if(health < maxhealth)
							{
								newhealth=RoundToNearest(float(newhealth)*(1.0+(float(RocketJump_Count[attacker])*f_RocketJumpScale*0.25)));
								newhealth=RoundToNearest(float(newhealth)*(1.0+(float(i_RocketJump_AirboneTime[attacker])*f_AirboneScale*0.9)));
								newhealth=RoundToNearest(float(newhealth)*0.5);
								newhealth+=health;
								if(newhealth > maxhealth)
									newhealth=maxhealth;
								SetEntityHealth(attacker, newhealth);
								ApplySelfHealEvent(attacker, newhealth - health);
							}
						}
					}
					if(TrueDMG)
					{
						if(!(damagetype & DMG_TRUEDAMAGE))
						{
							Handle AttackPack;
							CreateDataTimer(0.01, Timer_Delay_Attack, AttackPack, TIMER_FLAG_NO_MAPCHANGE);
							WritePackCell(AttackPack, DMGBuff*0.15);
							WritePackCell(AttackPack, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
							WritePackCell(AttackPack, victim);
							WritePackCell(AttackPack, attacker);
						}
						damage=DMGBuff*0.85;
					}
					else
						damage=DMGBuff;

					DisplayCritAboveNpc(victim, attacker, true, _, _, minicrit);
				}
				else damage *= 0.35;
			}
			case 3, 4, 5, 6, 7, 8, 9:
			{
				if(!b_SoldinPowerHit[attacker])
				{
					i_SoldinCharging[attacker]+=1+RocketJump_Count[attacker];
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
					Explode_Logic_Custom(damage*2.0, attacker, attacker, weapon, position, 250.0, 0.75, _, _, _, _, _, Ground_Slam);
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime(weapon)+1.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime(attacker)+1.0);
					damage *= 3.0;
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
			case 0, 1, 2, 10, 11, 12, 13, 14, 15:
			{
				if(RocketJump_Count[attacker])
				{
					float DMGBuff = damage;
					float f_AirboneScale = Attributes_Get(weapon, 19, 0.01);
					float f_RocketJumpScale = Attributes_Get(weapon, 426, 0.15);
					DMGBuff*=1.0+(RocketJump_Count[attacker]*f_RocketJumpScale);
					DMGBuff*=1.0+(i_RocketJump_AirboneTime[attacker]*f_AirboneScale);
					damage=DMGBuff;
				}
				else
				{
					if(Market_WeaponPap[attacker] == 2
						|| Market_WeaponPap[attacker] == 10
						|| Market_WeaponPap[attacker] == 11
						|| Market_WeaponPap[attacker] == 12
						|| Market_WeaponPap[attacker] == 13
						|| Market_WeaponPap[attacker] == 14
						|| Market_WeaponPap[attacker] == 15)
						damage *= 0.5;
					else
						damage *= 0.9;
				}
			}
			case 3, 4, 5, 6, 7, 8, 9:
			{
				if(RaidbossIgnoreBuildingsLogic(1))damage *= 2.0;
				if(i_SoldinCharging[attacker])
					damage *= 1.0+(float(i_SoldinCharging[attacker])*(b_SoldinLastMann_Buff ? 0.1 : 0.05));
				if(RocketJump_Count[attacker]>0 && i_RocketJump_AirboneTime[attacker]>5)
				{
					damage *= 1.15;
					DisplayCritAboveNpc(victim, attacker, true, _, _, true);
				}
			}
		}
	}
}

static void Trolldier_Effect(int client, bool weapons)
{
	switch(Market_WeaponPap[client])
	{
		case 0, 1, 2, 10, 11, 12, 13, 14, 15:
		{
		}
		case 3, 4, 5, 6, 7, 8, 9:
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
		RocketJump_Count[client]=0;
		i_RocketJump_AirboneTime[client]=0;
		switch(Market_WeaponPap[client])
		{
			case 0, 1, 2, 10, 11, 12, 13, 14, 15:
			{
				if(weapons)
				{
				}
				else
				{
				}
			}
			case 3, 4, 5, 6, 7, 8, 9:
			{
				if(weapons)
				{
					if(b_SoldinPowerHit[client])TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.2);
				}
				else
				{
				}
			}
		}
		if(b_SoldinPowerHit[client])
			i_SoldinCharging[client]=0;
		DestroyTrolldier_Effect(client);
	}
	else if(RocketJump_Count[client])
	{
		i_RocketJump_AirboneTime[client]++;
		switch(Market_WeaponPap[client])
		{
			case 0, 1, 2, 10, 11, 12, 13, 14, 15:
			{
				if(weapons)
				{
					if(RocketJump_Count[client]>1 || i_RocketJump_AirboneTime[client]>15)
						TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.2);
				}
				else
				{
				}
			}
			case 3, 4, 5, 6, 7, 8, 9:
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
static void DestroyTrolldier_Effect(int client)
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

static void Trolldier_HUD(int client, bool weapons)
{
	if(MarketHUDDelay[client] < GetGameTime())
	{
		char C_point_hints[512]="";
		switch(Market_WeaponPap[client])
		{
			case 0, 1, 2, 10, 11, 12, 13, 14, 15:
			{
				b_IsCannibal[client]=false;
				if(RocketJump_Count[client])
					Format(C_point_hints, sizeof(C_point_hints),
					"RocketJump: %i\n", RocketJump_Count[client]);
				if(i_RocketJump_AirboneTime[client])
					Format(C_point_hints, sizeof(C_point_hints),
					"%sAirborne Time: %.1f", C_point_hints, float(i_RocketJump_AirboneTime[client])*0.1);
				if(weapons)
				{
				
				}
				else
				{
				
				}
			}
			case 3, 4, 5, 6, 7, 8, 9:
			{
				b_IsCannibal[client]=true;
				i_SoldinChargingMAX[client]=(b_SoldinLastMann_Buff ? 13 : 15);
				if(RocketJump_Count[client] && b_SoldinPowerHit[client])
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
							if(RocketJump_Count[client])
								Format(C_point_hints, sizeof(C_point_hints),
								"%s [Charge Bonus +%i％]", C_point_hints, RoundToCeil(float(RocketJump_Count[client])*10.0));
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
					if(i_SoldinCharging[client]>=i_SoldinChargingMAX[client] && !b_SoldinPowerHit[client] && RocketJump_Count[client]<1)
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
			NpcStats_SpeedModifyEnemy(victim, 1.5, 0.25, true);
		else
			FreezeNpcInTime(victim, 1.5, true);
		Custom_Knockback(entity, victim, 600.0, true, true, true);
	}
}