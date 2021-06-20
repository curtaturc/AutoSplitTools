state("") {}

startup
{
	string path = @"Components\DownloadTest.asl";
	string template = @"https://pastebin.com/raw/FkrtRyj1";
	var content = File.ReadAllLines(path).ToList();
	content[content.IndexOf("	// mono_finder")] = new System.Net.WebClient().DownloadString(template);
	for (int i = 0; i < 7; ++i) content.RemoveAt(4);
	File.WriteAllLines(path, content);

	vars.Dbg = (Action<dynamic>) ((output) => print("[Mono ASL] " + output));
}

init
{
	var mono_image_loaded = new SigScanTarget(2, "FF 35 ???????? E8 ???????? 83 C4 08 8B F0 83 3D ???????? 00");
	mono_image_loaded.OnFound = (p, s, ptr) => p.ReadPointer(ptr);

	int[] OFFSETS_TABLE = { /*size*/ 0xC, /*items*/ 0x8, /*next*/ 0x8 };
	int[] OFFSETS_CACHE = { /*cache*/ 0x358, /*size*/ 0x8, /*items*/ 0x10 };
	int[] OFFSETS_KLASS = { /*parent*/ 0x20, /*name*/ 0x2C, /*space*/ 0x30, /*static*/ 0x38, /*fields*/ 0x60, /*runtime*/ 0x84, /*next*/ 0xA8 };
	int[] OFFSETS_FIELD = { /*next*/ 0x10, /*name*/ 0x4, /*offset*/ 0xC };

	// mono_finder
}

update
{
	if (vars.MonoFinder.IsAlive) return false;
}

exit
{
	vars.TokenSource.Cancel();
}

shutdown
{
	vars.TokenSource.Cancel();
}