#pragma semicolon 1
#pragma newdecls required

static bool JUST_TOGGLE[MAXENTITIES];
static bool b_Already_Link[MAXENTITIES]={false};
static int TempTargetOne[MAXENTITIES];
static int TempTargetTwo[MAXENTITIES];
static int TempTargetTree[MAXENTITIES];
static float TempDelayOne[MAXENTITIES];
//static float TempDelayTwo[MAXENTITIES];

static char g_BlitzkriegVioce_StartSounds[][] = {
	"zombiesurvival/altwaves_and_blitzkrieg/music/dm_start1.mp3",
	"zombiesurvival/altwaves_and_blitzkrieg/music/dm_start2.mp3",
	"zombiesurvival/altwaves_and_blitzkrieg/music/dm_start3.mp3",
	"zombiesurvival/altwaves_and_blitzkrieg/music/dm_start4.mp3",
	"zombiesurvival/altwaves_and_blitzkrieg/music/dm_start5.mp3",
	"zombiesurvival/altwaves_and_blitzkrieg/music/dm_start6.mp3"
};

static const char g_TeleSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};

void ResetITMLogic()
{
	Zero(b_Already_Link);
}

void Invisible_TRIGGER_Man_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Invisible Trigger Man");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_invisible_trigger_man");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_precision_strike");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_BlitzkriegVioce_StartSounds));	   i++) { PrecacheSound(g_BlitzkriegVioce_StartSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_TeleSounds));	   i++) { PrecacheSound(g_TeleSounds[i]);	   }
	PrecacheModel("models/player/spy.mdl");
	PrecacheSoundCustom("zombiesurvival/altwaves_and_blitzkrieg/music/dm_end.mp3");
	PrecacheSoundCustom("#zombiesurvival/altwaves_and_blitzkrieg/music/dm_loop1.mp3");
	PrecacheSoundCustom("zombiesurvival/altwaves_and_blitzkrieg/music/dm_start.mp3");
	PrecacheSoundCustom("zombiesurvival/altwaves_and_blitzkrieg/music/dm_start1.mp3");
	PrecacheSoundCustom("zombiesurvival/altwaves_and_blitzkrieg/music/dm_start2.mp3");
	PrecacheSoundCustom("zombiesurvival/altwaves_and_blitzkrieg/music/dm_start3.mp3");
	PrecacheSoundCustom("zombiesurvival/altwaves_and_blitzkrieg/music/dm_start4.mp3");
	PrecacheSoundCustom("zombiesurvival/altwaves_and_blitzkrieg/music/dm_start5.mp3");
	PrecacheSoundCustom("zombiesurvival/altwaves_and_blitzkrieg/music/dm_start6.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Invisible_TRIGGER_Man(client, vecPos, vecAng, ally, data);
}

