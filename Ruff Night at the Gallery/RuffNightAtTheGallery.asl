state("Nori-Win64-Shipping")
{
	// UWorld.Nori_GameInstance.SaveGame.CurrentRoomID
	string32 RoomID          : 0x3F29F40, 0x188, 0x198, 0x28, 0x0;

	// UWorld.PersistentLevel.UNKNOWN.Nori_LevelInfo.OrderedRoomNodes[14].RoomGate.Locked
	bool     FinalGateLocked : 0x3F29F40, 0x30, 0x98, 0xB8, 0x238, 0x70, 0x268, 0x2A0;
}

startup
{
	string[][] rooms =
	{
		new[] {    "Room_Left_00", "First Lobby" },
		new[] {    "Room_Left_01", "Mona Lisa" },
		new[] {    "Room_Left_02", "American Gothic" },
		new[] {    "Room_Left_03", "Self-Portrait with Thorn Necklace and Hummingbird" },
		new[] {    "Room_Left_04", "Girl before a Mirror" },
		new[] {   "Room_Right_00", "Second Lobby" },
		new[] {   "Room_Right_01", "Girl with a Pearl Earring & Self-Portrait (van Gogh)" },
		new[] {   "Room_Right_02", "Girl before a Mirror, The Scream, & American Gothic" },
		new[] {   "Room_Right_04", "Room with 4 Portraits" },
		new[] {   "Room_Final_00", "Third Lobby" },
		new[] {   "Room_Final_01", "The Son of Man" },
		new[] { "Room_Credits_00", "Credits" }
	};

	settings.Add("splits", true, "Split upon leaving these rooms:");
	foreach (var room in rooms)
		settings.Add(room[0], true, room[1], "splits");

	vars.Stopwatch = new Stopwatch();
	vars.CompletedRooms = new HashSet<string>();
	vars.PrevLevel = "Room_Left_00";

	vars.TimerStart = (EventHandler) ((s, e) => vars.CompletedRooms.Clear());
	timer.OnStart += vars.TimerStart;
}

init
{
	// UWorld.PersistentLevel.UNKNOWN.ACharacter.RootComponent.AbsolutePosition
	vars.Position = new MemoryWatcher<Vector3f>(new DeepPointer(0x3F29F40, 0x30, 0xA8, 0x68, 0x130, 0x100));
}

update
{
	vars.Position.Update(game);

	if (!string.IsNullOrEmpty(old.RoomID) && string.IsNullOrEmpty(current.RoomID))
		vars.PrevLevel = old.RoomID;
}

start
{
	return vars.Position.Old.X ==  250f && vars.Position.Current.X !=  250f ||
	       vars.Position.Old.Y == 1900f && vars.Position.Current.Y != 1900f;
}

split
{
	if (string.IsNullOrEmpty(current.RoomID)) return;

	return old.RoomID != current.RoomID && settings[old.RoomID] ||
	       old.FinalGateLocked && !current.FinalGateLocked;
}

reset
{
	return string.IsNullOrEmpty(old.RoomID) && current.RoomID == "Room_Left_00";
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}
