package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;

import objects.MenuItem;
import objects.MenuCharacter;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	public static var tracksSprite:FlxSprite;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	public var bgYellow:FlxSprite;
	public var bg_Warning:FlxSprite;
	public var warningText:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var gogo:FlxTimer;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var DiffDement:Bool;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	public function onWarning(Timer:FlxTimer):Void {
		if (DiffDement == true) {
			FlxTween.tween(warningText, {alpha: 1}, 0.4, {
				onComplete: function (twn:FlxTween) {
					FlxTween.tween(warningText, {alpha: 0}, 0.4);
				}
			});
			FlxTween.tween(bg_Warning, {alpha: 1}, 0.4, {
				onComplete: function(twn:FlxTween) {
					FlxTween.tween(bg_Warning, {alpha: 0}, 0.4);
				}
			});
		}
	}

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.sound.music.fadeIn(2, 0, 1.2);

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE:\n49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		bg_Warning = new FlxSprite().loadGraphic(Paths.image('Peligro_BG'));
		bg_Warning.antialiasing = ClientPrefs.data.antialiasing;
		bg_Warning.screenCenter();
		bg_Warning.width = FlxG.width;
		bg_Warning.height = FlxG.height;
		bg_Warning.alpha = 0;

		if (ClientPrefs.data.language == 'Spanish') {
		warningText = new FlxText(0, FlxG.height - 50, 0, "DIFICIL!!", 10);
		}
		if (ClientPrefs.data.language == 'Inglish') {
		warningText = new FlxText(0, FlxG.height - 50, 0, "DIFFICULT!!", 10);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
		warningText = new FlxText(0, FlxG.height - 50, 0, "DIFÍCIL!!", 10);
		}
		warningText.setFormat("vnd.ttf", 32, FlxColor.RED, CENTER, OUTLINE_FAST, FlxColor.BLACK);
		warningText.screenCenter(X);
		warningText.antialiasing = ClientPrefs.data.antialiasing;
		warningText.alpha = 0;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bgYellow = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgYellow.alpha = 0;
		bgSprite = new FlxSprite(0, 56);
		bgSprite.alpha = 0;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		//grpWeekText.alpha = 0;
		add(grpWeekText);
		//FlxTween.tween(grpWeekText, {alpha: 1}, 5);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(30, 0, WeekData.weeksList[i]);
				weekThing.y += ((weekThing.height + 20) * num);
				//weekThing.y = FlxG.height;
				weekThing.targetY = num;
				grpWeekText.add(weekThing);

				//weekThing.screenCenter(X);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, 0);
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.alpha = 0;
		difficultySelectors.add(leftArrow);
		FlxTween.tween(leftArrow, {alpha: 1}, 5);

		Difficulty.resetList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		sprDifficulty.alpha = 0;
		difficultySelectors.add(sprDifficulty);
		FlxTween.tween(sprDifficulty, {alpha: 1}, 5);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.alpha = 0;
		difficultySelectors.add(rightArrow);
		FlxTween.tween(rightArrow, {alpha: 1}, 5);

		//add(bgYellow);
		//FlxTween.tween(bgYellow, {alpha: 1}, 5);
		//add(bgSprite);
		//FlxTween.tween(bgSprite, {alpha: 1}, 5);
		/*add(grpWeekCharacters);
		FlxTween.tween(grpWeekCharacters, {alpha: 1}, 5);*/

		if (ClientPrefs.data.language == 'Inglish') {
		tracksSprite = new FlxSprite(850, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Musics_Inglish'));
		tracksSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(tracksSprite);
		FlxTween.tween(tracksSprite, {alpha: 1}, 5);
		}
		if (ClientPrefs.data.language == 'Spanish' ) {
			tracksSprite = new FlxSprite(850, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Musics_Spanish-Portugues'));
			tracksSprite.antialiasing = ClientPrefs.data.antialiasing;
			add(tracksSprite);
			FlxTween.tween(tracksSprite, {alpha: 1}, 5);
		}
		if (ClientPrefs.data.language == 'Mandarin') {
			tracksSprite = new FlxSprite(850, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Musics_Mandarin'));
			tracksSprite.antialiasing = ClientPrefs.data.antialiasing;
			add(tracksSprite);
			FlxTween.tween(tracksSprite, {alpha: 1}, 5);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			tracksSprite = new FlxSprite(850, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Musics_Spanish-Portugues'));
			tracksSprite.antialiasing = ClientPrefs.data.antialiasing;
			add(tracksSprite);
			FlxTween.tween(tracksSprite, {alpha: 1}, 5);
		}

		txtTracklist = new FlxText(850, tracksSprite.y + 50, 0, "", 32);
		//txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xffffffff;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(warningText);
		add(bg_Warning);

		changeWeek();
		changeDifficulty();

		gogo = new FlxTimer();
		gogo.start(0.8, onWarning, 0);

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		if (ClientPrefs.data.language == 'Spanish') {
		scoreText.text = "Puntuacion de Semana:\n" + lerpScore;
		}
		if (ClientPrefs.data.language == 'Inglish') {
		scoreText.text = "WEEK SCORE\n" + lerpScore;
		}
		if (ClientPrefs.data.language == 'Portuguese') {
		scoreText.text = "pontuação da semana\n" + lerpScore;
		}
		if (ClientPrefs.data.language == 'Mandarin') {
		scoreText.text = "周成绩\n" + lerpScore;
		}

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				//FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				//FlxG.sound.playMusic(Paths.inst(''), 0.7);
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (upP || downP)
				changeDifficulty();

			if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				FlxTween.tween(tracksSprite, {alpha: 0}, 0.5);
				FlxTween.tween(bgSprite, {alpha: 0}, 0.5);
				FlxTween.tween(bgYellow, {alpha: 0}, 0.5);
				FlxTween.tween(rightArrow, {alpha: 0}, 0.5);
				FlxTween.tween(leftArrow, {alpha: 0}, 0.5);
				FlxTween.tween(sprDifficulty, {alpha: 0}, 0.5, {
					onComplete: function (twn:FlxTween) {
						selectWeek();
					}
				});
				FlxG.sound.music.fadeOut(5, 0);
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.sound.music.fadeOut(2, 0);
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
			lock.visible = (lock.y > FlxG.height / 2);
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;
	
				var diffic = Difficulty.getFilePath(curDifficulty);
				if(diffic == null) diffic = '';
	
				PlayState.storyDifficulty = curDifficulty;
	
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}
			
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.sound.music.fadeOut(2, 0);

				grpWeekText.members[curWeek].startFlashing();

				for (char in grpWeekCharacters.members)
				{
					if (char.character != '' && char.hasConfirmAnimation)
					{
						char.animation.play('confirm');
					}
				}
				stopspamming = true;
			}

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
			
			#if MODS_ALLOWED
			DiscordClient.loadModRPC();
			#end
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Mods.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));
		if (diff == 'dementia') {
			DiffDement = true;
		}
		if (diff != 'dementia') {
			DiffDement = false;
		}

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 100;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
		txtWeekTitle.y = FlxG.height - (txtWeekTitle.height + 10);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		PlayState.storyWeek = curWeek;

		Difficulty.loadFromWeek();
		difficultySelectors.visible = unlocked;

		if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += '>' + stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		//txtTracklist.screenCenter(Y);
		txtTracklist.x -= FlxG.width * 0.00;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
