// This needs to be made into a goddamn component. This game is so shit.

state("mx")
{
	int playerID         : "mx.exe", 0x26E894;
	int playersInRace    : "mx.exe", 0x322A00;

	int firstLapCPs      : "mx.exe", 0x32094C;
	int normalLapCPs     : "mx.exe", 0x320950;

	//double tickRate      : "mx.exe", 0x162B90;
	int raceTicks        : "mx.exe", 0x321AE0;
	//int serverStartTicks : "mx.exe", 0x43248A0;

	string512 trackName  : "mx.exe", 0x31E4F0, 0x0;
}

startup
{
	vars.timerModel = new TimerModel { CurrentState = timer };

	vars.timerStart = (EventHandler) ((s, e) => vars.validLap = true);
	timer.OnStart += vars.timerStart;

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var Result = MessageBox.Show(
			"MX Simulator uses in-game time.\nWould you like to switch to it?",
			"MX Simulator Autosplitter",
			MessageBoxButtons.YesNo);

		if (Result == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}

init
{
	#region Initializing Variables
	current.CPs = 0;
	current.id = 0;
	vars.startTicks = 0;

	vars.CPsChanged = false;
	vars.onFinalSplit = false;
	vars.onFirstCP = false;
	vars.validLap = true;
	vars.showMsg = false;

	vars.checkpointWatcher = (MemoryWatcher<int>)null;
	vars.idWatcher = (MemoryWatcher<int>)null;
	#endregion

	#region Custom Functions
	// Whenever the player's position changes in a race (ghost in time trials counts too), the checkpoint memory address needs to be updated.
	vars.updateWatchers = (Action) (() =>
	{
		if (current.playersInRace > 0)
		{
			IntPtr ptr = IntPtr.Zero;
			for (int i = 0; i < current.playersInRace; ++i)
			{
				vars.idWatcher = new MemoryWatcher<int>(new DeepPointer("mx.exe", 0x322280 + 0xC * i));
				vars.idWatcher.Update(game);

				if (vars.idWatcher.Current == current.playerID)
				{
					vars.checkpointWatcher = new MemoryWatcher<int>(new DeepPointer("mx.exe", 0x322284 + 0xC * i));
					break;
				}
			}
		}
	});

	// A message box to pop up when the current number of splits or track name doesn't line up with the currently loaded track.
	vars.message = (Action) (() =>
	{
		bool hasLoaded = false;
		DialogResult result = DialogResult.None;

		if (!String.IsNullOrEmpty(current.trackName) && (current.normalLapCPs > 0 && timer.Run.Count != current.normalLapCPs || timer.Run.CategoryName != current.trackName)) {
			result = MessageBox.Show(
				"Current splits configuration:\n" + "\"" + timer.Run.CategoryName + "\" with " + timer.Run.Count + " segments\n\n" +
				"Required configuration:\n" + "\"" + current.trackName + "\" with " + current.normalLapCPs + " segments\n\n" +
				"Do you want to save your splits now and generate new ones for this track?",
				"MX Simulator Auto Splitter",
				MessageBoxButtons.YesNo,
				MessageBoxIcon.Information
			);
		}

		if (result == DialogResult.Yes) {
			LiveSplitState _state = (LiveSplitState)new LiveSplitState(timer.Run, timer.Form, timer.Layout, timer.LayoutSettings, timer.Settings).Clone();
			_state.Form.ContextMenuStrip.Items["saveSplitsAsMenuItem"].PerformClick();

			/*if (Directory.EnumerateFiles(Directory.GetCurrentDirectory() + @"\Resources\Splits").Any(fileName => fileName.Contains(current.trackName)))
			{
				result = MessageBox.Show(
					"A file for this track has been found in your directory. Would you like to load it?",
					"MX Simulator Auto Splitter",
					MessageBoxButtons.YesNo,
					MessageBoxIcon.Exclamation);

				if (result == DialogResult.Yes)
					_state.Form.ContextMenuStrip.Items["openSplitsFileMenuItem"].PerformClick(); // "openSplitsFromFileMenuItem" is not a valid object. Need to investigate.

				hasLoaded = true;
			}*/

			if (!hasLoaded)
			{
				int currAmtSplits = timer.Run.Count;

				for (int gateNo = 1; gateNo <= current.normalLapCPs; ++gateNo)
					timer.Run.Add(new Segment("Gate " + gateNo));

				for (int splitNo = 1; splitNo <= currAmtSplits; ++splitNo)
					timer.Run.RemoveAt(0);

				timer.Run.GameName = "MX Simulator";
				timer.Run.CategoryName = current.trackName;
			}
		}
	});

	// Using this instead of Thread.Sleep() so as to not block the thread.
	vars.wait = (Action<int>) ((time) => System.Threading.Tasks.Task.Run(async () => await System.Threading.Tasks.Task.Delay(time)).Wait());
	#endregion

	vars.updateWatchers();
	vars.message();
}

update
{
	if (vars.idWatcher == null || vars.checkpointWatcher == null)
	{
		vars.updateWatchers();
		return false;
	}

	#region Variable Updating
	// Updating several variables according to our needs.

	vars.idWatcher.Update(game);
	vars.checkpointWatcher.Update(game);
	current.CPs = vars.checkpointWatcher.Current;
	current.id = vars.idWatcher.Current;

	vars.CPsChanged = old.id == current.id && old.CPs != current.CPs || old.id != current.id && old.CPs == current.CPs;
	vars.onFinalSplit = timer.CurrentSplitIndex == timer.Run.Count - 1;
	vars.onFirstCP = (current.CPs - current.firstLapCPs) % current.normalLapCPs == 0;

	if (current.id != current.playerID) vars.updateWatchers();
	#endregion


	#region Splits Message
	// When the track the user is on changes, a messagebox will appear prompting them to save the splits and create new ones for this track.

	if (old.firstLapCPs != old.firstLapCPs ||
	    old.normalLapCPs != current.normalLapCPs ||
	    old.trackName != current.trackName && !String.IsNullOrEmpty(current.trackName))
	{
		vars.showMsg = true;
	}

	if (vars.showMsg && current.raceTicks > 0)
	{
		vars.showMsg = false;
		vars.msgShownForTrack = current.trackName;
		vars.message();
	}
	#endregion


	#region Reset Handling
	// To accomodate for TimerPhase.Ended, we need to do this outside of the reset {} block.

	if (settings.ResetEnabled)
	{
		if (old.raceTicks > current.raceTicks ||
		    current.id != current.playerID ||
		    vars.CPsChanged && vars.onFirstCP && (!vars.onFinalSplit || !vars.validLap) && timer.CurrentSplitIndex > 0)
		{
			vars.wait(500);
			vars.updateWatchers();
			vars.timerModel.Reset();
		}

		if (timer.CurrentPhase == TimerPhase.Ended && old.id == current.id && old.CPs < current.CPs)
		{
			vars.timerModel.Reset();
			vars.timerModel.Start();

			vars.wait(20);
		}
	}
	#endregion
}

start
{
	if (old.CPs != current.CPs && current.CPs == current.firstLapCPs ||
	    current.CPs - current.firstLapCPs > 0 && vars.onFirstCP)
	{
		vars.startTicks = current.raceTicks;
		return true;
	}
}

split
{
	if (vars.CPsChanged)
	{
		if (old.playersInRace < current.playersInRace) return false;
		int expectedCP = old.CPs + 1, actualCP = current.CPs;

		if (expectedCP < actualCP)
		{
			vars.validLap = false;
			for (int i = expectedCP; i < actualCP; ++i)
				vars.timerModel.SkipSplit();
		}

		if (vars.onFirstCP)
		{
			vars.startTicks = current.raceTicks;
			if (!vars.onFinalSplit || !vars.validLap) return false;
		}

		return true;
	}
}

reset
{
	return false;
}

gameTime
{
	return TimeSpan.FromSeconds((current.raceTicks - vars.startTicks) * 0.0078125);
}

isLoading
{
	return true;
}

exit
{
	vars.timerModel.Reset();
}

shutdown
{
	timer.OnStart -= vars.timerStart;
}