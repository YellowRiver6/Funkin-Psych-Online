package objects;

import objects.StrumNote;
import objects.Character;

class StrumLine extends FlxTypedGroup<StrumNote> {
	/**
	 * Array containing all of the characters "attached" to those strums.
	 */
	public var characters:Array<Character>;
	/**
	 * Strum controlling by cpu or not.
	 */
	public var cpu:Bool;

	/**
	 * Targetted Note Data for this strumline.
	 */
	public var targetNoteData:Int;

	/**
	 * bypass mustPress check for this strumline.
	 */
	public var isStrumCreation:Bool;

	/**
	 * The note count this strumline.
	 */
	public var noteCount:Int;

	public function new(?cpu:Bool, ?characters:Array<Character>, ?noteCount:Int, ?targetNoteData:Int, ?isStrumCreation:Bool) {
		super();
		this.isStrumCreation = isStrumCreation;
		this.cpu = cpu;
		this.isStrumCreation = false;
		this.noteCount = noteCount;
		this.characters = characters;
		this.targetNoteData = targetNoteData;
	}
}
