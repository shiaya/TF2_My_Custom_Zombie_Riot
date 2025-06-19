#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/heavy_meleedare13.mp3",
	"vo/heavy_meleedare12.mp3",
	"vo/heavy_meleedare07.mp3",
	"vo/heavy_meleedare06.mp3",
	"vo/heavy_meleedare05.mp3",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};
static const char g_RangedSound[][] = {
	"weapons/gauss/fire1.wav",
};

static const char g_HurtArmorSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};
static const char g_SuperJumpSound[][] = {
	"misc/halloween/spell_mirv_explode_primary.wav",
};

static char g_AngerSounds[][] = {
	"vo/taunts/soldier_taunts03.mp3",
};

static char g_SyctheHitSound[][] = {
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer3.wav",
	"ambient/machines/slicer4.wav",
};

static char g_SyctheInitiateSound[][] = {
	"npc/env_headcrabcanister/incoming.wav",
};


static char g_AngerSoundsPassed[][] = {
	"vo/taunts/soldier_taunts15.mp3",
};

static const char g_LaserGlobalAttackSound[][] = {
	"weapons/bumper_car_speed_boost_start.wav",
};

static const char g_MessengerThrowFire[][] = {
	"misc/halloween/spell_fireball_cast.wav",
};

static const char g_MessengerThrowIce[][] = {
	"weapons/icicle_freeze_victim_01.wav",
};


static const char g_BobSuperMeleeCharge[][] =
{
	"weapons/vaccinator_charge_tier_01.wav",
	"weapons/vaccinator_charge_tier_02.wav",
	"weapons/vaccinator_charge_tier_03.wav",
	"weapons/vaccinator_charge_tier_04.wav",
};

static const char g_BobSuperMeleeCharge_Hit[][] =
{
	"player/taunt_yeti_standee_break.wav",
};

static const char g_charge_sound[][] = {
	"misc/halloween/spell_blast_jump.wav",
};

static float f_MessengerSpeedUp[MAXENTITIES];
static int i_SpeedUpTime[MAXENTITIES];
static bool b_khamlWeaponRage[MAXENTITIES];

static int i_khamlCutscene[MAXENTITIES];
static float f_khamlCutscene[MAXENTITIES];


static float f_KahmlResTemp[MAXENTITIES];
static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

static int NPCId;

