#pragma semicolon 1
#pragma newdecls required

static Handle Still_HuntTimer[MAXTF2PLAYERS+1] = {null, ...};
static int Still_Hunt_Pap[MAXTF2PLAYERS+1];
static int Still_Hunt_charges[MAXTF2PLAYERS+1];
static int CaydeRetribution_charges[MAXTF2PLAYERS+1];
static float particle_delay[MAXTF2PLAYERS+1];
static float CaydeRetribution_duration[MAXTF2PLAYERS+1];
static int CaydeRetribution_End[MAXTF2PLAYERS+1];
static float fl_hud_timer[MAXTF2PLAYERS+1];

public void Still_Hunt_MapStart()
{
	if(FileExists("sound/baka_zr/goldengun_sfx.mp3", true))
		PrecacheSound("baka_zr/goldengun_sfx.mp3", true);
	Zero(fl_hud_timer);
	Zero(Still_Hunt_charges);
	Zero(CaydeRetribution_charges);
	Zero(CaydeRetribution_duration);
	Zero(Still_HuntTimer);
	Zero(CaydeRetribution_End);
	Zero(particle_delay);
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
		if(CaydeRetribution_charges[client] >= (Still_Hunt_Pap[client] >= 3 ? 1 : 3) && CaydeRetribution_duration[client] > GameTime + 0.5)CaydeRetribution_duration[client] = GameTime + 0.5;
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
		Format(HUDText, sizeof(HUDText), "%sAmmo: %i [%.1f]", HUDText, (Still_Hunt_Pap[client] >= 3 ? 1 : 3)-CaydeRetribution_charges[client], Duration);
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
			Rogue_OnAbilityUse(weapon);
			float Time = GetGameTime();
			float duration = 14.5+float(Still_Hunt_Pap[client]);
			Rogue_OnAbilityUse(weapon);
			CaydeRetribution_duration[client] = Time + duration;
			Still_Hunt_charges[client]=0;
			CaydeRetribution_charges[client]=0;
			char name[32];
			GetClientName(client, name, sizeof(name));
		//	CPrintToChatAll("%t", "Still_Hunt_Cayde", name);
			float EntLoc[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
			ParticleEffectAt(EntLoc, "mannpower_imbalance_red", 0.8);
			MakePlayerGiveResponseVoice(client, 1);
			int CaydeRetribution = Store_GiveSpecificItem(client, "Weapon CaydeRetribution");
			EmitSoundToAll("baka_zr/goldengun_sfx.mp3", client, SNDCHAN_AUTO, 75,_,1.0,100);
			Attributes_Set(CaydeRetribution, 2, Attributes_Get(weapon, 2, 1.0));
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
		if(IsValidEntity(WeaponIslive))
		{
			TF2_RemoveItem(client, WeaponIslive);
		}
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
		TF2_AutoSetActiveWeapon(client);
		Still_Hunt_charges[client]=0;
		CaydeRetribution_charges[client]=0;
		Ability_Apply_Cooldown(client, 3, 20.0);
		SDKUnhook(client, SDKHook_PreThink, CaydeRetribution_Think);
		return;
	}
	else if(particle_delay[client] < GetGameTime())
	{
		particle_delay[client] = GetGameTime() + 0.1;
		float EntLoc[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);
		int particle_power = ParticleEffectAt(EntLoc, "medic_radiusheal_red_spikes", 0.1);
		SetParent(client, particle_power);
		/*EntLoc[2]+=95.0;
		particle_power = ParticleEffectAt(EntLoc, "powerup_icon_precision_red", 0.1);
		SetParent(client, particle_power);*/
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
		if(target > 0 && IsValidEntity(target) && GetTeam(target) != TFTeam_Red)
		{
			victim = target;
			headshot = (TR_GetHitGroup(trace) == HITGROUP_HEAD && !b_CannotBeHeadshot[victim]);
		}
		
	}
	delete trace;
	WorldSpaceCenter(victim, vicLoc);
	float damage = 50.0;
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
			Still_Hunt_charges[client]++;
			DisplayCritAboveNpc(victim, client, headshot);
		}
		else if(i_HeadshotAffinity[client] == 1)
			damage *= 0.65;
	}
	else
	{
		++CaydeRetribution_charges[client];
		if(Still_Hunt_Pap[client] >= 3)
			damage *= 53.1;
		else
		{
			damage *= 8.0+float(Still_Hunt_Pap[client]);
			damage *= 1.0+(float(CaydeRetribution_charges[client])*0.2);
		}
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
		headshot=true;
	}
	SDKHooks_TakeDamage(victim, client, client, damage, DMG_BULLET, weapon, NULL_VECTOR, vicLoc);
	FinishLagCompensation_Base_boss();
	if(!TF2_IsPlayerInCondition(client, TFCond_FocusBuff)) Still_Hunt_bullet_tracer(client, weapon, hitPos, headshot);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+0.9);
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime()+0.9);
}

public void Still_Hunt_bullet_tracer(int client, int weapon, float endPos[3], bool crit)
{
	float pos[3];
	GetClientEyePosition(client, pos);
	pos[2] -= 15.0;

	ShootLaser(weapon, crit ? "bullet_tracer01_red_crit" : "bullet_tracer01_red", pos, endPos);
}