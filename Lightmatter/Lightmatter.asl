state("LightmatterSub") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Lightmatter ASL] " + output));

	settings.Add("ilTime", false, "Individual Level timer behavior (hover for info)");
}

init
{
	var CLASSES = new Dictionary<string, Tuple<uint, int>>
	{
		{ "Player_Manager", Tuple.Create((uint)(0x20001D2), 0xD0) },
		{ "EventLogManager", Tuple.Create((uint)(0x20000BB), 0x60) }
	};

	vars.CancelSource = new CancellationTokenSource();
	vars.MonoThread = new Thread(() =>
	{
		vars.Dbg("Starting mono thread.");

		IntPtr class_cache = IntPtr.Zero;
		int class_count = 0;

		var token = vars.CancelSource.Token;
		while (!token.IsCancellationRequested)
		{
			if (game.ModulesWow64Safe().FirstOrDefault(m => m.ModuleName == "mono-2.0-bdwgc.dll") != null)
			{
				class_count = new DeepPointer("mono-2.0-bdwgc.dll", 0x4950C0, 0x10, 0x1D0, 0x8, 0x4D8).Deref<int>(game);
				class_cache = new DeepPointer("mono-2.0-bdwgc.dll", 0x4950C0, 0x10, 0x1D0, 0x8, 0x4E0).Deref<IntPtr>(game);

				if (class_count != 0)
					break;
			}

			vars.Dbg("Mono module not found.");
			Thread.Sleep(2000);
		}

		vars.Mono = new Dictionary<string, IntPtr>();

		while (!token.IsCancellationRequested)
		{
			foreach (var entry in CLASSES)
			{
				var klass = game.ReadPointer(class_cache + 0x8 * (int)(entry.Value.Item1 % class_count));
				for (; klass != IntPtr.Zero; klass = game.ReadPointer(klass + 0x108))
				{
					string class_name = new DeepPointer(klass + 0x48, 0x0).DerefString(game, 32);
					if (class_name != entry.Key)
						continue;

					vars.Mono[class_name] = new DeepPointer(klass + 0xD0, 0x8, entry.Value.Item2).Deref<IntPtr>(game);
					vars.Dbg("Found " + class_name + ".");
				}
			}

			if (vars.Mono.Count == CLASSES.Count)
				break;

			vars.Dbg("Not all classes found.");
			Thread.Sleep(5000);
		}

		vars.Dbg("Exiting mono thread.");
	});

	vars.MonoThread.Start();
}

update
{
	if (vars.MonoThread.IsAlive) return false;

	Dictionary<string, IntPtr> mono = vars.Mono;

	current.MovSpeed = new DeepPointer(mono["Player_Manager"], 0x40, 0x168).Deref<float>(game);
	current.Level = new DeepPointer(mono["Player_Manager"], 0x80, 0xA0).Deref<int>(game);
	current.LevelTime = game.ReadValue<float>(mono["EventLogManager"] + 0x0);
	current.GameTime = game.ReadValue<float>(mono["EventLogManager"] + 0x4);
	current.BtnCount = game.ReadValue<int>(mono["EventLogManager"] + 0x40);
}

start
{
	if (settings["ilTime"])
	{
		return old.LevelTime > current.LevelTime && old.Level == current.Level;
	}
	else
	{
		return old.GameTime == 0f && current.GameTime > 0f && current.Level == 0;
	}
}

split
{
	bool transitionedLevel = current.Level == old.Level + 1 && current.Level <= 37;

	if (settings["ilTime"])
	{
		return old.LevelTime > current.LevelTime && transitionedLevel;
	}
	else
	{
		bool pressedInFinalRoom = current.BtnCount == old.BtnCount + 1 && current.MovSpeed == 0.3f && current.Level == 37;

		return transitionedLevel || pressedInFinalRoom;
	}
}

reset
{
	bool returnToLvl1 = old.Level != 0 && current.Level == 0;
	bool returnToMenu = current.Level == 0 && old.GameTime > 0f && current.GameTime == 0f;
	bool timeResetSameLevel = old.LevelTime > current.LevelTime && old.Level == current.Level;

	return returnToLvl1 || returnToMenu || timeResetSameLevel && settings["ilTime"];
}

gameTime
{
	if (settings["ilTime"])
	{
		if (current.LevelTime >= 0.01f)
			return TimeSpan.FromSeconds(current.LevelTime);
	}
	else
	{
		if (current.GameTime >= 0.01f)
			return TimeSpan.FromSeconds(current.GameTime);
	}
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
	vars.CancelSource.Cancel();
}