void ChaosKahmlstein_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chaos Kahmlstein");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_kahmlstein");
	strcopy(data.Icon, sizeof(data.Icon), "kahmlstein");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);

	//sound is also used somewhere else
	//for example, a weapon.
	PrecacheSoundCustom("zombiesurvival/internius/blinkarrival.wav");
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MessengerThrowFire));	   i++) { PrecacheSound(g_MessengerThrowFire[i]);	   }
	for (int i = 0; i < (sizeof(g_MessengerThrowIce));	   i++) { PrecacheSound(g_MessengerThrowIce[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedSound)); i++) { PrecacheSound(g_RangedSound[i]); }
	for (int i = 0; i < (sizeof(g_HurtArmorSounds)); i++) { PrecacheSound(g_HurtArmorSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_AngerSoundsPassed));   i++) { PrecacheSound(g_AngerSoundsPassed[i]);   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_SyctheHitSound));   i++) { PrecacheSound(g_SyctheHitSound[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheInitiateSound));   i++) { PrecacheSound(g_SyctheInitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_LaserGlobalAttackSound));   i++) { PrecacheSound(g_LaserGlobalAttackSound[i]);   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_charge_sound)); i++) { PrecacheSound(g_charge_sound[i]); }
	PrecacheSoundArray(g_BobSuperMeleeCharge_Hit);
	PrecacheSoundArray(g_BobSuperMeleeCharge);
	PrecacheSoundCustom("#zombiesurvival/internius/chaos_reigns_intro.mp3");
	PrecacheSoundCustom("#zombiesurvival/internius/chaos_reigns_loop.mp3");
	PrecacheSound("player/taunt_knuckle_crack.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return ChaosKahmlstein(vecPos, vecAng, team, data);
}
methodmap ChaosKahmlstein < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property float f_ChaosKahmlsteinMeleeCooldown
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float f_ChaosKahmlsteinRocketJumpCD
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property float f_ChaosKahmlsteinRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool b_ChaosKahmlsteinRocketJump
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
	}
	public void PlayAngerSoundPassed() 
	{
		int sound = GetRandomInt(0, sizeof(g_AngerSoundsPassed) - 1);
		EmitSoundToAll(g_AngerSoundsPassed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSoundsPassed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);

		EmitSoundToAll("mvm/mvm_tele_deliver.wav", this.index, SNDCHAN_STATIC, 80, _, 0.8);
	}
	public void PlaySytheInitSound() {
	
		int sound = GetRandomInt(0, sizeof(g_SyctheInitiateSound) - 1);
		EmitSoundToAll(g_SyctheInitiateSound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SyctheInitiateSound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], _, SNDCHAN_STATIC, _, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[sound], _, SNDCHAN_STATIC, _, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayChargeSound() 
	{
		EmitSoundToAll(g_charge_sound[GetRandomInt(0, sizeof(g_charge_sound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80, 85));

	}
	public void PlayProjectileSound() 
	{
		if(this.m_flidle_talk > GetGameTime(this.index))
			return;
			
		this.m_flidle_talk = GetGameTime(this.index) + 0.1;
		EmitSoundToAll(g_MessengerThrowIce[GetRandomInt(0, sizeof(g_MessengerThrowIce) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		EmitSoundToAll(g_IdleAlertedSounds[sound], _, SNDCHAN_STATIC, _, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleAlertedSounds[sound], _, SNDCHAN_STATIC, _, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0);
		EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0);
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() 
	{
		EmitSoundToAll(g_RangedSound[GetRandomInt(0, sizeof(g_RangedSound) - 1)], this.index, SNDCHAN_WEAPON, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayHurtArmorSound() 
	{
		EmitSoundToAll(g_HurtArmorSounds[GetRandomInt(0, sizeof(g_HurtArmorSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBobMeleePostHit()
	{
		int pitch = GetRandomInt(70,80);
		EmitSoundToAll(g_BobSuperMeleeCharge_Hit[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
		EmitSoundToAll(g_BobSuperMeleeCharge_Hit[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
	}
	public void PlayBobMeleePreHit()
	{
		EmitSoundToAll(g_BobSuperMeleeCharge[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, GetRandomInt(80,90));
	}
	
	public void PlayHurtSound() 
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() 
	{
		EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", this.index, SNDCHAN_STATIC, 80, _, 3.0);	
	}
	property float m_flFixAttackCanceling
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public ChaosKahmlstein(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ChaosKahmlstein npc = view_as<ChaosKahmlstein>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "40000", ally, false, true, true,_)); //giant!
		
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
///		SetVariantInt(4);
//		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;	
		b_khamlWeaponRage[npc.index] = false;
		b_angered_twice[npc.index] = false;
		f_TalkDelayCheck = 0.0;
		i_TalkDelayCheck = 0;



		func_NPCDeath[npc.index] = view_as<Function>(ChaosKahmlstein_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ChaosKahmlstein_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ChaosKahmlstein_ClotThink);


		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		npc.i_GunMode = 0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 10.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 5.0;
		npc.m_flAngerDelay = GetGameTime() + 15.0;
		BlockLoseSay = false;
		npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 9999.0;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 10.0;
		f_MessengerSpeedUp[npc.index] = 1.0;
		i_SpeedUpTime[npc.index] = 0;
		npc.g_TimesSummoned = 0;
		
		b_thisNpcIsARaid[npc.index] = true;
		

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			f_khamlCutscene[npc.index] = GetGameTime() + 45.0;
			i_khamlCutscene[npc.index] = 14;
			i_RaidGrantExtra[npc.index] = 1;
			b_NpcUnableToDie[npc.index] = true;
		}

		if(StrContains(data, "fake_2") != -1)
		{
			MakeObjectIntangeable(npc.index);
			i_RaidGrantExtra[npc.index] = 2;
			b_DoNotUnStuck[npc.index] = true;
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_thisNpcIsARaid[npc.index] = true;
			npc.m_flNextChargeSpecialAttack = 0.0;
			b_NoKillFeed[npc.index] = true;
			b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
			npc.PlayTeleportSound();
		}
		else if(StrContains(data, "fake_3") != -1)
		{
			MakeObjectIntangeable(npc.index);
			i_RaidGrantExtra[npc.index] = 3;
			b_DoNotUnStuck[npc.index] = true;
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_thisNpcIsARaid[npc.index] = true;
			npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 10.0;
			npc.i_GunMode = 1;
			b_NoKillFeed[npc.index] = true;
			b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
			npc.PlayTeleportSound();
		}
		else if(StrContains(data, "fake_4") != -1)
		{
			MakeObjectIntangeable(npc.index);
			i_RaidGrantExtra[npc.index] = 4;
			b_DoNotUnStuck[npc.index] = true;
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_thisNpcIsARaid[npc.index] = true;
			npc.m_flRangedSpecialDelay = 0.0;
			b_NoKillFeed[npc.index] = true;
			b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
			npc.PlayTeleportSound();
		}
		else
		{
			RemoveAllDamageAddition();
			func_NPCFuncWin[npc.index] = view_as<Function>(ChaosKahmlstein_Win);
			SDKHook(npc.index, SDKHook_OnTakeDamagePost, ChaosKahmlstein_OnTakeDamagePost);
			EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0);	
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "item_armor", 1, "%t", "Chaos Kahmlstein Arrived");
				}
			}
			RaidModeTime = GetGameTime(npc.index) + 250.0;
			if(final)
			{
				RaidModeTime += 45.0;
				Music_SetRaidMusicSimple("vo/null.mp3", 30, false, 0.5);
			}
			else
			{
				bool TotalShits = StrContains(data, "no_music_blitz") != -1;
				if(!TotalShits)
				{
					CPrintToChatAll("{darkblue}Kahmlstein{default}: 해보자고.");
					MusicEnum music;
					strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/internius/chaos_reigns_loop.mp3");
					music.Time = 240;
					music.Volume = 1.2;
					music.Custom = true;
					strcopy(music.Name, sizeof(music.Name), "Chaos Reigns");
					strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
					Music_SetRaidMusic(music);
				}
				else
				{
					CPrintToChatAll("{darkblue}Kahmlstein{default}: 하하, 시작해볼까!!");
					f_MessengerSpeedUp[npc.index] *= 2.0;
				}
			}

			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;
					
			float value;
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			//the very first and 2nd char are SC for scaling
			if(buffers[0][0] == 's' && buffers[0][1] == 'c')
			{
				//remove SC
				ReplaceString(buffers[0], 64, "sc", "");
				value = StringToFloat(buffers[0]);
				RaidModeScaling = value;
			}
			else
			{	
				RaidModeScaling = float(Waves_GetRoundScale()+1);
				value = float(Waves_GetRoundScale()+1);
			}

			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
			}
			
			float amount_of_people = ZRStocks_PlayerScalingDynamic();
			if(amount_of_people > 12.0)
			{
				amount_of_people = 12.0;
			}
			amount_of_people *= 0.12;
			
			if(amount_of_people < 1.0)
				amount_of_people = 1.0;

			RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
			
			if(value > 25 && value < 35)
			{
				RaidModeScaling *= 0.85;
			}
			else if(value > 35)
			{
				RaidModeScaling *= 0.7;
			}
			RaidModeScaling *= 0.6;
		}

		
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

	//	Weapon
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_heavy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/Robo_Heavy_Chief/Robo_Heavy_Chief.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_chest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		int Alpha = 255;
		if(i_RaidGrantExtra[npc.index] >= 2)
			Alpha = 180;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 21, 71, 171, Alpha);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 21, 71, 171, Alpha);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 21, 71, 171, Alpha);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 21, 71, 171, Alpha);

//		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		float flPos[3]; // original
		float flAng[3]; // original
	
		npc.GetAttachment("effect_hand_r", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_r", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);

		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;

		SetVariantColor(view_as<int>({173, 216, 230, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		return npc;
	}
}

public void ChaosKahmlstein_ClotThink(int iNPC)
{
	ChaosKahmlstein npc = view_as<ChaosKahmlstein>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(b_angered_twice[npc.index])
	{
		BlockLoseSay = true;
		npc.m_bisWalking = false;
		npc.StopPathing();
		switch(ChaosKahmlsteinTalk(iNPC))
		{
			case 1:
			{
				int closestTarget = GetClosestAllyPlayer(npc.index);
				if(IsValidEntity(closestTarget))
				{
					float WorldSpaceVec[3]; WorldSpaceCenter(closestTarget, WorldSpaceVec);
					npc.FaceTowards(WorldSpaceVec, 100.0);
				}
			}
			case 2:
			{
				GiveProgressDelay(0.5);
				npc.m_bDissapearOnDeath = true;
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			}
		}
		return;
	}

	if(i_RaidGrantExtra[npc.index] == 1 && i_khamlCutscene[npc.index] != 0)
	{
		if(i_khamlCutscene[npc.index] == 14)
		{
			bool foundEm = false;
			float Pos[3];
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(entity != INVALID_ENT_REFERENCE && (b_thisNpcIsARaid[entity] && IsEntityAlive(entity) && entity != npc.index))
				{
					foundEm = true;
					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Pos);
					b_DissapearOnDeath[entity] = false;
					b_thisNpcIsARaid[entity] = false;
					SmiteNpcToDeath(entity);
				}
			}
			if(foundEm)
			{
				EmitSoundToAll("player/taunt_knuckle_crack.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("player/taunt_knuckle_crack.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("player/taunt_knuckle_crack.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("player/taunt_knuckle_crack.wav", _, _, _, _, 1.0);	
				b_NpcIsInvulnerable[npc.index] = true;
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",true);
				TeleportEntity(npc.index, Pos);
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				i_khamlCutscene[npc.index] = 13;
				CPrintToChatAll("{darkblue}Kahmlstein{default}: 너희룰 충분히 지켜보고 있었다. 그리고 그건 큰 실수였던것 같다. {crimson} 처음부터 이 상황에 개입을 했어야했는데.");
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/internius/chaos_reigns_intro.mp3");
				music.Time = 42;
				music.Volume = 1.65;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Chaos Reigns");
				strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
				Music_SetRaidMusic(music);
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						SetMusicTimer(client, GetTime() + 3);
					}
				}
			}
			else
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/internius/chaos_reigns_loop.mp3");
				music.Time = 240;
				music.Volume = 1.2;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Chaos Reigns");
				strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
				Music_SetRaidMusic(music);
				i_khamlCutscene[npc.index] = 0;
			}
		}
		float TimeLeft = f_khamlCutscene[npc.index] - GetGameTime();

		switch(i_khamlCutscene[npc.index])
		{
			case 13:
			{
				if(TimeLeft < 41.0)
				{
					
					MusicEnum music;
					strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/internius/chaos_reigns_loop.mp3");
					music.Time = 240;
					music.Volume = 1.2;
					music.Custom = true;
					strcopy(music.Name, sizeof(music.Name), "Chaos Reigns");
					strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
					Music_SetRaidMusic(music, false);
					i_khamlCutscene[npc.index] = 12;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 너. 와서 나와 정면으로 마주해라... {crimson} 아니면 겁 먹은거냐?");
				}
			}
			case 12:
			{
				if(TimeLeft < 37.0)
				{
					i_khamlCutscene[npc.index] = 11;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 싸구려 클론과는 잘만 싸우면서, 진짜 본체에게는 손 하나 못 대겠다고?");
				}
			}
			case 11:
			{
				if(TimeLeft < 33.0)
				{
					i_khamlCutscene[npc.index] = 10;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 넌 나의 사람들을 죽이고, {crimson}나의 강아지도 죽였다.{default} 그런데 이제 와서 날 두려워해?!");
				}
			}
			case 10:
			{
				if(TimeLeft < 30.0)
				{
					i_khamlCutscene[npc.index] = 9;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 난 모든 것을 태워서 재만 남을 때까지 태워버릴 것이다. 그리고 그 재에서...");
				}
			}
			case 9:
			{
				if(TimeLeft < 26.0)
				{
					i_khamlCutscene[npc.index] = 8;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 완전히 새로운 자유 세계가 탄생할 것이다!! 다시는 너희를 지배할 자가 없는 세계!");
				}
			}
			case 8:
			{
				if(TimeLeft < 22.0)
				{
					i_khamlCutscene[npc.index] = 7;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 정치인이라는 기생충을 제거한 세계! 정부로부터 자유로워지는 시대!");
				}
			}
			case 7:
			{
				if(TimeLeft < 18.0)
				{
					i_khamlCutscene[npc.index] = 6;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 그것이 이상적인 세계이자 낙원이다! 그러니 저항하지 말고 받아들여라!!");
				}
			}
			case 6:
			{
				if(TimeLeft < 12.0)
				{
					i_khamlCutscene[npc.index] = 5;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 아니, 생각해보니까 너는 그 시대를 볼 수 없겠군...");
				}
			}
			case 5:
			{
				if(TimeLeft < 9.0)
				{
					i_khamlCutscene[npc.index] = 4;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 내가 정부보다 더 싫어하는게 뭔지 아나? {crimson}동물 학대.");
				}
			}
			case 4:
			{
				if(TimeLeft < 4.0)
				{
					i_khamlCutscene[npc.index] = 3;
					CPrintToChatAll("{darkblue}캄르스타인{default}: {crimson}넌 아무 이유 없이 모든 동물들을 학대하고, 학살하고 다녔지.");
				}
			}
			case 3:
			{
				if(TimeLeft < 2.0)
				{
					i_khamlCutscene[npc.index] = 2;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 그리고 이제 이제 널 죽여서 그들의 원수를 갚을 시간이다...");
				}
			}
			case 2:
			{
				if(TimeLeft < 0.0)
				{
					i_khamlCutscene[npc.index] = 0;
					CPrintToChatAll("{darkblue}캄르스타인{default}: 그럼 해보자고.");
					RaidBossActive = EntIndexToEntRef(npc.index);
					RaidAllowsBuildings = false;
				}
				
			}
		}
		return;
	}
	b_NpcIsInvulnerable[npc.index] = false;
	if(LastMann && i_RaidGrantExtra[npc.index] < 2)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{darkblue}캄르스타인{default}: 네 몸 안의 뼈 하나 하나를 으깨주마.");
				}
				case 1:
				{
					CPrintToChatAll("{darkblue}캄르스타인{default}: 혼자서 혼돈에 맞서겠다는건 실로 멍청하기 짝이 없군.");
				}
				case 2:
				{
					CPrintToChatAll("{darkblue}캄르스타인{default}: 저 심해 밑바닥까지 끌고 가주지. 최대한 고통스럽게 죽게끔.");
				}
				case 3:
				{
					CPrintToChatAll("{darkblue}캄르스타인{default}: 블리츠크리그는 약해서 패배한 거야. {crimson}너처럼 말이다.");
				}
			}
		}
	}
	float RaidModeTimeLeft = RaidModeTime - GetGameTime();

	if(RaidModeTimeLeft < 190.0 && i_SpeedUpTime[npc.index] == 0)
	{
		i_SpeedUpTime[npc.index] = 1; 
		f_MessengerSpeedUp[npc.index] *= 1.15;
		if(i_RaidGrantExtra[npc.index] < 2)
			CPrintToChatAll("{darkblue}캄르스타인{default}: 그래. 좀 심심했지, 응?");
	}
	else if(RaidModeTimeLeft < 130.0 && i_SpeedUpTime[npc.index] == 1)
	{
		i_SpeedUpTime[npc.index] = 2; 
		f_MessengerSpeedUp[npc.index] *= 1.15;
		if(i_RaidGrantExtra[npc.index] < 2)
			CPrintToChatAll("{darkblue}캄르스타인{default}: 돌아가신 내 할머니가 너희보단 더 세겠군.");
	}
	else if(RaidModeTimeLeft < 70 && i_SpeedUpTime[npc.index] == 2)
	{
		i_SpeedUpTime[npc.index] = 3; 
		f_MessengerSpeedUp[npc.index] *= 1.1;
		if(i_RaidGrantExtra[npc.index] < 2)
			CPrintToChatAll("{darkblue}캄르스타인{default}:{crimson} 으하하하하!! 난 막을 수 없다!");
	}
	else if(RaidModeTimeLeft < 0.0 && i_SpeedUpTime[npc.index] == 3)
	{
		i_SpeedUpTime[npc.index] = 4; 
		f_MessengerSpeedUp[npc.index] *= 3.0;
		npc.m_flSpeed = 600.0;
		if(i_RaidGrantExtra[npc.index] < 2)
			CPrintToChatAll("{darkblue}캄르스타인{default}:{crimson} 전부 죽는다.");
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
	if(i_RaidGrantExtra[npc.index] >= 2)
	{
		if(!IsValidAlly(npc.index, npc.m_iTargetAlly))
		{
			SmiteNpcToDeath(npc.index);
		}
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + (0.1 * (1.0 / f_MessengerSpeedUp[npc.index]));

	if(i_RaidGrantExtra[npc.index] == 4)
	{
		if(ChaosKahmlstein_Attack_Melee_BodySlam_thing(npc, 0))
		{
			return;
		}
		return;
	}

	if(i_RaidGrantExtra[npc.index] == 2)
	{
		if(ChaosKahmlstein_Attack_Melee_Uppercut(npc, 0))
		{
			return;
		}
		return;
	}
	if(Kahmlstein_Attack_TempPowerup(npc))
		return;

	if(f_KahmlResTemp[npc.index] > GetGameTime())
	{
		if(NpcStats_IsEnemySilenced(npc.index))
		{
			npc.m_flMeleeArmor = 0.65;
			npc.m_flRangedArmor = 0.5;	
		}
		else
		{
			npc.m_flMeleeArmor = 0.75;
			npc.m_flRangedArmor = 0.6;	
		}
	}
	else
	{
		npc.m_flMeleeArmor = 1.25;
		npc.m_flRangedArmor = 1.0;	
	}	

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		if(i_RaidGrantExtra[npc.index] < 2)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		else
		{
			ChaosKahmlstein allynpc = view_as<ChaosKahmlstein>(npc.m_iTargetAlly);
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,allynpc.m_iTarget);
		}

		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(ChaosKahmlstein_Attack_Melee_Uppercut(npc, npc.m_iTarget))
			return;

		if(ChaosKahmlstein_Attack_Melee_BodySlam_thing(npc, npc.m_iTarget))
			return;

		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = ChaosKahmlsteinSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					NPC_SetGoalVector(npc.index, vPredictedPos);
					if(npc.m_flCharge_delay < GetGameTime(npc.index))
					{
						if(npc.IsOnGround() && flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
						{
							npc.PlayChargeSound();
							npc.m_flCharge_delay = GetGameTime(npc.index) +  (5.0 *(1.0 / f_MessengerSpeedUp[npc.index]));
							PluginBot_Jump(npc.index, vecTarget);
							float flPos[3];
							float flAng[3];
							int Particle_1;
							int Particle_2;
							npc.GetAttachment("foot_L", flPos, flAng);
							Particle_1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "foot_L", {0.0,0.0,0.0});
							
							npc.GetAttachment("foot_R", flPos, flAng);
							Particle_2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_red_crit", npc.index, "foot_R", {0.0,0.0,0.0});
							CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				//	ChaosKahmlstein_Attack_FingerPoint(npc);
				}
				else 
				{
					if(npc.m_flCharge_delay < GetGameTime(npc.index))
					{
						if(npc.IsOnGround())
						{
							float vPredictedPos[3];
							PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
							vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0 ,vPredictedPos);
							static float hullcheckmaxs[3];
							static float hullcheckmins[3];
							hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
							hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	

							float SelfPos[3];
							GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
							float AllyAng[3];
							GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
							
							bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, false);
							if(Succeed)
							{
								npc.PlayTeleportSound();
								ParticleEffectAt(SelfPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
								ParticleEffectAt(vPredictedPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
								float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
								npc.FaceTowards(VecEnemy, 15000.0);
								npc.m_flCharge_delay = GetGameTime(npc.index) +  (5.0 *(1.0 / f_MessengerSpeedUp[npc.index]));
							}
						}
					}
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		if(i_RaidGrantExtra[npc.index] < 2)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		else
		{
			ChaosKahmlstein allynpc = view_as<ChaosKahmlstein>(npc.m_iTargetAlly);
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,allynpc.m_iTarget);
		}
	}
	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		npc.m_flFixAttackCanceling = 0.0;
		ChaosKahmlsteinAnimationChange(npc);
	}
}

bool ChaosKahmlstein_Attack_Melee_Uppercut(ChaosKahmlstein npc, int Target)
{
	if(i_RaidGrantExtra[npc.index] < 2)
	{
		if(!npc.m_flAttackHappens_2 && npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index) && !npc.m_flFixAttackCanceling)
		{
			npc.PlayIdleAlertSound();
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + (15.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_the_fist_bump");
			npc.m_flAttackHappens = 0.0;
			npc.SetCycle(0.01);
			npc.SetPlaybackRate(f_MessengerSpeedUp[npc.index]);
			npc.m_flDoingAnimation = GetGameTime(npc.index) + (1.85 * (1.0 / f_MessengerSpeedUp[npc.index]));	
			npc.m_iOverlordComboAttack = 555;
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flAttackHappens_2 = GetGameTime(npc.index) + (0.7 * (1.0 / f_MessengerSpeedUp[npc.index]));
			npc.m_flFixAttackCanceling = 1.0;
		}
		if(npc.m_flAttackHappens_2 > GetGameTime(npc.index))
		{
			return true;
		}
	}
	if(i_RaidGrantExtra[npc.index] == 2 && npc.m_iOverlordComboAttack == 0)
	{
		npc.m_iOverlordComboAttack = 555;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + (35.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
	}
	if(npc.m_flNextChargeSpecialAttack > GetGameTime(npc.index) && npc.m_flAttackHappens_2 < GetGameTime(npc.index) && npc.m_iOverlordComboAttack == 555)
	{
		npc.m_flAttackHappens_2 = GetGameTime(npc.index) + (1.35 * (1.0 / f_MessengerSpeedUp[npc.index]));
		npc.m_iOverlordComboAttack = 666;
		if(Target > 0)
		{
			UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
			int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
			//It should target upto 20 people only, if its anymore it starts becomming un dodgeable due to the nature of AOE laser attacks
			GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false);
			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					Target = enemy[i];
					float vPredictedPos[3];
					PredictSubjectPosition(npc, Target,_,_, vPredictedPos);
					vPredictedPos = GetBehindTarget(Target, 30.0 ,vPredictedPos);
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];
					hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
					hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	

					float SelfPos[3];
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
					float AllyAng[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
					
					bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, false, false);
					if(Succeed)
					{
						ParticleEffectAt(SelfPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						ParticleEffectAt(vPredictedPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						float WorldSpaceVec[3]; WorldSpaceCenter(Target, WorldSpaceVec);
						npc.FaceTowards(WorldSpaceVec, 15000.0);

						if(i_RaidGrantExtra[npc.index] < 2)
						{
							CreateCloneTempKahmlsteinFakeout(npc.index, 2, vPredictedPos, AllyAng);
						}

						SDKCall_SetLocalOrigin(npc.index, SelfPos);	
					}
				}
			}

		}
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + (25.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_bare_knuckle_beatdown_outro");
		npc.m_flAttackHappens = 0.0;
		npc.SetCycle(0.01);
		npc.SetPlaybackRate(f_MessengerSpeedUp[npc.index] * 0.50);
		npc.m_iOverlordComboAttack = 666;
		npc.m_iChanged_WalkCycle = 0;
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float damage = 70.0;
		int Enemypunch = npc.m_iTarget;
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			Enemypunch = GetClosestTarget(npc.index);
		}
		if(IsValidEnemy(npc.index, Enemypunch))
		{
			float vecThem[3]; WorldSpaceCenter(Enemypunch, vecThem );
			vecThem[2] += 35.0;
			KahmlsteinInitiatePunch(npc.index, vecThem, vecMe, (1.0 * (1.0 / f_MessengerSpeedUp[npc.index])) , damage * RaidModeScaling, false, 250.0);
		}
	}

	if(npc.m_flAttackHappens_2)
	{
		//one second into the ability
		if(npc.m_flAttackHappens_2 < GetGameTime(npc.index))
		{
			if(i_RaidGrantExtra[npc.index] >= 2)
			{
				SmiteNpcToDeath(npc.index);
			}
			npc.m_flAttackHappens_2 = 0.0;
		}
		return true;
	}
	return false;
}




bool ChaosKahmlstein_Attack_Melee_BodySlam_thing(ChaosKahmlstein npc, int Target)
{
	if(!npc.m_flInJump && npc.m_flRangedSpecialDelay < GetGameTime(npc.index) && !npc.m_flFixAttackCanceling)
	{
		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + (15.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_yetipunch");
		npc.m_flAttackHappens = 0.0;
		if(i_RaidGrantExtra[npc.index] < 2)
		{
			npc.SetCycle(0.35);
			npc.PlayIdleAlertSound();
		}
		else
			npc.SetCycle(0.55);
		npc.m_flFixAttackCanceling = 1.0;
		npc.SetPlaybackRate(1.2 *f_MessengerSpeedUp[npc.index]);
		npc.m_flDoingAnimation = GetGameTime(npc.index) + (1.85 * (1.0 / f_MessengerSpeedUp[npc.index]));	
		npc.m_iOverlordComboAttack = 5555;
		npc.m_iChanged_WalkCycle = 0;
		if(i_RaidGrantExtra[npc.index] < 2)
			npc.m_flInJump = GetGameTime(npc.index) + (0.7 * (1.0 / f_MessengerSpeedUp[npc.index]));

		npc.m_flInJump = GetGameTime(npc.index) + (0.7 * (1.0 / f_MessengerSpeedUp[npc.index]));
	}
	if(i_RaidGrantExtra[npc.index] == 4 && npc.m_iOverlordComboAttack == 0)
	{
		npc.m_iOverlordComboAttack = 5555;
		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + (35.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
	}
	if(npc.m_flRangedSpecialDelay > GetGameTime(npc.index) && (npc.m_flInJump < GetGameTime(npc.index) || i_RaidGrantExtra[npc.index] == 4) && npc.m_iOverlordComboAttack == 5555)
	{
		if(Target > 0)
		{
			UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
			int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
			//It should target upto 20 people only, if its anymore it starts becomming un dodgeable due to the nature of AOE laser attacks
			GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false);
			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					Target = enemy[i];
					float vPredictedPos[3];
					PredictSubjectPosition(npc, Target,_,_, vPredictedPos);
					vPredictedPos = GetBehindTarget(Target, 30.0 ,vPredictedPos);
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];
					hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
					hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	

					float SelfPos[3];
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
					float AllyAng[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
					
					bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, false, false);
					if(Succeed)
					{
						ParticleEffectAt(SelfPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						ParticleEffectAt(vPredictedPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						float WorldSpaceVec[3]; WorldSpaceCenter(Target, WorldSpaceVec);
						npc.FaceTowards(WorldSpaceVec, 15000.0);

						if(i_RaidGrantExtra[npc.index] < 2)
						{
							CreateCloneTempKahmlsteinFakeout(npc.index, 4, vPredictedPos, AllyAng);
						}

						SDKCall_SetLocalOrigin(npc.index, SelfPos);	
					}
				}
			}

		}
		npc.m_iOverlordComboAttack = 6666;
		npc.m_flAttackHappens = 0.0;
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float damage = 80.0;
		int Enemypunch = npc.m_iTarget;
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			Enemypunch = GetClosestTarget(npc.index);
		}
		if(IsValidEnemy(npc.index, Enemypunch))
		{
			float vecThem[3]; WorldSpaceCenter(Enemypunch, vecThem );
			vecThem[2] += 35.0;
			KahmlsteinInitiatePunch(npc.index, vecThem, vecMe, (1.0 * (1.0 / f_MessengerSpeedUp[npc.index])) , damage * RaidModeScaling, false, 300.0);
		}
	}

	if(npc.m_flInJump)
	{
		//one second into the ability
		if(npc.m_flInJump < GetGameTime(npc.index))
		{
			if(i_RaidGrantExtra[npc.index] >= 2)
			{
				SmiteNpcToDeath(npc.index);
			}
			npc.m_flInJump = 0.0;
		}
		return true;
	}
	return false;
}

