state("Grappler!") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Grapple! ASL] " + output));

	settings.Add("ilReset", false, "Reset timer when restarting a level");

	vars.TimerStart = (EventHandler) ((s, e) => vars.TotalTime = 0f);
	timer.OnStart += vars.TimerStart;
}

init
{
	var classes = new Dictionary<string, int>
	{
		{ "GameplayManager", 0x200000B }
	};

	Func<string, ProcessModuleWow64Safe> getModule = (moduleName)
		=> game.ModulesWow64Safe().FirstOrDefault(m => m.ModuleName == moduleName);

	vars.CancelSource = new CancellationTokenSource();
	vars.MonoThread = new Thread(() =>
	{
		vars.Dbg("Starting mono thread.");

		ProcessModuleWow64Safe unity = null;
		var token = vars.CancelSource.Token;
		while (!token.IsCancellationRequested)
		{
			if (getModule("mono-2.0-bdwgc.dll") == null || (unity = getModule("UnityPlayer.dll")) == null)
			{
				vars.Dbg("Mono module not found. Retrying.");
				Thread.Sleep(2000);
				continue;
			}

			var unityScanner = new SignatureScanner(game, unity.BaseAddress, unity.ModuleMemorySize);
			var sceneMngrTrg = new SigScanTarget(3, "48 8B 1D ???????? 0F 57 C0")
			{ OnFound = (p, s, ptr) => ptr + 0x4 + p.ReadValue<int>(ptr) };
			var sceneManager = unityScanner.Scan(sceneMngrTrg);

			var mono = new Dictionary<string, IntPtr>();
			var size = new DeepPointer("mono-2.0-bdwgc.dll", 0x49A0C8, 0x10, 0x1D0, 0x8, 0x4D8).Deref<int>(game);

			if (size == 0)
			{
				vars.Dbg("Class cache not initialized yet. Retrying.");
				Thread.Sleep(2000);
				continue;
			}

			var cache = new DeepPointer("mono-2.0-bdwgc.dll", 0x49A0C8, 0x10, 0x1D0, 0x8, 0x4E0).Deref<IntPtr>(game);
			foreach (var cls in classes)
			{
				var klass = game.ReadPointer(cache + 0x8 * (int)(cls.Value % size));
				for (int i = 0; klass != IntPtr.Zero && i < 5; klass = game.ReadPointer(klass + 0x108), ++i)
				{
					if (game.ReadValue<int>(klass + 0x58) != cls.Value) continue;
					mono[cls.Key] = new DeepPointer(klass + 0xD0, 0x8, 0x60).Deref<IntPtr>(game);
					vars.Dbg(cls.Key + ": 0x" + mono[cls.Key].ToString("X"));
					break;
				}
			}

			if (mono.Count == 0 || mono.Values.Any(ptr => ptr == IntPtr.Zero) || sceneManager == IntPtr.Zero)
			{
				vars.Dbg("Not all pointers resolved. Retrying.");
				Thread.Sleep(1000);
				continue;
			}

			vars.GameplayWatchers = new MemoryWatcherList
			{
				// new MemoryWatcher<bool>(new DeepPointer(mono["GameplayManager"], 0x38)) { Name = "levelComplete" },
				new MemoryWatcher<bool>(new DeepPointer(mono["GameplayManager"], 0x39)) { Name = "shouldIncrement" },
				new MemoryWatcher<bool>(new DeepPointer(mono["GameplayManager"], 0x3B)) { Name = "reset" },
				new MemoryWatcher<float>(new DeepPointer(mono["GameplayManager"], 0x3C)) { Name = "timeElapsed" },
				new MemoryWatcher<bool>(new DeepPointer(mono["GameplayManager"], 0x40)) { Name = "firstJump" },
				// new MemoryWatcher<int>(new DeepPointer(mono["GameplayManager"], 0x44)) { Name = "levelNum" }
			};

			vars.ActiveSceneId = new MemoryWatcher<int>(new DeepPointer(sceneManager, 0x50, 0x0, 0x98));

			vars.Dbg("All pointers found successfully.");
			break;
		}

		vars.Dbg("Exiting mono thread.");
	});

	vars.MonoThread.Start();

	vars.TotalTime = 0f;
}

update
{
	if (vars.MonoThread.IsAlive) return false;

	vars.ActiveSceneId.Update(game);
	vars.GameplayWatchers.UpdateAll(game);

	current.Scene = vars.ActiveSceneId.Current;
	current.ShouldIncrement = vars.GameplayWatchers["shouldIncrement"].Current;
	current.Reset = vars.GameplayWatchers["reset"].Current;
	current.Time = vars.GameplayWatchers["timeElapsed"].Current;
	current.FirstJump = vars.GameplayWatchers["firstJump"].Current;
}

start
{
	return !old.FirstJump && current.FirstJump;
}

split
{
	return old.Scene < current.Scene && current.Scene > 0;
}

reset
{
	return old.Scene != 0 && current.Scene == 0 ||
	       (!old.Reset && current.Reset || old.FirstJump && !current.FirstJump) && (settings["ilReset"] ? true : current.Scene == 1);
}

gameTime
{
	if (old.FirstJump && !current.FirstJump)
		vars.TotalTime += old.Time;

	return TimeSpan.FromSeconds(vars.TotalTime + current.Time);
}

isLoading
{
	return true;
}

exit
{
	vars.CancelSource.Cancel();
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
	vars.CancelSource.Cancel();
}