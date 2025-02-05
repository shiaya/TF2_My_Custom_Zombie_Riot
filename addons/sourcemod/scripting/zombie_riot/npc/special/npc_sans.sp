#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	"npc/fast_zombie/wake1.wav",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
};
static char g_HeIsAwake[][] = {
	"physics/concrete/concrete_break2.wav",
	"physics/concrete/concrete_break3.wav",
};

static const char g_TeleportSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static char[] GetSANSHealth()
{
	int health = 100;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(ZR_GetWaveCount()+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.2));
	}
	else if(ZR_GetWaveCount()+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.25));
	}
	else if(ZR_GetWaveCount()+1 < 60)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.3));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.2));
	}
	
	health = health * 3 / 8;
	
	if(!StrContains(WhatDifficultySetting_Internal, "Umbral Incursion"))
	{
		if(health<100000)
			health=100000;
	}
	else
	{
		if(health>80000)
			health=80000;
		else if(health<8000)
			health=8000;
	}
	
	health = health+RoundToCeil((CountPlayersOnRed()*65.0)*(float(ZR_GetWaveCount()+1)*0.1));
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}

static bool SANS[MAXENTITIES];
static int Prepar[MAXENTITIES];
static float GETOUTDAMIT[MAXENTITIES];
static MusicEnum CustomMusic;
bool TrumpetSkeleton_NotSpawning;

public void TrumpetSkeleton_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	if(FileExists("sound/baka_zr/golden_sins.mp3", true))
		PrecacheSoundCustom("#baka_zr/golden_sins.mp3");
	if(FileExists("sound/baka_zr/trumpet_tylenol.mp3", true))
		PrecacheSoundCustom("#baka_zr/trumpet_tylenol.mp3");
	if(FileExists("sound/baka_zr/trumpetskeleton.mp3", true))
		PrecacheSound("baka_zr/trumpetskeleton.mp3", true);
	PrecacheModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Special Trumpet Skeleton");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_trumpetsans");
	strcopy(data.Icon, sizeof(data.Icon), "special_trumpetskeletons"); 
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}

void ResetSansLogic()
{
	TrumpetSkeleton_NotSpawning = false;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return TrumpetSkeleton(client, vecPos, vecAng, ally, data);
}

