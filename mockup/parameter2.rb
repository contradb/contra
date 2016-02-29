class ParameterRange
end

class AngleRange < ParameterRange
  def degrees_options
    [AngleChooser.new(-1080, 1080, 45)]
  end
end

module ClockwiseRange; end
module CounterClockwiseRange; end

class PlacesRange < AngleRange
end

class PlacesClockwiseRa
  include 
end
