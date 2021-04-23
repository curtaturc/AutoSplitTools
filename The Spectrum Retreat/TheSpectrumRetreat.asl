state("Spectrum")
{
    int screen: "mono.dll", 0x01F50AC, 0xA80, 0x20, 0x24;
    int mouse : "UnityPlayer.dll", 0x0FD789C, 0x38, 0x20, 0x8, 0x44;
    int level : "UnityPlayer.dll", 0x0FD8D74, 0x54, 0x1E0, 0x22C, 0x3A0;
}

startup
{
    settings.Add("day1splits", true, "Day 1 splits:");
        settings.Add("day1time8", false, "Leave Room", "day1splits");
        settings.Add("day1time12", true, "Enter Code", "day1splits");
        settings.Add("day1and47to39", true, "Finishing 1_01", "day1splits");
        settings.Add("day1and39to26", true, "Finishing 1_02", "day1splits");
        settings.Add("day1and26to46", true, "Finishing 1_03", "day1splits");
        settings.Add("day1and46to135", true, "Finishing 1_04", "day1splits");
        settings.Add("day1and135to113", true, "Arrive back at Hotel (finishing 1_05)", "day1splits");

    settings.Add("day2splits", true, "Day 2 splits:");
        settings.Add("day2time7", false, "Wake Up", "day2splits");
        settings.Add("day2time8", false, "Leave Room", "day2splits");
        settings.Add("day2time9", false, "Finish Breakfast", "day2splits");
        settings.Add("day2time10", false, "Exit Elevator to Floor 2", "day2splits");
        settings.Add("day2time13", true, "Enter Code", "day2splits");
        settings.Add("day2and46to51", true, "Finishing 2_01", "day2splits");
        settings.Add("day2and51to59", true, "Finishing 2_02", "day2splits");
        settings.Add("day2and59to54", true, "Finishing 2_03", "day2splits");
        settings.Add("day2and54to46", true, "Finishing 2_04", "day2splits");
        settings.Add("day2and9to30", true, "Finishing 2_05", "day2splits");
        settings.Add("day2and30to26", true, "Finishing 2_06", "day2splits");
        settings.Add("day2and26to64", true, "Finishing 2_07", "day2splits");
        settings.Add("day2and64to53", true, "Finishing 2_08", "day2splits");
        settings.Add("day2and53to60", true, "Finishing 2_09", "day2splits");
        settings.Add("day2and18to8", true, "Arrive back at Hotel (finishing 2_10)", "day2splits");
        settings.Add("day2and8to113", false, "Taking Elevator to Floor 1", "day2splits");

    settings.Add("day3splits", true, "Day 3 splits:");
        settings.Add("day3time7", false, "Wake Up", "day3splits");
        settings.Add("day3time8", false, "Leave Room", "day3splits");
        settings.Add("day3time9", false, "Finish Breakfast", "day3splits");
        settings.Add("day3time10", false, "Exit Elevator to Floor 3", "day3splits");
        settings.Add("day3time13", true, "Enter Code", "day3splits");
        settings.Add("day3and31to50", true, "Finishing 3_01", "day3splits");
        settings.Add("day3and50to30", true, "Finishing 3_02", "day3splits");
        settings.Add("day3and30to31", false, "Finishing 3_03 (no skip)", "day3splits");
        settings.Add("day3and30to65", true, "Finishing 3_03 (with skip)", "day3splits");
        settings.Add("day3and31to65", true, "Finishing 3_04", "day3splits");
        settings.Add("day3and65to58", true, "Finishing 3_05", "day3splits");
        settings.Add("day3and58to36", true, "Finishing 3_06", "day3splits");
        settings.Add("day3and36to64", true, "Finishing 3_07", "day3splits");
        settings.Add("day3and64to60", false, "Finishing 3_08 (no skip)", "day3splits");
        settings.Add("day3and64to10", true, "Finishing 3_08 (with skip)", "day3splits");
        settings.Add("day3and60to10", true, "Arrive back at Hotel (finishing 3_09)", "day3splits");
        settings.Add("day3and10to113", false, "Taking Elevator to Floor 1", "day3splits");

    settings.Add("day4splits", true, "Day 4 splits:");
        settings.Add("day4time7", false, "Wake Up", "day4splits");
        settings.Add("day4time8", false, "Leave Room", "day4splits");
        settings.Add("day4time9", false, "Finish Breakfast", "day4splits");
        settings.Add("day4time10", false, "Exit Elevator to Floor 4", "day4splits");
        settings.Add("day4time14", true, "Enter Code", "day4splits");
        settings.Add("day4and80to41", true, "Finishing 4_01", "day4splits");
        settings.Add("day4and41to60", true, "Finishing 4_02", "day4splits");
        settings.Add("day4and60to44", false, "Finishing 4_03", "day4splits");
        settings.Add("day4and44to41", true, "Finishing 4_04", "day4splits");
        settings.Add("day4and41to46", true, "Finishing 4_05", "day4splits");
        settings.Add("day4and46to66", true, "Finishing 4_06", "day4splits");
        settings.Add("day4and66to65", true, "Finishing 4_07", "day4splits");
        settings.Add("day4and65to10", true, "Arrive back at Hotel (finishing 4_08)", "day4splits");
        settings.Add("day4and10to113", false, "Taking Elevator to Floor 1", "day4splits");

    settings.Add("day5splits", true, "Day 5 splits:");
        settings.Add("day5time7", false, "Wake Up", "day5splits");
        settings.Add("day5time8", false, "Leave Room", "day5splits");
        settings.Add("day5time9", false, "Finish Breakfast", "day5splits");
        settings.Add("day5time10", false, "Exit Elevator to Floor 5", "day5splits");
        settings.Add("day5time13", true, "Enter Code", "day5splits");
        settings.Add("day5and160to8", true, "Arrive back at Hotel (finishing 5_01)", "day5splits");
        settings.Add("day5and8to113", false, "Taking Elevator to Floor 1", "day5splits");

    settings.Add("day6splits", false, "Day 6 splits:");
        settings.Add("day6time7", false, "Wake Up", "day6splits");
        settings.Add("day6time9", false, "Leave Room", "day6splits");
        settings.Add("day6time10", false, "Exit Elevator to Roof", "day6splits");
}

