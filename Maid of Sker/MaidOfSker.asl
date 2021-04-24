// This auto splitter was generated using Ero's 'Unity ASL Generator'.
// More infos here: https://github.com/just-ero/Unity-ASL-Generator.

state("Maid of Sker") {}

startup
{
	var SplitScenes = new HashSet<string>
	{
		"MOS_LVL_ForestIntro",
		"MOS_LVL_GroundFloor",
		"MOS_LVL_Basement",
		"MOS_LVL_ForestDark",
		"MOS_LVL_Garden",
		"MOS_LVL_FirstFloor",
		"MOS_LVL_SecondFloor",
		"MOS_LVL_ForestDark_End"
	};

	vars.AdditionalPauses = new HashSet<string> { "MOS_LVL_LoadingScreen", "MOS_LVL_PersistentScene" };

	settings.Add("sceneSplits", true, "Split after finishing a scene:");
	foreach (string scene in SplitScenes)
		settings.Add(scene, true, scene, "sceneSplits");
}

init
{
	ProcessModuleWow64Safe UnityPlayer = game.ModulesWow64Safe().FirstOrDefault(x => x.ModuleName == "UnityPlayer.dll");
	ProcessModuleWow64Safe GameAssembly = game.ModulesWow64Safe().FirstOrDefault(x => x.ModuleName == "GameAssembly.dll");
	SignatureScanner UnityPlayerScanner = new SignatureScanner(game, UnityPlayer.BaseAddress, UnityPlayer.ModuleMemorySize);
	SignatureScanner GameAssemblyScanner = new SignatureScanner(game, GameAssembly.BaseAddress, GameAssembly.ModuleMemorySize);

	Func<IntPtr, int, int, IntPtr> PtrFromOpcode = (ptr, targetOperandOffset, totalSize) =>
	{
		byte[] bytes = game.ReadBytes(ptr + targetOperandOffset, 4);
		if (bytes == null) return IntPtr.Zero;

		Array.Reverse(bytes);
		int offset = Convert.ToInt32(BitConverter.ToString(bytes).Replace("-", ""), 16);
		return IntPtr.Add(ptr + totalSize, offset);
	};

	SigScanTarget SceneManagerSig = new SigScanTarget("48 8B 0D ???????? 48 8D 55 ?? 89 45 ?? 0F B6 85");
	SceneManagerSig.OnFound = (p, s, ptr) => PtrFromOpcode(ptr, 3, 7);
	SigScanTarget InventoryManagerSig = new SigScanTarget("48 8B 05 ???????? 48 8B 88 ???????? 48 8B 09 48 85 D2 74");
	InventoryManagerSig.OnFound = (p, s, ptr) => PtrFromOpcode(ptr, 3, 7);

	IntPtr SceneManager = IntPtr.Zero, InventoryManager = IntPtr.Zero;

	int iteration = 0;
	while (iteration++ < 50)
	{
		SceneManager = UnityPlayerScanner.Scan(SceneManagerSig);
		InventoryManager = GameAssemblyScanner.Scan(InventoryManagerSig);

		if (vars.SigsFound = new[] { SceneManager, InventoryManager }.All(addr => addr != IntPtr.Zero)) break;
	}

	if (!vars.SigsFound) return;

	vars.ItemAmount = new MemoryWatcher<int>(new DeepPointer(InventoryManager, 0xB8, 0x0, 0x28, 0x18));

	Func<string, string> PathToName = (path) =>
	{
		if (String.IsNullOrEmpty(path)) return String.Empty;

		int from = path.LastIndexOf('/') + 1;
		int to = path.LastIndexOf(".unity");
		return path.Substring(from, to - from);
	};

	vars.UpdateScenes = (Action) (() =>
	{
		current.ThisScene = PathToName(new DeepPointer(SceneManager, 0x48, 0x10, 0x0).DerefString(game, 256));
		current.NextScene = PathToName(new DeepPointer(SceneManager, 0x28, 0x0, 0x10, 0x0).DerefString(game, 256));
	});

	vars.UpdateInventoryItems = (Action) (() =>
	{
		vars.ItemAmount.Update(game);
		int index = vars.ItemAmount.Current - 1;
		current.Item = new DeepPointer(InventoryManager, 0xB8, 0x0, 0x28, 0x10, 0x20 + 0x8 * index, 0x10, 0x58, 0x14).DerefString(game, 128) ?? "None";
	});

	vars.Log = (Action<string>) (output => {
		string fileName = "MoS_ItemNames.log";
		var logWriter = File.AppendText(fileName);

		logWriter.WriteLine(output);
		logWriter.Close();

		if (new FileInfo(fileName).Length >= 500000)
			File.WriteAllText(fileName, output);
	});
}

update
{
	if (!vars.SigsFound) return false;
	vars.UpdateScenes();
	vars.UpdateInventoryItems();

	if (vars.ItemAmount.Old > 0 && vars.ItemAmount.Current == 0) vars.Log("\nNew run started!\n");
	if (old.Item != current.Item) vars.Log("New item: " + current.Item);
}

start
{
	return old.Item != current.Item && current.Item == "Music Sheet - 04";
}

split
{
	return old.Item != current.Item && settings[current.Item] ||
	       old.NextScene != current.NextScene && settings[old.NextScene];
}

isLoading
{
	return current.ThisScene != current.NextScene ||
	       vars.AdditionalPauses.Contains(current.ThisScene);
}