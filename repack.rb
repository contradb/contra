require 'json'

# input: string of json array of strings of json stuff
# output: string of json array of json stuff
def repack (json)
  ## ...LoL, we're in for a little chop...
  a = JSON.parse json # array
  a.map {|e| json_parse e}
end


def json_parse (s)
  if ''== s || !s then nil else JSON.parse s end
end

def fixDB 
  Dance.all.each do |d| 
    j = d.figures_json
    k = JSON.generate (repack j)
    puts "input " + j
    puts "output " + k
    puts "writing....."
    d.figures_json = k
    d.save
    puts "____________"
  end
end

def fixDB2
  Dance.all.each do |d|
    (1..8).each do |i|
      d["figure"+i.to_s] = d["figure"+i.to_s].gsub("=>",":")
      d.save
    end
  end
end


# return a JSON string to store in .figures
def figure_packer_wildcat(*args)
  '[' + args.join(', ') + ']'
end
