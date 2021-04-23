state("LightmatterSub")
{
	long EventLogCheck : "mono-2.0-bdwgc.dll", 0x490A68, 0x50, 0x180, 0x0, 0xF8, 0x88;
}

startup
{
	settings.Add("ilTime", false, "Individual Level timer behavior (hover for info)");
	settings.SetToolTip("ilTime", "Restarts the timer when pressing \'RETRY\'\nSyncs to in-game time (set LiveSplit comparison to \'Game Time\')");
	settings.Add("pushSplits", false, "Split whenever pressing a button/flipping a lever", "ilTime");
	settings.Add("showVO", false, "Display the current Voice Over", "ilTime");

	string[,] SettingsArray =
	{
		{ "Level 2", "Start_Unbelievable", "Unbelievable!" }
	};

	for (int i = 0; i < SettingsArray.GetLength(0); ++i)
	{
		string parent = SettingsArray[i, 0];
		string id     = SettingsArray[i, 1];
		string desc   = SettingsArray[i, 2];

		try { settings.Add(parent, false, "Split on new voice over in " + parent + ":", "ilTime"); } catch {}
		settings.Add(id, false, desc, parent);
	}

	vars.CreateTextComponent = (Func<string, string, LiveSplit.UI.Components.IComponent>) ((name, value) =>
	{
		foreach (dynamic component in timer.Layout.Components)
		{
			if (component.GetType().Name == "TextComponent" && component.Settings.Text1.Equals(name))
			{
				return component;
			}
		}

		var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
		dynamic textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
		timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
		textComponent.Settings.Text1 = name;
		textComponent.Settings.Text2 = value;
		return textComponent;
	});

	vars.RemoveTextComponent = (Action<string>) ((text1) =>
	{
		int indexToRemove = -1;
		foreach (dynamic component in timer.Layout.Components)
		{
			if (component.GetType().Name == "TextComponent" && component.Settings.Text1.Equals(text1))
			{
				indexToRemove = timer.Layout.Components.ToList().IndexOf(component);
				break;
			}
		}

		timer.Layout.LayoutComponents.RemoveAt(indexToRemove);
	});

	vars.VOFromPath = (Func<string, string>) ((path) =>
	{
		if (String.IsNullOrEmpty(input)) return "None";
		else return input.Substring(input.LastIndexOf('/') + 1);
	});
}

init
{
	#region Finding Pointers
	IntPtr Player_Common, EventLogManager, FMod;
	Player_Common = EventLogManager = FMod = IntPtr.Zero;
	
	var Timeout = new Stopwatch();
	vars.PtrsFound = false;

	Timeout.Start();
	while (!vars.PtrsFound)
	{
		new DeepPointer("fmodstudio.dll", 0x2B3CF0, 0x110, 0x10, 0x0, 0x28).DerefOffsets(game, out FMod);
		new DeepPointer("mono-2.0-bdwgc.dll", 0x490A68, 0x50, 0x140, 0x0).DerefOffsets(game, out Player_Common);
		new DeepPointer("mono-2.0-bdwgc.dll", 0x490A68, 0x50, 0x180, 0x0, 0xF8, 0x0).DerefOffsets(game, out EventLogManager);

		vars.PtrsFound = new[] { Player_Common, EventLogManager, FMod }.All(x => x != IntPtr.Zero);
		if (Timeout.ElapsedMilliseconds >= 15000) break;
	}
	Timeout.Reset();

	if (!vars.PtrsFound)
	{
		MessageBox.Show(
			"Pointer scan timed out!\n" +
			"Please contact Ero#1111 on Discord.",
			"Lightmatter Autosplitter"
		);

	}
	else
	{
		vars.StartVal = new MemoryWatcher<int>(FMod);
		vars.LevelID = new MemoryWatcher<int>(new DeepPointer(Player_Common + 0x58, 0xA0));
		vars.MovSpeed = new MemoryWatcher<float>(Player_Common + 0x168);
		vars.LvlTime = new MemoryWatcher<float>(EventLogManager + 0x0);
		vars.TotalTime = new MemoryWatcher<float>(EventLogManager + 0x4);
		vars.VOPath = new StringWatcher(new DeepPointer(EventLogManager + 0x18, 0x14), 256);
		vars.PushCount = new MemoryWatcher<int>(EventLogManager + 0x40);

		vars.Watchers = new MemoryWatcherList { vars.StartVal, vars.LevelID, vars.MovSpeed, vars.LvlTime, vars.TotalTime, vars.VOPath, vars.PushCount };
	}
	#endregion

	try
	{
		foreach (dynamic component in timer.Layout.Components)
		{
			if (component.GetType().Name == "TextComponent" && component.Settings.Text1.Equals("Recent VO:"))
			{
				vars.TextComponent = component;
			}
		}
	}
	catch
	{
		if (settings["showVO"] && vars.PtrsFound) vars.TextComponent = vars.CreateTextComponent("Recent VO:", "None");
	}
}

update
{
	if (!vars.PtrsFound) return false;

	if ((current.voSetting = settings["showVO"]) != old.voSetting)
	{
		if (current.voSetting) vars.TextComponent = vars.CreateTextComponent("Recent VO:", "None");
		else vars.RemoveTextComponent("Recent VO:");
	}

	if (current.EventLogCheck == 0) return;
	vars.Watchers.UpdateAll(game);

	current.VoiceOver = vars.VOFromPath(vars.VOPath.Current);

	try { if (current.voSetting) vars.TextComponent.Settings.Text2 = current.VoiceOver; } catch {}
}

start
{
	if (settings["ilTime"])
	{
		return vars.LvlTime.Old > vars.LvlTime.Current && vars.LevelID.Old == vars.LevelID.Current;
	}
	else
	{
		return vars.StartVal.Old == 3 && vars.StartVal.Current == 2 && vars.LevelID.Current == 0;
	}
}

split
{
	bool transitionedLevel = vars.LevelID.Current == vars.LevelID.Old + 1 && vars.LevelID.Current <= 37;

	if (settings["ilTime"])
	{
		bool newPush = vars.PushCount.Current == vars.PushCount.Old + 1 && settings["pushSplits"];
		bool newVO = old.VoiceOver != current.VoiceOver && !String.IsNullOrEmpty(current.VoiceOver) && settings[current.VoiceOver];
		bool newLevel = vars.LvlTime.Old > vars.LvlTime.Current && transitionedLevel;

		return newLevel || newPush || newVO;
	}
	else
	{
		bool pressedInFinalRoom = vars.MovSpeed.Current == 0.3f && current.Level == 37 && vars.PushCount.Current == vars.PushCount.Old + 1;

		return transitionedLevel || pressedInFinalRoom;
	}
}

reset
{
	bool returnToLvl1 = vars.LevelID.Old != 0 && vars.LevelID.Current == 0;
	bool returnToMenu = vars.LevelID.Current == 0 && vars.StartVal.Old == 2 && vars.StartVal.Current == 3;
	bool timeResetSameLevel = vars.LvlTime.Old > vars.LvlTime.Current && vars.LevelID.Old == vars.LevelID.Current;

	return returnToLvl1 || returnToMenu || timeResetSameLevel && settings["ilTime"];
}

gameTime
{
	if (settings["ilTime"])
	{
		if (vars.LvlTime.Current >= 0.01f)
			return TimeSpan.FromSeconds(vars.LvlTime.Current);
	}
	else
	{
		if (vars.TotalTime.Current >= 0.01f)
			return TimeSpan.FromSeconds(vars.TotalTime.Current);
	}
}

isLoading
{
	return true;
}