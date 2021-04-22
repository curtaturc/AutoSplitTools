state("AndAllWouldCryBeware")
{
	int Area     : "UnityPlayer.dll", 0x1092D68, 0xE48;
	int Entities : "UnityPlayer.dll", 0x10545C0, 0x9CC, 0x28, 0x8, 0x84, 0x210;
}

startup
{
	settings.Add("areaSplits", true, "Split when entering a new area:");
		settings.Add("7to21", false, "Wayfarer Offices", "areaSplits");
		settings.Add("21to27", true, "Mysterious Alien World", "areaSplits");
		settings.Add("16to11", true, "A Fresh Start", "areaSplits");

	settings.Add("eventSplits", false, "Split when doing certain events:");
		settings.Add("7-6", false, "Pick up Pistol", "eventSplits");
		settings.Add("6-5", false, "Pick up Green Key", "eventSplits");
		settings.Add("5-4", false, "Destroy Elevator", "eventSplits");
		settings.Add("4-3", false, "Defeat Security Mech", "eventSplits");
		settings.Add("MAW", false, "Defeat any boss in the Mysterious Alien World or collect Fire Orb", "eventSplits");
		settings.Add("16to7", false, "Defeat Transformed Rebekah", "eventSplits");
}

init
{
	vars.AllRealAreas = new HashSet<int> { 7, 8, 9, 11, 16, 21, 27 };
}

update
{
	if (!vars.AllRealAreas.Contains(current.Area))
		current.Area = old.Area;
}

start
{
	return old.Area != 7 && current.Area == 7;
}

split
{
	if (current.Entities == old.Entities - 1)
	{
		switch ((int)current.Area)
		{
			case 21: return settings[old.Entities + "-" + current.Entities];
			case 27: return settings["MAW"];
		}
	}

	return settings[old.Area + "to" + current.Area] ||
	       old.Area == 11 && current.Area == 9 ||
	       old.Area == 7 && current.Area == 8;
}