public Action ChaosKahmlstein_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChaosKahmlstein npc = view_as<ChaosKahmlstein>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if(GetTeam(npc.index) != TFTeam_Red && !b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 1)
	{
		if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			b_angered_twice[npc.index] = true;
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(32.0);
			damage = 0.0;
			RaidModeTime += 60.0;
			f_TalkDelayCheck = GetGameTime() + 0.0;
			ReviveAll(true);
			CPrintToChatAll("{darkblue}캄르스타인{default}: 으... 내 머리.");
			Music_SetRaidMusicSimple("vo/null.mp3", 60, false, 0.5);
			return Plugin_Handled;
		}
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		
	
	if(weapon > 0)
	{
		if(!b_khamlWeaponRage[npc.index])
		{
			if(i_CustomWeaponEquipLogic[weapon] == WEAPON_KAHMLFIST)
			{
				b_khamlWeaponRage[npc.index] = true;
				CPrintToChatAll("{darkblue}캄르스타인{default}: 지금 네 놈이 날 상대로 내 주먹을 쓰겠다는거냐? 웃기는군.");
			}
		}
	}
	return Plugin_Changed;
}

public void ChaosKahmlstein_NPCDeath(int entity)
{
	ChaosKahmlstein npc = view_as<ChaosKahmlstein>(entity);
	/*
		Explode on death code here please

	*/
		
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

	if(i_RaidGrantExtra[npc.index] >= 2)
		return;

	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

	RaidBossActive = INVALID_ENT_REFERENCE;
	if(BlockLoseSay)
		return;

	if(i_RaidGrantExtra[npc.index] != 1)
	{
		CPrintToChatAll("{darkblue}캄르스타인{default}: 잘했군, 좀 더 완벽하게 대응했어야했어.");
	}
}
/*


*/
void ChaosKahmlsteinAnimationChange(ChaosKahmlstein npc)
{
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
				// ResetChaosKahmlsteinWeapon(npc, 1);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
				//	ResetChaosKahmlsteinWeapon(npc, 1);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
				//	ResetChaosKahmlsteinWeapon(npc, 0);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
					if(!IsValidEntity(npc.m_iWearable1))
					{
						npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
						SetVariantString("1.0");
						AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					}
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
				//	ResetChaosKahmlsteinWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
					if(!IsValidEntity(npc.m_iWearable1))
					{
						npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
						SetVariantString("1.0");
						AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					}
				}	
			}
		}
	}

}

