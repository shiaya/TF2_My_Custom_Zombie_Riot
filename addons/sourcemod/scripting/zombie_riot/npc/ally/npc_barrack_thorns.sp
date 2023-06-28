#pragma semicolon 1
#pragma newdecls required

int ThornsDecidedOnAttack[MAXENTITIES];
int ThornsAbilityAttackTimes[MAXENTITIES];
int ThornsAbilityActiveTimes[MAXENTITIES];
float ThornsAbilityActive[MAXENTITIES];
int ThornsLevelAt[MAXENTITIES];
float ThornsAttackedSince[MAXENTITIES];

methodmap BarrackThorns < BarrackBody
{
	public BarrackThorns(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		bool elite = view_as<bool>(Store_HasNamedItem(client, "Construction Master"));
		bool MaxPot = view_as<bool>(Store_HasNamedItem(client, "Construction Killer"));
		
		char healthSize[10];

		Format(healthSize, sizeof(healthSize), "1500");

		if(elite)
		{
			Format(healthSize, sizeof(healthSize), "2500");
		}

		if(MaxPot)
		{
			Format(healthSize, sizeof(healthSize), "4000");
		}
		BarrackThorns npc = view_as<BarrackThorns>(BarrackBody(client, vecPos, vecAng, healthSize,_,_,"0.75"));

		ThornsLevelAt[npc.index] = 0;

		if(elite)
		{
			ThornsLevelAt[npc.index] = 1;
		}

		if(MaxPot)
		{
			ThornsLevelAt[npc.index] = 2;
		}

		i_NpcInternalId[npc.index] = BARRACK_THORNS;
		i_NpcWeight[npc.index] = 2;
		
		SDKHook(npc.index, SDKHook_Think, BarrackThorns_ClotThink);

		npc.m_flSpeed = 250.0;

		if(elite)
			npc.BonusDamageBonus *= 1.5;

		ThornsDecidedOnAttack[npc.index] = 0;
		ThornsAbilityAttackTimes[npc.index] = 0;
		ThornsAbilityActiveTimes[npc.index] = 0;
		ThornsAbilityActive[npc.index] = 0.0;
		ThornsAttackedSince[npc.index] = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/player/items/demo/hwn_demo_hat.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");


		SetVariantInt(12);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		return npc;
	}
}

public void BarrackThorns_ClotThink(int iNPC)
{
	BarrackThorns npc = view_as<BarrackThorns>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(npc.m_flDoingAnimation)
	{
		npc.m_flSpeed = 0.0;
		if(npc.m_flDoingAnimation < GetGameTime(npc.index))
		{
			npc.StartPathing();
			npc.m_flSpeed = 250.0;
		}
	}
	else
	{
		npc.m_flSpeed = 250.0;
	}

	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{

		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(ThornsAttackedSince[npc.index] < GetGameTime(npc.index))
		{
			if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + 10);
				if(GetEntProp(npc.index, Prop_Data, "m_iHealth") >= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
				{
					SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
				}
			}
		}
		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);


			if(ThornsAbilityAttackTimes[npc.index] >= 15)
			{
				ThornsAbilityActiveTimes[npc.index] += 1;
				ThornsAbilityAttackTimes[npc.index] = 0;
				ThornsAbilityActive[npc.index] = GetGameTime(npc.index) + 30.0;
				float startPosition[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				if(ThornsAbilityAttackTimes[npc.index] > 1)
				{
					npc.m_iWearable3 = ParticleEffectAt_Parent(startPosition, "utaunt_gifts_floorglow_brown", npc.index, "root", {0.0,0.0,0.0});

				}
				else
				{
					npc.m_iWearable3 = ParticleEffectAt_Parent(startPosition, "utaunt_gifts_floorglow_brown", npc.index, "root", {0.0,0.0,0.0});
					CreateTimer(30.0, Timer_RemoveEntity, EntIndexToEntRef(npc.m_iWearable3), TIMER_FLAG_NO_MAPCHANGE);
				}
			}


			if(ThornsAbilityActive[npc.index] > GetGameTime(npc.index) || ThornsDecidedOnAttack[npc.index] == 3)
			{
				if(flDistanceToTarget < (1200.0 * 1200.0) || ThornsDecidedOnAttack[npc.index] == 3)
				{
					ThornsBasicAttackM2Ability(npc,GetGameTime(npc.index),client); 
				}
			}
			else
			{
				if(flDistanceToTarget < (800.0 * 800.0) && flDistanceToTarget > (100.0 * 100.0) || ThornsDecidedOnAttack[npc.index] == 1)
				{
					ThornsBasicAttackM1Ranged(npc,GetGameTime(npc.index),client); 
				}
				if(flDistanceToTarget < (800.0 * 800.0) && flDistanceToTarget < (100.0 * 100.0) ||ThornsDecidedOnAttack[npc.index] == 2)
				{
					ThornsBasicAttackM1Melee(npc,GetGameTime(npc.index),client); 
				}				
			}

		}
		if(!npc.m_flDoingAnimation)
		{
			BarrackBody_ThinkMove(npc.index, 250.0, "ACT_THORNS_STAND", "ACT_THORNS_WALK");
		}
	}
}

