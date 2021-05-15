state("Phasmophobia") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Phasmophobia ASL] " + output.ToString()));

	settings.Add("header", true, "Split when these conditions are fulfilled, reset if not:");
		settings.Add("miss", true, "All objectives are completed", "header");
		settings.Add("evid", true, "All evidences and the ghost type are set", "header");
}

init
{
	vars.SigsFound = false;
	vars.TokenSource = new CancellationTokenSource();
	vars.SigThread = new Thread(() =>
	{
		vars.Dbg("Starting signature thread.");

		IntPtr LevelValues = IntPtr.Zero, LevelController = IntPtr.Zero, SceneManager = IntPtr.Zero;
		var LevelValuesSig = new SigScanTarget(7, "84 C0 75 ?? 48 8B 05 ???????? 48 8B 80 B8 00 00 00 48 8B 00 48 83");
		var LevelControllerSig = new SigScanTarget(3, "48 8B 05 ???????? 48 8B 88 ???????? 48 8B 01 48 8B C8");
		var SceneManagerSig = new SigScanTarget(3, "48 8B 0D ???????? 48 8D 55 ?? 89 45 ?? 0F B6 85");

		foreach (SigScanTarget sig in new[] { LevelValuesSig, LevelControllerSig, SceneManagerSig })
			sig.OnFound = (p, s, ptr) => IntPtr.Add(ptr + 4, p.ReadValue<int>(ptr));

		var Token = vars.TokenSource.Token;
		while (!Token.IsCancellationRequested)
		{
			var GameModules = game.ModulesWow64Safe();
			var GameAssembly = GameModules.FirstOrDefault(m => m.ModuleName == "GameAssembly.dll");
			var UnityPlayer = GameModules.FirstOrDefault(m => m.ModuleName == "UnityPlayer.dll");
			if (GameAssembly == null || UnityPlayer == null)
			{
				vars.Dbg("Modules not found! Retrying.");
				Thread.Sleep(2000);
				continue;
			}

			var GameAssemblyScanner = new SignatureScanner(game, GameAssembly.BaseAddress, GameAssembly.ModuleMemorySize);
			var UnityPlayerScanner = new SignatureScanner(game, UnityPlayer.BaseAddress, UnityPlayer.ModuleMemorySize);

			if (LevelValues == IntPtr.Zero && (LevelValues = GameAssemblyScanner.Scan(LevelValuesSig)) != IntPtr.Zero)
				vars.Dbg("Found LevelValues: 0x" + (LevelValues -= 0x28).ToString("X"));

			if (LevelController == IntPtr.Zero && (LevelController = GameAssemblyScanner.Scan(LevelControllerSig)) != IntPtr.Zero)
				vars.Dbg("Found LevelController: 0x" + LevelController.ToString("X"));

			if (SceneManager == IntPtr.Zero && (SceneManager = UnityPlayerScanner.Scan(SceneManagerSig)) != IntPtr.Zero)
				vars.Dbg("Found SceneManager: 0x" + SceneManager.ToString("X"));

			if (!(vars.SigsFound = new[] { LevelValues, LevelController, SceneManager }.All(a => a != IntPtr.Zero)))
			{
				vars.Dbg("Not all signatures found! Retrying.");
				Thread.Sleep(2000);
				continue;
			}
			else
			{
				vars.Watchers = new MemoryWatcherList
				{
					new MemoryWatcher<bool>(new DeepPointer(LevelValues, 0xB8, 0x0, 0x1A)) { Name = "IsTutorial" },
					new MemoryWatcher<bool>(new DeepPointer(LevelValues, 0xB8, 0x0, 0x24)) { Name = "M1Complete" },
					new MemoryWatcher<bool>(new DeepPointer(LevelValues, 0xB8, 0x0, 0x25)) { Name = "M2Complete" },
					new MemoryWatcher<bool>(new DeepPointer(LevelValues, 0xB8, 0x0, 0x26)) { Name = "M3Complete" },
					new MemoryWatcher<bool>(new DeepPointer(LevelValues, 0xB8, 0x0, 0x27)) { Name = "M4Complete" },
					new MemoryWatcher<byte>(new DeepPointer(LevelController, 0xB8, 0x0, 0x78, 0xE0)) { Name = "E1Index" },
					new MemoryWatcher<byte>(new DeepPointer(LevelController, 0xB8, 0x0, 0x78, 0xF0)) { Name = "E2Index" },
					new MemoryWatcher<byte>(new DeepPointer(LevelController, 0xB8, 0x0, 0x78, 0x100)) { Name = "E3Index" },
					new MemoryWatcher<byte>(new DeepPointer(LevelController, 0xB8, 0x0, 0x78, 0x110)) { Name = "GhostIndex" },
					new MemoryWatcher<bool>(new DeepPointer(LevelController, 0xB8, 0x0, 0x88, 0x80)) { Name = "PlayersConnected" },
					new MemoryWatcher<bool>(new DeepPointer(LevelController, 0xB8, 0x0, 0x88, 0x81)) { Name = "LoadingBackToMenu" }
				};
				vars.Watchers["LoadingBackToMenu"].Old = true;

				Func<string, string> PathToName = (path) =>
				{
					if (String.IsNullOrEmpty(path) || !path.StartsWith("Assets/")) return null;

					int from = path.LastIndexOf('/') + 1;
					int to = path.LastIndexOf(".unity");
					return path.Substring(from, to - from);
				};

				old.ThisScene = "";
				old.NextScene = "";
				vars.UpdateScenes = (Action) (() =>
				{
					current.ThisScene = PathToName(new DeepPointer(SceneManager, 0x48, 0x10, 0x0).DerefString(game, 128)) ?? old.ThisScene;
					current.NextScene = PathToName(new DeepPointer(SceneManager, 0x28, 0x0, 0x10, 0x0).DerefString(game, 128)) ?? old.NextScene;
				});
				break;
			}
		}

		vars.Dbg("Exiting signature thread.");
	});
	vars.SigThread.Start();

	vars.AllEvidenceSet = false;
	vars.AllMissionsDone = false;
	vars.Stopwatch = new Stopwatch();
	vars.DoOnTrue = (Func<bool, bool>) ((condition) =>
	{
		if (condition)
		{
			vars.Stopwatch.Reset();
			return true;
		}

		return false;
	});
}