int ChaosKahmlsteinSelfDefense(ChaosKahmlstein npc, float gameTime, int target, float distance)
{
	if(npc.i_GunMode == 1)
	{
		if(gameTime > npc.m_flNextMeleeAttack)
		{
			if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.5))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",true, 0.09, _, 4.0 * f_MessengerSpeedUp[npc.index]);
					npc.m_iTarget = Enemy_I_See;
					npc.PlayRangedSound();
					float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
					npc.FaceTowards(vecTarget, 20000.0);
					int projectile;
					float Proj_Damage = 10.0 * RaidModeScaling;
					vecTarget[0] += GetRandomFloat(-10.0, 10.0);
					vecTarget[1] += GetRandomFloat(-10.0, 10.0);
					vecTarget[2] += GetRandomFloat(-10.0, 10.0);
					switch(GetRandomInt(1,2))
					{
						case 1:
						{
							projectile = npc.FireParticleRocket(vecTarget, Proj_Damage, 1200.0, 150.0, "raygun_projectile_blue_crit", false);
						}
						case 2:
						{
							projectile = npc.FireParticleRocket(vecTarget, Proj_Damage, 1200.0, 150.0, "raygun_projectile_red_crit", false);
						}
					}
			
					SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
					int particle = EntRefToEntIndex(i_rocket_particle[projectile]);
					CreateTimer(3.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(3.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
					
					SDKHook(projectile, SDKHook_StartTouch, TheMessenger_Rocket_Particle_StartTouch);		
					
				}
				if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.5))
				{
					//target is too far, try to close in
					return 0;
				}
				else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						//target is too close, try to keep distance
						return 1;
					}
				}
				return 0;
			}
			else
			{
				if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.5))
				{
					//target is too far, try to close in
					return 0;
				}
				else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						//target is too close, try to keep distance
						return 1;
					}
				}
			}
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
		}
	}
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(targetTrace, vecHit);

							float damage = 24.0;
							damage *= 1.2;

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
								
							
							// Hit particle
							
							bool Knocked = false;
										
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 900.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
								else
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}

							Elemental_AddChaosDamage(targetTrace, npc.index, 100, true, true);

							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 650.0); 
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}
	//Melee attack, last prio
	else if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",true, 1.0, _, f_MessengerSpeedUp[npc.index]);
							
					npc.m_flAttackHappens = gameTime + (0.25 * (1.0 / f_MessengerSpeedUp[npc.index]));
					npc.m_flNextMeleeAttack = gameTime + (0.7 * (1.0 / f_MessengerSpeedUp[npc.index]));
					npc.m_flDoingAnimation = gameTime + (0.25 * (1.0 / f_MessengerSpeedUp[npc.index]));
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
	return 0;
}

