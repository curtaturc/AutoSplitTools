state("HelloNeighbor-Win64-Shipping")
{
	bool IsPlaying : 0x29C2C44;
	bool InControl : 0x2C4C258, 0xC8, 0x258, 0xAE0, 0x1B8;
}

startup
{
	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var mbox = MessageBox.Show(
			"Removing loads from Hello Neighbor requires comparing against Game Time.\nWould you like to switch to it?",
			"Hello Neighbor Load Remover",
			MessageBoxButtons.YesNo);

		if (mbox == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}

start
{
	return !old.InControl && current.InControl;
}

isLoading
{
	return !current.IsPlaying;
}