package funkin.graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.Assets;

@:nullSafety
class PuddleShader extends FlxRuntimeShader
{
  public function new()
  {
    super();
    _fromFile(Paths.frag('puddle'), null, null);
  }
}
