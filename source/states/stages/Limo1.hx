package states.stages;

import states.stages.objects.*;

class Limo1 extends BaseStage
{
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;
	var fastCarCanDrive:Bool = true;

	// event
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var dancersDiff:Float = 320;
	var changespeed:FlxTimer;

	public function onMovimentspeed(Timer:FlxTimer)
		{
			FlxTween.tween(bgLimo, {x: bgLimo.x - 120}, 3, {
				onComplete: function (twn:FlxTween) {
					FlxTween.tween(bgLimo, {x: bgLimo.x + 120}, 3, {
						onComplete: function (twn:FlxTween) {
							FlxTween.tween(bgLimo, {x: bgLimo.x + 120}, 3, {
								onComplete: function (twn:FlxTween) {
									FlxTween.tween(bgLimo, {x: bgLimo.x - 120}, 3);
								}
							});
						}
					});
				}
			});
		}

	override function create()
	{
		var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
		add(skyBG);

		if(!ClientPrefs.data.lowQuality) {
			limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
			add(limoMetalPole);

			bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
			add(bgLimo);

			/*limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
			add(limoCorpse);

			limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
			add(limoCorpseTwo);*/

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + dancersDiff + bgLimo.x, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
			add(limoLight);

			grpLimoParticles = new FlxTypedGroup<BGSprite>();
			add(grpLimoParticles);

			//PRECACHE BLOOD
			/*var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
			particle.alpha = 0.01;
			grpLimoParticles.add(particle);
			resetLimoKill();*/

			//PRECACHE SOUND
			//precacheSound('dancerdeath');
			//setDefaultGF('gf-car');
		}

		//fastCar = new BGSprite('limo/fastCarLol', -300, 160);
		//fastCar.active = true;

		changespeed = new FlxTimer();
		changespeed.start(15, onMovimentspeed, 0);
	}
	override function createPost()
	{
		//resetFastCar();
		//addBehindGF(fastCar);
		
		var limo:BGSprite = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
		addBehindGF(limo); //Shitty layering but whatev it works LOL
	}

	var limoSpeed:Float = 0;
	override function update(elapsed:Float)
	{
		if(!ClientPrefs.data.lowQuality) {
			grpLimoParticles.forEach(function(spr:BGSprite) {
				if(spr.animation.curAnim.finished) {
					spr.kill();
					grpLimoParticles.remove(spr, true);
					spr.destroy();
				}
			});
		}
	}

	override function beatHit()
	{
		if(!ClientPrefs.data.lowQuality) {
			grpLimoDancers.forEach(function(dancer:BackgroundDancer)
			{
				dancer.dance();
			});
		}

		//if (FlxG.random.bool(10) && fastCarCanDrive)
		//	fastCarDrive();
	}
	
	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			if(carTimer != null) carTimer.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			if(carTimer != null) carTimer.active = false;
		}
	}

	/*override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Kill Henchmen":
				killHenchmen();
		}
	}*/

	function dancersParenting()
	{
		var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
		for (i in 0...dancers.length) {
			dancers[i].x = (370 * i) + dancersDiff + bgLimo.x;
		}
	}
	
	function resetLimoKill():Void
	{
		limoMetalPole.x = -500;
		limoMetalPole.visible = false;
		limoLight.x = -500;
		limoLight.visible = false;
		limoCorpse.x = -500;
		limoCorpse.visible = false;
		limoCorpseTwo.x = -500;
		limoCorpseTwo.visible = false;
	}

	/*function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}*/

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		////FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			//resetFastCar();
			carTimer = null;
		});
	}
}