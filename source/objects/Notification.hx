package objects;

import cpp.Function;

//import backend.Achievements;

class Notification extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	public var notiBG:FlxSprite;
	public var notiBGAlert:FlxSprite;
	var alphaTween:FlxTween;
	var alphaTween2:FlxTween;
	var alphaTween3:FlxTween;
	//var Type:Int;
	public var notigroups:FlxTypedGroup<FlxSprite>;
	public function new(/*name:String, */?camera:FlxCamera = null, textNoti:String = '', descText:String = '', ?Type:Int)
	{
		super(x, y);
		ClientPrefs.saveSettings();
		notigroups = new FlxTypedGroup<FlxSprite>();

		//var id:Int = Achievements.getAchievementIndex(name);
		var achievementBG:FlxSprite = new FlxSprite(-990, 0).makeGraphic(420, 120, FlxColor.BLACK);
		//achievementBG.setGraphicSize(420, 120);
		//achievementBG.screenCenter(X);
		achievementBG.scrollFactor.set();

		if (Type == 0) {
		notiBG = new FlxSprite(-1000, -20).loadGraphic(Paths.image('notification_box'));
		notiBG.setGraphicSize(420, 120);
		//notiBG.screenCenter(X);
		notiBG.scrollFactor.set();
		//notiBG.alpha = 1;
		}
		if (Type == 1) {
			notiBG = new FlxSprite(-1000, -20).loadGraphic(Paths.image('notification_boxAlert'));
			notiBG.setGraphicSize(420, 120);
			//notiBG.screenCenter(X);
			notiBG.scrollFactor.set();
			//notiBG.alpha = 1;
		}
		if (Type == 2) {
			notiBG = new FlxSprite(-1000, -20).loadGraphic(Paths.image('notification_boxLevel'));
			notiBG.setGraphicSize(420, 10);
			//notiBG.screenCenter(X);
			notiBG.scrollFactor.set();
			//notiBG.alpha = 1;
		}

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image(''/* + name*/));
		achievementIcon.antialiasing = ClientPrefs.data.antialiasing;
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();

		var notiName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 10, achievementIcon.y + 17, 280, textNoti + "\n", 16);
		notiName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		notiName.scrollFactor.set();
		notiName.setGraphicSize(Std.int(notiBG.width * (2 / 3)));

		var notiText:FlxText = new FlxText(notiName.x, notiName.y + 32, 280, "\n" + descText, 16);
		notiText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.BLACK, LEFT, OUTLINE, FlxColor.WHITE);
		notiText.scrollFactor.set();
		notiText.setGraphicSize(Std.int(notiBG.width * (2 / 3)));

		add(achievementBG);
		add(notiBG);
		add(notiName);
		add(notiText);
		this.visible = ClientPrefs.data.notivisible;
		//add(achievementIcon);
		//add(notigroups);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		notiBG.cameras = cam;
		notiName.cameras = cam;
		notiText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween2 = FlxTween.tween(notiText, {alpha: 1}, 0.1, {onComplete: function (twn:FlxTween) {
			alphaTween2 = FlxTween.tween(notiText, {x: 40, y: 50}, 1, {
				onComplete: function(twn:FlxTween) {
					alphaTween2 = FlxTween.tween(notiText, {x: achievementIcon.x + achievementIcon.width + 10, y: achievementIcon.y + 17}, 1, {
						startDelay: 3.5,
						onComplete: function(twn:FlxTween) {
							trace('Texto Movido!!');
						}
					});
				}
			});
		}});

		alphaTween2 = FlxTween.tween(notiName, {alpha: 1}, 0.1, {onComplete: function (twn:FlxTween) {
			alphaTween2 = FlxTween.tween(notiName, {x: 40, y: 30}, 1, {
				onComplete: function(twn:FlxTween) {
					alphaTween2 = FlxTween.tween(notiName, {x: achievementIcon.x + achievementIcon.width + 10, y: achievementIcon.y + 17}, 1, {
						startDelay: 3.5,
						onComplete: function(twn:FlxTween) {
							trace('Texto Movido!!');
						}
					});
				}
			});
		}});
		alphaTween3 = FlxTween.tween(notiBG, {alpha: 1}, 0.1, {onComplete: function (twn:FlxTween) {
			alphaTween3 = FlxTween.tween(notiBG, {x: -50, y: -20}, 1, {
				//notiName.alpha = 1;
				//startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween3 = FlxTween.tween(notiBG, {x: -1000, y: -20}, 1, {
						startDelay: 3.5,
						onComplete: function(twn:FlxTween) {
					alphaTween3 = null;
					remove(this);
					if(onFinish != null) onFinish();
						}
					});
				}
			});
		}});
		alphaTween = FlxTween.tween(achievementBG, {alpha: 1}, 0.1, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(achievementBG, {x: -50, y: -210}, 1, {
				//notiName.alpha = 1;
				//startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = FlxTween.tween(achievementBG, {x: -1000, y: -210}, 1, {
						startDelay: 3.5,
						onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
						}
					});
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}