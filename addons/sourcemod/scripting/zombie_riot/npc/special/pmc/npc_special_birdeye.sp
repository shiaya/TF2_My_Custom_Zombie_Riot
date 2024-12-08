#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/csgo_awp_shoot.wav",
};

static const char g_ReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_TeleportSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static bool b_SUPERDUPERRAGE[MAXENTITIES];
static bool b_GotBuilding[MAXENTITIES];

void VictoriaSpecialBirdeye_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_TeleportSounds)); i++) { PrecacheSound(g_TeleportSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Birdeye");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_special_birdeye");
	strcopy(data.Icon, sizeof(data.Icon), "sniper_headshot");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaSpecialBirdeye(client, vecPos, vecAng, ally, data);
}

static char[] GetPMCHealth()
{
	int health = 55;
	
	health *= CountPlayersOnRed(); //yeah its high. will need to scale with waves exponentially.
	
	float temp_float_hp = float(health);
	
	if(ZR_GetWaveCount()+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.25));
	}
	else if(ZR_GetWaveCount()+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.35));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(ZR_GetWaveCount()+1)) * float(ZR_GetWaveCount()+1)),1.40));
	}
	
	health /= 6;
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}

methodmap VictoriaSpecialBirdeye < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRAGEattackSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 70, _, 0.6);
	}
	
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound[GetRandomInt(0, sizeof(g_ReloadSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayTeleportSound()
	{
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public VictoriaSpecialBirdeye(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaSpecialBirdeye npc = view_as<VictoriaSpecialBirdeye>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", GetPMCHealth(), ally));
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = view_as<Function>(VictoriaSpecialBirdeye_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaSpecialBirdeye_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaSpecialBirdeye_ClotThink);
		
		npc.m_iChanged_WalkCycle = 0;
		npc.g_TimesSummoned = 0;

		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.StartPathing();
			npc.m_flSpeed = 200.0;
		}	
		npc.m_flNextMeleeAttack = GetGameTime() + 1.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f_HeadshotDamageMultiNpc[npc.index] = 1.25;
		
		if(!StrContains(data, "rage"))
			npc.m_bFUCKYOU = true;
		else
			npc.m_bFUCKYOU = false;
		if(!StrContains(data, "notele"))
			b_SUPERDUPERRAGE[npc.index] = true;
		else
			b_SUPERDUPERRAGE[npc.index] = false;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		
		npc.m_iOverlordComboAttack = 31;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/cc_summer2015_the_rotation_sensation_style2/cc_summer2015_the_rotation_sensation_style2_sniper.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/spr17_down_under_duster/spr17_down_under_duster.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2020_gourd_grin/hwn2020_gourd_grin_sniper.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, _, _, _, 1.0);	
			}
			LastSpawnDiversio = GetGameTime() + 20.0;
			TeleportDiversioToRandLocation(npc.index, _,1750.0, 1250.0);
			float Vec[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Vec);
			ParticleEffectAt(Vec, "teleported_blue", 0.5);
		}

		if(!StrContains(data, "only"))
		{
			//none
		}
		else
			RequestFrame(VictoriaSpecialBirdeye_SpawnAllyDuo, EntIndexToEntRef(npc.index));
		return npc;
	}
}

/*
public void Birdeye_ClotDamaged_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	VictoriaSpecialBirdeye npc = view_as<VictoriaSpecialBirdeye>(victim);
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		
		float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
		if(0.8 - (npc.g_TimesSummoned*0.2) > ratio)
		{
			npc.PlayTeleportSound();
			TeleportDiversioToRandLocation(npc.index,_,1750.0, 1250.0);
			float self_vec[3]; WorldSpaceCenter(npc.index, self_vec);
			ParticleEffectAt(self_vec, "teleported_blue", 0.5);
			npc.g_TimesSummoned++;
		}
	}
	else
	{
		fl_TotalArmor[npc.index] = 1.0;
	}
}
*/

