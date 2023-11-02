package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxStringUtil;

import states.StoryMenuState;
import states.FreeplayState;
import flixel.FlxObject;
import options.OptionsState;

import objects.Notification;

class PauseModeSubState extends MusicBeatSubstate
{
    var grpMenuShit:FlxTypedGroup<FlxText>;
    var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
    var diffChoices = [];
    var curSelected:Int = 0;

    var ready:Bool = false;

    var overlay:FlxSprite;

    var skipTimeText:FlxText;
    var skipTimeTracker:Alphabet;
    var curTime:Float = Math.max(0, Conductor.songPosition);

    var pauseMusic:FlxSound;

    var item:FlxText;

    public static var songName:String = '';

    var Time:FlxTimer;

    public function onOverlay(Timer:FlxTimer):Void {
        FlxTween.tween(overlay, {alpha: 0.5}, 1, {
            onComplete: function (twn:FlxTween) {
                FlxTween.tween(overlay, {alpha: 0}, 1);
            }
        });
        }

    public function new(x:Float, y:Float)
    {
        super();
        
        for (i in 0...Difficulty.list.length) {
            var diff:String = Difficulty.getString(i);
            diffChoices.push(diff);
        }
            diffChoices.push('BACK');

            pauseMusic = new FlxSound();
            if (songName != null) {
                pauseMusic.loadEmbedded(Paths.music(songName), true, true);
            } else {
                pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
            }
            pauseMusic.volume = 0;
            pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

            FlxG.sound.list.add(pauseMusic);

            var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            bg.alpha = 0;
            bg.scrollFactor.set();
            add(bg);

            var box:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('pausemenu/BoxPause'));
            box.scrollFactor.set();
            box.antialiasing = ClientPrefs.data.antialiasing;
            box.width -= 30;
            box.height -= 30;
            box.alpha = 0;
            box.screenCenter();
            box.updateHitbox();
            add(box);

            overlay = new FlxSprite(0, 0).loadGraphic(Paths.image('pausemenu/Overlay_Box'));
            overlay.scrollFactor.set();
            overlay.antialiasing = ClientPrefs.data.antialiasing;
            overlay.width -= 30;
            overlay.height -= 30;
            overlay.alpha = 0;
            overlay.screenCenter();
            overlay.updateHitbox();
            add(overlay);

            var levelInfo:FlxText = new FlxText(20,15, 0, 'Notas Presionas: ' + PlayState.hitnotesong + ' | ' + PlayState.SONG.song + ' | ' + Difficulty.getString().toUpperCase(), 32);
            levelInfo.scrollFactor.set();
            levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
            levelInfo.updateHitbox();
            add(levelInfo);

            /*var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, Difficulty.getString().toUpperCase(), 32);
            levelDifficulty.scrollFactor.set();
            levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
            levelDifficulty.updateHitbox();
            add(levelDifficulty);

            var notes:FlxText = new FlxText(20,15 + 32 + 32, 0, 'Notas Presionadas:\n' + PlayState.hitnotesong, 32);
            notes.scrollFactor.set();
            notes.setFormat(Paths.font('vcr.ttf'), 32);
            notes.updateHitbox();
            add(notes);*/

            levelInfo.alpha = 0;
           // levelDifficulty.alpha = 0;
           // notes.alpha = 0;

            levelInfo.x = FlxG.width - (levelInfo.width + 20);
           // levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
           // notes.x = FlxG.width - (notes.width + 20);

            FlxTween.tween(bg, {alpha: 0.6}, 0.8, {ease: FlxEase.quartInOut});
            FlxTween.tween(box, {alpha: 1}, 1, {
                onComplete: function (twn:FlxTween) {
                    ready = true;
                }
            });

            FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
            //FlxTween.tween(levelDifficulty, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
            //FlxTween.tween(notes, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

            grpMenuShit = new FlxTypedGroup<FlxText>();
            add(grpMenuShit);

            regenMenu();
            cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

