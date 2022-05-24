static char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/metropolice/vo/putitinthetrash1.wav",
	"npc/metropolice/vo/putitinthetrash2.wav",
	
};

static char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/subject.wav",
	"npc/metropolice/vo/subjectis505.wav",
};

static char g_MeleeHitSounds[][] = {
	"weapons/stunstick/stunstick_fleshhit1.wav",
	"weapons/stunstick/stunstick_fleshhit2.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/stunstick/stunstick_swing1.wav",
	"weapons/stunstick/stunstick_swing2.wav",
};


static char g_RangedAttackSounds[][] = {
	"weapons/smg1/smg1_fire1.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/smg1/smg1_reload.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/stunstick/spark1.wav",
	"weapons/stunstick/spark2.wav",
	"weapons/stunstick/spark3.wav",
};


public void XenoCombinePoliceSmg_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
}

methodmap XenoCombinePoliceSmg < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	
	public XenoCombinePoliceSmg(int client, float vecPos[3], float vecAng[3])
	{
		XenoCombinePoliceSmg npc = view_as<XenoCombinePoliceSmg>(CClotBody(vecPos, vecAng, "models/police.mdl", "1.15", "900"));
		
		i_NpcInternalId[npc.index] = XENO_COMBINE_POLICE_SMG;
		
		int iActivity = npc.LookupActivity("ACT_RUN_AIM_RIFLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;		

		
		SDKHook(npc.index, SDKHook_OnTakeDamage, XenoCombinePoliceSmg_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, XenoCombinePoliceSmg_ClotThink);
				
		npc.m_flNextMeleeAttack = 0.0;
		
		
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 150, 255, 150, 100);

		npc.m_fbGunout = false;
		
		npc.m_iAttacksTillReload = 45;
		npc.m_bmovedelay = false;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 190.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		
		if(EscapeModeForNpc)
		{
			npc.m_flSpeed = 280.0;
		}
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_smg1.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		PF_StartPathing(npc.index);
		npc.m_bPathing = true;
		
		return npc;
	}
	
}

//TODO 
//Rewrite
public void XenoCombinePoliceSmg_ClotThink(int iNPC)
{
	XenoCombinePoliceSmg npc = view_as<XenoCombinePoliceSmg>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime() + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
				
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.flXenoInfectedSpecialHurtTime < GetGameTime())
	{
		if(npc.m_flNextThinkTime > GetGameTime())
		{
			return;
		}
		
		npc.m_flNextThinkTime = GetGameTime() + 0.1;
	}
	
	if(npc.m_flGetClosestTargetTime < GetGameTime())
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			if (npc.m_fbGunout == false && npc.m_flReloadDelay < GetGameTime())
			{
				if (!npc.m_bmovedelay)
				{
					int iActivity_melee = npc.LookupActivity("ACT_RUN_AIM_RIFLE");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay = true;
					
				}
			//	npc.FaceTowards(vecTarget);
				
			}
			else if (npc.m_fbGunout == true && npc.m_flReloadDelay < GetGameTime())
			{
				int iActivity_melee = npc.LookupActivity("ACT_IDLE_ANGRY_SMG1");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_bmovedelay = false;
				//npc.FaceTowards(vecTarget, 1000.0);
				PF_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
			
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				PF_SetGoalVector(npc.index, vPredictedPos);
			} else {
				PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			if(npc.m_flNextRangedAttack < GetGameTime() && flDistanceToTarget < 32400 && npc.m_flReloadDelay < GetGameTime())
			{
				int target;
			
				target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				
				if(!IsValidEnemy(npc.index, target))
				{
					if (!npc.m_bmovedelay)
					{
						int iActivity_melee = npc.LookupActivity("ACT_RUN_AIM_RIFLE");
						if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
						npc.m_bmovedelay = true;
						npc.m_flSpeed = 180.0;
					}
					PF_StartPathing(npc.index);
					npc.m_bPathing = true;
					npc.m_fbGunout = false;
				}
				else
				{
					npc.m_fbGunout = true;
					
					npc.m_bmovedelay = false;
					
					npc.FaceTowards(vecTarget, 20000.0);
					
					float vecSpread = 0.1;
				
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					
					float x, y;
					x = GetRandomFloat( -0.5, 0.5 ) + GetRandomFloat( -0.5, 0.5 );
					y = GetRandomFloat( -0.5, 0.5 ) + GetRandomFloat( -0.5, 0.5 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
					npc.m_flNextRangedAttack = GetGameTime() + 0.09;
					
					npc.m_iAttacksTillReload -= 1;
					
					if (npc.m_iAttacksTillReload == 0)
					{
						npc.AddGesture("ACT_RELOAD_SMG1");
						npc.m_flReloadDelay = GetGameTime() + 1.75;
						npc.m_iAttacksTillReload = 45;
						npc.PlayRangedReloadSound();
					}
					
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SMG1");
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					if(EscapeModeForNpc)
					{
						FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 6.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					}
					else
					{
						FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 3.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					}
					
					npc.PlayRangedSound();
				}
			}
			//Target close enough to hit
			if(flDistanceToTarget > 10000 && npc.m_flReloadDelay < GetGameTime())
			{
				PF_StartPathing(npc.index);
				npc.m_bPathing = true;
				npc.m_fbGunout = false;
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 5000.0);
			}
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}
	


public Action XenoCombinePoliceSmg_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	XenoCombinePoliceSmg npc = view_as<XenoCombinePoliceSmg>(victim);
	
	if(!npc.bXenoInfectedSpecialHurt)
	{
		npc.bXenoInfectedSpecialHurt = true;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 0, 0, 255);
		npc.flXenoInfectedSpecialHurtTime = GetGameTime() + 2.0;
		CreateTimer(2.0, XenoCombinePoliceSmg_Revert_Poison_Zombie_Resistance, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(10.0, XenoCombinePoliceSmg_Revert_Poison_Zombie_Resistance_Enable, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public Action XenoCombinePoliceSmg_Revert_Poison_Zombie_Resistance(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		XenoCombinePoliceSmg npc = view_as<XenoCombinePoliceSmg>(zombie);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 150, 255, 150, 255);
	}
	return Plugin_Handled;
}
public Action XenoCombinePoliceSmg_Revert_Poison_Zombie_Resistance_Enable(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		XenoCombinePoliceSmg npc = view_as<XenoCombinePoliceSmg>(zombie);
		npc.bXenoInfectedSpecialHurt = false;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 150, 255, 150, 100);
	}
	return Plugin_Handled;
}



public void XenoCombinePoliceSmg_NPCDeath(int entity)
{
	XenoCombinePoliceSmg npc = view_as<XenoCombinePoliceSmg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, XenoCombinePoliceSmg_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, XenoCombinePoliceSmg_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}