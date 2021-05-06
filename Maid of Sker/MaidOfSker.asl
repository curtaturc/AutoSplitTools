state("Maid of Sker") {}

startup
{
	vars.CollectedItems = new HashSet<string>();

	string[,] Settings =
	{
		{ "scenes",         "MOS_LVL_ForestIntro",       "Forest Intro" },
		{ "scenes",         "MOS_LVL_GroundFloor",       "Ground Floor" },
		{ "scenes",         "MOS_LVL_Basement",          "Basement" },
		{ "scenes",         "MOS_LVL_ForestDark",        "Forest Dark" },
		{ "scenes",         "MOS_LVL_Garden",            "Garden" },
		{ "scenes",         "MOS_LVL_FirstFloor",        "First Floor" },
		{ "scenes",         "MOS_LVL_SecondFloor",       "Second Floor" },
		{ "scenes",         "MOS_LVL_ForestDark_End",    "Forst Dark (End)" },
		{ "musicSheets",    "Music Sheet - 04",          "Music Sheet: Thomas Evans" },
		{ "musicSheets",    "Music Sheet - 03",          "Music Sheet: Henry Hughes" },
		{ "musicSheets",    "Music Sheet - 02",          "Music Sheet: Matilda Norton" },
		{ "musicSheets",    "Music Sheet - 01",          "Music Sheet: Arthur Morris" },
		{ "musicCylinders", "Music Cylinder - Cerebrus", "Music Cylinder - Cerebrus" },
		{ "musicCylinders", "Music Cylinder - Hero",     "Music Cylinder - Hero" },
		{ "musicCylinders", "Music Cylinder - Siren",    "Music Cylinder - Siren" },
		{ "musicCylinders", "Music Cylinder - Medusa",   "Music Cylinder - Medusa" },
		{ "keys",           "Music Key",                 "Music Key" },
		{ "keys",           "Key",                       "Crown Key" },
		{ "misc",           "Phonic Modulator",          "Phonic Modulator" }
	};

	settings.Add("items", false, "Split when collecting an item:");
		settings.Add("musicSheets", false, "Music Sheets", "items");
		settings.Add("musicCylinders", false, "Music Cylinders", "items");
		settings.Add("keys", false, "Keys", "items");
		settings.Add("misc", false, "Other items", "items");
	settings.Add("scenes", false, "Split after finishing an area:");

	for (int i = 0; i < Settings.GetLength(0); ++i)
	{
		string parent = Settings[i, 0];
		string id     = Settings[i, 1];
		string desc   = Settings[i, 2];

		settings.Add(id, false, desc, parent);
	}

	vars.TimerStart = (EventHandler) ((s, e) =>
	{
		vars.CollectedItems.Clear();
		vars.CutsceneNum = 0;
	});
	timer.OnStart += vars.TimerStart;
}

