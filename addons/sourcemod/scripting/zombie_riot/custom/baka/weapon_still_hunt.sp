#pragma semicolon 1
#pragma newdecls required

static int i_Still_HuntParticle[MAXTF2PLAYERS];
static Handle Still_HuntTimer[MAXTF2PLAYERS+1] = {null, ...};
static int Still_Hunt_Pap[MAXTF2PLAYERS+1];
static int Still_Hunt_Pap_Save[MAXTF2PLAYERS+1];
static int Still_Hunt_charges[MAXTF2PLAYERS+1];
static int CaydeRetribution_Ammo[MAXTF2PLAYERS+1];
static int CaydeRetribution_charges[MAXTF2PLAYERS+1];
static float CaydeRetribution_duration[MAXTF2PLAYERS+1];
static int CaydeRetribution_End[MAXTF2PLAYERS+1];
static int CaydeRetribution_Original[MAXTF2PLAYERS+1];
static float fl_hud_timer[MAXTF2PLAYERS+1];

public void Still_Hunt_MapStart()
{
	if(FileExists("sound/baka_zr/goldengun_sfx.mp3", true))
		PrecacheSound("baka_zr/goldengun_sfx.mp3", true);
	Zero(fl_hud_timer);
	Zero(Still_Hunt_charges);
	Zero(CaydeRetribution_Ammo);
	Zero(CaydeRetribution_charges);
	Zero(CaydeRetribution_duration);
	Zero(Still_HuntTimer);
	Zero(CaydeRetribution_End);
	Zero(CaydeRetribution_Original);
}

