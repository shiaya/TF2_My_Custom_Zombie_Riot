#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "npc/scanner/scanner_explode_crash2.wav";
static const char g_AttackReadySounds[] = "weapons/sentry_spot_client.wav";
static const char g_AttackRocketSounds[] = "weapons/sentry_shoot3.wav";
static float SET_XZY_POS[MAXENTITIES][3];
static bool MK2[MAXENTITIES];
static bool Limit[MAXENTITIES];
static bool ISVOLI[MAXENTITIES];
static int OverrideTarget[MAXENTITIES];
static int OverrideAlly[MAXENTITIES];
static float IDiying[MAXENTITIES];

static int SaveSolidFlags[MAXENTITIES];
static int SaveSolidType[MAXENTITIES];

void VictorianDroneFragments_MapStart()
{
	PrecacheModel("models/props_teaser/saucer.mdl");
	PrecacheModel("models/combine_apc_dynamic.mdl");
	PrecacheModel("models/buildables/gibs/sentry1_gib1.mdl");
	PrecacheModel("models/buildables/gibs/sentry2_gib3.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_AttackReadySounds);
	PrecacheSound(g_AttackRocketSounds);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Fragments");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_fragments");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_fragments");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianDroneFragments(client, vecPos, vecAng, ally, data);
}

