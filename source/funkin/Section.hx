package funkin;

import funkin.noteStuff.NoteBasic.NoteData;

typedef SwagSection =
{
  var sectionNotes:Array<NoteData>;
  var lengthInSteps:Int;
  var typeOfSection:Int;
  var mustHitSection:Bool;
  var bpm:Float;
  var changeBPM:Bool;
  var altAnim:Bool;
}

class Section
{
  public var sectionNotes:Array<Dynamic> = [];

  public var lengthInSteps:Int = 16;
  public var typeOfSection:Int = 0;
  public var mustHitSection:Bool = true;

  /**
   *	Copies the first section into the second section!
   */
  public static var COPYCAT:Int = 0;

  public function new(lengthInSteps:Int = 16)
  {
    this.lengthInSteps = lengthInSteps;
  }
}