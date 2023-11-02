package states;

import states.editors.UpdatingState;
import flixel.FlxState;
import flixel.math.FlxPoint;
import openfl.events.MouseEvent;
import flixel.input.mouse.FlxMouseButton;
import openfl.ui.MouseCursor;
import flixel.ui.FlxSpriteButton;
import options.Option;
import flixel.ui.FlxButton;
import backend.WeekData;
import backend.Achievements;
import openfl.utils.Timer;
import flixel.util.FlxTimer;

import substates.Prompt;
import flixel.FlxState;
import objects.Notification;

import flixel.input.FlxPointer;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.input.mouse.FlxMouseEvent;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;

import objects.AchievementPopup;
import objects.Notification;
import states.editors.MasterEditorMenu;
import options.OptionsState;
//import openfl.display.Internet;

class MainMenuState extends MusicBeatState
{
	//public static var psychEngineVersion:String = '0.7.1h'; //This is also used for Discord RPC
	public static var endingcorruptionVersion:String = '1.1'; //Update!! to Release
	public static var engineVersion:String = '0.9'; //update to Release
	var tipkey:FlxText;
	var tipvideo:FlxText;
	public static var curSelected:Int = 0;

	//public var camHUD:FlxCamera;
	//var controllerPointer:FlxSprite;

	public var bg:FlxSprite;
	public var bgCG:FlxSprite;
	public var TimerEffect:FlxTimer;
	public var alphaeffect:FlxTimer;
	public var versionEngine:FlxText;
	public var versionShit:FlxText;

	var Nit:Bool;

	//var ajustes_Button:FlxButton;

	//var optionpos:FlxPoint;

	//var mousepos:FlxPoint = new FlxPoint();
	//var _lastControllerMode:Bool = false;

	var settingsSprite:FlxSprite;

	var internet:String = '';
	public var ignoreWarnings = false;

	public var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'statistics',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'links'
		//#if !switch 'donate', #end
		//'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var bg_vineta:FlxSprite;

	public function onEffect(Timer:FlxTimer):Void {
		FlxTween.tween(bgCG, {alpha: 0}, ClientPrefs.data.timetrans + 1, {
			onComplete: function (twn:FlxTween) {
				trace('Effect Part1 Complete');
				FlxTween.tween(bgCG, {alpha: 1}, ClientPrefs.data.timetrans + 1, {
					onComplete: function (twn:FlxTween) {
					trace('effect Part2 Complete');
					}
				});
			}
		});
	}

	function changeItem(huh:Int = 0)
		{
			curSelected += huh;
	
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
	
			menuItems.forEach(function(spr:FlxSprite)
			{
				//spr.animation.play('idle');
				//spr.alpha = 0.3;
				if (spr.ID != curSelected) {
				FlxTween.tween(spr, {alpha: 0.3}, 0.3);
				}
				//spr.visible = false;
				spr.updateHitbox();
				//FlxTween.tween(spr.ID != curSelected, {x: -30}, 1);
	
				if (spr.ID == curSelected)
				{
					//spr.animation.play('selected');
					//spr.visible = true;
					//FlxTween.tween(, {x: 0}, 0.7);
					FlxTween.tween(spr, {alpha: 1}, 0.4);
					//spr.alpha = 1;
					var add:Float = 0;
					if(menuItems.length > 4) {
						add = menuItems.length * 8;
					}
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
					spr.centerOffsets();
				}
			});
		}

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.sound.music.fadeIn(3, 0.1, 0.8);