init
{
	#region SigScans
	ProcessModuleWow64Safe UnityPlayer = game.ModulesWow64Safe().FirstOrDefault(x => x.ModuleName == "UnityPlayer.dll");
	ProcessModuleWow64Safe GameAssembly = game.ModulesWow64Safe().FirstOrDefault(x => x.ModuleName == "GameAssembly.dll");
	SignatureScanner UnityPlayerScanner = new SignatureScanner(game, UnityPlayer.BaseAddress, UnityPlayer.ModuleMemorySize);
	SignatureScanner GameAssemblyScanner = new SignatureScanner(game, GameAssembly.BaseAddress, GameAssembly.ModuleMemorySize);

	var SceneManagerSig = new SigScanTarget("48 8B 0D ???????? 48 8D 55 ?? 89 45 ?? 0F B6 85");
	var InventoryManagerSig = new SigScanTarget("48 8B 05 ???????? 48 8B 88 ???????? 48 8B 09 48 85 D2 74");
	var PlayerControllerSig = new SigScanTarget("48 8B 05 ???????? 4C 89 B4 24 ???????? 0F 29 B4 24");
	var LoadClassSig = new SigScanTarget("48 8B 15 ???????? 45 33 C9 4D 8B C6 48 8B CB");

	foreach (var sig in new[] { SceneManagerSig, InventoryManagerSig, PlayerControllerSig, LoadClassSig })
		sig.OnFound = (p, s, ptr) => IntPtr.Add(ptr + 7, game.ReadValue<int>(ptr + 3));

	IntPtr SceneManager = IntPtr.Zero, InventoryManager = IntPtr.Zero, PlayerController = IntPtr.Zero, LoadClass = IntPtr.Zero;

	int iteration = 0;
	while (iteration++ < 50)
	{
		SceneManager = UnityPlayerScanner.Scan(SceneManagerSig);
		LoadClass = GameAssemblyScanner.Scan(LoadClassSig);
		InventoryManager = GameAssemblyScanner.Scan(InventoryManagerSig);
		PlayerController = GameAssemblyScanner.Scan(PlayerControllerSig);

		if (vars.SigsFound = new[] { SceneManager, InventoryManager, PlayerController, LoadClass }.All(addr => addr != IntPtr.Zero)) break;
	}

	if (!vars.SigsFound) return;

	var InventorySize = new MemoryWatcher<int>(new DeepPointer(InventoryManager, 0xB8, 0x0, 0x28, 0x18));
	vars.CutsceneStartTime = new MemoryWatcher<float>(new DeepPointer(PlayerController, 0xB8, 0x0, 0xE0, 0x108));
	vars.Loading = new MemoryWatcher<bool>(new DeepPointer(LoadClass, 0x350, 0x28, 0x70));
	#endregion

	#region UpdateFunctions
	Func<string, string> PathToName = (path) =>
	{
		if (String.IsNullOrEmpty(path)) return null;

		int from = path.LastIndexOf('/') + 1;
		int to = path.LastIndexOf(".unity");
		return path.Substring(from, to - from);
	};

	vars.UpdateScenes = (Action) (() =>
	{
		current.ThisScene = PathToName(new DeepPointer(SceneManager, 0x48, 0x10, 0x0).DerefString(game, 256)) ?? old.ThisScene;
		current.NextScene = PathToName(new DeepPointer(SceneManager, 0x28, 0x0, 0x10, 0x0).DerefString(game, 256)) ?? old.NextScene;
	});

	vars.UpdateInventoryItems = (Action) (() =>
	{
		InventorySize.Update(game);
		int index = 0;
		string newItem = String.Empty;

		if (InventorySize.Changed && InventorySize.Current != 0)
		{
			index = InventorySize.Current - 1;
			newItem = new DeepPointer(InventoryManager, 0xB8, 0x0, 0x28, 0x10, 0x20 + 0x8 * index, 0x10, 0x58, 0x14).DerefString(game, 128);

			if (!String.IsNullOrEmpty(newItem)) current.Item = newItem;
		}
	});
	#endregion

	current.Item = "No item!";
	current.CutsceneNum = 0;
}

update
{
	if (!vars.SigsFound) return false;
	vars.UpdateScenes();
	vars.UpdateInventoryItems();
	vars.CutsceneStartTime.Update(game);
	vars.Loading.Update(game);

	if (current.ThisScene == "MOS_LVL_GroundFloor" && vars.CutsceneStartTime.Old == -1 && vars.CutsceneStartTime.Current > 0) ++current.CutsceneNum;
}

start
{
	return old.Item != current.Item && current.Item == "Music Sheet - 04";
}

split
{
	if (old.Item != current.Item && !vars.CollectedItems.Contains(current.Item))
	{
		vars.CollectedItems.Add(current.Item);
		return settings[current.Item];
	}

	return old.NextScene != current.NextScene && settings[old.NextScene] ||
	       old.CutsceneNum != 3 && current.CutsceneNum == 3;
}

reset
{
	return old.NextScene != current.NextScene && current.NextScene == "MOS_LVL_Frontend";
}

isLoading
{
	return vars.Loading.Current;
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}