public void ChaosKahmlstein_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	ChaosKahmlstein npc = view_as<ChaosKahmlstein>(victim);
	if(npc.g_TimesSummoned < 100)
	{
		int nextLoss = (ReturnEntityMaxHealth(npc.index) / 10) * (100 - npc.g_TimesSummoned) / 100;
		if((GetEntProp(npc.index, Prop_Data, "m_iHealth") / 10) < nextLoss)
		{
			npc.g_TimesSummoned++;
			if((npc.g_TimesSummoned % 25) == 0)
			{
				f_MessengerSpeedUp[npc.index] *= 1.05;
				RaidModeScaling *= 1.05;
				switch(GetRandomInt(0,3))
				{
					case 0:
					{
						CPrintToChatAll("{darkblue}캄르스타인{default}: 참 간지러운 공격이군.");
					}
					case 1:
					{
						CPrintToChatAll("{darkblue}캄르스타인{default}: 어이구 무서워라.");
					}
					case 2:
					{
						CPrintToChatAll("{darkblue}캄르스타인{default}: 벌레가 너보단 더 세게 문다.");
					}
					case 3:
					{
						CPrintToChatAll("{darkblue}캄르스타인{default}: 도망가시던가. 그게 네 팀한테 더 도움된다.");
					}
				}
				f_KahmlResTemp[npc.index] = GetGameTime() + 3.5;
			}
			npc.m_flNextChargeSpecialAttack -= 0.25;
			npc.m_flRangedSpecialDelay -= 0.25;
			npc.m_flCharge_delay -= 0.05;
		}
	}

	if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		f_MessengerSpeedUp[npc.index] *= 1.15;
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 그것보다 더 세게 나갔어야지.");
			}
			case 1:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 한심한 놈.");
			}
			case 2:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 멍청한 놈들.");
			}
			case 3:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 네 잔혹함은 국가들보다 더 심하다.");
			}
		}
		RaidModeScaling *= 1.2;
		npc.g_TimesSummoned = 100;
		npc.Anger = true;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 0.0;
		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 0.0;
		npc.m_flSpeed = 340.0;
	}
}