methodmap VictorianDroneFragments < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAttackSound() 
	{
		EmitSoundToAll(g_AttackRocketSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_AttackReadySounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public VictorianDroneFragments(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianDroneFragments npc = view_as<VictorianDroneFragments>(CClotBody(vecPos, vecAng, "models/props_teaser/saucer.mdl", "1.0", "3000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		SaveSolidFlags[npc.index]=GetEntProp(npc.index, Prop_Send, "m_usSolidFlags");
		SaveSolidType[npc.index]=GetEntProp(npc.index, Prop_Send, "m_nSolidType");
		MK2[npc.index]=false;
		Limit[npc.index]=false;
		ISVOLI[npc.index]=false;
		OverrideTarget[npc.index] = -1;
		OverrideAlly[npc.index] = -1;
		
		bool FactorySpawn;
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(!StrContains(countext[i], "factory"))FactorySpawn=true;
			else if(!StrContains(countext[i], "mk2")){MK2[npc.index]=true;strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Victoria Fragments MK2");}
			else if(!StrContains(countext[i], "limit"))Limit[npc.index]=true;
			else if(!StrContains(countext[i], "isvoli"))ISVOLI[npc.index]=true;
			int targetdata = StringToInt(countext[i]);
			if(IsValidEntity(targetdata))
			{
				if(GetTeam(npc.index) != GetTeam(targetdata))
					OverrideTarget[npc.index] = targetdata;
				else
					OverrideAlly[npc.index] = targetdata;
			}
		}

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 3;
		npc.m_flAttackHappens = GetGameTime(npc.index)+500.0;
		IDiying[npc.index] = 0.0;

		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 1.00;
		
		b_CannotBeKnockedUp[npc.index] = true;
		b_CannotBeSlowed[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		b_IgnoreAllCollisionNPC[npc.index]=true;
		npc.m_bDissapearOnDeath = true;
		npc.m_bisWalking = true;
		npc.m_bFUCKYOU = true;
		npc.Anger = false;
		SET_XZY_POS[npc.index]={0.0, 0.0, 0.0};

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		float Vec[3], Ang[3]={0.0,0.0,0.0};
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable1 = npc.EquipItemSeperate("head", "models/buildables/gibs/sentry1_gib1.mdl",_,1,1.001,_,true);
		Ang[0] = -90.0;
		Ang[1] = 270.0;
		Vec[1] -= 36.5;
		TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 80, 50, 50, 255);

		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable2 = npc.EquipItemSeperate("head", "models/buildables/gibs/sentry2_gib3.mdl",_,1,1.001,_,true);
		Ang[0] = 30.0;
		Ang[1] = 0.0;
		Ang[2] = -90.0;
		Vec[0] -= 10.0;
		Vec[1] -= 31.5;
		Vec[2] -= 21.0;
		TeleportEntity(npc.m_iWearable2, Vec, Ang, NULL_VECTOR);
		
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable3 = npc.EquipItemSeperate("head", "models/buildables/gibs/sentry2_gib3.mdl",_,1,1.001,_,true);
		Ang[0] = 30.0;
		Ang[1] = 0.0;
		Ang[2] = -90.0;
		Vec[0] -= 10.0;
		Vec[1] -= 47.5;
		Vec[2] -= 21.0;
		TeleportEntity(npc.m_iWearable3, Vec, Ang, NULL_VECTOR);
		
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable4 = npc.EquipItemSeperate("head", "models/props_teaser/saucer.mdl",_,1,1.001,_,true);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 80, 50, 50, 255);
		
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.m_iWearable4);
		MakeObjectIntangeable(npc.m_iWearable1);
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable2, "SetParent", npc.m_iWearable4);
		MakeObjectIntangeable(npc.m_iWearable2);
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable3, "SetParent", npc.m_iWearable4);
		MakeObjectIntangeable(npc.m_iWearable3);
		Ang[0] = 0.0;
		Ang[1] = -90.0;
		Ang[2] = 0.0;
		TeleportEntity(npc.m_iWearable4, Vec, Ang, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable4, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable4);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({229, 235, 52, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		GetAbsOrigin(npc.index, Vec);
		if(FactorySpawn)
		{
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
				if (IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianFactory_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
				{
					GetAbsOrigin(entity, Vec);
					break;
				}
			}
		}
		Vec[2]+=45.0;
		TeleportEntity(npc.index, Vec, NULL_VECTOR, NULL_VECTOR);
		NPC_StopPathing(npc.index);
		return npc;
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void ClotThink(int iNPC)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(!npc.m_bisWalking)
	{
		npc.SetVelocity({0.0,0.0,0.0});
		npc.m_flSpeed=0.0;
	}
	else
	{
		npc.m_flSpeed = NpcStats_VictorianCallToArms(npc.index) ? 400.0 : 300.0;
		if(!b_IgnoreAllCollisionNPC[npc.index])b_IgnoreAllCollisionNPC[npc.index]=true;
	}
	//"Source Spaghetti" is made without asking for help. Don't be afraid to ask for help.
	/*float ProjectileDamage = -1.0;
	int attacker = ProjectileDetection(npc.index, _, true, ProjectileDamage);
	if(IsValidClient(attacker))
	{
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float damage = 45.0;
		if(ProjectileDamage<0.0)
		{
			int primary = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary);
			int secondary = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Secondary);
			int melee = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee);
			int active = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
			int GotWeapons = -1;
			if(IsValidEntity(active))
			{
				if(IsValidEntity(primary) && active==primary)GotWeapons=primary;
				else if(IsValidEntity(secondary) && active==secondary)GotWeapons=secondary;
				else if(IsValidEntity(melee) && active==melee)GotWeapons=melee;
			}
			if(IsValidEntity(GotWeapons))
			{
				damage *= Attributes_Get(GotWeapons, 1, 1.0);
				damage *= Attributes_Get(GotWeapons, 2, 1.0);
				damage *= Attributes_Get(GotWeapons, 1000, 1.0);
				damage *= Attributes_Get(GotWeapons, 410, 1.0);
				if(damage<45.0)damage=45.0;
			}
		}
		else damage=ProjectileDamage;
		Explode_Logic_Custom(damage, attacker, attacker, -1, VecSelfNpc, 125.0,_,_,false);
	}
	else if(IsValidEntity(attacker))
	{
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float damage = 150.0;
		if(ProjectileDamage>0.0)damage=ProjectileDamage;
		Explode_Logic_Custom(damage, attacker, attacker, -1, VecSelfNpc, 125.0,_,_,false);
	}*/

	if(npc.m_flNextThinkTime > gameTime)
		return;

	if((!IsValidAlly(npc.index, GetClosestAlly(npc.index)) && !ISVOLI[npc.index] && !IsValidAlly(npc.index, OverrideAlly[npc.index]))
	|| (gameTime > npc.m_flAttackHappens && Limit[npc.index]))
	{
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
		return;
	}

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	int target = npc.m_iTarget;

	float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float DistanceToTarget = GetVectorDistance(VecEnemy, VecSelfNpc, true);
	
	if(npc.m_flGetClosestTargetTime < gameTime || !IsValidEntity(target))
		target = VictoriaFragmentsGetTarget(npc.index, gameTime, (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0));
	
	if(!npc.Anger)
	{
		npc.SetVelocity({0.0,0.0,0.0});
		int LZ = -1;
		if(IsValidEntity(OverrideTarget[npc.index]) && GetTeam(npc.index) != GetTeam(OverrideTarget[npc.index]))LZ = OverrideTarget[npc.index];
		else LZ = GetClosestTarget(npc.index);
		if(IsValidEnemy(npc.index,LZ))
		{
			WorldSpaceCenter(LZ, SET_XZY_POS[npc.index]);
			float Ang[3], OpenSky[3], distance;
			Ang[0]=-90.0;
			LookPoint(LZ, Ang, SET_XZY_POS[npc.index], OpenSky);
			distance = GetVectorDistance(SET_XZY_POS[npc.index], OpenSky);
			if(distance>100.0) SET_XZY_POS[npc.index][2]+=180.0;
			npc.Anger=true;
		}
	}
	else if(!npc.m_bFUCKYOU)
	{
		npc.m_bisWalking = false;
		if(ISVOLI[npc.index])
		{
			float Ang[3];
			npc.GetAttachment("m_vecAbsOrigin", VecSelfNpc, Ang);
			npc.m_iWearable5 = ParticleEffectAt_Parent(VecSelfNpc, "utaunt_poweraura_teamcolor", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
			npc.GetAttachment("", VecSelfNpc, Ang);
			ISVOLI[npc.index]=false;
		}
		if(IsValidEntity(npc.m_iWearable5) && gameTime > IDiying[npc.index])
		{
			int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.01);
			int health = GetEntProp(npc.index, Prop_Data, "m_iHealth")-maxhealth;
			if(health<=0)
			{
				b_NpcForcepowerupspawn[npc.index] = 0;
				i_RaidGrantExtra[npc.index] = 0;
				b_DissapearOnDeath[npc.index] = true;
				b_DoGibThisNpc[npc.index] = true;
				SmiteNpcToDeath(npc.index);
				return;
			}
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			IDiying[npc.index] = gameTime + 1.0;
		}
		
		int AI = VictoriaFragmentsAssaultMode(npc.index, gameTime, target, DistanceToTarget);
		switch(AI)
		{
			case 0://attack
			{
				/*none*/
			}
			case 1://cooldown
			{
				/*none*/
			}
			case 2://reload
			{
				if(npc.m_iOverlordComboAttack < 3)
				{
					if(gameTime > npc.m_flNextMeleeAttack)
					{
						npc.m_iOverlordComboAttack++;
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
					npc.m_flCharge_delay = gameTime + 0.3;
				}
				else
				{
					npc.PlayReloadSound();
					npc.m_flNextMeleeAttack = gameTime + 0.3;
				}
			}
			case 3://notfound
			{
				npc.m_flGetClosestTargetTime=0.0;
				if(npc.m_iOverlordComboAttack < 3)
				{
					if(gameTime > npc.m_flNextMeleeAttack)
					{
						npc.m_iOverlordComboAttack++;
						npc.m_flNextMeleeAttack = gameTime + 0.4;
					}
				}
			}
		}
	}
	else
	{
		if(GetVectorDistance(SET_XZY_POS[npc.index], VecSelfNpc) < 200.0)
		{
			float NPCAng[3];
			SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", SaveSolidFlags[npc.index]);
			SetEntProp(npc.index, Prop_Data, "m_nSolidType", SaveSolidType[npc.index]);
			if(GetTeam(npc.index) == TFTeam_Red)
				SetEntityCollisionGroup(npc.index, 24);
			else
				SetEntityCollisionGroup(npc.index, 9);
			npc.m_flSpeed = 0.0;
			VecSelfNpc[2] += 500.0;
			npc.SetVelocity({0.0,0.0,0.0});
			PluginBot_Jump(npc.index, VecSelfNpc);
			GetEntPropVector(npc.m_iWearable4, Prop_Data, "m_angRotation", NPCAng);
			NPCAng[2]=0.0;
			NPCAng[1]+=180.0;
			NPCAng[0]=0.0;
			SetEntPropVector(npc.m_iWearable4, Prop_Data, "m_angRotation", NPCAng);
			npc.m_bFUCKYOU = false;
			npc.m_flNextThinkTime = gameTime + 0.2;
			if(Limit[npc.index])
				npc.m_flAttackHappens = gameTime + (MK2[npc.index] ? 30.0 : 20.0);
		}
		else
		{
			if(gameTime > npc.m_flCharge_delay)
			{
				float Pathing[3], Npvel[3], NPCAng[3];
				MakeObjectIntangeable(npc.index);
				SubtractVectors(SET_XZY_POS[npc.index], VecSelfNpc, Pathing);
				GetEntPropVector(npc.m_iWearable4, Prop_Data, "m_angRotation", NPCAng);
				npc.GetVelocity(Npvel);
				float NPCSpeed = npc.m_flSpeed;
				NormalizeVector(Pathing, Npvel);
				ScaleVector(Npvel, NPCSpeed);
				GetVectorAngles(Npvel, NPCAng);
				npc.SetVelocity(Npvel);
				NPCAng[2]=0.0;
				NPCAng[0]=0.0;
				SetEntPropVector(npc.m_iWearable4, Prop_Data, "m_angRotation", NPCAng);
			}
		}
		return;
	}
}

int VictoriaFragmentsGetTarget(int iNPC, float gameTime, float distance)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(iNPC);
	if(IsValidEnemy(npc.index,npc.m_iTarget))
	{
		if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,distance,_,_,_,_,true,_,_,true);
		}
	}
	else
	{
		npc.m_iTarget = GetClosestTarget(npc.index,_,distance,_,_,_,_,true,_,_,true);
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,distance,_,_,_,_,_,_, true);
		}		
	}
	if(!IsValidEnemy(npc.index,npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index,_,distance,_,_,_,_,_,_, true);
	}
	npc.m_flGetClosestTargetTime = gameTime + 1.0;
	return npc.m_iTarget;
}

