#pragma semicolon 1
#pragma newdecls required

static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";
static int NPCId;

static float Vs_DelayTime[MAXENTITIES];
static int Vs_Target[MAXENTITIES];
static int Vs_ParticleSpawned[MAXENTITIES];
static float Vs_Temp_Pos[MAXENTITIES][3];
static int Vs_RNDTarget;

static int gLaser1;
static int gRedPoint;
static int g_BeamIndex_heal;
static int g_HALO_Laser;

int VictorianPrecisionStrike_ID()
{
	return NPCId;
}

void Victoria_Precision_Strike_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Precision Strike");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_precision_strike");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_precision_strike");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	PrecacheModel("models/player/spy.mdl");
	gRedPoint = PrecacheModel("sprites/redglow1.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	g_BeamIndex_heal = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_HALO_Laser = PrecacheModel("materials/sprites/halo01.vmt", true);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Victoria_Precision_Strike(client, vecPos, vecAng, ally, data);
}

methodmap Victoria_Precision_Strike < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayBoomSound(){
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIncomingBoomSound(){
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public Victoria_Precision_Strike(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ally = TFTeam_Stalkers;
		Victoria_Precision_Strike npc = view_as<Victoria_Precision_Strike>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "19721121", ally, false, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		bool Online=false;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && i_NpcInternalId[entity] == VictorianPrecisionStrike_ID() && !b_NpcHasDied[entity])
				Online=true;
		}
		if(Online)
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			CPrintToChatAll("{skyblue}The Canon's shooter is already here. Instead, someone else is interested in the place....");
			NPC_SpawnNext(true, true, -1);
		
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		
		func_NPCDeath[npc.index] = view_as<Function>(Victoria_Precision_Strike_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Victoria_Precision_Strike_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Victoria_Precision_Strike_ClotThink);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		Vs_RechargeTimeMax[npc.index] = 20.0;
		Victoria_Support_RechargeTimeMax(npc.index, 20.0);
		Vs_RNDTarget = GetRandomInt(0, 4);
		
		AddNpcToAliveList(npc.index, 1);
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		b_NoHealthbar[npc.index]=true;
		npc.i_GunMode = Waves_GetRound();
		if(IsValidEntity(i_InvincibleParticle[npc.index]))
		{
			int particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
			SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
			SetEntityRenderColor(particle, 255, 255, 255, 1);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
		}
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
			
		if(ally != TFTeam_Red)
		{
			int Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 750.0);
			switch(Decicion)
			{
				case 2:
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 500.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 250.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 0.0);
						}
					}
				}
				case 3:
				{
					//todo code on what to do if random teleport is disabled
				}
			}
		}
		
		b_thisNpcIsABoss[npc.index] = true;
		if(!IsValidEntity(RaidBossActive))
		{
			RaidModeTime = FAR_FUTURE;
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = true;
			RaidModeScaling = 19.721;
		}
		
		return npc;
	}
}

static void Victoria_Precision_Strike_ClotThink(int iNPC)
{
	Victoria_Precision_Strike npc = view_as<Victoria_Precision_Strike>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.i_GunMode <= (Waves_GetRound() - 3) || RaidbossIgnoreBuildingsLogic(1) || LastMann)
	{
		float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		VecSelfNpcabs[2] += 85.0;
		Event event = CreateEvent("show_annotation");
		if(event)
		{
			event.SetFloat("worldPosX", VecSelfNpcabs[0]);
			event.SetFloat("worldPosY", VecSelfNpcabs[1]);
			event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
		//	event.SetInt("follow_entindex", 0);
			event.SetFloat("lifetime", 5.0);
		//	event.SetInt("visibilityBitfield", (1<<client));
			//event.SetBool("show_effect", effect);
			event.SetString("text", "PowerUp Spawn!");
			event.SetString("play_sound", "vo/null.mp3");
			IdRef++;
			event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
			event.Fire();
		}
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
		return;
	}
	
	bool GETVictoria_Support = Victoria_Support(npc);
	if(GETVictoria_Support)Vs_RNDTarget = GetRandomInt(0, 4);
	
	bool sniper = view_as<bool>((npc.i_GunMode + 1) == Waves_GetRound());
	if(sniper)
	{
		/*none*/
	}
	
	if(!IsValidEntity(RaidBossActive))
	{
		RaidModeTime = FAR_FUTURE;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = true;
		RaidModeScaling = 19.721;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
}

