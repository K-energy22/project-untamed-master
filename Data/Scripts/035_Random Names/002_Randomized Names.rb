#Name Randomizer
#Text Entry UI modified by Gardenette
#===============================================================================
#
#===============================================================================
class Window_CharacterEntry
  XSIZE = 13
  YSIZE = 4

  def initialize(charset, viewport = nil)
    @viewport = viewport
    @charset = charset
    @othercharset = ""
    super(0, 96, 480, 192)
    colors = getDefaultTextColors(self.windowskin)
    self.baseColor = colors[0]
    self.shadowColor = colors[1]
    self.columns = XSIZE
    refresh
  end

  def setOtherCharset(value)
    @othercharset = value.clone
    refresh
  end

  def setCharset(value)
    @charset = value.clone
    refresh
  end

  def character
    if self.index < 0 || self.index >= @charset.length
      return ""
    else
      return @charset[self.index]
    end
  end

  def command
    return -1 if self.index == @charset.length
    return -2 if self.index == @charset.length + 1
    return -3 if self.index == @charset.length + 2
    return self.index
  end

  def itemCount
    return @charset.length + 3
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    if index == @charset.length # -1
      pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, "[ ]",
                       self.baseColor, self.shadowColor)
    elsif index == @charset.length + 1 # -2
      pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, @othercharset,
                       self.baseColor, self.shadowColor)
    elsif index == @charset.length + 2 # -3
      pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, _INTL("OK"),
                       self.baseColor, self.shadowColor)
    else
      pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, @charset[index],
                       self.baseColor, self.shadowColor)
    end
  end
end



