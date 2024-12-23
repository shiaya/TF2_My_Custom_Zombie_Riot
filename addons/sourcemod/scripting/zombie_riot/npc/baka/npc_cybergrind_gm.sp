#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static ArrayList Voting;
static int VotedFor[MAXTF2PLAYERS];
static float VoteEndTime;
int CyberGrind_Difficulty;
int CyberGrind_InternalDifficulty;
bool CyberVote;
static bool TeleToU[MAXENTITIES];

void CyberGrindGM_OnMapStart_NPC()
{
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Cyber Grind GM");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_cybergrind_gm");
	strcopy(data.Icon, sizeof(data.Icon), "rnd_enemy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	PrecacheModel("models/player/spy.mdl");
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return CyberGrindGM(client, vecPos, vecAng, ally, data);
}

void ResetCyberGrindGMLogic()
{
	CyberVote = false;
}

methodmap CyberGrindGM < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public CyberGrindGM(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		CyberGrindGM npc = view_as<CyberGrindGM>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "12000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		if(!StrContains(data, "nextwave"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsValidClient(target))
					Ammo_Count_Used[target] -= (CyberGrind_InternalDifficulty>2 ? 20 : 15);
			}
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "go_wave_15"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsValidClient(target))
					Ammo_Count_Used[target] -= (CyberGrind_InternalDifficulty>2 ? 20 : 15);
			}
			
			Waves_ClearWaves();
			CurrentRound = (CyberGrind_InternalDifficulty>1 ? 13 : 14);
			CurrentWave = -1;
			Waves_Progress();
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "go_wave_30"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsValidClient(target))
					Ammo_Count_Used[target] -= (CyberGrind_InternalDifficulty>2 ? 20 : 15);
			}
			
			Waves_ClearWaves();
			CurrentRound = (CyberGrind_InternalDifficulty>1 ? 28 : 29);
			CurrentWave = -1;
			Waves_Progress();
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "go_wave_45"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsValidClient(target))
					Ammo_Count_Used[target] -= (CyberGrind_InternalDifficulty>2 ? 20 : 15);
			}
			
			Waves_ClearWaves();
			CurrentRound = (CyberGrind_InternalDifficulty>1 ? 43 : 44);
			CurrentWave = -1;
			Waves_Progress();
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "go_wave_60"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			for(int target = 1; target <= MaxClients; target++)
			{
				if(IsValidClient(target))
					Ammo_Count_Used[target] -= (CyberGrind_InternalDifficulty>2 ? 20 : 15);
			}
			
			Waves_ClearWaves();
			CurrentRound = (CyberGrind_InternalDifficulty>1 ? 58 : 59);
			CurrentWave = -1;
			Waves_Progress();
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "difficulty"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			if(CyberGrind_InternalDifficulty>2)
				NPC_SpawnNext(true, true, -1);
			WaveStart_SubWaveStart(GetGameTime() + 800.0);
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "we_got_soldine"))
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3");
			music.Time = 187;
			music.Volume = 1.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "The Game");
			strcopy(music.Artist, sizeof(music.Artist), "Disturbed");
			Music_SetRaidMusic(music);
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		else if(!StrContains(data, "final_item"))
		{
			func_NPCDeath[npc.index] = CyberGrindGM_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = CyberGrindGM_OnTakeDamage;
			func_NPCThink[npc.index] = CyberGrindGM_Final_Item;
			
			npc.m_iBleedType = BLEEDTYPE_NORMAL;
			npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
			npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
			
			//IDLE
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			npc.m_iState = 0;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.StartPathing();
			npc.m_flSpeed = 0.0;
			npc.m_iOverlordComboAttack = 0;
			npc.m_flNextMeleeAttack = 0.0;
			npc.m_flNextRangedAttack = GetGameTime() + 1.0;
			CyberGrind_Difficulty = 0;
			TeleToU[npc.index] = true;
		
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/spy/spr18_assassins_attire/spr18_assassins_attire.mdl");

			npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_hat.mdl");

			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
			return npc;
		}
		
		func_NPCDeath[npc.index] = view_as<Function>(CyberGrindGM_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(CyberGrindGM_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(CyberGrindGM_ClotThink);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = GetGameTime() + 1.0;
		CyberGrind_Difficulty = 0;
		TeleToU[npc.index] = true;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/spy/spr18_assassins_attire/spr18_assassins_attire.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_hat.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

static void CyberGrindGM_Final_Item(int iNPC)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	if(npc.m_flNextRangedAttack < gameTime && TeleToU[npc.index])
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		if(npc.m_flNextRangedAttack < gameTime && TeleToU[npc.index])
		{
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_NpcIsInvulnerable[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			MakeObjectIntangeable(npc.index);
			int Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 300.0);
			switch(Decicion)
			{
				case 2:
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 150.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 50.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 0.0);
						}
					}
				}
				case 3:
				{
					//todo code on what to do if random teleport is disabled
				}
			}
			TeleToU[npc.index]=false;
			WorldSpaceCenter(npc.index, WorldSpaceVec);
			ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
			NPC_SetGoalVector(npc.index, WorldSpaceVec, true);
			npc.PlayDeathSound();
		}
	}
	
	if(!TeleToU[npc.index] && npc.m_flNextMeleeAttack < gameTime)
	{
		switch(npc.m_iOverlordComboAttack)
		{
			case 0:
			{
				CPrintToChatAll("{unique}[GM] {slateblue}Cyber Grind{default}: Congratulations, Cleared the Challenge");
				npc.m_flNextMeleeAttack = gameTime + 4.0;
				npc.m_iOverlordComboAttack=1;
			}
			case 1:
			{
				CPrintToChatAll("{unique}[GM] {slateblue}Cyber Grind{default}: Here, I'll give you the {unique}Item{default} as promised.");
				for (int client = 0; client < MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
					{
						char Give_me_the_item[512];
						Format(Give_me_the_item, sizeof(Give_me_the_item),
						"{default}He opened his briefcase and handed over the items:");
						if(CyberGrind_InternalDifficulty>0 && !(Items_HasNamedItem(client, "Widemouth Refill Port")))
						{
							Items_GiveNamedItem(client, "Widemouth Refill Port");
							Format(Give_me_the_item, sizeof(Give_me_the_item),
							"%s\n{gray}[Normal]{uncommon}''Widemouth Refill Port''{default}", Give_me_the_item);
						}
						if(CyberGrind_InternalDifficulty>1 && !(Items_HasNamedItem(client, "Builder's Blueprints")))
						{
							Items_GiveNamedItem(client, "Builder's Blueprints");
							Format(Give_me_the_item, sizeof(Give_me_the_item),
							"%s\n{red}[Hard]{darkblue}''Builder's Blueprints''{default}", Give_me_the_item);
						}
						if(CyberGrind_InternalDifficulty>2 && !(Items_HasNamedItem(client, "Sardis Gold")))
						{
							Items_GiveNamedItem(client, "Sardis Gold");
							Format(Give_me_the_item, sizeof(Give_me_the_item),
							"%s\n{collectors}[Expert]{gold}''Sardis Gold''{default}", Give_me_the_item);
						}
						CPrintToChat(client,"%s", Give_me_the_item);
					}
				}
				npc.m_flNextMeleeAttack = gameTime + 0.5;
				npc.m_iOverlordComboAttack=2;
			}
			case 2:
			{
				ResetReplications();
				cvarTimeScale.SetFloat(0.1);
				CreateTimer(0.5, SetTimeBack);
				if(!Music_Disabled())
					EmitCustomToAll("#zombiesurvival/music_win_1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					
				ConVar roundtime = FindConVar("mp_bonusroundtime");
				float last = roundtime.FloatValue;
				roundtime.FloatValue = 20.0;

				MVMHud_Disable();
				int entity = CreateEntityByName("game_round_win"); 
				DispatchKeyValue(entity, "force_map_reset", "1");
				SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Red);
				DispatchSpawn(entity);
				AcceptEntityInput(entity, "RoundWin");
				roundtime.FloatValue = last;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && !b_IsPlayerABot[client])
						Music_Stop_All(client);
				}
				RemoveAllCustomMusic();
				npc.m_iOverlordComboAttack=3;
			}
			case 3:
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
				npc.PlayDeathSound();
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
				if(IsValidEntity(npc.m_iWearable1))
				{
					SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
					SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
					SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
				}
				if(IsValidEntity(npc.m_iWearable2))
				{
					SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
					SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
					SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
				}
				if(IsValidEntity(npc.m_iTeamGlow))
					RemoveEntity(npc.m_iTeamGlow);
			}
		}
	}
}