void CreateCloneTempKahmlsteinFakeout(int entity, int TypeOfFake, float SelfPos[3], float AllyAng[3])
{
	int KamlcloneSpawn;
	
	switch(TypeOfFake)
	{
		case 2:
		{
			KamlcloneSpawn = NPC_CreateById(NPCId, -1, SelfPos, AllyAng, GetTeam(entity), "fake_2"); //can only be enemy
		}
		case 3:
		{
			KamlcloneSpawn = NPC_CreateById(NPCId, -1, SelfPos, AllyAng, GetTeam(entity), "fake_3"); //can only be enemy
		}
		case 4:
		{
			KamlcloneSpawn = NPC_CreateById(NPCId, -1, SelfPos, AllyAng, GetTeam(entity), "fake_4"); //can only be enemy
		}
	}
	if(IsValidEntity(KamlcloneSpawn))
	{
		MakeObjectIntangeable(KamlcloneSpawn);
		b_DoNotUnStuck[KamlcloneSpawn] = true;
		b_NpcIsInvulnerable[KamlcloneSpawn] = true;
		b_ThisNpcIsImmuneToNuke[KamlcloneSpawn] = true;
		b_NoKnockbackFromSources[KamlcloneSpawn] = true;
		b_ThisEntityIgnored[KamlcloneSpawn] = true;
		b_thisNpcIsARaid[KamlcloneSpawn] = true;
		i_RaidGrantExtra[KamlcloneSpawn] = TypeOfFake;
		ChaosKahmlstein npc = view_as<ChaosKahmlstein>(KamlcloneSpawn);
		npc.m_iTargetAlly = entity;
		f_MessengerSpeedUp[KamlcloneSpawn] = f_MessengerSpeedUp[entity];
	}
}


