#pragma semicolon 1
#pragma newdecls required

static int i_ToolGun_Mode[MAXPLAYERS];
static int i_ToolGun_Extra[MAXPLAYERS];
static int i_ToolGun_GetEntities[MAXPLAYERS];

static int gLaser1;

static const char g_TeleSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};

public void Weapon_ToolGun_MapStart()
{
	Zero(i_ToolGun_Mode);
	Zero(i_ToolGun_Extra);
	Zero(i_ToolGun_GetEntities);
	for (int i = 0; i < (sizeof(g_TeleSounds));	   i++) { PrecacheSound(g_TeleSounds[i]);	   }
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
}

public void ToolGun_Main_Attack(int client, int weapon, bool crit, int slot)
{
	float pos[3], ang[3], endPos[3], hitPos[3], direction[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, 9999.0);
	AddVectors(pos, direction, endPos);
	int victim=-1;
	Handle trace = TR_TraceRayFilterEx(pos, endPos, MASK_SHOT, RayType_EndPoint, ToolGun_TraceNotMe, client);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(hitPos, trace);
	}
	if(TR_GetFraction(trace) < 1.0)
	{
		int target = TR_GetEntityIndex(trace);
		if(target > 0 && IsValidEntity(target))
			victim = target;
	}
	delete trace;
	pos[2] -= 15.0;
	TE_SetupBeamPoints(pos, hitPos, gLaser1, -1, 0, 0, 0.1, 0.0, 25.0, 0, 1.0, {115, 125, 255, 255}, 3);
	TE_SendToAll();
	ToolGunWork(client, victim, i_ToolGun_Mode[client], hitPos);
}

public void ToolGun_Secondary_Attack(int client, int weapon, bool crit, int slot)
{
	if(i_ToolGun_Mode[client]==1)
	{
		i_ToolGun_Extra[client]++;
		switch(i_ToolGun_Extra[client])
		{
			case 1:PrintToChat(client, "Set DMG: 1000");
			case 2:PrintToChat(client, "Set DMG: 2500");
			case 3:PrintToChat(client, "Set DMG: 5000");
			case 4:PrintToChat(client, "Set DMG: 10000");
			case 5:PrintToChat(client, "Set DMG: 50000");
			case 6:PrintToChat(client, "Set DMG: 100000");
			case 7:PrintToChat(client, "Set DMG: 500000");
			case 8:PrintToChat(client, "Set DMG: 1000000");
			default:
			{
				PrintToChat(client, "Set DMG: 500");
				i_ToolGun_Extra[client]=0;
			}
		}
		return;
	}
	float pos[3], ang[3], endPos[3], hitPos[3], direction[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, 9999.0);
	AddVectors(pos, direction, endPos);
	int victim;
	Handle trace = TR_TraceRayFilterEx(pos, endPos, MASK_SHOT, RayType_EndPoint, ToolGun_TraceNotMe, client);
	if(TR_DidHit(trace)) TR_GetEndPosition(hitPos, trace);
	if(TR_GetFraction(trace) < 1.0)
	{
		int target = TR_GetEntityIndex(trace);
		if(target > 0 && IsValidEntity(target))
			victim = target;
	}
	delete trace;
	pos[2] -= 15.0;
	TE_SetupBeamPoints(pos, hitPos, gLaser1, -1, 0, 0, 0.1, 0.0, 25.0, 0, 1.0, {115, 125, 255, 255}, 3);
	TE_SendToAll();
	if(IsValidEntity(victim))
	{
		i_ToolGun_GetEntities[client]=EntIndexToEntRef(victim);
		if(!IsValidClient(victim))
		{
			char npc_classname[60];
			strcopy(npc_classname, sizeof(npc_classname), c_NpcName[victim]);
			PrintToChat(client, "Get: %s", npc_classname);
		}
		else PrintToChat(client, "Get: %N", victim);
	}
}

public void ToolGun_Change_Mode(int client, int weapon, bool crit, int slot)
{
	ClientCommand(client, "playgamesound weapons/vaccinator_toggle.wav");
	i_ToolGun_Mode[client]++;
	switch(i_ToolGun_Mode[client])
	{
		case 1:PrintToChat(client, "Set Mode: Hit DMG");
		case 2:PrintToChat(client, "Set Mode: Teleport");
		default:
		{
			PrintToChat(client, "Set Mode: Instant Kill");
			i_ToolGun_Mode[client]=0;
		}
	}
}

static bool ToolGun_TraceNotMe(int entity, int contentsMask, any data)
{
	if(entity == data)
		return false;

	return true;
}

//0: kill
//1: DMG
//2: Teleport
static void ToolGunWork(int attacker, int victim, int Mode, float hitPos[3])
{
	switch(Mode)
	{
		case 2:
		{
			int entity = EntRefToEntIndex(i_ToolGun_GetEntities[attacker]);
			if(IsValidEntity(entity))
			{
				float flPos[3]; WorldSpaceCenter(entity, flPos);
				hitPos[2]+=10.0;
				if(GetTeam(attacker) == GetTeam(entity))
				{
					ParticleEffectAt(flPos, "teleported_red", 0.5);
					ParticleEffectAt(hitPos, "teleported_red", 0.5);
				}
				else
				{
					ParticleEffectAt(flPos, "teleported_blue", 0.5);
					ParticleEffectAt(hitPos, "teleported_blue", 0.5);
				}
					
				TeleportEntity(entity, hitPos, NULL_VECTOR, NULL_VECTOR);
				EmitSoundToAll(g_TeleSounds[GetRandomInt(0, sizeof(g_TeleSounds) - 1)], entity, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
				return;
			}
		}
	}
	if(IsValidEntity(victim))
	{
		switch(Mode)
		{
			case 0:
			{
				if(IsValidClient(victim))return;
				b_NpcForcepowerupspawn[victim] = 0;
				i_RaidGrantExtra[victim] = 0;
				b_DissapearOnDeath[victim] = true;
				b_DoGibThisNpc[victim] = true;
				SmiteNpcToDeath(victim);
			}
			case 1:
			{
				int DMG;
				switch(i_ToolGun_Extra[attacker])
				{
					case 1:DMG=1000;
					case 2:DMG=2500;
					case 3:DMG=5000;
					case 4:DMG=10000;
					case 5:DMG=50000;
					case 6:DMG=100000;
					case 7:DMG=500000;
					case 8:DMG=1000000;
					default:DMG=500;
				}
				int teamkill=attacker;
				if(GetTeam(attacker) == GetTeam(victim))
					teamkill=0;
				SDKHooks_TakeDamage(victim, teamkill, teamkill, float(DMG), DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE, -1);
			}
		}
	}
}