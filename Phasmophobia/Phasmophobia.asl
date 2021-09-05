state("Phasmophobia") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Phasmophobia ASL] " + output));

	settings.Add("header", true, "Split when these conditions are fulfilled, reset if not:");
		settings.Add("miss", true, "All objectives are completed", "header");
		settings.Add("evid", true, "All evidences and the ghost type are set", "header");

	vars.Stopwatch = new Stopwatch();
	vars.TimerSplit = (EventHandler) ((s, e) => vars.Stopwatch.Reset());
	vars.TimerReset = (LiveSplit.Model.Input.EventHandlerT<TimerPhase>) ((s, e) => vars.Stopwatch.Reset());
	timer.OnSplit += vars.TimerSplit;
	timer.OnReset += vars.TimerReset;
}

init
{
	var classes = new Dictionary<string, IntPtr>
	{
		{ "LevelValues", IntPtr.Zero },
		{ "LevelController", IntPtr.Zero }
	};

	vars.TokenSource = new CancellationTokenSource();
	vars.SigThread = new Thread(() =>
	{
		vars.Dbg("Starting scan thread.");

		ProcessModuleWow64Safe gameAssembly = null, unityPlayer = null;
		IntPtr classSequence = IntPtr.Zero, sceneManager = IntPtr.Zero;

		var classSequenceTrg = new SigScanTarget(3, "48 8B 05 ???????? 48 83 3C ?? 00 75 ?? 48 8D 35")
		{ OnFound = (p, s, ptr) => p.ReadPointer(ptr + 0x4 + p.ReadValue<int>(ptr)) + 0x18 };

		var sceneManagerTrg = new SigScanTarget(3, "48 8B 0D ???????? 48 8D 55 ?? 89 45 ?? 0F B6 85")
		{ OnFound = (p, s, ptr) => ptr + 0x4 + p.ReadValue<int>(ptr) };

		var token = vars.TokenSource.Token;
		while (!token.IsCancellationRequested)
		{
			var mods = game.ModulesWow64Safe();
			gameAssembly = mods.FirstOrDefault(m => m.ModuleName == "GameAssembly.dll");
			unityPlayer = mods.FirstOrDefault(m => m.ModuleName == "UnityPlayer.dll");

			if (gameAssembly != null && unityPlayer != null)
				break;

			vars.Dbg("Modules not found! Retrying.");
			Thread.Sleep(2000);
		}

		while (!token.IsCancellationRequested)
		{
			var gaScanner = new SignatureScanner(game, gameAssembly.BaseAddress, gameAssembly.ModuleMemorySize);
			var upScanner = new SignatureScanner(game, unityPlayer.BaseAddress, unityPlayer.ModuleMemorySize);

			if (classSequence == IntPtr.Zero && (classSequence = gaScanner.Scan(classSequenceTrg)) != IntPtr.Zero)
				vars.Dbg("Found 'ClassSequence' at 0x" + classSequence.ToString("X"));

			if (sceneManager == IntPtr.Zero && (sceneManager = upScanner.Scan(sceneManagerTrg)) != IntPtr.Zero)
				vars.Dbg("Found 'SceneManager' at 0x" + sceneManager.ToString("X"));

			if (new[] { classSequence, sceneManager }.All(addr => addr != IntPtr.Zero))
				break;

			vars.Dbg("Not all signatures resolved! Retrying.");
			Thread.Sleep(2000);
		}

		while (!token.IsCancellationRequested)
		{
			bool allFound = false;
			IntPtr klass = game.ReadPointer(classSequence);
			for (int i = 0; klass != IntPtr.Zero; i += 0x8, klass = game.ReadPointer(classSequence + i))
			{
				string name = new DeepPointer(klass + 0x10, 0x0).DerefString(game, 32);
				if (classes.Keys.Contains(name))
				{
					classes[name] = game.ReadPointer(klass + 0xB8);
					vars.Dbg("Found '" + name + "' at 0x" + classes[name].ToString("X") + ".");

					if (allFound = classes.Values.All(addr => addr != IntPtr.Zero))
						break;
				}
			}

			if (allFound)
				break;

			vars.Dbg("Not all classes found! Retrying.");
			Thread.Sleep(2000);
		}

		if (!token.IsCancellationRequested)
		{
			vars.GameWatchers = new MemoryWatcherList
			{
				new MemoryWatcher<bool>(new DeepPointer(classes["LevelValues"], 0x1A)) { Name = "IsTutorial" },
				new MemoryWatcher<bool>(new DeepPointer(classes["LevelValues"], 0x28)) { Name = "M1Complete" },
				new MemoryWatcher<bool>(new DeepPointer(classes["LevelValues"], 0x29)) { Name = "M2Complete" },
				new MemoryWatcher<bool>(new DeepPointer(classes["LevelValues"], 0x2A)) { Name = "M3Complete" },
				new MemoryWatcher<bool>(new DeepPointer(classes["LevelValues"], 0x2B)) { Name = "M4Complete" },
				new MemoryWatcher<byte>(new DeepPointer(classes["LevelController"], 0x68, 0xE8)) { Name = "E1Index" },
				new MemoryWatcher<byte>(new DeepPointer(classes["LevelController"], 0x68, 0xF8)) { Name = "E2Index" },
				new MemoryWatcher<byte>(new DeepPointer(classes["LevelController"], 0x68, 0x108)) { Name = "E3Index" },
				new MemoryWatcher<byte>(new DeepPointer(classes["LevelController"], 0x68, 0x118)) { Name = "GhostIndex" },
				new MemoryWatcher<bool>(new DeepPointer(classes["LevelController"], 0x78, 0x90)) { Name = "PlayersConnected" },
				new MemoryWatcher<bool>(new DeepPointer(classes["LevelController"], 0x78, 0x91)) { Name = "LoadingBackToMenu" }
			};

			vars.SceneWatchers = new MemoryWatcherList
			{
				new StringWatcher(new DeepPointer(sceneManager, 0x48, 0x10, 0x0), 128) { Name = "Active" },
				new StringWatcher(new DeepPointer(sceneManager, 0x28, 0x0, 0x10, 0x0), 128) { Name = "Loading" }
			};

			vars.GameWatchers["LoadingBackToMenu"].Old = true;
		}

		vars.Dbg("Exiting signature thread.");
	});

	vars.SigThread.Start();

	vars.AllEvidenceSet = false;
	vars.AllMissionsDone = false;
}

