state("Here Comes Niko!") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Niko ASL] " + output));

	dynamic[,] Flags =
	{
		{ "Home", "h_Coins", true, "Coins" },
			{ "h_Coins", "1_Fetch", true, "Low Frog: take lunch box to High Frog" },

		{ "Home", "h_Letters", false, "Letters" },
			{ "h_Letters", "1_letter12", false, "on the rocks near the crane" },

		{ "Home", "1_End", true, "Enter train to leave Home" },


		{ "Hairball City", "hc_Coins", true, "Coins" },
			{ "hc_Coins", "2_main", true, "Gunther: talk to Gunther" },
			{ "hc_Coins", "2_volley", true, "Travis: BIG VOLLEY" },
			{ "hc_Coins", "2_Dustan", true, "Dustan: get to the top of the lighthouse" },
			{ "hc_Coins", "2_flowerPuzzle", true, "Little Gabi: plant flowers in each of the plant beds" },
			{ "hc_Coins", "2_fishing", true, "Fischer: catch all 5 fish" },
			{ "hc_Coins", "2_bug", true, "Blessley: collect 30 butterflies" },
			{ "hc_Coins", "hc_Coins+", false, "Requires Contact List" },
				{ "hc_Coins+", "2_arcadeBone", false, "Arcade Machine: get 5 dog bones" },
				{ "hc_Coins+", "2_arcade", false, "Arcade Machine: get the coin" },
				{ "hc_Coins+", "2_hamsterball", false, "Moomy: collect 10 sunflower seeds" },
				{ "hc_Coins+", "2_carrynojump", false, "Serschel/Louist: bring Louist back to Serschel" },
				{ "hc_Coins+", "2_gamerQuest", false, "Game Kid: jump from the skyscraper into the water without touching ground" },
				{ "hc_Coins+", "2_graffiti", false, "Nina: paint 5 symbols on the ground" },
				{ "hc_Coins+", "2_cassetteCoin", false, "Mitch: trade 5 cassettes for a coin" },
				{ "hc_Coins+", "2_cassetteCoin2", false, "Mai: trade 5 cassettes for a coin" },

		{ "Hairball City", "hc_Cassettes", false, "Cassettes" },
			{ "hc_Cassettes", "2_casHairballCity0", false, "on the rock near the whiteboard" },
			{ "hc_Cassettes", "2_casHairballCity4", false, "on the palm tree" },
			{ "hc_Cassettes", "2_casHairballCity5", false, "in the dark tunnel" },
			{ "hc_Cassettes", "2_casHairballCity2", false, "above the big red umbrellas near the scarecrow frog" },
			{ "hc_Cassettes", "2_casHairballCity3", false, "above the door of the lighthouse" },
			{ "hc_Cassettes", "2_casHairballCity7", false, "at the back side of the lighthouse" },
			{ "hc_Cassettes", "2_casHairballCity8", false, "under the ramp" },
			{ "hc_Cassettes", "2_casHairballCity6", false, "inside of a breakable box" },
			{ "hc_Cassettes", "2_casHairballCity1", false, "on the crown of the frog statue" },
			{ "hc_Cassettes", "2_casHairballCity9", false, "in the sky above the frog statue" },

		{ "Hairball City", "hc_Letters", false, "Letters" },
			{ "hc_Letters", "2_letter1", false, "in the tree near the scarecrow frog" },
			{ "hc_Letters", "2_letter7", false, "on the other side of the train" },

		{ "Hairball City", "2_End", true, "Enter train to leave Hairball City" },


		{ "Turbine Town", "tt_Coins", true, "Coins" },
			{ "tt_Coins", "3_main", true, "Pelly: get the wind turbine working" },
			{ "tt_Coins", "3_volley", true, "Trixie: AIR VOLLEY" },
			{ "tt_Coins", "3_Dustan", true, "Dustan: get to the top of the turbine" },
			{ "tt_Coins", "3_flowerPuzzle", true, "Little Gabi: plant flowers in each of the plant beds" },
			{ "tt_Coins", "3_fishing", true, "Fischer: catch all 5 fish" },
			{ "tt_Coins", "3_bug", true, "Blessley: collect 30 butterflies" },
			{ "tt_Coins", "tt_Coins+", false, "Requires Contact List" },
				{ "tt_Coins+", "3_arcadeBone", false, "Arcade Machine: get 5 dog bones" },
				{ "tt_Coins+", "3_arcade", false, "Arcade Machine: get the coin" },
				{ "tt_Coins+", "3_carrynojump", false, "Serschel/Louist: bring Louist back to Serschel" },
				{ "tt_Coins+", "3_cassetteCoin", false, "Mitch: trade 5 cassettes for a coin" },
				{ "tt_Coins+", "3_cassetteCoin2", false, "Mai: trade 5 cassettes for a coin" },

		{ "Turbine Town", "tt_Cassettes", false, "Cassettes" },
			{ "tt_Cassettes", "3_Cassette (2)", false, "on top of the first set of shipping containers" },
			{ "tt_Cassettes", "3_Cassette (5)", false, "inside the container with a button in front of it" },
			{ "tt_Cassettes", "3_Cassette (4)", false, "inside the container with a fan blowing outwards" },
			{ "tt_Cassettes", "3_Cassette (3)", false, "behind Blessley's backdrop" },
			{ "tt_Cassettes", "3_Cassette (6)", false, "in the bushes on around the turbine" },
			{ "tt_Cassettes", "3_Cassette", false, "in the partially sunken container" },
			{ "tt_Cassettes", "3_Cassette (1)", false, "on a cube shaped rock around the back of the flower beds" },
			{ "tt_Cassettes", "3_Cassette (7)", false, "on a pile of cube rocks near the AIR VOLLEY arena" },

		{ "Turbine Town", "tt_Letters", false, "Letters" },
			{ "tt_Letters", "3_letter8", false, "in the tree above the partially sunken container" },
			{ "tt_Letters", "3_letter2", false, "at the back side of the rock where you meet the Wind God" },

		{ "Turbine Town", "tt_Keys", false, "Keys" },
			{ "tt_Keys", "3_containerKey", false, "inside the container with the breakable blocks" },
			{ "tt_Keys", "3_parasolKey", false, "on the stone pillar at the back side of the turbine" },

		{ "Turbine Town", "tt_Misc", false, "Miscellaneous" },
			{ "tt_Misc", "3_TurbineLock", false, "unlock turbine ladder" },

		{ "Turbine Town", "3_End", true, "Enter train to leave Turbine Town" },


		{ "Salmon Creek Forest", "scf_Coins", true, "Coins" },
			{ "scf_Coins", "4_main", true, "Stijn: talk to Melissa and bring them to the plateau" },
			{ "scf_Coins", "4_volley", true, "Trixie: SPORTVIVAL VOLLEY" },
			{ "scf_Coins", "4_Dustan", true, "Dustan: get to the top of the mountain" },
			{ "scf_Coins", "4_flowerPuzzle", true, "Little Gabi: plant flowers in each of the plant beds" },
			{ "scf_Coins", "4_fishing", true, "Fischer: catch all 5 fish" },
			{ "scf_Coins", "4_bug", true, "Blessley: collect 30 dragonflies" },
			{ "scf_Coins", "4_arcadeBone", true, "Arcade Machine: get 5 dog bones" },
			{ "scf_Coins", "4_hamsterball", true, "Moomy: collect 10 sunflower seeds" },
			{ "scf_Coins", "4_graffiti", true, "Nina: paint 5 symbols on the ground" },
			{ "scf_Coins", "4_cassetteCoin", true, "Mitch: trade 5 cassettes for a coin" },
			{ "scf_Coins", "4_cassetteCoin2", true, "Mai: trade 5 cassettes for a coin" },
			{ "scf_Coins", "4_tree", true, "Treeman: dive into the Treeman until a coin falls" },
			{ "scf_Coins", "4_behindWaterfall", true, "Secret of the Forest: jump through a waterfall and go to the end of the area" },
			{ "scf_Coins", "scf_Coins+", false, "Requires Contact List" },
				{ "scf_Coins+", "4_arcade", false, "Arcade Machine: get the coin" },
				{ "scf_Coins+", "4_carrynojump", false, "Serschel/Louist: bring Louist back to Serschel" },
				{ "scf_Coins+", "4_gamerQuest", false, "Game Kid: jump from the skyscraper into the water without touching ground" },

		{ "Salmon Creek Forest", "scf_Cassettes", false, "Cassettes" },
			{ "scf_Cassettes", "4_Cassette", false, "on a large rock behind the train" },
			{ "scf_Cassettes", "4_Cassette (9)", false, "on a leaning tree a little past Treeman" },
			{ "scf_Cassettes", "4_Cassette (10)", false, "in the camp" },
			{ "scf_Cassettes", "4_Cassette (8)", false, "at the back side of the camp, on a grassy outcropping" },
			{ "scf_Cassettes", "4_Cassette (3)", false, "at the back side of the camp, on a stone outcropping" },
			{ "scf_Cassettes", "4_Cassette (1)", false, "on the bridge leading to one of the flower beds" },
			{ "scf_Cassettes", "4_Cassette (6)", false, "on a platform at the top of a tree near Nina and Melissa" },
			{ "scf_Cassettes", "4_Cassette (2)", false, "on the roof of the tree house" },
			{ "scf_Cassettes", "4_Cassette (7)", false, "on a rock just near the flower bed past Stijn's home" },
			{ "scf_Cassettes", "4_Cassette (4)", false, "to the right of the higher waterfall in the secret area" },
			{ "scf_Cassettes", "4_Cassette (5)", false, "in a breakable box in the secret area" },

		{ "Salmon Creek Forest", "scf_Letters", false, "Letters" },
			{ "scf_Letters", "4_letter9", false, "behind a bush in the cave" },
			{ "scf_Letters", "4_letter3", false, "on the left at the end of the secret area" },

		{ "Salmon Creek Forest", "scf_Keys", false, "Keys" },
			{ "scf_Keys", "4_2Key", false, "in the first pond" },
			{ "scf_Keys", "4_3Key", false, "in the small bush behind the frog statue" },
			{ "scf_Keys", "4_1Key", false, "on a rock by the sunken skyscraper" },

		{ "Salmon Creek Forest", "scf_Misc", false, "Miscellaneous" },
			{ "scf_Misc", "4_lock2", false, "unlock the cave" },

		{ "Salmon Creek Forest", "4_End", true, "Enter train to leave Salmon Creek Forest" },


		{ "Public Pool", "pp_Coins", true, "Coins" },
			{ "pp_Coins", "5_main", true, "Frogtective: solve the crime" },
			{ "pp_Coins", "5_fishing", true, "Fischer: catch all 5 fish" },
			{ "pp_Coins", "5_arcadeBone", true, "Arcade Machine: get 5 dog bones" },
			{ "pp_Coins", "5_arcade", true, "Arcade Machine: get the coin" },
			{ "pp_Coins", "5_cassetteCoin2", true, "Mai: trade 5 cassettes for a coin" },
			{ "pp_Coins", "5_2D", true, "Far Away Island: complete the 2D section" },
			{ "pp_Coins", "pp_Coins+", false, "Requires Contact List" },
				{ "pp_Coins+", "5_volley", false, "Trixie: WATER VOLLEY" },
				{ "pp_Coins+", "5_flowerPuzzle", false, "Little Gabi: plant flowers in each of the plant beds" },
				{ "pp_Coins+", "5_bug", false, "Blessley: collect 30 cicadas" },
				{ "pp_Coins+", "5_cassetteCoin", false, "Mitch: trade 5 cassettes for a coin" },

		{ "Public Pool", "pp_Cassettes", false, "Cassettes" },
			{ "pp_Cassettes", "5_Cassette (4)", false, "in the pool with the lily pads" },
			{ "pp_Cassettes", "5_Cassette (5)", false, "in the corner of the deep pool" },
			{ "pp_Cassettes", "5_Cassette (1)", false, "at the end of the mid-height diving board" },
			{ "pp_Cassettes", "5_Cassette (9)", false, "in front of the highest level diving board" },
			{ "pp_Cassettes", "5_Cassette (2)", false, "in a bush behind Blessley's backdrop" },
			{ "pp_Cassettes", "5_Cassette (3)", false, "at the line of donuts behind Blessley's backdrop" },
			{ "pp_Cassettes", "5_Cassette (8)", false, "in a breakable box in the kiddie pool" },
			{ "pp_Cassettes", "5_Cassette", false, "on top of the green frog statue" },
			{ "pp_Cassettes", "5_Cassette (6)", false, "in the ring of donuts behind the green frog statue" },
			{ "pp_Cassettes", "5_Cassette (7)", false, "in a palm tree near the guinea pigs" },

		{ "Public Pool", "pp_Letters", false, "Letters" },
				{ "pp_Letters", "5_letter10", false, "on the far left of the 2D section" },
				{ "pp_Letters", "5_letter4", false, "on the far right of the 2D section" },

		{ "Public Pool", "pp_Keys", false, "Keys" },
			{ "pp_Keys", "5_testKey", false, "on the island with the fan covered by a breakable box" },

		{ "Public Pool", "pp_Misc", false, "Miscellaneous" },
			{ "pp_Misc", "5_lock1", false, "unlock the second Arcade Machine" },

		{ "Public Pool", "5_End", true, "Enter train to leave Public Pool" },


		{ "The Bathhouse" ,"tb_Coins", true, "Coins" },
			{ "tb_Coins", "6_main", true, "Poppy: check on Paul and then find Skippy" },
			{ "tb_Coins", "6_volley", true, "Travis: LONG VOLLEY" },
			{ "tb_Coins", "6_Dustan", true, "Dustan: get to the top of the main bathhouse" },
			{ "tb_Coins", "6_hamsterball", true, "Moomy: collect 10 sunflower seeds" },
			{ "tb_Coins", "6_carrynojump", true, "Serschel/Louist: bring Louist back to Serschel" },
			{ "tb_Coins", "6_gamerQuest", true, "Game Kid: get from the marked lamp to the marked hot tub without touching snow" },
			{ "tb_Coins", "6_graffiti", true, "Nina: paint 5 symbols on the ground" },
			{ "tb_Coins", "6_cassetteCoin", true, "Mitch: trade 5 cassettes for a coin" },
			{ "tb_Coins", "6_cassetteCoin2", true, "Mai: trade 5 cassettes for a coin" },
			{ "tb_Coins", "tb_Coins+", false, "Requires Contact List" },
				{ "tb_Coins+", "6_flowerPuzzle", false, "Little Gabi: plant flowers in each of the plant beds" },
				{ "tb_Coins+", "6_fishing", false, "Fischer: catch all 5 fish" },
				{ "tb_Coins+", "6_bug", false, "Blessley: collect 30 cicadas" },
				{ "tb_Coins+", "6_arcadeBone", false, "Arcade Machine: get 5 dog bones" },
				{ "tb_Coins+", "6_arcade", false, "Arcade Machine: get the coin" },

		{ "The Bathhouse" ,"tb_Cassettes", false, "Cassettes" },
			{ "tb_Cassettes" ,"6_Cassette", false, "behind the golden frog statue" },
			{ "tb_Cassettes" ,"6_Cassette (8)", false, "along a pipe below the entrace to the main bathhouse" },
			{ "tb_Cassettes" ,"6_Cassette (4)", false, "on top of a lamp to the left of the main bathhouse" },
			{ "tb_Cassettes" ,"6_Cassette (6)", false, "behind a waterfall to the right of the main bathhouse" },
			{ "tb_Cassettes" ,"6_Cassette (9)", false, "in the secret frog hideout" },
			{ "tb_Cassettes" ,"6_Cassette (1)", false, "on a rock off the ledge where Masked Kid stands" },
			{ "tb_Cassettes" ,"6_Cassette (2)", false, "under the sunken tower" },
			{ "tb_Cassettes" ,"6_Cassette (3)", false, "on top of the giant frog statue" },
			{ "tb_Cassettes" ,"6_Cassette (7)", false, "above a tree near the giant frog statue" },
			{ "tb_Cassettes" ,"6_Cassette (5)", false, "behind Blessley's backdrop" },

		{ "The Bathhouse" ,"tb_Letters", false, "Letters" },
			{ "tb_Letters" ,"6_letter11", false, "near the axolotl family" },
			{ "tb_Letters" ,"6_letter5", false, "on the other side of the wall where Game Kid is standing" },

		{ "The Bathhouse" ,"tb_Keys", false, "Keys" },
			{ "tb_Keys" ,"6_underfloorKey", false, "under the floor of the main bathhouse" },
			{ "tb_Keys" ,"6_inpuzzleKey", false, "in a breakable box on the bottom level of one of the bathhouses" },
			{ "tb_Keys" ,"6_ontoriiKey", false, "on top of one of the red torii gates leading to Paul" },

		{ "The Bathhouse" ,"tb_Miscellaneous", false, "Miscellaneous" },
			{ "tb_Miscellaneous" ,"6_mahjonglock", false, "unlock the frog hideout" },

		{ "The Bathhouse", "6_End", true, "Enter train to leave The Bathhouse" },


		{ "Tadpole HQ", "thq_Coins", true, "Coins" },
			{ "thq_Coins", "7_main", true, "King Frog: listen to King Frog" },
			{ "thq_Coins", "7_volley", true, "Travis: HUGE VOLLEY" },
			{ "thq_Coins", "7_flowerPuzzle", true, "Little Gabi: plant flowers in each of the plant beds" },
			{ "thq_Coins", "7_fishing", true, "Fischer: catch all 5 fish" },
			{ "thq_Coins", "7_bug", true, "Blessley: collect 30 cicadas" },
			{ "thq_Coins", "7_arcadeBone", true, "Arcade Machine: get 5 dog bones" },
			{ "thq_Coins", "7_arcade", true, "Arcade Machine: get the coin" },
			{ "thq_Coins", "7_carrynojump", true, "Serschel/Louist: bring Louist back to Serschel" },
			{ "thq_Coins", "7_cassetteCoin", true, "Mitch: trade 5 cassettes for a coin" },
			{ "thq_Coins", "7_cassetteCoin2", true, "Mai: trade 5 cassettes for a coin" },

		{ "Tadpole HQ", "thq_Cassettes", false, "Cassettes" },
			{ "thq_Cassettes", "7_Cassette (2)", false, "in a bush behind the bench with the contact list" },
			{ "thq_Cassettes", "7_Cassette (4)", false, "in a tree near the first pond (soda can to shoot into it)" },
			{ "thq_Cassettes", "7_Cassette (5)", false, "on top of the golden frog statue" },
			{ "thq_Cassettes", "7_Cassette (6)", false, "in a breakable box behind the first buildings to the right" },
			{ "thq_Cassettes", "7_Cassette (9)", false, "in the wall jump area of the largest building" },
			{ "thq_Cassettes", "7_Cassette (3)", false, "around the corner of the broken soda can" },
			{ "thq_Cassettes", "7_Cassette (7)", false, "on some rocks past Fischer" },
			{ "thq_Cassettes", "7_Cassette (8)", false, "under the giant red umbrella near Blessley" },
			{ "thq_Cassettes", "7_Cassette", false, "in the cross section between the buildings with the flower beds" },
			{ "thq_Cassettes", "7_Cassette (1)", false, "at the back side of the second-level building with the flower beds" },

		{ "Tadpole HQ", "thq_Letters", false, "Letters" },
			{ "thq_Letters", "7_letter6", false, "on the second highest ledge leading to pepper" },

		{ "Tadpole HQ", "thq_Misc", false, "Miscellaneous" },
			{ "thq_Misc", "7_lock1", false, "unlock the second Arcade Machine" },

		{ "Tadpole HQ", "7_End", false, "Enter train to leave Tadpole HQ" }
	};

	settings.Add("Home");
	settings.Add("Hairball City");
	settings.Add("Turbine Town");
	settings.Add("Salmon Creek Forest");
	settings.Add("Public Pool");
	settings.Add("The Bathhouse");
	settings.Add("Tadpole HQ");

	for (int i = 0; i < Flags.GetLength(0); ++i)
	{
		string parent = Flags[i, 0];
		string id     = Flags[i, 1];
		bool state    = Flags[i, 2];
		string desc   = Flags[i, 3];

		settings.Add(id, state, desc, parent);
	}

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var mbox = MessageBox.Show(
			"Removing loads from Here Comes Niko requires comparing against Game Time.\nWould you like to switch to it?",
			"Here Comes Niko Autosplitter",
			MessageBoxButtons.YesNo);

		if (mbox == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}

