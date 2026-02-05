package objects;

import objects.StrumNote;
import objects.Character;

class StrumLine extends FlxTypedGroup<StrumNote> {
	/**
	 * Array containing all of the characters "attached" to those strums.
	 */
	public var characters:Array<Character>;

	public function new(?characters:Array<Character>) {
		super();
		this.characters = characters;
	}
}
