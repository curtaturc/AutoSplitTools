state("Post Void")
{
	//double inGameScore : 0x128AE8, 0x50, 0x21C, 0x318, 0x0;
	//double hitsTaken   : 0x4B2780, 0x2C, 0x10, 0x18, 0x40;
	//double headshots   : 0x4B2780, 0x2C, 0x10, 0x18, 0x60;
	//double shots       : 0x4B2780, 0x2C, 0x10, 0x18, 0x70;
	//double hits        : 0x4B2780, 0x2C, 0x10, 0x18, 0x80;
	//double kills       : 0x4B2780, 0x2C, 0x10, 0x18, 0xA0;
	double igtLvl      : 0x4B2780, 0x2C, 0x10, 0x18, 0xB0;
	double igtFull     : 0x4B2780, 0x2C, 0x10, 0x18, 0xC0;
	double lvlID       : 0x4B2780, 0x2C, 0x10, 0x18, 0xE0;
}

startup
{
    vars.timerModel = new TimerModel {CurrentState = timer};

    settings.Add("lvlSplits", true, "Choose which level(s) to split on:");
        settings.Add("99to0", true, "After the Tutorial", "lvlSplits");
        settings.Add("0to1", true, "After Level 1", "lvlSplits");
        settings.Add("1to2", true, "After Level 2", "lvlSplits");
        settings.Add("2to3", true, "After Level 3", "lvlSplits");
        settings.Add("3to4", true, "After Level 4", "lvlSplits");
        settings.Add("4to5", true, "After Level 5", "lvlSplits");
        settings.Add("5to6", true, "After Level 6", "lvlSplits");
        settings.Add("6to7", true, "After Level 7", "lvlSplits");
        settings.Add("7to8", true, "After Level 8", "lvlSplits");
        settings.Add("8to9", true, "After Level 9", "lvlSplits");
        settings.Add("9to10", true, "After Level 10", "lvlSplits");
        settings.Add("finalSplit", true, "After Level 11", "lvlSplits");
}

start
{
    if (old.igtFull == 0 && current.igtFull > 0)
    {
        vars.finalLevel = false;
        return true;
    }
}

split
{
    bool finalLevel = current.lvlID == 10 && old.igtLvl == 0 && current.igtLvl > 0;

    return
        old.lvlID != current.lvlID && settings[old.lvlID + "to" + current.lvlID] ||
        finalLevel && old.igtLvl > 0 && current.igtLvl == 0 && settings["finalSplit"];
}

reset
{
    return old.lvlID != 99 && current.igtFull == 0 && old.igtFull > 0;
}

gameTime
{
    if (current.igtFull != 0) return TimeSpan.FromSeconds(current.igtFull);
}

isLoading
{
    return true;
}

exit
{
    if (timer.CurrentPhase != TimerPhase.Ended) vars.timerModel.Reset();
}