state("DonutCounty")
{
	string50 SceneName       : "mono.dll", 0x298AE8, 0x20, 0x400, 0xB8, 0x20, 0x14;
	bool Loading             : "mono.dll", 0x298AE8, 0x20, 0x400, 0xB8, 0x30;
	bool IsLoadingScene      : "mono.dll", 0x298AE8, 0x20, 0x400, 0xB8, 0x32;
	int LevelIndex           : "mono.dll", 0x298AE8, 0x20, 0x400, 0xD8, 0x18, 0x8C;
	int TornadoDestructables : "mono.dll", 0x298AE8, 0x20, 0x400, 0xF0, 0xD0;
}

startup
{
	dynamic[,] Settings =
	{
		{ "splits", "Mira's House", true, "mira" },
			{ "mira", "Goose on a Scooter", false, "0" },
			{ "mira", "BK talking to Mira", true, "1" },

		{ "splits", "Potter's Rock", true, "2" },
		{ "splits", "Ranger Station", true, "3" },
		{ "splits", "Riverbed", true, "4" },
		{ "splits", "Campground", true, "5" },
		{ "splits", "Hopper Springs", true, "6" },
		{ "splits", "Joshua Tree", true, "7" },
		{ "splits", "Beach Lot C", true, "8" },
		{ "splits", "Gecko Park", true, "9" },
		{ "splits", "Chicken Barn", true, "10" },
		{ "splits", "Honey Nut Forest", true, "11" },
		{ "splits", "Cat Soup", true, "12" },
		{ "splits", "Donut Shop", true, "13" },
		{ "splits", "Abandoned House", true, "14" },
		{ "splits", "Raccoon Lagoon", true, "15" },
		{ "splits", "The 405", true, "16" },
		{ "splits", "Above Donut County", false, "17" },
		{ "splits", "Raccoon HQ Exterior", false, "18" },
		{ "splits", "Biology Lab", true, "20" },
		{ "splits", "Anthropology Lab", true, "22" },
		{ "splits", "Trash King's Office", false, "24" }
	};

	settings.Add("splits", true, "Split after completing levels:");

	for (int i = 0; i < Settings.GetLength(0); ++i)
	{
		string parent = Settings[i, 0];
		string desc   = Settings[i, 1];
		bool state    = Settings[i, 2];
		string id     = Settings[i, 3];

		settings.Add(id, state, desc, parent);
	}

	vars.TimerStart = (EventHandler) ((s, e) => vars.CompletedSplits = new HashSet<int>());
	timer.OnStart += vars.TimerStart;
}

start
{
	return old.SceneName != current.SceneName &&
	       old.SceneName == "titlescreen" &&
	       current.SceneName != "scn_credits";
}

split
{
	if (old.LevelIndex != current.LevelIndex && !vars.CompletedSplits.Contains(old.LevelIndex))
	{
		vars.CompletedSplits.Add(old.LevelIndex);
		return settings[old.LevelIndex.ToString()];
	}

	return old.TornadoDestructables == 3 && current.TornadoDestructables == 4;
}

isLoading
{
	return current.Loading || current.IsLoadingScene;
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}