            Time = new FlxTimer();
            Time.start(2.5, onOverlay, 0);
        }

        var holdTime:Float = 0;
        var cantUnpause:Float = 0.1;
        override function update(elapsed:Float)
            {
                cantUnpause -= elapsed;
                if (pauseMusic.volume < 0.5)
                    pauseMusic.volume +=  0.01 * elapsed;

                super.update(elapsed);
                updateSkipTextStuff();

                var upP = controls.UI_UP_P;
                var downP = controls.UI_DOWN_P;
                var accepted = controls.ACCEPT;

                if (ready == true) {
                if (upP)
                    {
                        changeSelection(-1);
                    }
                if (downP)
                    {
                        changeSelection(1);
                    }
                }
                
                var daSelected:String = menuItems[curSelected];

                if (ready == true) {
                if (accepted && (cantUnpause <= 0 || !controls.controllerMode))
                {

                switch (daSelected)
                {
                    case "Resume":
                        close();
                    case 'Change Difficulty':
                        menuItems = diffChoices;
                        deleteSkipTimeText();
                        regenMenu();
                    case "Restart Song":
                        restartSong();
                    case 'Options':
                        PlayState.instance.paused = true; // For lua
                        PlayState.instance.vocals.volume = 0;
                        MusicBeatState.switchState(new options.OptionsState());
                        if(ClientPrefs.data.pauseMusic != 'None')
                        {
                            FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
                            FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
                            FlxG.sound.music.time = pauseMusic.time;
                            //add(new Notification(null, "Opciones:", "Opciones en Modo Juego!!", 0));
                        }
                        OptionsState.onPlayState = true;
                    case "Exit to menu":
                        #if desktop DiscordClient.resetClientID(); #end
                        PlayState.deathCounter = 0;
                        PlayState.seenCutscene = false;
    
                        Mods.loadTopMod();
                        if(PlayState.isStoryMode) {
                            MusicBeatState.switchState(new StoryMenuState());
                        } else {
                            MusicBeatState.switchState(new FreeplayState());
                        }
                        PlayState.cancelMusicFadeTween();
                        //FlxG.sound.playMusic(Paths.music('freakyMenu'));
                        PlayState.changedDifficulty = false;
                        PlayState.chartingMode = false;
                        FlxG.camera.followLerp = 0;
                }
            }
        }
        }

                function deleteSkipTimeText()
                    {
                        if(skipTimeText != null)
                        {
                            skipTimeText.kill();
                            remove(skipTimeText);
                            skipTimeText.destroy();
                        }
                        skipTimeText = null;
                        skipTimeTracker = null;
                    }

                    public static function restartSong(noTrans:Bool = false)
                        {
                            PlayState.instance.paused = true; // For lua
                            FlxG.sound.music.volume = 0;
                            PlayState.instance.vocals.volume = 0;
                    
                            if(noTrans)
                            {
                                FlxTransitionableState.skipNextTransIn = true;
                                FlxTransitionableState.skipNextTransOut = true;
                            }
                            MusicBeatState.resetState();
                        }

                        override function destroy()
                            {
                                pauseMusic.destroy();

                                super.destroy();
                            }

                        function changeSelection(change:Int = 0):Void
                            {
                                curSelected += change;

                                FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
                        
                                if (curSelected < 0)
                                    curSelected = menuItems.length - 1;
                                if (curSelected >= menuItems.length)
                                    curSelected = 0;
                        
                                //item.screenCenter(X);
                        
                                /*if (curSelected < 0)
                                    curSelected = menuItems.length - 1;
                                if (curSelected >= menuItems.length)
                                    curSelected = 0;*/
                        
                                var bullShit:Int = 0;
                        
                                for (item in grpMenuShit.members)
                                {
                                    item.ID = bullShit - curSelected;
                                    bullShit++;
                        
                                    item.alpha = 0.6;
                        
                                    if (item.ID == 0)
                                    {
                                        item.alpha = 1;
                                        item.screenCenter(X);
                                    }
                        
                                }
                            }

            function regenMenu():Void {
                for (i in 0...grpMenuShit.members.length) {
                    var obj = grpMenuShit.members[0];
                    obj.kill();
                    grpMenuShit.remove(obj, true);
                    obj.destroy();
                    //item.screenCenter(X);
                }

                var offset:Float = 108 - (Math.max(menuItems.length, 4) - 4) * 80;
                for (i in 0...menuItems.length) {
                    item = new FlxText(220, i * 60 + 200, menuItems[i], true);
                    item.setFormat(Paths.font("vcr.ttf"), 44);
                    //item.y += 10;
                    item.ID = i;
                    item.alpha = 0;
                    item.screenCenter(X);
                    grpMenuShit.add(item);
                }
                curSelected = 0;
                changeSelection();
            }

            function updateSkipTextStuff()
                {
                    if(skipTimeText == null || skipTimeTracker == null) return;

                    skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
                    skipTimeText.y = skipTimeTracker.y;
                    skipTimeText.visible = (skipTimeTracker.alpha >= 1); 
                }

                function updateSkipTimeText()
                    {
                    skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
                    }
}