void BarrackThorns_NPCDeath(int entity)
{
	BarrackThorns npc = view_as<BarrackThorns>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackThorns_ClotThink);
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		BarrackThorns prop = view_as<BarrackThorns>(entity_death);
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);

		DispatchKeyValue(entity_death, "model", COMBINE_CUSTOM_MODEL);

		DispatchSpawn(entity_death);
		
		prop.m_iWearable1 = prop.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable1, "SetModelScale");

		prop.m_iWearable2 = prop.EquipItem("weapon_bone", "models/player/items/demo/hwn_demo_hat.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(prop.m_iWearable2, "SetModelScale");

		SetVariantInt(12);
		AcceptEntityInput(entity_death, "SetBodyGroup");

		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 0.75); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("Thorns_Death");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable1), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable2), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void ThornsBasicAttackM1Melee(BarrackThorns npc, float gameTime, int client)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			ThornsDecidedOnAttack[npc.index] = 0;
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
								
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						ThornsAbilityAttackTimes[npc.index] += 1;
						float damage = 2000.0;
						if(ThornsLevelAt[npc.index] == 2)
						{
							damage *= 2.5;
						}
						else if(ThornsLevelAt[npc.index] == 1)
						{
							damage *= 1.5;
						}
						SDKHooks_TakeDamage(target, npc.index, client, damage * npc.BonusDamageBonus, DMG_CLUB, -1, _, vecHit);						

						npc.PlayMeleeHitSound();
					} 
				}
				delete swingTrace;
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			int Enemy_I_See;
									
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
			if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.AddGesture("ACT_THORNS_ATTACK_1");
				npc.PlaySwordSound();
				npc.m_flAttackHappens = gameTime + 0.3;
				npc.m_flNextMeleeAttack = gameTime + (1.0 * npc.BonusFireRate);
				npc.m_flDoingAnimation = gameTime + 1.0;
				NPC_StopPathing(npc.index);
				npc.m_flSpeed = 0.0;
				ThornsDecidedOnAttack[npc.index] = 2;
				ThornsAttackedSince[npc.index] = GetGameTime(npc.index) + 5.0;
				//make thorns not move when attacking.
			}
		}
	}
}



