// This auto splitter was generated using Ero's 'Unity ASL Generator'.
// More infos here: https://github.com/just-ero/Unity-ASL-Generator.

state("Maid of Sker") {}

startup
{
	vars.CollectedItems = new HashSet<string>();
	vars.AdditionalPauses = new HashSet<string> { "MOS_LVL_LoadingScreen", "MOS_LVL_PersistentScene" };

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
		{ "keys",           "k1",                        "asd" },
		{ "keys",           "k2",                        "asd" }
	};

	settings.Add("items", false, "Split when collecting an item:");
		settings.Add("musicSheets", false, "Music Sheets", "items");
		settings.Add("musicCylinders", false, "Music Cylinders", "items");
		settings.Add("keys", false, "Keys", "items");
	settings.Add("scenes", false, "Split after finishing an area:");

	for (int i = 0; i < Settings.GetLength(0); ++i)
	{
		string parent = Settings[i, 0];
		string id     = Settings[i, 1];
		string desc   = Settings[i, 2];

		settings.Add(id, false, desc, parent);
	}

	vars.TimerStart = (EventHandler) ((s, e) => vars.CollectedItems.Clear());
	timer.OnStart += vars.TimerStart;
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

	current.Item = "No item!";
	var InventorySize = new MemoryWatcher<int>(new DeepPointer(InventoryManager, 0xB8, 0x0, 0x28, 0x18));
	var ReadablesSize = new MemoryWatcher<int>(new DeepPointer(InventoryManager, 0xB8, 0x0, 0x30, 0x18));
	var AudiblesSize = new MemoryWatcher<int>(new DeepPointer(InventoryManager, 0xB8, 0x0, 0x38, 0x18));
	var CollectiblesSize = new MemoryWatcher<int>(new DeepPointer(InventoryManager, 0xB8, 0x0, 0x40, 0x18));
	var QuestablesSize = new MemoryWatcher<int>(new DeepPointer(InventoryManager, 0xB8, 0x0, 0x48, 0x18));

	vars.UpdateInventoryItems = (Action) (() =>
	{
		InventorySize.Update(game);
		ReadablesSize.Update(game);
		AudiblesSize.Update(game);
		CollectiblesSize.Update(game);
		QuestablesSize.Update(game);
		int index = 0;
		string newItem = String.Empty;

		if (InventorySize.Changed && InventorySize.Current != 0)
		{
			index = InventorySize.Current - 1;
			newItem = new DeepPointer(InventoryManager, 0xB8, 0x0, 0x28, 0x10, 0x20 + 0x8 * index, 0x10, 0x58, 0x14).DerefString(game, 128);
			print(newItem);

			if (!String.IsNullOrEmpty(newItem))
			{
				current.Item = newItem;
				vars.Log("New Item: " + newItem);
			}
		}

		if (ReadablesSize.Changed && ReadablesSize.Current != 0)
		{
			index = ReadablesSize.Current - 1;
			newItem = new DeepPointer(InventoryManager, 0xB8, 0x0, 0x30, 0x10, 0x20 + 0x8 * index, 0x10, 0x58, 0x14).DerefString(game, 128);
			print(newItem);

			if (!String.IsNullOrEmpty(newItem))
			{
				current.Item = newItem;
				vars.Log("New Readable: " + newItem);
			}
		}

		if (AudiblesSize.Changed && AudiblesSize.Current != 0)
		{
			index = AudiblesSize.Current - 1;
			newItem = new DeepPointer(InventoryManager, 0xB8, 0x0, 0x38, 0x10, 0x20 + 0x8 * index, 0x10, 0x58, 0x14).DerefString(game, 128);
			print(newItem);

			if (!String.IsNullOrEmpty(newItem))
			{
				current.Item = newItem;
				vars.Log("New Audible: " + newItem);
			}
		}

		if (CollectiblesSize.Changed && CollectiblesSize.Current != 0)
		{
			index = CollectiblesSize.Current - 1;
			newItem = new DeepPointer(InventoryManager, 0xB8, 0x0, 0x40, 0x10, 0x20 + 0x8 * index, 0x10, 0x58, 0x14).DerefString(game, 128);
			print(newItem);

			if (!String.IsNullOrEmpty(newItem))
			{
				current.Item = newItem;
				vars.Log("New Collectible: " + newItem);
			}
		}

		if (QuestablesSize.Changed && QuestablesSize.Current != 0)
		{
			index = QuestablesSize.Current - 1;
			newItem = new DeepPointer(InventoryManager, 0xB8, 0x0, 0x48, 0x10, 0x20 + 0x8 * index, 0x10, 0x58, 0x14).DerefString(game, 128);
			print(newItem);

			if (!String.IsNullOrEmpty(newItem))
			{
				current.Item = newItem;
				vars.Log("New Questable: " + newItem);
			}
		}
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

	return old.NextScene != current.NextScene && settings[old.NextScene];
}

reset
{
	return old.ThisScene != current.ThisScene && current.ThisScene == "MOS_LVL_Frontend";
}

isLoading
{
	return current.ThisScene != current.NextScene ||
	       vars.AdditionalPauses.Contains(current.ThisScene);
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}