		ClientPrefs.saveSettings();

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		bgCG = new FlxSprite(-80).loadGraphic(Paths.image('OMMenu'));
		bgCG.antialiasing = ClientPrefs.data.antialiasing;
		bgCG.scrollFactor.set(0, yScroll);
		bgCG.setGraphicSize(Std.int(bgCG.width * 1.175));
		bgCG.updateHitbox();
		bgCG.screenCenter();
		//bgCG.color = 0x000000;
		bgCG.alpha = 0;
		add(bgCG);
		FlxTween.tween(bgCG, {alpha: 1}, ClientPrefs.data.timetrans);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			//var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			//menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			//menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", ClientPrefs.data.SpritesFPS);
			//menuItem.animation.addByPrefix('selected', optionShit[i] + " white", ClientPrefs.data.SpritesFPS);
			//menuItem.animation.play('idle');
			var menuItem:FlxSprite = new FlxSprite(-500, (i * 115) + offset).loadGraphic(Paths.image('mainmenu/menu_' + optionShit[i]));
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItem.alpha = 0;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			FlxTween.tween(menuItem, {x: 0}, ClientPrefs.data.timetrans);
			FlxTween.tween(menuItem, {alpha: 0.5}, 0.2);
		}	

		FlxG.camera.follow(camFollow, null, 0);

		if (ClientPrefs.data.language == 'Inglish') {
		tipvideo = new FlxText(-100, FlxG.height - 84, 0, "Press 'O' To go to the last Video", 12);
		}
		if (ClientPrefs.data.language == 'Spanish') {
			tipvideo = new FlxText(-100, FlxG.height - 84, 0, "Presiona 'O' Para ir al ultimo Video", 12);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			tipvideo = new FlxText(-100, FlxG.height - 84, 0, "Pressione 'O' para ir para o último vídeo", 12);
		}
		tipvideo.scrollFactor.set();
		tipvideo.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipvideo.alpha = 0;
		add(tipvideo);
		if (ClientPrefs.data.language == 'Inglish') {
			tipkey = new FlxText(-100, FlxG.height - 64, 0, "Press 'P' to Access Options", 12);
		}
		if (ClientPrefs.data.language == 'Spanish') {
			tipkey = new FlxText(-100, FlxG.height - 64, 0, "Presiona 'P' para Acceder a Opciones", 12);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			tipkey = new FlxText(-100, FlxG.height - 64, 0, "Pressione 'P' para acessar as opções", 12);
		}
		tipkey.scrollFactor.set();
		tipkey.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipkey.alpha = 0;
		add(tipkey);
		versionEngine = new FlxText(-100, FlxG.height - 44, 0, "Engine V" + engineVersion, 12);
		versionEngine.scrollFactor.set();
		versionEngine.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionEngine.alpha = 0;
		add(versionEngine);
		versionShit = new FlxText(-100, FlxG.height - 24, 0, "Ending Corruption V" + endingcorruptionVersion + '', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.alpha = 0;
		add(versionShit);

		FlxTween.tween(tipvideo, {alpha: 1}, 0.5);
		FlxTween.tween(tipvideo, {x: 12}, 0.3);
		FlxTween.tween(tipkey, {alpha: 1}, 0.5);
		FlxTween.tween(tipkey, {x: 12}, 0.3);
		FlxTween.tween(versionEngine, {alpha: 1}, 0.5);
		FlxTween.tween(versionEngine, {x: 12}, 0.6);
		FlxTween.tween(versionShit, {alpha: 1}, 0.5);
		FlxTween.tween(versionShit, {x: 12}, 0.8, {
			onComplete: function(twn:FlxTween) {
				Nit = true;
			}
		});

		changeItem();

	TimerEffect = new FlxTimer();
	TimerEffect.start(ClientPrefs.data.timetrans + 3, onEffect, 0);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}
		
		if (Nit == true) {
			if (FlxG.keys.justPressed.O) {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				CoolUtil.browserLoad(TitleState.releasevideolink);
			}
		}

		if (Nit == true) {
			if (FlxG.keys.justPressed.P) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.sound.music.fadeOut(3, 0);
				FlxTween.tween(bgCG, {alpha: 0}, ClientPrefs.data.timetrans);
				//FlxTween.tween(versionEngine, {alpha: 0}, ClientPrefs.data.timetrans);
				FlxTween.tween(versionEngine, {x: -500}, 1);
				FlxTween.tween(tipvideo, {x: -500}, 1);
				FlxTween.tween(tipkey, {x: -500}, 1);
				FlxTween.tween(versionShit, {x: -500}, 1);
				//FlxTween.tween(tipkey, {alpha: 0}, ClientPrefs.data.timetrans);
				menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {x: -500}, 0.5);
							FlxTween.tween(spr, {x: -500}, 0.5, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(spr, {x: -500}, 0.5);
									Nit = false;
								}
							});
						}
					});
				FlxTween.tween(versionShit, {alpha: 0}, ClientPrefs.data.timetrans + 0.5,{
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new options.OptionsState());
					}});
			}
		}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

		if (Nit == true) {
			if (FlxG.keys.justPressed.A) {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				selectedSomethin = true;
				FlxG.sound.music.fadeOut(3, 0);
				FlxTween.tween(bgCG, {alpha: 0}, ClientPrefs.data.timetrans);
				FlxTween.tween(versionEngine, {alpha: 0}, ClientPrefs.data.timetrans);
				FlxTween.tween(tipvideo, {alpha: 0}, ClientPrefs.data.timetrans);
				FlxTween.tween(tipkey, {alpha: 0}, ClientPrefs.data.timetrans);
				FlxTween.tween(versionShit, {alpha: 0}, ClientPrefs.data.timetrans + 0.5,{
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new states.EstadisticsMenuState());
					}});
			}
		}
			

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0x4CFF0000, 1);
				if (ClientPrefs.data.language == 'Spanish') {
					add(new Notification(camAchievement, "Accion No Permitida..", "No te podemos dejar Regresar por el Bien de la optimizacion del Juego. Gracias", 1));
				}
				if (ClientPrefs.data.language == 'Inglish') {
					add(new Notification(camAchievement, "Action Not Allowed..", "We cannot let you return for the sake of game optimization. Thank you", 1));
				}
				if (ClientPrefs.data.language == 'Portuguese') {
					add(new Notification(camAchievement, "Atualmente não disponível!", "Não podemos permitir que você retorne para otimizar o jogo. Obrigado", 1));
				}
			}

		if (Nit == true) {
			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://gamebanana.com/wips/79622');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.sound.music.fadeOut(3, 0.3);
					//FlxTween.tween(menuItems, {alpha: 0}, 1);
					FlxTween.tween(bgCG, {alpha: 0}, 0.5);
					FlxTween.tween(versionEngine, {alpha: 0}, 0.5);
					FlxTween.tween(versionShit, {alpha: 0}, 0.5);
					FlxTween.tween(tipkey, {alpha: 0}, 0.5);
					FlxTween.tween(tipvideo, {alpha: 0}, 0.5);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {x: -500}, 0.5);
							FlxTween.tween(spr, {x: -500}, 0.5, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(spr, {x: -500}, 0.5);
									Nit = false;
								}
							});
						}
						else
						{
							new FlxTimer().start(2, function(tmr:FlxTimer) {
								FlxTween.tween(spr, {x: -500}, 0.7,{
									onComplete: function(twn:FlxTween)
									{
										var daChoice:String = optionShit[curSelected];
		
										switch (daChoice)
										{
											case 'story_mode':
												MusicBeatState.switchState(new StoryMenuState());
											case 'freeplay':
												MusicBeatState.switchState(new FreeplayState());
											case 'statistics':
												MusicBeatState.switchState(new EstadisticsMenuState());
											/*#if MODS_ALLOWED
											case 'mods':
												MusicBeatState.switchState(new ModsMenuState());
											#end
											case 'awards':
												MusicBeatState.switchState(new AchievementsMenuState());*/
											case 'links':
												MusicBeatState.switchState(new CreditsState());
										}
									}});
							});
						}
					});
				}
			}
		}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				if (TitleState.editorresult == true) {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					MusicBeatState.switchState(new MasterEditorMenu());
				}
				if (TitleState.editorresult == false) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0x4CFF0000, 1);
				if (ClientPrefs.data.language == 'Spanish') {
					openSubState(new Prompt('Esta acción no esta permitida actualmente por el Admin.\n\nPide Permisos', 0, function() {
					},
					null, ignoreWarnings));
				add(new Notification(camAchievement, "No Disponible Actualmente!", "Lastimosamente no se encuentra esta opcion habilitada en la V" + endingcorruptionVersion, 1));
			}
			if (ClientPrefs.data.language == 'Inglish') {
				openSubState(new Prompt('This action is not currently allowed by the Admin.\n\nRequest Permissions', 0, function() {
				},
				null, ignoreWarnings));
				add(new Notification(camAchievement, "Not Currently Available!", "Unfortunately this option is not enabled in the V" + endingcorruptionVersion, 1));
			}
			if (ClientPrefs.data.language == 'Portuguese') {
				openSubState(new Prompt('Esta ação não é permitida atualmente pelo administrador.\n\nSolicitar permissões', 0, function() {
				},
				null, ignoreWarnings));
				add(new Notification(camAchievement, "Atualmente não disponível!", "Infelizmente esta opção não está habilitada no V" + endingcorruptionVersion, 1));
			}
			//add(new Notification(camAchievement, "No Disponible Actualmente!", "Lastimosamente no se encuentra esta opcion habilitada en la V" + endingcorruptionVersion, false));
			}
		}
			#end
		}
		super.update(elapsed);
	}
}