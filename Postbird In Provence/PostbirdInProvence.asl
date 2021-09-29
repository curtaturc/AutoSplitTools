state("PostbirdInProvence")
{
	int      Managers : "GameAssembly.dll", 0x203BA50, 0xB8, 0x0, 0x28, 0x30, 0x18;
	string64 Dialogue : "GameAssembly.dll", 0x203BA50, 0xB8, 0x0, 0x28, 0x60, 0x30, 0x10, 0x30, 0x50, 0x10, 0x14;
	int      Node     : "GameAssembly.dll", 0x203BA50, 0xB8, 0x0, 0x28, 0x60, 0x30, 0x10, 0x30, 0x50, 0x18;
	uint     Day      : "GameAssembly.dll", 0x203BA50, 0xB8, 0x0, 0x28, 0xA8;
}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Postbird ASL] " + output));

	settings.Add("day", true, "Split when finishing the day");

	settings.Add("Community manager");
	settings.CurrentDefaultParent = "Community manager";
		settings.Add("Enchanté Henri", false);
		settings.Add("Enchanté Daphné", false);
		settings.Add("Enchanté Charline", false);
		settings.Add("Enchanté Charles", false);
		settings.Add("Enchanté Charlie", false);
		settings.Add("Enchanté Rosette", false);
		settings.Add("Enchanté Louis", false);
		settings.Add("Enchanté Jean", false);
		settings.Add("Enchanté Léon", false);

	settings.CurrentDefaultParent = null;
	settings.Add("Tourist");
	settings.CurrentDefaultParent = "Tourist";
		settings.Add("The viewpoint", false);
		settings.Add("The island", false);
		settings.Add("The marina", false);
		settings.Add("The picnic area", false);
		settings.Add("The main plaza", false);

	settings.CurrentDefaultParent = null;
	settings.Add("Fear of silence");
	settings.CurrentDefaultParent = "Fear of silence";
		settings.Add("Montélimace FM", false);

	settings.CurrentDefaultParent = null;
	settings.Add("Philatelist");
	settings.CurrentDefaultParent = "Philatelist";
		settings.Add("Only 9 left!", false);

	settings.CurrentDefaultParent = null;

	settings.Add("Honk honk");
	settings.Add("E.T.");
	settings.Add("Crazy driving");
	settings.Add("Use splash!");
	settings.Add("Ohlala");
	settings.Add("Inspector Marcel");
	settings.Add("Run like the wind");
	settings.Add("Handyman");
	settings.Add("Professional basketball player");
	settings.Add("The green thumb");
	settings.Add("The new champ");
	settings.Add("Postbird in Provence");

	vars.TimerStart = (EventHandler) ((s, e) => vars.UpdateAchievements());
	timer.OnStart += vars.TimerStart;
}

init
{
	string[] achvNames =
	{
		"Enchanté Henri",
		"Enchanté Daphné",
		"Enchanté Charline",
		"Enchanté Charles",
		"Enchanté Charlie",
		"Enchanté Rosette",
		"Enchanté Louis",
		"Enchanté Jean",
		"Enchanté Léon",
		"The viewpoint",
		"The island",
		"The marina",
		"The picnic area",
		"The main plaza",
		"Community manager",
		"Tourist",
		"Fear of silence",
		"Montélimace FM",
		"Philatelist",
		"Only 9 left!",
		"Honk honk",
		"E.T.",
		"Crazy driving",
		"Use splash!",
		"Ohlala",
		"Inspector Marcel",
		"Run like the wind",
		"Handyman",
		"Professional basketball player",
		"The green thumb",
		"The new champ",
		"Postbird in Provence"
	};

	vars.Achievements = new MemoryWatcherList();
	vars.UpdateAchievements = (Action) (() =>
	{
		vars.Achievements = new MemoryWatcherList();

		for (int i = 0; i < 32; ++i)
		{
			var ptr = new DeepPointer("GameAssembly.dll", 0x203BA50, 0xB8, 0x0, 0x28, 0x80, 0x20, 0x20 + 0x8 * i, 0x70).Deref<IntPtr>(game);
			vars.Achievements.Add(new MemoryWatcher<bool>(ptr + 0x10) { Name = achvNames[i] });
		}
	});

	old.Managers = 0;
}

start
{
	return old.Node == 4 && current.Node > 4 && current.Dialogue == "Player.Dialogue.IntroCinematic";
}

split
{
	vars.Achievements.UpdateAll(game);

	foreach (MemoryWatcher<bool> watcher in vars.Achievements)
	{
		if (!watcher.Old && watcher.Current && settings[watcher.Name])
		{
			vars.Dbg("split for watcher: " + watcher.Name);
			return true;
		}
	}

	if (old.Day < current.Day && settings["day"])
	{
		vars.Dbg("split for day: " + old.Day + " -> " + current.Day);
		return true;
	}

	if (old.Dialogue == "Player.Dialogue.EndGameCutScene" && string.IsNullOrEmpty(current.Dialogue))
	{
		vars.Dbg("split for end?");
		return true;
	}
}

reset
{
	return old.Managers != 2 && current.Managers == 2;
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}