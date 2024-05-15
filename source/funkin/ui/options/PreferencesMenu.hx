package funkin.ui.options;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.ui.AtlasText.AtlasFont;
import funkin.ui.options.OptionsState.Page;
import funkin.graphics.FunkinCamera;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.util.Constants;
import funkin.input.Controls;
import funkin.util.MathUtil;

class PreferencesMenu extends Page
{
  inline static final DESC_BG_OFFSET_X = 15.0;
  inline static final DESC_BG_OFFSET_Y = 15.0;
  static var DESC_TEXT_WIDTH:Null<Float>;

  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;
  var preferenceDesc:Array<String> = [];

  var menuCamera:FlxCamera;
  var camFollow:FlxObject;

  var descText:FlxText;
  var descTextBG:FlxSprite;

  public function new()
  {
    super();

    if (DESC_TEXT_WIDTH == null) DESC_TEXT_WIDTH = FlxG.width * 0.8;

    menuCamera = new FunkinCamera('prefMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;
    camera = menuCamera;

    add(items = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());

    descTextBG = new FlxSprite().makeGraphic(1, 1, 0x80000000);
    descTextBG.scrollFactor.set();
    descTextBG.antialiasing = false;
    descTextBG.active = false;

    descText = new FlxText(0, 0, 0, "Ass Text!!!", 26);
    descText.scrollFactor.set();
    descText.font = "VCR OSD Mono";
    descText.alignment = CENTER;
    descText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
    // descText.antialiasing = false;

    descTextBG.x = descText.x - DESC_BG_OFFSET_X;
    descTextBG.scale.x = descText.width + DESC_BG_OFFSET_X * 2;
    descTextBG.updateHitbox();

    add(descTextBG);
    add(descText);

    createPrefItems();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    camFollow.y = items.selectedItem.y;
    add(camFollow);

    menuCamera.follow(camFollow, null, Constants.DEFAULT_CAMERA_FOLLOW_RATE_MENU);
    menuCamera.deadzone.set(0, 280, menuCamera.width, 40);
    menuCamera.minScrollY = -30;

    var prevIndex = 0;
    var prevItem = items.selectedItem;
    items.onChange.add(function(selected) {
      camFollow.y = selected.y;

      prevItem.x = 120;
      selected.x = 150;

      var counterItem = preferenceItems.members[prevIndex];
      if (Std.isOfType(counterItem, CounterPreferenceItem)) counterItem.active = false;
      counterItem = preferenceItems.members[items.selectedIndex];
      if (Std.isOfType(counterItem, CounterPreferenceItem)) counterItem.active = true;

      final newDesc = preferenceDesc[items.selectedIndex];
      final showDesc = (newDesc != null && newDesc.length != 0);
      descText.visible = descTextBG.visible = showDesc;
      if (showDesc)
      {
        descText.text = newDesc;
        descText.fieldWidth = descText.width > DESC_TEXT_WIDTH ? DESC_TEXT_WIDTH : 0;
        descText.screenCenter(X).y = FlxG.height * 0.85 - descText.height * 0.5;

        descTextBG.x = descText.x - DESC_BG_OFFSET_X;
        descTextBG.y = descText.y - DESC_BG_OFFSET_Y;
        descTextBG.scale.set(descText.width + DESC_BG_OFFSET_X * 2, descText.height + DESC_BG_OFFSET_Y * 2);
        descTextBG.updateHitbox();
      }

      prevIndex = items.selectedIndex;
      prevItem = selected;
    });
    items.selectItem(items.selectedIndex);
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createPrefItems():Void
  {
    createPrefItemCheckbox('Naughtyness', 'Toggle displaying raunchy content', function(value:Bool):Void {
      Preferences.naughtyness = value;
    }, Preferences.naughtyness);

    createPrefItemCheckbox('Downscroll', 'Enable to make notes move downwards', function(value:Bool):Void {
      Preferences.downscroll = value;
    }, Preferences.downscroll);

    createPrefItemCheckbox('Ghost Tapping', 'Disables ghost misses', function(value:Bool):Void {
      Preferences.ghostTapping = value;
    }, Preferences.ghostTapping);

    #if !web
    // 'amogus sussy baka kill me please'
    createPrefItemCounter('Framerate', '', function(value:Int):Void {
      Preferences.framerate = value;
    }, Preferences.framerate, Constants.MIN_FRAMERATE, Constants.MAX_FRAMERATE);
    #end

    createPrefItemCheckbox('Flashing Lights', 'Disable to dampen flashing effects', function(value:Bool):Void {
      Preferences.flashingLights = value;
    }, Preferences.flashingLights);

    createPrefItemCheckbox('Camera Zooming on Beat', 'Disable to stop the camera bouncing to the song', function(value:Bool):Void {
      Preferences.zoomCamera = value;
    }, Preferences.zoomCamera);

    createPrefItemCheckbox('Debug Display', 'Enable to show FPS and other debug stats', function(value:Bool):Void {
      Preferences.debugDisplay = value;
    }, Preferences.debugDisplay);

    createPrefItemCheckbox('Auto Pause', 'Automatically pause the game when it loses focus', function(value:Bool):Void {
      Preferences.autoPause = value;
    }, Preferences.autoPause);
  }

  function createPrefItemCheckbox(prefName:String, prefDesc:String, onChange:Bool->Void, defaultValue:Bool):Void
  {
    final posY = 120 * items.length;
    var checkbox:CheckboxPreferenceItem = new CheckboxPreferenceItem(0, posY, defaultValue);

    items.createItem(120, posY + 30, prefName, AtlasFont.BOLD, () -> onChange(checkbox.currentValue = !checkbox.currentValue), true);

    preferenceItems.add(checkbox);
    preferenceDesc.push(prefDesc);
  }

  function createPrefItemCounter(prefName:String, prefDesc:String, onChange:Int->Void, defaultValue:Int, minValue:Int, maxValue:Int, step:Int = 1):Void
  {
    final posY = 120 * items.length;
    final counter = new CounterPreferenceItem(16, posY + 52, defaultValue, minValue, maxValue, onChange);
    counter.ID = items.length;
    counter.active = false;

    items.createItem(120, posY + 30, prefName, AtlasFont.BOLD, null, true);

    preferenceItems.add(counter);
    preferenceDesc.push(prefDesc);
  }
}

class CheckboxPreferenceItem extends FlxSprite
{
  public var currentValue(default, set):Bool;

  public function new(x:Float, y:Float, defaultValue:Bool = false)
  {
    super(x, y);

    frames = Paths.getSparrowAtlas('checkboxThingie');
    animation.addByPrefix('static', 'Check Box unselected', 24, false);
    animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

    setGraphicSize(width * 0.7);
    updateHitbox();

    this.currentValue = defaultValue;
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    switch (animation.curAnim.name)
    {
      case 'static':
        offset.set();
      case 'checked':
        offset.set(17, 70);
    }
  }

  function set_currentValue(value:Bool):Bool
  {
    if (value)
    {
      animation.play('checked', true);
    }
    else
    {
      animation.play('static');
    }

    return currentValue = value;
  }
}

class CounterPreferenceItem extends FlxText
{
  inline static final MAX_HOLD_TIME = 0.6;
  inline static final HOLD_SPEED = 50.0;

  public var currentValue(default, set):Int;
  public var onChange:Int->Void;

  var minValue:Int;
  var maxValue:Int;
  var step:Int;

  var holdTimer = 0.0;
  var holdValue = 0.0;

  public function new(x:Float, y:Float, defaultValue:Int = 0, minValue:Int = 0, maxValue:Int = 1, onChange:Int->Void, step:Int = 1)
  {
    super(x, y, 0, "", 42);
    this.font = "VCR OSD Mono";
    this.alignment = RIGHT;
    this.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
    // this.antialiasing = false;

    this.step = step;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.onChange = onChange;
    this.currentValue = defaultValue;
  }

  // TODO: better code lmao
  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    final controls = PlayerSettings.player1.controls;
    final UI_LEFT = controls.UI_LEFT;
    final UI_RIGHT = controls.UI_RIGHT;
    final UI_LEFT_P = controls.UI_LEFT_P;
    final UI_RIGHT_P = controls.UI_RIGHT_P;

    if (UI_LEFT || UI_RIGHT)
    {
      if (UI_LEFT_P || UI_RIGHT_P)
      {
        currentValue += UI_LEFT_P ? -step : step;
        holdValue = currentValue;
      }

      holdTimer += elapsed;
      if (holdTimer >= MAX_HOLD_TIME)
      {
        holdValue = FlxMath.bound(holdValue + step * HOLD_SPEED * (UI_LEFT ? -elapsed : elapsed), minValue, maxValue);
        currentValue = Math.floor(holdValue);
      }
    }
    else
    {
      holdTimer = 0.0;
    }
  }

  function set_currentValue(value:Int):Int
  {
    value = MathUtil.boundInt(value, minValue, maxValue);
    if (currentValue != value)
    {
      this.text = '$value';
      currentValue = value;
      if (onChange != null) onChange(value);
    }
    return value;
  }
}