int VictoriaFragmentsAssaultMode(int iNPC, float gameTime, int target, float distance)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(iNPC);
	if(npc.m_iOverlordComboAttack < 1 || gameTime < npc.m_flCharge_delay)
		return 2;
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0))
		{
			npc.PlayAttackSound();
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
			{
				target = TR_GetEntityIndex(swingTrace);	
					
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				float origin[3], angles[3];
				view_as<CClotBody>(npc.index).GetAttachment("partyhat", origin, angles);
				ShootLaser(npc.index, "bullet_tracer01_red", origin, vecHit, false);
				npc.m_flNextMeleeAttack = gameTime + 0.3;
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 25.0;
					if(MK2[npc.index])
					{
						damageDealt +=50.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 4.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						if(!ShouldNpcDealBonusDamage(target))
							Explode_Logic_Custom(damageDealt/5.0, npc.index, npc.index, -1, vecHit, 125.0,_,_,_,3, _, 1.0);
					}
					else
					{
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 4.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						if(!ShouldNpcDealBonusDamage(target))
							Explode_Logic_Custom(damageDealt/10.0, npc.index, npc.index, -1, vecHit, 85.0,_,_,_,3, _, 1.0);
					}
				}
				npc.m_iOverlordComboAttack--;
			}
			delete swingTrace;
			return 0;
		}
		return 3;
	}
	return 1;
}

