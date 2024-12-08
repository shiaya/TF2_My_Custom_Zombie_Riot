#pragma semicolon 1
#pragma newdecls required

public void Pixel_Gun_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	float Attackerpos[3], VictimPos[3];
	GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", Attackerpos);
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", VictimPos);
	int Pixel_WeaponMode = RoundToFloor(Attributes_Get(weapon, 425));
	float DMGBuff = damage;
	switch(Pixel_WeaponMode)
	{
		case 4:
		{
			DMGBuff+=float(ReturnEntityMaxHealth(victim))*(Attributes_Get(weapon, 19)/100.0);
		}
	}
	damage=DMGBuff;
}