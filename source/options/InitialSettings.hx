package options;

import flixel.graphics.frames.FlxAtlasFrames;
import animateatlas.AtlasFrameMaker;
import flixel.graphics.frames.FlxFrame;
import openfl.sensors.Accelerometer;
import objects.Character;

class InitialSettings extends BaseOptionsMenu
{
    var antialiasingOption:Int;
	var boyfriend:Character = null;
    public function new()
        {
            ClientPrefs.loadPrefs();
            title = 'Initial Settings';
            rpcTitle = 'Initial Settings Menu'; //for Discord Rich Presence

          /*  boyfriend = new Character(840, 170, 'bf', true);
            boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
            boyfriend.updateHitbox();
            boyfriend.dance();
            boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
            boyfriend.visible = false;*/
    
            //I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
            var option:Option = new Option('Language', //Name
                'Change all type of language in the game.', //Description
                'language', //Save data variable name
                'string',
                ['Spanish', 'Inglish', 'Portuguese'/*, 'Mandarin'*/]); //Variable type
            addOption(option);
            ClientPrefs.loadPrefs();
    
            var option:Option = new Option('Graphics',
                'This is an Internal graphics option.\nIt does not affect the Gameplay only the UI.',
                'graphics_internal',
                'string',
                ['Low','Medium','High','Ultra']);
            addOption(option);
    
            var option:Option = new Option('Fullscreen',
                'Disable this if recording as this interrupts.',
                'fullyscreen',
                'bool');
            addOption(option);
            ClientPrefs.loadPrefs();
    
            /*var option:Option = new Option('Mouse opacity',
                "This option set to 0 if you don't want to see it \nand 1 if you don't want it to be transparent.",
                'opacity_mouse',
                'percent');
            option.scrollSpeed = 1.2;
            option.minValue = 1;
            option.maxValue = 1;
            option.changeValue = 0.1;
            option.decimals = 1;
            addOption(option);*/

            var option:Option = new Option('sprites per second',
            "This is the sprites per second running on a model.\n'Recommended: 24'",
            'SpritesFPS',
            'Int');
           // option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
            addOption(option);
            antialiasingOption = optionsArray.length-1;
            option.minValue = 1;
            option.maxValue = 60;
            option.changeValue = 1;
            option.displayFormat = '%v Frames';
            //option.onChange = onChangeAntiAliasing;
            
            #if !DEMO_MODE
            var option:Option = new Option('Update Support',
                "Add a support to the game so that it updates itself.\nThis function is disabled in your version",
                'Update_Support',
                'bool');
            addOption(option);
            ClientPrefs.loadPrefs();
    
            var option:Option = new Option('Internet Data',
                'Using the Internet\nthis is used to download and install update files or profiles.\n!This function is disabled in your version!',
                'Internet',
                'string',
                [/*'Always','Only in Menus','Only in Matches',*/'Disabled']);
            addOption(option);
            #end
            ClientPrefs.loadPrefs();

            var option:Option = new Option('Recording Optimization',
            'Optimize all game fragments so that the recorder does not stop due to errors',
            'recordoptimization',
            'string',
            ['enabled', 'Disabled']);
            addOption(option);

            var option:Option = new Option('Notification Visibility',
            'Shows whether notifications are Visible or Invisible\nSelect the option if you want to see notifications',
            'notivisible',
            'bool');
            addOption(option);
    
            super();
        }
      /*  function onChangeAntiAliasing()
            {
                for (sprite in members)
                {
                    var sprite:FlxSprite = cast sprite;
                   // var num:porc = ClientPrefs.data.spritesFPS;
                    if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
                        sprite.setFrames(num, true);
                    }
                }
            }

        override function changeSelection(change:Int = 0)
            {
                super.changeSelection(change);
                boyfriend.visible = (antialiasingOption == curSelected);
            }*/
}