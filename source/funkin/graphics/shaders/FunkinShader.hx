package funkin.graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;

@:nullSafety
class FunkinShader extends FlxRuntimeShader
{
  public function new(?fragmentSource:String, ?vertexSource:String, ?glslVersion:String):Void
  {
    super(fragmentSource, vertexSource, glslVersion);
  }

  public static function fromFile(fragmentPath:String, ?vertexPath:String, ?version:String):FunkinShader
  {
    return new FunkinShader().loadShaderFile(fragmentPath, vertexPath, version);
  }

  public function loadShaderFile(fragmentPath:String, ?vertexPath:String, ?version:String):FunkinShader
  {
    if (vertexPath == null)
    {
      final idx = fragmentPath.lastIndexOf(".");
      if (idx == -1) vertexPath = fragmentPath;
      else vertexPath = fragmentPath.substr(0, idx);
    }

    _fromFile(FlxRuntimeShader._getPath(fragmentPath, false), FlxRuntimeShader._getPath(vertexPath, true), version);

    return this;
  }

  override function __createAssembler():Void
  {
    __glSourceAssembler = new FunkinShaderSourceAssembler(this);
  }
}

class FunkinShaderSourceAssembler extends FlxRuntimeShader.FlxShaderSourceAssembler
{
  public function new(parent:FunkinShader)
  {
    super(parent);
  }

  override function __getIncludeSource(include:String, fromVertex:Bool):Null<String>
  {
    if (Assets.exists('assets/shaders/' + include)) return Assets.getText('assets/shaders/' + include);

    return __getIncludeSource(include, fromVertex);
  }
}