void ThornsBasicAttackM1Ranged(BarrackThorns npc, float gameTime, int client)
{
	if(npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
		}
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			ThornsDecidedOnAttack[npc.index] = 0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				int Enemy_I_See;
										
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
							
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					ThornsAbilityAttackTimes[npc.index] += 1;
					npc.PlayRangedSound();

					float damage = 1500.0;
					if(ThornsLevelAt[npc.index] == 2)
					{
						damage *= 2.5;
					}
					else if(ThornsLevelAt[npc.index] == 1)
					{
						damage *= 1.5;
					}
							
					float flPos[3]; // original
					float flAng[3]; // original
					GetAttachment(npc.index, "weapon_bone", flPos, flAng);
					float vecTarget[3];
					float speed = 2000.0;
					vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, speed);
					npc.m_flSpeed = 0.0;
					int rocket;
					rocket = npc.FireParticleRocket(vecTarget, damage * npc.BonusDamageBonus , speed, 100.0 , "raygun_projectile_red_trail", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
				//	npc.DispatchParticleEffect(npc.index, "utaunt_firework_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);

					DataPack pack;
					CreateDataTimer(0.1, PerfectHomingShot, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					pack.WriteCell(EntIndexToEntRef(rocket)); //projectile
					pack.WriteCell(EntIndexToEntRef(npc.m_iTarget));		//victim to annihilate :)
				}
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			int Enemy_I_See;
									
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
			if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.AddGesture("ACT_THORNS_ATTACK_1_RANGED");
				npc.PlaySwordSound();
				npc.m_flAttackHappens = gameTime + 0.45;
				npc.m_flNextMeleeAttack = gameTime + (1.0 * npc.BonusFireRate);
				npc.m_flDoingAnimation = gameTime + 1.0;
				NPC_StopPathing(npc.index);
				npc.m_flSpeed = 0.0;
				//make thorns not move when attacking.
				ThornsDecidedOnAttack[npc.index] = 1;
				ThornsAttackedSince[npc.index] = GetGameTime(npc.index) + 5.0;
			}
		}
	}
}



void ThornsBasicAttackM2Ability(BarrackThorns npc, float gameTime, int client)
{
	if(npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
		}
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			ThornsDecidedOnAttack[npc.index] = 0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				int Enemy_I_See;
										
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
							
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.PlayRangedSound();

					float damage = 4500.0;

					if(ThornsAbilityActiveTimes[npc.index] > 1)
					{
						damage = 10000.0;
					}
					
					if(ThornsLevelAt[npc.index] == 2)
					{
						damage *= 2.5;
					}
					else if(ThornsLevelAt[npc.index] == 1)
					{
						damage *= 1.5;
					}
							
					float flPos[3]; // original
					float flAng[3]; // original
					GetAttachment(npc.index, "weapon_bone", flPos, flAng);
					float vecTarget[3];
					float speed = 2000.0;
					vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, speed);
					npc.m_flSpeed = 0.0;
					int rocket;
					rocket = npc.FireParticleRocket(vecTarget, damage * npc.BonusDamageBonus , speed, 100.0 , "raygun_projectile_red_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
				
				//	npc.DispatchParticleEffect(npc.index, "utaunt_firework_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
					DataPack pack;
					CreateDataTimer(0.1, PerfectHomingShot, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					pack.WriteCell(EntIndexToEntRef(rocket)); //projectile
					pack.WriteCell(EntIndexToEntRef(npc.m_iTarget));		//victim to annihilate :)
				
				}
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			int Enemy_I_See;
									
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
			if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				if(ThornsAbilityActiveTimes[npc.index] > 1)
				{
					npc.AddGesture("ACT_THORNS_ATTACK_2_FAST");
					npc.PlaySwordSound();
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + (0.4 * npc.BonusFireRate);
					npc.m_flDoingAnimation = gameTime + 0.4;
				}
				else
				{
					npc.AddGesture("ACT_THORNS_ATTACK_2");
					npc.PlaySwordSound();
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + (0.75 * npc.BonusFireRate);
					npc.m_flDoingAnimation = gameTime + 0.75;					
					
				}
				NPC_StopPathing(npc.index);
				npc.m_flSpeed = 0.0;
				//make thorns not move when attacking.
				ThornsDecidedOnAttack[npc.index] = 3;
				ThornsAttackedSince[npc.index] = GetGameTime(npc.index) + 5.0;
			}
		}
	}
}