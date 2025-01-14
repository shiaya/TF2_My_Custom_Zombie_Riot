#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerMajorSteam_Launcher[MAXTF2PLAYERS] = {null, ...};
static float i_MajorSteam_Launcher_Delay[MAXTF2PLAYERS];
static int i_MajorSteam_Launcher_Resistance[MAXTF2PLAYERS];
static int i_MajorSteam_Launcher_Recharging[MAXTF2PLAYERS];
static int i_MajorSteam_Launcher_WeaponPap[MAXTF2PLAYERS];

static const char g_ResistanceSounds[][] = {
	"weapons/fx/rics/ric1.wav",
	"weapons/fx/rics/ric2.wav",
	"weapons/fx/rics/ric3.wav",
	"weapons/fx/rics/ric4.wav",
	"weapons/fx/rics/ric5.wav"
};


float f_MajorSteam_Launcher_Resistance(int client)
{
	if(h_TimerMajorSteam_Launcher[client] != null)
	{
		if(i_MajorSteam_Launcher_WeaponPap[client]==1)
		{
			float f_Resistance = 1.8;
			if(i_MajorSteam_Launcher_Resistance[client]>0)
				f_Resistance=(float(1000-i_MajorSteam_Launcher_Resistance[client])/1000.0)*1.8;
			if(f_Resistance>1.8)f_Resistance=1.8;
			if(f_Resistance<0.1)f_Resistance=0.1;
			return f_Resistance;
		}
		else
		{
			float f_Resistance = 1.2;
			if(i_MajorSteam_Launcher_Resistance[client]>0)
				f_Resistance=(float(1000-i_MajorSteam_Launcher_Resistance[client])/1000.0)*1.2;
			if(f_Resistance>1.8)f_Resistance=1.2;
			if(f_Resistance<0.1)f_Resistance=0.4;
			return f_Resistance;
		}
	}
	return 1.0;
}

public void MajorSteam_Launcher_OnMapStart()
{
	Zero(i_MajorSteam_Launcher_WeaponPap);
	Zero(i_MajorSteam_Launcher_Resistance);
	Zero(i_MajorSteam_Launcher_Delay);
	Zero(i_MajorSteam_Launcher_Recharging);
	for (int i = 0; i < (sizeof(g_ResistanceSounds));	   i++) { PrecacheSound(g_ResistanceSounds[i]);	   }
}

public void MajorSteam_Launcher_WaveEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !b_IsPlayerABot[client])
			i_MajorSteam_Launcher_Resistance[client]=1000;
	}
}

public void Enable_MajorSteam_Launcher(int client, int weapon)
{
	if(h_TimerMajorSteam_Launcher[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MAJORSTEAM_LAUNCHER)
		{
			i_MajorSteam_Launcher_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			delete h_TimerMajorSteam_Launcher[client];
			h_TimerMajorSteam_Launcher[client] = null;
			DataPack pack;
			h_TimerMajorSteam_Launcher[client] = CreateDataTimer(0.1, Timer_MajorSteam_Launcher, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MAJORSTEAM_LAUNCHER)
		{
			i_MajorSteam_Launcher_WeaponPap[client] = RoundToFloor(Attributes_Get(weapon, 391, 0.0));
			DataPack pack;
			h_TimerMajorSteam_Launcher[client] = CreateDataTimer(0.1, Timer_MajorSteam_Launcher, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
}

static Action Timer_MajorSteam_Launcher(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerMajorSteam_Launcher[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	bool holding;
	if(weapon_holding == weapon)
	{
		holding=true;
		ApplyStatusEffect(client, client, "Major Steam's Launcher Resistance", 0.5);
	}
	else
		holding=false;
	MajorSteam_Launcher_Function(client, holding);

	return Plugin_Continue;
}

public void MajorSteam_Launcher_PlayerTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(attacker) || GetTeam(attacker) == TFTeam_Red)
		return;
	if(!IsValidClient(victim))
		return;
	i_MajorSteam_Launcher_Delay[victim]= GetGameTime() + 10.0;
	if(i_MajorSteam_Launcher_Resistance[victim] > 0)
	{
		EmitSoundToAll(g_ResistanceSounds[GetRandomInt(0, sizeof(g_ResistanceSounds) - 1)], victim, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		if(i_MajorSteam_Launcher_WeaponPap[victim]==1)
		{
			if(RaidbossIgnoreBuildingsLogic(1))
				i_MajorSteam_Launcher_Resistance[victim]-=20;
			else
				i_MajorSteam_Launcher_Resistance[victim]-=5;
		}
		else
		{
			if(RaidbossIgnoreBuildingsLogic(1))
				i_MajorSteam_Launcher_Resistance[victim]-=40;
			else
				i_MajorSteam_Launcher_Resistance[victim]-=10;
		}
		if(i_MajorSteam_Launcher_Resistance[victim]<1)
			i_MajorSteam_Launcher_Resistance[victim]=0;
		PrintToChat(victim, "Resistance: %i",i_MajorSteam_Launcher_Resistance[victim]);
	}
}

static void MajorSteam_Launcher_Function(int client, bool holding)
{
	if(Armor_Charge[client] < 1)
	{
		//none
	}
	else if(Waves_InSetup())
	{
		i_MajorSteam_Launcher_Resistance[client]=1000;
	}
	else if(holding && i_MajorSteam_Launcher_Delay[client] < GetGameTime())
	{
		i_MajorSteam_Launcher_Recharging[client]++;
		if(i_MajorSteam_Launcher_Recharging[client]>30 && i_MajorSteam_Launcher_Resistance[client]<1000)
		{
			i_MajorSteam_Launcher_Recharging[client]=0;
			i_MajorSteam_Launcher_Resistance[client]+=25;
			if(i_MajorSteam_Launcher_Resistance[client]>1000)
				i_MajorSteam_Launcher_Resistance[client]=1000;
			PrintToChat(client, "Resistance: %i",i_MajorSteam_Launcher_Resistance[client]);
		}
	}
	else i_MajorSteam_Launcher_Recharging[client]=0;
}