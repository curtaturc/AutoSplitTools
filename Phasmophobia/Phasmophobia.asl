state("Phasmophobia") {}

startup
{
	vars.sW = new Stopwatch();
	vars.doOnTrue = (Func<bool, bool>) ((cond) => { if (cond) { vars.sW.Reset(); return true; } else return false; });

	settings.Add("header", true, "Split ONLY when these conditions are met, reset if not:");
		settings.Add("miss", true, "Objectives must be completed", "header");
		settings.Add("evid", true, "Evidences and ghost type must be set", "header");
}

init
{
	vars.sW.Start();
	// SigScan code by 2838.
	Func<IntPtr, int, int, IntPtr> getPointerFromOpcode = (ptr, trgOperandOffset, totalSize) =>
	{
		byte[] bytes = memory.ReadBytes(ptr + trgOperandOffset, 4);
		if (bytes == null) return IntPtr.Zero;

		Array.Reverse(bytes);
		int offset = Convert.ToInt32(BitConverter.ToString(bytes).Replace("-", ""), 16);
		IntPtr actualPtr = IntPtr.Add((ptr + totalSize), offset);
		return actualPtr;
	};

	ProcessModuleWow64Safe assembly = modules.FirstOrDefault(x => x.ModuleName.ToLower() == "gameassembly.dll");
	var assemblyScanner = new SignatureScanner(game, assembly.BaseAddress, assembly.ModuleMemorySize);

	// Additional thanks to 2838's Ghidra signature script.
	var levelValuesSig = new SigScanTarget(9, "E8 ???????? 84 C0 75 ?? 48 8B 05 ???????? 48 8B 80 B8 00 00 00 48 8B 00 48 83 C4 20 5B C3");
	var levelControllerSig = new SigScanTarget(0, "48 8B 05 ???????? 48 8B 88 B8 00 00 00 48 8B 01 48 85 C0 0F 84 ?? 00 00 00 48 8B 40 28 48 85 C0 0F 84 ?? 00 00 00");
	IntPtr levelValuesPtr = IntPtr.Zero;
	IntPtr levelControllerPtr = IntPtr.Zero;

	vars.sigsFound = false;
	while (!vars.sigsFound)
	{
		levelValuesPtr = getPointerFromOpcode(assemblyScanner.Scan(levelValuesSig), 3, 7);
		levelControllerPtr = getPointerFromOpcode(assemblyScanner.Scan(levelControllerSig), 3, 7);
		vars.sigsFound = new[]{levelValuesPtr, levelControllerPtr}.All(x => x != IntPtr.Zero);
		if (vars.sW.ElapsedMilliseconds >= 15000)
		{
			MessageBox.Show("Could not find pointers because the signatures aren't unique!", "Phasmophobia Auto Splitter", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
			vars.sW.Reset();
			break;
		}
	}

	print("Found LevelValues    : 0x" + levelValuesPtr.ToString("X"));
	print("Found LevelController: 0x" + levelControllerPtr.ToString("X"));

	vars.isTutorial     = new MemoryWatcher<bool>(new DeepPointer(levelValuesPtr, 0xB8, 0x0, 0x1A));
	vars.miss1Completed = new MemoryWatcher<bool>(new DeepPointer(levelValuesPtr, 0xB8, 0x0, 0x24));
	vars.miss2Completed = new MemoryWatcher<bool>(new DeepPointer(levelValuesPtr, 0xB8, 0x0, 0x25));
	vars.miss3Completed = new MemoryWatcher<bool>(new DeepPointer(levelValuesPtr, 0xB8, 0x0, 0x26));
	vars.miss4Completed = new MemoryWatcher<bool>(new DeepPointer(levelValuesPtr, 0xB8, 0x0, 0x27));
	vars.evidence1Index = new MemoryWatcher<byte>(new DeepPointer(levelControllerPtr, 0xB8, 0x0, 0x78, 0xD0));
	vars.evidence2Index = new MemoryWatcher<byte>(new DeepPointer(levelControllerPtr, 0xB8, 0x0, 0x78, 0xE0));
	vars.evidence3Index = new MemoryWatcher<byte>(new DeepPointer(levelControllerPtr, 0xB8, 0x0, 0x78, 0xF0));
	vars.ghostTypeIndex = new MemoryWatcher<byte>(new DeepPointer(levelControllerPtr, 0xB8, 0x0, 0x78, 0x100));
	vars.allPlayersAreConnected = new MemoryWatcher<bool>(new DeepPointer(levelControllerPtr, 0xB8, 0x0, 0x88, 0x68));
	vars.isLoadingBackToMenu    = new MemoryWatcher<bool>(new DeepPointer(levelControllerPtr, 0xB8, 0x0, 0x88, 0x69));

	vars.allWatchers = new MemoryWatcherList
	{
		vars.isTutorial, vars.miss1Completed, vars.miss2Completed, vars.miss3Completed, vars.miss4Completed,
		vars.evidence1Index, vars.evidence2Index, vars.evidence3Index, vars.ghostTypeIndex, vars.allPlayersAreConnected, vars.isLoadingBackToMenu
	};
}

update
{
	if (!vars.sigsFound) return false;
	vars.allWatchers.UpdateAll(game);
	vars.miss = new[] {vars.miss1Completed.Current, vars.miss2Completed.Current, vars.miss3Completed.Current, vars.miss4Completed.Current}.All(x => x == true);
	vars.evid = new[] {vars.evidence1Index.Current, vars.evidence2Index.Current, vars.evidence3Index.Current, vars.ghostTypeIndex.Current}.All(x => x != 0);
	current.phase = timer.CurrentPhase;

	if (!vars.isLoadingBackToMenu.Old && vars.isLoadingBackToMenu.Current) vars.sW.Start();
	if (old.phase != TimerPhase.NotRunning && current.phase == TimerPhase.NotRunning) vars.sW.Reset();
}

start
{
	return !vars.allPlayersAreConnected.Old && vars.allPlayersAreConnected.Current;
}

split
{
	if (vars.sW.ElapsedMilliseconds >= 8967)
	{
		if (!settings["evid"] && !settings["miss"]) return vars.doOnTrue(true);

		if (vars.isTutorial.Current) return vars.doOnTrue(vars.evid && settings["evid"]);
		else return vars.doOnTrue(vars.evid && settings["evid"] || vars.miss && settings["miss"]);
	}
}

reset
{
	if (vars.sW.ElapsedMilliseconds >= 8982)
	{
		if (!settings["evid"]) return false;
		if (vars.isTutorial.Current) return vars.doOnTrue(settings["evid"] && !vars.evid);
		else return vars.doOnTrue(settings["evid"] && !vars.evid || settings["miss"] && !vars.miss);
	}
}