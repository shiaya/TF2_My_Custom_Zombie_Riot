#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float ability_cooldown_2[MAXPLAYERS+1]={0.0, ...};
static int Attack3AbilitySlotArray[MAXPLAYERS+1]={0, ...};
static float f_HealDelay[MAXENTITIES];
static float f_Duration[MAXENTITIES];
static bool b_ActivatedDuringLastMann[MAXPLAYERS+1];
static int g_ProjectileModel;
static int g_ProjectileModelArmor;
int g_BeamIndex_heal = -1;
static int i_BurstpackUsedThisRound [MAXPLAYERS+1];
static int i_OrbitalCount [MAXPLAYERS+1];
static int i_EagleCount [MAXPLAYERS+1];
static int i_AttackCount [MAXENTITIES];
static float f_PDelay[MAXPLAYERS+1];
static float f_PDuration[MAXPLAYERS+1];
bool b_Iron_Will[MAXPLAYERS+1];
static bool b_OneWave[MAXPLAYERS+1];
static bool b_OneDown[MAXPLAYERS+1];
static int i_ReinforcePoint[MAXPLAYERS+1];
static int i_ReinforcePointMax[MAXPLAYERS+1];
static bool b_ReinforceReady[MAXPLAYERS+1];
static bool b_ReinforceReady_soundonly[MAXPLAYERS+1];
static int i_SupportWeapons[MAXPLAYERS+1];
static int i_SupportWeapon_Delete[MAXPLAYERS+1];
static int i_SupportWeapon_Lvl[MAXPLAYERS+1];
static float f_SupportWeapon_Timer[MAXPLAYERS+1];

static const char g_TeleSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};

static char gExplosive1;
static char gLaser1;
static char gRedPoint;
static char gBluePoint2;
static int LSPR=-1;
static const char SupportWeaponList[][] =
{
	"SupportWeapon SMG-43",
	"SupportWeapon APW-1 Sniperrifle",
	"SupportWeapon RS-422 Rail Gun",
};


//#define ARROW_TRAIL_GRENADE "effects/arrowtrail_blu.vmt"

//int trail = Trail_Attach(entity, ARROW_TRAIL_GRENADE, 255, 0.3, 3.0, 3.0, 5);


#define SOUND_HEAL_BEAM			"items/medshot4.wav"
#define SOUND_ARMOR_BEAM			"physics/metal/metal_box_strain1.wav"
#define SOUND_REPAIR_BEAM			"physics/metal/metal_box_strain2.wav"


public void M3_Abilities_Precache()
{
	gRedPoint = PrecacheModel("sprites/redglow1.vmt");
	gBluePoint2 = PrecacheModel("sprites/blueglow2.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	LSPR = PrecacheModel("sprites/lgtning.vmt");
	PrecacheModel("models/props_trainyard/cart_bomb_separate.mdl", true);
//	PrecacheModel(ARROW_TRAIL_GRENADE);
//	PrecacheDecal(ARROW_TRAIL_GRENADE, true);
	static char model[PLATFORM_MAX_PATH];
	model = "models/healthvial.mdl";
	g_ProjectileModel = PrecacheModel(model);
	model = "models/Items/battery.mdl";
	g_ProjectileModelArmor = PrecacheModel(model);
	g_BeamIndex_heal = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	HookEntityOutput("func_movelinear", "OnFullyOpen", OnBombDrop);
	PrecacheSound(SOUND_HEAL_BEAM);
	PrecacheSound(SOUND_ARMOR_BEAM);
	PrecacheSound(SOUND_REPAIR_BEAM);
	PrecacheSound(SOUND_DASH);
	PrecacheSound("weapons/gas_can_explode.wav");
	PrecacheSound("mvm/mvm_tank_start.wav");
	PrecacheSound("baka/nuke_doom.mp3");
	PrecacheSound("weapons/air_burster_explode3.wav");
	PrecacheSound("ambient/explosions/explode_9.wav");
	for (int i = 0; i < (sizeof(g_TeleSounds));	   i++) { PrecacheSound(g_TeleSounds[i]);	   }
	if(FileExists("sound/baka/sd_reinforce01.mp3", true))
		PrecacheSound("baka/sd_reinforce01.mp3", true);
	if(FileExists("sound/baka/sd_reinforce02.mp3", true))
		PrecacheSound("baka/sd_reinforce02.mp3", true);
	if(FileExists("sound/baka_zr/sa_hellpod_ready.mp3", true))
		PrecacheSound("baka_zr/sa_hellpod_ready.mp3", true);
	if(FileExists("sound/baka_zr/sd_de_01.mp3", true))
		PrecacheSound("baka_zr/sd_de_01.mp3", true);
	if(FileExists("sound/baka_zr/sd_de_02.mp3", true))
		PrecacheSound("baka_zr/sd_de_02.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_01.mp3", true))
		PrecacheSound("baka_zr/sd_spw_01.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_02.mp3", true))
		PrecacheSound("baka_zr/sd_spw_02.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_03.mp3", true))
		PrecacheSound("baka_zr/sd_spw_03.mp3", true);
}

public Action CommandDeployingSupportWeapon(int client, int args)
{
	if(!IsValidClient(client) || IsFakeClient(client))
	{
		PrintToConsole(client, "Command is in-game only");
		return Plugin_Handled;
	}
	DeployingSupportWeapon(client, true);
	
	return Plugin_Handled;
}