public void VictoriaSpecialBirdeye_ClotThink(int iNPC)
{
	VictoriaSpecialBirdeye npc = view_as<VictoriaSpecialBirdeye>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int ExtraBehavior;
		if(npc.m_bFUCKYOU)
			ExtraBehavior = VictoriaSpecialBirdeyeAssaultMode(npc,GetGameTime(npc.index), npc.m_iTargetWalkTo, flDistanceToTarget); 
		else
			ExtraBehavior = VictoriaSpecialBirdeyeSniperMode(npc,GetGameTime(npc.index));
		switch(ExtraBehavior)
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
					npc.m_flSpeed = 200.0;
				}
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}
				npc.m_flSpeed = (npc.m_flCharge_delay < GetGameTime(npc.index)) ? 280.0 : 150.0;
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
				}
			}
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}
				npc.m_flSpeed = (npc.m_flCharge_delay < GetGameTime(npc.index)) ? 280.0 : 150.0;
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true); //update more often, we need it
			}
			case 4:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 2;
					npc.StartPathing();
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.5;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true,_,_,0.37);
					npc.m_flSpeed = 350.0;
					npc.PlayReloadSound();
					DataPack ReloadAmmo;
					CreateDataTimer(2.5, Timer_Runaway, ReloadAmmo, TIMER_FLAG_NO_MAPCHANGE);
					ReloadAmmo.WriteCell(npc.index);
					ReloadAmmo.WriteCell(31);
				}
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true);
			}
		}
		
		if(!npc.m_bFUCKYOU)
		{
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else 
			{
				NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action VictoriaSpecialBirdeye_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaSpecialBirdeye npc = view_as<VictoriaSpecialBirdeye>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.5 || (float(health)-damage)<(maxhealth*0.5))
	{
		if(!npc.Anger)
		{
			damage=0.0;
			IncreaceEntityDamageTakenBy(npc.index, 0.000001, 0.2);
			if(b_SUPERDUPERRAGE[npc.index])
			{
				npc.PlayIdleAlertSound();
				npc.m_flMeleeArmor -= 0.3;
				npc.m_flRangedArmor -= 0.3;
				npc.m_bFUCKYOU = true;
			}
			else
				CreateTimer(0.1, Timer_BirdEyeTele, npc.index, TIMER_FLAG_NO_MAPCHANGE);
			npc.Anger = true;
		}
	}
	return Plugin_Changed;
}

static Action Timer_BirdEyeTele(Handle timer, int iNPC)
{
	VictoriaSpecialBirdeye npc = view_as<VictoriaSpecialBirdeye>(iNPC);
	float Vec[3], VecOld[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", VecOld);
	bool FUCKU=false;
	if(GetRandomInt(0, 10) > 8)
		FUCKU=true;
	else
	{
		int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1750.0, 1250.0);
		switch(Decicion)
		{
			case 2:
			{
				Decicion = TeleportDiversioToRandLocation(npc.index, true, 1750.0, 625.0);
				if(Decicion == 2)
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 1750.0, 312.5);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 1750.0, 0.0);
						if(Decicion == 3) FUCKU=true;
					}
					else if(Decicion == 3) FUCKU=true;
				}
				else if(Decicion == 3) FUCKU=true;
			}
			case 3: FUCKU=true;
		}
	}
	if(FUCKU)
	{
		npc.PlayIdleAlertSound();
		npc.m_flMeleeArmor -= 0.3;
		npc.m_flRangedArmor -= 0.3;
		npc.m_bFUCKYOU = true;
	}
	else
	{
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Vec);
		NPC_SetGoalVector(npc.index, Vec, true);
		float SoClose = GetVectorDistance(Vec, VecOld);
		if(SoClose < 500.0)
		{
			npc.PlayIdleAlertSound();
			npc.m_flMeleeArmor -= 0.3;
			npc.m_flRangedArmor -= 0.3;
			npc.m_bFUCKYOU = true;
			TeleportEntity(npc.index, VecOld);
			return Plugin_Stop;
		}
		ParticleEffectAt(VecOld, "teleported_red", 0.5);
		ParticleEffectAt(Vec, "teleported_blue", 0.5);
		TeleportEntity(npc.index, Vec);
		npc.PlayTeleportSound();
	}
	return Plugin_Stop;
}

