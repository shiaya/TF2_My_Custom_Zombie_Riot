public void TeamBakaCustom_OnMapStart()
{
	Neuron_ActivationSoundOverrideMapStart();
	MajorSteam_Launcher_OnMapStart();
	LockDown_Wand_MapStart();
}

public void TeamBakaCustom_Enable(int client, int weapon)
{
	Enable_MajorSteam_Launcher(client, weapon);
	LockDown_Enable(client, weapon);
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

