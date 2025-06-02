#pragma semicolon 1
#pragma newdecls required

static int i_OrbitalCount [MAXTF2PLAYERS];
static int i_EagleCount [MAXTF2PLAYERS];
static int i_AttackCount [MAXENTITIES];
static float f_PDelay[MAXTF2PLAYERS];
static float f_PDuration[MAXTF2PLAYERS];
bool b_Iron_Will[MAXTF2PLAYERS];
static bool b_OneWave[MAXTF2PLAYERS];
static bool b_OneDown[MAXTF2PLAYERS];
static int i_SupportWeapons[MAXTF2PLAYERS];
static int i_SupportWeapon_Delete[MAXTF2PLAYERS];
static int i_SupportWeapon_Lvl[MAXTF2PLAYERS];
static float f_SupportWeapon_Timer[MAXTF2PLAYERS];

static char gRedPoint;
static int LSPR=-1;
static const char SupportWeaponList[][] =
{
	"SupportWeapon SMG-43",
	"SupportWeapon APW-1 Sniperrifle",
	"SupportWeapon RS-422 Rail Gun",
};

void M3_Abilities_forBaka(int client)
{
	switch(Attack3AbilitySlotArray[client])
	{
		case 1001:
		{
			Orbital120MMHEBarrage(client);
		}
		case 1002:
		{
			DrinkRND(client);
		}
		case 1003:
		{
			EagleBomb(client);
		}
		case 1004:
		{
			StimPacks(client);
		}
		case 1005:
		{
			Seeyou_in_HELL(client);
		}
		case 1006:
		{
			Iron_Will(client);
		}
		case 1007:
		{
			Reinforce(client, false);
		}
		case 1008:
		{
			OrbitalGASStrike(client);
		}
		case 1009:
		{
			DeployingSupportWeapon(client, false);
		}
		case 1010:
		{
			NanomachinePacks(client);
		}
		case 1011:
		{
			CharismaPotions(client);
		}
	}
}

public void M3_Abilities_Baka_Precache()
{
	gRedPoint = PrecacheModel("sprites/redglow1.vmt");
	LSPR = PrecacheModel("sprites/lgtning.vmt");
	PrecacheSound("weapons/gas_can_explode.wav");
	PrecacheSound("ambient/explosions/explode_9.wav");
	if(FileExists("sound/baka_zr/sd_de_01.mp3", true))
		PrecacheSound("baka_zr/sd_de_01.mp3", true);
	if(FileExists("sound/baka/nuke_doom.mp3", true))
		PrecacheSound("baka/nuke_doom.mp3", true);
	if(FileExists("sound/baka_zr/sd_de_02.mp3", true))
		PrecacheSound("baka_zr/sd_de_02.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_01.mp3", true))
		PrecacheSound("baka_zr/sd_spw_01.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_02.mp3", true))
		PrecacheSound("baka_zr/sd_spw_02.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_03.mp3", true))
		PrecacheSound("baka_zr/sd_spw_03.mp3", true);
}

void M3_ClearAll_forBaka()
{
	Zero(i_AttackCount);
	Zero(f_PDelay);
	Zero(f_PDuration);
	Zero(b_Iron_Will);
	Zero(b_OneWave);
	Zero(b_OneDown);
	Zero(i_SupportWeapons);
	Zero(i_SupportWeapon_Delete);
	Zero(i_SupportWeapon_Lvl);
	Zero(f_SupportWeapon_Timer);
}

void M3_AbilitiesWaveEnd_forBaka()
{
	Zero(i_OrbitalCount);
	Zero(i_EagleCount);
	Zero(b_OneWave);
	i_MaxRevivesAWave = 0;
}

