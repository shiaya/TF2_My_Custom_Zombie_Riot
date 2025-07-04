#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void K_Unspeakable_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Unspeakable");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_k_unspeakable");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_precision_strike");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{

}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return K_Unspeakable(client, vecPos, vecAng, ally, data);
}

methodmap K_Unspeakable < CClotBody
{

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
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
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
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
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