methodmap Invisible_TRIGGER_Man < CClotBody
{
	property int i_NPCStats
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property int i_GetWave
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}

	public void PlayBlitzkriegStartSound() 
	{
		EmitCustomToAll("zombiesurvival/altwaves_and_blitzkrieg/music/dm_start.mp3", _, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayBlitzkriegVioceStartSound() 
	{
		EmitCustomToAll(g_BlitzkriegVioce_StartSounds[GetRandomInt(0, sizeof(g_BlitzkriegVioce_StartSounds) - 1)], _, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayBlitzkriegEndSound() 
	{
		EmitCustomToAll("zombiesurvival/altwaves_and_blitzkrieg/music/dm_end.mp3", _, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayTeleSound() 
	{
		EmitSoundToAll(g_TeleSounds[GetRandomInt(0, sizeof(g_TeleSounds) - 1)], _, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public Invisible_TRIGGER_Man(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool Cybergrind_EX_Hard_Mode=false;
		if(!StrContains(data, "cybergrind_ex_hard"))
		{
			Cybergrind_EX_Hard_Mode=true;
			ally = TFTeam_Stalkers;
		}
		Invisible_TRIGGER_Man npc = view_as<Invisible_TRIGGER_Man>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "12000", ally));
		
		b_NoKillFeed[npc.index] = true;
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.i_NPCStats=0;
		
		if(Cybergrind_EX_Hard_Mode)
		{
			func_NPCDeath[npc.index] = view_as<Function>(Invisible_TRIGGER_Man_NPCDeath);
			func_NPCOnTakeDamage[npc.index] = view_as<Function>(Invisible_TRIGGER_Man_OnTakeDamage);
			func_NPCThink[npc.index] = view_as<Function>(Cybergrind_EX_Hard_Mode_ClotThink);
			
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
			npc.m_flDead_Ringer_Invis = 0.0;
			TempDelayOne[npc.index] = 0.0;
			
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
			
			return npc;
		}
		
		if(!StrContains(data, "cover_blitzkrieg"))
			npc.i_NPCStats=1;
		if(!StrContains(data, "cover_bobthefirst"))
			npc.i_NPCStats=2;
		if(!StrContains(data, "cover_corruptedbarney"))
			npc.i_NPCStats=3;
		if(!StrContains(data, "cover_twins"))
			npc.i_NPCStats=4;
		if(!StrContains(data, "delete_timerlimit"))
			npc.i_NPCStats=3000;

		func_NPCDeath[npc.index] = view_as<Function>(Invisible_TRIGGER_Man_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Invisible_TRIGGER_Man_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Invisible_TRIGGER_Man_ClotThink);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flNextMeleeAttack = GetGameTime() + 2.0;
		npc.m_flNextRangedAttack = 0.0;
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		b_NoHealthbar[npc.index]=true;
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
		
		return npc;
	}
}

static void Cybergrind_EX_Hard_Mode_ClotThink(int iNPC)
{
	Invisible_TRIGGER_Man npc = view_as<Invisible_TRIGGER_Man>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(Waves_InSetup())
	{
		if(JUST_TOGGLE[npc.index])
		{
			bool YESISWAVE=false;
			/*switch(ZR_GetWaveCount()+1)
			{
				case 16:CPrintToChatAll("{crimson}Enemies grow restless...{default}");
				case 31:CPrintToChatAll("{crimson}Enemies power gauge increases...{default}");
				case 46:CPrintToChatAll("{crimson}Enemies Power The limit is lifted...{default}");
				case 65:CPrintToChatAll("{crimson}Is 9001!!{default}");
				default:
				{
					//none
				}
			}*/
			if(YESISWAVE)
			{
				npc.i_GetWave=ZR_GetWaveCount()+1;
				JUST_TOGGLE[npc.index]=true;
			}
		}
		return;
	}
	JUST_TOGGLE[npc.index]=false;
	
	bool there_is_no_one=true;
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
		if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == TFTeam_Blue)
		{
			ApplyStatusEffect(npc.index, entity, "Cybergrind EX-Hard Enemy Buff", 0.5);
			there_is_no_one=false;
		}
	}
	if(there_is_no_one)
	{
		npc.m_flNextMeleeAttack = gameTime + 1.0;
	}
	else if(npc.m_flNextMeleeAttack < gameTime)
	{
		WaveStart_SubWaveStart(GetGameTime() + 3000.0);
		npc.m_flNextMeleeAttack = gameTime + 2250.0;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
}

static void Invisible_TRIGGER_Man_ClotThink(int iNPC)
{
	Invisible_TRIGGER_Man npc = view_as<Invisible_TRIGGER_Man>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	switch(npc.i_NPCStats)
	{
		case 1:
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				switch(npc.m_iOverlordComboAttack)
				{
					case 0:
					{
						if(f_DelaySpawnsForVariousReasons < GetGameTime() + 11.0)
						{
							for(int client = 1; client <= MaxClients; client++)
							{
								if(IsClientInGame(client) && !b_IsPlayerABot[client])
									Music_Stop_All(client);
							}
							RemoveAllCustomMusic();
							npc.PlayBlitzkriegStartSound();
							npc.m_flNextMeleeAttack = gameTime + 1.0;
							npc.m_iOverlordComboAttack=1;
						}
					}
					case 1:
					{
						npc.PlayBlitzkriegVioceStartSound();
						npc.m_iOverlordComboAttack=2;
					}
					case 2:
					{
						bool BlitzkriegOnline=false;
						for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
						{
							int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
							if(IsValidEntity(entity) && i_NpcInternalId[entity] == RaidBoss_Blitzkrieg_ID() && !b_NpcHasDied[entity])
							{
								BlitzkriegOnline=true;
								break;
							}
						}
						if(BlitzkriegOnline)
						{
							npc.m_flNextMeleeAttack = gameTime + 0.25;
							npc.m_iOverlordComboAttack=3;
						}
					}
					case 3:
					{
						MusicEnum music;
						strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/altwaves_and_blitzkrieg/music/dm_loop1.mp3");
						music.Time = 356;
						music.Volume = 2.0;
						music.Custom = true;
						strcopy(music.Name, sizeof(music.Name), "感情の魔天楼　～ World's End");
						strcopy(music.Artist, sizeof(music.Artist), "Demetori");
						Music_SetRaidMusic(music);
						npc.m_iOverlordComboAttack=4;
					}
					case 4:
					{
						bool BlitzkriegOnline=false;
						for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
						{
							int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
							if(IsValidEntity(entity) && i_NpcInternalId[entity] == RaidBoss_Blitzkrieg_ID() && !b_NpcHasDied[entity])
							{
								BlitzkriegOnline=true;
								break;
							}
						}
						if(BlitzkriegOnline)
						{
							//lol
							/*bool DeadPlayer;
							for(int client_check=1; client_check<=MaxClients; client_check++)
							{
								if(!IsValidClient(client_check))continue;
								if(TeutonType[client_check] == TEUTON_NONE)continue;
								if(GetTeam(client_check) != TFTeam_Red)continue;
								DeadPlayer=true;
							}
							if(DeadPlayer)
							{
								for(int client=1; client<=MaxClients; client++)
								{
									if(IsClientInGame(client) && !IsFakeClient(client))
									{
										StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/altwaves_and_blitzkrieg/music/dm_loop1.mp3");
										StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/altwaves_and_blitzkrieg/music/dm_loop1.mp3");
									}
								}
								npc.PlayBlitzkriegEndSound();
								b_NpcForcepowerupspawn[npc.index] = 0;
								i_RaidGrantExtra[npc.index] = 0;
								b_DissapearOnDeath[npc.index] = true;
								b_DoGibThisNpc[npc.index] = true;
								SmiteNpcToDeath(npc.index);
							}*/
						}
						else
						{
							for(int client = 1; client <= MaxClients; client++)
							{
								if(IsClientInGame(client) && !b_IsPlayerABot[client])
									Music_Stop_All(client);
							}
							RemoveAllCustomMusic();
							npc.PlayBlitzkriegEndSound();
							b_NpcForcepowerupspawn[npc.index] = 0;
							i_RaidGrantExtra[npc.index] = 0;
							b_DissapearOnDeath[npc.index] = true;
							b_DoGibThisNpc[npc.index] = true;
							SmiteNpcToDeath(npc.index);
						}
					}
				}
			}
		}
		case 2:
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				float WorldSpaceVec[3];
				switch(npc.m_iOverlordComboAttack)
				{
					case 0:
					{
						for(int i; i < i_MaxcountNpcTotal; i++)
						{
							int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
							if(IsValidEntity(entity))
							{
								char npc_classname[60];
								NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
								if(entity != INVALID_ENT_REFERENCE && StrEqual(npc_classname, "npc_bob_the_first_last_savior") && IsEntityAlive(entity))
								{
									GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", WorldSpaceVec);
									ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
									int Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 750.0);
									if(Decicion == 2)
									{
										Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 375.0);
										if(Decicion == 2)
										{
											Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 187.5);
											if(Decicion == 2)
											{
												Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 0.0);
											}
										}
									}
									npc.PlayTeleSound();
									GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", WorldSpaceVec);
									ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
									npc.m_iOverlordComboAttack=1;
									return;
								}
							}
						}
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
					case 1:
					{
						b_NpcForcepowerupspawn[npc.index] = 0;
						i_RaidGrantExtra[npc.index] = 0;
						b_DissapearOnDeath[npc.index] = true;
						b_DoGibThisNpc[npc.index] = true;
						SmiteNpcToDeath(npc.index);
					}
				}
			}
		}
		case 3:
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				float WorldSpaceVec[3];
				switch(npc.m_iOverlordComboAttack)
				{
					case 0:
					{
						for(int i; i < i_MaxcountNpcTotal; i++)
						{
							int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
							if(IsValidEntity(entity))
							{
								char npc_classname[60];
								NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
								if(entity != INVALID_ENT_REFERENCE && StrEqual(npc_classname, "npc_corruptedbarney") && IsEntityAlive(entity))
								{
									float SelfPos[3];
									GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
									float AllyAng[3];
									GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
									int Spawner_entity = GetRandomActiveSpawner();
									if(IsValidEntity(Spawner_entity))
									{
										GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", SelfPos);
										GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", AllyAng);
									}
									int IsThatSawRunner = NPC_CreateByName("npc_sawrunner", -1, SelfPos, AllyAng, GetTeam(entity), "no_play_music");
									if(IsValidEntity(IsThatSawRunner))
									{
										b_ThisNpcIsImmuneToNuke[IsThatSawRunner] = true;
										b_NoKnockbackFromSources[IsThatSawRunner] = true;
										b_NpcIsInvulnerable[IsThatSawRunner] = true;
										b_ThisEntityIgnored[IsThatSawRunner] = true;
										b_NoHealthbar[IsThatSawRunner]=true;
										fl_Extra_Speed[IsThatSawRunner] = 1.25;
										if(IsValidEntity(i_InvincibleParticle[IsThatSawRunner]))
										{
											int particle = EntRefToEntIndex(i_InvincibleParticle[IsThatSawRunner]);
											SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
											SetEntityRenderColor(particle, 255, 255, 255, 1);
											SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
											SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
										}
										TempTargetTwo[npc.index] = EntIndexToEntRef(IsThatSawRunner);
										npc.m_flNextRangedAttack = gameTime + 15.0;
									}
									TempTargetOne[npc.index] = EntIndexToEntRef(entity);
									GrantEntityArmor(entity, false, 0.075, 0.5, 0);
									npc.m_iOverlordComboAttack=1;
									break;
								}
							}
						}
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
					case 1:
					{
						int entity = EntRefToEntIndex(TempTargetOne[npc.index]);
						if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
						{
							int Health = GetEntProp(entity, Prop_Data, "m_iHealth");
							int MaxHealth = ReturnEntityMaxHealth(entity);
							entity = EntRefToEntIndex(TempTargetTwo[npc.index]);
							if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
							{
								if(npc.m_flNextRangedAttack < gameTime)
								{
									GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", WorldSpaceVec);
									ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
									int Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 750.0);
									if(Decicion == 2)
									{
										Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 375.0);
										if(Decicion == 2)
										{
											Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 187.5);
											if(Decicion == 2)
											{
												Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 0.0);
											}
										}
									}
									npc.PlayTeleSound();
									GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", WorldSpaceVec);
									ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
									npc.m_flNextRangedAttack = gameTime + 30.0;
								}
								if(float(Health)<=float(MaxHealth)*0.5)
								{
									float SelfPos[3];
									GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
									float AllyAng[3];
									GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
									int Spawner_entity = GetRandomActiveSpawner();
									if(IsValidEntity(Spawner_entity))
									{
										GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", SelfPos);
										GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", AllyAng);
									}
									int IsThatSawRunner = NPC_CreateByName("npc_sawrunner", -1, SelfPos, AllyAng, GetTeam(entity), "no_play_music");
									if(IsValidEntity(IsThatSawRunner))
									{
										b_ThisNpcIsImmuneToNuke[IsThatSawRunner] = true;
										b_NoKnockbackFromSources[IsThatSawRunner] = true;
										b_NpcIsInvulnerable[IsThatSawRunner] = true;
										b_ThisEntityIgnored[IsThatSawRunner] = true;
										b_NoHealthbar[IsThatSawRunner]=true;
										fl_Extra_Speed[IsThatSawRunner] = 1.25;
										if(IsValidEntity(i_InvincibleParticle[IsThatSawRunner]))
										{
											int particle = EntRefToEntIndex(i_InvincibleParticle[IsThatSawRunner]);
											SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
											SetEntityRenderColor(particle, 255, 255, 255, 1);
											SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
											SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
										}
										TempTargetTree[npc.index] = EntIndexToEntRef(IsThatSawRunner);
										npc.m_flNextRangedAttack = gameTime + 6.0;
									}
									entity = EntRefToEntIndex(TempTargetOne[npc.index]);
									GrantEntityArmor(entity, false, 0.075, 0.5, 0);
									npc.m_iOverlordComboAttack=2;
								}
							}
						}
						else
						{
							entity = EntRefToEntIndex(TempTargetTwo[npc.index]);
							if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
							{
								b_NoKillFeed[entity] = true;
								b_NpcForcepowerupspawn[entity] = 0;
								i_RaidGrantExtra[entity] = 0;
								b_DissapearOnDeath[entity] = true;
								b_DoGibThisNpc[entity] = true;
								SmiteNpcToDeath(entity);
							}
							npc.m_iOverlordComboAttack=3;
						}
					}
					case 2:
					{
						int entity = EntRefToEntIndex(TempTargetOne[npc.index]);
						if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
						{
							if(npc.m_flNextRangedAttack < gameTime)
							{
								bool TeleON=false;
								entity = EntRefToEntIndex(TempTargetTwo[npc.index]);
								if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
								{
									GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", WorldSpaceVec);
									ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
									int Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 750.0);
									if(Decicion == 2)
									{
										Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 375.0);
										if(Decicion == 2)
										{
											Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 187.5);
											if(Decicion == 2)
											{
												Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 0.0);
											}
										}
									}
									TeleON=true;
									GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", WorldSpaceVec);
									ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
								}
								entity = EntRefToEntIndex(TempTargetTree[npc.index]);
								if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
								{
									GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", WorldSpaceVec);
									ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
									int Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 750.0);
									if(Decicion == 2)
									{
										Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 375.0);
										if(Decicion == 2)
										{
											Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 187.5);
											if(Decicion == 2)
											{
												Decicion = TeleportDiversioToRandLocation(entity, true, 750.0, 0.0);
											}
										}
									}
									TeleON=true;
									GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", WorldSpaceVec);
									ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
								}
								if(TeleON)
								{
									npc.m_flNextRangedAttack = gameTime + 24.0;
									npc.PlayTeleSound();
								}
								else npc.m_flNextRangedAttack = gameTime + 1.0;
							}
						}
						else
						{
							entity = EntRefToEntIndex(TempTargetTwo[npc.index]);
							if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
							{
								b_NoKillFeed[entity] = true;
								b_NpcForcepowerupspawn[entity] = 0;
								i_RaidGrantExtra[entity] = 0;
								b_DissapearOnDeath[entity] = true;
								b_DoGibThisNpc[entity] = true;
								SmiteNpcToDeath(entity);
							}
							entity = EntRefToEntIndex(TempTargetTree[npc.index]);
							if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
							{
								b_NoKillFeed[entity] = true;
								b_NpcForcepowerupspawn[entity] = 0;
								i_RaidGrantExtra[entity] = 0;
								b_DissapearOnDeath[entity] = true;
								b_DoGibThisNpc[entity] = true;
								SmiteNpcToDeath(entity);
							}
							npc.m_iOverlordComboAttack=3;
						}
					}
					case 3:
					{
						b_NpcForcepowerupspawn[npc.index] = 0;
						i_RaidGrantExtra[npc.index] = 0;
						b_DissapearOnDeath[npc.index] = true;
						b_DoGibThisNpc[npc.index] = true;
						SmiteNpcToDeath(npc.index);
					}
				}
			}
		}
		case 4:
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				switch(npc.m_iOverlordComboAttack)
				{
					case 0:
					{
						bool YESAlready_Linkss=false;
						for(int i; i < i_MaxcountNpcTotal; i++)
						{
							int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
							if(IsValidEntity(entity))
							{
								char npc_classname[60];
								NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
								if(entity != INVALID_ENT_REFERENCE && StrEqual(npc_classname, "npc_twins") && IsEntityAlive(entity))
								{
									if(b_Already_Link[entity])
										YESAlready_Linkss=true;
									else
									{
										strcopy(npc_classname, sizeof(npc_classname), c_NpcName[entity]);
										if(StrContains(npc_classname, "Twin No. 1"))
										{
											TempTargetOne[npc.index] = EntIndexToEntRef(entity);
											VausMagicaGiveShield(entity, 48+RoundToNearest(float(CountPlayersOnRed(1)) * 2.0));
											b_Already_Link[entity]=true;
										}
										else if(StrContains(npc_classname, "Twin No. 2"))
										{
											TempTargetTwo[npc.index] = EntIndexToEntRef(entity);
											VausMagicaGiveShield(entity, 48+RoundToNearest(float(CountPlayersOnRed(1)) * 2.0));
											b_Already_Link[entity]=true;
										}
									}
								}
							}
						}
						if(YESAlready_Linkss)
						{
							npc.m_flNextRangedAttack = gameTime + 29.5;
							npc.m_flDead_Ringer_Invis = gameTime + 24.5;
							TempDelayOne[npc.index] = GetGameTime() + 15.5;
							npc.m_iOverlordComboAttack=1;
						}
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
					case 1:
					{
						bool AllDieTwins=false;
						bool TwinsTele=false;
						int entity = EntRefToEntIndex(TempTargetOne[npc.index]);
						if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
						{
							if(npc.m_flNextRangedAttack < gameTime)
							{
								VausMagicaGiveShield(entity, CountPlayersOnRed(1) * 2);
								GrantEntityArmor(entity, false, 1.0, 0.5, 0, float(ReturnEntityMaxHealth(entity))*0.075);
								npc.m_flNextRangedAttack = gameTime + 29.5;
							}
							if(TempDelayOne[npc.index] < GetGameTime())
							{
								int Temp_Target = Victoria_GetTargetDistance(entity, true, false);
								if(IsValidEnemy(entity, Temp_Target))
								{
									static float hullcheckmaxs[3];
									static float hullcheckmins[3];
									hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
									hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );
									float VecEnemy[3]; WorldSpaceCenter(Temp_Target, VecEnemy);
									float vPredictedPos[3];
									PredictSubjectPosition(npc, Temp_Target,_,_, vPredictedPos);
									vPredictedPos = GetBehindTarget(Temp_Target, 30.0 ,vPredictedPos);

									float PreviousPos[3];
									WorldSpaceCenter(entity, PreviousPos);
									float WorldSpaceVec[3]; WorldSpaceCenter(entity, WorldSpaceVec);
									
									bool Succeed = Npc_Teleport_Safe(entity, vPredictedPos, hullcheckmins, hullcheckmaxs, true);
									if(Succeed)
									{
										Matrix_Twins npcGetInfo = view_as<Matrix_Twins>(entity);
										float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
										float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);

										TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
										TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
										TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
										TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
										npcGetInfo.FaceTowards(VecEnemy, 15000.0);
										Elemental_AddCorruptionDamage(Temp_Target, entity, 20);
										TwinsTele=true;
									}
								}
							}
							AllDieTwins=false;
						}
						else
							AllDieTwins=true;
						entity = EntRefToEntIndex(TempTargetTwo[npc.index]);
						if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(npc.index))
						{
							if(npc.m_flDead_Ringer_Invis < gameTime)
							{
								VausMagicaGiveShield(entity, CountPlayersOnRed(1) * 2);
								GrantEntityArmor(entity, false, 1.0, 0.5, 0, float(ReturnEntityMaxHealth(entity))*0.075);
								npc.m_flDead_Ringer_Invis = gameTime + 24.5;
							}
							if(TempDelayOne[npc.index] < GetGameTime())
							{
								int Temp_Target = Victoria_GetTargetDistance(entity, true, false);
								if(IsValidEnemy(entity, Temp_Target))
								{
									static float hullcheckmaxs[3];
									static float hullcheckmins[3];
									hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
									hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );
									float VecEnemy[3]; WorldSpaceCenter(Temp_Target, VecEnemy);
									float vPredictedPos[3];
									PredictSubjectPosition(npc, Temp_Target,_,_, vPredictedPos);
									vPredictedPos = GetBehindTarget(Temp_Target, 30.0 ,vPredictedPos);

									float PreviousPos[3];
									WorldSpaceCenter(entity, PreviousPos);
									float WorldSpaceVec[3]; WorldSpaceCenter(entity, WorldSpaceVec);
									
									bool Succeed = Npc_Teleport_Safe(entity, vPredictedPos, hullcheckmins, hullcheckmaxs, true);
									if(Succeed)
									{
										Matrix_Twins npcGetInfo = view_as<Matrix_Twins>(entity);
										float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
										float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);

										TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
										TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
										TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
										TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
										npcGetInfo.FaceTowards(VecEnemy, 15000.0);
										Elemental_AddCorruptionDamage(Temp_Target, entity, 20);
										TwinsTele=true;
									}
								}
							}
							AllDieTwins=false;
						}
						else
							AllDieTwins=true;
						if(TwinsTele)
						{
							npc.PlayTeleSound();
							TempDelayOne[npc.index] = GetGameTime() + 20.0;
						}
						if(AllDieTwins)
							npc.m_iOverlordComboAttack=2;
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
					case 2:
					{
						b_NpcForcepowerupspawn[npc.index] = 0;
						i_RaidGrantExtra[npc.index] = 0;
						b_DissapearOnDeath[npc.index] = true;
						b_DoGibThisNpc[npc.index] = true;
						SmiteNpcToDeath(npc.index);
					}
				}
			}
		}
		case 3000:
		{
			bool there_is_no_one=true;
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
				if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == TFTeam_Blue)
				{
					there_is_no_one=false;
				}
			}
			if(there_is_no_one)
			{
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
			else if(npc.m_flNextMeleeAttack < gameTime)
			{
				WaveStart_SubWaveStart(GetGameTime() + 3000.0);
				npc.m_flNextMeleeAttack = gameTime + 2250.0;
			}
		}
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
}

static Action Invisible_TRIGGER_Man_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Invisible_TRIGGER_Man npc = view_as<Invisible_TRIGGER_Man>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Invisible_TRIGGER_Man_NPCDeath(int entity)
{
	Invisible_TRIGGER_Man npc = view_as<Invisible_TRIGGER_Man>(entity);

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