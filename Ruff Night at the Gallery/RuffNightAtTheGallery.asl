state("Nori-Win64-Shipping") {}

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

	vars.CompletedRooms = new HashSet<string>();

	vars.TimerStart = (EventHandler) ((s, e) => vars.CompletedRooms.Clear());
	timer.OnStart += vars.TimerStart;
}

init
{
	// UWorld.PersistentLevel.UNKNOWN.ACharacter.RootComponent.AbsolutePosition
	vars.Position = new MemoryWatcher<Vector3f>(new DeepPointer(0x3F29F40, 0x30, 0xA8, 0x68, 0x130, 0x100));

	// UWorld.Nori_GameInstance.SaveGame.CurrentRoomID
	vars.RoomID = new StringWatcher(new DeepPointer(0x3F29F40, 0x188, 0x198, 0x28, 0x0), 32) { FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull };

	// UWorld.PersistentLevel.UNKNOWN.Nori_LevelInfo.OrderedRoomNodes[14].RoomGate.Locked
	vars.FinalGateLocked = new MemoryWatcher<bool>(new DeepPointer(0x3F29F40, 0x30, 0x98, 0xB8, 0x238, 0x70, 0x268, 0x2A0));
}

update
{
	vars.Position.Update(game);
	vars.RoomID.Update(game);
	vars.FinalGateLocked.Update(game);
}

start
{
	return vars.Position.Old.X ==  250f && vars.Position.Current.X !=  250f ||
	       vars.Position.Old.Y == 1900f && vars.Position.Current.Y != 1900f;
}

split
{
	if (string.IsNullOrEmpty(vars.RoomID.Current)) return;

	if (vars.RoomID.Changed && !vars.CompletedRooms.Contains(vars.RoomID.Old))
	{
		vars.CompletedRooms.Add(vars.RoomID.Old);
		return settings[vars.RoomID.Old];
	}

	return vars.FinalGateLocked.Old && !vars.FinalGateLocked.Current;
}

reset
{
	return string.IsNullOrEmpty(vars.RoomID.Old) && vars.RoomID.Current == "Room_Left_00";
}

isLoading
{
	return string.IsNullOrEmpty(vars.RoomID.Current);
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}
