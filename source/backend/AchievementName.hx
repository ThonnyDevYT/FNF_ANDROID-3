package backend;

import haxe.Json;
import sys.io.File;

class AchievementName {
    var currentLanguage = ClientPrefs.data.language; //Este valor representa la eleccion de idioma del usuario
    public static var LanguageData:Dynamic = null;

    public function loadJSON() {
        //Carga el Archivo de idioma tipo JSON
        try {
            var fileContent:String = sys.io.File.getContent("data/language-" + currentLanguage + ".json");
            LanguageData = haxe.Json.parse(fileContent);
        } catch (error:Dynamic) {
            trace("Error loading language file: " + error);
        }
    }
}