public void VictoriaSpecialBirdeye_NPCDeath(int entity)
{
	VictoriaSpecialBirdeye npc = view_as<VictoriaSpecialBirdeye>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

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

int VictoriaSpecialBirdeyeSniperMode(VictoriaSpecialBirdeye npc, float gameTime)
{
	if(!npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
			if(!IsValidEnemy(npc.index,npc.m_iTarget))
			{
				return 0;
			}		
		}
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			return 0;
		}
	}
	/*if(RogueTheme == BlueParadox && i_npcspawnprotection[npc.index] == 1)
		return 0;*/
		
	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	npc.FaceTowards(VecEnemy, 15000.0);

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3], angles[3];
	view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
	if(npc.m_flDoingAnimation > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, ThrowPos[npc.index]);
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
		}
	}
	else
	{	
		if(npc.m_flAttackHappens)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	if(npc.m_flAttackHappens)
	{
		TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, {0,0,255,255}, 3);
		TE_SendToAll(0.0);
	}
			
	npc.FaceTowards(ThrowPos[npc.index], 15000.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, ThrowPos[npc.index], false );
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;	

			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			npc.PlayMeleeSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 250.0;
				if(ZR_GetWaveCount()+1 > 12)
					damageDealt *= float(ZR_GetWaveCount()+1)*0.1;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 99.0;
				
				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				if(IsValidClient(target))
					TF2_AddCondition(target, TFCond_MarkedForDeath, 60.0);
				else
					NpcStats_SilenceEnemy(target, (b_thisNpcIsARaid[target] || b_thisNpcIsABoss[target] ? 30.0 : 60.0));
			} 
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.m_flAttackHappens = gameTime + 1.25;
		npc.m_flDoingAnimation = gameTime + 0.95;
		npc.m_flNextMeleeAttack = gameTime + 2.5;
	}
	return 1;
}

int VictoriaSpecialBirdeyeAssaultMode(VictoriaSpecialBirdeye npc, float gameTime, int target, float distance)
{
	if(npc.m_iOverlordComboAttack < 1)
		return 4;
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 18.0))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTargetWalkTo);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.PlayRAGEattackSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				npc.m_iTargetWalkTo = Enemy_I_See;
				if(ShouldNpcDealBonusDamage(npc.m_iTargetWalkTo))
					b_GotBuilding[npc.index]=true;
				else
					b_GotBuilding[npc.index]=false;
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					target = TR_GetEntityIndex(swingTrace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer01_red", origin, vecHit, false);
					npc.m_flNextMeleeAttack = gameTime + 0.1;
					npc.m_flCharge_delay = gameTime + 0.8;
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 20.0;
						if(ZR_GetWaveCount()+1 > 12)
							damageDealt *= float(ZR_GetWaveCount()+1)*0.1;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 3.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
					npc.m_iOverlordComboAttack--;
				}
				delete swingTrace;
			}
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0) || b_GotBuilding[npc.index])
			{
				//target is too far, try to close in
				return 2;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 14.0))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 3;
				}
			}
			return 2;
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 14.5) || b_GotBuilding[npc.index])
			{
				//target is too far, try to close in
				return 2;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 13.0))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 3;
				}
			}
		}
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 14.5) || b_GotBuilding[npc.index])
		{
			//target is too far, try to close in
			return 2;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 13.0))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 3;
			}
		}
	}
	return 0;
}

void VictoriaSpecialBirdeye_SpawnAllyDuo(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(entity, Prop_Data, "m_iHealth");
		
		maxhealth = RoundToFloor(maxhealth*2.0);

		int spawn_index = NPC_CreateByName("npc_special_harbringer", entity, pos, ang, GetTeam(entity));
		int spawn_index2 = NPC_CreateByName("npc_special_bigpipe", entity, pos, ang, GetTeam(entity));
		if(spawn_index > MaxClients)
		{
			//i_ally_index = EntIndexToEntRef(spawn_index);
			//VictoriaHarbringer_Set_Ally_Index(entity);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
		if(spawn_index2 > MaxClients)
		{
			//i_ally_index = EntIndexToEntRef(spawn_index2);
			//VictoriaBigPipe_Set_Ally_Index(entity);
			NpcAddedToZombiesLeftCurrently(spawn_index2, true);
			SetEntProp(spawn_index2, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index2, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}