#define KAHML_MELEE_SIZE 50
#define KAHML_MELEE_SIZE_F 50.0


void KahmlsteinInitiatePunch(int entity, float VectorTarget[3], float VectorStart[3], float TimeUntillHit, float damage, bool kick, float RangeOfPunch)
{

	ChaosKahmlstein npc = view_as<ChaosKahmlstein>(entity);
	npc.PlayBobMeleePreHit();
	npc.FaceTowards(VectorTarget, 20000.0);
	int FramesUntillHit = RoundToNearest(TimeUntillHit * float(TickrateModifyInt) * ReturnEntityAttackspeed(entity));

	float vecForward[3], Angles[3];

	GetVectorAnglesTwoPoints(VectorStart, VectorTarget, Angles);

	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);

	float VectorTarget_2[3];
	float VectorForward = RangeOfPunch; //a really high number.
	
	VectorTarget_2[0] = VectorStart[0] + vecForward[0] * VectorForward;
	VectorTarget_2[1] = VectorStart[1] + vecForward[1] * VectorForward;
	VectorTarget_2[2] = VectorStart[2] + vecForward[2] * VectorForward;


	int red = 25;
	int green = 25;
	int blue = 255;
	int Alpha = 255;

	int colorLayer4[4];
	float diameter = float(BOB_MELEE_SIZE * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	int glowColor[4];

	for(int BeamCube = 0; BeamCube < 4 ; BeamCube++)
	{
		float OffsetFromMiddle[3];
		switch(BeamCube)
		{
			case 0:
			{
				OffsetFromMiddle = {0.0, BOB_MELEE_SIZE_F,BOB_MELEE_SIZE_F};
			}
			case 1:
			{
				OffsetFromMiddle = {0.0, -BOB_MELEE_SIZE_F,-BOB_MELEE_SIZE_F};
			}
			case 2:
			{
				OffsetFromMiddle = {0.0, BOB_MELEE_SIZE_F,-BOB_MELEE_SIZE_F};
			}
			case 3:
			{
				OffsetFromMiddle = {0.0, -BOB_MELEE_SIZE_F,BOB_MELEE_SIZE_F};
			}
		}
		float AnglesEdit[3];
		AnglesEdit[0] = Angles[0];
		AnglesEdit[1] = Angles[1];
		AnglesEdit[2] = Angles[2];

		float VectorStartEdit[3];
		VectorStartEdit[0] = VectorStart[0];
		VectorStartEdit[1] = VectorStart[1];
		VectorStartEdit[2] = VectorStart[2];

		float VectorStartEdit_2[3];
		VectorStartEdit_2[0] = VectorTarget_2[0];
		VectorStartEdit_2[1] = VectorTarget_2[1];
		VectorStartEdit_2[2] = VectorTarget_2[2];

		GetBeamDrawStartPoint_Stock(entity, VectorStartEdit,OffsetFromMiddle, AnglesEdit);
		GetBeamDrawStartPoint_Stock(entity, VectorStartEdit_2,OffsetFromMiddle, AnglesEdit);

		SetColorRGBA(glowColor, red, green, blue, Alpha);
		TE_SetupBeamPoints(VectorStartEdit, VectorStartEdit_2, Shared_BEAM_Laser, 0, 0, 0, TimeUntillHit * ReturnEntityAttackspeed(entity), ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.0, glowColor, 0);
		TE_SendToAll(0.0);
	}
	
	
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget_2[0]);
	pack.WriteFloat(VectorTarget_2[1]);
	pack.WriteFloat(VectorTarget_2[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	pack.WriteFloat(damage);
	pack.WriteCell(kick);
	RequestFrames(KahmlsteinInitiatePunch_DamagePart, FramesUntillHit, pack);
}

void KahmlsteinInitiatePunch_DamagePart(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	for (int i = 1; i < MAXENTITIES; i++)
	{
		LaserVarious_HitDetection[i] = false;
	}
	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();
	float damagedata = pack.ReadFloat();
	bool kick = pack.ReadCell();

	int red = 50;
	int green = 50;
	int blue = 255;
	int Alpha = 222;
	int colorLayer4[4];

	float diameter = float(BOB_MELEE_SIZE * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(BOB_MELEE_SIZE);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	ChaosKahmlstein npc = view_as<ChaosKahmlstein>(entity);
	npc.PlayBobMeleePostHit();

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Sensal_BEAM_TraceUsers_3, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	KillFeed_SetKillIcon(entity, kick ? "mantreads" : "fists");

	if(NpcStats_IsEnemySilenced(entity))
		kick = false;
	
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (LaserVarious_HitDetection[victim] && GetTeam(entity) != GetTeam(victim))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float damage = damagedata;

			if(victim > MaxClients) //make sure barracks units arent bad
				damage *= 0.35;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_CLUB, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
			
			if(kick)
			{
				if(victim <= MaxClients)
				{
					hullMin[0] = 0.0;
					hullMin[1] = 0.0;
					hullMin[2] = 400.0;
					TeleportEntity(victim, _, _, hullMin, true);
				}
				else if(!b_NpcHasDied[victim])
				{
					FreezeNpcInTime(victim, 1.5);
					
					WorldSpaceCenter(victim, hullMin);
					hullMin[2] += 100.0; //Jump up.
					PluginBot_Jump(victim, hullMin);
				}
			}
		}
	}
	delete pack;

	KillFeed_SetKillIcon(entity, "tf_projectile_rocket");
}