init
{
	vars.OnStartPtr = IntPtr.Zero;
	vars.SpeedrunData = new MemoryWatcherList();
	vars.WorldData = new MemoryWatcherList();

	Func<SigScanTarget, IntPtr> scanPages = (trg) =>
	{
		var ptr = IntPtr.Zero;
		foreach (var page in game.MemoryPages(true))
		{
			var scnr = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
			if ((ptr = scnr.Scan(trg)) != IntPtr.Zero) return ptr;
		}

		return IntPtr.Zero;
	};

	vars.CancelSource = new CancellationTokenSource();
	vars.ScanThread = new Thread(() =>
	{
		vars.Dbg("Starting scan thread.");

		var speedrunDataTrg = new SigScanTarget(10, "00 00 C9 B0 F9 5A 47 88 90 B9");
		IntPtr speedrunData = IntPtr.Zero, worldData = IntPtr.Zero;

		var token = vars.CancelSource.Token;
		while (!token.IsCancellationRequested)
		{
			if ((speedrunData = scanPages(speedrunDataTrg)) != IntPtr.Zero)
			{
				vars.SpeedrunData.Add(new MemoryWatcher<int>(speedrunData + 0x0) { Name = "Level" });
				vars.SpeedrunData.Add(new MemoryWatcher<bool>(speedrunData + 0x4) { Name = "End" });
				vars.SpeedrunData.Add(new MemoryWatcher<bool>(speedrunData + 0x5) { Name = "Loading" });
				vars.SpeedrunData.Add(new MemoryWatcher<bool>(speedrunData + 0x6) { Name = "GameStart" });
				vars.SpeedrunData.Add(new MemoryWatcher<bool>(speedrunData + 0x7) { Name = "LevelStart" });
				vars.OnStartPtr = speedrunData + 0x6;

				vars.Dbg("Found SpeedRunData at 0x" + speedrunData.ToString("X") + ".");
				break;
			}

			vars.Dbg("SpeedRunData not initialized yet. Retrying.");
			Thread.Sleep(2000);
		}

		while (!token.IsCancellationRequested)
		{
			var size = new DeepPointer("mono-2.0-bdwgc.dll", 0x49A0C8, 0x10, 0x1D0, 0x8, 0x4D8).Deref<int>(game);
			var class_cache = new DeepPointer("mono-2.0-bdwgc.dll", 0x49A0C8, 0x10, 0x1D0, 0x8, 0x4E0).Deref<IntPtr>(game);

			for (int i = 0; i < size; ++i)
			{
				var klass = game.ReadPointer(class_cache + 0x8 * i);
				for (; klass != IntPtr.Zero; klass = game.ReadPointer(klass + 0x108))
				{
					var class_name = new DeepPointer(klass + 0x48, 0x0).DerefString(game, 32);
					if (string.IsNullOrEmpty(class_name)) break;
					if (class_name != "scrWorldSaveDataContainer") continue;

					vars.WorldDataPtr = worldData = new DeepPointer(klass + 0xD0, 0x8, 0x60).Deref<IntPtr>(game);
					for (int offset = 0x20; offset <= 0x40; offset += 0x8)
						vars.WorldData.Add(new MemoryWatcher<int>(new DeepPointer(worldData, offset, 0x18)) { Name = offset.ToString() });

					vars.Dbg("Found WorldSaveData at 0x" + worldData.ToString("X") + ".");
					break;
				}

				if (worldData != IntPtr.Zero) break;
			}

			if (worldData != IntPtr.Zero)
			{
				vars.Dbg("All pointers found successfully.");
				break;
			}

			vars.Dbg("Could not find WorldSaveData. Retrying.");
			Thread.Sleep(2000);
		}

		vars.Dbg("Exiting scan thread.");
	});

	vars.ScanThread.Start();

	vars.CompletedFlags = new List<string>();
	vars.TimerStart = (EventHandler) ((s, e) =>
	{
		vars.CompletedFlags.Clear();
		vars.EndGame = false;
		timer.Run.Offset = TimeSpan.Zero;
		if (vars.OnStartPtr != IntPtr.Zero)
			game.WriteValue<bool>((IntPtr)vars.OnStartPtr, false);
	});
	timer.OnStart += vars.TimerStart;
}

