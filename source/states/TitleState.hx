package states;

import openfl.ui.MouseCursor;
import backend.WeekData;
import backend.Highscore;
import objects.Notification;
import sys.io.File;
import lime.app.Application;

import flixel.tweens.misc.ColorTween;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import tjson.TJSON as Json;

import flixel.effects.FlxFlicker;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import flixel.input.mouse.FlxMouse;

import substates.Prompt;

import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;
//import openfl.display.Internet;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

typedef TitleData =
{

	titlex:Float,
	titley:Float,
	//startx:Float,
	//starty:Float,
	//gfx:Float,
	//gfy:Float,
	backgroundSprite:String,
	bpm:Int
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public var ignoreWarnings:Bool = false;

	var textTitle:String;

	//var timetran:Int = ClientPrefs.data.timeTransaction;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var phantomSr:FlxSprite;

	var titleTxt:FlxText;
	var titleTxt2:FlxText;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];
	var curThonny:Array<String> = [];

	public static var editorresult:Bool;

	var wackyImage:FlxSprite;

	#if TITLE_SCREEN_EASTER_EGG
	var easterEggKeys:Array<String> = [
		'SHADOW', 'RIVER', 'SHUBS', 'BBPANZU'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	//var mustUpdate:Bool = false;
	var UpdateEC:Bool = false;

	//public static var fpsalpha:Float = 0;

	var TitleTxt:String;
	var coolText:Alphabet;

	var titleJSON:TitleData;
	var Bit:Bool;
	var Line:Int;
	var Line2:Int;

	public static var updateVersion:String = '';
	public static var updateVersionEC:String = '';
	public static var editorverification:String = 'disabled';
	public static var editorpermiss:String = '';
	public static var releasevideolink:String = '';

//	public var BitLogo:FlxTimer;

	public function onAlpha(Timer:FlxTimer):Void {
		FlxTween.tween(logoBl, {"scale.x": 1, "scale.y": 1}, 0.1, {
			onComplete: function (twn:FlxTween) {
				//FlxG.camera.zoom += 0.050;
				FlxTween.tween(logoBl, {"scale.x": 0.9, "scale.y": 0.9}, 0.1, {
					onComplete: function (twn:FlxTween) {
						//FlxG.camera.zoom -= 0.050;
					}
			});
		}});
		FlxTween.tween(titleTxt, {alpha: 0}, 2, {
			onComplete: function (twn:FlxTween) {
			//	trace('Title Alpha = 0');
				FlxTween.tween(titleTxt, {alpha: 1}, 2, {
					onComplete: function (twn:FlxTween) {
					//trace('Title Alpha = 1');
					}
				});
			}
		});
	}

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		ClientPrefs.loadPrefs();

		if (ClientPrefs.data.Welcome == true) {
			trace('cheking for release video');
			var htss = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/Link_video.txt");

			htss.onData = function (data:String)
				{
					releasevideolink = data.split("*")[0].trim();
				}

				htss.onError = function (error) {
					trace('error: $error');
					trace('Release Video. Cargara el Guardado en El juego');
					releasevideolink = "https://www.youtube.com/watch?v=M67O8wIE-2U";
				}

				htss.request();
		}

		if (ClientPrefs.data.Welcome == true) {
			trace('cheking for editors permiss');
			var htsp = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/Editor-Permiss.txt");

			htsp.onData = function (data:String)
				{
					editorpermiss = data.split("!")[0].trim();
					var curVerificator:String = editorverification.trim();
					trace('Editor Permiss Online is in = ' + editorpermiss);
					if (editorpermiss != curVerificator) {
						trace('enabled!!');
						editorresult = true;
					}
					if (editorpermiss == curVerificator) {
						trace('disabled!!');
						editorresult = false;
					}
				}

				htsp.onError = function (error) {
					trace('error: $error');
					trace('Editor Permiss. Desabilitado por seguridad');
					editorresult = false;
				}

				htsp.request();
		}

		if(ClientPrefs.data.Welcome == true) {
			trace('checking for update');
			var htps = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/GitVersion.txt");

			htps.onData = function (data:String)
			{
				updateVersionEC = data.split('\n')[0].trim();
				var curVersionEC:String = MainMenuState.endingcorruptionVersion.trim();
				trace('version online: ' + updateVersionEC + ', your version: ' + curVersionEC);
				if(updateVersionEC != curVersionEC) {
					trace('versions arebt matching!');
					UpdateEC = true;
				}
			}

			htps.onError = function (error) {
				trace('error: $error');
			}

			htps.request();
		}

		Highscore.load();

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = true;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(ClientPrefs.data.Welcome == false) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new PreloadingState());
		}

			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		#end
	}

	var logoBl:FlxSprite;
	//var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;
	var FadeTimer:FlxTimer;
	var errorTimer:FlxTimer;

	//function saveFileIntro(data:String):Void {
		//var FileTitle = sys.io.File("titleintrotext.txt");
	//}

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxG.sound.playMusic(Paths.music(ClientPrefs.data.musicstate), 1.2);
			}
		}

		//Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		var bg:FlxSprite;
		//bg.antialiasing = ClientPrefs.data.antialiasing; //Esto es inecesario ya que creo una imagen de Color Negro no veo que tengo que suavizar
		bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var tweens:ColorTween;

		logoBl = new FlxSprite().loadGraphic(Paths.image('corruption-logo'));
		//logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;

		//logoBl.animation.addByPrefix('bump', 'logo bumpin', ClientPrefs.data.SpritesFPS, true);
		//logoBl.animation.play('bump');
		logoBl.updateHitbox();
		logoBl.screenCenter();
		logoBl.alpha = 1;
		logoBl.scale.x = 0.9;
		logoBl.scale.y = 0.9;

		if (ClientPrefs.data.language == 'Spanish') {
			titleTxt = new FlxText(0, 650, FlxG.width, "Presiona 'Enter' para Continuar", 48);
		}
		if (ClientPrefs.data.language == 'Inglish') {
			titleTxt = new FlxText(0, 650, FlxG.width, "Press 'Enter' to Continue", 48);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			titleTxt = new FlxText(0, 650, FlxG.width, "Pressione 'Enter' para Continuar", 48);
		}
		titleTxt.setFormat(Paths.font("vnd.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.visible = true;
		titleTxt.screenCenter(X);


		if (ClientPrefs.data.language == 'Spanish') {
			titleTxt2 = new FlxText(0, 650, FlxG.width, "Iniciando", 48);
		}
		if (ClientPrefs.data.language == 'Inglish') {
			titleTxt2 = new FlxText(0, 650, FlxG.width, "Starting", 48);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			titleTxt2 = new FlxText(0, 650, FlxG.width, "Iniciando", 48);
		}
		titleTxt2.setFormat(Paths.font("vnd.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt2.visible = false;
		titleTxt2.screenCenter(X);

		if (ClientPrefs.data.graphics_internal == 'Low') {
			ClientPrefs.data.antialiasing = false;
			ClientPrefs.data.lowQuality = true;
			ClientPrefs.data.framerate = 60;
			ClientPrefs.data.recordoptimization = "enabled";
			ClientPrefs.data.shaders = false;
			ClientPrefs.data.SpritesFPS = 16;
			ClientPrefs.data.alphahud = true;
			ClientPrefs.data.ultraMode = false;
		}
		if (ClientPrefs.data.graphics_internal == 'Medium') {
			ClientPrefs.data.antialiasing = false;
			ClientPrefs.data.lowQuality = true;
			ClientPrefs.data.framerate = 75;
			ClientPrefs.data.recordoptimization = "Disabled";
			ClientPrefs.data.shaders = false;
			ClientPrefs.data.SpritesFPS = 24;
			ClientPrefs.data.ultraMode = false;
		}
		if (ClientPrefs.data.graphics_internal == 'High') {
			ClientPrefs.data.antialiasing = true;
			ClientPrefs.data.lowQuality = false;
			ClientPrefs.data.framerate = 85;
			ClientPrefs.data.recordoptimization = "Disabled";
			ClientPrefs.data.shaders = true;
			ClientPrefs.data.SpritesFPS = 24;
			ClientPrefs.data.ultraMode = false;
		}
		if (ClientPrefs.data.graphics_internal == 'Ultra') {
			ClientPrefs.data.antialiasing = true;
			ClientPrefs.data.lowQuality = false;
			ClientPrefs.data.framerate = 100;
			ClientPrefs.data.recordoptimization = "Disabled";
			ClientPrefs.data.shaders = true;
			ClientPrefs.data.SpritesFPS = 32;
			ClientPrefs.data.alphahud = true;
			ClientPrefs.data.ultraMode = true;
		}


		//tweens.tween(logoBl.alpha, 1, 2);
		//tweens.onUpdate = function(Float):Void {
		//	logoBl.alpha = 1;
		//}
		//FlxTween.tween(logoBl.alpha, tweens, 2);
		// logoBl.color = FlxColor.BLACK;

		/*if(ClientPrefs.data.shaders) swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;*/

		//add(gfDance);
		add(logoBl);
		add(titleTxt);
		add(titleTxt2);
		if(swagShader != null)
		{
			logoBl.shader = swagShader.shader;
		}

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.screenCenter();

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		phantomSr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('phantom_fear_logo'));
		add(phantomSr);
		phantomSr.visible = false;
		phantomSr.setGraphicSize(Std.int(phantomSr.width * 0.8));
		phantomSr.updateHitbox();
		phantomSr.screenCenter(X);
		phantomSr.antialiasing = ClientPrefs.data.antialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

			FadeTimer = new FlxTimer();
			FadeTimer.start(4, onAlpha, 0);

			errorTimer = new FlxTimer();
	}

	#if CRASH_HANDLER
	function onCrash(Timer:FlxTimer):Void
		{
			var errMsg:String = "";
			var path:String;
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var dateNow:String = Date.now().toString();
	
			dateNow = dateNow.replace(" ", "_");
			dateNow = dateNow.replace(":", "'");
	
			path = "./Tplugins/log/error.dll/" + "EndingGame_dll_" + dateNow + ".txt";
	
			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += "(error: [" + 'dll:GameCode.ERR' + "])\n";
					default:
						Sys.println(stackItem);
				}
			}
	
			errMsg += "State: TitleState\nError: ['dll:GameCode.ERR']\nLine: " + Line + " - " + Line2 + "\nDate: " + dateNow + "\n\nLook for a solution to this problem in: 'https://github.com/ThonnyDevYT/Plugins/wiki'\n\nPlease Report this error on Our YouTube Channel in Community Tab\n\n> Youtube Channel: 'ThonnyDev'";
	
			File.saveContent(path, errMsg + "\n");
	
			Sys.println(errMsg);
			Sys.println("Crash dump saved in " + Path.normalize(path));
		}
		#end

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getPreloadPath());
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	var noModsSine:Float = 0;

	override function update(elapsed:Float)
	{

		Line = FlxG.random.int(400, 480);
		Line2 = FlxG.random.int(510, 622);

		if (FlxG.keys.justPressed.Y) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0x4CFF0000, 1);
			if (ClientPrefs.data.language == 'Spanish') {
				openSubState(new Prompt('No se pudo Completar la Carga.\n\n[dll:GameCode.ERR]', 0, function() {
					errorTimer.start(0.1, onCrash, 1);
				},null, ignoreWarnings));
			add(new Notification(null, "Error", "Lastimosamente no se encuentra esta opcion habilitada en la V" + MainMenuState.endingcorruptionVersion, 1));
		}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				titleTxt.visible = false;
				titleTxt2.visible = true;

					FlxG.sound.play(Paths.sound('confirmMenu'), 0.2);

					transitioning = true;
					FlxTween.tween(titleTxt2, {alpha: 0}, ClientPrefs.data.timetrans + 3);
					FlxFlicker.flicker(titleTxt2, ClientPrefs.data.timetrans + 3, 0.2, true, true);
					FlxG.sound.music.fadeOut(ClientPrefs.data.timetrans, 0.1);
					FlxTween.tween(logoBl, {alpha: 0}, ClientPrefs.data.timetrans + 2, {
						onComplete: function (twn:FlxTween) {
	
							new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									if (UpdateEC) {
										MusicBeatState.switchState(new ActAvailableState());
									} else {
										MusicBeatState.switchState(new MainMenuState());
									}
									closedState = true;
								});
						}
					});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		ClientPrefs.loadPrefs();

		ClientPrefs.saveSettings();

		super.update(elapsed);
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {

			coolText = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
					credGroup.remove(textGroup.members[0], true);
					textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 1; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
				//	FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.playMusic(Paths.music(ClientPrefs.data.musicstate), 0);
					FlxG.sound.music.fadeIn(2, 0, 1.2);
				case 2:
					addMoreText('Ending Corruption by');
					//createCoolText(['Psych Engine by'], 40);
					//createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
				// credTextShit.visible = true;
				case 4:
					addMoreText('ThonnyDev');
					addMoreText('---');
					addMoreText('---');
					addMoreText('present');
					FlxG.sound.music.volume = 1.2;
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 5:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 6:
					addMoreText('Not associated with');
					//createCoolText(['Not associated', 'with'], -40);
					//createCoolText(['In association', 'with'], -40);
				case 8:
					addMoreText('Phantom Fear');
					ngSpr.visible = false;
					phantomSr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
					phantomSr.visible = false;
					FlxG.sound.music.volume = 1.2;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 10:
					addMoreText(curWacky[0]);
				// credTextShit.visible = true;
				case 12:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 13:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 14:
					addMoreText('Friday');
					FlxG.sound.music.volume = 1.2;
				// credTextShit.visible = true;
				case 15:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 16:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
				case 17:
					deleteCoolText();
				//credTextShit.visible = false;
				//credTextShit.text = "Friday";
				//credTextShit.screenCenter();
				case 18:
					addMoreText('Ending');
					FlxG.sound.music.volume = 1.2;
				case 19:
					addMoreText('Corruption');
				case 20:
					addMoreText('DEMO');
				case 21:
					addMoreText('V' + MainMenuState.endingcorruptionVersion);
				case 22:
				case 23:
					deleteCoolText();
				case 24:
					//createCoolText([curThonny[0]]);
					//addMoreText(curThonny[0]);
					addMoreText(curWacky[2]);
					FlxG.sound.music.volume = 1.2;
				case 25:
					//createCoolText(curThonny[1]);
					//addMoreText(curThonny[1]);
					addMoreText(curWacky[3]);
				case 26:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
				remove(ngSpr);
				remove(phantomSr);
				remove(credGroup);
				FlxG.camera.flash(FlxColor.BLACK, 2.5);
				if (ClientPrefs.data.recordoptimization == 'enabled') {
				add(new Notification(null, "Optimizacion de Grabacion..", "la Optimizacion de Grabacion esta Actualmente [" + ClientPrefs.data.recordoptimization + "]", 0));
				}
			skippedIntro = true;
		}
	}
}
