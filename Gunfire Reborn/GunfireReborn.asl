state ("Gunfire Reborn") { }

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Gunfire Reborn ASL] " + output));

	vars.TimerModel = new TimerModel { CurrentState = timer };
	var Stages = new Dictionary<int, string>
	{
		{ 1, "Longling Tomb" },
		{ 2, "Anxi Desert" },
		{ 3, "Duo Fjord" }
	};

	for (int stageID = 1; stageID <= Stages.Count; ++stageID)
	{
		int max = stageID == 1 ? 5 : 4;

		settings.Add("layer" + stageID, true, "Split after completing a stage in " + Stages[stageID] + ":");

		for (int levelID = 0; levelID <= max; ++levelID)
		{
			if (stageID != 1 && levelID == 0)
				settings.Add(stageID + "-0to" + stageID + "-1", false, Stages[stageID] + " Entrance", "layer" + stageID);
			else if (levelID > 0 && levelID < max)
				settings.Add(stageID + "-" + levelID + "to" + stageID + "-" + (levelID + 1), true, "Stage " + levelID, "layer" + stageID);
			else if (stageID != 3 && levelID == max)
				settings.Add(stageID + "-" + levelID + "to" + (stageID + 1) + "-0", true, Stages[stageID] + " Boss", "layer" + stageID);
		}
	}

	settings.Add("finalSplit", true, "Duo Fjord Boss", "layer3");

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var Result = MessageBox.Show(
			"Gunfire Reborn uses in-game time.\nWould you like to switch to it?",
			"Gunfire Reborn Autosplitter",
			MessageBoxButtons.YesNo);

		if (Result == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}

init
{
	var GameAssembly = modules.FirstOrDefault(m => m.ModuleName == "GameAssembly.dll");
	var AssemblyScanner = new SignatureScanner(game, GameAssembly.BaseAddress, GameAssembly.ModuleMemorySize);

	Func<IntPtr, int, IntPtr> FromRelativeAddress = (ptr, size) =>
		ptr + size + game.ReadValue<int>(ptr);

	var WarCacheSig = new SigScanTarget(3, "48 8B 05 ???????? 48 8B 80 ???????? 33 C9 C6 00 01");
	var GameUtilitySig = new SigScanTarget(3, "48 8B 0D ???????? F3 41 0F 59 F4");

	var WarCache = FromRelativeAddress(AssemblyScanner.Scan(WarCacheSig), 4);
	var SceneManager = FromRelativeAddress(AssemblyScanner.Scan(WarCacheSig) + 0xDF, 4);
	var GameUtility = FromRelativeAddress(AssemblyScanner.Scan(GameUtilitySig), 4);

	if (!(vars.SigsFound = new[] { WarCache, SceneManager, GameUtility }.All(a => a != IntPtr.Zero))) return;

	vars.Watchers = new MemoryWatcherList
	{
		new MemoryWatcher<byte>(new DeepPointer(WarCache, 0xB8, 0x70, 0x1C)) { Name = "Level" },
		new MemoryWatcher<byte>(new DeepPointer(WarCache, 0xB8, 0x70, 0x20)) { Name = "Layer" },
		new MemoryWatcher<bool>(new DeepPointer(SceneManager, 0xB8, 0x10)) { Name = "InWar" },
		new MemoryWatcher<int>(new DeepPointer(GameUtility, 0xB8, 0x30)) { Name = "Time" }
	};

	timer.IsGameTimePaused = false;
}

update
{
	if (!vars.SigsFound) return false;

	vars.Watchers.UpdateAll(game);
	current.Level = vars.Watchers["Level"].Current;
	current.Layer = vars.Watchers["Layer"].Current;
	current.IsInWar = vars.Watchers["InWar"].Current;
	current.HalfTime = vars.Watchers["Time"].Current;

	if (!(current.Layer == 3 && current.Level == 4) && old.IsInWar && !current.IsInWar)
		vars.TimerModel.Pause();
}

start
{
	return current.Layer == 1 && current.Level == 1 && old.HalfTime == 0 && current.HalfTime > 0;
}

split
{
	bool finalSplit = current.Layer == 3 && current.Level == 4 && old.IsInWar && !current.IsInWar && old.HalfTime == current.HalfTime;

	return old.Level != current.Level && settings[old.Layer + "-" + old.Level + "to" + current.Layer + "-" + current.Level] ||
	       finalSplit &&settings["finalSplit"];
}

reset
{
	return old.Layer != 0 && current.Layer == 0;
}

gameTime
{
	return TimeSpan.FromMilliseconds(current.HalfTime * 20);
}

isLoading
{
	return true;
}

exit
{
	timer.IsGameTimePaused = true;
}