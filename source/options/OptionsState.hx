package options;

import states.MainMenuState;
import backend.StageData;
import flixel.util.FlxTimer;
import objects.Notification;
import objects.Notification;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		//'Note Colors',
		//'Controls',
		'Adjust',
		'Graphics',
		'Visuals UI',
		'Gameplay',
		'NewOptions',
		#if DEMO_MODE
		'Debug Config'
		#end
	];

	#if !DEMO_MODE
	public function onEffect(Timer:FlxTimer):Void {
		FlxTween.tween(bgCG, {alpha: 0}, 2, {
			onComplete: function (twn:FlxTween) {
				trace('Effect Part1 Complete');
				FlxTween.tween(bgCG, {alpha: 1}, 2, {
					onComplete: function (twn:FlxTween) {
					trace('effect Part2 Complete');
					}
				});
			}
		});
	}

	public function onEffectvineta(Timer:FlxTimer):Void {
		FlxTween.tween(vineta, {alpha: 0}, 3, {
			onComplete: function (twn:FlxTween) {
				trace('Effect Part1 Complete');
				FlxTween.tween(vineta, {alpha: 1}, 3, {
					onComplete: function (twn:FlxTween) {
					trace('effect Part2 Complete');
					}
				});
			}
		});
	}
	#end

	/*var opciones:Array<String> = ['Color de Nota', 'Controles', 'Ajustar', 'Graficos', 'visuales UI', 'GamePlays', 'Debug Config'];
	var opcionesport:Array<String> = ['Nota Cores', 'Controles', 'Ajustar', 'Gráficos', 'Visuals UI', 'Jogabilidade', 'Debug Config'];*/
	
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var TipText:FlxText;
	public static var TipText2:FlxText;
	public static var menuBG:FlxSprite;
	public var bgCG:FlxSprite;
	public static var onPlayState:Bool = false;
	public var vineta:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			/*case 'Controls':
				openSubState(new options.ControlsSubState());*/
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Debug Config':
				openSubState(new options.InitialSettings());
			case 'Adjust':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'NewOptions':
				if (ClientPrefs.data.language == 'Spanish') {
					add(new Notification(null, "Error!!", "Al parecer esta opcion esta Bloqueada por una condicion!!", 1));
				}
			if (ClientPrefs.data.language == 'Inglish') {
				openSubState(new options.NewOptions());
			}
			}
}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	var TimerEffect:FlxTimer;
	var TimerEffectvineta:FlxTimer;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().makeGraphic(0, 0, FlxColor.WHITE);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0x7b7d0000;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

		bgCG = new FlxSprite(0, 0).loadGraphic(Paths.image('OMMenu'));
		bgCG.antialiasing = ClientPrefs.data.antialiasing;
	//	bgCG.scrollFactor.set(0, yScroll);
		//bgCG.setGraphicSize(Std.int(bgCG.width * 1.175));
		bgCG.updateHitbox();
		bgCG.screenCenter();
		bgCG.color = 0x008920;
		bgCG.alpha = 0;
		add(bgCG);
		FlxTween.tween(bgCG, {alpha: 1}, 2);

		//Viñeta
		vineta = new FlxSprite(0, 0).loadGraphic(Paths.image('Vineta'));
		vineta.antialiasing = ClientPrefs.data.antialiasing;
		vineta.width = FlxG.width;
		vineta.height = FlxG.height;
	//	bgCG.scrollFactor.set(0, yScroll);
		//vineta.setGraphicSize(Std.int(bgCG.width * 1.175));
		vineta.updateHitbox();
		vineta.screenCenter();
		vineta.color = 0x000000;
		vineta.alpha = 0;
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(50, 300, options[i], true);
			//optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.screenCenter(X);
			//grpOptions.screenCenter(X);
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<]', true);
		add(selectorRight);

		//add(bgCG);
		if (ClientPrefs.data.graphics_internal != 'Low') {
		add(vineta);
		FlxTween.tween(vineta, {alpha: 1}, 2);
		}

		changeSelection();
		//ClientPrefs.saveSettings();

		if (ClientPrefs.data.language == 'Inglish') {
		TipText = new FlxText(12, FlxG.height - 44, 0, "Press 'X' to access Controls", 12);
		TipText.scrollFactor.set();
		TipText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		TipText.alpha = 1;
		add(TipText);
		}
		if (ClientPrefs.data.language == 'Spanish') {
			TipText = new FlxText(12, FlxG.height - 44, 0, "Presiona 'X' para acceder a los Controles", 12);
			TipText.scrollFactor.set();
			TipText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			TipText.alpha = 1;
			add(TipText);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			TipText = new FlxText(12, FlxG.height - 44, 0, "Pressione 'X' para acessar os controles", 12);
			TipText.scrollFactor.set();
			TipText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			TipText.alpha = 1;
			add(TipText);
		}

		if (ClientPrefs.data.language == 'Inglish') {
			TipText2 = new FlxText(12, FlxG.height - 24, 0, "Press 'T' to load Changes", 12);
			TipText2.scrollFactor.set();
			TipText2.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			TipText2.alpha = 1;
			add(TipText2);
			}
			if (ClientPrefs.data.language == 'Spanish') {
				TipText2 = new FlxText(12, FlxG.height - 24, 0, "Presiona 'T' para Cargar los Cambios", 12);
				TipText2.scrollFactor.set();
				TipText2.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				TipText2.alpha = 1;
				add(TipText2);
			}
			if (ClientPrefs.data.language == 'Portuguese') {
				TipText2 = new FlxText(12, FlxG.height - 24, 0, "Pressione 'T' para carregar as alterações", 12);
				TipText2.scrollFactor.set();
				TipText2.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				TipText2.alpha = 1;
				add(TipText2);
			}

		TimerEffect = new FlxTimer();
		TimerEffect.start(4, onEffect, 0);

		TimerEffectvineta = new FlxTimer();
		TimerEffectvineta.start(6, onEffectvineta, 0);

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.music.fadeOut(2, 0);
			//FlxTween.tween(grpOptions, {alpha: 0}, 5);
			//FlxTween.tween(option, {alpha: 0.5}, 5);
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.X) {
			openSubState(new options.ControlsSubState());
		}
		
		if (controls.ACCEPT){
			openSelectedSubstate(options[curSelected]);
		}
		if (FlxG.keys.justPressed.T) {
			ClientPrefs.loadPrefs();
			ClientPrefs.saveSettings();
			MusicBeatState.switchState(new options.OptionsState());
			trace('Se Forzo la Carga de los ajustes!!');
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.saveSettings();
		super.destroy();
	}
}