package funkin.graphics.shaders;

import openfl.display.BitmapData;
import openfl.display.BlendMode;

class RuntimeCustomBlendShader extends RuntimePostEffectShader
{
  // only different name purely for hashlink fix
  public var sourceSwag(default, set):BitmapData;

  function set_sourceSwag(value:BitmapData):BitmapData
  {
    this.setBitmapData("source", value);
    return sourceSwag = value;
  }

  public var backgroundSwag(default, set):BitmapData;

  function set_backgroundSwag(value:BitmapData):BitmapData
  {
    this.setBitmapData("background", value);
    return backgroundSwag = value;
  }

  // name change make sure it's not the same variable name as whatever is in the shader file
  public var blendSwag(default, set):BlendMode;

  function set_blendSwag(value:BlendMode):BlendMode
  {
    this.setInt("blendMode", cast value);
    return blendSwag = value;
  }

  public function new()
  {
    super();
    _fromFile("assets/shaders/customBlend.frag", null, null);
  }
}
