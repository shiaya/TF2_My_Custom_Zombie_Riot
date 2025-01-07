#pragma semicolon 1
#pragma newdecls required

static bool OC_Weapon_On[MAXTF2PLAYERS][MAXTF2PLAYERS];
static bool Kritzkrieg_One[MAXTF2PLAYERS];\
static float Kritzkrieg_Buff2[MAXENTITIES];
static float Kritzkrieg_Buff3[MAXENTITIES];
static bool UberOn[MAXTF2PLAYERS];
//static Handle OC_Timer = null;

public void OClocker_OnMapStart()
{
	Zero(Kritzkrieg_One);
	Zero(UberOn);
	for(int GetHealtarget=1; GetHealtarget<=MaxClients; GetHealtarget++)
	{
		if(!IsValidClient(GetHealtarget))
			continue;
		for(int client=1; client<=MaxClients; client++)
		{
			if(!IsValidClient(client))
				continue;
			OC_Weapon_On[GetHealtarget][client]=false;
		}
	}
	HookEvent("player_chargedeployed", OnUberDeployed);
}

public void OnUberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsValidClient(client) || !IsPlayerAlive(client))return;
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(!IsValidEntity(medigun))
		return;
	if(i_CustomWeaponEquipLogic[medigun]!=WEAPON_OVERCLOCKER)
		return;
	if((Attributes_Get(medigun, 304, 0.0)==0.0 || Attributes_Get(medigun, 2046, 0.0)!=5.0) && (Attributes_Get(medigun, 88, 0.0)==5.0 || Attributes_Get(medigun, 18, 0.0)!=1.0))
	{
		float clientpos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientpos);
		float entitypos[3], distance;
		int Dohit;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
				distance = GetVectorDistance(clientpos, entitypos);
				if(distance<850.0)
				{
					float damage=(b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] ? 1.5 : 1.0)*((5000.0*Attributes_GetOnPlayer(client, 8, true, true))+(Pow(float(CashSpentTotal[client]), 1.18)/10.0))+SDKCall_GetMaxHealth(client);
					if(Dohit>1) damage/=Dohit;
					NpcStats_SpeedModifyEnemy(entity, (b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] ? 1.0 : 3.0), 0.35, true);
					ApplyStatusEffect(client, entity, "Silenced", (b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] ? 1.0 : 3.0));
					SDKHooks_TakeDamage(entity, client, client, damage, DMG_BLAST|DMG_PREVENT_PHYSICS_FORCE, GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary));
					Dohit++;
				}
			}
		}
		ParticleEffectAt(clientpos, "hightower_explosion", 1.0);
		EmitSoundToAll("weapons/explode3.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, clientpos);
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 0.0);
		HealPointToReinforce(client, 1, 0.15);
		AddHealthToUbersaw(client, 1, 0.15);
		return;
	}
	CreateTimer(0.1, Timer_Uber, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if(Attributes_Get(medigun, 304, 0.0)==0.0 || Attributes_Get(medigun, 2046, 0.0)!=5.0)
	{
		int target = GetHealingTarget(client);
		if(IsValidClient(target) && IsPlayerAlive(target)) GiveArmorViaPercentage(target, 0.5, 1.0);
		GiveArmorViaPercentage(client, 0.5, 1.0);
		UberOn[client]=true;
		//if(OC_Timer == null) OC_Timer = CreateTimer(0.1, Timer_OCW, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_Uber(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if(!IsValidEntity(medigun))return Plugin_Stop;
	int client = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
	int target = GetHealingTarget(client);
	float charge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	for(int NonHealingTarget=1; NonHealingTarget<=MaxClients; NonHealingTarget++)
	{
		if(!IsValidClient(NonHealingTarget))
			continue;
		OC_Weapon_On[NonHealingTarget][client]=false;
	}
	if((!IsValidClient(client) && !IsPlayerAlive(client))||charge <= 0.05)
	{
		UberOn[client]=false;
		return Plugin_Stop;
	}
	if(Attributes_Get(medigun, 304, 0.0)==1.0 || Attributes_Get(medigun, 2046, 0.0)==5.0)
	{
		float Healing_Value=Attributes_GetOnPlayer(client, 8, true, true);
		if(IsValidClient(target) && IsPlayerAlive(target))
		{
			if(dieingstate[target] > 0)
			{
				if(i_CurrentEquippedPerk[client] == 1)
				{
					SetEntityHealth(target,  GetClientHealth(target) + 12);
					dieingstate[target] -= 10;
				}
				else
				{
					SetEntityHealth(target,  GetClientHealth(target) + 6);
					dieingstate[target] -= 5;
				}
				if(dieingstate[target] < 1)
				{
					dieingstate[target] = 1;
				}
			}
			else
			{
				float Healing_Amount=5.0*Healing_Value;
				if(f_TimeUntillNormalHeal[target] > GetGameTime())
				{
					Healing_Amount *= 0.5;
				}
				if(Healing_Amount < 10.0)
				{
					Healing_Amount = 10.0;
				}
				HealEntityGlobal(client, target, Healing_Amount, 1.5, _, HEAL_SELFHEAL);
			}
			if(Armor_Charge[target] < 0)
			{
				Armor_Charge[target]=0;
			}
			HealPointToReinforce(client, 1, 0.0015);
			AddHealthToUbersaw(client, 1, 0.0015);
		}
		if(IsValidClient(client) && IsPlayerAlive(client))
		{
			if(dieingstate[client] > 0)
			{
				if(i_CurrentEquippedPerk[client] == 1)
				{
					SetEntityHealth(client,  GetClientHealth(client) + 12);
					dieingstate[client] -= 20;
				}
				else
				{
					SetEntityHealth(client,  GetClientHealth(client) + 6);
					dieingstate[client] -= 10;
				}
				if(dieingstate[client] < 1)
				{
					dieingstate[client] = 1;
				}
			}
			else
			{
				float Healing_Amount=5.0*Healing_Value;
				if(f_TimeUntillNormalHeal[client] > GetGameTime())
				{
					Healing_Amount *= 0.5;
				}
				if(Healing_Amount < 10.0)
				{
					Healing_Amount = 10.0;
				}
				HealEntityGlobal(client, client, Healing_Amount, 1.5, _, HEAL_SELFHEAL);
			}
			if(Armor_Charge[client] < 0)
			{
				Armor_Charge[client]=0;
			}
		}
	}
	else
	{
		if(IsValidClient(target) && IsPlayerAlive(target))
		{
			f_Overclocker_Buff[target] = GetGameTime()+0.2;
			Overclock_Magical(target, 0.2, true);
		}
		else if(IsValidEntity(target) && !b_NpcHasDied[target] && GetTeam(client) == GetTeam(target))
		{
			f_Overclocker_Buff[target] = GetGameTime()+0.2;
		}
		if(IsValidClient(client) && IsPlayerAlive(client))
		{
			f_Overclocker_Buff[client] = GetGameTime()+0.2;
			Overclock_Magical(client, 0.2, true);
		}
	}
	return Plugin_Continue;
}

/*public Action Timer_OCW(Handle timer)
{
	bool Kritzkrieg, AllOFF;
	for(int client=1; client<=MaxClients; client++)
	{
		if(!IsValidClient(client))
			continue;
		if(!IsPlayerAlive(client))
			continue;
		for(int GetHealtarget=1; GetHealtarget<=MaxClients; GetHealtarget++)
		{
			if(!IsValidClient(GetHealtarget))
				continue;
			if(UberOn[GetHealtarget] && IsPlayerAlive(GetHealtarget))
			{
				Kritzkrieg=true;
			}
		}
	
		int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		
		if(Kritzkrieg && f_Overclocker_Buff[client] > GetGameTime())
		{
			if(!Kritzkrieg_One[client])
			{
				//PrintToChat(client, "Add Kritzkrieg");
				if(IsValidEntity(primary))
					Overclock_Weapon(client, primary);
				if(IsValidEntity(secondary))
					Overclock_Weapon(client, secondary);
				if(IsValidEntity(melee))
					Overclock_Weapon(client, melee);
			}
			Kritzkrieg_One[client]=true;
		}
		else if(Kritzkrieg_One[client])
		{
			//PrintToChat(client, "End Kritzkrieg");
			if(IsValidEntity(primary))
				Overclock_WeaponEnd(client, primary);
			if(IsValidEntity(secondary))
				Overclock_WeaponEnd(client, secondary);
			if(IsValidEntity(melee))
				Overclock_WeaponEnd(client, melee);
			Kritzkrieg_One[client]=false;
		}
		if(!Kritzkrieg_One[client] && !Kritzkrieg)
			AllOFF=true;
		else AllOFF=false;
	}
	if(AllOFF)
	{
		OC_Timer = null;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}*/

public void Nitro_NPCTakeDamage(int victim, int attacker, float &damage, int &damagetype, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	if(Attributes_Get(weapon, 88, 0.0)!=5.0 || Attributes_Get(weapon, 18, 0.0)==1.0)
		return;
	char mediclassname[64];
	if(IsValidEntity(weapon) && GetEntityClassname(weapon, mediclassname, sizeof(mediclassname)) && !StrContains(mediclassname, "tf_weapon_medigun", false))
	{
		if((damagetype | DMG_TRUEDAMAGE))
		{
			Handle AttackPack;
			CreateDataTimer(0.01, Timer_Delay_Attack, AttackPack, TIMER_FLAG_NO_MAPCHANGE);
			WritePackCell(AttackPack, damage*0.15);
			WritePackCell(AttackPack, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			WritePackCell(AttackPack, victim);
			WritePackCell(AttackPack, attacker);
			damage*=0.85;
		}
		SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel")+0.0025);
	}
}

public Action Timer_Delay_Attack(Handle timer, Handle AttackPack)
{
	ResetPack(AttackPack);
	float AttackDMG=ReadPackCell(AttackPack);
	int DMGType=(ReadPackCell(AttackPack));
	int victim=ReadPackCell(AttackPack), attacker=ReadPackCell(AttackPack);
	SDKHooks_TakeDamage(victim, attacker, attacker, AttackDMG, DMGType);
	return Plugin_Continue;
}

stock int GetHealingTarget(int client, bool checkgun=false)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(!checkgun)
	{
		if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
			return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");

		return -1;
	}

	if(IsValidEntity(medigun))
	{
		static char classname[64];
		GetEntityClassname(medigun, classname, sizeof(classname));
		if(StrEqual(classname, "tf_weapon_medigun", false))
		{
			if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
				return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
		}
	}
	return -1;
}

public void Overclock_Magical(int client, float Scale, bool apply)
{
	int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	bool Magical;
	if((IsValidEntity(primary) && i_IsWandWeapon[primary])
	||(IsValidEntity(secondary) && i_IsWandWeapon[secondary])
	||(IsValidEntity(melee) && i_IsWandWeapon[melee])) Magical=true;
	if(Magical)
	{
		int MaxMana = RoundToCeil((800.0*Mana_Regen_Level[client]));
		if(apply)
		{
			int AddMana = Current_Mana[client]+RoundToCeil(MaxMana*Scale);
			if(AddMana>MaxMana)
				AddMana=MaxMana;
			Current_Mana[client]=AddMana;
			return;
		}
		Current_Mana[client]=RoundToCeil(MaxMana*Scale);
	}
}

stock void Overclock_Weapon(int client, int Weapon, float muit=1.0)
{
	if(IsValidEntity(Weapon))
	{
		//float ODamage = Attributes_Get(Weapon, 2);
		float ASpeed = Attributes_Get(Weapon, 6);
		//float ASpeed_alt = Attributes_Get(Weapon, 5);
		float RSpeed = Attributes_Get(Weapon, 97);
		float ASpread = Attributes_Get(Weapon, 106);
		float SCharge = Attributes_Get(Weapon, 41);
		float BlastRadius = Attributes_Get(Weapon, 99);
		float SpinUP = Attributes_Get(Weapon, 87);
		float PerShot = Attributes_Get(Weapon, 45);
		float PSpeed = Attributes_Get(Weapon, 103);
		float BOMBChargeRate = Attributes_Get(Weapon, 670);
		float SSpeed = Attributes_Get(Weapon, 343);
		float SRange = Attributes_Get(Weapon, 344);
		float SDamage = Attributes_Get(Weapon, 287);
		//float HealUP = Attributes_Get(Weapon, 8);
		char classname[64];
		if(GetEntityClassname(Weapon, classname, sizeof(classname)) && !StrContains(classname, "tf_weapon_wrench", false))
		{
			if(!SSpeed) SSpeed=1.0;
			if(!SRange) SRange=1.0;
			if(!SDamage) SDamage=1.0;
		}
		
		//float Magical = Attributes_Get(Weapon, 410);
		
		/*if(ODamage)
		{
			switch(i_CustomWeaponEquipLogic[Weapon])
			{
				case WEAPON_FUSION, WEAPON_NEARL, WEAPON_FUSION_PAP1, WEAPON_FUSION_PAP2, WEAPON_SICCERINO, WEAPON_EXPLORER: ODamage+=6.75*muit;
				default: ODamage+=4.7*muit;
			}
			ODamage+=10.0*muit;
			Attributes_Set(Weapon, 2, ODamage);
		}
		if(Magical)
		{
			if(i_CustomWeaponEquipLogic[Weapon]==WEAPON_DIMENSION_RIPPER)
				Magical+=4.25*muit;
			else
				Magical+=2.8*muit;
			Magical+=5.0*muit;
			Attributes_Set(Weapon, 410, Magical);
		}*/
		if(ASpeed)
		{
			/*switch(i_CustomWeaponEquipLogic[Weapon])
			{
				case WEAPON_FUSION, WEAPON_NEARL, WEAPON_FUSION_PAP1, WEAPON_FUSION_PAP2, WEAPON_SICCERINO, WEAPON_EXPLORER: ASpeed-=0.25*muit;
				case WEAPON_DIMENSION_RIPPER: ASpeed-=0.01*muit;
				default: ASpeed-=0.65*muit;
			}*/
			ASpeed-=0.05*muit;
			Attributes_Set(Weapon, 6, ASpeed);
		}
		/*else if(ASpeed_alt)
		{
			ASpeed_alt-=0.75*muit;
			Attributes_Set(Weapon, 5, ASpeed_alt);
		}*/
		if(RSpeed)
		{
			RSpeed-=0.75*muit;
			Attributes_Set(Weapon, 97, RSpeed);
		}
		if(ASpread)
		{
			ASpread-=0.5*muit;
			Attributes_Set(Weapon, 106, ASpread);
		}
		if(SCharge)
		{
			SCharge+=2.0*muit;
			Attributes_Set(Weapon, 41, SCharge);
		}
		if(BlastRadius)
		{
			BlastRadius+=2.0*muit;
			Attributes_Set(Weapon, 99, BlastRadius);
		}
		if(SpinUP)
		{
			SpinUP-=0.5*muit;
			Attributes_Set(Weapon, 87, SpinUP);
		}
		if(PerShot)
		{
			PerShot+=1.0*muit;
			Attributes_Set(Weapon, 45, PerShot);
		}
		if(PSpeed)
		{
			PSpeed+=0.5*muit;
			Attributes_Set(Weapon, 103, PSpeed);
		}
		if(BOMBChargeRate)
		{
			BOMBChargeRate-=0.5;
			Attributes_Set(Weapon, 670, BOMBChargeRate);
		}
		if(SSpeed)
		{
			SSpeed-=0.5*muit;
			Attributes_Set(Weapon, 343, SSpeed);
		}
		if(SRange)
		{
			SRange+=2.0*muit;
			Attributes_Set(Weapon, 344, SRange);
		}
		if(SDamage)
		{
			SDamage+=2.0*muit;
			Attributes_Set(Weapon, 287, SDamage);
		}
		/*if(HealUP)
		{
			HealUP+=5.0*muit;
			Attributes_Set(Weapon, 8, HealUP);
		}*/
	}
}

stock void Overclock_WeaponEnd(int client, int Weapon, float muit=1.0)
{
	if(IsValidEntity(Weapon))
	{
		//float ODamage = Attributes_Get(Weapon, 2);
		float ASpeed = Attributes_Get(Weapon, 6);
		//float ASpeed_alt = Attributes_Get(Weapon, 5);
		float RSpeed = Attributes_Get(Weapon, 97);
		float ASpread = Attributes_Get(Weapon, 106);
		float SCharge = Attributes_Get(Weapon, 41);
		float BlastRadius = Attributes_Get(Weapon, 99);
		float SpinUP = Attributes_Get(Weapon, 87);
		float PerShot = Attributes_Get(Weapon, 45);
		float PSpeed = Attributes_Get(Weapon, 103);
		float BOMBChargeRate = Attributes_Get(Weapon, 670);
		float SSpeed = Attributes_Get(Weapon, 343);
		float SRange = Attributes_Get(Weapon, 344);
		float SDamage = Attributes_Get(Weapon, 287);
		//float HealUP = Attributes_Get(Weapon, 8);
		//float Magical = Attributes_Get(Weapon, 410);
		
		/*if(ODamage)
		{
			switch(i_CustomWeaponEquipLogic[Weapon])
			{
				case WEAPON_FUSION, WEAPON_NEARL, WEAPON_FUSION_PAP1, WEAPON_FUSION_PAP2, WEAPON_SICCERINO, WEAPON_EXPLORER: ODamage+=6.75*muit;
				default: ODamage+=4.7*muit;
			}
			ODamage-=10.0*muit;
			Attributes_Set(Weapon, 2, ODamage);
		}
		if(Magical)
		{
			if(i_CustomWeaponEquipLogic[Weapon]==WEAPON_DIMENSION_RIPPER)
				Magical+=4.25*muit;
			else
				Magical+=2.8*muit;
			Magical-=5.0*muit;
			Attributes_Set(Weapon, 410, Magical);
		}*/
		if(ASpeed)
		{
			/*switch(i_CustomWeaponEquipLogic[Weapon])
			{
				case WEAPON_FUSION, WEAPON_NEARL, WEAPON_FUSION_PAP1, WEAPON_FUSION_PAP2, WEAPON_SICCERINO, WEAPON_EXPLORER: ASpeed-=0.25*muit;
				case WEAPON_DIMENSION_RIPPER: ASpeed-=0.01*muit;
				default: ASpeed-=0.65*muit;
			}*/
			ASpeed+=0.05*muit;
			Attributes_Set(Weapon, 6, ASpeed);
		}
		/*else if(ASpeed_alt)
		{
			ASpeed_alt+=0.75*muit;
			Attributes_Set(Weapon, 5, ASpeed_alt);
		}*/
		if(RSpeed)
		{
			RSpeed+=0.75*muit;
			Attributes_Set(Weapon, 97, RSpeed);
		}
		if(ASpread)
		{
			ASpread+=0.5*muit;
			Attributes_Set(Weapon, 106, ASpread);
		}
		if(SCharge)
		{
			SCharge-=2.0*muit;
			Attributes_Set(Weapon, 41, SCharge);
		}
		if(BlastRadius)
		{
			BlastRadius-=2.0*muit;
			Attributes_Set(Weapon, 99, BlastRadius);
		}
		if(SpinUP)
		{
			SpinUP+=0.5*muit;
			Attributes_Set(Weapon, 87, SpinUP);
		}
		if(PerShot)
		{
			PerShot-=1.0*muit;
			Attributes_Set(Weapon, 45, PerShot);
		}
		if(PSpeed)
		{
			PSpeed-=0.5*muit;
			Attributes_Set(Weapon, 103, PSpeed);
		}
		if(BOMBChargeRate)
		{
			BOMBChargeRate+=0.5;
			Attributes_Set(Weapon, 670, BOMBChargeRate);
		}
		if(SSpeed)
		{
			SSpeed+=0.5*muit;
			Attributes_Set(Weapon, 343, SSpeed);
		}
		if(SRange)
		{
			SRange-=2.0*muit;
			Attributes_Set(Weapon, 344, SRange);
		}
		if(SDamage)
		{
			SDamage-=2.0*muit;
			Attributes_Set(Weapon, 287, SDamage);
		}
		/*if(HealUP)
		{
			HealUP-=5.0*muit;
			Attributes_Set(Weapon, 8, HealUP);
		}*/
	}
}

stock void ModifyOverclockBuff(int entity, int type, float buffammount, bool GrantBuff = true, float buffammount2, float buffammount3)
{
	float BuffValueDo = MaxNumBuffValue(buffammount, 1.0, PlayerCountBuffAttackspeedScaling);
	float BuffValueDo2 = MaxNumBuffValue(buffammount2, 1.0, PlayerCountBuffAttackspeedScaling);
	float BuffValueDo3 = MaxNumBuffValue(buffammount3, 1.0, PlayerCountBuffAttackspeedScaling);
	if(type == 1)
	{
		int i, weapon;
		while(TF2_GetItem(entity, weapon, i))
		{
			if(Kritzkrieg_Buff[weapon] == 0.0 && !i_IsWandWeapon[weapon])
			{
				if(GrantBuff)
				{
					Kritzkrieg_Buff[weapon] = BuffValueDo;
					Kritzkrieg_Buff2[weapon] = BuffValueDo2;
					Kritzkrieg_Buff3[weapon] = BuffValueDo3;
					if(Attributes_Has(weapon, 6))
						Attributes_SetMulti(weapon, 6, BuffValueDo);	// Fire Rate
					
					if(Attributes_Has(weapon, 97))
						Attributes_SetMulti(weapon, 97, BuffValueDo);	// Reload Time
						
					if(Attributes_Has(weapon, 670))
						Attributes_SetMulti(weapon, 670, BuffValueDo);	// SpinUP
					
					if(Attributes_Has(weapon, 87))
						Attributes_SetMulti(weapon, 87, BuffValueDo);	// BOMB Charge Rate
					
					if(Attributes_Has(weapon, 343))
						Attributes_SetMulti(weapon, 343, BuffValueDo);	// Sentry Fire Rate
					
					if(Attributes_Has(weapon, 344))
						Attributes_SetMulti(weapon, 344, BuffValueDo2);	// Sentry Range
					
					if(Attributes_Has(weapon, 287))
						Attributes_SetMulti(weapon, 287, BuffValueDo2);	// Sentry DMG
					
					if(Attributes_Has(weapon, 41))
						Attributes_SetMulti(weapon, 41, BuffValueDo2);	// Sniper Charge Rate
					
					if(Attributes_Has(weapon, 99))
						Attributes_SetMulti(weapon, 99, BuffValueDo2);	// BlastRadius
						
					if(Attributes_Has(weapon, 103))
						Attributes_SetMulti(weapon, 103, BuffValueDo3);	// SpinUP
					
					if(Attributes_Has(weapon, 45))
						Attributes_SetMulti(weapon, 45, BuffValueDo3);	// PerShot
				}
			}
			else
			{
				if(!GrantBuff)
				{
					if(Kritzkrieg_Buff[weapon] != 0.0 && !i_IsWandWeapon[weapon])
					{
						if(Attributes_Has(weapon, 6))
							Attributes_SetMulti(weapon, 6, 1.0 / (Kritzkrieg_Buff[weapon]));	// Fire Rate
						
						if(Attributes_Has(weapon, 97))
							Attributes_SetMulti(weapon, 97, 1.0 / (Kritzkrieg_Buff[weapon]));	// Reload Time
							
						if(Attributes_Has(weapon, 670))
							Attributes_SetMulti(weapon, 670, 1.0 / (Kritzkrieg_Buff[weapon]));	// SpinUP
						
						if(Attributes_Has(weapon, 87))
							Attributes_SetMulti(weapon, 87, 1.0 / (Kritzkrieg_Buff[weapon]));	// BOMB Charge Rate
						
						if(Attributes_Has(weapon, 343))
							Attributes_SetMulti(weapon, 343, 1.0 / (Kritzkrieg_Buff[weapon]));	// Sentry Fire Rate
						
						if(Attributes_Has(weapon, 344))
							Attributes_SetMulti(weapon, 344, 1.0 / (Kritzkrieg_Buff2[weapon]));	// Sentry Range
						
						if(Attributes_Has(weapon, 287))
							Attributes_SetMulti(weapon, 287, 1.0 / (Kritzkrieg_Buff2[weapon]));	// Sentry DMG
						
						if(Attributes_Has(weapon, 41))
							Attributes_SetMulti(weapon, 41, 1.0 / (Kritzkrieg_Buff2[weapon]));	// Sniper Charge Rate
						
						if(Attributes_Has(weapon, 99))
							Attributes_SetMulti(weapon, 99, 1.0 / (Kritzkrieg_Buff2[weapon]));	// BlastRadius
							
						if(Attributes_Has(weapon, 103))
							Attributes_SetMulti(weapon, 103, 1.0 / (Kritzkrieg_Buff3[weapon]));	// SpinUP
						
						if(Attributes_Has(weapon, 45))
							Attributes_SetMulti(weapon, 45, 1.0 / (Kritzkrieg_Buff3[weapon]));	// PerShot

						Kritzkrieg_Buff[weapon] = 0.0;
					}
				}
			}
		}
	}
	else if(type == 2)
	{
		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
		if(StrEqual(npc_classname, "npc_citizen"))
		{
			Citizen npc = view_as<Citizen>(entity);
			if(Kritzkrieg_Buff[entity] == 0.0)
			{
				if(GrantBuff)
				{
					Kritzkrieg_Buff[entity] = BuffValueDo;
					npc.m_fGunFirerate *= BuffValueDo;
					npc.m_fGunReload *= BuffValueDo;
				}
			}
			else
			{
				if(!GrantBuff)
				{
					npc.m_fGunFirerate /= (Kritzkrieg_Buff[entity]);
					npc.m_fGunReload /= (Kritzkrieg_Buff[entity]);
					Kritzkrieg_Buff[entity] = 0.0;
				}
			}
		}
		else if(entity > MaxClients)
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(Kritzkrieg_Buff[entity] == 0.0)
			{
				if(GrantBuff)
				{
					Kritzkrieg_Buff[entity] = BuffValueDo;
					npc.BonusFireRate *= BuffValueDo;
				}
			}
			else
			{
				if(!GrantBuff)
				{
					npc.BonusFireRate /= (Kritzkrieg_Buff[entity]);
					Kritzkrieg_Buff[entity] = 0.0;
				}
			}
		}
	}
}