public Action OnBombDrop(const char [] output, int caller, int activator, float delay)
{
	char name[64];
	GetEntPropString(caller, Prop_Data, "m_iName", name, sizeof(name));
	if(StrContains(name, "ZR_Bomb_Drop_", false) != -1)
	{
		int client = GetEntProp(caller, Prop_Data, "m_iHammerID")-1972;
		float position[3];
		GetEntPropVector(caller, Prop_Data, "m_vecAbsOrigin", position);
		AcceptEntityInput(caller, "KillHierarchy");
		position[2]+=35.0;
		if(IsValidClient(client))
		{
			float position2[3], distance;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position2);
					distance = GetVectorDistance(position, position2);
					if(distance<850.0)
					{
						float MaxHealth = float(ReturnEntityMaxHealth(entity));
						float damage=(MaxHealth*0.05)+(Pow(float(CashSpentTotal[client]), 1.18)/10.0);
						SDKHooks_TakeDamage(entity, client, client, damage, DMG_BLAST|DMG_PREVENT_PHYSICS_FORCE);
					}
				}
			}
		}
		ParticleEffectAt(position, "hightower_explosion", 1.0);
		for(int all=1; all<=MaxClients; all++)
		{
			if(IsValidClient(all) && !IsFakeClient(all))
				ClientCommand(all, "playgamesound \"baka/nuke_doom.mp3\"");
		}
	}
	else if(StrContains(name, "ZR_ReinforcePOD_", false) != -1)
	{
		int HELLDIVER = GetEntProp(caller, Prop_Data, "m_iHammerID")-1972;
		float position[3];
		GetEntPropVector(caller, Prop_Data, "m_vecAbsOrigin", position);
		AcceptEntityInput(caller, "KillHierarchy");
		position[2]-=10.0;
		if(IsValidClient(HELLDIVER))
		{
			if(b_ReinforceReady[HELLDIVER])
			{
				int RandomHELLDIVER = GetRandomDeathPlayer(HELLDIVER);
				if(IsValidClient(RandomHELLDIVER) && GetTeam(RandomHELLDIVER) == TFTeam_Red && TeutonType[RandomHELLDIVER] == TEUTON_DEAD)
				{
					TeutonType[RandomHELLDIVER] = TEUTON_NONE;
					dieingstate[RandomHELLDIVER] = 0;
					//i_AmountDowned[RandomHELLDIVER]--;
					DHook_RespawnPlayer(RandomHELLDIVER);
					ForcePlayerCrouch(RandomHELLDIVER, false);
					DataPack pack;
					CreateDataTimer(0.5, Timer_DelayTele, pack, TIMER_FLAG_NO_MAPCHANGE);
					if(LastMann)Music_EndLastmann();
					pack.WriteCell(GetClientUserId(RandomHELLDIVER));
					pack.WriteFloat(position[0]);
					pack.WriteFloat(position[1]);
					pack.WriteFloat(position[2]);
					TF2_AddCondition(RandomHELLDIVER, TFCond_UberchargedCanteen, 3.5);
					TF2_AddCondition(RandomHELLDIVER, TFCond_SpeedBuffAlly, 2.0);
				}
			
				float entitypos[3], distance;
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
					if(IsValidEntity(entity) && GetTeam(entity) != TFTeam_Red)
					{
						GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
						distance = GetVectorDistance(position, entitypos);
						if(distance<125.0)
						{
							float MaxHealth = float(ReturnEntityMaxHealth(entity));
							float damage=(MaxHealth*2.0);
							if(b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] || b_IsGiant[entity])
								damage=(MaxHealth*0.05)+(Pow(float(CashSpentTotal[HELLDIVER]), 1.18)/10.0);
							SDKHooks_TakeDamage(entity, HELLDIVER, HELLDIVER, damage, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);
						}
					}
				}
				for(int target=1; target<=MaxClients; target++)
				{
					if(IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
					{
						GetEntPropVector(target, Prop_Send, "m_vecOrigin", entitypos);
						distance = GetVectorDistance(position, entitypos);
						if(distance<=125.0)
						{
							int health = GetClientHealth(target);
							SDKHooks_TakeDamage(target, 0, 0, float(health)*3.0, DMG_SLASH|DMG_CRIT);
						}
					}
				}
				RequestFrame(Timer_Deploy);
				b_ReinforceReady[HELLDIVER]=false;
			}
		}
	}
	else if(StrContains(name, "ZR_SupportWeapon_", false) != -1)
	{
		float position[3];
		GetEntPropVector(caller, Prop_Data, "m_vecAbsOrigin", position);
		AcceptEntityInput(caller, "KillHierarchy");
		position[2]-=10.0;
		int client = GetEntProp(caller, Prop_Data, "m_iHammerID")-1972;
		if(IsValidClient(client))
		{
			float entitypos[3], distance;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity))
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(position, entitypos);
					if(distance<125.0)
					{
						float MaxHealth = float(ReturnEntityMaxHealth(entity));
						float damage=(MaxHealth*2.0);
						if(b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] || b_IsGiant[entity])
							damage=(MaxHealth*0.05)+(Pow(float(CashSpentTotal[client]), 1.18)/10.0);
						if(GetTeam(client) != GetTeam(entity))
							SDKHooks_TakeDamage(entity, client, client, damage, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);
						else
							SDKHooks_TakeDamage(entity, 0, 0, damage, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);
					}
				}
			}
			for(int target=1; target<=MaxClients; target++)
			{
				if(IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
				{
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(position, entitypos);
					if(distance<=125.0)
					{
						int health = GetClientHealth(target);
						SDKHooks_TakeDamage(target, 0, 0, float(health)*3.0, DMG_SLASH|DMG_CRIT);
					}
				}
			}
			int Prop = CreateEntityByName("prop_dynamic");
			if(IsValidEntity(Prop))
			{
				//position[2]+=30.0;
				DispatchKeyValue(Prop, "model", "models/props_urban/urban_crate002.mdl");
				DispatchKeyValue(Prop, "angles", "0 0 0");
				DispatchKeyValue(Prop, "solid", "0");
				TeleportEntity(Prop, position, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(Prop);
				CClotBody npc = view_as<CClotBody>(Prop);
				npc.m_bThisEntityIgnored = true;
				
				f_HealDelay[Prop] = GetGameTime() + 300.0;
				
				SetEntProp(Prop, Prop_Data, "m_nNextThinkTick", -1);
				DataPack pack;
				CreateDataTimer(0.1, Timer_SupportWeapon_Get, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				pack.WriteCell(EntIndexToEntRef(Prop));
				pack.WriteCell(GetClientUserId(client));
			}
		}
	}
	return Plugin_Continue;
}

void Timer_Deploy()
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client))
			ClientCommand(client, "playgamesound \"mvm/mvm_tele_deliver.wav\"");
	}
}

public Action Timer_DelayTele(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidClient(client))
	{
		float position[3];
		position[0] = pack.ReadFloat();
		position[1] = pack.ReadFloat();
		position[2] = pack.ReadFloat();
		SetEntityHealth(client, SDKCall_GetMaxHealth(client));
		GiveArmorViaPercentage(client, 0.5, 1.0);
		TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
		MakePlayerGiveResponseVoice(client, 3);
	}
	return Plugin_Stop;
}

