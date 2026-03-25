package funkin.graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;

/**
 * Create a little dotting effect.
 */
@:nullSafety
class InverseDotsShader extends FlxRuntimeShader
{
  public var amount:Float = 0;

  public function new(amount:Float = 1.0)
  {
    super();
    _fromFile(Paths.frag('InverseDots'), null, null);
    setAmount(amount);
  }

  public function setAmount(value:Float):Void
  {
    this.amount = value;
    this.setFloat("_amount", amount);
  }
}
