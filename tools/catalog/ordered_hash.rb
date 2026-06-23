kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

class OrderedHash < Hash
  def initialize
    @keys = []
    super
  end

  def keys
    @keys.clone
  end

  def []=(key, value)
    oldvalue = self[key]
    if !oldvalue && value
      @keys.push(key)
    elsif !value
      @keys |= []
      @keys -= [key]
    end
    super(key, value)
  end

  def self._load(string)
    result = new
    keysvalues = Marshal.load(string)
    keys = keysvalues[0]
    values = keysvalues[1]
    for index in 0...keys.length
      result[keys[index]] = values[index]
    end
    result
  end

  def _dump(_depth = 100)
    values = []
    keys.each do |key|
      values << self[key]
    end
    Marshal.dump([keys, values])
  end
end

