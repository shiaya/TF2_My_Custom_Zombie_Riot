
static const char g_Yes[][] = {
	"baka_pmvoice/ohno/yes.mp3",
};
static const char g_No[][] = {
	"baka_pmvoice/ohno/no.mp3",
};
static const char g_DeathSound[][] = {
	"baka_pmvoice/ohno/medic.mp3",
};
static const char g_Help[][] = {
	"vo/k_lab/kl_thenwhere.wav",
};
static const char g_Medic[][] = {
	"baka_pmvoice/ohno/medic.mp3",
	"baka_pmvoice/ohno/damege.mp3",
};

static const char g_GoGoGo[][] = {
	"baka_pmvoice/ohno/go.mp3",
};
static const char g_Neagtive[][] =
{
	"baka_pmvoice/ohno/negetive.mp3",
};

static const char g_Positive[][] =
{
	"baka_pmvoice/ohno/laugh.mp3",
};

static const char g_Jeers[][] =
{
	"baka_pmvoice/ohno/jeers.mp3",
};
static const char g_Cheers[][] =
{
	"baka_pmvoice/ohno/cheers.mp3",
};

static const char g_Spy[][] =
{
	"baka_pmvoice/ohno/spy.mp3",
};

static const char g_Incoming[][] =
{
	"baka_pmvoice/ohno/incoming.mp3",
};
static const char g_Battlecry[][] =
{
	"baka_pmvoice/ohno/battlecry.mp3",
};

static const char g_HurtSound[][] =
{
	"baka_pmvoice/ohno/damege.mp3",
};

bool Neuron_ActivationSoundOverride(int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, int &seed)
{
	if(StrContains(sample, "negative", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Neagtive[GetRandomInt(0, sizeof(g_Neagtive) - 1)]);
		return true;
	}
	if(StrContains(sample, "jeers", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Jeers[GetRandomInt(0, sizeof(g_Jeers) - 1)]);
		return true;
	}
	if(StrContains(sample, "help", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Help[GetRandomInt(0, sizeof(g_Help) - 1)]);
		return true;
	}
	if(StrContains(sample, "incoming", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Incoming[GetRandomInt(0, sizeof(g_Incoming) - 1)]);
		return true;
	}
	if(StrContains(sample, "cloakedspy", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Spy[GetRandomInt(0, sizeof(g_Spy) - 1)]);
		return true;
	}
	if(StrContains(sample, "positive", false) != -1 || StrContains(sample, "laughshort", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Positive[GetRandomInt(0, sizeof(g_Positive) - 1)]);
		return true;
	}
	if(StrContains(sample, "cheers", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Cheers[GetRandomInt(0, sizeof(g_Cheers) - 1)]);
		return true;
	}
	if(StrContains(sample, "battlecry", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Battlecry[GetRandomInt(0, sizeof(g_Battlecry) - 1)]);
		return true;
	}
	if(StrContains(sample, "painsevere", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)]);
		return true;
	}
	if(StrContains(sample, "painsharp", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)]);
		return true;
	}
	if(StrContains(sample, "paincrticialdeath", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_DeathSound[GetRandomInt(0, sizeof(g_DeathSound) - 1)]);
		return true;
	}
	if(StrContains(sample, "go", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_GoGoGo[GetRandomInt(0, sizeof(g_GoGoGo) - 1)]);
		return true;
	}
	if(StrContains(sample, "yes", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Yes[GetRandomInt(0, sizeof(g_Yes) - 1)]);
		return true;
	}
	if(StrContains(sample, "no", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_No[GetRandomInt(0, sizeof(g_No) - 1)]);
		return true;
	}
	if(StrContains(sample, "medic", false) != -1)
	{
		strcopy(sample, sizeof(sample), g_Medic[GetRandomInt(0, sizeof(g_Medic) - 1)]);
		return true;
	}
	return false;
}
/*void Neuron_ActivationSoundOverrideMapStart()
{
	PrecacheSoundArray(g_Yes);
	PrecacheSoundArray(g_Help);
	PrecacheSoundArray(g_Jeers);
	PrecacheSoundArray(g_Neagtive);
	PrecacheSoundArray(g_GoGoGo);
	PrecacheSoundArray(g_Incoming);
	PrecacheSoundArray(g_Spy);
	PrecacheSoundArray(g_Positive);
	PrecacheSoundArray(g_Cheers);
	PrecacheSoundArray(g_Battlecry);
	PrecacheSoundArray(g_No);
	PrecacheSoundArray(g_Medic);
	PrecacheSoundArray(g_DeathSound);
	PrecacheSoundArray(g_HurtSound);
}*/