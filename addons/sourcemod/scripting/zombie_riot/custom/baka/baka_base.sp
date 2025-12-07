public void TeamBakaCustom_OnMapStart()
{
	Neuron_ActivationSoundOverrideMapStart();
	MajorSteam_Launcher_OnMapStart();
	LockDown_Wand_MapStart();
	MSword_OnMapStart();
	ResetMapStartExploARWeapon();
	
	//Wand_Sigil_Blade_MapStart();
	//KitOmega_OnMapStart();
}

public void TeamBakaCustom_Enable(int client, int weapon)
{
	Enable_MajorSteam_Launcher(client, weapon);
	LockDown_Enable(client, weapon);
	MSword_Enable(client, weapon);
	Enable_ExploARWeapon(client, weapon);
	
	//Enable_Sigil_Blade(client, weapon);
	//Enable_KitOmega(client, weapon);
}

void BakaCustomLastMan(int client)
{
	/*if(Wkit_Omega_LastMann(client))
	{
		CPrintToChatAll("{gold}%N are now alone,however,he won't give up that early...", client);
		Yakuza_Lastman(12);
	}*/
	if(Sigil_LastMann(client))
	{
		CPrintToChatAll("{blue}Diabolus Ex Machina", client);
		Yakuza_Lastman(12);
	}
}

bool BakaStartCustomSoundForLastMan(int client, int WhatSoundPlay)
{
	bool CompleteFailure;
	switch(WhatSoundPlay)
	{
		case 13:
		{
			EmitCustomToClient(client, "#zombiesurvival/expidonsa_waves/wave_45_music_1.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			SetMusicTimer(client, GetTime() + 279);
		}
		default:CompleteFailure=true;
	}
	return CompleteFailure;
}

void BakaStopCustomSoundForLastMan(int client, int WhatSoundPlay)
{
	switch(WhatSoundPlay)
	{
		case 12:StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/expidonsa_waves/wave_45_music_1.mp3", 2.0);
	}
}

void TeamBakaCustom_WaveEnd()
{
	MajorSteam_Launcher_WaveEnd();
}

void TeamBakaCustom_OnKill(int attacker)
{

}

public void TeamBakaCustom_NPCTakeDamage(int attacker, int victim, float &damage, int weapon, float damagePosition[3], int damagetype)
{
	/*if(!CheckInHud())
		return;*/
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_MAJORSTEAM_LAUNCHER:MajorSteam_Launcher_NPCTakeDamage(attacker, victim, damage, weapon, damagetype);
		case WEAPON_MINECRAFT_SWORD:MSword_NPCTakeDamage(attacker, victim, damage, weapon);
	}
}

public void TeamBakaCustom_PlayerTakeDamage(int victim, int attacker, float &damage, int weapon, float damagePosition[3], int damagetype)
{
	/*if(!CheckInHud())
		return;*/
	if(!IsValidEntity(attacker) || GetTeam(attacker) == TFTeam_Red)
		return;
	if(!IsValidClient(victim))
		return;
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_MAJORSTEAM_LAUNCHER:MajorSteam_Launcher_PlayerTakeDamage(victim, attacker, damage, weapon)
	}
}