init
{
    string logPath = Environment.GetEnvironmentVariable("appdata")+"\\..\\LocalLow\\Ripstone\\The Spectrum Retreat\\output_log.txt";
    vars.line = "";
    vars.reader = new StreamReader(new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite));

    vars.time = "";
    vars.day = "1";
    vars.date = "";
    vars.roofHelp = 0;
    vars.lastRealLevel = 0;
    vars.storeNewLevel = 0;

    vars.reader.BaseStream.Seek(0, SeekOrigin.End);
}

update {
    if (vars.reader == null) return false;
    vars.line = vars.reader.ReadLine();

    if (old.level != current.level && current.level != 0)
    {
        vars.lastRealLevel = vars.storeNewLevel;
        vars.storeNewLevel = current.level;
        print(">>>>> storeNewLevel changed to " + vars.storeNewLevel + " and lastRealLevel changed to " + vars.lastRealLevel);
    }

    if (vars.line != null && vars.line.StartsWith("Time advanced to "))
    {
        vars.time = vars.line.Split(' ')[3];
        vars.day  = vars.line.Split(' ')[6];
        vars.date = "day" + vars.day.ToString() + "time" + vars.time.ToString();
    }
}

start
{
    if (current.screen != 14 && old.screen == 14)
    {
        vars.roofHelp = 0;
        return true;
    }
}

reset
{
    return (current.screen == 14 && old.screen == 18);
}

split
{
    if (vars.line != null && vars.line.StartsWith("Time advanced to ") && settings[vars.date])
    {
        print(">>>>> got split because settings is " + vars.date);
        return true;
    }

    if (vars.date == "day6time10" && old.mouse == 257 && current.mouse == 0)
    {
        vars.roofHelp++;
        if (vars.roofHelp == 2) {
            print(">>>>> got split because roofHelp is " + vars.roofHelp);
            return true;
        }
    }

    if (old.level != current.level && vars.lastRealLevel != vars.storeNewLevel && settings["day" + vars.day + "and" + vars.lastRealLevel + "to" + vars.storeNewLevel])
    {
        print(">>>>> got split because settings is " + vars.lastRealLevel + "to" + vars.storeNewLevel);
        vars.lastRealLevel = vars.storeNewLevel;
        print(">>>>> storeNewLevel changed to " + vars.storeNewLevel);
        return true;
    }
}

exit
{
    vars.reader = null;
}