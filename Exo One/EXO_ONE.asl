state("EXO ONE") {}

startup
{
	vars.Log = (Action<object>)((output) => print("[EXO ONE] " + output));
}

init
{
	var classes = new Dictionary<string, uint>
	{
		{ "GameManager", 0x2000214 },
		// { "LevelManager", 0x200023A }
	};

	vars.CancelSource = new CancellationTokenSource();
	vars.MonoThread = new Thread(() =>
	{
		vars.Log("Starting thread.");

		var class_count = 0;
		var class_cache = IntPtr.Zero;

		var cancelToken = vars.CancelSource.Token;
		while (!cancelToken.IsCancellationRequested)
		{
			if (game.ModulesWow64Safe().FirstOrDefault(m => m.ModuleName == "mono-2.0-bdwgc.dll") != null)
				break;

			vars.Log("Mono module not loaded.");
			Thread.Sleep(1000);
		}

		while (!cancelToken.IsCancellationRequested)
		{
			var table_size = new DeepPointer("mono-2.0-bdwgc.dll", 0x49A0C8, 0x18).Deref<int>(game);
			var slot = new DeepPointer("mono-2.0-bdwgc.dll", 0x49A0C8, 0x10, 0x8 * (int)(0xFA381AED % table_size)).Deref<IntPtr>(game);

			for (; slot != IntPtr.Zero; slot = game.ReadPointer(slot + 0x10))
			{
				var slot_key = new DeepPointer(slot, 0x0).DerefString(game, 32);
				if (slot_key != "Assembly-CSharp") continue;

				class_count = new DeepPointer(slot + 0x8, 0x4D8).Deref<int>(game);
				class_cache = new DeepPointer(slot + 0x8, 0x4E0).Deref<IntPtr>(game);
			}

			if (class_count > 0 && class_cache != IntPtr.Zero)
				break;

			vars.Log("Assembly-CSharp not found.");
			Thread.Sleep(1000);
		}

		while (!cancelToken.IsCancellationRequested)
		{
			var mono = classes.ToDictionary(token => token.Key, token => IntPtr.Zero);

			foreach (var token in classes)
			{
				var klass = game.ReadPointer(class_cache + 0x8 * (int)(token.Value % class_count));

				for (; klass != IntPtr.Zero; klass = game.ReadPointer(klass + 0x108))
				{
					var type_token = game.ReadValue<uint>(klass + 0x58);
					if (type_token != token.Value) continue;

					var vtable_size = game.ReadValue<int>(klass + 0x5C);
					mono[token.Key] = new DeepPointer(klass + 0xD0, 0x8, 0x40 + 0x8 * vtable_size).Deref<IntPtr>(game);

					vars.Log("Found " + token.Key + " at 0x" + mono[token.Key].ToString("X") + ".");
					break;
				}
			}

			if (mono.Values.All(ptr => ptr != IntPtr.Zero))
			{
				vars.Data = new MemoryWatcherList
				{
					new MemoryWatcher<bool>(new DeepPointer(mono["GameManager"], 0x98, 0x10, 0x19)) { Name = "intro" },
					new MemoryWatcher<bool>(new DeepPointer(mono["GameManager"], 0xCC)) { Name = "warping" },
					new MemoryWatcher<float>(new DeepPointer(mono["GameManager"], 0xDC)) { Name = "TDtime" },
				};

				break;
			}

			vars.Log("Not all classes found.");
			Thread.Sleep(5000);
		}

		vars.Log("Exiting thread.");
	});

	vars.MonoThread.Start();
}

update
{
	if (vars.MonoThread.IsAlive || !((IDictionary<string, dynamic>)vars).ContainsKey("Data"))
		return false;

	vars.Data.UpdateAll(game);
}

start
{
	return !vars.Data["intro"].Old && vars.Data["intro"].Current;
}

split
{
	return !vars.Data["warping"].Old && vars.Data["warping"].Current;
}

reset
{
	return !vars.Data["intro"].Old && vars.Data["intro"].Current;
}

gameTime
{
	return TimeSpan.FromSeconds(vars.Data["TDtime"].Current);
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