#pragma semicolon 1
#pragma newdecls required

static float SupportWeapon_Energy[MAXTF2PLAYERS];
static float SupportWeapon_Energy_Regen[MAXTF2PLAYERS];
static float SupportWeapon_Energy_Max[MAXTF2PLAYERS];
static Handle SupportWeaponTimer[MAXTF2PLAYERS];
static float SupportWeaponHUDDelay[MAXTF2PLAYERS];
static bool SupportWeapon_ReloadMiddle[MAXTF2PLAYERS];
static bool SupportWeapon_Reload[MAXTF2PLAYERS];

public void SupportWeapons_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_SUPPORTWEAPONS)
	{
		delete SupportWeaponTimer[client];
		SupportWeaponTimer[client] = null;
		DataPack pack;
		SupportWeaponTimer[client] = CreateDataTimer(0.2, Timer_SupportWeapons, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_SupportWeapons(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon) || i_CustomWeaponEquipLogic[weapon]!=WEAPON_SUPPORTWEAPONS)
	{
		SupportWeapon_Energy[client]=0.0;
		SupportWeapon_Energy_Max[client]=0.0;
		SupportWeaponTimer[client] = null;
		return Plugin_Stop;
	}
	if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
	{
		int primary=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		if(IsValidEntity(primary) && primary == weapon)
		{
			if(Attributes_Get(weapon, 413, 0.0)==1.0 || Attributes_Get(weapon, 305, 0.0)==1.0)
			{
				SupportWeapon_Energy_Max[client]=10.0;
				int clip = GetEntData(primary, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"));
				if(clip>=1)
				{
					if(SupportWeapon_Energy[client]>=SupportWeapon_Energy_Max[client])
					{
						float position[3];
						GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
						Explode_Logic_Custom(5000.0, client, client, -1, position, 250.0,_,_,false);
						ParticleEffectAt(position, "rd_robot_explosion", 1.0);
						EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, position);
						SDKHooks_TakeDamage(client, 0, 0, float(GetClientHealth(client))*3.0, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE);
						ForcePlayerSuicide(client);
					}
					else if(SupportWeapon_Energy[client]>SupportWeapon_Energy_Max[client]*0.9)
					{
						SupportWeapon_Energy_Regen[client]=0.12;
						if(!SupportWeapon_Reload[client])
						{
							EmitSoundToAll(RAILGUN_READY_ALARM, client, _, 90, _, 0.8);
							SupportWeapon_Reload[client]=true;
						}
					}
					else if(SupportWeapon_Energy[client]>SupportWeapon_Energy_Max[client]*0.8)
						SupportWeapon_Energy_Regen[client]=0.3;
					else if(SupportWeapon_Energy[client]>SupportWeapon_Energy_Max[client]*0.7)
						SupportWeapon_Energy_Regen[client]=0.5;
					else if(SupportWeapon_Energy[client]>SupportWeapon_Energy_Max[client]*0.5)
					{
						SupportWeapon_Energy_Regen[client]=0.55;
						if(!SupportWeapon_ReloadMiddle[client])
						{
							EmitSoundToAll(RAILGUN_READY, client, _, 90, _, 0.8);
							SupportWeapon_ReloadMiddle[client]=true;
						}
					}
					else
						SupportWeapon_Energy_Regen[client]=0.85;
					SupportWeapon_Energy[client]+=SupportWeapon_Energy_Regen[client];
					if(SupportWeapon_Energy[client]>SupportWeapon_Energy_Max[client])
						SupportWeapon_Energy[client]=SupportWeapon_Energy_Max[client];
				}
				else
				{
					SupportWeapon_ReloadMiddle[client]=false;
					SupportWeapon_Reload[client]=false;
					SupportWeapon_Energy[client]=0.0;
				}
				if(SupportWeaponHUDDelay[client] < GetGameTime())
				{
					char buffer[32];
					if(SupportWeapon_Energy[client]>SupportWeapon_Energy_Max[client]*0.9)
						Format(buffer, sizeof(buffer), "!!!Warning!!!\nEnergy [%i％]", RoundToFloor(SupportWeapon_Energy[client]/SupportWeapon_Energy_Max[client]*100.0));
					else if(SupportWeapon_Energy[client]>SupportWeapon_Energy_Max[client]*0.8)
						Format(buffer, sizeof(buffer), "!!Warning!!\nEnergy [%i％]", RoundToFloor(SupportWeapon_Energy[client]/SupportWeapon_Energy_Max[client]*100.0));
					else if(SupportWeapon_Energy[client]>SupportWeapon_Energy_Max[client]*0.7)
						Format(buffer, sizeof(buffer), "!Warning!\nEnergy [%i％]", RoundToFloor(SupportWeapon_Energy[client]/SupportWeapon_Energy_Max[client]*100.0));
					else
						Format(buffer, sizeof(buffer), "Safety\nEnergy [%i％]", RoundToFloor(SupportWeapon_Energy[client]/SupportWeapon_Energy_Max[client]*100.0));
					PrintHintText(client, "%s", buffer);
					StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
					SupportWeaponHUDDelay[client] = GetGameTime() + 0.35;
				}
			}
		}
	}
	return Plugin_Continue;
}

public void SupportWeapons_NPCTakeDamage(int victim, int attacker, float &damage, int &damagetype, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	if(Attributes_Get(weapon, 413, 0.0)==1.0 || Attributes_Get(weapon, 305, 0.0)==1.0)
	{
		damagetype &= DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE;
		damage*=SupportWeapon_Energy[attacker]*12.0;
	}
}