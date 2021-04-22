state("A Proof of Concept 1.1")
{
	int LevelID : 0x6C2DB8;
	//int Time : 0x6C2DE0;
}

state("Concept - v2.6")
{
	int LevelID : 0x6FFF60;
}

startup
{
	string[,] Settings =
	{
		{ "libSplits", "0to1", "Enter Vault/Museum from Library" },
		{ "libSplits", "0to2", "Enter Main Frame from Library" },
		{ "libSplits", "0to6", "Enter Power Plant from Library" },
		{ "libSplits", "0to8", "Enter Gravitational Management from Library (2.0+)" },
		{ "libSplits", "0to11", "Enter SA * RC from Library (2.0+)" },
		{ "libSplits", "0to7", "Enter Woods from Library" },
		{ "libSplits", "0to4", "Enter Great Door from Library" },

		{ "libBackSplits", "1to0", "Leave Museum/Vault to Library" },
		{ "libBackSplits", "2to0", "Leave Main Frame to Library" },
		{ "libBackSplits", "5to0", "Leave Back Door level to Library" },
		{ "libBackSplits", "6to0", "Leave Power Plant to Library" },
		{ "libBackSplits", "9to0", "Leave Centrifuge to Library (2.0+)" },
		{ "libBackSplits", "12to0", "Leave Event Horizon to Library (2.0+)" },
		{ "libBackSplits", "14to0", "Leave Continuum to Library (2.0+)" },
		{ "libBackSplits", "7to0", "Leave Woods to Library" },

		{ "inLevelSplits", "4to3", "Enter Archive from Big Orb Room" },
		{ "inLevelSplits", "frameSplits", "Splits in Main Frame:" },
			{ "frameSplits", "2to3", "Enter second half of Main Frame" },
			{ "frameSplits", "3to4", "Enter Back Door Corridor from Main Frame" },
			{ "frameSplits", "4to5", "Enter Back Door level from Corridor" },
		{ "inLevelSplits", "centSplits", "Splits in Centrifuge (2.0+):" },
			{ "centSplits", "8to9", "Enter Centrifuge from Gravitational Management" },
			{ "centSplits", "9to10", "Enter Warp Machine from Centrifuge" },
		{ "inLevelSplits", "eventSplits", "Splits in Event Horizon (2.0+):" },
			{ "eventSplits", "11to12", "Enter Event Horizon from SA * RC" },
			{ "eventSplits", "11to13", "Enter Professor's lab from SA * RC" },
			{ "eventSplits", "13to14", "Enter Continuum from lab" }
	};

	settings.Add("libSplits", false, "Split when going into a level:");
	settings.Add("libBackSplits", false, "Split when finishing a level:");
	settings.Add("inLevelSplits", false, "Split within a level:");

	for (int i = 0; i < Settings.GetLength(0); ++i)
	{
		string parent = Settings[i, 0];
		string id = Settings[i, 1];
		string desc = Settings[i, 2];

		settings.Add(id, false, desc, parent);
	}
}

init
{
	switch (game.ProcessName)
	{
		case "A Proof of Concept 1.1":
			vars.LevelIDByIndex = new List<int> { 12, 5, 6, 7, 9, 10, 11, 14 };
			break;
		case "Concept - v2.6":
			vars.LevelIDByIndex = new List<int>
			{
				21, // Library
				12, // Museum
				13, // Main Frame
				15, // Main Frame 2 / Archive
				17, // Back Door 0.5 / Great Door
				18, // Back Door
				19, // Power Plant
				23, // Woods
				14, // Gravitational Management
				31, // Centrifuge
				 4, // Warp Machine
				 3, // SA * RC
				20, // Event Horizon
				 5, // Professor's lab
				10  // Continuum
			};
			break;
	}
}

start
{
	if (old.LevelID != current.LevelID)
	{
		switch (game.ProcessName)
		{
			case "A Proof of Concept 1.1" : return old.LevelID == 1 && current.LevelID == 4;
			case "Concept - v2.6"         : return old.LevelID == 2 && current.LevelID == 11;
		}
	}
}

split
{
	if (old.LevelID != current.LevelID)
	{
		int oldIndex = vars.LevelIDByIndex.IndexOf(old.LevelID);
		int currIndex = vars.LevelIDByIndex.IndexOf(current.LevelID);
		return settings[oldIndex + "to" + currIndex];
	}
}

reset
{
	if (old.LevelID != current.LevelID)
	{
		switch (game.ProcessName)
		{
			case "A Proof of Concept 1.1" : return old.LevelID != 0 && old.LevelID != 4 && current.LevelID == 0;
			case "Concept - v2.6"         : return current.LevelID == 2;
		}
	}
}