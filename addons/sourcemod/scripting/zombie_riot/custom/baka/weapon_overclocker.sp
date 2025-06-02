#pragma semicolon 1
#pragma newdecls required

static bool UberOn[MAXTF2PLAYERS];
//static Handle OC_Timer = null;

public void OClocker_OnMapStart()
{
	Zero(UberOn);
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
}

public Action Timer_Uber(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if(!IsValidEntity(medigun))return Plugin_Stop;
	int client = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
	int target = old_GetHealingTarget(client);
	float charge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
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
	return Plugin_Continue;
}

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

stock int old_GetHealingTarget(int client, bool checkgun=false)
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