public void Still_Hunt_Enable(int client, int weapon)
{
	if(Still_HuntTimer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_STILLHUNT)
		{
			Still_Hunt_Pap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			delete Still_HuntTimer[client];
			Still_HuntTimer[client] = null;
			DataPack pack;
			Still_HuntTimer[client] = CreateDataTimer(0.1, Timer_Still_Hunt, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_STILLHUNT)
	{
		Still_Hunt_Pap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
		DataPack pack;
		Still_HuntTimer[client] = CreateDataTimer(0.1, Timer_Still_Hunt, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_Still_Hunt(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Still_HuntTimer[client] = null;
		return Plugin_Stop;
	}

	float GameTime = GetGameTime();
	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon || weapon_holding == EntRefToEntIndex(CaydeRetribution_End[client])) //Only show if the weapon is actually in your hand right now.
	{
		Still_Hunt_Hud(client, GameTime);
		if(TF2_IsPlayerInCondition(client, TFCond_Zoomed)) TF2_AddCondition(client, TFCond_FocusBuff, 0.2);
		if(CaydeRetribution_duration[client] > GameTime + 0.5)
		{
			if(Still_Hunt_Pap_Save[client] == 4 && CaydeRetribution_Ammo[client] >= 6)
				CaydeRetribution_duration[client] = GameTime + 0.5;
			else if(Still_Hunt_Pap_Save[client] == 3 && CaydeRetribution_Ammo[client] >= 1)
				CaydeRetribution_duration[client] = GameTime + 0.5;
			else if(Still_Hunt_Pap_Save[client] < 3 && CaydeRetribution_Ammo[client] >= 3)
				CaydeRetribution_duration[client] = GameTime + 0.5;
		}
	}

	return Plugin_Continue;
}

static void Still_Hunt_Hud(int client, float GameTime)
{
	if(fl_hud_timer[client] > GameTime)
	{
		return;
	}
	fl_hud_timer[client] = GameTime+0.5;

	char HUDText[255] = "";

	if(CaydeRetribution_duration[client] < GameTime)
	{
		int MaxCharge=(Items_HasNamedItem(client, "Head Equipped Blue Goggles") ? 6 : 7);
		if(Still_Hunt_charges[client] >= MaxCharge)
			Format(HUDText, sizeof(HUDText), "%sCayde's Retribution Ready!", HUDText);
		else
			Format(HUDText, sizeof(HUDText), "%sCayde's Retribution Charges: [%i/%i]", HUDText, Still_Hunt_charges[client], MaxCharge);
	}
	else
	{
		float Duration = CaydeRetribution_duration[client]-GameTime;
		if(Still_Hunt_Pap_Save[client] == 4)
			Format(HUDText, sizeof(HUDText), "%sAmmo: %i ", HUDText, 6-CaydeRetribution_Ammo[client]);
		else if(Still_Hunt_Pap_Save[client] == 3)
			Format(HUDText, sizeof(HUDText), "%sAmmo: %i ", HUDText, 1-CaydeRetribution_Ammo[client]);
		else
			Format(HUDText, sizeof(HUDText), "%sAmmo: %i ", HUDText, 3-CaydeRetribution_Ammo[client]);
		Format(HUDText, sizeof(HUDText), "%s[%.1f]", HUDText, Duration);
	}
	PrintHintText(client, HUDText);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
}

public void Still_Hunt_Secondary_Attack(int client, int weapon, bool crit, int slot)
{
	int MaxCharge=(Items_HasNamedItem(client, "Head Equipped Blue Goggles") ? 6 : 7);
	if(Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		if(Still_Hunt_charges[client] >= MaxCharge && !IsValidEntity(EntRefToEntIndex(CaydeRetribution_End[client])))
		{
			Rogue_OnAbilityUse(client, weapon);
			CaydeRetribution_Original[client] = EntIndexToEntRef(weapon);
			float Time = GetGameTime();
			float duration = 14.5+float(Still_Hunt_Pap[client]);
			if(Still_Hunt_Pap[client] == 4)duration -= 8.0;
			Still_Hunt_Pap_Save[client] = Still_Hunt_Pap[client];
			Rogue_OnAbilityUse(client, weapon);
			CaydeRetribution_duration[client] = Time + duration;
			Still_Hunt_charges[client]=0;
			CaydeRetribution_Ammo[client]=0;
			CaydeRetribution_charges[client]=0;
			char name[32];
			GetClientName(client, name, sizeof(name));
			int entity = EntRefToEntIndex(i_Still_HuntParticle[client]);
			if(!IsValidEntity(entity))
			{
				float flPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
				int particle = ParticleEffectAt(flPos, "medic_radiusheal_red_spikes", 0.0);
				SetParent(client, particle, "m_vecAbsOrigin");
				i_Still_HuntParticle[client] = EntIndexToEntRef(particle);
			}
			MakePlayerGiveResponseVoice(client, 1);
			int CaydeRetribution = Store_GiveSpecificItem(client, "Weapon CaydeRetribution");
			EmitSoundToAll("baka_zr/goldengun_sfx.mp3", client, SNDCHAN_AUTO, 75,_,1.0,100);
			Attributes_Set(CaydeRetribution, 2, Attributes_Get(weapon, 2, 1.0));
			if(Still_Hunt_Pap_Save[client] == 4)Attributes_Set(CaydeRetribution, 6, 0.2);
			Attributes_Set(CaydeRetribution, 391, Attributes_Get(weapon, 391, 0.0));
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", CaydeRetribution);
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", Time+1.5);
			SetEntPropFloat(CaydeRetribution, Prop_Send, "m_flNextPrimaryAttack", Time+1.5);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", Time+1.5);
			CaydeRetribution_End[client] = EntIndexToEntRef(CaydeRetribution);
			SDKUnhook(client, SDKHook_PreThink, CaydeRetribution_Think);
			SDKHook(client, SDKHook_PreThink, CaydeRetribution_Think);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Not enough energy");
			return;
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		return;
	}
}

public void CaydeRetribution_Think(int client)
{
	if(CaydeRetribution_duration[client] < GetGameTime())
	{
		Store_RemoveSpecificItem(client, "Weapon CaydeRetribution");
		int WeaponIslive = EntRefToEntIndex(CaydeRetribution_End[client]);
		int WeaponOriginal = EntRefToEntIndex(CaydeRetribution_Original[client]);
		if(IsValidEntity(WeaponIslive))
			TF2_RemoveItem(client, WeaponIslive);
		if(IsValidEntity(WeaponOriginal))
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", WeaponOriginal);
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
		Still_Hunt_charges[client]=0;
		CaydeRetribution_Ammo[client]=0;
		CaydeRetribution_charges[client]=0;
		Ability_Apply_Cooldown(client, 3, 25.0);
		DestroyStill_Hunt_Effect(client);
		SDKUnhook(client, SDKHook_PreThink, CaydeRetribution_Think);
		return;
	}
	else
	{
		Ability_Apply_Cooldown(client, 3, (Still_Hunt_Pap_Save[client] == 4 ? 20.0 : 25.0));
		Still_Hunt_charges[client]=0;
	}
}

public void Still_Hunt_Primary_Attack(int client, int weapon, bool crit)
{
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	bool headshot = false;
	float pos[3], ang[3], endPos[3], vicLoc[3], hitPos[3], direction[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, 9999.0);
	AddVectors(pos, direction, endPos);
	int victim;
	Handle trace = TR_TraceRayFilterEx(pos, endPos, MASK_SHOT, RayType_EndPoint, BulletAndMeleeTrace, client);
	if(TR_DidHit(trace)) TR_GetEndPosition(hitPos, trace);
	if(TR_GetFraction(trace) < 1.0)
	{
		int target = TR_GetEntityIndex(trace);
		if(target > 0 && IsValidEntity(target) && GetTeam(client) != GetTeam(target))
		{
			victim = target;
			headshot = (TR_GetHitGroup(trace) == HITGROUP_HEAD && !b_CannotBeHeadshot[victim]);
		}
		
	}
	delete trace;
	float damage = 50.0;
	if(IsValidEntity(victim))
	{
		WorldSpaceCenter(victim, vicLoc);
		damage *= Attributes_Get(weapon, 1, 1.0);
		damage *= Attributes_Get(weapon, 2, 1.0);
		damage *= Attributes_Get(weapon, 1000, 1.0);

		if(CaydeRetribution_duration[client] < GetGameTime())
		{
			if(headshot)
			{
				if(i_HeadshotAffinity[client] == 1)
					damage *= 3.0;
				else
					damage *= 2.5;
				if(i_CurrentEquippedPerk[client] == 5)
					damage *= 1.25;
				if(Ability_Check_Cooldown(client, 3) < 0.0 || CvarInfiniteCash.BoolValue)
					Still_Hunt_charges[client]++;
				DisplayCritAboveNpc(victim, client, headshot);
			}
			else if(i_HeadshotAffinity[client] == 1)
				damage *= 0.65;
		}
		else
		{
			if(Still_Hunt_Pap_Save[client] == 3)
			{
				damage *= 38.65;
				if(Still_Hunt_Pap_Save[client] == 4 && (b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim] || b_IsGiant[victim]))
					damage *= 1.05;
			}
			else
			{
				if(Still_Hunt_Pap_Save[client] == 4)
				{
					++CaydeRetribution_charges[client];
					damage *= 9.95;
				}
				else
					damage *= 8.0+(float(CaydeRetribution_charges[client])*0.65);
				damage *= 1.0+(float(CaydeRetribution_charges[client])*0.2);
				if(Still_Hunt_Pap_Save[client] == 4 && (b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim] || b_IsGiant[victim]))
					damage *= 0.4;
			}
			if(Still_Hunt_Pap_Save[client] != 4)
			{
				if(headshot)
				{
					if(i_HeadshotAffinity[client] == 1)
						damage *= 1.6;
					else
						damage *= 1.4;
					if(i_CurrentEquippedPerk[client] == 5)
						damage *= 1.25;
					DisplayCritAboveNpc(victim, client, true);
				}
				else
				{
					if(i_HeadshotAffinity[client] == 1)
						damage *= 0.65;
					else
						DisplayCritAboveNpc(victim, client, false);
				}
			}
			else DisplayCritAboveNpc(victim, client, false);
			headshot=true;
		}
	}
	CaydeRetribution_duration[client] -=(Still_Hunt_Pap_Save[client] == 4 ? 0.5 : 3.0);
	++CaydeRetribution_Ammo[client];
	SDKHooks_TakeDamage(victim, client, client, damage, DMG_BULLET, weapon, NULL_VECTOR, vicLoc);
	FinishLagCompensation_Base_boss();
	if(!TF2_IsPlayerInCondition(client, TFCond_FocusBuff)) Still_Hunt_bullet_tracer(client, weapon, hitPos, headshot);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime(weapon)+(Still_Hunt_Pap_Save[client] == 4 ? 0.3 : 0.9));
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime(client)+(Still_Hunt_Pap_Save[client] == 4 ? 0.3 : 0.9));
}

public void Still_Hunt_bullet_tracer(int client, int weapon, float endPos[3], bool crit)
{
	float pos[3];
	GetClientEyePosition(client, pos);
	pos[2] -= 15.0;

	ShootLaser(weapon, crit ? "bullet_tracer01_red_crit" : "bullet_tracer01_red", pos, endPos);
}

public void Still_Hunt_OnKill(int attacker)
{
	if(IsValidClient(attacker) && Still_Hunt_Pap_Save[attacker] == 4 && CaydeRetribution_duration[attacker] > GetGameTime() + 0.5 && CaydeRetribution_Ammo[attacker]>1)
		CaydeRetribution_Ammo[attacker]-=1;
}

static void DestroyStill_Hunt_Effect(int client)
{
	int entity = EntRefToEntIndex(i_Still_HuntParticle[client]);
	if(IsValidEntity(entity))
		RemoveEntity(entity);
	i_Still_HuntParticle[client] = INVALID_ENT_REFERENCE;
}