update
{
	if (vars.SigThread.IsAlive) return false;

	vars.GameWatchers.UpdateAll(game);
	vars.SceneWatchers.UpdateAll(game);

	vars.AllEvidenceSet = new[] {
		vars.GameWatchers["E1Index"].Current,
		vars.GameWatchers["E2Index"].Current,
		vars.GameWatchers["E3Index"].Current,
		vars.GameWatchers["GhostIndex"].Current
	}.All(i => i > 0);

	vars.AllMissionsDone = new[] {
		vars.GameWatchers["M1Complete"].Current,
		vars.GameWatchers["M2Complete"].Current,
		vars.GameWatchers["M3Complete"].Current,
		vars.GameWatchers["M4Complete"].Current
	}.All(m => m == true);

	if (!vars.GameWatchers["LoadingBackToMenu"].Old && vars.GameWatchers["LoadingBackToMenu"].Current)
		vars.Stopwatch.Start();

	vars.Dbg(vars.GameWatchers["LoadingBackToMenu"].Current);
}

start
{
	return !vars.GameWatchers["PlayersConnected"].Old && vars.GameWatchers["PlayersConnected"].Current;
}

split
{
	if (vars.Stopwatch.ElapsedMilliseconds >= 8950)
	{
		if (!settings["evid"] && !settings["miss"]) return true;

		return vars.AllEvidenceSet && settings["evid"] || vars.AllMissionsDone && settings["miss"];
	}
}

reset
{
	if (vars.Stopwatch.ElapsedMilliseconds >= 8967)
	{
		return !vars.AllEvidenceSet && settings["evid"] || !vars.AllMissionsDone && settings["miss"];
	}
}

isLoading
{
	return vars.SceneWatchers["Active"].Current != vars.SceneWatchers["Loading"].Current ||
	       vars.SceneWatchers["Active"].Current != "Assets/Scenes/Menu_New.unity" && !vars.GameWatchers["PlayersConnected"].Current;
}

exit
{
	vars.TokenSource.Cancel();
}

shutdown
{
	vars.TokenSource.Cancel();
	timer.OnSplit -= vars.TimerSplit;
	timer.OnReset -= vars.TimerReset;
}