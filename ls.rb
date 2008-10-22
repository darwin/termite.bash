class Bashls < TermiteAPI::Soldier
  def reset()
    @current_path = nil
    @mode = 0
  end

  def eat(original, current)
    if @mode==0
      md = original.match(/^\[((\/|~)[^\/ "'\]]*){1,}\] ls( |$)/)
      return false unless md
      md = original.match(/\[([^\]]+)\] ls/)
      o = md.offset(1)
      file = original[o[0]..o[1]-1]
      efile = File.expand_path(file)
      return false unless File.exists?(efile)
      @current_path = efile
      @mode = 1
      $mound.emit_code(current+"<br/>")
      return true
    end
    
    if @mode==1
      md1 = original.match(/^\[((\/|~)[^\/ "'\]]*){1,}\]/)
      md2 = original.match(/^ls:/)
      
      if md1 or md2
        @mode = 0
        return false
      end
      
      res = ""
      s = original+" "
      while s.strip!="" do
        md = s.match(/([^\s]*)[^\w]*/)
        if md
          o = md.offset(0)
          res += current[0...o[0]] || ""
          g = s[o[0]...o[1]]
          f = g.strip
          file = File.join(@current_path, f)
          file = file[0...-1] if file[-1].chr=='*'
          style = ""
          style = "style='color:#080'" if File.directory?(file)
          style = "style='color:#999'" unless File.exists?(file)
          res += "<a #{style} href=\"txmt://open?url=file://#{file}&line=1&column=2\">#{f}</a>"
          res += g[f.size..-1] if f.size!=g.size
          s = md.post_match
          next
        end
        res += s || ""
        s = ""
      end
      $mound.emit_code(res+"<br/>")
      return true
    end
  end
end

$mound.soldiers << Bashls.new