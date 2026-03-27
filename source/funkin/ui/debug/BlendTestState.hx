package funkin.ui.debug;

import flixel.graphics.tile.FlxGraphicsShader;

import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput.FlxInputState;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;

import openfl.display.BlendMode;

using flixel.util.FlxArrayUtil;

class BlendTestState extends MusicBeatState
{
  final SPRITE1_KEYS = [
    "left" => FlxKey.A,
    "down" => FlxKey.S,
    "up" => FlxKey.W,
    "right" => FlxKey.D,
    "decrement" => FlxKey.Q,
    "increment" => FlxKey.E,
    "alphaup" => FlxKey.C,
    "alphadown" => FlxKey.X,
    "alphareset" => FlxKey.Z
  ];

  final SPRITE2_KEYS = [
    "left" => FlxKey.F,
    "down" => FlxKey.G,
    "up" => FlxKey.T,
    "right" => FlxKey.H,
    "decrement" => FlxKey.R,
    "increment" => FlxKey.Y,
    "alphaup" => FlxKey.N,
    "alphadown" => FlxKey.B,
    "alphareset" => FlxKey.V
  ];

  var sprite1:FlxSprite;
  var sprite1label:FlxText;
  var sprite2:FlxSprite;
  var sprite2label:FlxText;

  override function create():Void
  {
    super.create();

    bgColor = 0xFF808080;

    sprite2 = new FlxSprite(Paths.image("newgrounds_logo_classic"));
    sprite2.blend = NORMAL;
    //sprite2.setPosition((FlxG.width * 0.5 - sprite2.width) * 0.5 + FlxG.width * 0.5, (FlxG.height - sprite2.height) * 0.5);
    sprite2.setPosition((FlxG.width - sprite2.width) * 0.5, (FlxG.height - sprite2.height) * 0.5);
    add(sprite2);

    sprite2label = new FlxText(0, FlxG.height * 0.80 - 12, 0, "", 24);
    sprite2label.color = FlxColor.BLACK;
    add(sprite2label);

    sprite1 = new FlxSprite(Paths.image("newgrounds_logo"));
    sprite1.blend = DARKEN;
    //sprite1.setPosition((FlxG.width * 0.5 - sprite1.width) * 0.5, (FlxG.height - sprite1.height) * 0.5);
    sprite1.setPosition((FlxG.width - sprite1.width) * 0.5, (FlxG.height - sprite1.height) * 0.5);
    add(sprite1);

    sprite1label = new FlxText(0, FlxG.height * 0.80 - 12, 0, "", 24);
    sprite1label.color = FlxColor.BLACK;
    add(sprite1label);

    var shader = new FlxGraphicsShader();

    sprite1.shader = sprite2.shader = shader;

    trace(shader.glFragmentSource, shader.glVertexSource);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.ESCAPE)
    {
      FlxG.switchState(() -> new funkin.ui.mainmenu.MainMenuState());
    }

    updateSprite(sprite1, sprite1label, FlxG.width * 0.25, elapsed, SPRITE1_KEYS);
    updateSprite(sprite2, sprite2label, FlxG.width * 0.75, elapsed, SPRITE2_KEYS);

    if (FlxG.keys.justPressed.TAB)
    {
      members.swapByIndex(members.indexOf(sprite1), members.indexOf(sprite2));
    }
  }

  function updateSprite(sprite:FlxSprite, label:FlxText, labelxcenter:Float, elapsed:Float, keys:Map<String, FlxKey>):Void
  @:privateAccess
  {
    if (FlxG.keys.pressed.SHIFT) elapsed *= 2;

    if (checkPress(keys.get("left"))) sprite.x -= elapsed * 256;
    if (checkPress(keys.get("right"))) sprite.x += elapsed * 256;
    if (checkPress(keys.get("up"))) sprite.y -= elapsed * 256;
    if (checkPress(keys.get("down"))) sprite.y += elapsed * 256;

    if (checkPress(keys.get("alphareset"))) sprite.alpha = 1;
    else
    {
      if (checkPress(keys.get("alphadown"))) sprite.alpha -= elapsed;
      if (checkPress(keys.get("alphaup"))) sprite.alpha += elapsed;
    }

    if (checkJustPress(keys.get("increment"))) sprite.blend = getBlend(sprite.blend, 1);
    if (checkJustPress(keys.get("decrement"))) sprite.blend = getBlend(sprite.blend, -1);

    var text = sprite.blend.toString();
    if (label.text != text)
    {
      label.text = text;
      label.x = labelxcenter - label.width * 0.5;
    }
  }

  inline function checkPress(key:Null<FlxKey>):Bool
  {
    return key != null && FlxG.keys.checkStatus(key, PRESSED);
  }

  inline function checkJustPress(key:Null<FlxKey>):Bool
  {
    return key != null && FlxG.keys.checkStatus(key, JUST_PRESSED);
  }

  function getBlend(blend:BlendMode, increment:Int):BlendMode
  {
    var value = (cast blend : Int) + increment;

    if (value < 0) value = 22;
    else if (value > 22) value = 0;

    return cast value;
  }
}