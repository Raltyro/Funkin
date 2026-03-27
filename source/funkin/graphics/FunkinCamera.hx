package funkin.graphics;

import funkin.graphics.framebuffer.FixedBitmapData;
import funkin.graphics.shaders.RuntimeCustomBlendShader;

import animate.internal.RenderTexture;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxCamera;

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.OpenGLRenderer;
import openfl.display.TriangleCulling;
import openfl.display3D.Context3DWrapMode;
import openfl.display3D.Context3DCompareMode;
import openfl.geom.ColorTransform;
import openfl.Lib;

using funkin.graphics.framebuffer.BitmapDataUtil;

/**
 * A FlxCamera with additional powerful features:
 * - Added the ability to grab the camera screen as a `BitmapData` and use it as a texture.
 * - Added support for the following blend modes for a sprite through shaders:
 *   - DARKEN
 *   - HARDLIGHT
 *   - LIGHTEN
 *   - OVERLAY
 *   - DIFFERENCE
 *   - INVERT
 *   - COLORDODGE
 *   - COLORBURN
 *   - SOFTLIGHT
 *   - EXCLUSION
 *   - HUE
 *   - SATURATION
 *   - COLOR
 *   - LUMINOSITY
 */
@:nullSafety
@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.textures.TextureBase)
@:access(flixel.graphics.FlxGraphic)
@:access(flixel.graphics.frames.FlxFrame)
@:access(openfl.display.OpenGLRenderer)
@:access(openfl.geom.ColorTransform)
class FunkinCamera extends FlxCamera
{
  /**
   * The ID of this camera, used for debugging.
   */
  public var id:String;

  /**
   * If `true` the blend shader will try to blend with the cameras underneath it.
   * This is useful for, say, making a strumline note have a shader-only blend mode like `INVERT`.
   *
   * Defaults to `false` since this can impact performance.
   */
  public var crossCameraBlending:Bool;

  var _blendShader:RuntimeCustomBlendShader;
  var _backgroundFrame:FlxFrame;

  var _blendRenderTexture:RenderTexture;
  var _backgroundRenderTexture:RenderTexture;

  var _cameraTexture:FixedBitmapData;
  var _cameraMatrix:FlxMatrix;

  @:nullSafety(Off)
  public function new(id:String = 'unknown', x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, zoom:Float = 0)
  {
    super(x, y, width, height, zoom);

    this.id = id;

    _backgroundFrame = new FlxFrame(new FlxGraphic('', null));
    _backgroundFrame.frame = new FlxRect();

    _blendShader = new RuntimeCustomBlendShader();

    _backgroundRenderTexture = new RenderTexture(this.width, this.height);
    _blendRenderTexture = new RenderTexture(this.width, this.height);

    _cameraMatrix = new FlxMatrix();
    _cameraTexture = FixedBitmapData.create(this.width, this.height);

    crossCameraBlending = false;
  }

  override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
      ?shader:FlxShader, ?wrapMode:Context3DWrapMode, ?depthCompareMode:Context3DCompareMode):Void
  {
    @:nullSafety(Off)
    final shouldUseShader:Bool = switch (blend)
    {
      case DARKEN, DIFFERENCE, HARDLIGHT, OVERLAY, COLORDODGE, COLORBURN, SOFTLIGHT, EXCLUSION, HUE, SATURATION, COLOR, LUMINOSITY:
        !OpenGLRenderer.__complexBlendsSupported;
      case LIGHTEN:
        !OpenGLRenderer.__blendMinMaxSupported && !OpenGLRenderer.__complexBlendsSupported;
      default: false;
    }

    // Fallback to the shader implementation if the device doesn't support `KHR_blend_equation_advanced`, or if
    // the specified blend mode requires the shader.
    if (shouldUseShader)
    {
      if (crossCameraBlending)
      {
        var camerasUnderneath:Array<FlxCamera> = FlxG.cameras.list.copy();

        for (i in camerasUnderneath.length - 1...-1)
        {
          if (i > FlxG.cameras.list.indexOf(this))
          {
            camerasUnderneath.remove(camerasUnderneath[i]);
          }
        }

        _cameraTexture.drawCameraScreens(camerasUnderneath);

        for (camera in camerasUnderneath)
        {
          camera.clearDrawStack();
          camera.canvas.graphics.clear();
        }
      }
      else
      {
        _cameraTexture.drawCameraScreen(this);
      }

      _backgroundFrame.frame.set(0, 0, this.width, this.height);

      // Clear the camera's graphics
      // It'll get redrawn anyway
      this.clearDrawStack();
      this.canvas.graphics.clear();

      _blendRenderTexture.init(this.width, this.height);
      _blendRenderTexture.drawToCamera((camera, frameMatrix) ->
      {
        var pivotX:Float = width / 2;
        var pivotY:Float = height / 2;

        frameMatrix.copyFrom(matrix);
        frameMatrix.translate(-pivotX, -pivotY);
        frameMatrix.scale(this.scaleX, this.scaleY);
        frameMatrix.translate(pivotX, pivotY);
        camera.drawPixels(frame, pixels, frameMatrix, transform, null, smoothing, shader);
      });
      _blendRenderTexture.render();

      _blendShader.sourceSwag = _blendRenderTexture.graphic.bitmap;
      _blendShader.backgroundSwag = _cameraTexture;

      _blendShader.blendSwag = blend;
      _blendShader.updateViewInfo(width, height, this);

      _backgroundFrame.parent.bitmap = _blendRenderTexture.graphic.bitmap;

      // On some displays, the DPI can be less than 1, which causes the blend shader to look bad
      // We just clamp the scale to 1 to avoid this!
      var clampedScale:Float = Math.max(1, Lib.current.stage.window.scale);

      _backgroundRenderTexture.init(Std.int(this.width * clampedScale), Std.int(this.height * clampedScale));
      _backgroundRenderTexture.drawToCamera((camera, matrix) ->
      {
        camera.zoom = this.zoom;
        matrix.scale(clampedScale, clampedScale);
        camera.drawPixels(_backgroundFrame, null, matrix, canvas.transform.colorTransform, null, false, _blendShader);
      });

      _backgroundRenderTexture.render();

      // Resize the frame so it always fills the screen
      _cameraMatrix.identity();
      _cameraMatrix.scale(1 / (this.scaleX * clampedScale), 1 / (this.scaleY * clampedScale));
      _cameraMatrix.translate(((width - width / this.scaleX) * 0.5), ((height - height / this.scaleY) * 0.5));

      super.drawPixels(_backgroundRenderTexture.graphic.imageFrame.frame, null, _cameraMatrix, null, null, smoothing, null, wrapMode, depthCompareMode);
    }
    else
    {
      super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader, wrapMode, depthCompareMode);
    }
  }

  override function destroy():Void
  {
    super.destroy();

    _blendRenderTexture.destroy();
    _backgroundRenderTexture.destroy();

    _cameraTexture.dispose();
  }
}
