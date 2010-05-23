require 'rexml/document'

class LineTree
  include REXML

  def initialize(lines)
    a = lines.split(/\r?\n|\r(?!\n)/)
    pattern = %r((\s+)?(.*))
    a.map!{|x| x.match(pattern).captures}

    new_a, history = [], []
    history << new_a
    build_tree(a, new_a, 0, history)
    @a = new_a
  end

  def to_a()
    @a
  end

  def to_xml()
    d = REXML::Formatters::Default.new
    doc = Document.new '<root/>'
    scan_line doc.root, @a       
    d.write(XPath.first(doc.root, '*'), out='')
    out
  end

  private

  def build_tree(a, new_a, prev_indent, history=[])
    if a.length > 0 then
      x = a.shift
      n = x.shift
      cur_indent = n ? n.length : 0
      indent, xr = build_branch(a, new_a, cur_indent, prev_indent, x, history )

      if xr then
        cur_indent, xr = build_branch(a, history[-1] || new_a, indent, prev_indent, xr, history ) 
        return [cur_indent, xr] if xr
      end
    end
  end

  def build_branch(a, new_a, cur_indent, prev_indent, x, history=[])
    if cur_indent > prev_indent then
      new_a = history[-1]
      new_inner_a = [x]
      new_a << new_inner_a
      history << new_inner_a
      build_tree(a, history[-2], cur_indent, history)
    elsif cur_indent == prev_indent then
      history.pop unless history.length <= 1
      new_a = history[-1] if history[-1]
      new_inner_a = [x]
      new_a << new_inner_a
      history << new_inner_a
      build_tree(a, new_inner_a, cur_indent, history)
    else
      # revert to the earlier new_a
      history.pop unless history.length <= 1
      return [cur_indent, x]
    end
  end

  def scan_line(node, a)
    a.each do |x|
      name, text = x.shift.compact
      element = Element.new(name.gsub(/^[^a-zA-Z][^a-zA-Z0-9]?/,'')).add_text text
      scan_line(element, x) unless x.empty?
      node.add element
    end
  end

end