static void ClotDeath(int entity)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(entity);

	npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}

public bool LookPoint(int client, float flAng[3], float flPos[3], float pos[3])
{
	Handle trace = TR_TraceRayFilterEx(flPos, flAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterIgnorePlayersAndSelf, client);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
}

static bool TraceEntityFilterIgnorePlayersAndSelf(int entity, int contentsMask, any data)
{
	if(entity == data)
		return false;

	if(1 <= entity <= MaxClients)
		return false;

	return true;
}

stock int ProjectileDetection(int entity, float Targetdist=146.0, bool Remove = false, float DMG)
{
	float position[3], position2[3], distance[3], dist;
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	int team = GetTeam(entity);
	bool success;
	int projectile = -1;
	int Owner = -1;
	while((projectile = FindEntityByClassname(projectile, "tf_projectile_*")) != INVALID_ENT_REFERENCE)
	{
		if(HasEntProp(projectile, Prop_Send, "m_hOriginalLauncher"))
			Owner=GetEntPropEnt(projectile, Prop_Send, "m_hOriginalLauncher");
		else if(HasEntProp(projectile, Prop_Send, "m_hOwnerprojectile"))
			Owner=GetEntPropEnt(projectile, Prop_Data, "m_hOwnerprojectile");
		else if(HasEntProp(projectile, Prop_Data, "m_hOwnerEntity"))
			Owner=GetEntPropEnt(projectile, Prop_Data, "m_hOwnerEntity");
		else
			continue;
		int OwnerTeam=TFTeam_Stalkers;
		if(IsValidEntity(Owner))
			 OwnerTeam = GetTeam(Owner);
		if(team!=OwnerTeam)
		{
			GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", position2);
			MakeVectorFromPoints(position, position2, distance);
			dist = GetVectorLength(distance);
			if(dist<Targetdist)
			{
				if(HasEntProp(projectile, Prop_Send, "m_flDamage"))
					DMG = GetEntPropFloat(projectile, Prop_Send, "m_flDamage");
				else DMG=-1.0;
				if(Remove)
				{
					if(projectile <= 0 || !IsValidEntity(projectile))
						continue;
					RemoveEntity(projectile);
					AcceptEntityInput(projectile, "Kill");
				}
				success=true;
				continue;
			}
			else continue;
		}
	}
	if(success)
		return Owner;
	return -1;
}