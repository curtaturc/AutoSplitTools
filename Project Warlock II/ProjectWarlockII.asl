state("Project Warlock 2 Demo") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[PW2D ASL] " + output));

	settings.Add("keys", false, "Split when collecting a key");

	vars.TimerStart = (EventHandler) ((s, e) => vars.TimeBetweenDeaths = TimeSpan.Zero);
	timer.OnStart += vars.TimerStart;
}

init
{
	var CLASSES = new Dictionary<string, uint>
	{
		{ "PlayerManager", (uint)(0x200023C) }
	};

	vars.CancelSource = new CancellationTokenSource();
	vars.MonoThread = new Thread(() =>
	{
		vars.Dbg("Starting mono thread.");

		int class_count = 0;
		IntPtr class_cache = IntPtr.Zero;

		var token = vars.CancelSource.Token;
		while (!token.IsCancellationRequested)
		{
			if (game.ModulesWow64Safe().FirstOrDefault(m => m.ModuleName == "mono-2.0-bdwgc.dll") != null)
				break;

			vars.Dbg("Mono module not loaded yet.");
			Thread.Sleep(2000);
		}

		while (!token.IsCancellationRequested)
		{
			int size = new DeepPointer("mono-2.0-bdwgc.dll", 0x4990C0, 0x18).Deref<int>(game);
			IntPtr slot = new DeepPointer("mono-2.0-bdwgc.dll", 0x4990C0, 0x10, 0x8 * (int)(0xFA381AED % size)).Deref<IntPtr>(game);

			for (; slot != IntPtr.Zero; slot = game.ReadPointer(slot + 0x10))
			{
				string key = new DeepPointer(slot + 0x0, 0x0).DerefString(game, 32);
				if (key != "Assembly-CSharp")
					continue;

				class_count = new DeepPointer(slot + 0x8, 0x4D8).Deref<int>(game);
				class_cache = new DeepPointer(slot + 0x8, 0x4E0).Deref<IntPtr>(game);
				break;
			}

			if (class_cache != IntPtr.Zero)
				break;

			vars.Dbg("Assembly-CSharp could not be found.");
			Thread.Sleep(2000);
		}

		var mono = new Dictionary<string, IntPtr>();

		while (!token.IsCancellationRequested)
		{
			bool allFound = false;
			foreach (var classEntry in CLASSES)
			{
				var klass = game.ReadPointer(class_cache + 0x8 * (int)(classEntry.Value % class_count));
				for (; klass != IntPtr.Zero; klass = game.ReadPointer(klass + 0x108))
				{
					string class_name = new DeepPointer(klass + 0x48, 0x0).DerefString(game, 64);
					if (class_name != classEntry.Key)
						continue;

					var instance = new DeepPointer(klass + 0xD0, 0x8, 0x90, 0x0).Deref<IntPtr>(game);
					if (instance != IntPtr.Zero)
					{
						mono[class_name] = instance;
						vars.Dbg("Found " + class_name + " at 0x" + instance.ToString("X"));
					}

					if (allFound = mono.Count == CLASSES.Count)
						break;
				}

				if (allFound)
					break;
			}

			if (allFound)
			{
				vars.Watchers = new MemoryWatcherList
				{
					new MemoryWatcher<bool>(new DeepPointer(mono["PlayerManager"] + 0xE8, 0xAE)) { Name = "demoEnd" },
					new MemoryWatcher<int>(new DeepPointer(mono["PlayerManager"] + 0xE8, 0xB0)) { Name = "gamestate" },
					new MemoryWatcher<float>(new DeepPointer(mono["PlayerManager"] + 0xE8, 0x68, 0x18)) { Name = "seconds" },
					new MemoryWatcher<int>(new DeepPointer(mono["PlayerManager"] + 0xE8, 0x68, 0x1C)) { Name = "minutes" },
					new MemoryWatcher<int>(new DeepPointer(mono["PlayerManager"] + 0xE8, 0x68, 0x20)) { Name = "hours" },
					new MemoryWatcher<bool>(new DeepPointer(mono["PlayerManager"] + 0xE8, 0x68, 0x24)) { Name = "started" },
					new MemoryWatcher<bool>(new DeepPointer(mono["PlayerManager"] + 0x100, 0x70, 0x20)) { Name = "redKey" },
					new MemoryWatcher<bool>(new DeepPointer(mono["PlayerManager"] + 0x100, 0x70, 0x21)) { Name = "blueKey" },
					new MemoryWatcher<bool>(new DeepPointer(mono["PlayerManager"] + 0x100, 0x70, 0x22)) { Name = "yellowKey" }
				};

				break;
			}

			vars.Dbg("Not all classes found.");
			Thread.Sleep(5000);
		}

		vars.Dbg("Exiting mono thread.");
	});

	vars.MonoThread.Start();
	vars.TimeBetweenDeaths = TimeSpan.Zero;
}

update
{
	if (vars.MonoThread.IsAlive) return false;

	vars.Watchers.UpdateAll(game);

	float s = vars.Watchers["seconds"].Current;
	int m = vars.Watchers["minutes"].Current;
	int h = vars.Watchers["hours"].Current;

	current.GameTime = TimeSpan.FromSeconds(s + m * 60 + h * 3600);
}

start
{
	return vars.Watchers["gamestate"].Old == 3 && vars.Watchers["gamestate"].Current == 1;
}

split
{
	return !vars.Watchers["demoEnd"].Old && vars.Watchers["demoEnd"].Current ||
	       settings["keys"] && (!vars.Watchers["redKey"].Old && vars.Watchers["redKey"].Current ||
	                            !vars.Watchers["blueKey"].Old && vars.Watchers["blueKey"].Current ||
	                            !vars.Watchers["yellowKey"].Old && vars.Watchers["yellowKey"].Current);
}

reset
{
	return vars.Watchers["gamestate"].Changed && vars.Watchers["gamestate"].Current == 5;
}

gameTime
{
	if (old.GameTime > current.GameTime)
		vars.TimeBetweenDeaths += old.GameTime - current.GameTime;

	if (vars.Watchers["started"].Current)
		return current.GameTime + vars.TimeBetweenDeaths;
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