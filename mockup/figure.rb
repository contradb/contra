require 'set'

def assert(b)
  b or raise "failed assert"
end

class Figure
  # figures take parameters
  attr_reader :pvalues          # instance returns its values, all members of ptypes
  def self.ptypes () [] end     # declares parameter types - subclasses may narrow elements
  def self.pdefaults () [] end  # declares its default choice, or nil - subclasses may brazenly overwrite elements

  def initialize(pvalues=[])
    pts = self.class.ptypes
    pds = self.class.pdefaults
    assert pvalues.length <= pts.length
    pvalues2 = [];
    pts.each_with_index do |pt,i|
      pvalues2.push (pvalues[i] || pds[i] || ((1 == pt.options.length)&&pt.options[0]) || (raise "supply parameter #{i} of type #{pt}"))
    end
    @pvalues = pvalues2
  end

  def self.instantiable?
    pd = pdefaults
    pt = ptypes
    assert(pd.length == pt.length)
    for i in 0...(pd.length)
      return nil unless pd[i] || (1 == pt[i].options.length)
    end
    true
  end

  KIDS ||= {}
  def self.momma
    mom = self.superclass
    if KIDS[mom]
    then KIDS[mom] << self
    else KIDS[mom] = Set[self]
    end
  end
  def self.kids()
    KIDS[self] ||= Set.new
  end
end

# class SerialFigure < Figure; momma; end 
# class ParallelFigure < Figure; momma; end 

# ________________________________________________________________

# Digression: PType - Parameter Type

class PType; end
# inplements class method "options"

class PTurn < PType;
  def self.options(); [-720,-630,-540,-450,-360,-270,-180,-90,0,90,180,270,360,450,540,630,720] end
end
# clockwise is positive so that circle-right is dealing with positive
# quantities and swings go in the positive direction. So this is
# nautical convention not mathematical convention.

class PTurnPlus < PTurn
  def self.options() super.select {|x| x>0}; end
end

class PTurnMinus < PTurn
  def self.options() super.select {|x| x<0}; end
end

class PTurnPlusOnce < PTurnPlus; def self.options() [360]; end end
class PTurnMinusOnce < PTurnMinus; def self.options() [-360]; end end
class PTurnPlusOnceAndHalf < PTurnPlus; def self.options() [540]; end end
class PTurnMinusOnceAndHalf < PTurnMinus; def self.options() [-540]; end end
class PTurnPlusThreeQuarters < PTurnPlus; def self.options() [270]; end end
class PTurnMinusThreeQuarters < PTurnMinus; def self.options() [-270]; end end


# PWho says which dancers are acted on by the other parameters.
# Semantics are set by Figures, but these establish grouping for
# those parameters. Consider the allemande orbit figure - in some ways
# the most complicated figure. It takes three parameters:
# some subclass of P2x2Dancers, PTurnMinus540 and PTurnPlus180.
# The first PTurn is the amount of turning for the inner couple,
# and the second PTurn is the turning for the
# outer couple. 
# P1Dancer subclasses could likewise be used to establish 3&1
# commands, like Lady1 into the center and be a bird, everybody else
# circle round. 

class PWho < PType;
  def self.options() self.kids end
  KIDS ||= {}
  def self.momma
    mom = self.superclass
    if KIDS[mom]
    then KIDS[mom] << self
    else KIDS[mom] = Set[self]
    end
  end
  def self.kids()
    KIDS[self] ||= Set.new
  end
end
class PPairOrPairs < PWho; momma; end
class P1Dancer       < PWho; momma; end # {1},{3} (1-2 total commands)
class P2Dancers      < PPairOrPairs; momma; end # {1},{3} (1-2 total commands)
class P2x2Dancers    < PPairOrPairs; momma; end # {2&2}   (1 total command, sent to both, e.g. partner swing)
class P4Dancers      < PWho; momma; end # {4}     (1 total command)
# these classes aren't exhaustive, consider the pathological figure
# Ones: swing, L2: spin around clockwise in place, G2 slide left.
# So if there is a user-request for that busy a figure: extend as needed. 

class PGentlespoon1  < P1Dancer    ; momma; end
class PGentlespoon2  < P1Dancer    ; momma; end
class PLadle1        < P1Dancer    ; momma; end
class PLadle2        < P1Dancer    ; momma; end
class POnes          < P2Dancers   ; momma; end
class PTwos          < P2Dancers   ; momma; end
class PGentlespoons  < P2Dancers   ; momma; end
class PLadles        < P2Dancers   ; momma; end
class PFirstCorners  < P2Dancers   ; momma; end # G1L2
class PSecondCorners < P2Dancers   ; momma; end # G2L1
class PPartners      < P2x2Dancers ; momma; end
class PNeighbors     < P2x2Dancers ; momma; end
class PSameRoles     < P2x2Dancers ; momma; end # G1G2,L1L2

# ________________________________________________________________



# This is just an implementation helper. Don't rely on a figure having this type. 
class TurningFigure < Figure
  momma
  def self.ptypes() super << pturn end
  def self.pdefaults() super << (pturn.options.length == 1 ? pturn.options[0] : nil) end
  def self.pturn() PTurn end; 
end

class Circle < TurningFigure; momma; end
class CircleOnce < Circle; momma; def self.pturn() PTurnPlusOnce end end
class Circle3Places < Circle; momma; def self.pturn() PTurnPlusThreeQuarters end end
class CircleRight < Circle; momma; def self.pturn() PTurnMinus end end


class Star < TurningFigure; momma; end
class StarRight < Star; momma; def self.pturn() PTurnPlus end end
class StarLeft < Star; momma; def self.pturn() PTurnMinus end end

class PairOrPairsTurningFigure < TurningFigure
  momma;
  def self.ptypes() super << pwho end
  def self.pdefaults() super << pwho_default end
  def self.pwho() PPairOrPairs end
  def self.pwho_default() PPartners end
end

class Gyre < PairOrPairsTurningFigure; momma; end
class GyreRightShoulder < Gyre; momma; def self.pturn() PTurnPlus end end
class GyreLeftShoulder < Gyre; momma; def self.pturn() PTurnMinus end end

class AllemandeAndOrbit < Figure
  momma
  def self.pwho_inner() P2Dancers end
  def self.ptypes()   super << P2Dancers  << PTurn << PTurn end
  def self.pdefaults() super << pwho_inner << -540  << 180 end
end


