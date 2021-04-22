state("HelloNeighbor-Win64-Shipping")
{
	bool IsPlaying : 0x29C2C44;
	bool InControl : 0x2C4C258, 0xC8, 0x258, 0xAE0, 0x1B8;
}

start
{
	return !old.InControl && current.InControl;
}

isLoading
{
	return !current.IsPlaying;
}