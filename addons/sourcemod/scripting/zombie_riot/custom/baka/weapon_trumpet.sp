#pragma semicolon 1
#pragma newdecls required

public void Weapon_Trumpet_MapStart()
{
	if(FileExists("sound/baka_zr/trumpetskeleton.mp3", true))
		PrecacheSound("baka_zr/trumpetskeleton.mp3", true);
}

public void Trumpet_NoKnockback_Secondary_Attack(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, 1) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, 1, 1.0);
		EmitSoundToAll("baka_zr/trumpetskeleton.mp3", client, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, 1);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
	}
}

public void Trumpet_Secondary_Attack(int client, int weapon, bool crit, int slot)
{
	if(GetEntityFlags(client) & FL_DUCKING)
	{
		if(Ability_Check_Cooldown(client, 1) < 0.0 || CvarInfiniteCash.BoolValue)
		{
			Ability_Apply_Cooldown(client, slot, 1.0);
			Ability_Apply_Cooldown(client, 1, 1.0);
			EmitSoundToAll("baka_zr/trumpetskeleton.mp3", client, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, 1);
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
	}
	else if(Ability_Check_Cooldown(client, slot) < 0.0 || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(weapon);
		Ability_Apply_Cooldown(client, slot, 30.0);
		Ability_Apply_Cooldown(client, 1, 3.0);
		bool PlaySound=false;
		float position[3], entitypos[3], distance;
		WorldSpaceCenter(client, position);
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
				distance = GetVectorDistance(position, entitypos);
				if(distance<125.0)
				{
					Custom_Knockback(client, entity, 600.0, true, true, true);
					PlaySound=true;
				}
			}
		}
		for(int target=1; target<=MaxClients; target++)
		{
			if(IsValidClient(target) && target!=client)
			{
				GetEntPropVector(target, Prop_Send, "m_vecOrigin", entitypos);
				distance = GetVectorDistance(position, entitypos);
				if(distance<=125.0)
				{
					Custom_Knockback(client, target, 600.0, true, true, true);
					PlaySound=true;
				}
			}
		}
	
		if(PlaySound)
			EmitSoundToAll("baka_zr/trumpetskeleton.mp3", client, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	}
}