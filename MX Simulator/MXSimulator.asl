state("mx")
{
	int PlayerID         : 0x26F234;
	int PlayersInRace    : 0x323220;

	int FirstLapCPs      : 0x17234C;
	int NormalLapCPs     : 0x172350;

	//double TickRate      : 0x162B90;
	int RaceTicks        : 0x322300;
	//int ServerStartTicks : 0x43248A0;

	string512 TrackName  : 0x31ED10, 0x0;
}

startup
{
	vars.TimerModel = new TimerModel { CurrentState = timer };

	vars.TimerStart = (EventHandler) ((s, e) => vars.ValidLap = true);
	timer.OnStart += vars.TimerStart;

	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var result = MessageBox.Show(
			"MX Simulator uses in-game time.\nWould you like to switch to it?",
			"MX Simulator Autosplitter",
			MessageBoxButtons.YesNo);

		if (result == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}

init
{
	#region Initializing Variables
	current.CPs = 0;
	current.id = 0;
	vars.StartTicks = 0;

	vars.CPsChanged = false;
	vars.OnFinalSplit = false;
	vars.OnFirstCP = false;
	vars.ValidLap = true;
	vars.ShowMsg = false;

	vars.checkpointWatcher = (MemoryWatcher<int>)null;
	vars.idWatcher = (MemoryWatcher<int>)null;
	#endregion

	#region Custom Functions
	// Whenever the player's position changes in a race (ghost in time trials counts too), the checkpoint memory address needs to be updated.
	vars.UpdateWatchers = (Action) (() =>
	{
		if (current.PlayersInRace > 0)
		{
			for (int i = 0; i < current.PlayersInRace; ++i)
			{
				vars.idWatcher = new MemoryWatcher<int>(new DeepPointer(0x322AA0 + 0xC * i));
				vars.idWatcher.Update(game);

				if (vars.idWatcher.Current == current.PlayerID)
				{
					vars.checkpointWatcher = new MemoryWatcher<int>(new DeepPointer(0x322AA4 + 0xC * i));
					break;
				}
			}
		}
	});

	// A message box to pop up when the current number of splits or track name doesn't line up with the currently loaded track.
	vars.TrackMsg = (Action) (() =>
	{
		DialogResult result = DialogResult.None;

		if (!String.IsNullOrEmpty(current.TrackName) && (current.NormalLapCPs > 0 && timer.Run.Count != current.NormalLapCPs || timer.Run.CategoryName != current.TrackName)) {
			result = MessageBox.Show(
				"Current splits configuration:\n" + "\"" + timer.Run.CategoryName + "\" with " + timer.Run.Count + " segments\n\n" +
				"Required configuration:\n" + "\"" + current.TrackName + "\" with " + current.NormalLapCPs + " segments\n\n" +
				"Do you want to save your splits now and generate new ones for this track?",
				"MX Simulator Auto Splitter",
				MessageBoxButtons.YesNo,
				MessageBoxIcon.Information
			);
		}

		if (result == DialogResult.Yes) {
			timer.Form.ContextMenuStrip.Items["saveSplitsAsMenuItem"].PerformClick();

			int currAmtSplits = timer.Run.Count;

			for (int gateNo = 1; gateNo <= current.NormalLapCPs; ++gateNo)
				timer.Run.Add(new Segment("Gate " + gateNo));

			for (int splitNo = 1; splitNo <= currAmtSplits; ++splitNo)
				timer.Run.RemoveAt(0);

			timer.Run.GameName = "MX Simulator";
			timer.Run.CategoryName = current.TrackName;
		}
	});

	// Using this instead of Thread.Sleep() so as to not block the thread.
	vars.Wait = (Action<int>) ((time) => System.Threading.Tasks.Task.Run(async () => await System.Threading.Tasks.Task.Delay(time)).Wait());
	#endregion

	vars.UpdateWatchers();
	vars.TrackMsg();
}

update
{
	if (vars.idWatcher == null || vars.checkpointWatcher == null)
	{
		vars.UpdateWatchers();
		return false;
	}

	#region Variable Updating
	// Updating several variables according to our needs.

	vars.idWatcher.Update(game);
	vars.checkpointWatcher.Update(game);
	current.CPs = vars.checkpointWatcher.Current;
	current.id = vars.idWatcher.Current;

	vars.CPsChanged = old.id == current.id && old.CPs != current.CPs || old.id != current.id && old.CPs == current.CPs;
	vars.OnFinalSplit = timer.CurrentSplitIndex == timer.Run.Count - 1;
	vars.OnFirstCP = (current.CPs - current.FirstLapCPs) % current.NormalLapCPs == 0;

	if (current.id != current.PlayerID) vars.UpdateWatchers();
	#endregion


	#region Splits Message
	// When the track the user is on changes, a messagebox will appear prompting them to save the splits and create new ones for this track.

	if (old.FirstLapCPs != old.FirstLapCPs ||
	    old.NormalLapCPs != current.NormalLapCPs ||
	    old.TrackName != current.TrackName && !String.IsNullOrEmpty(current.TrackName))
	{
		vars.ShowMsg = true;
	}

	if (vars.ShowMsg && current.RaceTicks > 0)
	{
		vars.ShowMsg = false;
		vars.MsgShownForTrack = current.TrackName;
		vars.TrackMsg();
	}
	#endregion


	#region Reset Handling
	// To accomodate for TimerPhase.Ended, we need to do this outside of the reset {} block.

	if (settings.ResetEnabled)
	{
		if (old.RaceTicks > current.RaceTicks ||
		    current.id != current.PlayerID ||
		    vars.CPsChanged && vars.OnFirstCP && (!vars.OnFinalSplit || !vars.ValidLap) && timer.CurrentSplitIndex > 0)
		{
			vars.Wait(500);
			vars.UpdateWatchers();
			vars.TimerModel.Reset();
		}

		if (timer.CurrentPhase == TimerPhase.Ended && old.id == current.id && old.CPs < current.CPs)
		{
			vars.TimerModel.Reset();
			vars.TimerModel.Start();

			vars.Wait(20);
		}
	}
	#endregion
}

start
{
	if (old.CPs != current.CPs && current.CPs == current.FirstLapCPs ||
	    current.CPs - current.FirstLapCPs > 0 && vars.OnFirstCP)
	{
		vars.StartTicks = current.RaceTicks;
		return true;
	}
}

split
{
	if (vars.CPsChanged)
	{
		if (old.PlayersInRace < current.PlayersInRace) return false;
		int expectedCP = old.CPs + 1, actualCP = current.CPs;

		if (expectedCP < actualCP)
		{
			vars.ValidLap = false;
			for (int i = expectedCP; i < actualCP; ++i)
				vars.TimerModel.SkipSplit();
		}

		if (vars.OnFirstCP)
		{
			vars.StartTicks = current.RaceTicks;
			if (!vars.OnFinalSplit || !vars.ValidLap) return false;
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
	return TimeSpan.FromSeconds((current.RaceTicks - vars.StartTicks) * 0.0078125);
}

isLoading
{
	return true;
}

exit
{
	vars.TimerModel.Reset();
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}