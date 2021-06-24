state ("CityOfBeatsDemo-Win64-Shipping") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[City of Beats ASL] " + output));
}

init
{
	vars.TokenSource = new CancellationTokenSource();
	vars.ScanThread = new Thread(() =>
	{
		vars.Dbg("Starting scan thread.");

		var ProcScanner = new SignatureScanner(game, game.MainModule.BaseAddress, game.MainModule.ModuleMemorySize);
		var UWorld = IntPtr.Zero;
		var UWorldTrg = new SigScanTarget(3, "48 8B 05 ???????? 49 8B D3 45 33 C0")
		{ OnFound = (p, s, ptr) => ptr + 0x4 + p.ReadValue<int>(ptr) };

		while (!vars.TokenSource.Token.IsCancellationRequested)
		{
			if (UWorld == IntPtr.Zero && (UWorld = ProcScanner.Scan(UWorldTrg)) != IntPtr.Zero)
				vars.Dbg("Found UWorld at " + UWorld.ToString("X"));

			if (new[] { UWorld }.Any(a => a == IntPtr.Zero))
			{
				vars.Dbg("Not all signatures could be resolved. Retrying.");
				Thread.Sleep(2000);
				continue;
			}

			vars.Watchers = new MemoryWatcherList
			{
				new MemoryWatcher<bool>(new DeepPointer(UWorld, 0x120, 0x280, 0x230)) { Name = "CurrentNodeFinished" },
				new MemoryWatcher<bool>(new DeepPointer(UWorld, 0x120, 0x280, 0x231)) { Name = "ExpeditionOngoing" },
				new MemoryWatcher<float>(new DeepPointer(UWorld, 0x120, 0x24C)) { Name = "WorldTime" },
				new MemoryWatcher<int>(new DeepPointer(UWorld, 0x30, 0xE8, 0x2A0, 0x2F0, 0x4D8, 0x170)) { Name = "BossHealth" }
			};

			break;
		}

		vars.Dbg("Exiting scan thread.");
	});

	vars.ScanThread.Start();

	vars.StartTime = 0;
}

update
{
	if (vars.ScanThread.IsAlive) return false;
	vars.Watchers.UpdateAll(game);
}

start
{
	if (!vars.Watchers["ExpeditionOngoing"].Old && vars.Watchers["ExpeditionOngoing"].Current)
	{
		vars.StartTime = vars.Watchers["WorldTime"].Current;
		return true;
	}
}

split
{
	return !vars.Watchers["CurrentNodeFinished"].Old && vars.Watchers["CurrentNodeFinished"].Current ||
	       vars.Watchers["BossHealth"].Old > 0 && vars.Watchers["BossHealth"].Current == 0;
}

reset
{
	return vars.Watchers["ExpeditionOngoing"].Old && !vars.Watchers["ExpeditionOngoing"].Current;
}

gameTime
{
	return TimeSpan.FromSeconds(vars.Watchers["WorldTime"].Current - vars.StartTime);
}

isLoading
{
	return true;
}

exit
{
	vars.TokenSource.Cancel();
}

shutdown
{
	vars.TokenSource.Cancel();
}