public void M3_ClearAll()
{
	Zero(b_ActivatedDuringLastMann);
	Zero(ability_cooldown);
	Zero(ability_cooldown_2);
	Zero(Attack3AbilitySlotArray);
	Zero(f_HealDelay);
	Zero(f_Duration);
	Zero(i_AttackCount);
	Zero(f_PDelay);
	Zero(f_PDuration);
	Zero(b_Iron_Will);
	Zero(b_OneWave);
	Zero(b_OneDown);
	Zero(i_ReinforcePoint);
	Zero(i_ReinforcePointMax);
	Zero(b_ReinforceReady);
	Zero(b_ReinforceReady_soundonly);
	Zero(i_SupportWeapons);
	Zero(i_SupportWeapon_Delete);
	Zero(i_SupportWeapon_Lvl);
	Zero(f_SupportWeapon_Timer);
}

public void M3_Abilities(int client)
{
	switch(Attack3AbilitySlotArray[client])
	{
		case 1:
		{
			PlaceableTempomaryHealingGrenade(client);
		}
		case 2:
		{
			WeakDash(client);
		}
		case 3:
		{
			PlaceableTempomaryArmorGrenade(client);
		}
		case 4:
		{
			GearTesting(client);
		}
		case 5:
		{
			Orbital120MMHEBarrage(client);
		}
		case 6:
		{
			PlaceableTempomaryRepairGrenade(client);
		}
		case 7:
		{
			DrinkRND(client);
		}
		case 8:
		{
			EagleBomb(client);
		}
		case 9:
		{
			StimPacks(client);
		}
		case 10:
		{
			Seeyou_in_HELL(client);
		}
		case 11:
		{
			Iron_Will(client);
		}
		case 12:
		{
			Reinforce(client);
		}
		case 13:
		{
			OrbitalGASStrike(client);
		}
		case 14:
		{
			DeployingSupportWeapon(client, false);
		}
	}
}

void M3_AbilitiesWaveEnd()
{
	Zero(i_BurstpackUsedThisRound);
	Zero(i_OrbitalCount);
	Zero(i_EagleCount);
	Zero(b_OneWave);
	Zero(b_ReinforceReady);
}

void HealPointToReinforce(int client, int healthvalue, float autoscale = 0.0)
{
	if(!b_Reinforce[client])
		return;
	float Healing_Amount=Attributes_GetOnPlayer(client, 8, true, true)/2.0;
	if(Healing_Amount<1.0)Healing_Amount=1.0;
	i_ReinforcePointMax[client] = RoundToCeil(1500.0 * Healing_Amount);
	if(autoscale != 0.0) healthvalue = RoundToCeil(float(i_ReinforcePointMax[client]) * autoscale);
	if(b_ReinforceReady[client]) healthvalue=0;

	i_ReinforcePoint[client] += healthvalue;
	if(i_ReinforcePoint[client] >= i_ReinforcePointMax[client])
	{
		if(!b_ReinforceReady[client])
			b_ReinforceReady[client]=true;
		if(!b_ReinforceReady_soundonly[client])
		{
			b_ReinforceReady_soundonly[client]=true;
			ClientCommand(client, "playgamesound \"baka_zr/sa_hellpod_ready.mp3\"");
		}
		i_ReinforcePoint[client] = i_ReinforcePointMax[client];
	}
	else
		b_ReinforceReady_soundonly[client]=false;
}

int ReinforcePoint(int client)
{
	if(!b_Reinforce[client])
		return 0;
	if(i_ReinforcePoint[client]<=0 || i_ReinforcePointMax[client]<=0)
		return 0;
	return RoundToFloor((float(i_ReinforcePoint[client])/float(i_ReinforcePointMax[client]))*100.0);
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
								SDKHooks_TakeDamage(npc, client, client, damage, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);
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

public void Reinforce(int client)
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
		if(i_ReinforcePoint[client] < i_ReinforcePointMax[client] || i_ReinforcePointMax[client]==0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Need Healing Point", (i_ReinforcePointMax[client] - i_ReinforcePoint[client]));
			return;
		}
		bool DeadPlayer;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(!IsValidClient(client_check))continue;
			if(TeutonType[client_check] == TEUTON_NONE)continue;
			if(client==client_check || GetTeam(client_check) != TFTeam_Red)continue;
			DeadPlayer=true;
		}
		if(!DeadPlayer)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Player not detected");
			return;
		}
		i_ReinforcePoint[client]=0;
		for(int all=1; all<=MaxClients; all++)
		{
			if(IsValidClient(all) && !IsFakeClient(all))
			{
				if(GetRandomInt(1, 10)<=5)
					EmitSoundToClient(all, "baka/sd_reinforce01.mp3", _, _, _, _, 0.8, _, _, _, _, false);
				else
					EmitSoundToClient(all, "baka/sd_reinforce02.mp3", _, _, _, _, 0.8, _, _, _, _, false);
			}
		}
		float position[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
		Handle Reinforcement = CreateDataPack();
		WritePackFloat(Reinforcement, position[0]);
		WritePackFloat(Reinforcement, position[1]);
		WritePackFloat(Reinforcement, position[2]);
		WritePackFloat(Reinforcement, 145.0);
		WritePackCell(Reinforcement, false);
		WritePackFloat(Reinforcement, 1200.0);
		WritePackString(Reinforcement, "ZR_ReinforcePOD_");
		WritePackString(Reinforcement, "models/props_urban/urban_crate002.mdl");
		WritePackString(Reinforcement, "weapons/air_burster_explode3.wav");
		WritePackCell(Reinforcement, client);
		ResetPack(Reinforcement);
		Deploy_Drop(Reinforcement);
	}
}

