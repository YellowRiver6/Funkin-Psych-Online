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
	public var cpu(default, set):Bool;
	private function set_cpu(variable:Bool) {
		if (PlayState.instance != null && !isStrumCreation) {
			for (note in PlayState.instance.unspawnNotes) {
				if (note.rawNoteData >= targetNoteData && note.rawNoteData < targetNoteData + noteCount) {
					note.mustPress = !variable;
				}
			}
		}
		cpu = variable; //silly me
		return variable;
	}

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