methodmap TrumpetSkeleton < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() {
		
		int sound = GetRandomInt(0, sizeof(g_TeleportSounds) - 1);
		
		EmitSoundToAll(g_TeleportSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll("baka_zr/trumpetskeleton.mp3", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRAGEMeleeSound() 
	{
		EmitSoundToAll("baka_zr/trumpetskeleton.mp3", this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public TrumpetSkeleton(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ally = TFTeam_Stalkers;
		TrumpetSkeleton npc = view_as<TrumpetSkeleton>(CClotBody(vecPos, vecAng, "models/bots/skeleton_sniper/skeleton_sniper.mdl", "1.0", GetSANSHealth(), ally, false, false, true));
		
		/*if(buffed)
		{
			TE_SetupParticleEffect("utaunt_wispy_parent_g", PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);	
			TE_SendToAll();	
		}*/
		i_NpcWeight[npc.index] = 4;
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bDoSpawnGesture = true;
		DispatchKeyValue(npc.index, "skin", "2");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(TrumpetSkeleton_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(TrumpetSkeleton_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(TrumpetSkeleton_ClotThink);
		
		//IDLE
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_bFUCKYOU = false;
		SANS[npc.index] = false;
		npc.m_flSpeed = 200.0;
		Prepar[npc.index] = 0;
		GETOUTDAMIT[npc.index] = 0.0;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		npc.i_GunMode = Waves_GetRound();
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_bugle/c_bugle.mdl");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 2);
		
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		npc.StartPathing();
		
		return npc;
	}
}

static void TrumpetSkeleton_ClotThink(int iNPC)
{
	TrumpetSkeleton npc = view_as<TrumpetSkeleton>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.AddGesture("ACT_TRANSITION");
		npc.m_bDoSpawnGesture = false;
		npc.PlayHeIsAwake();
		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 3;
		npc.m_flSpeed = 0.0;
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		npc.StopPathing();
		npc.m_flAttackHappens = gameTime+1.4;
	}
	else if(npc.m_flAttackHappens > gameTime)
		return;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;
	int target = npc.m_iTarget;
	float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float DistanceToTarget = GetVectorDistance(VecEnemy, VecSelfNpc, true);
	if(npc.m_flGetClosestTargetTime < gameTime	|| !IsValidEnemy(npc.index,npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			npc.m_iTarget = GetClosestTarget(npc.index, true, _, _, true);
		}
	}
	target = npc.m_iTarget;

	npc.m_flGetClosestTargetTime = gameTime + 1.0;
		
	if(!IsValidEnemy(npc.index,target))
	{
		if(npc.m_iChanged_WalkCycle != 0)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flSpeed = 0.0;
			npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			npc.StopPathing();
		}
		return;
	}
	
	if((b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] && (npc.i_GunMode <= (Waves_GetRound() - 2) || RaidbossIgnoreBuildingsLogic(1) || LastMann)) || TrumpetSkeleton_NotSpawning)
	{
		if(TrumpetSkeleton_NotSpawning)
		{
			CPrintToChatAll("{unique}The Skeleton is no longer interested in you. someone else takes its place instead...");
			NPC_SpawnNext(true, true, -1); //This will force spawn a panzer.
			b_NpcForcepowerupspawn[npc.index] = 0;
		}
		TrumpetSkeleton_NotSpawning=true;
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		SmiteNpcToDeath(npc.index);
		return;
	}

	if(npc.m_bFUCKYOU)
	{
		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_flSpeed = 0.0;
		npc.SetActivity("ACT_MP_STAND_MELEE");
		npc.StopPathing();
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 10);
			}
		}
		
		switch(Prepar[npc.index]++)
		{
			case 2:
			{
				b_thisNpcIsABoss[npc.index] = true;
				if(!IsValidEntity(RaidBossActive))
				{
					RaidModeTime = FAR_FUTURE;
					RaidBossActive = EntIndexToEntRef(npc.index);
					RaidAllowsBuildings = true;
					RaidModeScaling = 0.0;
				}
				b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = false;
				SANS[npc.index] = true;
				if(IsValidEntity(RaidBossActive) && RaidBossActive == EntIndexToEntRef(npc.index))
				{
					if(GetRandomInt(1,100)<=50)
					{
						strcopy(CustomMusic.Path, sizeof(CustomMusic.Path), "#baka_zr/golden_sins.mp3");
						CustomMusic.Time = 210;
						CustomMusic.Volume = 2.0;
						CustomMusic.Custom = false;
						strcopy(CustomMusic.Name, sizeof(CustomMusic.Name), "Golden Sins");
						strcopy(CustomMusic.Artist, sizeof(CustomMusic.Artist), "LiterallyNoOne");
					}
					else
					{
						strcopy(CustomMusic.Path, sizeof(CustomMusic.Path), "#baka_zr/trumpet_tylenol.mp3");
						CustomMusic.Time = 113;
						CustomMusic.Volume = 2.0;
						CustomMusic.Custom = false;
						strcopy(CustomMusic.Name, sizeof(CustomMusic.Name), "Trumpet Tylenol");
						strcopy(CustomMusic.Artist, sizeof(CustomMusic.Artist), "sud");
					}
					if(CustomMusic.Path[0])
					{
						for(int client=1; client<=MaxClients; client++)
						{
							if(IsClientInGame(client) && !IsFakeClient(client))
							{
								Music_Stop_All(client);
								EmitCustomToClient(client, CustomMusic.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, CustomMusic.Volume);
								if(CustomMusic.Name[0] || CustomMusic.Artist[0])
									CPrintToChat(client, "%t", "Now Playing Song", CustomMusic.Artist, CustomMusic.Name);
							}
						}
					}
				}
				SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/dec17_down_tundra_coat/dec17_down_tundra_coat.mdl");
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
				
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/dec17_down_tundra_coat/dec17_down_tundra_coat.mdl");
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
				
				float flPos[3]; // original
				float flAng[3]; // original	
				GetAttachment(npc.index, "head", flPos, flAng);
				flPos[0]+=1.5;
				flPos[1]-=0.5;
				flPos[2]-=2.0;	
				npc.m_iWearable4 = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 80.0);
				SetParent(npc.index, npc.m_iWearable4, "head");
			}
			case 3:
			{
				//view_as<CClotBody>(npc.index).Ally = TFTeam_Blue;
				SetTeam(npc.index, TFTeam_Blue);
				npc.m_flMeleeArmor = 0.9;
				npc.m_flRangedArmor = 0.9;
				int MaxHealth = RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")*1.25);
				SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", MaxHealth);
				GrantEntityArmor(npc.index, true, 0.2, 0.75, 0);
				npc.m_bFUCKYOU=false;
				IncreaceEntityDamageTakenBy(npc.index, 0.005, 1.0);
				b_NpcIsInvulnerable[npc.index] = false;
				Is_a_Medic[npc.index] = false;
				npc.m_bStaticNPC = false;
				EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
				strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Rare bloodsucking TrumpetSkeleton of Conflagration");
				i_NpcWeight[npc.index] = 5;
				npc.m_flNextRangedAttack = gameTime + 60.0;
			}
		}
		if(npc.m_bFUCKYOU)npc.m_flNextThinkTime = gameTime + 2.5;
		return;
	}
	bool sniper = view_as<bool>((npc.i_GunMode + 1) == Waves_GetRound());
	if(sniper)
	{
		/*none*/
	}
	float EndBoss=60.0;
	if(IsValidEntity(RaidBossActive) && RaidBossActive == EntIndexToEntRef(npc.index))
	{
		RaidModeScaling = ((EndBoss-(npc.m_flNextRangedAttack - gameTime))/EndBoss)*2.0;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 10);
			}
		}
	}
	if(npc.m_flNextRangedAttack < gameTime && SANS[npc.index])
	{
		TrumpetSkeleton_NotSpawning=true;
		ParticleEffectAt(VecSelfNpc, "teleported_blue", 0.5);
		npc.PlayTeleportSound();
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		if(IsValidEntity(RaidBossActive) && RaidBossActive == EntIndexToEntRef(npc.index))
		{
			RaidBossActive = INVALID_ENT_REFERENCE;
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && !IsFakeClient(client))
				{
					SetMusicTimer(client, GetTime() + 1);
					StopCustomSound(client, SNDCHAN_STATIC, "#baka_zr/golden_sins.mp3");
					StopCustomSound(client, SNDCHAN_STATIC, "#baka_zr/trumpet_tylenol.mp3");
					StopCustomSound(client, SNDCHAN_STATIC, "#baka_zr/golden_sins.mp3");
					StopCustomSound(client, SNDCHAN_STATIC, "#baka_zr/trumpet_tylenol.mp3");
				}
			}
		}
		SmiteNpcToDeath(npc.index);
		return;
	}
	int AI = TrumpetSkeletonAssaultMode(npc.index, gameTime, DistanceToTarget);
	switch(AI)
	{
		case 0, 1://notfound, cooldown
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 1;
				npc.m_flSpeed = SANS[npc.index] ? 310.0+(((EndBoss-(npc.m_flNextRangedAttack - gameTime))/EndBoss)*140.0) : 200.0;
				npc.SetActivity("ACT_MP_RUN_MELEE");
				npc.StartPathing();
			}
		}
		case 2://attack
		{
			if(SANS[npc.index])
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flSpeed = SANS[npc.index] ? 310.0+(((EndBoss-(npc.m_flNextRangedAttack - gameTime))/EndBoss)*140.0) : 200.0;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}
			}
			else if(npc.m_iChanged_WalkCycle != 0)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flSpeed = 0.0;
				npc.SetActivity("ACT_MP_STAND_MELEE");
				npc.StopPathing();
			}
		}
	}
	
	if(npc.m_bisWalking && DistanceToTarget < npc.GetLeadRadius()) 
	{
		float vPredictedPos[3];
		PredictSubjectPosition(npc, target,_,_, vPredictedPos);
		NPC_SetGoalVector(npc.index, vPredictedPos);
	}
	else 
	{
		NPC_SetGoalEntity(npc.index, target);
	}
	npc.PlayIdleSound();
}
static Action TrumpetSkeleton_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	TrumpetSkeleton npc = view_as<TrumpetSkeleton>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(b_ThisEntityIgnoredByOtherNpcsAggro[npc.index])
	{
		if(attacker <= MaxClients && TeutonType[attacker] != TEUTON_NONE)
		{	
			damage = 0.0;
			return Plugin_Handled;
		}
	}
		
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(b_ThisEntityIgnoredByOtherNpcsAggro[npc.index])
	{
		damage = 0.0;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 10);
			}
		}
		npc.m_bFUCKYOU=true;
		b_NpcIsInvulnerable[npc.index] = true;
		return Plugin_Handled;
	}
	
	if(SANS[npc.index])
		GETOUTDAMIT[npc.index]+=damage;

	return Plugin_Changed;
}