public void Deploy_Drop(Handle data)
{
	float position[3];
	static char PropName[512];
	static char Worldmodel_Patch[PLATFORM_MAX_PATH];
	static char Sound_Patch[PLATFORM_MAX_PATH];
	position[0] = ReadPackFloat(data);
	position[1] = ReadPackFloat(data);
	position[2] = ReadPackFloat(data);
	float Delay = ReadPackFloat(data);
	bool NoDrawBeam =ReadPackCell(data);
	float Prop_Speed = ReadPackFloat(data);
	ReadPackString(data, PropName, sizeof(PropName));
	ReadPackString(data, Worldmodel_Patch, sizeof(Worldmodel_Patch));
	ReadPackString(data, Sound_Patch, sizeof(Sound_Patch));
	int client = ReadPackCell(data);
	if(!IsValidClient(client))return;
	if(!b_ReinforceReady[client])return;
	
	if(Delay > 0 && !NoDrawBeam)
	{
		float Laserpos[3];
		EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);
		Laserpos[0] = position[0];
		Laserpos[1] = position[1];
		Laserpos[2] = position[2] + 1500.0;
		
		TE_SetupBeamPoints(Laserpos, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, {0, 150, 255, 255}, 3);
		TE_SendToAll();
		Laserpos[2] -= 1490.0;
		TE_SetupGlowSprite(Laserpos, gBluePoint2, 1.0, 1.0, 255);
		TE_SendToAll();
	}
	Delay -= 5;
	
	Handle DDPack = CreateDataPack();
	WritePackFloat(DDPack, position[0]);
	WritePackFloat(DDPack, position[1]);
	WritePackFloat(DDPack, position[2]);
	WritePackFloat(DDPack, Delay);
	WritePackCell(DDPack, NoDrawBeam);
	WritePackFloat(DDPack, Prop_Speed);
	WritePackString(DDPack, PropName);
	WritePackString(DDPack, Worldmodel_Patch);
	WritePackString(DDPack, Sound_Patch);
	WritePackCell(DDPack, client);
	ResetPack(DDPack);
	if(Delay > -50)
		CreateTimer(0.1, Recycle_DropProp, DDPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
	else
	{
		if(!StrEqual(Sound_Patch, "No_Sound", true))EmitSoundToAll(Sound_Patch, 0, SNDCHAN_AUTO, SNDLEVEL_TRAIN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);
		Drop_Prop(client, position, Prop_Speed, PropName, Worldmodel_Patch);
	}
}

