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
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return CyberGrindGM(client, vecPos, vecAng, ally, data);
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
					Ammo_Count_Used[target] = -15;
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
					Ammo_Count_Used[target] = -15;
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
					Ammo_Count_Used[target] = -15;
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
					Ammo_Count_Used[target] = -15;
			}
			
			Waves_ClearWaves();
			CurrentRound = (CyberGrind_InternalDifficulty>1 ? 58 : 59);
			CurrentRound = 59;
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
		b_DoNotUnStuck[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
		int enemy[MAXENTITIES], Temp_Target;
		GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy));
		do
		{
			Temp_Target = enemy[GetRandomInt(0, sizeof(enemy) - 1)];
		}
		while(!IsValidEntity(Temp_Target) || GetTeam(npc.index) == GetTeam(Temp_Target) || npc.index==Temp_Target);
		float WorldSpaceVec[3]; WorldSpaceCenter(Temp_Target, WorldSpaceVec);
		TeleportEntity(npc.index, WorldSpaceVec, NULL_VECTOR, NULL_VECTOR);
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		RaidMode_SetupVote();
		TeleToU[npc.index]=false;
		npc.PlayDeathSound();	
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
	
	strcopy(vote.Name, sizeof(vote.Name), "Standard");
	strcopy(vote.Desc, sizeof(vote.Desc), "Standard Desc");
	vote.Config[0] = 0;
	vote.Level = 120;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Expert");
	strcopy(vote.Desc, sizeof(vote.Desc), "Expert Desc");
	vote.Config[0] = 0;
	vote.Level = 150;
	Voting.PushArray(vote);
	
	strcopy(vote.Name, sizeof(vote.Name), "Hard");
	strcopy(vote.Desc, sizeof(vote.Desc), "Hard Desc");
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
							CPrintToChat(client, "%s: %t", vote.Name, vote.Desc);
						}
						else
						{
							CPrintToChat(client, "%s: %s", vote.Name, vote.Desc);
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
		VoteEndTime = GetGameTime() + 40.0;
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
			
			if(!StrContains(vote.Name, "Hard"))
			{
				CyberGrind_Difficulty = 3;
				CurrentCash = 4000;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
						Ammo_Count_Used[client] = -10;
				}
				
			}
			else if(!StrContains(vote.Name, "Expert"))
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
			PrintToChatAll("%t: %s","Difficulty set to", vote.Name);
		}
	}
	return Plugin_Continue;
}

