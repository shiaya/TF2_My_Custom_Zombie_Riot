#pragma semicolon 1
#pragma newdecls required

methodmap CombineAR2 < CombineSoldier
{
	public CombineAR2(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CombineAR2 npc = view_as<CombineAR2>(BaseSquad(vecPos, vecAng, "models/combine_soldier.mdl", "1.15", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_AR2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = true;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 31;

		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, BaseSquad_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombineAR2_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		return npc;
	}
}

public void CombineAR2_ClotThink(int iNPC)
{
	CombineAR2 npc = view_as<CombineAR2>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.PlayHurt();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	float vecMe[3];
	vecMe = WorldSpaceCenter(npc.index);
	BaseSquad_BaseThinking(npc, vecMe);

	bool canWalk = view_as<bool>(npc.m_iTargetWalk);
	bool duckAnim;
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		vecTarget = WorldSpaceCenter(npc.m_iTargetAttack);

		bool shouldFlank = view_as<bool>(npc.m_iTargetWalk);
		if(shouldFlank)
		{
			for(int i = MaxClients + 1; i < MAXENTITIES; i++) 
			{
				if(i != npc.index)
				{
					BaseSquad ally = view_as<BaseSquad>(i);
					if(ally.m_bIsSquad && ally.m_iTargetAttack == npc.m_iTargetAttack && !ally.m_bRanged)
					{
						shouldFlank = false;	// An ally rushing with a melee, I should cover them
						break;
					}
				}
			}
		}

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(shouldFlank)
		{
			if(distance > (npc.m_bRanged ? 70000.0 : 125000.0))	// 265, 355  HU
			{
				shouldFlank = false;
			}
		}

		npc.m_bRanged = shouldFlank;
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				canWalk = false;
				npc.FaceTowards(vecTarget, 20000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						// E2 L5 = 105, E2 L10 = 120
						SDKHooks_TakeDamage(target, npc.index, npc.index, Level[npc.index] * 3.0, DMG_CLUB, -1, _, vecTarget);
						npc.PlayFistHit();
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextRangedSpecialAttackHappens)
		{
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
			{
				// E2 L5 = 280, E2 L10 = 320
				vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTargetAttack, 800.0);
				npc.FireGrenade(vecTarget, 800.0, Level[npc.index] * 8.0, "models/weapons/w_grenade.mdl");
			}
		}

		if(npc.m_flNextRangedAttack > gameTime)
		{
			canWalk = false;

			if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				npc.FaceTowards(vecTarget, 2000.0);
		}
		else if(distance < 10000.0)	// 100 HU
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_MELEE_ATTACK1");
				npc.PlayFistFire();

				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.85;
			}
		}
		else if(distance < 250000.0 || !npc.m_iTargetWalk)	// 500 HU
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				float distance = GetVectorDistance(vecMe, vecTarget, true);

				if(npc.m_iAttacksTillReload < 1)
				{
					canWalk = false;
					
					npc.AddGesture("ACT_RELOAD");
					npc.m_flNextMeleeAttack = gameTime + 1.85;
					npc.m_flNextRangedAttack = gameTime + 2.15;
					npc.m_iAttacksTillReload = 30;
					npc.PlayAR2Reload();
				}
				else if(IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
				{
					npc.FaceTowards(vecTarget, 2000.0);
					canWalk = false;

					//npc.m_flNextRangedAttack = gameTime + 0.09;
					npc.m_iAttacksTillReload--;
					
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					float x = GetRandomFloat( -0.05, 0.05 );
					float y = GetRandomFloat( -0.05, 0.05 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					float vecDir[3];
					for(int i; i < 3; i++)
					{
						vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
					}

					NormalizeVector(vecDir, vecDir);
					
					// E2 L5 = 5.25, E2 L10 = 6
					FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, Level[npc.index] * 0.125, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
					npc.PlayAR2Fire();
				}
			}
			else
			{
				npc.FaceTowards(vecTarget, 1500.0);
				canWalk = false;
			}
		}
		else if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			if(IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.PlayFistFire();

				npc.m_flNextMeleeAttack = gameTime + 0.95;
				npc.m_flNextRangedAttack = gameTime + 1.15;
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 0.55;
				npc.m_flNextRangedSpecialAttack = gameTime + 19.5;
			}
		}

		if(npc.m_flNextRangedSpecialAttack > gameTime && !npc.m_flAttackHappens && (!canWalk || npc.m_flNextRangedAttack < gameTime) && npc.m_bRanged && distance > 20000.0)	// 141 HU
			duckAnim = true;
	}

	if(canWalk)
	{
		BaseSquad_BaseWalking(npc, vecMe);
	}
	else
	{
		npc.StopPathing();
	}

	if(!npc.m_bPathing && npc.m_iAttacksTillReload < 31)
	{
		npc.AddGesture("ACT_RELOAD");
		npc.m_flNextMeleeAttack = gameTime + 1.85;
		npc.m_flNextRangedAttack = gameTime + 2.15;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_iAttacksTillReload = 31;
		npc.PlayAR2Reload();
	}

	bool anger = BaseSquad_BaseAnim(npc, 89.60, "ACT_IDLE", "ACT_WALK_EASY", 108.20, duckAnim ? "ACT_COVER" : "ACT_IDLE_ANGRY", duckAnim ? "ACT_WALK_CROUCH_RIFLE" : "ACT_WALK_AIM_RIFLE");
	npc.PlayIdle(anger);
}

void CombineAR2_NPCDeath(int entity)
{
	CombineAR2 npc = view_as<CombineAR2>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, BaseSquad_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, CombineAR2_ClotThink);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
