#pragma semicolon 1
#pragma newdecls required

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
		Invisible_TRIGGER_Man npc = view_as<Invisible_TRIGGER_Man>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "12000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.i_NPCStats=0;
		if(!StrContains(data, "cover_blitzkrieg"))
			npc.i_NPCStats=1;
		if(!StrContains(data, "cover_bobthefirst"))
			npc.i_NPCStats=2;

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