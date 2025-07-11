#pragma semicolon 1
#pragma newdecls required

void K_Unspeakable_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Uglyble");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_k_unspeakable");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_precision_strike");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundCustom("baka_zr/0hn0.mp3");
	PrecacheSoundCustom("baka_zr/ki11me.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return K_Unspeakable(client, vecPos, vecAng, ally, data);
}

methodmap K_Unspeakable < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll("baka_zr/0hn0.mp3", this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayTeleportSound() 
	{
		EmitSoundToAll("baka_zr/ki11me.mp3", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public K_Unspeakable(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ally = TFTeam_Stalkers;
		K_Unspeakable npc = view_as<K_Unspeakable>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.0", "19721121", ally, false, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.AddActivityViaSequence("ref");
		npc.SetCycle(0.01);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = view_as<Function>(K_Unspeakable_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(K_Unspeakable_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(K_Unspeakable_ClotThink);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 30.0;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 10.0;
		
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
		
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_the_haha_hairdo/hw2013_the_haha_hairdo.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2019_binoculus/hwn2019_binoculus_pyro.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/hwn2019_pyro_lantern/hwn2019_pyro_lantern.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
				
		if(ally != TFTeam_Red)
		{
			int Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 750.0);
			switch(Decicion)
			{
				case 2:
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 500.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 250.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 750.0, 0.0);
						}
					}
				}
				case 3:
				{
					//todo code on what to do if random teleport is disabled
				}
			}
		}
		return npc;
	}
}

static void K_Unspeakable_ClotThink(int iNPC)
{
	K_Unspeakable npc = view_as<K_Unspeakable>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 35.0;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 5.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
			ApplyStatusEffect(npc.index, npc.m_iTarget, "Oh No Kill Me", 1.0);
		}
		else 
		{
			if(!npc.m_bPathing)
				npc.StartPathing();
			npc.SetGoalEntity(npc.m_iTarget);
		}
		KUglyble_TeleToU(npc);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action K_Unspeakable_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	K_Unspeakable npc = view_as<K_Unspeakable>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void K_Unspeakable_NPCDeath(int entity)
{
	K_Unspeakable npc = view_as<K_Unspeakable>(entity);

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

bool KUglyble_TeleToU(K_Unspeakable npc)
{
	if(npc.m_flJumpCooldown < GetGameTime(npc.index))
	{
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );
		if(IsValidEnemy(npc.index, npc.m_iTarget, true, true))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );	
				
			float PreviousPos[3];
			WorldSpaceCenter(npc.index, PreviousPos);
			//randomly around the target.
			vecTarget[0] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
			vecTarget[1] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
			
			bool Succeed = Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, true);
			if(Succeed)
			{
				npc.PlayTeleportSound();
				ParticleEffectAt(PreviousPos, "teleported_blue", 0.5);
				ParticleEffectAt(PreviousPos, "teleported_red", 0.5);
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
				ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.FaceTowards(vecTarget, 15000.0);
				npc.m_flJumpCooldown = GetGameTime(npc.index) + 20.0;
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 5.0;
				int particle = ParticleEffectAt(flPos, "utaunt_headless_glow", 1.5);
				SetParent(npc.index, particle);

				int red = 125;
				int green = 0;
				int blue = 125;
				int Alpha = 200;
				int colorLayer4[4];
				float diameter = float(10 * 4);
				SetColorRGBA(colorLayer4, red, green, blue, Alpha);
				//we set colours of the differnet laser effects to give it more of an effect
				int colorLayer1[4];
				SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
				int glowColor[4];
				SetColorRGBA(glowColor, red, green, blue, Alpha);
				TE_SetupBeamPoints(PreviousPos, WorldSpaceVec, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(PreviousPos, WorldSpaceVec, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(PreviousPos, WorldSpaceVec, Shared_BEAM_Laser, 0, 0, 0, 0.35, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
				TE_SendToAll(0.0);
			}
			else
			{
				npc.m_flJumpCooldown = GetGameTime(npc.index) + 0.25;
			}
		}
	}
	return false;
}