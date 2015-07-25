json.array!(@choreographers) do |choreographer|
  json.extract! choreographer, :id, :name
  json.url choreographer_url(choreographer, format: :json)
end