static void CyberGrindGM_ClotThink(int iNPC)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(IsValidEntity(i_InvincibleParticle[npc.index]))
	{
		int particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
		SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
		SetEntityRenderColor(particle, 255, 255, 255, 1);
		SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
	}
	if(npc.m_flNextRangedAttack < gameTime && TeleToU[npc.index])
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		if(npc.m_flNextRangedAttack < gameTime && TeleToU[npc.index])
		{
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_NpcIsInvulnerable[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			MakeObjectIntangeable(npc.index);
			int Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 300.0);
			switch(Decicion)
			{
				case 2:
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 150.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 50.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 300.0, 0.0);
						}
					}
				}
				case 3:
				{
					//todo code on what to do if random teleport is disabled
				}
			}
			TeleToU[npc.index]=false;
			ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
			NPC_SetGoalVector(npc.index, WorldSpaceVec, true);
			npc.PlayDeathSound();
			RaidMode_SetupVote();
		}
	}

	if(CyberGrind_Difficulty>0)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			switch(npc.m_iOverlordComboAttack)
			{
				case 0:
				{
					CPrintToChatAll("{unique}[GM] {slateblue}Cyber Grind{default}: Oh, I See...");
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_iOverlordComboAttack=1;
				}
				case 1:
				{
					CPrintToChatAll("{unique}[GM] {slateblue}Cyber Grind{default}: I checked. Have a Funny Time.");
					CyberGrind_InternalDifficulty = CyberGrind_Difficulty;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_iOverlordComboAttack=2;
				}
				case 2:
				{
					Citizen_SpawnAtPoint("b");
					Citizen_SpawnAtPoint();
					CPrintToChatAll("{gray}Barney: {default}Hey! We came late to assist! Got a friend too!");
				
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

static Action CyberGrindGM_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

void RaidMode_RevoteCmd(int client)
{
	if(Voting)
	{
		VotedFor[client] = 0;
		RaidMode_CallVote(client, 1);
	}
}

static void CyberGrindGM_NPCDeath(int entity)
{
	CyberGrindGM npc = view_as<CyberGrindGM>(entity);
	
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

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

static void RaidMode_SetupVote()
{
	delete Voting;
	Voting = new ArrayList(sizeof(Vote));
	CyberVote=true;
	Vote vote;
	
	strcopy(vote.Name, sizeof(vote.Name), "Normal");
	strcopy(vote.Desc, sizeof(vote.Desc), "Normal Desc");
	vote.Config[0] = 0;
	vote.Level = 120;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Hard");
	strcopy(vote.Desc, sizeof(vote.Desc), "Hard Desc");
	vote.Config[0] = 0;
	vote.Level = 150;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Expert");
	strcopy(vote.Desc, sizeof(vote.Desc), "Expert Desc");
	vote.Config[0] = 0;
	vote.Level = 200;
	Voting.PushArray(vote);

	CreateTimer(1.0, RaidMode_VoteDisplayTimer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)>1)
		{
			RaidMode_RoundStart();
			VotedFor[client] = 0;
			RaidMode_CallVote(client);
			break;
		}
	}
}

bool RaidMode_CallVote(int client, int force = 0)
{
	if(Voting && (force || !VotedFor[client]))
	{
		Menu menu = new Menu(RaidMode_CallVoteH);
		
		SetGlobalTransTarget(client);
		
		menu.SetTitle("Vote for the Mode!:\n ");
		
		Vote vote;
		Format(vote.Name, sizeof(vote.Name), "%t", "No Vote");
		menu.AddItem(NULL_STRING, vote.Name);

		if(Voting)
		{
			int length = Voting.Length;
			for(int i; i < length; i++)
			{
				Voting.GetArray(i, vote);
				vote.Name[0] = CharToUpper(vote.Name[0]);
				Format(vote.Name, sizeof(vote.Name), "%s (Lv %d)", vote.Name, vote.Level);
				int MenuDo = ITEMDRAW_DISABLED;
				if(!vote.Level)
					MenuDo = ITEMDRAW_DEFAULT;
				if(Level[client] >= 1)
					MenuDo = ITEMDRAW_DEFAULT;
				menu.AddItem(vote.Config, vote.Name, MenuDo);
			}
		}
		
		menu.ExitButton = false;
		menu.DisplayAt(client, (force / 7 * 7), MENU_TIME_FOREVER);
		return true;
	}
	return false;
}

static int RaidMode_CallVoteH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			ArrayList list = Voting;
			if(list)
			{
				if(!choice || VotedFor[client] != choice)
				{
					VotedFor[client] = choice;
					if(VotedFor[client] == 0)
					{
						VotedFor[client] = -1;
					}
					else if(VotedFor[client] > list.Length)
					{
						VotedFor[client] = 0;
						RaidMode_CallVote(client, choice);
						return 0;
					}
					else
					{
						Vote vote;
						list.GetArray(choice - 1, vote);

						if(vote.Desc[0] && TranslationPhraseExists(vote.Desc))
						{
							CPrintToChat(client, "%t: %t", vote.Name, vote.Desc);
						}
						else
						{
							CPrintToChat(client, "%t: %s", vote.Name, vote.Desc);
						}

						RaidMode_CallVote(client, choice);
						return 0;
					}
				}
			}
			Store_Menu(client);
		}
	}
	return 0;
}