update
{
	if (!vars.SigsFound) return false;

	vars.Watchers.UpdateAll(game);
	vars.UpdateScenes();

	vars.AllEvidenceSet = new[]
	{
		vars.Watchers["E1Index"].Current,
		vars.Watchers["E2Index"].Current,
		vars.Watchers["E3Index"].Current,
		vars.Watchers["GhostIndex"].Current
	}.All(i => i > 0);

	vars.AllMissionsDone = new[]
	{
		vars.Watchers["M1Complete"].Current,
		vars.Watchers["M2Complete"].Current,
		vars.Watchers["M3Complete"].Current,
		vars.Watchers["M4Complete"].Current
	}.All(m => m == true);

	if (!vars.Watchers["LoadingBackToMenu"].Old && vars.Watchers["LoadingBackToMenu"].Current) {
		vars.Dbg("yo shit");
		vars.Stopwatch.Start();
	}
}

start
{
	return !vars.Watchers["PlayersConnected"].Old && vars.Watchers["PlayersConnected"].Current;
}

split
{
	if (vars.Stopwatch.ElapsedMilliseconds >= 8950)
	{
		if (!settings["evid"] && !settings["miss"]) return vars.DoOnTrue(true);

		return vars.DoOnTrue(vars.AllEvidenceSet && settings["evid"] || vars.AllMissionsDone && settings["miss"]);
	}
}

reset
{
	if (vars.Stopwatch.ElapsedMilliseconds >= 8950)
	{
		if (!settings["evid"]) return false;

		return vars.DoOnTrue(!vars.AllEvidenceSet && settings["evid"] || !vars.AllMissionsDone && settings["miss"]);
	}
}

isLoading
{
	return current.ThisScene != current.NextScene || current.ThisScene != "Menu_New" && !vars.Watchers["PlayersConnected"].Current;
}

exit
{
	vars.TokenSource.Cancel();
}

shutdown
{
	vars.TokenSource.Cancel();
}