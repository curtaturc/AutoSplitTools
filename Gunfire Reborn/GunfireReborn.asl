state("Gunfire Reborn") {}

startup
{
	vars.TimerModel = new TimerModel { CurrentState = timer };
	var Stages = new Dictionary<int, string>
	{
		{1, "Longling Tomb"},
		{2, "Anxi Desert"},
		{3, "Duo Fjord"}
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
	// Shoutouts to 2838 for this piece of code: https://github.com/thisis2838
	Func<IntPtr, int, int, IntPtr> PtrFromOpcode = (ptr, trgOperandOffset, totalSize) =>
	{
		byte[] bytes = memory.ReadBytes(ptr + trgOperandOffset, 4);
		if (bytes == null) return IntPtr.Zero;

		Array.Reverse(bytes);
		int offset = Convert.ToInt32(BitConverter.ToString(bytes).Replace("-",""),16);
		IntPtr actualPtr = IntPtr.Add(ptr + totalSize, offset);
		return actualPtr;
	};

	ProcessModuleWow64Safe AssemblyModule = modules.FirstOrDefault(x => x.ModuleName == "GameAssembly.dll");
	var AssemblyScanner = new SignatureScanner(game, AssemblyModule.BaseAddress, AssemblyModule.ModuleMemorySize);

	var WarCacheSig = new SigScanTarget("48 8B 05 ???????? 48 8B 80 ???????? 33 C9 C6 00 01");
	var GameUtilitySig = new SigScanTarget("48 8B 0D ???????? 0F 29 74 24 ?? F3 0F 10 73 ?? F6 81 27 01 ???? 02 74 ?? 83 B9 ???????? 00 75 ?? E8 ???????? 33 C9");
	IntPtr WarCachePtr = IntPtr.Zero, SceneManagerPtr = IntPtr.Zero, GameUtilityPtr = IntPtr.Zero;

	var Timeout = new Stopwatch();
	vars.SigsFound = false;

	Timeout.Start();
	while (!vars.SigsFound)
	{
		vars.SigsFound = new[]
		{
			WarCachePtr = PtrFromOpcode(AssemblyScanner.Scan(WarCacheSig), 3, 7),
			SceneManagerPtr = PtrFromOpcode(AssemblyScanner.Scan(WarCacheSig) + 0x18, 3, 7),
			GameUtilityPtr = PtrFromOpcode(AssemblyScanner.Scan(GameUtilitySig), 3, 7)
		}.All(addr => addr != IntPtr.Zero);
		if (Timeout.ElapsedMilliseconds >= 5000) break;
	}
	Timeout.Reset();

	if (!vars.SigsFound) return;

	vars.Watchers = new MemoryWatcherList
	{
		new MemoryWatcher<byte>(new DeepPointer(WarCachePtr, 0xB8, 0x60, 0x1C)) { Name = "Level" },
		new MemoryWatcher<byte>(new DeepPointer(WarCachePtr, 0xB8, 0x60, 0x20)) { Name = "Layer" },
		new MemoryWatcher<bool>(new DeepPointer(SceneManagerPtr, 0xB8, 0xC)) { Name = "InWar" },
		new MemoryWatcher<int>(new DeepPointer(GameUtilityPtr, 0xB8, 0x30)) { Name = "Time" }
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