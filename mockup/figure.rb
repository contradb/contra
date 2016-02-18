class Figure
  def pvalues () [] end
  def self.ptypes () [] end
  def self.pdefaults () [] end
end

class SerialFigure < Figure
end 

class ParallelFigure < Figure
end 

# ________________________________________________________________

class Parameter
end

class PTurn < Parameter;
end
# clockwise is positive so that circle-right is dealing with positive
# quantities and swings go in the positive direction.




# PWho says which dancers are acted on by the other parameters.
# Semantics are set by Figures, but these establish grouping and for
# those parameters. Consider the allemande orbit figure - in some ways
# the most complicated figure. It takes three parameters:
# some subclass of P22Dancers, PTurnMinus540 and PTurnPlus180.
# The first PTurn is the amount of turning for the inner couple,
# and the second PTurn is the turning for the
# outter couple. 
# P1Dancer subclasses could likewise be used to establish 3&1
# commands, like Lady1 into the center and be a bird, everybody else
# circle round. 

class PWho < Parameter; end
class FROGS < PWho; end
class PPairOrPairs < PWho; end
class P1Dancer       < PWho; end # {1},{3} (1-2 total commands)
class P2Dancers      < PPairOrPairs; end # {1},{3} (1-2 total commands)
class P2x2Dancers    < PPairOrPairs; end # {2&2}   (1 total command, sent to both, e.g. partner swing)
class P4Dancers      < PWho; end # {4}     (1 total command)
# these classes aren't exhaustive, consider the pathological figure
# Ones: swing, L2: spin around clockwise in place, G2 slide left.
# So if there is a user-request for that busy a figure: extend as needed. 

class PGentlespoon1  < P1Dancer    ; end
class PGentlespoon2  < P1Dancer    ; end
class PLadle1        < P1Dancer    ; end
class PLadle2        < P1Dancer    ; end
class POnes          < P2Dancers   ; end
class PTwos          < P2Dancers   ; end
class PGentlespoons  < P2Dancers   ; end
class PLadles        < P2Dancers   ; end
class PFirstCorners  < P2Dancers   ; end # G1L2
class PSecondCorners < P2Dancers   ; end # G2L1
class PPartners      < P2x2Dancers ; end
class PNeighbors     < P2x2Dancers ; end
class PSameRoles     < P2x2Dancers ; end # G1G2,L1L2

# ________________________________________________________________

## outdated section

# Interface TurningFigure < Figure
# * initialize takes PTurn
# * implement pvalues method: appends PTurn onto super
# * implement self.ptypes class method: appends self.pturn onto super
# * implement self.pdefaults class method: appends defaults/nil onto super

# Interface SubjectsFigure < Figure
# * initialize takes pwho, default value self.class.GetPSubjects.default???
# * implement pvalues method: appends PWho onto super
# * implement self.ptypes class method: appends self.GetPSubject onto super???
# * implement self.pdefaults class method: appends defaults/nil onto super

# ________________________________________________________________




class VariableTurnHelperFigure < Figure
  def self.ptypes() super << PTurn end
  def self.pdefaults() super << pturn_default end
  def pvalues() super << @degrees end
  def self.pturn_default() 360 end # may be overridden
  def initialize(degrees=self.class.pturn_default)
    raise "type error" unless degrees.is_a? Integer
    @degrees=degrees
  end
end

class Circle < VariableTurnHelperFigure; end
class Circle3Places < Circle; def self.pturn_default() 270 end end
class CircleRight < Circle; def self.pturn_default() -360 end end
class CircleRight3Places < CircleRight; def self.pturn_default() -270 end end

class Star < VariableTurnHelperFigure; end
class StarRight < Star; end
class StarLeft < Star; def self.pturn_default() -360 end end

class Gyre < VariableTurnHelperFigure
  def self.ptypes() super << pwho end
  def self.pdefaults() super << pwho_default end
  def pvalues() super << @subject end
  def self.pwho() PPairOrPairs end
  def self.pwho_default() PPartners end
  def initialize(subject=self.class.pwho_default, degrees=self.class.pturn_default)
    raise "type error" unless degrees.is_a? Integer
    raise "type error" unless subject.is_a? Class and self.class.pwho > subject
    @subject = subject
    @degrees = degrees
  end
end

class GyreLeftShoulder < Gyre; def self.pturn_default() super * -1 end end

class AllemandeAndOrbit < Figure
  def self.pwho_inner() P2Dancers end
  def self.ptypes()   super << P2Dancers  << PTurn << PTurn end
  def self.pdefault() super << pwho_inner << -540  << 180 end
  def pvalues() super << @who_inner << @deg_inner << @deg_outer end
  def initialize(who_inner, deg_inner=self.class.pturn_inner, deg_outer=self.class.pturn_outer)
    raise "type error" unless who_inner < pwho_inner
    raise "type error" unless deg_inner.is_a? Integer
    raise "type error" unless deg_outer.is_a? Integer
    raise "inners and outers going same direction" unless deg_inner * deg_outer < 0
    @who_inner = who_inner
    @deg_inner = deg_inner
    @deg_outer = deg_outer
  end
end


# Here's the thing: I think this initialize business is waste of time.
# We need pvalues=(class &rest rest) that takes rest, subs in defaults for nil, and stores it.
# initialize is set once at Figure and just calls pvalue=. Otherwise it's simple.
# Finally we need a pchoices class method that describes valid UI choices for parameters.