public bool Sensal_BEAM_TraceUsers_3(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		LaserVarious_HitDetection[entity] = true;
	}
	return false;
}



bool Kahmlstein_Attack_TempPowerup(ChaosKahmlstein npc)
{
	if(!npc.m_flNextRangedBarrage_Spam && npc.m_flJumpCooldown < GetGameTime(npc.index) && !npc.m_flFixAttackCanceling)
	{
		npc.m_flJumpCooldown = GetGameTime(npc.index) + (35.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_bare_knuckle_beatdown");
		npc.m_flAttackHappens = 0.0;
		npc.SetCycle(0.01);
		npc.SetPlaybackRate(f_MessengerSpeedUp[npc.index]);
		npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + (1.85 * (1.0 / f_MessengerSpeedUp[npc.index]));	
		npc.m_flDoingAnimation = GetGameTime(npc.index) + (1.85 * (1.0 / f_MessengerSpeedUp[npc.index]));	
		npc.m_iOverlordComboAttack = 0;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + (10.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
		EmitSoundToAll("mvm/mvm_tank_horn.wav");
		npc.m_flFixAttackCanceling = 1.0;
	}
	if(npc.m_flNextRangedBarrage_Spam)
	{

		if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index))
		{
			if(i_RaidGrantExtra[npc.index] == 3)
			{
				SmiteNpcToDeath(npc.index);
			}
			npc.i_GunMode = 0;
			npc.m_flNextRangedBarrage_Spam = 0.0;
		}
	}
	if(npc.m_flNextRangedBarrage_Singular)
	{
		float TimeUntillOver = npc.m_flNextRangedBarrage_Singular - GetGameTime(npc.index);

		if(TimeUntillOver < (1.2 * (1.0 / f_MessengerSpeedUp[npc.index])))
		{
			if(npc.m_iOverlordComboAttack != 1)
			{
				npc.m_iOverlordComboAttack = 1;
			}
		}
		if(npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index))
		{
			npc.i_GunMode = 1;
			npc.m_flNextRangedBarrage_Singular = 0.0;
			float SelfPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
			float AllyAng[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
			CreateCloneTempKahmlsteinFakeout(npc.index, 3, SelfPos, AllyAng);
		}
		return true;
	}
	return false;
}


public void ChaosKahmlstein_Win(int entity)
{
	switch(GetRandomInt(0,2))
	{
		case 0:
		{
			CPrintToChatAll("{darkblue}캄르스타인{default}: 넌 이제 아무것도 아니다.");
		}
		case 1:
		{
			CPrintToChatAll("{darkblue}캄르스타인{default}: 모든 것이 전부 불타리라.");
		}
		case 2:
		{
			CPrintToChatAll("{darkblue}캄르스타인{default}: 혼돈은 다시 일어나리라.");
		}
	}
}


int ChaosKahmlsteinTalk(int iNPC)
{
	ChaosKahmlstein npc = view_as<ChaosKahmlstein>(iNPC);
	if(i_TalkDelayCheck == 15)
	{
		return 2;
	}
	if(f_TalkDelayCheck < GetGameTime())
	{
		f_TalkDelayCheck = GetGameTime() + 5.0;
		RaidModeTime += 10.0; //cant afford to delete it, since duo.
		GiveProgressDelay(10.0);
		switch(i_TalkDelayCheck)
		{
			case 0:
			{
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("taunt_heavy_workout_end");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.25);
				npc.SetPlaybackRate(0.0);
				i_TalkDelayCheck += 1;
			}
			case 1:
			{
				f_TalkDelayCheck = GetGameTime() + 2.3;
				npc.SetPlaybackRate(0.5);
				CPrintToChatAll("{darkblue}캄르스타인{default}: 마치 어깨에 앉아있던 무거운 무언가가 떠나간 듯한 같은 느낌이야.");
				i_TalkDelayCheck += 1;
			}
			case 2:
			{
				npc.m_bisWalking = false;
				npc.SetActivity("ACT_MP_STAND_MELEE");
				CPrintToChatAll("{darkblue}캄르스타인{default}: 혼돈이 나를 완전히 떠나간 모양이군.");
				i_TalkDelayCheck += 1;
			}
			case 3:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 하지만 내가 저질렀던 모든 일들은 잊히지 않아.");
				i_TalkDelayCheck += 1;
			}
			case 4:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 하지만 시간을 되돌릴 수도 없고, 이미 엎질러진 물이다.");
				i_TalkDelayCheck += 1;
			}
			case 5:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 그래. 혼돈을 조사해보려는게 큰 실수였던거야.");
				i_TalkDelayCheck += 1;
			}
			case 6:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 아무래도 혼돈은 나를 미쳐 날뛰기에 최적의 대상으로 삼은것 같다.");
				i_TalkDelayCheck += 1;
			}
			case 7:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 호기심이 고양이를 죽인다더니.");
				i_TalkDelayCheck += 1;
			}
			case 8:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 너도 내 경고를 주의 깊게 여겨라.");
				i_TalkDelayCheck += 1;
			}
			case 9:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 혼돈과 관련된 문제는 절대적으로 피해라. 그렇지 않으면 너도 나처럼 될테니.");
				i_TalkDelayCheck += 1;
			}
			case 10:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 만약 그것과 어떻게든 싸우고 싶다면, 나와 함께 하자.");
				i_TalkDelayCheck += 1;
			}
			case 11:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 그리고 한 가지 조언은, 절대 네 자신을 잃지 말도록.");
				i_TalkDelayCheck += 1;
			}
			case 12:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 자, 이걸 가져가라. 네 손에 있으면 안전할 거다..");
				i_TalkDelayCheck += 1;
				for (int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
					{
						Items_GiveNamedItem(client, "Kahml's Contained Chaos");
						CPrintToChat(client,"{default}당신이 얻은 것은... : {red}''격리된 캄르스타인의 혼돈''{default}!");
					}
				}
			}
			case 13:
			{
				CPrintToChatAll("{darkblue}캄르스타인{default}: 지금은 해야할 일이 있지, {crimson}끝내지 못한 그 일.{default}");
				i_TalkDelayCheck += 1;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("taunt_cyoa_PDA_intro");
				npc.SetCycle(0.05);
				f_TalkDelayCheck = GetGameTime() + 1.5;
				if(IsValidEntity(npc.m_iWearable1))
				{
					RemoveEntity(npc.m_iWearable1);
				}
				npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/cyoa_pda/cyoa_pda.mdl");
			}
			case 14:
			{
				i_TalkDelayCheck = 15;
			}
		}
	}
	if(i_TalkDelayCheck >= 2)
	{
		return 1;
	}
	return 0;
}