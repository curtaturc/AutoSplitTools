state ("Muck") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Muck ASL] " + output));
}

init
{
	string[] classes = { "LoadingScreen", "BossUI" };
	vars.TokenSource = new CancellationTokenSource();
	vars.ScanThread = new Thread (() =>
	{
		vars.Dbg("Starting scan thread.");

		SignatureScanner MonoScanner = null, UnityScanner = null;
		IntPtr loaded_images = IntPtr.Zero, Asm_Cs_image = IntPtr.Zero, SceneManager = IntPtr.Zero;
		var mono_image_loaded = new SigScanTarget(3, "48 8B 0D ???????? 48 8B D7 E8 ???????? 48 8B D8 83 3D ???????? 00");
		var SceneManagerSig = new SigScanTarget(3, "48 8B 0D ???????? 48 8D 55 ?? 89 45 ?? 0F");

		foreach (var sig in new[] { mono_image_loaded, SceneManagerSig })
			sig.OnFound = (p, s, ptr) => ptr + 0x4 + p.ReadValue<int>(ptr);

		while (!vars.TokenSource.Token.IsCancellationRequested)
		{
			if (MonoScanner == null || UnityScanner == null)
			{
				var Mono = modules.FirstOrDefault(m => m.ModuleName.StartsWith("mono"));
				var UnityPlayer = modules.FirstOrDefault(m => m.ModuleName == "UnityPlayer.dll");
				if (Mono == null || UnityPlayer == null)
				{
					vars.Dbg("One or more modules were not found. Retrying.");
					Thread.Sleep(2000);
					continue;
				}

				MonoScanner = new SignatureScanner(game, Mono.BaseAddress, Mono.ModuleMemorySize);
				UnityScanner = new SignatureScanner(game, UnityPlayer.BaseAddress, UnityPlayer.ModuleMemorySize);
			}

			loaded_images = MonoScanner.Scan(mono_image_loaded);
			SceneManager = UnityScanner.Scan(SceneManagerSig);

			if (new[] { loaded_images, SceneManager }.Any(a => a == IntPtr.Zero))
			{
				vars.Dbg("One or more signatures could not be resolved. Retrying.");
				Thread.Sleep(2000);
				continue;
			}

			int loaded_images_size = new DeepPointer(loaded_images, 0x18).Deref<int>(game);
			var image = new DeepPointer(loaded_images, 0x10, 0x8 * (int)(0xFA381AED % loaded_images_size)).Deref<IntPtr>(game);
			for (; image != IntPtr.Zero; image = game.ReadPointer(image + 0x10))
			{
				string image_name = new DeepPointer(image, 0x0).DerefString(game, 32, "");
				if (image_name != "Assembly-CSharp") continue;

				Asm_Cs_image = game.ReadPointer(image + 0x8);
				break;
			}

			if (Asm_Cs_image == IntPtr.Zero)
			{
				vars.Dbg("Assembly-CSharp was not found in the loaded images. Trying again.");
				Thread.Sleep(2000);
				continue;
			}

			vars.Mono = new Dictionary<string, IntPtr>();
			var vtable_size = game.ReadValue<int>(Asm_Cs_image + 0x4D8);
			var vtable = game.ReadPointer(Asm_Cs_image + 0x4E0);

			for (int i = 0; i < vtable_size; ++i)
			{
				for (var klass = game.ReadPointer(vtable + 0x8 * i); klass != IntPtr.Zero; klass = game.ReadPointer(klass + 0x108))
				{
					string class_name = new DeepPointer(klass + 0x48, 0x0).DerefString(game, 64);
					if (!classes.Contains(class_name)) continue;

					vars.Dbg("Found class '" + class_name + "'.");
					vars.Mono[class_name] = new DeepPointer(klass + 0xD0, 0x8, 0x60).Deref<IntPtr>(game);
				}

				if (vars.Mono.Count == classes.Length)
				{
					vars.Dbg("Found all classes successfully.");
					break;
				}
			}

			vars.SceneIndex = new MemoryWatcher<int>(new DeepPointer(SceneManager, 0x48, 0x98));

			break;
		}

		vars.Dbg("Exiting scan thread.");
	});

	vars.ScanThread.Start();

	vars.F = (Func<dynamic, int[], float>) ((ptr, offsets) => new DeepPointer((IntPtr)ptr, offsets).Deref<float>(game));
}

update
{
	if (vars.ScanThread.IsAlive) return false;

	current.Fade = vars.F(vars.Mono["LoadingScreen"], new[] { 0x38, 0x10, 0x40 });
	current.BossHP = vars.F(vars.Mono["BossUI"], new[] { 0x30, 0x38, 0x50 });
	vars.SceneIndex.Update(game);
}

start
{
	return old.Fade == 1f && 0f < current.Fade && current.Fade < 1f;
}

split
{
	return old.BossHP > 0 && current.BossHP <= 0;
}

reset
{
	return vars.SceneIndex.Old == 1 && vars.SceneIndex.Current == 0;
}

exit
{
	vars.TokenSource.Cancel();
}

shutdown
{
	vars.TokenSource.Cancel();
}