package options;

import objects.Note;
import objects.StrumNote;
import objects.Alphabet;

class VisualsUISubState extends BaseOptionsMenu
{
	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteY:Float = 90;
	public function new()
	{
		if (ClientPrefs.data.language == 'Inglish') {
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence
		
		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');
		if(noteSplashes.length > 0)
		{
			if(!noteSplashes.contains(ClientPrefs.data.splashSkin))
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); //Default skin always comes first
			var option:Option = new Option('Note Splashes:',
				"Select your prefered Note Splash variation or turn it off.",
				'splashSkin',
				'string',
				noteSplashes);
			addOption(option);
		}

		var option:Option = new Option('Note Splash Opacity',
			'How much transparent should the Note Splashes be.',
			'splashAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool');
		addOption(option);

		var option:Option = new Option('Welcome',
			'Beta Option not Original.',
			'Welcome',
			'bool');
			addOption(option);
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool');
		addOption(option);
		
		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool');
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool');
		addOption(option);

		var option:Option = new Option('Health Bar Opacity',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool');
		addOption(option);
		#end

		#if desktop
		var option:Option = new Option('Discord Rich Presence',
			"Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord",
			'discordRPC',
			'bool');
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			'bool');
		addOption(option);

		super();
		add(notes);
	}


	////////////////////////////////////////////////////////////////////////////////////



	if (ClientPrefs.data.language == 'Spanish') {
		title = 'Imágenes y UI';
		rpcTitle = 'Menú de configuración de imágenes y UI'; //for Discord Rich Presence

			var option:Option = new Option('Music:',
			'Musica del Juego en los Menus',
			'musicstate',
			'String',
			['MenuTetrik-State Horror', 'FightsMix', 'disabled']);
		option.onChange = onMusic; 
		addOption(option);
		
		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');

			var option:Option = new Option('Nota salpicaduras:',
				"Seleccione su variación de Note Splash preferida o apáguela.",
				'splashSkin',
				'string',
				noteSplashes);
			addOption(option);

		var option:Option = new Option('Nota Opacidad de salpicadura',
			'¿Qué tan transparentes deben ser las Note Splashes?',
			'splashAlpha',
			'percent');
			option.scrollSpeed = 1.6;
			option.minValue = 0.0;
			option.maxValue = 1;
			option.changeValue = 0.1;
			option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Visibilidad de notificación',
		'Muestra si las notificaciones son visibles o invisibles\nSeleccione la opción si desea ver las notificaciones',
		'notivisible',
		'bool');
		addOption(option);

		var option:Option = new Option('Tiempo de Transaccion',
		'Determina el tiempo que tarda las animaciones de Transaccion',
		'timetrans',
		'int');
		option.minValue = 1;
		option.maxValue = 6;
		option.displayFormat = '%v s';
		//option.onChange = ;
		addOption(option);

		var option:Option = new Option('Ocultar HUD',
			'Si está marcado, oculta la mayoría de los elementos del HUD.',
			'hideHud',
			'bool');
		addOption(option);

		var option:Option = new Option('Welcome',
			'Beta Option not Original.',
			'Welcome',
			'bool');
			addOption(option);
		
		var option:Option = new Option('Barra de tiempo:',
			"¿Qué debería mostrar la barra de tiempo?\n'Song Name' Mustra tambien la Difficultad de la Musica",
			'timeBarType',
			'string',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Luces parpadeantes',
			"¡Desmarca esta opción si eres sensible a las luces intermitentes!",
			'flashing',
			'bool');
		addOption(option);

		var option:Option = new Option('Pantalla completa:',
			'Cambia la visualización del juego a Pantalla completa.\n!¡Necesita reiniciar!',
			'fullyscreen',
			'bool');
		addOption(option);
		
		var option:Option = new Option('Zooms de cámara',
			"Si no está marcada, la cámara no hará zoom en un hit.",
			'camZooms',
			'bool');
		addOption(option);

		var option:Option = new Option('Puntuación de zoom de texto al golpear',
			"Si no está marcado, desactiva el zoom del texto de la partitura\n cada vez que tocas una nota.",
			'scoreZoom',
			'bool');
		addOption(option);

		var option:Option = new Option('Idioma',
			'Tipo de idioma del juego solo en textos y algunas imágenes.',
			'language',
			'string',
			['Spanish', 'Inglish', 'Portuguese'/*, 'Mandarin' //El mandarin fue elimido en la version 1.0(Beta)*/]);
		addOption(option);

