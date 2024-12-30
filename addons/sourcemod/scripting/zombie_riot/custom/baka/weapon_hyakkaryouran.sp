#pragma semicolon 1
#pragma newdecls required

static Handle h_TimerHyakkaryouranWeaponManagement[MAXTF2PLAYERS] = {null, ...};
static float f_Hyakkaryouran_HUDDelay[MAXTF2PLAYERS];

/*public void Weapon_ToolGun_MapStart()
{
	Zero(i_ToolGun_Mode);
	Zero(i_ToolGun_Extra);
	Zero(i_ToolGun_GetEntities);
	for (int i = 0; i < (sizeof(g_TeleSounds));	   i++) { PrecacheSound(g_TeleSounds[i]);	   }
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
}*/

public void Enable_HyakkaryouranWeapon(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerHyakkaryouranWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_HYAKKARYOURAN)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerHyakkaryouranWeaponManagement[client];
			h_TimerHyakkaryouranWeaponManagement[client] = null;
			DataPack pack;
			h_TimerHyakkaryouranWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Hyakkaryouran, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_HYAKKARYOURAN)
		{
			DataPack pack;
			h_TimerHyakkaryouranWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_Hyakkaryouran, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
}

static Action Timer_Management_Hyakkaryouran(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerHyakkaryouranWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	bool holding;
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		Hyakkaryouran_HUD(client);
		holding=true;
	}
	else
	{
		holding=false;
	}
	Hyakkaryouran_Function(client, holding);

	return Plugin_Continue;
}

public void Hyakkaryouran_Main_Attack(int client, int weapon, bool crit, int slot)
{
}

static void Hyakkaryouran_HUD(int client)
{
	if(f_Hyakkaryouran_HUDDelay[client] < GetGameTime())
	{
		/*if(Change[client])
			PrintHintText(client,"Mode: BLAST / Blast Shells: %i", new_ammo);
		else
			PrintHintText(client,"Mode: PIERCE / Blast Shells: %i", new_ammo);*/

		StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
		f_Hyakkaryouran_HUDDelay[client] = GetGameTime() + 0.5;
	}

}

static void Hyakkaryouran_Function(int client, bool holding)
{
	if(holding && !(GetClientButtons(client) & IN_ATTACK))
	{
	
	}
	else
	{
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
	}
}