state("AWC")
{
	string64 Chapter : "mono-2.0-bdwgc.dll", 0x491A90, 0xD00, 0x28, 0x20, 0x14;
	int LevelState   : "mono-2.0-bdwgc.dll", 0x491A90, 0xD00, 0x40;
	int StartValue   : "UnityPlayer.dll", 0x17E1760, 0xE8, 0x58, 0x20, 0xE8;
}

start
{
	return old.StartValue == 4 && current.StartValue == 0;
}

split
{
	return old.StartValue == 0 && current.StartValue == 4 || (
	       current.Chapter.Contains("EspressoMachine")
	       ? old.LevelState == 5 && current.LevelState == 8
	       : old.LevelState == 4 && current.LevelState == 5);
}

reset
{
	return old.StartValue == 4 && current.StartValue == 0;
}