public Action Recycle_DropProp(Handle timer, any data)
{
	Deploy_Drop(data);
	return Plugin_Stop;
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

public void EagleBomb(int client)
{
	if (ability_cooldown[client] < GetGameTime())
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

stock int Drop_Prop(int client, float fPos[3], float PropSpeed=1200.0, const char [] PropNeam_patch="No_Name", const char [] worldmodel_patch="No_Worldmodel")
{
	int PropMove = CreateEntityByName("func_movelinear");
	if(StrEqual(PropNeam_patch, "No_Name", true))
	{
		LogError("[Prop] Drop_Prop No_Name!!!");
		return -1;
	}
	if(StrEqual(worldmodel_patch, "No_Worldmodel", true))
	{
		LogError("[Prop] Drop_Prop No_Worldmodel!!!");
		return -1;
	}
	if(IsValidEntity(PropMove))
	{
		char buffer[32];
		fPos[2]+=5010.0;
		float Down[3]={90.0,0.0,0.0};
		DispatchKeyValueVector(PropMove, "origin", fPos);
		DispatchKeyValueVector(PropMove, "movedir", Down);
		DispatchKeyValue(PropMove, "movedir", "90 0 0");
		DispatchKeyValue(PropMove, "modelscale", "3");
		Format(buffer, sizeof(buffer), "%.2f", 5000.0);
		DispatchKeyValue(PropMove, "movedistance", buffer);
		Format(buffer, sizeof(buffer), "%.2f", PropSpeed);
		DispatchKeyValue(PropMove, "speed", buffer);
		FormatEx(buffer, sizeof(buffer), "%s_Drop_%d", PropNeam_patch, client);
		DispatchKeyValue(PropMove, "targetname", buffer);
		DispatchKeyValue(PropMove, "startsound", "none");
		DispatchKeyValue(PropMove, "stopsound", "none");
		TeleportEntity(PropMove, fPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(PropMove);
		
		int Prop = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(Prop))
		{
			DispatchKeyValue(Prop, "model", worldmodel_patch);
			DispatchKeyValue(Prop, "angles", "-90 0 0");
			DispatchKeyValue(Prop, "parentname", buffer);
			DispatchKeyValue(Prop, "solid", "0");
			FormatEx(buffer, sizeof(buffer), "%s_%d", PropNeam_patch, client);
			DispatchKeyValue(Prop, "targetname", buffer);
			TeleportEntity(Prop, fPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(Prop);
			
			FormatEx(buffer, sizeof(buffer), "%s_Drop_%d", PropNeam_patch, client);
			SetVariantString(buffer);
			AcceptEntityInput(Prop, "SetParent");
		}
		AcceptEntityInput(PropMove, "Open");
		SetEntProp(PropMove, Prop_Data, "m_iHammerID", client+1972);
		return PropMove;
	}
	return -1;
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
			GetRND=GetRandomInt(1, 12);
		else
			GetRND=GetRandomInt(1, 9);
		f_PDelay[client]=GetGameTime();
		float AddTime;
		switch(GetRND)
		{
			case 10,11:AddTime=20.0;
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
				Overclock_Magical(client, 1.0, true);
				f_Overclocker_Buff[client] = GetGameTime() + 0.2;
			}
			case 11:
			{
				float damage = 5+(Pow(float(CashSpentTotal[client]), 1.225))/10000.0;
				if(damage<5.0)damage=5.0;
				float position[3]; WorldSpaceCenter(client, position);
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int npc = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
					if(IsValidEntity(npc) && GetTeam(npc) != TFTeam_Red)
					{
						float position2[3], distance;
						GetEntPropVector(npc, Prop_Send, "m_vecOrigin", position2);
						distance = GetVectorDistance(position, position2);
						if(distance<200.0)
						{
							SDKHooks_TakeDamage(npc, client, client, damage, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);
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

public void WeakDash(int client)
{
	if(dieingstate[client] > 0)
	{
		if (ability_cooldown_2[client] < GetGameTime())
		{
			ability_cooldown_2[client] = GetGameTime() + 120.0;
			WeakDashLogic(client);
		}
		else
		{
			float Ability_CD = ability_cooldown_2[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}		
	}
	else
	{
		if (ability_cooldown[client] < GetGameTime())
		{
			if(i_BurstpackUsedThisRound[client] >= 2)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Burstpack Already Used This Round, Recharging");	
				return;
			}
			i_BurstpackUsedThisRound[client] += 1;
			ability_cooldown[client] = GetGameTime() + 60.0;
			CreateTimer(60.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
			WeakDashLogic(client);
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
}

public void WeakDashLogic(int client)
{
	EmitSoundToAll(SOUND_DASH, client, _, 70, _, 1.0);
			
	static float EntLoc[3];
			
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
			
	SpawnSmallExplosion(EntLoc);
			
	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 750.0;
			
	ScaleVector(velocity, knockback);
	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
		velocity[2] = fmax(velocity[2], 300.0);
	else
		velocity[2] += 150.0; // a little boost to alleviate arcing issues
			
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);

	Magnesis_OnBurstPack(client);
}

public void PlaceableTempomaryArmorGrenade(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		ability_cooldown[client] = GetGameTime() + 100.0;
		CreateTimer(100.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		int entity;

		if(b_StickyExtraGrenades[client])
			entity = CreateEntityByName("tf_projectile_pipe_remote");
		else
			entity = CreateEntityByName("tf_projectile_pipe");

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
			if(b_StickyExtraGrenades[client])
				SetEntProp(entity, Prop_Send, "m_iType", 1);
				
			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelArmor, _, i);
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
			
			f_HealDelay[entity] = GetGameTime() + 1.0;
			f_Duration[entity] = GetGameTime() + (Items_HasNamedItem(client, "Whiteflower's Elite Grenade") ? 12.0 : 10.0);
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			 
			DataPack pack;
			CreateDataTimer(0.1, Timer_Detect_Player_Near_Armor_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
	//		pack.WriteCell(Healing_Amount);	
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


public Action Timer_Detect_Player_Near_Armor_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
//	float Healing_Amount = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.0;
				int color[4];
				
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 500.0 * 2.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
	   			TE_SendToAll();
	   			for (int target = 1; target <= MaxClients; target++)
				{
					if (IsValidClient(target) && IsPlayerAlive(target) && GetClientTeam(target) == view_as<int>(TFTeam_Red) && TeutonType[target] == 0)
					{
						GetClientAbsOrigin(target, client_pos);
						if (GetVectorDistance(powerup_pos, client_pos, true) <= (500.0 * 500.0))
						{
							EmitSoundToClient(target, SOUND_ARMOR_BEAM, target, _, 90, _, 1.0);
							EmitSoundToClient(target, SOUND_ARMOR_BEAM, target, _, 90, _, 1.0);
							EmitSoundToClient(target, SOUND_ARMOR_BEAM, target, _, 90, _, 1.0);
							//This gives 35% armor
							if(f_TimeUntillNormalHeal[target] > GetGameTime())
							{
								GiveArmorViaPercentage(target, 0.075 * 0.5, 1.0);
							}
							else
							{
								GiveArmorViaPercentage(target, 0.075, 1.0);
							}
						}
					}
				}
   			}
   			if(f_Duration[entity] < GetGameTime())
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



public void PlaceableTempomaryHealingGrenade(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		ability_cooldown[client] = GetGameTime() + 140.0;
		
		CreateTimer(140.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		int entity;		
		if(b_StickyExtraGrenades[client])
			entity = CreateEntityByName("tf_projectile_pipe_remote");
		else
			entity = CreateEntityByName("tf_projectile_pipe");

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
			if(b_StickyExtraGrenades[client])
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
			
			float Healing_Amount = 10.0;
			Healing_Amount *= Attributes_GetOnPlayer(client, 8, true, true);
			
			f_HealDelay[entity] = GetGameTime() + 1.0;
			f_Duration[entity] = GetGameTime() + (Items_HasNamedItem(client, "Whiteflower's Elite Grenade") ? 12.0 : 10.0);
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			 
			DataPack pack;
			CreateDataTimer(0.1, Timer_Detect_Player_Near_Healing_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteFloat(Healing_Amount);	
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


public Action Timer_Detect_Player_Near_Healing_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float Healing_Amount = pack.ReadFloat();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.0;
				int color[4];
				
				color[0] = 0;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 500.0 * 2.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
	   			TE_SendToAll();
	   			for (int target = 1; target <= MaxClients; target++)
				{
					if (IsValidClient(target) && IsPlayerAlive(target) && GetClientTeam(target) == view_as<int>(TFTeam_Red) && TeutonType[target] == 0)
					{
						GetClientAbsOrigin(target, client_pos);
						if (GetVectorDistance(powerup_pos, client_pos, true) <= (500.0 * 500.0))
						{
							if(dieingstate[target] > 0)
							{
								EmitSoundToClient(target, SOUND_HEAL_BEAM, target, _, 90, _, 1.0);
								if(i_CurrentEquippedPerk[client] == 1)
								{
									SetEntityHealth(target,  GetClientHealth(target) + 12);
									dieingstate[target] -= 20;
								}
								else
								{
									SetEntityHealth(target,  GetClientHealth(target) + 6);
									dieingstate[target] -= 10;
								}
								if(dieingstate[target] < 1)
								{
									dieingstate[target] = 1;
								}
							}
							else
							{
								if(f_TimeUntillNormalHeal[target] > GetGameTime())
								{
									Healing_Amount *= 0.5;
								}
								if(Healing_Amount < 10.0)
								{
									Healing_Amount = 10.0;
								}
								EmitSoundToClient(target, SOUND_HEAL_BEAM, target, _, 90, _, 1.0);
								HealEntityGlobal(client, target, Healing_Amount, _, 1.0);	
							}
						}
					}
				}
				for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
				{
					int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
					if (IsValidEntity(baseboss_index_allied) && GetTeam(baseboss_index_allied) == TFTeam_Red)
					{
						if(!b_ThisEntityIgnored[baseboss_index_allied])
						{
							GetEntPropVector(baseboss_index_allied, Prop_Data, "m_vecAbsOrigin", client_pos);
							if (GetVectorDistance(powerup_pos, client_pos, true) <= 90000)
							{
								if(f_TimeUntillNormalHeal[baseboss_index_allied] < GetGameTime())
								{
									Healing_Amount *= 0.25;
								}
								if(Healing_Amount < 10.0)
								{
									Healing_Amount = 10.0;
								}
								HealEntityGlobal(client, baseboss_index_allied, Healing_Amount, _, 1.0);
							}
						}
					}
				}
   			}
   			if(f_Duration[entity] < GetGameTime())
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


public Action M3_Ability_Is_Back(Handle cut_timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	
	if (IsValidClient(client))
	{
		ClientCommand(client, "playgamesound items/gunpickup2.wav");
		SetHudTextParams(-1.0, 0.45, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "M3 Ability Is Back");
	}
	return Plugin_Handled;
}

public void BuilderMenu(int client)
{
	if(dieingstate[client] == 0)
	{	
		CancelClientMenu(client);
		SetStoreMenuLogic(client, false);
		static char buffer[128];
		Menu menu = new Menu(BuilderMenuM);

		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t", "Extra Menu");
		
		FormatEx(buffer, sizeof(buffer), "%t", "Deleting buildings refunds text");
		menu.AddItem("-999", buffer, ITEMDRAW_DISABLED);

		FormatEx(buffer, sizeof(buffer), "%t", "Mark Building For Deletion");
		menu.AddItem("-1", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Un-Claim Building");
		menu.AddItem("-2", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Destroy all your non-Mounted Buildings");
		menu.AddItem("-3", buffer);
									
		FormatEx(buffer, sizeof(buffer), "%t", "Bring up Class Change Menu");
		menu.AddItem("-4", buffer);
									
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

/*
	SetStoreMenuLogic(client, false);
	sResetStoreMenuLogic(client);
*/
public int BuilderMenuM(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						DeleteBuildingLookedAt(client);
					}
				}
				case -2:
				{
					if(IsValidClient(client))
					{
						Un_ClaimBuildingLookedAt(client);
					}
				}
				case -3:
				{
					if(IsValidClient(client))
					{
						DestroyAllBuildings_ClientSelf(client);
					}
				}
				case -4:
				{
					if(IsValidClient(client))
					{
						ShowVGUIPanel(client, GetTeam(client) == TFTeam_Red ? "class_red" : "class_blue");
					}
				}
				default:
				{
					delete menu;
				}
			}
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
	}
	return 0;
}


int i_BuildingSelectedToBeDeleted[MAXPLAYERS + 1];
int i_BuildingSelectedToBeUnClaimed[MAXPLAYERS + 1];


public void Un_ClaimBuildingLookedAt(int client)
{
	int entity = GetClientPointVisible(client, _ , true, true);
	if(entity > MaxClients)
	{
		if (IsValidEntity(entity))
		{
			if(!BuildingIsSupport(entity))
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "This building cannot be unclaimed, only destroyed.");
				return;
			}
			static char buffer[64];
			if(GetEntityClassname(entity, buffer, sizeof(buffer)))
			{
				if(!StrContains(buffer, "obj_"))
				{
					if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
					{
						i_BuildingSelectedToBeUnClaimed[client] = EntIndexToEntRef(entity);
						DataPack pack;
						CreateDataTimer(0.1, UnclaimBuildingTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						pack.WriteCell(client);
						pack.WriteCell(EntIndexToEntRef(entity));
						pack.WriteCell(GetClientUserId(client));
						Menu menu = new Menu(UnClaimBuildingMenu);
						CancelClientMenu(client);
						SetStoreMenuLogic(client, false);

						SetGlobalTransTarget(client);
						
						menu.SetTitle("%t", "UnClaim Current Marked Building");

						FormatEx(buffer, sizeof(buffer), "%t", "Yes");
						menu.AddItem("-1", buffer);
						FormatEx(buffer, sizeof(buffer), "%t", "No");
						menu.AddItem("-2", buffer);
									
						menu.ExitButton = true;
						menu.Display(client, MENU_TIME_FOREVER);
						
						i_BuildingSelectedToBeUnClaimed[client] = EntIndexToEntRef(entity);
					}
				}
			}
		}
	}
}

public Action UnclaimBuildingTimer(Handle sentryHud, DataPack pack)
{
	pack.Reset();
	int original_index = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());

	if(IsValidClient(client))
	{
		if (IsValidEntity(entity) && entity == EntRefToEntIndex(i_BuildingSelectedToBeUnClaimed[client]))
		{
			static float m_vecMaxs[3];
			static float m_vecMins[3];
			GetEntPropVector(entity, Prop_Send, "m_vecMins", m_vecMins);
			GetEntPropVector(entity, Prop_Send, "m_vecMaxs", m_vecMaxs);
			float fPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fPos);
			TE_DrawBox(client, fPos, m_vecMins, m_vecMaxs, 0.2, view_as<int>({255, 0, 0, 255}));
			return Plugin_Continue;
		}
		else
		{
			i_BuildingSelectedToBeUnClaimed[original_index] = -1;
			return Plugin_Stop;
		}
	}
	else
	{
		i_BuildingSelectedToBeUnClaimed[original_index] = -1;
		return Plugin_Stop;
	}
}

public Action DeleteBuildingTimer(Handle sentryHud, DataPack pack)
{
	pack.Reset();
	int original_index = pack.ReadCell();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());

	if(IsValidClient(client))
	{
		if (IsValidEntity(entity) && entity == EntRefToEntIndex(i_BuildingSelectedToBeDeleted[client]))
		{
			static float m_vecMaxs[3];
			static float m_vecMins[3];
			GetEntPropVector(entity, Prop_Send, "m_vecMins", m_vecMins);
			GetEntPropVector(entity, Prop_Send, "m_vecMaxs", m_vecMaxs);
			float fPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fPos);
			TE_DrawBox(client, fPos, m_vecMins, m_vecMaxs, 0.2, view_as<int>({255, 0, 0, 255}));
			return Plugin_Continue;
		}
		else
		{
			i_BuildingSelectedToBeDeleted[original_index] = -1;
			return Plugin_Stop;
		}
	}
	else
	{
		i_BuildingSelectedToBeDeleted[original_index] = -1;
		return Plugin_Stop;
	}
}

public void DeleteBuildingLookedAt(int client)
{
	int entity = GetClientPointVisible(client, _ , true, true);
	if(entity > MaxClients)
	{
		if (IsValidEntity(entity))
		{
			static char buffer[64];
			if(GetEntityClassname(entity, buffer, sizeof(buffer)))
			{
				if(!StrContains(buffer, "obj_"))
				{
					if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client || GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") > MaxClients)
					{
						i_BuildingSelectedToBeDeleted[client] = EntIndexToEntRef(entity);
						DataPack pack;
						CreateDataTimer(0.1, DeleteBuildingTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						pack.WriteCell(client);
						pack.WriteCell(EntIndexToEntRef(entity));
						pack.WriteCell(GetClientUserId(client));
						Menu menu = new Menu(DeleteBuildingMenu);
						CancelClientMenu(client);
						SetStoreMenuLogic(client, false);

						SetGlobalTransTarget(client);
						
						menu.SetTitle("%t", "Delete Current Marked Building");

						FormatEx(buffer, sizeof(buffer), "%t", "Yes");
						menu.AddItem("-1", buffer);
						FormatEx(buffer, sizeof(buffer), "%t", "No");
						menu.AddItem("-2", buffer);
									
						menu.ExitButton = true;
						menu.Display(client, MENU_TIME_FOREVER);
						
						i_BuildingSelectedToBeDeleted[client] = EntIndexToEntRef(entity);
					}
				}
			}
		}
	}
}



public void DestroyAllBuildings_ClientSelf(int client)
{
	Menu menu = new Menu(DestroyAllSelfBuildings_Menu);
	CancelClientMenu(client);
	SetStoreMenuLogic(client, false);
	SetGlobalTransTarget(client);

	static char buffer[64];
	menu.SetTitle("%t", "Destroy all your non-Mounted Buildings Sure");

	FormatEx(buffer, sizeof(buffer), "%t", "Yes");
	menu.AddItem("-1", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "No");
	menu.AddItem("-2", buffer);
				
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}
public int DestroyAllSelfBuildings_Menu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(client))
			{
				ResetStoreMenuLogic(client);		
			}
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						int mountedentity = EntRefToEntIndex(Building_Mounted[client]);
						for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++)
						{
							int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
							if(IsValidEntity(entity) && entity != 0)
							{
								if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client && mountedentity != entity)
								{
									if(!Can_I_See_Enemy_Only(client, entity))
									{
										DeleteAndRefundBuilding(client, entity);
									}
								}
							}
						}
					}
				}
				default:
				{
					if(IsValidClient(client))
					{
						ResetStoreMenuLogic(client);
					}
				}
			}
		}
	}
	return 0;
}

