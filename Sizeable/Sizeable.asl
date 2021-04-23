state("Sizeable")
{
	string32 ThisScene : "UnityPlayer.dll", 0x1800DA8, 0x48, 0x40;
	string32 NextScene : "UnityPlayer.dll", 0x1800DA8, 0x28, 0x0, 0x40;
}

startup
{
	vars.TimerStart = (EventHandler) ((s, e) => vars.DoneSplits.Clear());
	timer.OnStart += vars.TimerStart;
}

init
{
	vars.DoneSplits = new HashSet<string>();
}

start
{
	bool fromMainMenu = old.NextScene == "Main Menu" && new[] { "Main Menu", "LevelSelect", "Options" }.All(x => x != current.NextScene);
	bool fromLevelSelect = old.NextScene == "LevelSelect" && new[] { "LevelSelect", "Main Menu" }.All(x => x != current.NextScene);

	return fromMainMenu || fromLevelSelect;
}

split
{
	bool toLevelSelect = old.NextScene != "LevelSelect" && current.NextScene == "LevelSelect";
	bool toCredits = old.NextScene != "End of Game" && current.NextScene == "End of Game";

	if ((toLevelSelect || toCredits) && !vars.DoneSplits.Contains(old.NextScene))
	{
		vars.DoneSplits.Add(old.NextScene);
		return true;
	}
}

reset
{
	return old.NextScene != "Options" && current.NextScene == "Options";
}

isLoading
{
	return current.ThisScene != current.NextScene;
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}