state("Nori-Win64-Shipping")
{
	int keys           : 0x3E5A530, 0x10F0;
	byte1 mov          : 0x3E9EC28, 0x20, 0x240, 0x4C0, 0x14;
	//int challengesDone : 0x3EC3C98, 0xA0, 0xEF0, 0x18;
	float xPos         : 0x3EE9668, 0x1790, 0x838;
	float yPos         : 0x3EE9668, 0x1790, 0x83C;
	//float zPos         : 0x3EE9668, 0x1790, 0x840;
}

startup
{
	var tB = (Func<float, float, float, float, Tuple<float, float, float, float>>) ((xMin, xMax, yMin, yMax) => Tuple.Create(xMin, xMax, yMin, yMax));

	vars.parts = new Dictionary<string, Tuple<float, float, float, float>>
	{
		{ "Mona Lisa",                                         tB( 2300f,  2450f, -310f, -300f) },
		{ "American Gothic",                                   tB( 3300f,  3450f, -220f, -210f) },
		{ "Self-Portrait with Thorn Necklace and Hummingbird", tB( 4300f,  4450f, 1770f, 1780f) },
		{ "Girl before a Mirror",                              tB( 2210f,  2220f, 2300f, 2450f) },
		{ "Room with 2 Portraits",                             tB(-3280f, -3270f,   50f,  200f) },
		{ "Room with 3 Portraits",                             tB(-6270f, -6260f,  534f,  716f) },
		{ "Room with 4 Portraits",                             tB(-2980f, -2970f, 1550f, 1700f) },
		{ "The Son of Man",                                    tB( -325f,  -174f, 7770f, 7780f) },
		{ "Enter Section 1",                                   tB( 1510f,  1520f,  192f,  308f) },
		{ "Enter Section 2",                                   tB(-2010f, -2000f,  192f,  308f) },
		{ "Enter Section 3",                                   tB( -308f,  -192f, 2500f, 2510f) }
	};

	settings.Add("sectionSplits", true, "Split on entering these gallery sections:");
	foreach (var p in vars.parts)
		if (p.Key.StartsWith("Enter"))
			settings.Add(p.Key, (p.Key.Contains("1") ? false : true), p.Key, "sectionSplits");

	settings.Add("paintingSplits", false, "Split after finishing these painting sections:");
	foreach (var p in vars.parts)
		if (!p.Key.StartsWith("Enter"))
			settings.Add(p.Key, false, p.Key, "paintingSplits");

	vars.completedSections = new HashSet<string>();
}

update
{
	vars.inPos = (Func<float, float, float, float, bool>) ((xMin, xMax, yMin, yMax) =>
		current.xPos >= xMin && current.xPos <= xMax && current.yPos >= yMin && current.yPos <= yMax ? true : false
	);

	vars.ending = vars.inPos(-1000, -880, -885, -875) && current.mov == null;
}

start
{
	if (old.xPos != current.xPos && old.xPos == -250.0 ||
	    old.yPos != current.yPos && old.yPos == -1900.0)
	{
		vars.completedSections.Clear();
		return true;
	}
}

split
{
	foreach (var p in vars.parts) {
		if (vars.inPos(p.Value.Item1, p.Value.Item2, p.Value.Item3, p.Value.Item4) && !vars.completedSections.Contains(p.Key))
		{
			vars.completedSections.Add(p.Key);
			return settings[p.Key];
		}
	}

	return vars.completedSections.Contains("The Son of Man") && vars.ending;
}

reset
{
	return vars.ending;
}