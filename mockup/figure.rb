class Figure
  def pvalues () [] end
  def Figure.ptypes () [] end
end

class SerialFigure < Figure
end 

class ParallelFigure < Figure
end 

# ________________________________________________________________

class Parameter
  # subclasses may override self.Default to give a default:
  def self.Default () nil end
end

class PTurn < Parameter; end
  class PTurnPlus270  < PTurn; def self.Default () +270 end end
  class PTurnPlus360  < PTurn; def self.Default () +360 end end
  class PTurnPlus540  < PTurn; def self.Default () +540 end end
  class PTurnMinus270 < PTurn; def self.Default () -270 end end
  class PTurnMinus360 < PTurn; def self.Default () -360 end end
  class PTurnMinus540 < PTurn; def self.Default () -540 end end


module ConcreteWho
  def self.Default () self end
end

class PWho                 < Parameter  ; end
  class P1Dancer           < PWho       ; end # {1},{3}
    class PGentlespoon1    < P1Dancer ; def self.Default () self end end
    class PGentlespoon2    < P1Dancer ; def self.Default () self end end
    class PLadle1          < P1Dancer ; def self.Default () self end end
    class PLadle2          < P1Dancer ; def self.Default () self end end
  class P2Dancers          < PWho       ; end # {2},{1},{1}
    class POnes            < P2Dancers; def self.Default () self end end
    class PTwos            < P2Dancers; def self.Default () self end end
    class PGentlespoons    < P2Dancers; def self.Default () self end end
    class PLadles          < P2Dancers; def self.Default () self end end
    class PFirstCorners    < P2Dancers; def self.Default () self end end # G1L2
    class PSecondCorners   < P2Dancers; def self.Default () self end end # G2L1
  class P4Dancers          < PWho       ; end # {4}
  class P2Pairs            < PWho       ; end # {2},{2}
    class PPartners        < P2Pairs  ; def self.Default () self end end
    class PNeighbors       < P2Pairs  ; def self.Default () self end end
    class PSameRoles       < P2Pairs  ; def self.Default () self end end # G1G2,L1L2



# ________________________________________________________________

class Turny < Figure
  def initialize(degrees=self.class.GetPTurn.Default)
    @degrees=degrees
  end
  # subclasses implement self.GetPTurn for defaulting
  def pvalues ()
    super << @degrees
  end
  def self.ptypes ()
    super << self.GetPTurn
  end
end

# ________________________________________________________________




class Circle < Turny
  def self.GetPTurn ()
    PTurnPlus360
  end
end

class StarRight < Turny
  def self.GetPTurn ()
    PTurnPlus360
  end
end

class StarLeft < Turny
  def self.GetPTurn ()
    PTurnMinus360
  end
end

class Gyre < Turny
  def self.GetPTurn ()
    PTurnPlus360
  end
end