static Action Victoria_Precision_Strike_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Victoria_Precision_Strike npc = view_as<Victoria_Precision_Strike>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Victoria_Precision_Strike_NPCDeath(int entity)
{
	Victoria_Precision_Strike npc = view_as<Victoria_Precision_Strike>(entity);

	ExpidonsaRemoveEffects(entity);
	if(IsValidEntity(RaidBossActive) && RaidBossActive == EntIndexToEntRef(npc.index))
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
				SetMusicTimer(client, GetTime() + 1);
		}
	}
	
	Vs_RechargeTime[npc.index]=0.0;
	Vs_RechargeTimeMax[npc.index]=0.0;

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && !IsFakeClient(client))
			Vs_LockOn[client]=false;
	}

	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static bool Victoria_Support(Victoria_Precision_Strike npc)
{
	float GameTime = GetGameTime();
	if(Vs_DelayTime[npc.index] > GameTime)
		return false;
	if(!Waves_Started() || InSetup)
		return false;
	Vs_DelayTime[npc.index] = GameTime + 0.1;
	
	switch(Vs_RNDTarget)
	{
		case 1:Vs_Target[npc.index] = Victoria_GetTargetDistance(npc.index, false, false);
		case 2, 3, 4:Vs_Target[npc.index] = GetClosestTarget(npc.index, true, _, _, true);
		default:Vs_Target[npc.index] = Victoria_GetTargetDistance(npc.index, true, false);
	}
	if(!IsValidEnemy(npc.index, Vs_Target[npc.index]))
	{
		if(npc.m_flGetClosestTargetTime < GameTime)
		{
			Vs_RNDTarget = GetRandomInt(0, 4);
			npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		}
		return false;
	}
	if(Vs_RechargeTime[npc.index] >= 1.0 && Vs_RechargeTime[npc.index] <= 3.0 && IsValidEntity(Vs_ParticleSpawned[npc.index]))
		RemoveEntity(Vs_ParticleSpawned[npc.index]);
	Vs_RechargeTime[npc.index] += 0.1;
	if(Vs_RechargeTime[npc.index]>(Vs_RechargeTimeMax[npc.index]+1.0))
		Vs_RechargeTime[npc.index]=0.0;
	
	float vecTarget[3];
	GetEntPropVector(Vs_Target[npc.index], Prop_Data, "m_vecAbsOrigin", vecTarget);
	vecTarget[2] += 5.0;
	
	if(Vs_RechargeTime[npc.index] < Vs_RechargeTimeMax[npc.index])
	{
		float position[3];
		position[0] = vecTarget[0];
		position[1] = vecTarget[1];
		position[2] = vecTarget[2] + 3000.0;
		if(Vs_RechargeTime[npc.index] < (Vs_RechargeTimeMax[npc.index] - 3.0))
		{
			Vs_Temp_Pos[npc.index][0] = position[0];
			Vs_Temp_Pos[npc.index][1] = position[1];
			Vs_Temp_Pos[npc.index][2] = position[2] - 3000.0;
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsValidClient(client))
					Vs_LockOn[client]=false;
			}
			if(IsValidClient(Vs_Target[npc.index]))Vs_LockOn[Vs_Target[npc.index]]=true;
		}
		else
		{
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsValidClient(client) && !IsFakeClient(client))
					Vs_LockOn[client]=false;
			}
		}
		TE_SetupBeamRingPoint(Vs_Temp_Pos[npc.index], 500.0 - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*500.0), (500.0 - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*500.0))+0.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {255, 255, 255, 150}, 0, 0);
		TE_SendToAll();
		float position2[3];
		position2[0] = Vs_Temp_Pos[npc.index][0];
		position2[1] = Vs_Temp_Pos[npc.index][1];
		position2[2] = Vs_Temp_Pos[npc.index][2] + 65.0;
		TE_SetupBeamRingPoint(position2, 500.0, 500.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {145, 47, 47, 150}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(Vs_Temp_Pos[npc.index], 500.0, 500.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {145, 47, 47, 150}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamPoints(Vs_Temp_Pos[npc.index], position, gLaser1, -1, 0, 0, 0.1, 0.0, 25.0, 0, 1.0, {145, 47, 47, 150}, 3);
		TE_SendToAll();
		TE_SetupGlowSprite(Vs_Temp_Pos[npc.index], gRedPoint, 0.1, 1.0, 255);
		TE_SendToAll();
		if(Vs_RechargeTime[npc.index] > (Vs_RechargeTimeMax[npc.index] - 1.0) && !IsValidEntity(Vs_ParticleSpawned[npc.index]))
		{
			position[0] = 250.0;
			position[1] = 350.0;
			Vs_ParticleSpawned[npc.index] = EntIndexToEntRef(ParticleEffectAt(position, "kartimpacttrail", 2.0));
			SetEdictFlags(Vs_ParticleSpawned[npc.index], (GetEdictFlags(Vs_ParticleSpawned[npc.index]) | FL_EDICT_ALWAYS));
			SetEntProp(Vs_ParticleSpawned[npc.index], Prop_Data, "m_iHammerID", npc.index);
			npc.PlayIncomingBoomSound();
		}
	}
	else if(IsValidEntity(Vs_ParticleSpawned[npc.index]))
	{
		float position[3];
		position[0] = Vs_Temp_Pos[npc.index][0];
		position[1] = Vs_Temp_Pos[npc.index][1];
		position[2] = Vs_Temp_Pos[npc.index][2] - 700.0;
		TeleportEntity(EntRefToEntIndex(Vs_ParticleSpawned[npc.index]), position, NULL_VECTOR, NULL_VECTOR);
		position[2] += 700.0;
		
		float damageDealt = 100.0;
		if(ZR_GetWaveCount()+1 > 12)
			damageDealt *= float(ZR_GetWaveCount()+1)*0.7;
		if(damageDealt>9000.0)damageDealt=9000.0;
		
		i_ExplosiveProjectileHexArray[npc.index] = EP_DEALS_TRUE_DAMAGE;
		Explode_Logic_Custom(damageDealt, 0, npc.index, -1, position, 250.0, 1.0, _, true, 20);
		
		ParticleEffectAt(position, "hightower_explosion", 1.0);
		i_ExplosiveProjectileHexArray[npc.index] = 0; 
		npc.PlayBoomSound();
		Vs_RechargeTime[npc.index]=0.0;
		Vs_RechargeTime[npc.index]=0.0;
		return true;
	}
	return false;
}