		var option:Option = new Option('Opacidad de la barra de salud',
			'¿Qué tan transparentes deben ser la barra de salud y los íconos?',
			'healthBarAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('Contador de FPS',
			'Si no está marcado, oculta el contador de FPS.\nTambien elimina el contador de Memoria!!',
			'showFPS',
			'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option('Pausar canción en pantalla:',
			"¿Qué canción prefieres para la pantalla de pausa?",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool');
		addOption(option);
		#end

		#if desktop
		var option:Option = new Option('Presencia rica en discord',
			"Desmarque esta opción para evitar filtraciones accidentales;\nocultará la aplicación de su casilla \"Reproduciendo\" en Discord.",
			'discordRPC',
			'bool');
		addOption(option);
		#end

		var option:Option = new Option('Apilamiento combinado',
			"Si no está marcado, las calificaciones y el combo no se acumularán,\nlo que ahorrará en la memoria del sistema y facilitará su lectura.",
			'comboStacking',
			'bool');
		addOption(option);

		super();
		add(notes);
	}


	////////////////////////////////////////////////////////////////////////////////////////



	if (ClientPrefs.data.language == 'Portuguese') {
		title = 'Imagens e IU';
		rpcTitle = 'Menu de configurações de imagens e interface do usuário'; //for Discord Rich Presence
		
		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');
		if(noteSplashes.length > 0)
		{
			if(!noteSplashes.contains(ClientPrefs.data.splashSkin))
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); //Default skin always comes first
			var option:Option = new Option('Nota salpicos:',
				"Selecione sua variação preferida do Note Splash ou desligue-a.",
				'splashSkin',
				'string',
				noteSplashes);
			addOption(option);
		}

		var option:Option = new Option('Nota Splash Opacidade',
			'Quão transparente deve ser o Note Splashes?',
			'splashAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Visibilidade de notificação',
		'Mostra se as notificações estão visíveis ou invisíveis\nSelecione a opção se quiser ver as notificações',
		'notivisible',
		'bool');
		addOption(option);

		var option:Option = new Option('Tempo de transação',
		'Determina o tempo que leva para animações de transação',
		'timetrans',
		'int');
		option.minValue = 1;
		option.maxValue = 6;
		option.displayFormat = '%v s';
		//option.onChange = ;
		addOption(option);

		var option:Option = new Option('Ocultar HUD',
			'Se marcada, oculta a maioria dos elementos do HUD.',
			'hideHud',
			'bool');
		addOption(option);

		var option:Option = new Option('Welcome',
			'Beta Option not Original.',
			'Welcome',
			'bool');
			addOption(option);
		
		var option:Option = new Option('Barra de tempo:',
			"O que a barra de tempo deve mostrar?\n'Nome da música' Também mostra a dificuldade da música",
			'timeBarType',
			'string',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('luzes piscando',
			"Desmarque esta opção se você for sensível a luzes piscantes!",
			'flashing',
			'bool');
		addOption(option);

		var option:Option = new Option('Tela completa:',
			'Mude a exibição do jogo para tela inteira.\n!É necessário reiniciar!',
			'fullyscreen',
			'bool');
		addOption(option);
		
		var option:Option = new Option('Zoom da câmera',
			"Se desmarcada, a câmera não ampliará o acerto.",
			'camZooms',
			'bool');
		addOption(option);

		var option:Option = new Option('Pontuação de zoom de texto ao acertar',
			"Se desmarcada, desativa o zoom do texto da partitura\nsempre que você toca uma nota.",
			'scoreZoom',
			'bool');
		addOption(option);

		var option:Option = new Option('Linguagem',
			'Tipo de linguagem do jogo apenas em textos e algumas imagens.',
			'language',
			'string',
			['Spanish', 'Inglish', 'Portuguese'/*, 'Mandarin' //El mandarin fue elimido en la version 1.0(Beta)*/]);
		addOption(option);

		var option:Option = new Option('Opacidade da barra de saúde',
			'Quão transparentes devem ser a barra de saúde e os ícones?',
			'healthBarAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('Contador de FPS',
			'Se não estiver marcada, oculta o contador de FPS.\nTambém remove o contador de memória!!',
			'showFPS',
			'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option('Pausar música na tela:',
			"Qual música você prefere para a tela de pausa?",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool');
		addOption(option);
		#end

		#if desktop
		var option:Option = new Option('Presença rica de discord',
			"Desmarque esta opção para evitar vazamentos acidentais;\nisso ocultará o aplicativo da caixa \"Reproduzindo\" no Discord.",
			'discordRPC',
			'bool');
		addOption(option);
		#end

		var option:Option = new Option('Empilhamento combinado',
		"Se desmarcado, notas e combos não serão acumulados,\n economizando memória do sistema e facilitando a leitura.",
			'comboStacking',
			'bool');
		addOption(option);

		super();
		add(notes);
	}
}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
	}

	var changeMusicState:Bool = false;
	function onMusic() {
		if(ClientPrefs.data.musicstate == 'disabled')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(ClientPrefs.data.musicstate));
		
		changeMusicState = true;
	}


	override function destroy()
	{
		if(changedMusic && !OptionsState.onPlayState) FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end
}
