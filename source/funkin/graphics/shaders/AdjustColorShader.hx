package funkin.graphics.shaders;

class AdjustColorShader extends FunkinShader
{
  public var hue(get, set):Float;
  public var saturation(get, set):Float;
  public var brightness(get, set):Float;
  public var contrast(get, set):Float;

  @:glFragmentSource('
    #pragma header

    #include "functions/adjustColor.glsl"

    uniform float _hue = 0.0;
    uniform float _saturation = 0.0;
    uniform float _brightness = 0.0;
    uniform float _contrast = 0.0;

    void main()
    {
      vec4 color = texture2D(bitmap, openfl_TextureCoordv);
      if (color.a == 0.0) discard;

      vec3 rgb = color.rgb;

      // Un-multiply alpha if the texture is premultiplied
      // Lime premultiplies alphas before sending it to render, so we want to accomodate header. This fixes some antialiased edges appearing darker
      if (!premultiplyAlpha) rgb /= color.a;

      rgb = applyBrightness(rgb, _brightness);
      rgb = applyHue(rgb, _hue);
      rgb = applySaturation(rgb, _saturation);
      rgb = applyContrast(rgb, _contrast);

      gl_FragColor = apply_flixel_transform(vec4(rgb * color.a, color.a));
    }
  ')

  public function new()
  {
    super();
  }

  inline function get_hue():Float
  {
    return _hue.value[0];
  }

  inline function set_hue(value:Float):Float
  {
    return _hue.value[0] = value;
  }

  inline function get_saturation():Float
  {
    return _saturation.value[0];
  }

  inline function set_saturation(value:Float):Float
  {
    return _saturation.value[0] = value;
  }

  inline function get_brightness():Float
  {
    return _brightness.value[0];
  }

  inline function set_brightness(value:Float):Float
  {
    return _brightness.value[0] = value;
  }

  inline function get_contrast():Float
  {
    return _contrast.value[0];
  }

  inline function set_contrast(value:Float):Float
  {
    return _contrast.value[0] = value;
  }

  public override function toString():String
  {
    return 'AdjustColorShader(${this.hue}, ${this.saturation}, ${this.brightness}, ${this.contrast})';
  }
}
