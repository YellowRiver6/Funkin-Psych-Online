package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import backend.ClientPrefs;
import states.PlayState;
import objects.StrumNote;
import objects.Note;
import objects.Character;
import backend.Controls;

class StrumLine extends FlxTypedGroup<StrumNote> {
	/**
	 * Array containing all of the characters "attached" to those strums.
	 */
	public var characters:Array<Character>;
	
	/**
	 * Whenever this strumline is controlled by cpu or not.
	 */
	public var cpu(default, set):Bool = false;
	
	/**
	 * Controls assigned to this strumline.
	 */
	public var controls:Controls = null;

	/**
	 * The Player ID (0 = Dad/Opponent, 1 = BF/Player)
	 */
	public var data:Int = 0;

	public function new(characters:Array<Character>, cpu:Bool = false, data:Int = 0, ?controls:Controls) {
		super();
		this.characters = characters;
		this.cpu = cpu;
		this.data = data;
		this.controls = controls;
	}

	public function generateStrums() {
		var strumWidth = Note.maniaKeys * Note.swagScaledWidth - (Note.getNoteOffsetX() * (Note.maniaKeys - 1));
		var strumLineX:Float = 0;

		if (ClientPrefs.data.middleScroll) {
			strumLineX = FlxG.width / 2 - strumWidth / 2;
		}
		else {
			strumLineX = (FlxG.width / 2 - strumWidth) / 2;
			strumLineX += FlxG.width / 2 * (this.data == 0 ? 0 : 1);
		}

		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;

		for (i in 0...Note.maniaKeys)
		{
			var targetAlpha:Float = 1;

			if (this.data == 0)
			{
				if(!ClientPrefs.data.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.data.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, this.data);
			babyArrow.forceShow = ClientPrefs.data.opponentStrums && ClientPrefs.data.disableStrumMovement;
			babyArrow.downScroll = ClientPrefs.data.downScroll;

			if (!PlayState.isStoryMode && !PlayState.instance.skipArrowStartTween)
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + 4 / Note.maniaKeys * 0.2 * i});
			}
			else
				babyArrow.alpha = targetAlpha;

			// Middle Scroll Layout Logic
			if (this.data == 0 && ClientPrefs.data.middleScroll) {
				babyArrow.x = strumLineX / 2 - strumWidth / 4;
				if (i > Note.maniaKeys / 2 - 1) { // half rest
					babyArrow.x += (strumLineX + strumWidth / 2);
				}

				if (Note.maniaKeys % 2 != 0 && i == Std.int(Note.maniaKeys / 2)) {
					babyArrow.forceHide = true;
				}
			}

			this.add(babyArrow);

			// --- UNDERLAYS: By Note ---
			if (PlayState.instance.replayPlayer == null && ClientPrefs.data.noteUnderlayOpacity > 0 && this.data == 1 && ClientPrefs.data.noteUnderlayType == 'By Note') {
				var underlay = new FlxSprite().makeGraphic(1, Std.int(FlxG.width * 2), FlxColor.BLACK);
				underlay.alpha = ClientPrefs.data.noteUnderlayOpacity;
				underlay.scale.x = Note.swagScaledWidth;
				underlay.updateHitbox();
				PlayState.instance.noteUnderlays.add(underlay);
			}

			if (GameClient.isConnected()) {
				var playsAsBF = true;
				if (PlayState.instance != null) playsAsBF = PlayState.instance.playsAsBF();

				if (!playsAsBF)
					babyArrow.maxAlpha = (this.data == 0 ? 1 : 0.7);
				else
					babyArrow.maxAlpha = (this.data == 0 ? 0.7 : 1);
			}

			// Add to PlayState global list if needed
			if (PlayState.instance.strumLineNotes != null)
				PlayState.instance.strumLineNotes.add(babyArrow);
				
			babyArrow.postAddedToGroup();
		}

		// --- UNDERLAYS: All-In-One ---
		if (PlayState.instance.replayPlayer == null && ClientPrefs.data.noteUnderlayOpacity > 0 && this.data == 1 && ClientPrefs.data.noteUnderlayType == 'All-In-One') {
			var vsliceControlFix:Float = 1;
			if (ClientPrefs.data.ogGameControls && Note.maniaKeys < 10) {
				switch (Note.maniaKeys) {
					case 4: vsliceControlFix = 6.5 / 3.5;
					case 5: vsliceControlFix = 6.5 / 5;
					case 6: vsliceControlFix = 6.5 / 4.8;
					case 7: vsliceControlFix = 6.5 / 4.6;
					case 8: vsliceControlFix = 6.5 / 4.8;
					case 9: vsliceControlFix = 6.5 / 4.5;
				}
			}
			var underlay = new FlxSprite().makeGraphic(1, Std.int(FlxG.width * 2), FlxColor.BLACK);
			underlay.alpha = ClientPrefs.data.noteUnderlayOpacity;
			underlay.scale.x = (Note.swagScaledWidth * Note.maniaKeys - (Note.getNoteOffsetX() * (Note.maniaKeys - 1))) * vsliceControlFix;

			underlay.updateHitbox();
			PlayState.instance.noteUnderlays.add(underlay);
		}
	}

	/**
	 * SETTERS & GETTERS
	 */
	private inline function set_cpu(b:Bool):Bool {
		for(s in members)
			if (s != null)
				s.cpu = b;
		return cpu = b;
	}
}
