state("Just Shake It")
{
	bool isEnding  : "UnityPlayer.dll", 0x19B5F90, 0xB48, 0x720, 0xF48, 0x18, 0x48;
	int checkpoint : "UnityPlayer.dll", 0x19B5F90, 0xB48, 0x720, 0xF48, 0x40, 0x28;
	float ms       : "UnityPlayer.dll", 0x19B5F90, 0xB48, 0x720, 0xF48, 0x48, 0x28;
	int min        : "UnityPlayer.dll", 0x19B5F90, 0xB48, 0x720, 0xF48, 0x48, 0x2C;
	int s          : "UnityPlayer.dll", 0x19B5F90, 0xB48, 0x720, 0xF48, 0x48, 0x30;
	bool isStart   : "UnityPlayer.dll", 0x19B5F90, 0xB48, 0x720, 0xF48, 0x48, 0x34;
}

startup
{
	timer.CurrentTimingMethod = TimingMethod.GameTime;
}

start
{
	return !old.isStart && current.isStart;
}

split
{
	return old.checkpoint != current.checkpoint && current.checkpoint > 1 || !old.isEnding && current.isEnding;
}

reset
{
	return old.isStart != current.isStart;
}

gameTime
{
	return TimeSpan.FromSeconds(current.min * 60 + current.s + current.ms);
}

isLoading
{
	return true;
}