static void TrumpetSkeleton_NPCDeath(int entity)
{
	TrumpetSkeleton npc = view_as<TrumpetSkeleton>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	ExpidonsaRemoveEffects(entity);
	if(IsValidEntity(RaidBossActive) && RaidBossActive == EntIndexToEntRef(npc.index))
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
			{
				SetMusicTimer(client, GetTime() + 1);
				StopCustomSound(client, SNDCHAN_STATIC, "#baka_zr/golden_sins.mp3");
				StopCustomSound(client, SNDCHAN_STATIC, "#baka_zr/trumpet_tylenol.mp3");
				StopCustomSound(client, SNDCHAN_STATIC, "#baka_zr/golden_sins.mp3");
				StopCustomSound(client, SNDCHAN_STATIC, "#baka_zr/trumpet_tylenol.mp3");
			}
		}
	}
	
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
	
	if(!StrContains(WhatDifficultySetting_Internal, "Umbral Incursion"))
	{
		//none
	}
	else
	{
		if(!TrumpetSkeleton_NotSpawning && GetRandomInt(1, 100)<=25)
		{
			for (int client = 0; client < MaxClients; client++)
			{
				if(IsValidClient(client) && GetClientTeam(client) == 2
				&& TeutonType[client] != TEUTON_WAITING && !(Items_HasNamedItem(client, "Bone Power Trumpet")))
				{
					Items_GiveNamedItem(client, "Bone Power Trumpet");
					CPrintToChat(client, "%t", "Snas Trumpet Give");
				}
			}
		}
	}
}

