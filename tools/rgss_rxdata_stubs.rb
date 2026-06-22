class Table
  attr_accessor :dim, :xsize, :ysize, :zsize, :data

  def self._load(data)
    obj = new
    obj.dim = data[0]
    obj.xsize = data[1]
    obj.ysize = data[2]
    obj.zsize = data[3]
    obj.data = data[4]
    obj
  end
end

class Tone
  attr_accessor :red, :green, :blue, :gray

  def self._load(data)
    obj = new
    obj.red = data[0]
    obj.green = data[1]
    obj.blue = data[2]
    obj.gray = data[3]
    obj
  end
end

class Color
  attr_accessor :red, :green, :blue, :alpha

  def self._load(data)
    obj = new
    obj.red = data[0]
    obj.green = data[1]
    obj.blue = data[2]
    obj.alpha = data[3]
    obj
  end
end

module RGSSRxdataStubs
  def self.install_marshal_loader(klass, attrs)
    klass.class_eval do
      class << self
        define_method(:_load) do |data|
          obj = new
          attrs.each_with_index do |attr, index|
            obj.send(attr.to_s + "=", data[index]) unless data[index].nil?
          end
          obj
        end
      end
    end
  end
end

module RPG
  class AudioFile
    attr_accessor :name, :volume, :pitch

    def initialize(name = "", volume = 100, pitch = 100)
      @name = name
      @volume = volume
      @pitch = pitch
    end
  end
  RGSSRxdataStubs.install_marshal_loader(AudioFile, [:name, :volume, :pitch])

  class Tone
    attr_accessor :red, :green, :blue, :gray

    def initialize(red = 0, green = 0, blue = 0, gray = 0)
      @red = red
      @green = green
      @blue = blue
      @gray = gray
    end
  end
  RGSSRxdataStubs.install_marshal_loader(Tone, [:red, :green, :blue, :gray])

  class MoveRoute
    attr_accessor :repeat, :skippable, :list

    def initialize(repeat = true, skippable = true)
      @repeat = repeat
      @skippable = skippable
      @list = []
    end
  end
  RGSSRxdataStubs.install_marshal_loader(MoveRoute, [:repeat, :skippable, :list])

  class MoveCommand
    attr_accessor :code, :parameters

    def initialize(code = 0, parameters = [])
      @code = code
      @parameters = parameters
    end
  end
  RGSSRxdataStubs.install_marshal_loader(MoveCommand, [:code, :parameters])

  class EventCommand
    attr_accessor :code, :indent, :parameters

    def initialize(code = 0, indent = 0, parameters = [])
      @code = code
      @indent = indent
      @parameters = parameters
    end
  end
  RGSSRxdataStubs.install_marshal_loader(EventCommand, [:code, :indent, :parameters])

  class Event
    class Page
      class Condition
        attr_accessor :switch1_valid, :switch2_valid, :variable_valid, :self_switch_valid,
          :switch1_id, :switch2_id, :variable_id, :variable_value, :self_switch_ch
      end
      RGSSRxdataStubs.install_marshal_loader(Condition, [
        :switch1_valid, :switch2_valid, :variable_valid, :self_switch_valid,
        :switch1_id, :switch2_id, :variable_id, :variable_value, :self_switch_ch
      ])

      class Graphic
        attr_accessor :tile_id, :character_name, :character_hue, :direction, :pattern, :opacity,
          :blend_type
      end
      RGSSRxdataStubs.install_marshal_loader(Graphic, [
        :tile_id, :character_name, :character_hue, :direction, :pattern, :opacity, :blend_type
      ])

      attr_accessor :condition, :graphic, :move_type, :move_speed, :move_frequency, :move_route,
        :walk_anime, :step_anime, :direction_fix, :through, :always_on_top, :trigger, :list
    end
    RGSSRxdataStubs.install_marshal_loader(Page, [
      :always_on_top, :condition, :direction_fix, :graphic, :list, :move_frequency, :move_route,
      :move_speed, :move_type, :step_anime, :through, :trigger, :walk_anime
    ])

    attr_accessor :id, :name, :x, :y, :pages
  end
  RGSSRxdataStubs.install_marshal_loader(Event, [:id, :name, :pages, :x, :y])

  class Map
    attr_accessor :tileset_id, :width, :height, :autoplay_bgm, :bgm, :autoplay_bgs, :bgs,
      :encounter_list, :encounter_step, :data, :events, :scroll_type, :expanded, :priority_type,
      :parallax_name, :parallax_x, :parallax_y, :parallax_loop_x, :parallax_loop_y, :fog_name,
      :fog_x, :fog_y, :fog_zoom, :fog_sx, :fog_sy, :fog_opacity, :fog_blend_type, :fog_hue,
      :fog_tone
  end
  RGSSRxdataStubs.install_marshal_loader(Map, [
    :autoplay_bgm, :autoplay_bgs, :bgm, :bgs, :data, :encounter_list, :encounter_step, :events,
    :expanded, :fog_blend_type, :fog_hue, :fog_name, :fog_opacity, :fog_sx, :fog_sy, :fog_tone,
    :fog_x, :fog_y, :fog_zoom, :height, :parallax_loop_x, :parallax_loop_y, :parallax_name,
    :parallax_x, :parallax_y, :priority_type, :scroll_type, :tileset_id, :width
  ])
end
