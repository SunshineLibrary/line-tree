#!/usr/bin/env ruby


class LineTree
  attr_reader :to_a

  def initialize(lines) @to_a = scan_shift(lines)  end
  def to_xml(options={})
    require 'rexle' if not defined? Rexle
    Rexle.new(scan_a(*@to_a)).xml(options)
  end

  private

  def scan_shift(lines)
    a = lines.split(/(?=^\S+)/)

    a.map do |x|
      rlines = x.split(/[\r\n]+/)
      label = [rlines.shift]
      new_lines = rlines.map{|x1| x1[2..-1] }

      if new_lines.length > 1 then
        label + scan_shift(new_lines.join("\n"))
      else
        new_lines.length > 0 ? label + [new_lines] : label
      end
    end
  end

  def scan_a(a)
    r = a.shift.match(/('[^']+[']|[^\s]+)\s*(\{[^\}]+\})?\s*(.*)/).captures.values_at(0,-1,1)

    r[-1] = get_attributes(r.last) if r.last
    a.map {|x| r << scan_a(x.clone) } if a.is_a? Array
    r
  end

  def get_attributes(s)
    a = s[/{(.*)}/,1].split(',').map do |attr|
      attr.match(/\s*([^:=]+)[:=]\s*['"]*([a-zA-Z0-9\(\);\-\/:\.]*)/).captures
    end

    Hash[*a.flatten]
  end

end
