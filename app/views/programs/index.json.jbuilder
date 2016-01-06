json.array!(@programs) do |program|
  json.extract! program, :id, :title, :user_id
  json.url program_url(program, format: :json)
end