static Action RaidMode_VoteDisplayTimer(Handle timer)
{
	if(!Voting)
		return Plugin_Stop;
	
	RaidMode_DisplayHintVote();
	return Plugin_Continue;
}

static void RaidMode_DisplayHintVote()
{
	ArrayList list = Voting;
	int length = list.Length;
	if(length > 1)
	{
		int count, total;
		int[] votes = new int[length + 1];
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				total++;

				if(VotedFor[client])
				{
					count++;

 					if(VotedFor[client] > 0 && VotedFor[client] <= length)
						votes[VotedFor[client] - 1]++;
				}
			}
		}

		int top[3] = {-1, ...};
		for(int i; i < length; i++)
		{
			if(votes[i] < 1)
			{

			}
			else if(top[0] == -1 || votes[i] > votes[top[0]])
			{
				top[2] = top[1];
				top[1] = top[0];
				top[0] = i;
			}
			else if(top[1] == -1 || votes[i] > votes[top[1]])
			{
				top[2] = top[1];
				top[1] = i;
			}
			else if(top[2] == -1 || votes[i] > votes[top[2]])
			{
				top[2] = i;
			}
		}

		if(top[0] != -1)
		{
			Vote vote;
			list.GetArray(top[0], vote);
			vote.Name[0] = CharToUpper(vote.Name[0]);

			char buffer[256];
			FormatEx(buffer, sizeof(buffer), "Votes: %d/%d, %ds left\n1. %s: (%d)", count, total, RoundFloat(VoteEndTime - GetGameTime()), vote.Name, votes[top[0]]);

			for(int i = 1; i < sizeof(top); i++)
			{
				if(top[i] != -1)
				{
					list.GetArray(top[i], vote);
					vote.Name[0] = CharToUpper(vote.Name[0]);

					Format(buffer, sizeof(buffer), "%s\n%d. %s: (%d)", buffer, i + 1, vote.Name, votes[top[i]]);
				}
			}

			PrintHintTextToAll(buffer);
		}
	}
}

