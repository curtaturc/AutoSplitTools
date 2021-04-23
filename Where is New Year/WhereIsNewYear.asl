state("Where is 2018")
{
	int Screen: 0x6A7F98;
}

state("Where is 2019")
{
	int Screen: 0x6B2D88;
}

state("Where is 2020")
{
	int Screen: 0x6C2DB8;
}

init
{
	switch (game.ProcessName)
	{
		case "Where is 2018": vars.Game = 2018; break;
		case "Where is 2019": vars.Game = 2019; break;
		case "Where is 2020": vars.Game = 2020; break;
	}

	vars.ScreenChange = (Func<int, int, bool>) ((_old, _current) => old.Screen == _old && current.Screen == _current ? true : false);
	vars.Exclude2019 = new List<int> { 8, 9, 38, 39, 41 };
}

start
{
	switch ((int)vars.Game)
	{
		case 2018: return vars.ScreenChange(2, 3);
		case 2019: return vars.ScreenChange(3, 5);
		case 2020: return vars.ScreenChange(3, 6);
	}
}

split
{
	return vars.Game == 2018 && old.Screen != current.Screen ||
	       vars.Game == 2019 && old.Screen < current.Screen && !vars.Exclude2019.Contains(old.Screen) ||
	       vars.Game == 2020 && old.Screen < current.Screen;
}