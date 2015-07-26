json.array!(@dances) do |dance|
  json.extract! dance, :id, :title, :start_type, :figure1, :figure2, :figure3, :figure4, :figure5, :figure6, :figure7, :figure8, :notes
  json.url dance_url(dance, format: :json)
end
