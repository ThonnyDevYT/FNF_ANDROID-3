package states;

import states.stages.IntroState;
import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import options.OptionsState;

class PreloadingState extends MusicBeatState
{
    public static var WarnText2:FlxText;
    public var bg:FlxSprite;
    var updateV:String;
    public static var WarnTextBack:FlxText;
    var Press:Bool = false;

    override function create() {
        super.create();
        
        ClientPrefs.loadPrefs();

        bg = new FlxSprite().loadGraphic(Paths.image('BGMenu/TitleMenu'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.alpha = 0;
        add(bg);
        FlxTween.tween(bg, {alpha: 1}, 6, {
            onComplete: function (twn:FlxTween) {
                //MusicBeatState.switchState(new TitleState());
                trace('Fondo cargado!! [bg - Alpha = 1]');
            }
        });

        WarnText2 = new FlxText(0, 0, FlxG.width,
            "Welcome to Ending Corruption\n\nBefore we start we need you to configure some things.\n\nPress 'Y' to set or 'N' to Skip",32);
        WarnText2.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
        WarnText2.screenCenter();
       // WarnText2.visible = true;
       WarnText2.alpha = 0;
        add(WarnText2);
        FlxTween.tween(WarnText2, {alpha: 1}, 4, {
            onComplete: function (twn:FlxTween) {
                //MusicBeatState.switchState(new TitleState());
                trace('Fondo cargado!!' + '[WarnText2 - Alpha = 1]');
            }
        });

        WarnTextBack = new FlxText(0, 0, FlxG.width,"Press [N] to Start Game!\n\nPreferences are loaded at startup",32);
        WarnTextBack.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
        WarnTextBack.screenCenter();
        WarnTextBack.alpha = 0;
       // WarnTextBack.visible = true;
       // add(WarnTextBack);
    }

    override function update(elapsed:Float)
    {

      /*  if (FlxG.keys.justPressed.Y) {
            FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
        }*/

            if (FlxG.keys.justPressed.Y) {
                ClientPrefs.data.Welcome = true;
                trace('Welcome = true');
                  ClientPrefs.saveSettings();
                  ClientPrefs.loadPrefs();
                  Press = true;
                  FlxG.sound.play(Paths.sound('confirmMenu'));
                  //FlxFlicker.flicker(WarnText2, 1, 0.3, false, true, function(flk:FlxFlicker) {
                        FlxTween.tween(WarnText2, {alpha: 0}, 4, {
                            onComplete: function (twn:FlxTween) {
                                //MusicBeatState.switchState(new TitleState());
                                openSubState(new options.InitialSettings());
                                //trace('Fondo cargado!!');
                                add(WarnTextBack);
                                       FlxTween.tween(WarnTextBack, {alpha: 1}, 6, {
                                onComplete: function (twn:FlxTween) {
                                //MusicBeatState.switchState(new TitleState());
                                trace('Fondo cargado!!');
                            }
                        });
                            }
                        });
                 // });

        }
        
            if (FlxG.keys.justPressed.N) {
            ClientPrefs.data.Welcome = true;
            ClientPrefs.saveSettings();
            ClientPrefs.loadPrefs();
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxTween.tween(WarnTextBack, {alpha: 0}, 5, {
                onComplete: function (twn:FlxTween) {
                    trace('Texto Desaparecido [WarnText2]');
                }
            });

            if (WarnText2.alpha == 1) {
            FlxTween.tween(WarnText2, {alpha: 0}, 5, {
                onComplete: function (twn:FlxTween) {
                    trace('No quiso configurar nada');
                }
            });
        }

            FlxTween.tween(bg, {alpha: 0}, 5, {
                onComplete: function (twn:FlxTween) {
                    ClientPrefs.loadPrefs();
                    trace('Fondo Desaparecido!!');

                   MusicBeatState.switchState(new TitleState());
                }
            });
        }
        super.update(elapsed);
    }
}