state("Where is 2018")
{
	int screen: 0x6A7F98;
}

state("Where is 2019")
{
	int screen: 0x6B2D88;
}

state("Where is 2020")
{
	int screen: 0x6C2DB8;
}

init
{
	switch (game.ProcessName)
	{
		case "Where is 2018": vars.game = 2018;
		case "Where is 2019": vars.game = 2019;
		case "Where is 2020": vars.game = 2020;
	}

	vars.screenChange = (Func(<int, int, bool>) ((old, curr) => old.screen == old && current.screen == curr ? true : false);
}

start
{
	switch ((int)vars.game)
	{
		case 2018: return vars.screenChange(2, 3);
		case 2019: return vars.screenChange(3, 5);
		case 2020: return vars.screenChange(3, 6);
	}
}

reset
{
	return vars.game != 2016 &&
	       (old.screen != 2 && current.screen == 2 ||
	       old.screen != 0 && current.screen == 0);
}

split
{
	return vars.game == 2018 && old.screen != current.screen ||
	       vars.game == 2019 && old.screen < current.screen && !(new[]{8, 9, 38, 39, 41}.Contains(old.screen)) ||
	       vars.game == 2020 && old.screen < current.screen;
}