update
{
	if (vars.SpeedrunData.Count == 0) return false;

	vars.SpeedrunData.UpdateAll(game);
	if (vars.WorldData.Count > 0) vars.WorldData.UpdateAll(game);
}

start
{
	return !vars.SpeedrunData["GameStart"].Old && vars.SpeedrunData["GameStart"].Current ||
	       !vars.SpeedrunData["LevelStart"].Old && vars.SpeedrunData["LevelStart"].Current;
}

split
{
	if (vars.SpeedrunData["Level"].Changed && vars.SpeedrunData["Level"].Current != 1)
	{
		vars.Dbg("Level changed from " + vars.SpeedrunData["Level"].Old + " to " + vars.SpeedrunData["Level"].Current + ".");
		return settings[vars.SpeedrunData["Level"].Old + "_End"];
	}

	if (!vars.SpeedrunData["End"].Old && vars.SpeedrunData["End"].Current)
	{
		vars.Dbg("Split for end!");
		return true;
	}

	if (vars.WorldData.Count == 0) return;

	foreach (var watcher in vars.WorldData)
	{
		if (watcher.Current != watcher.Old + 1) continue;

		int offset = int.Parse(watcher.Name);
		string newFlag = new DeepPointer((IntPtr)vars.WorldDataPtr, offset, 0x10, 0x20 + 0x8 * (watcher.Current - 1), 0x14).DerefString(game, 64);
		newFlag = vars.SpeedrunData["Level"].Current + "_" + newFlag;

		vars.Dbg("Got flag " + newFlag);
		if (!vars.CompletedFlags.Contains(newFlag))
		{
			vars.CompletedFlags.Add(newFlag);
			return settings[newFlag];
		}
	}
}

reset
{
	return !vars.SpeedrunData["GameStart"].Old && vars.SpeedrunData["GameStart"].Current;
}

isLoading
{
	return vars.SpeedrunData["Loading"].Current;
}

exit
{
	vars.OnStartPtr = IntPtr.Zero;
	timer.OnStart -= vars.TimerStart;
	vars.CancelSource.Cancel();
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
	vars.CancelSource.Cancel();
}