public void DeployingSupportWeapon(int client, bool NoCD)
{
	if(ability_cooldown[client] < GetGameTime() || NoCD)
	{
		if(!NoCD)
		{
			if(i_OrbitalCount[client] >= 1)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Orbital Cannon Out of Ammo This Round, Reload");	
				return;
			}
			i_OrbitalCount[client] += 1;
			ability_cooldown[client] = GetGameTime() + 300.0;
			CreateTimer(300.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		int entity = CreateEntityByName("tf_projectile_pipe_remote");	

		if(IsValidEntity(entity))
		{
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
			if(team==TFTeam_Spectator)team=TFTeam_Red;
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			SetEntProp(entity, Prop_Send, "m_iType", 1);

			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);	
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			f_HealDelay[entity] = GetGameTime() + 5.0;
			i_AttackCount[entity] = 0;
			i_SupportWeapon_Lvl[client]=RoundToFloor(float(CashSpentTotal[client])/5000.0);
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			int GETRNG=GetRandomInt(1, 5);
			for(int all=1; all<=MaxClients; all++)
			{
				if(IsValidClient(all) && !IsFakeClient(all))
				{
					switch(GETRNG)
					{
						case 1: EmitSoundToClient(all, "baka_zr/sd_de_01.mp3", _, _, _, _, 0.8, _, _, _, _, false);
						case 2: EmitSoundToClient(all, "baka_zr/sd_de_02.mp3", _, _, _, _, 0.8, _, _, _, _, false);
						case 3: EmitSoundToClient(all, "baka_zr/sd_spw_01.mp3", _, _, _, _, 0.8, _, _, _, _, false);
						case 4: EmitSoundToClient(all, "baka_zr/sd_spw_02.mp3", _, _, _, _, 0.8, _, _, _, _, false);
						case 5: EmitSoundToClient(all, "baka_zr/sd_spw_03.mp3", _, _, _, _, 0.8, _, _, _, _, false);
					}
				}
			}
			DataPack pack;
			CreateDataTimer(0.1, Timer_SupportWeapon_Stratagems, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public Action Timer_SupportWeapon_Stratagems(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float position[3], Laserpos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
			
			EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);
			Laserpos[0] = position[0];
			Laserpos[1] = position[1];
			Laserpos[2] = position[2] + 1500.0;
			
			TE_SetupBeamPoints(Laserpos, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, {0, 150, 255, 255}, 3);
			TE_SendToAll();
			Laserpos[2] -= 1490.0;
			TE_SetupGlowSprite(Laserpos, gBluePoint2, 1.0, 1.0, 255);
			TE_SendToAll();
			if(f_HealDelay[entity] < GetGameTime())
			{
				switch(i_AttackCount[entity])
				{
					case 1:
					{
						Drop_Prop(client, position, 2000.0, "ZR_SupportWeapon_", "models/props_urban/urban_crate002.mdl");
						EmitSoundToAll("weapons/air_burster_explode3.wav", 0, SNDCHAN_AUTO, SNDLEVEL_TRAIN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);
						i_AttackCount[entity]=2;
					}
					default:
					{
						i_AttackCount[entity]++;
					}
				}
   			}
   			if(i_AttackCount[entity]>=2)
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;	
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

public Action Timer_SupportWeapon_Get(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float position[3], position2[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
			for(int target=1; target<=MaxClients; target++)
			{
				if(IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
				{
					int SupportWeaponIslive = EntRefToEntIndex(i_SupportWeapon_Delete[target]);
					if(IsValidEntity(SupportWeaponIslive))
						continue;
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", position2);
					float distance = GetVectorDistance(position, position2);
					if(distance<=50.0)
					{
						i_SupportWeapons[target]=GetRandomInt(0, 2);
						int SupportWeapon = Store_GiveSpecificItem(target, SupportWeaponList[i_SupportWeapons[target]]);
						if(IsValidEntity(SupportWeapon))
						{
							switch(i_SupportWeapon_Lvl[client])
							{
								case 1:
								{
									if(i_SupportWeapons[target]!=2)
									{
										Attributes_SetMulti(SupportWeapon, 205, 0.9);
										Attributes_SetMulti(SupportWeapon, 206, 0.9);
										Attributes_SetMulti(SupportWeapon, 106, 0.9);
										Attributes_SetMulti(SupportWeapon, 103, 1.20);
										Attributes_SetMulti(SupportWeapon, 2, 1.5);
									}
									else
										Attributes_SetMulti(SupportWeapon, 2, 1.5);
								}
								case 2:
								{
									if(i_SupportWeapons[target]!=2)
									{
										Attributes_SetMulti(SupportWeapon, 205, 0.9);
										Attributes_SetMulti(SupportWeapon, 206, 0.9);
										Attributes_SetMulti(SupportWeapon, 106, 0.9);
										Attributes_SetMulti(SupportWeapon, 103, 1.20);
										Attributes_SetMulti(SupportWeapon, 2, 2.4);
									}
									else
										Attributes_SetMulti(SupportWeapon, 2, 2.4);
								}
								case 3:
								{
									if(i_SupportWeapons[target]!=2)
									{
										Attributes_SetMulti(SupportWeapon, 205, 0.9);
										Attributes_SetMulti(SupportWeapon, 206, 0.9);
										Attributes_SetMulti(SupportWeapon, 106, 0.9);
										Attributes_SetMulti(SupportWeapon, 103, 1.20);
										Attributes_SetMulti(SupportWeapon, 97, 0.85);
										Attributes_SetMulti(SupportWeapon, 6, 0.85);
										Attributes_SetMulti(SupportWeapon, 4, 1.25);
										Attributes_SetMulti(SupportWeapon, 2, 3.84);
									}
									else
										Attributes_SetMulti(SupportWeapon, 2, 3.84);
								}
								case 4:
								{
									if(i_SupportWeapons[target]!=2)
									{
										Attributes_SetMulti(SupportWeapon, 205, 0.9);
										Attributes_SetMulti(SupportWeapon, 206, 0.9);
										Attributes_SetMulti(SupportWeapon, 106, 0.9);
										Attributes_SetMulti(SupportWeapon, 103, 1.20);
										Attributes_SetMulti(SupportWeapon, 97, 0.85);
										Attributes_SetMulti(SupportWeapon, 6, 0.85);
										Attributes_SetMulti(SupportWeapon, 4, 1.25);
										Attributes_SetMulti(SupportWeapon, 2, 4.608);
									}
									else
										Attributes_SetMulti(SupportWeapon, 2, 4.608);
								}
								case 5:
								{
									if(i_SupportWeapons[target]!=2)
									{
										Attributes_SetMulti(SupportWeapon, 205, 0.9);
										Attributes_SetMulti(SupportWeapon, 206, 0.9);
										Attributes_SetMulti(SupportWeapon, 106, 0.9);
										Attributes_SetMulti(SupportWeapon, 103, 1.20);
										Attributes_SetMulti(SupportWeapon, 97, 0.85);
										Attributes_SetMulti(SupportWeapon, 6, 0.85);
										Attributes_SetMulti(SupportWeapon, 4, 1.25);
										Attributes_SetMulti(SupportWeapon, 2, 7.3728);
									}
									else
										Attributes_SetMulti(SupportWeapon, 2, 7.3728);
								}
								case 6, 7, 8, 9:
								{
									if(i_SupportWeapons[target]!=2)
									{
										Attributes_SetMulti(SupportWeapon, 205, 0.9);
										Attributes_SetMulti(SupportWeapon, 206, 0.9);
										Attributes_SetMulti(SupportWeapon, 106, 0.9);
										Attributes_SetMulti(SupportWeapon, 103, 1.20);
										Attributes_SetMulti(SupportWeapon, 97, 0.85);
										Attributes_SetMulti(SupportWeapon, 6, 0.85);
										Attributes_SetMulti(SupportWeapon, 4, 1.25);
										Attributes_SetMulti(SupportWeapon, 2, 12.16512);
									}
									else
										Attributes_SetMulti(SupportWeapon, 2, 12.16512);
								}
								case 10:
								{
									if(i_SupportWeapons[target]!=2)
									{
										Attributes_SetMulti(SupportWeapon, 205, 0.9);
										Attributes_SetMulti(SupportWeapon, 206, 0.9);
										Attributes_SetMulti(SupportWeapon, 106, 0.9);
										Attributes_SetMulti(SupportWeapon, 103, 1.20);
										Attributes_SetMulti(SupportWeapon, 97, 0.7225);
										Attributes_SetMulti(SupportWeapon, 6, 0.7225);
										Attributes_SetMulti(SupportWeapon, 4, 1.5625);
										Attributes_SetMulti(SupportWeapon, 2, 19.464192);
									}
									else
										Attributes_SetMulti(SupportWeapon, 2, 19.464192);
								}
							}
						}
						SetAmmo(target, 1, 9999);
						SetAmmo(target, 2, 9999);
						f_SupportWeapon_Timer[target] =  GetGameTime() + 50.0;
						i_SupportWeapon_Delete[target] = EntIndexToEntRef(SupportWeapon);
						RemoveEntity(entity);
						SDKUnhook(target, SDKHook_PreThink, SupportWeapon_Think);
						SDKHook(target, SDKHook_PreThink, SupportWeapon_Think);
						return Plugin_Stop;	
					}
				}
			}
   			if(f_HealDelay[entity] < GetGameTime())
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;	
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

public void SupportWeapon_Think(int client)
{
	if(f_SupportWeapon_Timer[client] < GetGameTime())
	{
		Store_RemoveSpecificItem(client, SupportWeaponList[i_SupportWeapons[client]]);
		//We are Done, kill think.
		int SupportWeaponIslive = EntRefToEntIndex(i_SupportWeapon_Delete[client]);
		if(IsValidEntity(SupportWeaponIslive))
		{
			TF2_RemoveItem(client, SupportWeaponIslive);
		}
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
		TF2_AutoSetActiveWeapon(client);
		SDKUnhook(client, SDKHook_PreThink, SupportWeapon_Think);
		return;
	}	
}

public void OrbitalGASStrike(int client)
{
	if(ability_cooldown[client] < GetGameTime())
	{
		if(i_OrbitalCount[client] >= 3)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Orbital Cannon Out of Ammo This Round, Reload");	
			return;
		}
		i_OrbitalCount[client] += 1;
		ability_cooldown[client] = GetGameTime() + 50.0;
		CreateTimer(50.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		int entity = CreateEntityByName("tf_projectile_pipe_remote");	

		if(IsValidEntity(entity))
		{
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			SetEntProp(entity, Prop_Send, "m_iType", 1);

			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);	
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			float damage = 5+(Pow(float(CashSpentTotal[client]), 1.225))/10000.0;
			if(damage<5.0)damage=5.0;
			
			f_HealDelay[entity] = GetGameTime() + 3.0;
			i_AttackCount[entity] = 0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			
			if(GetRandomInt(0, 100)>50)
				ClientCommand(client, "playgamesound baka_zr/su_ogs_01.mp3");
			else
				ClientCommand(client, "playgamesound baka_zr/su_ogs_02.mp3");
			DataPack pack;
			CreateDataTimer(0.1, Timer_Orbital_GAS_Stratagems, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteFloat(damage);	
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public Action Timer_Orbital_GAS_Stratagems(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadFloat();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float bomb_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", bomb_pos);
			int color[4];
			
			color = {145, 47, 47, 200};
	
			TE_SetupBeamRingPoint(bomb_pos, 500.0 * 2.0, (500.0 * 2.0)+0.5, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
			TE_SendToAll();
			float position[3];
			position[0] = bomb_pos[0];
			position[1] = bomb_pos[1];
			position[2] = bomb_pos[2] + 1500.0;
			
			TE_SetupBeamPoints(bomb_pos, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3);
			TE_SendToAll();
			position[2] -= 1490.0;
			TE_SetupGlowSprite(bomb_pos, gRedPoint, 1.0, 1.0, 255);
			TE_SendToAll();
			if(f_HealDelay[entity] < GetGameTime())
			{
				if(i_AttackCount[entity]>0)
				{
					float position2[3], distance;
					for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
					{
						int npc = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
						if(IsValidEntity(npc) && GetTeam(npc) != TFTeam_Red)
						{
							GetEntPropVector(npc, Prop_Send, "m_vecOrigin", position2);
							distance = GetVectorDistance(position, position2);
							if(distance<500.0)
							{
								SDKHooks_TakeDamage(npc, client, client, damage, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
								NpcStats_SpeedModifyEnemy(npc, 1.0, 0.9, true);
							}
						}
					}
					if(f_Duration[entity] < GetGameTime())
					{
						position[2] += 50.0;
						float fPos[3], fDir[2];
						for (int i = 0; i < RoundFloat(500.0 / 64.0); ++i)
						{
							float fRadius = GetRandomFloat(470.0, 500.0);

							fDir[0] = GetRandomFloat(0.0, 2.0 * 3.1415); // radians
							fDir[1] = GetRandomFloat(0.0, 2.0 * 3.1415);
							GetPointOnSphere(position, fDir, fRadius, fPos);

							ParticleEffectAt(fPos, "peejar_impact_cloud_gas", 1.0);
						}
						f_Duration[entity] = GetGameTime() + 1.0;
					}
				}
				else
				{
					ParticleEffectAt(position, "rd_robot_explosion", 1.0);
					EmitSoundToAll("weapons/gas_can_explode.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, position);
				}
				i_AttackCount[entity]++;
   			}
   			if(i_AttackCount[entity]>(Items_HasNamedItem(client, "Whiteflower's Elite Grenade") ? 120 : 100))
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

public void Iron_Will(int client)
{
	if(dieingstate[client] > 0)
	{
		if(ability_cooldown[client] > GetGameTime())
		{
			float Ability_CD = ability_cooldown[client] - GetGameTime();

			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		if(b_Iron_Will[client] || b_OneWave[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "1 per wave");
			return;
		}
		ability_cooldown[client] = GetGameTime() + 300.0;
		CreateTimer(300.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		b_Iron_Will[client]=true;
		b_OneWave[client]=true;
		
		float clientpos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientpos);
		SpawnSmallExplosion(clientpos);
		b_LeftForDead[client] = true;
		dieingstate[client] = 5; // 5 seconds
		i_AmountDowned[client]--;
		f_PDelay[client]=GetGameTime() + 10.0;
		CreateTimer(0.1, Timer_Iron_Will_Activated, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Down");
	}
}

public Action Timer_Iron_Will_Activated(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		int maxhealth = RoundToFloor(float(SDKCall_GetMaxHealth(client))*0.5);
		int health = GetClientHealth(client);
		int color[4];
		float clientpos[3], position[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientpos);
		color = {145, 47, 47, 200};
		position[0] = clientpos[0];
		position[1] = clientpos[1];
		position[2] = clientpos[2] + 1500.0;
		TE_SetupBeamPoints(clientpos, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3);
		TE_SendToAll();
		position[2] -= 1490.0;
		TE_SetupGlowSprite(clientpos, gRedPoint, 1.0, 1.0, 255);
		TE_SendToAll();
		if(f_PDelay[client] < GetGameTime() && health < maxhealth)
		{
			b_Iron_Will[client]=false;
			SDKHooks_TakeDamage(client, 0, 0, float(health)*3.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
			if(dieingstate[client] > 0)
				return Plugin_Stop;
		}
		if(health>=maxhealth && dieingstate[client] <= 0)
		{
			b_Iron_Will[client]=false;
			return Plugin_Stop;	
		}
		return Plugin_Continue;	
	}
	else
	{
		return Plugin_Stop;	
	}
}

public void Seeyou_in_HELL(int client)
{
	if(dieingstate[client] > 0)
	{
		if(ability_cooldown[client] > GetGameTime())
		{
			float Ability_CD = ability_cooldown[client] - GetGameTime();

			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		if(b_OneDown[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "1 per down");
			return;
		}
		ability_cooldown[client] = GetGameTime() + 10.0;
		b_OneDown[client]=true;
		
		float clientpos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientpos);
		EmitSoundToAll("weapons/air_burster_explode3.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, clientpos);
		int color[4];
		color = {145, 47, 47, 200};
		TE_SetupBeamRingPoint(clientpos, 0.5, 650.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
		TE_SendToAll();
		SpawnSmallExplosion(clientpos);
		FakeClientCommandEx(client, "voicemenu 2 1");
		float entitypos[3], distance;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
				distance = GetVectorDistance(clientpos, entitypos);
				if(distance<650.0)
				{
					FreezeNpcInTime(entity, (b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] ? 3.0 : 6.0), true);
					ApplyStatusEffect(client, entity, "Silenced", (b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] ? 3.0 : 6.0));
					float MaxHealth = float(ReturnEntityMaxHealth(entity));
					float damage=(MaxHealth*0.02)+(Pow(float(CashSpentTotal[client]), 1.18)/9.0);
					SDKHooks_TakeDamage(entity, client, client, damage, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
				}
			}
		}
		CreateTimer(0.1, Timer_Seeyou_in_HELL_Reload, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Down");
	}
}

public Action Timer_Seeyou_in_HELL_Reload(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		if(dieingstate[client] <= 0)
		{
			b_OneDown[client]=false;
			return Plugin_Stop;
		}
		return Plugin_Continue;
	}
	else
		return Plugin_Stop;
}

public void StimPacks(int client)
{
	if(dieingstate[client] > 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Alive");
		return;
	}
	else
	{
		if(ability_cooldown[client] > GetGameTime())
		{
			float Ability_CD = ability_cooldown[client] - GetGameTime();

			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		ability_cooldown[client] = GetGameTime() + 15.0;
		CreateTimer(15.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		int maxhealth = SDKCall_GetMaxHealth(client);
		int health = GetClientHealth(client);
		int newhealth=RoundFloat(maxhealth*0.25);
		if(newhealth>health)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Low Health No Use");
			return;
		}
		FakeClientCommandEx(client, "voicemenu 2 1");
		SDKHooks_TakeDamage(client, 0, 0, float(newhealth), DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
		TF2_RemoveCondition(client, TFCond_KingAura);
		TF2_AddCondition(client, TFCond_KingAura, 10.0);
		TF2_RemoveCondition(client, TFCond_Buffed);
		TF2_AddCondition(client, TFCond_Buffed, 10.0);
	}
}

public void NanomachinePacks(int client)
{
	if(dieingstate[client] > 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Alive");
		return;
	}
	else
	{
		if(ability_cooldown[client] > GetGameTime())
		{
			float Ability_CD = ability_cooldown[client] - GetGameTime();

			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		ability_cooldown[client] = GetGameTime() + 75.0;
		CreateTimer(75.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		MakePlayerGiveResponseVoice(client, 4);
		ApplyStatusEffect(client, client, "Nanomachine", 10.0);
	}
}

public void CharismaPotions(int client)
{
	if(dieingstate[client] > 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Alive");
		return;
	}
	else
	{
		if(ability_cooldown[client] > GetGameTime())
		{
			float Ability_CD = ability_cooldown[client] - GetGameTime();

			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		ability_cooldown[client] = GetGameTime() + 75.0;
		CreateTimer(75.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		MakePlayerGiveResponseVoice(client, 4);
		ApplyStatusEffect(client, client, "Charisma Effect", 10.0);
		ApplyStatusEffect(client, client, "Charisma Effect Detect", 9.5);
	}
}

public void EagleBomb(int client)
{
	if(ability_cooldown[client] < GetGameTime())
	{
		if(i_EagleCount[client] >= 1)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Eagle 1 Out of Ammo This Round, Reload");	
			return;
		}
		i_EagleCount[client] += 1;
		ability_cooldown[client] = GetGameTime() + 60.0;
		CreateTimer(60.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		int entity = CreateEntityByName("tf_projectile_pipe_remote");	

		if(IsValidEntity(entity))
		{
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			SetEntProp(entity, Prop_Send, "m_iType", 1);

			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);	
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
			//Make them barely bounce at all.
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			f_HealDelay[entity] = GetGameTime();
			i_AttackCount[entity] = 0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			
			switch(GetRandomInt(1, 6))
			{
				case 1:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_administering_freedom.mp3\"");}
				case 2:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_attack_underway.mp3\"");}
				case 3:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_coming_in_hot.mp3\"");}
				case 4:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_democracy_is_on_its_way.mp3\"");}
				case 5:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_eat_liberty.mp3\"");}
				case 6:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_here_comes_the_cavalry.mp3\"");}
			}
			CreateTimer(0.1, Timer_EagleRearm_Stratagems, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			DataPack pack;
			CreateDataTimer(0.1, Timer_EagleBomb_Stratagems, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public Action Timer_EagleBomb_Stratagems(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float bomb_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", bomb_pos);
			int color[4];
			
			color = {145, 47, 47, 200};
	
			TE_SetupBeamRingPoint(bomb_pos, 350.0 * (f_HealDelay[entity]-GetGameTime()), (350.0 * (f_HealDelay[entity]-GetGameTime()))+0.5, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
			TE_SendToAll();
			float position[3];
			position[0] = bomb_pos[0];
			position[1] = bomb_pos[1];
			position[2] = bomb_pos[2] + 1500.0;
			
			TE_SetupBeamPoints(bomb_pos, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3);
			TE_SendToAll();
			position[2] -= 1490.0;
			TE_SetupGlowSprite(bomb_pos, gRedPoint, 1.0, 1.0, 255);
			TE_SendToAll();
			if(f_HealDelay[entity] < GetGameTime())
			{
				switch(i_AttackCount[entity])
				{
					case 1:
					{
						Drop_Prop(client, position, 2000.0, "ZR_Bomb", "models/props_trainyard/cart_bomb_separate.mdl");
						switch(GetRandomInt(1, 4))
						{
							case 1:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_leaving_combat_zone_to_resupply.mp3\"");}
							case 2:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_rearming_be_back_shortly.mp3\"");}
							case 3:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_returning_to_destroyer_to_resuply.mp3\"");}
							case 4:{ClientCommand(client, "playgamesound \"baka_zr/eagle-1_withdrawing_to_rearm.mp3\"");}
						}
						i_AttackCount[entity]=2;
					}
					default:
					{
						i_AttackCount[entity]++;
						f_HealDelay[entity] = GetGameTime() + (Items_HasNamedItem(client, "Whiteflower's Elite Grenade") ? 2.0 : 3.0);
					}
				}
   			}
   			if(i_AttackCount[entity]>=2)
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;	
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

public Action Timer_EagleRearm_Stratagems(Handle timer, int ref)
{
	int client = GetClientOfUserId(ref);
	if(IsValidClient(client) && i_EagleCount[client] < 1 && ability_cooldown[client] < GetGameTime())
	{
		ClientCommand(client, "playgamesound baka_zr/eagle-1_super_earths_finest_back_in_action.mp3");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void DrinkRND(int client)
{
	if(ability_cooldown[client] < GetGameTime())
	{
		EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", client, SNDCHAN_STATIC, 70, _, 0.9);
		ability_cooldown[client] = GetGameTime() + 60.0;
		CreateTimer(60.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		int GetRND=-1;
		if(Items_HasNamedItem(client, "Atomizer's Special Drink Pack"))
			GetRND=GetRandomInt(1, 13);
		else
			GetRND=GetRandomInt(1, 9);
		f_PDelay[client]=GetGameTime();
		float AddTime;
		switch(GetRND)
		{
			case 10:AddTime=0.1;
			case 11:AddTime=20.0;
			case 13:AddTime=10.0;
			default:AddTime=30.0;
		}
		f_PDuration[client]=GetGameTime() + AddTime;
		char RNDWeaponName[512];
		FormatEx(RNDWeaponName, sizeof(RNDWeaponName), "Get_DrinkRND_%i", GetRND);
		if(TranslationPhraseExists(RNDWeaponName))
		{
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", RNDWeaponName);
		}
		else PrintToChat(client, "[%i] No Translation?", GetRND);
		DataPack pack;
		CreateDataTimer(0.1, Timer_DrinkRND, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(GetRND);
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public Action Timer_DrinkRND(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int GetRND = pack.ReadCell();
	if(IsValidClient(client))
	{
		switch(GetRND)
		{
			case 1:
			{
				if(f_PDelay[client] < GetGameTime())
				{
					GiveArmorViaPercentage(client, 0.075, 1.0);
					f_PDelay[client]=GetGameTime() + 0.2;
				}
			}
			case 2:
			{
				if(f_PDelay[client] < GetGameTime())
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
						HealEntityGlobal(client, client, 25.0, 1.0, _, HEAL_SELFHEAL);
					}
					f_PDelay[client]=GetGameTime() + 0.2;
				}
			}
			case 3:
			{
				int health = GetClientHealth(client), selfDMG = 5;
				int safety = health-selfDMG;
				if(health>1)
				{
					if(safety>1)
						SDKHooks_TakeDamage(client, 0, 0, float(selfDMG), DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
					else
						SetEntityHealth(client, 1);
				}
			}
			case 4:
			{
				TF2_RemoveCondition(client, TFCond_ObscuredSmoke);
				TF2_AddCondition(client, TFCond_ObscuredSmoke, 1.0);
				TF2_RemoveCondition(client, TFCond_SpeedBuffAlly);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
				if(Items_HasNamedItem(client, "Atomizer's Special Drink Pack"))
				{
					ApplyStatusEffect(client, client, "Caffinated", 2.6);
					ApplyStatusEffect(client, client, "Caffinated Drain", 1.1);
				}
				if(f_PDuration[client] < GetGameTime())
				{
					TF2_RemoveCondition(client, TFCond_MarkedForDeath);
					TF2_AddCondition(client, TFCond_MarkedForDeath, 10.0);
					TF2_StunPlayer(client, 10.0, 0.9, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN, client);
				}
			}
			case 5:
			{
				SetEntityHealth(client, 1);
				return Plugin_Stop;
			}
			case 6:
			{
				TF2_RemoveCondition(client, TFCond_Buffed);
				TF2_AddCondition(client, TFCond_Buffed, 30.0);
				TF2_RemoveCondition(client, TFCond_KingAura);
				TF2_AddCondition(client, TFCond_KingAura, 30.0);
				return Plugin_Stop;
			}
			case 7:
			{
				if(!TF2_IsPlayerInCondition(client, TFCond_OnFire))
				{
					TF2_IgnitePlayer(client, client, 10.0);
					TF2_AddCondition(client, TFCond_HealingDebuff, 10.0);
				}
				SDKHooks_TakeDamage(client, 0, 0, 4.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
			}
			case 8:
			{
				TF2_StunPlayer(client, 30.0, 0.5, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN, client);
				return Plugin_Stop;
			}
			case 9:
			{
				TF2_RemoveCondition(client, TFCond_UberchargedCanteen);
				TF2_AddCondition(client, TFCond_UberchargedCanteen, 5.0);
				return Plugin_Stop;
			}
			case 10:
			{
				if(f_PDuration[client] < GetGameTime() && f_PDelay[client] < GetGameTime())
				{
					int health = GetClientHealth(client);
					float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
					TimedLgtning(client, WorldSpaceVec);
					if(!IsInvuln(client))
					{
						if(health>2)
							SDKHooks_TakeDamage(client, 0, 0, float(health/2), DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
						else
							SDKHooks_TakeDamage(client, 0, 0, 195.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
					}
					else
					{
						int newhealth = health/2;
						if(health>2)
							SetEntityHealth(client, newhealth);
						else
							ForcePlayerSuicide(client);
					}
					f_PDelay[client] = GetGameTime() + 60.0;
					f_PDuration[client] = GetGameTime() + 20.0;
				}
				ApplyStatusEffect(client, client, "Weapon Clocking", 0.5);
				ApplyStatusEffect(client, client, "Weapon Overclock", 1.0);
				Kritzkrieg_Magical(client, 0.2, true);
			}
			case 11:
			{
				float damage = 10.0+(Pow(float(CashSpentTotal[client]), 1.225))/10000.0;
				if(damage<10.0)damage=10.0;
				float position[3]; WorldSpaceCenter(client, position);
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int npc = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
					if(IsValidEntity(npc) && GetTeam(npc) != TFTeam_Red)
					{
						float position2[3], distance;
						GetEntPropVector(npc, Prop_Send, "m_vecOrigin", position2);
						distance = GetVectorDistance(position, position2);
						if(distance<300.0)
						{
							SDKHooks_TakeDamage(npc, client, client, damage, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
							NpcStats_SpeedModifyEnemy(npc, 1.0, 0.9, true);
						}
					}
				}
				if(f_PDelay[client] < GetGameTime())
				{
					position[2] += 50.0;
					float fPos[3], fDir[2];
					for (int i = 0; i < RoundFloat(200.0 / 64.0); ++i)
					{
						float fRadius = GetRandomFloat(170.0, 200.0);

						fDir[0] = GetRandomFloat(0.0, 2.0 * 3.1415); // radians
						fDir[1] = GetRandomFloat(0.0, 2.0 * 3.1415);
						GetPointOnSphere(position, fDir, fRadius, fPos);

						ParticleEffectAt(fPos, "peejar_impact_cloud_gas", 1.0);
					}
					f_PDelay[client] = GetGameTime() + 0.6;
				}
			}
			case 12:
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
				ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);
				int TempTarget;
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
					if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
					{
						TempTarget=entity;
						break;
					}
				}
				if(IsValidEntity(TempTarget))
				{
					UnderTides npcGetInfo = view_as<UnderTides>(TempTarget);
					int AllyNPC[MAXENTITIES];
					GetHighDefTargets(npcGetInfo, AllyNPC, sizeof(AllyNPC));
					for( int loop = 1; loop <= 500; loop++ ) 
					{
						TempTarget = AllyNPC[GetRandomInt(0, sizeof(AllyNPC) - 1)];
						if(!IsValidEntity(TempTarget) || GetTeam(client) != GetTeam(TempTarget) || client==TempTarget)
							continue;
						else
							break;
					}
					
					if(IsValidEntity(TempTarget) && GetTeam(client) == GetTeam(TempTarget))
					{
						WorldSpaceCenter(TempTarget, WorldSpaceVec);
						ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);
						TeleportEntity(client, WorldSpaceVec, NULL_VECTOR, NULL_VECTOR);
						EmitSoundToAll(g_TeleSounds[GetRandomInt(0, sizeof(g_TeleSounds) - 1)], client, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
						return Plugin_Stop;
					}
				}
				
				int Decicion = TeleportDiversioToRandLocation(client, true, 1500.0, 1000.0);
				switch(Decicion)
				{
					case 2:
					{
						Decicion = TeleportDiversioToRandLocation(client, true, 1500.0, 500.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(client, true, 1500.0, 250.0);
							if(Decicion == 2)
							{
								Decicion = TeleportDiversioToRandLocation(client, true, 1500.0, 0.0);
							}
						}
					}
					case 3:
					{
						ability_cooldown[client] = GetGameTime() + 5.0;
						return Plugin_Stop;
					}
				}
				WorldSpaceCenter(client, WorldSpaceVec);
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
				EmitSoundToAll(g_TeleSounds[GetRandomInt(0, sizeof(g_TeleSounds) - 1)], client, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
				return Plugin_Stop;
			}
			case 13:
			{
				b_DrinkRND_BuildingCD_Buff[client]=true;
				if(f_PDuration[client] < GetGameTime())
					b_DrinkRND_BuildingCD_Buff[client]=false;
			}
		}
		if(f_PDuration[client] < GetGameTime())
			return Plugin_Stop;	
		return Plugin_Continue;
	}
	else
		return Plugin_Stop;
}

public void Orbital120MMHEBarrage(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		if(i_OrbitalCount[client] >= 2)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Orbital Cannon Out of Ammo This Round, Reload");	
			return;
		}
		i_OrbitalCount[client] += 1;
		ability_cooldown[client] = GetGameTime() + 90.0;
		CreateTimer(90.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		int entity = CreateEntityByName("tf_projectile_pipe_remote");	

		if(IsValidEntity(entity))
		{
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
			static float pos[3], ang[3], vel_2[3];
			GetClientEyeAngles(client, ang);
			GetClientEyePosition(client, pos);	
		
			ang[0] -= 8.0;
			
			float speed = 1500.0;
			
			vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel_2[2] = Sine(DegToRad(ang[0]))*speed;
			vel_2[2] *= -1;
			
			int team = GetClientTeam(client);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			SetEntProp(entity, Prop_Send, "m_iType", 1);

			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModel, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);	
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
			
			SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
			//Make them barely bounce at all.
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, ang, vel_2);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody npc = view_as<CClotBody>(entity);
			npc.m_bThisEntityIgnored = true;
			
			float damage = (Pow(float(CashSpentTotal[client]), 1.225))/50.0;
			
			f_HealDelay[entity] = GetGameTime() + 3.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			
			if(GetRandomInt(0, 100)>50)
				ClientCommand(client, "playgamesound baka_zr/su_ob_01.mp3");
			else
				ClientCommand(client, "playgamesound baka_zr/su_os_01.mp3");
			DataPack pack;
			CreateDataTimer(0.1, Timer_Orbital_HE_Barrage_Stratagems, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteFloat(damage);	
			pack.WriteCell(GetClientUserId(client));
		}
	}
	else
	{
		float Ability_CD = ability_cooldown[client] - GetGameTime();
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public Action Timer_Orbital_HE_Barrage_Stratagems(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadFloat();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float bomb_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", bomb_pos);
			int color[4];
			
			color = {145, 47, 47, 200};
	
			TE_SetupBeamRingPoint(bomb_pos, 500.0 * 2.0, (500.0 * 2.0)+0.5, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
			TE_SendToAll();
			float position[3];
			position[0] = bomb_pos[0];
			position[1] = bomb_pos[1];
			position[2] = bomb_pos[2] + 1500.0;
			
			TE_SetupBeamPoints(bomb_pos, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3);
			TE_SendToAll();
			position[2] -= 1490.0;
			TE_SetupGlowSprite(bomb_pos, gRedPoint, 1.0, 1.0, 255);
			TE_SendToAll();
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.5;
				i_AttackCount[entity]++;	
				position[0] = bomb_pos[0] + GetRandomFloat(-500.0, 500.0);
				position[1] = bomb_pos[1] + GetRandomFloat(-500.0, 500.0);	
				Explode_Logic_Custom(damage, client, client, -1, position, 850.0,_,_,false);
				
				CreateEarthquake(position, 0.5, 850.0, 16.0, 255.0);
				EmitSoundToAll(MORTAR_BOOM, 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, position);
				ParticleEffectAt(position, "rd_robot_explosion", 1.0);
   			}
   			if(i_AttackCount[entity]>(Items_HasNamedItem(client, "Whiteflower's Elite Grenade") ? 17 : 15))
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

stock void GetPointOnSphere(const float fOrigin[3], const float fDirectionRads[2], float fRadius, float fOut[3])
{
	fOut[0] = fOrigin[0] + fRadius * Cosine(fDirectionRads[0]) * Sine(fDirectionRads[1]);
	fOut[1] = fOrigin[1] + fRadius * Sine(fDirectionRads[0]) * Sine(fDirectionRads[1]);
	fOut[2] = fOrigin[2] + fRadius * Cosine(fDirectionRads[1]);
}

stock void TF2_AutoSetActiveWeapon(int client, bool NoPrimary=false, bool NoSecondary=false)
{
	int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	
	if(!NoPrimary && (primary>1 || IsValidEntity(primary)))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", primary);
	}
	else if(!NoSecondary && (secondary>1 || IsValidEntity(secondary)))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", secondary);
	}
	else if(melee>1 || IsValidEntity(melee))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", melee);
	}
}

stock void TimedLgtning(int client, float flPos[3])
{
	float LgtningPos[3];
	
	flPos[2] -= 26.0; // increase y-axis by 26 to strike at player's chest instead of the ground
	
	LgtningPos[0] = flPos[0] + 500.0 + GetRandomFloat(-125.0, 125.0);
	LgtningPos[1] = flPos[1] + 5000.0 + GetRandomFloat(-125.0, 125.0);
	LgtningPos[2] = flPos[2] + 1500.0;
	
	float dir[3] =  { 0.0, 0.0, 0.0 };
	
	TE_SetupBeamPoints(LgtningPos, flPos, LSPR, 0, 0, 0, 0.2, 160.0, 80.0, 0, 50.0, { 255, 255, 255, 255 }, 3);
	TE_SendToAll();
	
	TE_SetupSparks(flPos, dir, 7500, 2500);
	TE_SendToAll();
	
	TE_SetupEnergySplash(flPos, dir, false);
	TE_SendToAll();
	
	EmitAmbientSound("ambient/explosions/explode_9.wav", LgtningPos, client, SNDLEVEL_HELICOPTER);
}