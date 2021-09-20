import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;

// different than FlxSoundGroup cuz this can control all the sounds time and shit
// when needed
class VoicesGroup extends FlxTypedGroup<FlxSound>
{
	public var time(default, set):Float = 0;

	public var volume(default, set):Float = 1;

	// make it a group that you add to?
	public function new(song:String, ?files:Array<String>, ?needsVoices:Bool = true)
	{
		super();

		if (!needsVoices)
		{
			// simply adds an empty sound? fills it in moreso for easier backwards compatibility
			add(new FlxSound());
			// FlxG.sound.list.add(snd);

			return;
		}

		if (files == null)
			files = [""]; // loads with no file name assumption, to load "Voices.ogg" or whatev normally

		for (sndFile in files)
		{
			var snd:FlxSound = new FlxSound().loadEmbedded(Paths.voices(song, '$sndFile'));
			FlxG.sound.list.add(snd); // adds it to sound group for proper volumes
			add(snd); // adds it to main group for other shit
		}
	}

	// prob a better / cleaner way to do all these forEach stuff?
	public function pause()
	{
		forEachAlive(function(snd)
		{
			snd.pause();
		});
	}

	public function play()
	{
		forEachAlive(function(snd)
		{
			snd.play();
		});
	}

	public function stop()
	{
		forEachAlive(function(snd)
		{
			snd.stop();
		});
	}

	function set_time(time:Float):Float
	{
		forEachAlive(function(snd)
		{
			// account for different offsets per sound?
			snd.time = time;
		});

		return time;
	}

	// in PlayState, adjust the code so that it only mutes the player1 vocal tracks?
	function set_volume(volume:Float):Float
	{
		forEachAlive(function(snd)
		{
			snd.volume = volume;
		});

		return volume;
	}
}