static int TrumpetSkeletonAssaultMode(int iNPC, float gameTime, float distance)
{
	TrumpetSkeleton npc = view_as<TrumpetSkeleton>(iNPC);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * (SANS[npc.index] ? 1.5 : 1.2)))
	{
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		//int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		float ratio = float(maxhealth)*0.25;
		float VecSelfNpc[3];
		WorldSpaceCenter(npc.index, VecSelfNpc);
		if(GETOUTDAMIT[npc.index]>=ratio && npc.m_flRangedSpecialDelay < gameTime && SANS[npc.index])
		{
			GETOUTDAMIT[npc.index]-=ratio;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 350.0, _, _, true, _, false, _, SuperAttack);
			npc.PlayRAGEMeleeSound();
			float SuperCD=1.0;
			if(!StrContains(WhatDifficultySetting_Internal, "Umbral Incursion"))
				SuperCD=2.0;
			else
			{
				if(ZR_GetWaveCount()+1 < 30)
					SuperCD=5.0;
				else
					SuperCD=2.5;
			}
			npc.m_flRangedSpecialDelay = gameTime + SuperCD;
		}
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, SANS[npc.index] ? 225.0 : 125.0, _, _, true, _, false, _, TrumpetAttack);
			npc.m_flNextMeleeAttack = gameTime + (SANS[npc.index] ? 2.5-(((60.0-(npc.m_flNextRangedAttack - gameTime))/60.0)*2.3) : 8.0);
			if(SANS[npc.index])
				npc.PlayRAGEMeleeSound();
			else
				npc.PlayMeleeSound();
			return 2;
		}
		return 1;
	}
	return 0;
}

static void TrumpetAttack(int entity, int victim, float damage, int weapon)
{
	TrumpetSkeleton npc = view_as<TrumpetSkeleton>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	Custom_Knockback(npc.index, victim, SANS[npc.index] ? 600.0 : 1100.0, true, true, true);
	if(GetTeam(victim) == TFTeam_Red && SANS[npc.index])
	{
		float damageDealt = 25.0;
		if(ZR_GetWaveCount()+1 > 12)
			damageDealt *= float(ZR_GetWaveCount()+1)*0.1;
		//if(damageDealt>85.0)damageDealt=85.0;
		if(ShouldNpcDealBonusDamage(victim))
			damageDealt *= 2.0;
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
		if(!NpcStats_IsEnemySilenced(npc.index))
		{
			IncreaceEntityDamageTakenBy(npc.index, 0.85, 1.0);
			HealEntityGlobal(npc.index, npc.index, (damageDealt*3.0), 1.5, _, HEAL_SELFHEAL);
		}
		else HealEntityGlobal(npc.index, npc.index, (damageDealt*0.5), 1.0, _, HEAL_SELFHEAL);
	}
}

static void SuperAttack(int entity, int victim, float damage, int weapon)
{
	TrumpetSkeleton npc = view_as<TrumpetSkeleton>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	Custom_Knockback(npc.index, victim, 1380.0, true, true, true);
	if(GetTeam(victim) == TFTeam_Red && SANS[npc.index])
	{
		float damageDealt = 25.0;
		if(ZR_GetWaveCount()+1 > 12)
			damageDealt *= float(ZR_GetWaveCount()+1)*0.25;
		if(!StrContains(WhatDifficultySetting_Internal, "Umbral Incursion"))
		{
			if(damageDealt>1000.0)damageDealt=1000.0;
		}
		else if(damageDealt>400.0)damageDealt=400.0;
		if(ShouldNpcDealBonusDamage(victim))
			damageDealt *= 2.0;
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
		if(!NpcStats_IsEnemySilenced(npc.index))
		{
			IncreaceEntityDamageTakenBy(npc.index, 0.9, 0.3);
			HealEntityGlobal(npc.index, npc.index, (damageDealt*3.0), 1.5, _, HEAL_SELFHEAL);
		}
		else HealEntityGlobal(npc.index, npc.index, (damageDealt*1.0), 1.0, _, HEAL_SELFHEAL);
	}
}