public void GearTesting(int client)
{
	if(dieingstate[client] > 0)
	{
		if (ability_cooldown_2[client] < GetGameTime())
		{
	//		PrintToChatAll("User is dead");
		}
		else
		{
			float Ability_CD = ability_cooldown_2[client] - GetGameTime();
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}		
	}
	else
	{
		if (ability_cooldown[client] < GetGameTime())
		{
			ability_cooldown[client] = GetGameTime() + 350.0;


			CreateTimer(350.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);

			SetEntityMoveType(client, MOVETYPE_NONE);

			i_ClientHasCustomGearEquipped[client] = true;
			b_ActivatedDuringLastMann[client] = false;
			if(LastMann)
			{
				b_ActivatedDuringLastMann[client] = true;
			}
			if(Items_HasNamedItem(client, "Chaos Machina Waldch Chip"))
				IncreaceEntityDamageTakenBy(client, 0.5, 3.0);
			
			CreateTimer(3.0, QuantumActivate, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		//	ClientCommand(client, "playgamesound mvm/mvm_tank_start.wav");

			EmitSoundToAll("mvm/mvm_tank_start.wav", client, SNDCHAN_STATIC, 70, _, 0.9);

			float startPosition[3];
			float position[3];
			GetClientAbsOrigin(client, startPosition);

			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 500.0;
			startPosition[2] += -500;
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 3.0, 30.0, 30.0, 0, 0.9, {255, 255, 255, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.8, 50.0, 50.0, 0, 0.9, {200, 255, 200, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.5, 80.0, 80.0, 0, 0.9, {180, 255, 180, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.4, 100.0, 100.0, 0, 0.8, {120, 255, 120, 255}, 3);
			TE_SendToAll();
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
}

public Action QuantumActivate(Handle cut_timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		if(TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0 && IsPlayerAlive(client))
		{
			float startPosition[3];
			GetClientAbsOrigin(client, startPosition);
			i_HealthBeforeSuit[client] = GetClientHealth(client);

			i_ClientHasCustomGearEquipped[client] = true;
			
			Store_GiveAll(client, 50, true);
			ViewChange_PlayerModel(client);
			
			float HealthMulti = float(CashSpentTotal[client]);
			HealthMulti = Pow(HealthMulti, 1.2);
			HealthMulti *= 0.025;
			if(Items_HasNamedItem(client, "Chaos Machina Waldch Chip"))
				HealthMulti *= 1.1;
				
			SetEntityHealth(client, RoundToCeil(HealthMulti));

			SetEntityMoveType(client, MOVETYPE_WALK);

			Store_GiveSpecificItem(client, "Quantum Repeater");
			Store_GiveSpecificItem(client, "Quantum Nanosaber");
			
			SetAmmo(client, 1, 9999);
			SetAmmo(client, 2, 9999);

			//somehow the new tf2 update broke its infinite ammo, i have to set it like this
			//TODO: Find a different fix, 30/07/2023
			SetConVarInt(sv_cheats, 1, false, false);
			SDKCall(g_hImpulse, client, 101);
			if(nav_edit.IntValue != 1)
			{
				SetConVarInt(sv_cheats, 0, false, false);
			}
			ResetReplications();
		
			startPosition[2] += 25.0;
			makeexplosion(client, client, startPosition, "", 0, 0);

			CreateTimer(30.0, QuantumDeactivate, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			SetEntityMoveType(client, MOVETYPE_WALK);

			i_ClientHasCustomGearEquipped[client] = false;
		}
	}
	return Plugin_Handled;
}

public Action QuantumDeactivate(Handle cut_timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client) && i_HealthBeforeSuit[client] > 0)
	{
		i_ClientHasCustomGearEquipped[client] = false;
		int health = i_HealthBeforeSuit[client];

		i_HealthBeforeSuit[client] = 0;
		f_HealthBeforeSuittime[client] = GetGameTime() + 0.25;
	//	SetEntityMoveType(client, MOVETYPE_WALK);
		UnequipQuantumSet(client);
		//Remove both just in case.
		
		TF2_RegeneratePlayer(client);
	
		ViewChange_PlayerModel(client);
		Store_ApplyAttribs(client);
		Store_GiveAll(client, health);

		CurrentClass[client] = view_as<TFClassType>(GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"));
		ViewChange_DeleteHands(client);
		ViewChange_UpdateHands(client, CurrentClass[client]);
		if(b_ActivatedDuringLastMann[client])
		{
			int MaxHealth = SDKCall_GetMaxHealth(client) * 2;
			SetEntProp(client, Prop_Send, "m_iHealth", MaxHealth);
		}
		b_ActivatedDuringLastMann[client] = false;
		//if in lastman, then give extra health.
	}
	return Plugin_Handled;
}

void UnequipQuantumSet(int client)
{
	Store_RemoveSpecificItem(client, "Quantum Repeater");
	Store_RemoveSpecificItem(client, "Quantum Nanosaber");
}

public float GetAbilityCooldownM3(int client)
{
	return ability_cooldown[client] - GetGameTime();
}


public void SetAbilitySlotCount(int client, int value)
{
	Attack3AbilitySlotArray[client] = value;
}

public int GetAbilitySlotCount(int client)
{
	return Attack3AbilitySlotArray[client];
}



public void PlaceableTempomaryRepairGrenade(int client)
{
	if (ability_cooldown[client] < GetGameTime())
	{
		ability_cooldown[client] = GetGameTime() + 100.0;
		CreateTimer(100.0, M3_Ability_Is_Back, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		int entity;		
		if(b_StickyExtraGrenades[client])
			entity = CreateEntityByName("tf_projectile_pipe_remote");
		else
			entity = CreateEntityByName("tf_projectile_pipe");

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
			if(b_StickyExtraGrenades[client])
				SetEntProp(entity, Prop_Send, "m_iType", 1);

			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelArmor, _, i);
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
			
			f_HealDelay[entity] = GetGameTime() + 1.0;
			f_Duration[entity] = GetGameTime() + (Items_HasNamedItem(client, "Whiteflower's Elite Grenade") ? 12.0 : 10.0);
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			 
			DataPack pack;
			CreateDataTimer(0.1, Timer_Detect_Player_Near_Repair_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
	//		pack.WriteCell(Healing_Amount);	
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


public Action Timer_Detect_Player_Near_Repair_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
//	float Healing_Amount = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_HealDelay[entity] < GetGameTime())
			{
				f_HealDelay[entity] = GetGameTime() + 1.0;
				int color[4];
				
				color[0] = 255;
				color[1] = 255;
				color[2] = 255;
				color[3] = 255;
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 500.0 * 2.0, g_BeamIndex_heal, -1, 0, 5, 0.5, 5.0, 1.0, color, 0, 0);
	   			TE_SendToAll();
				bool Repaired_Building = false;

				//just get highest value
				float RepairRateBonus = Attributes_GetOnPlayer(client, 95, true, false);
				int healing_Amount = RoundToCeil(20.0 * RepairRateBonus);
				int CurrentMetal = GetAmmo(client, 3);

				CurrentMetal *= 5;
				for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
				{
					int entity_close = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
					if(IsValidEntity(entity_close))
					{
						GetEntPropVector(entity_close, Prop_Data, "m_vecOrigin", client_pos);
						if (GetVectorDistance(powerup_pos, client_pos, true) <= (500.0 * 500.0))
						{
							Repaired_Building = true;
							powerup_pos[2] += 45.0;
							ParticleEffectAt(client_pos, "halloween_boss_axe_hit_sparks", 1.0);
							if(CurrentMetal < healing_Amount)
							{
								healing_Amount = CurrentMetal;
							}
							if(CurrentMetal > 0)
							{
								int HealthAfter = HealEntityGlobal(client, entity_close, float(healing_Amount), _, _, _, _);

								CurrentMetal -= (HealthAfter) / 5;
							}
							Resistance_for_building_High[entity_close] = GetGameTime() + 1.1; 
						}
					}
				}

				CurrentMetal /= 5;
				SetAmmo(client, 3, CurrentMetal);
				CurrentAmmo[client][3] = GetAmmo(client, 3);
				if(Repaired_Building)
				{
					EmitSoundToAll(SOUND_REPAIR_BEAM, entity, SNDCHAN_STATIC, 90, _, 1.0);
					EmitSoundToAll(SOUND_REPAIR_BEAM, entity, SNDCHAN_STATIC, 90, _, 1.0);
				}
   			}
   			if(f_Duration[entity] < GetGameTime())
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


public int UnClaimBuildingMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(client))
			{
				ResetStoreMenuLogic(client);
				i_BuildingSelectedToBeUnClaimed[client] = -1;		
			}
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						int entity = EntRefToEntIndex(i_BuildingSelectedToBeUnClaimed[client]);
						if (IsValidEntity(entity))
						{
							int builder_owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
							if(builder_owner == client)
							{
								SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", -1);
							}
						}
						i_BuildingSelectedToBeUnClaimed[client] = -1;	
					}
				}
				default:
				{
					if(IsValidClient(client))
					{
						i_BuildingSelectedToBeUnClaimed[client] = -1;		
					}
				}
			}
		}
	}
	return 0;
}