#===============================================================================
# Text entry screen - free typing.
#===============================================================================
class PokemonEntryScene < SpriteWindow_Base
  @@Characters = [
    [("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").scan(/./), "[*]"],
    [("0123456789   !@\#$%^&*()   ~`-_+={}[]   :;'\"<>,.?/   ").scan(/./), "[A]"]
  ]
  USEKEYBOARD = true
  
  #set to true if you want names picked from a list of possible
  #names (RandomNameList)
  #set to false if you want truly randomly generated names
  RANDOM_FROM_LIST = true

  def pbStartScene(helptext, minlength, maxlength, initialText, subject = 0, pokemon = nil)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    if USEKEYBOARD
      @sprites["entry"] = Window_TextEntry_Keyboard.new(
        initialText, 0, 0, 400 - 112, 96, helptext, true
      )
      Input.text_input = true
    else
      @sprites["entry"] = Window_TextEntry.new(initialText, 0, 0, 400, 96, helptext, true)
    end
    @sprites["entry"].x = (Graphics.width / 2) - (@sprites["entry"].width / 2) + 32
    @sprites["entry"].viewport = @viewport
    @sprites["entry"].visible = true
    @minlength = minlength
    @maxlength = maxlength
    @symtype = 0
    @sprites["entry"].maxlength = maxlength
    if !USEKEYBOARD
      @sprites["entry2"] = Window_CharacterEntry.new(@@Characters[@symtype][0])
      @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
      @sprites["entry2"].viewport = @viewport
      @sprites["entry2"].visible = true
      @sprites["entry2"].x = (Graphics.width / 2) - (@sprites["entry2"].width / 2)
    end
    if minlength == 0
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel.\nPress F4 to randomize."),
        32, Graphics.height - 138, Graphics.width - 64, 128, @viewport
      )
    else
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel.\nPress F4 to randomize."),
        32, Graphics.height - 138, Graphics.width - 64, 128, @viewport
      )
    end
    @sprites["helpwindow"].letterbyletter = false
    @sprites["helpwindow"].viewport = @viewport
    #@sprites["helpwindow"].visible = USEKEYBOARD
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].baseColor = Color.new(16, 24, 32)
    @sprites["helpwindow"].shadowColor = Color.new(168, 184, 184)
    
    #add empty bitmap to show FORMATTED text on
    @sprites["textBitmap"] = Sprite.new(@viewport)
    @sprites["textBitmap"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["textBitmap"].viewport = @viewport
    @sprites["textBitmap"].z = 99999
    @sprites["textBitmap"].visible = USEKEYBOARD
    
    baseColor = Color.new(16, 24, 32)
    shadowColor = Color.new(168, 184, 184)
    
    message = _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel.\nPress <c3=E82010,F8A8B8>F4</c3> to randomize.")
    #drawFormattedTextEx(bitmap,x,y,width,text,basecolor,shadowncolor,lineheight)
    #@sprites["textBitmap"].bitmap.font.name = MessageConfig.pbGetSystemFontName
    pbSetSystemFont(@sprites["textBitmap"].bitmap)
    drawFormattedTextEx(@sprites["textBitmap"].bitmap,Graphics.width / 2 - 436 / 2,Graphics.height-112,436,message,baseColor,shadowColor,lineheight=32)
    
    
    addBackgroundPlane(@sprites, "background", "Naming/bg_2", @viewport)
    case subject
    when 1   # Player
      meta = GameData::PlayerMetadata.get($player.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x = 33 * 2
        @sprites["shadow"].y = 32 * 2
        filename = pbGetPlayerCharset(meta.walk_charset, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = (44 * 2) - (charwidth / 8)
        @sprites["subject"].y = (38 * 2) - (charheight / 4)
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x = 33 * 2
        @sprites["shadow"].y = 32 * 2
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::CENTER)
        @sprites["subject"].x = 88
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos = []
        if pokemon.male?
          textpos.push([_INTL("♂"), 0, 6, false, Color.new(0, 128, 248), Color.new(168, 184, 184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"), 0, 6, false, Color.new(248, 24, 24), Color.new(168, 184, 184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
      @sprites["shadow"].x = 33 * 2
      @sprites["shadow"].y = 32 * 2
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = (44 * 2) - (charwidth / 8)
      @sprites["subject"].y = (38 * 2) - (charheight / 4)
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = "Graphics/Pictures/Naming/icon_storage"
      @sprites["subject"].animspeed = 4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = (44 * 2) - (charwidth / 8)
      @sprites["subject"].y = (26 * 2) - (charheight / 2)
    end
    pbFadeInAndShow(@sprites)
  end
  
  def pbRandomName
    if RANDOM_FROM_LIST
      loop do
        @randomName = RandomNameList::RANDOM_NAMES[rand(RandomNameList::RANDOM_NAMES.length)]
        if @randomName.length > Settings::MAX_PLAYER_NAME_SIZE
           #go through loop again to get another name
        else
           break
        end
      end
    else
      @randomName = getRandomNameEx(0, nil, 1, Settings::MAX_PLAYER_NAME_SIZE)
    end
      @sprites["entry"].text = ""
      for i in 0...@randomName.length
        @sprites["entry"].insert(@randomName[i])
      end
  end

  def pbEntry1
    ret = ""
    loop do
      Graphics.update
      Input.update
      
      #if you press the designated button, randomize name
      if Input.triggerex?(:F4)
        pbRandomName
      end
      
      if Input.triggerex?(:ESCAPE) && @minlength == 0
        ret = ""
        break
      elsif Input.triggerex?(:RETURN) && @sprites["entry"].text.length >= @minlength
        ret = @sprites["entry"].text
        break
      end
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["subject"]&.update
    end
    Input.update
    return ret
  end

  def pbEntry2
    ret = ""
    loop do
      Graphics.update
      Input.update
      
      #if you press the designated button, randomize name
      if Input.triggerex?(:F4)
        pbRandomName
      end
      
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["entry2"].update
      @sprites["subject"]&.update
      if Input.trigger?(Input::USE)
        index = @sprites["entry2"].command
        if index == -3 # Confirm text
          ret = @sprites["entry"].text
          if ret.length < @minlength || ret.length > @maxlength
            pbPlayBuzzerSE
          else
            pbPlayDecisionSE
            break
          end
        elsif index == -1 # Insert a space
          if @sprites["entry"].insert(" ")
            pbPlayDecisionSE
          else
            pbPlayBuzzerSE
          end
        elsif index == -2 # Change character set
          pbPlayDecisionSE
          @symtype += 1
          @symtype = 0 if @symtype >= @@Characters.length
          @sprites["entry2"].setCharset(@@Characters[@symtype][0])
          @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
        else # Insert given character
          if @sprites["entry"].insert(@sprites["entry2"].character)
            pbPlayDecisionSE
          else
            pbPlayBuzzerSE
          end
        end
        next
      end
    end
    Input.update
    return ret
  end

  def pbEntry
    return USEKEYBOARD ? pbEntry1 : pbEntry2
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Input.text_input = false if USEKEYBOARD
  end
end



#===============================================================================
# Text entry screen - arrows to select letter.
#===============================================================================
class PokemonEntryScene2
  
  @@Characters = [
    [("ABCDEFGHIJ ,." + "KLMNOPQRST '-" + "UVWXYZ     ♂♀" + "             " + "0123456789   ").scan(/./), _INTL("UPPER")],
    [("abcdefghij ,." + "klmnopqrst '-" + "uvwxyz     ♂♀" + "             " + "0123456789   ").scan(/./), _INTL("lower")],
    [("ÀÁÂÄÃàáâäã Ææ" + "ÈÉÊË èéêë  Çç" + "ÌÍÎÏ ìíîï  Œœ" + "ÒÓÔÖÕòóôöõ Ññ" + "ÙÚÛÜ ùúûü  Ýý").scan(/./), _INTL("accents")],
    [(",.:;…•!?¡¿ ♂♀" + "“”‘’﴾﴿*~_^ ΡΚ" + "@\#&%+-×÷/= ΠΜ" + "◎○□△♠♥♦♣★✨  $" + "♈♌♒♐♩♪♫☽☾    ").scan(/./), _INTL("other")]
  ]
  ROWS    = 13
  COLUMNS = 5
  MODE1   = -7
  MODE2   = -6
  MODE3   = -5
  MODE4   = -4
  RANDOM  = -3
  BACK    = -2
  OK      = -1

  class NameEntryCursor
    def initialize(viewport)
      @sprite = Sprite.new(viewport)
      @cursortype = 0
      @cursor1 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_1")
      @cursor2 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_2")
      @cursor3 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_3")
      @cursor4 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_4")
      @cursorPos = 0
      updateInternal
    end

    def setCursorPos(value)
      @cursorPos = value
    end

    def updateCursorPos
      value = @cursorPos
      case value
      when PokemonEntryScene2::MODE1   # Upper case
        @sprite.x = 22
        @sprite.y = 116
        @cursortype = 1
      when PokemonEntryScene2::MODE2   # Lower case
        #@sprite.x = 106
        @sprite.x = 86
        @sprite.y = 116
        @cursortype = 1
      when PokemonEntryScene2::MODE3   # Accents
        #@sprite.x = 168
        @sprite.x = 150
        @sprite.y = 116
        @cursortype = 1
      when PokemonEntryScene2::MODE4   # Other symbols
        #@sprite.x = 230
        @sprite.x = 214
        @sprite.y = 116
        @cursortype = 1
      when PokemonEntryScene2::RANDOM   # Randomize button, added by Gardenette
        @sprite.x = 284
        @sprite.y = 116
        @cursortype = 3
      when PokemonEntryScene2::BACK   # Back
        @sprite.x = 330
        @sprite.y = 116
        @cursortype = 2
      when PokemonEntryScene2::OK   # OK
        @sprite.x = 408
        @sprite.y = 116
        @cursortype = 2
      else
        if value >= 0
          @sprite.x = 48 + (32 * (value % PokemonEntryScene2::ROWS))
          @sprite.y = 176 + (38 * (value / PokemonEntryScene2::ROWS))
          @cursortype = 0
        end
      end
    end

    def visible=(value)
      @sprite.visible = value
    end

    def visible
      @sprite.visible
    end

    def color=(value)
      @sprite.color = value
    end

    def color
      @sprite.color
    end

    def disposed?
      @sprite.disposed?
    end

    def updateInternal
      @cursor1.update
      @cursor2.update
      @cursor3.update
      @cursor4.update
      updateCursorPos
      case @cursortype
      when 0 then @sprite.bitmap = @cursor1.bitmap
      when 1 then @sprite.bitmap = @cursor2.bitmap
      when 2 then @sprite.bitmap = @cursor3.bitmap
      when 3 then @sprite.bitmap = @cursor4.bitmap
      end
    end

    def update
      updateInternal
    end

    def dispose
      @cursor1.dispose
      @cursor2.dispose
      @cursor3.dispose
      @cursor4.dispose
      @sprite.dispose
    end
  end

  def pbRandomName
    if PokemonEntryScene::RANDOM_FROM_LIST
      loop do
        @randomName = RandomNameList::RANDOM_NAMES[rand(RandomNameList::RANDOM_NAMES.length)]
        if @randomName.length > Settings::MAX_PLAYER_NAME_SIZE
           #go through loop again to get another name
        else
           break
        end
      end
    else
      @randomName = getRandomNameEx(0, nil, 1, Settings::MAX_PLAYER_NAME_SIZE)
    end
    @helper = CharacterEntryHelper.new("")
    @helper.insert(@randomName)
    @helper.cursor = @randomName.length
  end

  def pbStartScene(helptext, minlength, maxlength, initialText, subject = 0, pokemon = nil)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @helptext = helptext
    @helper = CharacterEntryHelper.new(initialText)
    # Create bitmaps
    @bitmaps = []
    @@Characters.length.times do |i|
      @bitmaps[i] = AnimatedBitmap.new(sprintf("Graphics/Pictures/Naming/overlay_tab_#{i + 1}"))
      b = @bitmaps[i].bitmap.clone
      pbSetSystemFont(b)
      textPos = []
      COLUMNS.times do |y|
        ROWS.times do |x|
          pos = (y * ROWS) + x
          textPos.push([@@Characters[i][0][pos], 44 + (x * 32), 24 + (y * 38), 2,
                        Color.new(16, 24, 32), Color.new(160, 160, 160)])
        end
      end
      pbDrawTextPositions(b, textPos)
      @bitmaps[@@Characters.length + i] = b
    end
    underline_bitmap = BitmapWrapper.new(24, 6)
    underline_bitmap.fill_rect(2, 2, 22, 4, Color.new(168, 184, 184))
    underline_bitmap.fill_rect(0, 0, 22, 4, Color.new(16, 24, 32))
    @bitmaps.push(underline_bitmap)
    # Create sprites
    @sprites = {}
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Naming/bg")
    case subject
    when 1   # Player
      meta = GameData::PlayerMetadata.get($player.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        filename = pbGetPlayerCharset(meta.walk_charset, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = 88 - (charwidth / 8)
        @sprites["subject"].y = 76 - (charheight / 4)
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::CENTER)
        @sprites["subject"].x = 88
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos = []
        if pokemon.male?
          textpos.push([_INTL("♂"), 0, 6, false, Color.new(0, 128, 248), Color.new(168, 184, 184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"), 0, 6, false, Color.new(248, 24, 24), Color.new(168, 184, 184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
      @sprites["shadow"].x = 66
      @sprites["shadow"].y = 64
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 76 - (charheight / 4)
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = "Graphics/Pictures/Naming/icon_storage"
      @sprites["subject"].animspeed = 4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 52 - (charheight / 2)
    end
    @sprites["bgoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay
    @blanks = []
    @mode = 0
    @minlength = minlength
    @maxlength = maxlength
    @maxlength.times { |i|
      @sprites["blank#{i}"] = Sprite.new(@viewport)
      @sprites["blank#{i}"].x = 160 + (24 * i)
      @sprites["blank#{i}"].bitmap = @bitmaps[@bitmaps.length - 1]
      @blanks[i] = 0
    }
    @sprites["bottomtab"] = Sprite.new(@viewport)   # Current tab
    @sprites["bottomtab"].x = 22
    @sprites["bottomtab"].y = 162
    @sprites["bottomtab"].bitmap = @bitmaps[@@Characters.length]
    @sprites["toptab"] = Sprite.new(@viewport)   # Next tab
    @sprites["toptab"].x = 22 - 504
    @sprites["toptab"].y = 162
    @sprites["toptab"].bitmap = @bitmaps[@@Characters.length + 1]
    @sprites["controls"] = IconSprite.new(0, 0, @viewport)
    #@sprites["controls"].x = 16
    @sprites["controls"].x = 0
    @sprites["controls"].y = 96
    @sprites["controls"].setBitmap(_INTL("Graphics/Pictures/Naming/overlay_controls"))
    @init = true
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay2
    @sprites["cursor"] = NameEntryCursor.new(@viewport)
    @cursorpos = 0
    @refreshOverlay = true
    @sprites["cursor"].setCursorPos(@cursorpos)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdateOverlay
    @refreshOverlay = true
  end

  def pbDoUpdateOverlay2
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    #modeIcon = [[_INTL("Graphics/Pictures/Naming/icon_mode"), 44 + (@mode * 62), 120, @mode * 60, 0, 60, 44]]
    modeIcon = [[_INTL("Graphics/Pictures/Naming/icon_mode"), 26 + (@mode * 64), 120, @mode * 60, 0, 60, 44]]
    pbDrawImagePositions(overlay, modeIcon)
  end

  def pbDoUpdateOverlay
    return if !@refreshOverlay
    @refreshOverlay = false
    bgoverlay = @sprites["bgoverlay"].bitmap
    bgoverlay.clear
    pbSetSystemFont(bgoverlay)
    textPositions = [
      [@helptext, 160, 18, false, Color.new(16, 24, 32), Color.new(168, 184, 184)]
    ]
    chars = @helper.textChars
    x = 166
    chars.each do |ch|
      textPositions.push([ch, x, 54, false, Color.new(16, 24, 32), Color.new(168, 184, 184)])
      x += 24
    end
    pbDrawTextPositions(bgoverlay, textPositions)
  end

  def pbChangeTab(newtab = @mode + 1)
    pbSEPlay("GUI naming tab swap start")
    @sprites["cursor"].visible = false
    @sprites["toptab"].bitmap = @bitmaps[(newtab % @@Characters.length) + @@Characters.length]
    # Move bottom (old) tab down off the screen, and move top (new) tab right
    # onto the screen
    deltaX = 48 * 20 / Graphics.frame_rate
    deltaY = 24 * 20 / Graphics.frame_rate
    loop do
      if @sprites["bottomtab"].y < 414
        @sprites["bottomtab"].y += deltaY
        @sprites["bottomtab"].y = 414 if @sprites["bottomtab"].y > 414
      end
      if @sprites["toptab"].x < 22
        @sprites["toptab"].x += deltaX
        @sprites["toptab"].x = 22 if @sprites["toptab"].x > 22
      end
      Graphics.update
      Input.update
      pbUpdate
      break if @sprites["toptab"].x >= 22 && @sprites["bottomtab"].y >= 414
    end
    # Swap top and bottom tab around
    @sprites["toptab"].x, @sprites["bottomtab"].x = @sprites["bottomtab"].x, @sprites["toptab"].x
    @sprites["toptab"].y, @sprites["bottomtab"].y = @sprites["bottomtab"].y, @sprites["toptab"].y
    @sprites["toptab"].bitmap, @sprites["bottomtab"].bitmap = @sprites["bottomtab"].bitmap, @sprites["toptab"].bitmap
    Graphics.update
    Input.update
    pbUpdate
    # Set the current mode
    @mode = newtab % @@Characters.length
    # Set the top tab up to be the next tab
    newtab = @bitmaps[((@mode + 1) % @@Characters.length) + @@Characters.length]
    @sprites["cursor"].visible = true
    @sprites["toptab"].bitmap = newtab
    @sprites["toptab"].x = 22 - 504
    @sprites["toptab"].y = 162
    pbSEPlay("GUI naming tab swap end")
    pbDoUpdateOverlay2
  end

  def pbUpdate
    @@Characters.length.times do |i|
      @bitmaps[i].update
    end
    if @init || Graphics.frame_count % 5 == 0
      @init = false
      cursorpos = @helper.cursor
      cursorpos = @maxlength - 1 if cursorpos >= @maxlength
      cursorpos = 0 if cursorpos < 0
      @maxlength.times { |i|
        @blanks[i] = (i == cursorpos) ? 1 : 0
        @sprites["blank#{i}"].y = [78, 82][@blanks[i]]
      }
    end
    pbDoUpdateOverlay
    pbUpdateSpriteHash(@sprites)
  end

  def pbColumnEmpty?(m)
    return false if m >= ROWS - 1
    chset = @@Characters[@mode][0]
    COLUMNS.times do |i|
      return false if chset[(i * ROWS) + m] != " "
    end
    return true
  end

  def wrapmod(x, y)
    result = x % y
    result += y if result < 0
    return result
  end

  def pbMoveCursor
    oldcursor = @cursorpos
    cursordiv = @cursorpos / ROWS   # The row the cursor is in
    cursormod = @cursorpos % ROWS   # The column the cursor is in
    cursororigin = @cursorpos - cursormod
    if Input.repeat?(Input::LEFT)
      if @cursorpos < 0   # Controls
        @cursorpos -= 1
        @cursorpos = OK if @cursorpos < MODE1
      else
        loop do
          cursormod = wrapmod(cursormod - 1, ROWS)
          @cursorpos = cursororigin + cursormod
          break unless pbColumnEmpty?(cursormod)
        end
      end
    elsif Input.repeat?(Input::RIGHT)
      if @cursorpos < 0   # Controls
        @cursorpos += 1
        @cursorpos = MODE1 if @cursorpos > OK
      else
        loop do
          cursormod = wrapmod(cursormod + 1, ROWS)
          @cursorpos = cursororigin + cursormod
          break unless pbColumnEmpty?(cursormod)
        end
      end
    elsif Input.repeat?(Input::UP)
      if @cursorpos < 0         # Controls
        case @cursorpos
        when MODE1 then @cursorpos = ROWS * (COLUMNS - 1)
        when MODE2 then @cursorpos = (ROWS * (COLUMNS - 1)) + 2
        when MODE3 then @cursorpos = (ROWS * (COLUMNS - 1)) + 4
        when MODE4 then @cursorpos = (ROWS * (COLUMNS - 1)) + 6
        when RANDOM then @cursorpos = (ROWS * (COLUMNS - 1)) + 7
        when BACK  then @cursorpos = (ROWS * (COLUMNS - 1)) + 9
        when OK    then @cursorpos = (ROWS * (COLUMNS - 1)) + 11
        end
      elsif @cursorpos < ROWS   # Top row of letters
        case @cursorpos
        when 0, 1     then @cursorpos = MODE1
        when 2, 3     then @cursorpos = MODE2
        when 4, 5     then @cursorpos = MODE3
        when 6        then @cursorpos = MODE4
        when 7        then @cursorpos = RANDOM
        when 8, 9, 10 then @cursorpos = BACK
        when 11, 12   then @cursorpos = OK
        end
      else
        cursordiv = wrapmod(cursordiv - 1, COLUMNS)
        @cursorpos = (cursordiv * ROWS) + cursormod
      end
    elsif Input.repeat?(Input::DOWN)
      if @cursorpos < 0                      # Controls
        case @cursorpos
        when MODE1 then @cursorpos = 0
        when MODE2 then @cursorpos = 2
        when MODE3 then @cursorpos = 4
        when MODE4 then @cursorpos = 6
        when RANDOM then @cursorpos = 7
        when BACK  then @cursorpos = 9
        when OK    then @cursorpos = 11
        end
      elsif @cursorpos >= ROWS * (COLUMNS - 1)   # Bottom row of letters
        case cursormod
        when 0, 1     then @cursorpos = MODE1
        when 2, 3     then @cursorpos = MODE2
        when 4, 5     then @cursorpos = MODE3
        when 6        then @cursorpos = MODE4
        when 7        then @cursorpos = RANDOM
        when 8, 9, 10 then @cursorpos = BACK
        else               @cursorpos = OK
        end
      else
        cursordiv = wrapmod(cursordiv + 1, COLUMNS)
        @cursorpos = (cursordiv * ROWS) + cursormod
      end
    end
    if @cursorpos != oldcursor   # Cursor position changed
      @sprites["cursor"].setCursorPos(@cursorpos)
      pbPlayCursorSE
      return true
    end
    return false
  end

  def pbEntry
    ret = ""
    loop do
      Graphics.update
      Input.update
      pbUpdate
      
      #if you press the designated button, randomize name
      if Input.triggerex?(:F4)
        pbRandomName
        pbSEPlay("GUI sel cursor")
        pbUpdateOverlay
      end
      
      next if pbMoveCursor
      if Input.trigger?(Input::SPECIAL)
        pbChangeTab
      elsif Input.trigger?(Input::ACTION)
        @cursorpos = OK
        @sprites["cursor"].setCursorPos(@cursorpos)
      elsif Input.trigger?(Input::BACK)
        @helper.delete
        pbPlayCancelSE
        pbUpdateOverlay
      elsif Input.trigger?(Input::USE)
        case @cursorpos
        when BACK   # Backspace
          @helper.delete
          pbPlayCancelSE
          pbUpdateOverlay
        when RANDOM   # Randomize the name
          pbRandomName
          pbSEPlay("GUI sel cursor")
          pbUpdateOverlay
        when OK     # Done
          pbSEPlay("GUI naming confirm")
          if @helper.length >= @minlength
            ret = @helper.text
            break
          end
        when MODE1
          pbChangeTab(0) if @mode != 0
        when MODE2
          pbChangeTab(1) if @mode != 1
        when MODE3
          pbChangeTab(2) if @mode != 2
        when MODE4
          pbChangeTab(3) if @mode != 3
        else
          cursormod = @cursorpos % ROWS
          cursordiv = @cursorpos / ROWS
          charpos = (cursordiv * ROWS) + cursormod
          chset = @@Characters[@mode][0]
          if @helper.length >= @maxlength
            @helper.delete
          end
          @helper.insert(chset[charpos])
          pbPlayCursorSE
          if @helper.length >= @maxlength
            @cursorpos = OK
            @sprites["cursor"].setCursorPos(@cursorpos)
          end
          pbUpdateOverlay
          # Auto-switch to lowercase letters after the first uppercase letter is selected
          pbChangeTab(1) if @mode == 0 && @helper.cursor == 1
        end
      end
    end
    Input.update
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    @bitmaps.each do |bitmap|
      bitmap&.dispose
    end
    @bitmaps.clear
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



#===============================================================================
#
#===============================================================================
class PokemonEntry
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(helptext, minlength, maxlength, initialText, mode = -1, pokemon = nil)
    @scene.pbStartScene(helptext, minlength, maxlength, initialText, mode, pokemon)
    ret = @scene.pbEntry
    @scene.pbEndScene
    return ret
  end
end



#===============================================================================
#
#===============================================================================
def pbEnterText(helptext, minlength, maxlength, initialText = "", mode = 0, pokemon = nil, nofadeout = false)
  ret = ""
  if ($PokemonSystem.textinput == 1 rescue false)   # Keyboard
    pbFadeOutIn(99999, nofadeout) {
      sscene = PokemonEntryScene.new
      sscreen = PokemonEntry.new(sscene)
      ret = sscreen.pbStartScreen(helptext, minlength, maxlength, initialText, mode, pokemon)
    }
  else   # Cursor
    pbFadeOutIn(99999, nofadeout) {
      sscene = PokemonEntryScene2.new
      sscreen = PokemonEntry.new(sscene)
      ret = sscreen.pbStartScreen(helptext, minlength, maxlength, initialText, mode, pokemon)
    }
  end
  return ret
end

def pbEnterPlayerName(helptext, minlength, maxlength, initialText = "", nofadeout = false)
  return pbEnterText(helptext, minlength, maxlength, initialText, 1, nil, nofadeout)
end

def pbEnterPokemonName(helptext, minlength, maxlength, initialText = "", pokemon = nil, nofadeout = false)
  return pbEnterText(helptext, minlength, maxlength, initialText, 2, pokemon, nofadeout)
end

def pbEnterNPCName(helptext, minlength, maxlength, initialText = "", id = 0, nofadeout = false)
  return pbEnterText(helptext, minlength, maxlength, initialText, 3, id, nofadeout)
end

def pbEnterBoxName(helptext, minlength, maxlength, initialText = "", nofadeout = false)
  return pbEnterText(helptext, minlength, maxlength, initialText, 4, nil, nofadeout)
end