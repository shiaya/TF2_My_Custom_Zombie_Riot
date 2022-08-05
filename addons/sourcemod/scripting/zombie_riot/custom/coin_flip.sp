#define MODEL_GORDON_PROP "models/roller_spikes.mdl"
#define SOUND_GORDON_MINE_TOSS "weapons/grenade_throw.wav"
#define SOUND_GORDON_MINE_DET	"npc/roller/mine/rmine_explode_shock1.wav"

static const float gf_gordon_propthrowforce	= 900.0;
static const float gf_gordon_propthrowoffset = 90.0;
static int Coin_flip[MAXTF2PLAYERS];
static int particle_1[MAXTF2PLAYERS];
static bool mb_coin[MAXENTITIES];
static bool already_ricocated[MAXENTITIES];
static int Beam_Laser;
static int entity_test[MAXENTITIES];
static float damage_multiplier[MAXTF2PLAYERS];
static float mf_extra_damage[MAXENTITIES];
static int coins_flipped[MAXTF2PLAYERS];

//	if (Ability_Check_Cooldown(client, slot) < 0.0)
//	{
//		Ability_Apply_Cooldown(client, slot, 10.0);
		
// Ability_Check_Cooldown(client, slot);

public void Ability_Coin_Flip(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{
		Ability_Apply_Cooldown(client, slot, 10.0);
		CreateTimer(0.0, flip_extra, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public void Ability_Coin_Flip2(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 && coins_flipped[client] <= 1)
	{
		coins_flipped[client] += 1;
		CreateTimer(0.0, flip_extra, client, TIMER_FLAG_NO_MAPCHANGE);
		if(coins_flipped[client] >= 2)
		{
			coins_flipped[client] = 0;
			Ability_Apply_Cooldown(client, slot, 10.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public void Ability_Coin_Flip3(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 && coins_flipped[client] <= 2)
	{
		coins_flipped[client] += 1;
		CreateTimer(0.0, flip_extra, client, TIMER_FLAG_NO_MAPCHANGE);
		if(coins_flipped[client] >= 3)
		{
			coins_flipped[client] = 0;
			Ability_Apply_Cooldown(client, slot, 10.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}
public void Ability_Coin_Flip4(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0 && coins_flipped[client] <= 3)
	{
		coins_flipped[client] += 1;
		CreateTimer(0.0, flip_extra, client, TIMER_FLAG_NO_MAPCHANGE);
		if(coins_flipped[client] >= 4)
		{
			coins_flipped[client] = 0;
			Ability_Apply_Cooldown(client, slot, 10.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public Action short_bonus_damage(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > 0)
	{
		float chargerPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", chargerPos);
		mf_extra_damage[entity] = GetGameTime() + 1.0;
		ParticleEffectAt(chargerPos, "raygun_projectile_blue_crit", 0.3);
	}
	else
	{
		KillTimer(timer);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action Coin_on_for_too_long(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > 0)
	{
		mb_coin[entity] = false;
		entity_test[entity] = 0;
		AcceptEntityInput(entity, "break");
	}
	else
	{
		KillTimer(timer);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}
public Action Coin_on_ground(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > 0)
	{
		float targPos[3];
		float chargerPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", targPos);
		targPos[2] += 32;
		GetEntPropVector(entity_test[entity], Prop_Data, "m_vecAbsOrigin", chargerPos);
		
		if(chargerPos[2] > targPos[2])
			AcceptEntityInput(entity, "break");
	}
	else
	{
		KillTimer(timer);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}




public Action flip_extra(Handle timer, int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname) != TFWeaponSlot_Melee)
	{
		
		float fPlayerPos[3];
		float fPlayerAngles[3];
		float fThrowingVector[3];
		
		GetClientEyeAngles( client, fPlayerAngles );
		GetClientEyePosition( client, fPlayerPos );
	
		float fLen = gf_gordon_propthrowoffset * Sine( DegToRad( fPlayerAngles[0] + 90.0 ) );
		
		int entity = CreateEntityByName( "prop_physics_multiplayer" );
		if(entity != -1)
		{
		//	SetEntityCollisionGroup(entity, 2); //COLLISION_GROUP_DEBRIS_TRIGGER
		//	SDKHook(entity, SDKHook_ShouldCollide, Gib_ShouldCollide);
			for (int i = 0; i < ZR_MAX_LAG_COMP; i++) //Make them lag compensate
			{
				if (EntRefToEntIndex(i_Objects_Apply_Lagcompensation[i]) <= 0)
				{
					i_Objects_Apply_Lagcompensation[i] = EntIndexToEntRef(entity);
					i = ZR_MAX_LAG_COMP;
				}
			}
			b_IsAlliedNpc[entity] = true;
			
			entity_test[entity] = client;

			fPlayerPos[0] = fPlayerPos[0] + fLen * Cosine( DegToRad( fPlayerAngles[1] + 0.0) );
			fPlayerPos[1] = fPlayerPos[1] + fLen * Sine( DegToRad( fPlayerAngles[1] + 0.0) );
			fPlayerPos[2] = fPlayerPos[2] + gf_gordon_propthrowoffset * Sine( DegToRad( -1 * (fPlayerAngles[0] + 0.0)) );
		
			DispatchKeyValue(entity, "model", MODEL_GORDON_PROP);
			DispatchKeyValue(entity, "massScale", "0.25");
			DispatchKeyValue(entity, "disableshadows", "1");
			DispatchKeyValue( entity, "solid", "6");
			DispatchKeyValue( entity, "spawnflags", "12288");

			DispatchSpawn(entity);
			ActivateEntity(entity);

			SetEntProp(entity, Prop_Send, "m_usSolidFlags", 8);			// Fire trigger even if not solid (8)
			
			DispatchKeyValueFloat(entity, "modelscale", 0.5);
			
			SetEntityGravity(entity, 0.65);
		
			Coin_flip[client] = EntIndexToEntRef(entity);
			mb_coin[entity] = true;
			
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Red);
			
			SDKHook(entity, SDKHook_OnTakeDamage, Coin_HookDamaged);
			
			CreateTimer(3.0, Coin_on_for_too_long, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			
	//		CreateTimer(0.1, Coin_on_ground, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			float fScal = gf_gordon_propthrowforce * Sine( DegToRad( fPlayerAngles[0] + 90.0 ) );

			fThrowingVector[0] = fScal * Cosine( DegToRad( fPlayerAngles[1] ) );
			fThrowingVector[1] = fScal * Sine( DegToRad( fPlayerAngles[1] ) );
			fThrowingVector[2] = gf_gordon_propthrowforce * Sine( DegToRad( -1 * fPlayerAngles[0] ) );
			
			CreateTimer(0.75, short_bonus_damage, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);

			TeleportEntity( entity, fPlayerPos, fPlayerAngles, fThrowingVector );
			
			
			particle_1[client] = ParticleEffectAt(fPlayerPos, "raygun_projectile_red_crit", 5.0);
			
			SetParent(entity, particle_1[client]);
			
			EmitSoundToAll(SOUND_GORDON_MINE_TOSS, entity);
		}
	}
	return Plugin_Handled;
}
/*
public Action coin_land_detection(Handle timer, int client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int entity = EntRefToEntIndex(Coin_flip[client]);
		if(entity>MaxClients && IsValidEntity(entity))
		{
			if(GetEntProp(entity, Prop_Send, "m_bTouched"))
			{
				AcceptEntityInput(entity, "break");
    			PrintToChatAll("collision2");
			}
		}
	}
}

*/
public Action coin_got_rioceted(Handle timer, int client)
{
	int victim = EntRefToEntIndex(client);
	
	if (IsValidEntity(victim))
	{
		float chargerPos[3];
		
		already_ricocated[victim] = false;
		
		damage_multiplier[entity_test[victim]] *= 1.5;
		
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", -1, _, _, _, _, _, _, chargerPos);
			}
			case 2:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet2.wav", -1, _, _, _, _, _, _, chargerPos);
			}
			case 3:
			{
				EmitSoundToAll("physics/metal/metal_box_impact_bullet3.wav", -1, _, _, _, _, _, _, chargerPos);
			}
		}
		
		Do_Coin_calc(victim);
		
		entity_test[victim] = 0;
		mb_coin[victim] = false;
		AcceptEntityInput(victim, "break");
	}
	return Plugin_Handled;
}

public Action Coin_HookDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(GetEntProp(victim, Prop_Send, "m_iTeamNum") != GetEntProp(attacker, Prop_Send, "m_iTeamNum"))
		return Plugin_Continue;
		
	//Valid attackers only.
	if(attacker < 0)
		return Plugin_Continue;
	
	if (entity_test[victim] != attacker)
		return Plugin_Continue;
		
	float targPos[3];
	float chargerPos[3];
	float flAng_l[3];
	
	damage_multiplier[entity_test[victim]] = damage*3.0;
	
		
	switch(GetRandomInt(1, 3))
	{
		case 1:
		{
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", attacker);
		}
		case 2:
		{
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", attacker);
		}
		case 3:
		{
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", attacker);
		}
	}
	
	GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
	
	GetAttachment(attacker, "effect_hand_R", targPos, flAng_l);
	
	TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 5.0, 5.0, 5, 0.0, view_as<int>({160, 160, 255, 255}), 30);
	TE_SendToAll();
									
	
	already_ricocated[victim] = false;
	
	Do_Coin_calc(victim);
			
	entity_test[victim] = 0;
	mb_coin[victim] = false;
	AcceptEntityInput(victim, "break");
	
	return Plugin_Changed;
}


stock void Do_Coin_calc(int victim)
{
	float targPos[3];
	float chargerPos[3];
		
	int Closest_entity = GetClosestTarget_Coin(victim);
	
	if (IsValidEntity(Closest_entity))
	{
		mb_coin[victim] = false;
		static char classname[36];
		GetEntityClassname(Closest_entity, classname, sizeof(classname));
		if (mb_coin[Closest_entity] && !StrContains(classname, "prop_physics_multiplayer", true))
		{
			GetEntPropVector(Closest_entity, Prop_Data, "m_vecAbsOrigin", targPos);
			GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
			if (GetVectorDistance(chargerPos, targPos) <= 1200.0 && !already_ricocated[victim] && Closest_entity != victim)
			{
				already_ricocated[victim] = true;
				CreateTimer(0.1, coin_got_rioceted, EntIndexToEntRef(Closest_entity), TIMER_FLAG_NO_MAPCHANGE);
				mb_coin[Closest_entity] = false;
				
				TR_TraceRayFilter( chargerPos, targPos, ( MASK_SOLID | CONTENTS_HITBOX ), RayType_EndPoint, WorldOnly, victim );
				if(TR_DidHit())
				{
					int target = TR_GetEntityIndex();	
					static char classname_baseboss_extra[36];
					GetEntityClassname(target, classname_baseboss_extra, sizeof(classname_baseboss_extra));
					if ( target != Closest_entity && !StrContains(classname_baseboss_extra, "base_boss", true) && (GetEntProp(target, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum")))
					{
						if(mf_extra_damage[victim] > GetGameTime() && mf_extra_damage[victim] < GetGameTime() + 2.0) //You got one second.
						{
							SDKHooks_TakeDamage(target, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]]*2, DMG_BULLET, -1, NULL_VECTOR, chargerPos);
						}
						else
						{
							SDKHooks_TakeDamage(target, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
						}
					}
					TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 5.0, 5.0, 5, 0.0, view_as<int>({255, 0, 0, 255}), 30);
					TE_SendToAll();
				}
				else
				{
					TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 5.0, 5.0, 5, 0.0, view_as<int>({160, 160, 255, 255}), 30);
					TE_SendToAll();
				}
			}
			else
			{
				if (IsValidEntity(Closest_entity))
				{
					static char classname_baseboss[36];
					GetEntityClassname(Closest_entity, classname_baseboss, sizeof(classname_baseboss));
					
					if (!StrContains(classname_baseboss, "base_boss", true) && (GetEntProp(Closest_entity, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum")))
					{
						GetEntPropVector(Closest_entity, Prop_Data, "m_vecAbsOrigin", targPos);
						targPos[2] += 35;
						GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
						if (GetVectorDistance(chargerPos, targPos) <= 1300.0 && !already_ricocated[victim])
						{
							already_ricocated[victim] = true;
							TR_TraceRayFilter( chargerPos, targPos, ( MASK_SOLID | CONTENTS_HITBOX ), RayType_EndPoint, WorldOnly, victim );
							if(TR_DidHit())
							{
								int target = TR_GetEntityIndex();	
								static char classname_baseboss_extra[36];
								GetEntityClassname(target, classname_baseboss_extra, sizeof(classname_baseboss_extra));
								if ( target != Closest_entity && !StrContains(classname_baseboss_extra, "base_boss", true) && (GetEntProp(target, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum")))
								{
									if(mf_extra_damage[victim] > GetGameTime() && mf_extra_damage[victim] < GetGameTime() + 2.0) //You got one second.
									{
										SDKHooks_TakeDamage(target, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]]*2, DMG_BULLET, -1, NULL_VECTOR, chargerPos);
									}
									else
									{
										SDKHooks_TakeDamage(target, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
									}
								}
								TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 5.0, 5.0, 5, 0.0, view_as<int>({255, 0, 0, 255}), 30);
								TE_SendToAll();
							}
							else
							{
								TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 5.0, 5.0, 5, 0.0, view_as<int>({160, 160, 255, 255}), 30);
								TE_SendToAll();
							}
							
							int ent = CreateEntityByName("env_explosion");
							if(ent != -1)
							{
								
								SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", entity_test[victim]);
								
								EmitAmbientSound(SOUND_GORDON_MINE_DET, targPos);
								EmitAmbientSound(SOUND_GORDON_MINE_DET, targPos);
						
								DispatchKeyValueVector(ent, "origin", targPos);
								DispatchKeyValue(ent, "spawnflags", "64");
							
								SetEntProp(ent, Prop_Data, "m_iMagnitude", 0); 
								SetEntProp(ent, Prop_Data, "m_iRadiusOverride", 0); 
						
								DispatchSpawn(ent);
								ActivateEntity(ent);
						
								AcceptEntityInput(ent, "explode");
								AcceptEntityInput(ent, "kill");
							}
				
							if(mf_extra_damage[victim] > GetGameTime())
							{
								SDKHooks_TakeDamage(Closest_entity, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]]*2, DMG_BULLET, -1, NULL_VECTOR, chargerPos);
							}
							else
							{
								SDKHooks_TakeDamage(Closest_entity, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
							}
						}
					}
				}
			}
		}
		else
		{
			if (IsValidEntity(Closest_entity))
			{
				static char classname_baseboss[36];
				GetEntityClassname(Closest_entity, classname_baseboss, sizeof(classname_baseboss));
				if (!StrContains(classname_baseboss, "base_boss", true) && (GetEntProp(Closest_entity, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum")))
				{
					GetEntPropVector(Closest_entity, Prop_Data, "m_vecAbsOrigin", targPos);
					targPos[2] += 35;
					GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
					if (GetVectorDistance(chargerPos, targPos) <= 1300.0 && !already_ricocated[victim])
					{
						already_ricocated[victim] = true;
						TR_TraceRayFilter( chargerPos, targPos, ( MASK_SOLID | CONTENTS_HITBOX ), RayType_EndPoint, WorldOnly, victim );
						if(TR_DidHit())
						{
							int target = TR_GetEntityIndex();	
							static char classname_baseboss_extra[36];
							GetEntityClassname(target, classname_baseboss_extra, sizeof(classname_baseboss_extra));
							if ( target != Closest_entity && !StrContains(classname_baseboss_extra, "base_boss", true) && (GetEntProp(target, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum")))
							{
								if(mf_extra_damage[victim] > GetGameTime() && mf_extra_damage[victim] < GetGameTime() + 2.0) //You got one second.
								{
									SDKHooks_TakeDamage(target, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]]*2, DMG_BULLET, -1, NULL_VECTOR, chargerPos);
								}
								else
								{
									SDKHooks_TakeDamage(target, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
								}
							}
							TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 5.0, 5.0, 5, 0.0, view_as<int>({255, 0, 0, 255}), 30);
							TE_SendToAll();
						}
						else
						{
							TE_SetupBeamPoints(chargerPos, targPos, Beam_Laser, Beam_Laser, 0, 30, 1.0, 5.0, 5.0, 5, 0.0, view_as<int>({160, 160, 255, 255}), 30);
							TE_SendToAll();
						}
						
						int ent = CreateEntityByName("env_explosion");
						if(ent != -1)
						{
							SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", entity_test[victim]);
							
							EmitAmbientSound(SOUND_GORDON_MINE_DET, targPos);
							EmitAmbientSound(SOUND_GORDON_MINE_DET, targPos);
					
							DispatchKeyValueVector(ent, "origin", targPos);
							DispatchKeyValue(ent, "spawnflags", "64");
						
							SetEntProp(ent, Prop_Data, "m_iMagnitude", 0); 
							SetEntProp(ent, Prop_Data, "m_iRadiusOverride", 0); 
					
							DispatchSpawn(ent);
							ActivateEntity(ent);
						
							AcceptEntityInput(ent, "explode");
							AcceptEntityInput(ent, "kill");
						}
							
						if(mf_extra_damage[victim] > GetGameTime() && mf_extra_damage[victim] < GetGameTime() + 2.0) //You got one second.
						{
							SDKHooks_TakeDamage(Closest_entity, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]]*2, DMG_BULLET, -1, NULL_VECTOR, chargerPos);
						}
						else
						{
							SDKHooks_TakeDamage(Closest_entity, entity_test[victim], entity_test[victim], damage_multiplier[entity_test[victim]], DMG_BULLET, -1, NULL_VECTOR, chargerPos);
						}
					}
				}
			}
		}
	}
}
/*
public Action Coin_HookTouch(int entity, int other)
{
	if(other == 0)
	{
		mb_coin[entity] = false;
	//	AcceptEntityInput(entity, "break");
		PrintToChatAll("collision2");
		return Plugin_Continue;
    }
}
*/
void Abiltity_Coin_Flip_Map_Change()
{
	PrecacheSound(SOUND_GORDON_MINE_TOSS, true);
	PrecacheSound(SOUND_GORDON_MINE_DET, true);
	PrecacheSound("physics/metal/metal_box_impact_bullet1.wav", true);
	PrecacheSound("physics/metal/metal_box_impact_bullet2.wav", true);
	PrecacheSound("physics/metal/metal_box_impact_bullet3.wav", true);
	
	Beam_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Zero(coins_flipped);
//	PrecacheSound("weapons/shotgun/shotgun_cock.wav", true);
}

stock int GetClosestTarget_Coin(int entity)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 

	for(int new_entity=1; new_entity <= MAXENTITIES; new_entity++)
	{
		if (IsValidEntity(new_entity))
		{
			static char classname[36];
			GetEntityClassname(new_entity, classname, sizeof(classname));
			if (mb_coin[new_entity] && !StrContains(classname, "prop_physics_multiplayer", true) && entity != new_entity)
			{
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetEntPropVector( new_entity, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
				
				if(distance <= 1200.0)
				{
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = new_entity; 
							TargetDistance = distance;          
						}
					} 
					else 
					{
						ClosestTarget = new_entity; 
						TargetDistance = distance;
					}
				}
			}
		}
	}
	if (ClosestTarget > 0)
	{
		return ClosestTarget; 
	}
	for(int new_entity=1; new_entity <= MAXENTITIES; new_entity++)
	{
		if (IsValidEntity(new_entity) && !b_NpcHasDied[new_entity])
		{
			static char classname[36];
			GetEntityClassname(new_entity, classname, sizeof(classname));
			if (!StrContains(classname, "base_boss", true) && (GetEntProp(new_entity, Prop_Send, "m_iTeamNum") != GetEntProp(entity, Prop_Send, "m_iTeamNum")) && entity != new_entity)
			{ 
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetEntPropVector( new_entity, Prop_Data, "m_vecAbsOrigin", TargetLocation );
				TargetLocation[2] += 35;				
				float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
				
				if(distance <= 1300.0)
				{
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = new_entity; 
							TargetDistance = distance;          
						}
					} 
					else 
					{
						ClosestTarget = new_entity; 
						TargetDistance = distance;
					}
				}
			}
		}
	}
	return ClosestTarget; 
}

public bool WorldOnly(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	else if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
	
	return !(entity == iExclude);
}