static void RaidMode_RoundStart()
{
	if(Voting)
	{
		VoteEndTime = GetGameTime() + 30.0;
		CreateTimer(30.0, RaidMode_EndVote, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

static Action RaidMode_EndVote(Handle timer, float time)
{
	if(Voting)
	{
		int length = Voting.Length;
		if(length)
		{
			RaidMode_DisplayHintVote();

			int[] votes = new int[length];
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					if(VotedFor[client] > 0 && GetClientTeam(client) == 2)
					{
						votes[VotedFor[client]-1]++;
					}
				}
			}
			
			int highest;
			for(int i = 1; i < length; i++)
			{
				if(votes[i] > votes[highest])
					highest = i;
			}
			
			Vote vote;
			Voting.GetArray(highest, vote);
			delete Voting;
			
			if(!StrContains(vote.Name, "Expert"))
			{
				CyberGrind_Difficulty = 3;
				CurrentCash = 4500;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -25;
				}
				
			}
			else if(!StrContains(vote.Name, "Hard"))
			{
				CyberGrind_Difficulty = 2;
				CurrentCash = 4700;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -50;
				}
			}
			else
			{
				CyberGrind_Difficulty = 1;
				CurrentCash = 5706;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -100;
				}
			}
			PrintToChatAll("%t: %t","Difficulty set to", vote.Name);
		}
	}
	return Plugin_Continue;
}