public int DeleteBuildingMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(IsValidClient(client))
			{
				ResetStoreMenuLogic(client);
				i_BuildingSelectedToBeDeleted[client] = -1;		
			}
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			switch(id)
			{
				case -1:
				{
					if(IsValidClient(client))
					{
						int entity = EntRefToEntIndex(i_BuildingSelectedToBeDeleted[client]);
						if (IsValidEntity(entity))
						{
							DeleteAndRefundBuilding(client, entity);
						}
					}
				}
				default:
				{
					if(IsValidClient(client))
					{
						i_BuildingSelectedToBeDeleted[client] = -1;		
					}
				}
			}
		}
	}
	return 0;
}

stock int GetRandomDeathPlayer(int client)
{
	int Getclient;
	bool DeadPlayer;
	for(int client_check=1; client_check<=MaxClients; client_check++)
	{
		if(!IsValidClient(client_check))continue;
		if(TeutonType[client_check] == TEUTON_NONE)continue;
		if(client==client_check || GetTeam(client_check) != TFTeam_Red)continue;
		DeadPlayer=true;
	}
	if(!DeadPlayer)
		return -1;
	do
	{
		Getclient = GetRandomInt(1, MaxClients);
	}
	while(!IsValidClient(Getclient) || GetTeam(Getclient) != TFTeam_Red || Getclient==client || TeutonType[Getclient] == TEUTON_NONE);
	return Getclient;
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