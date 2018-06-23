class Racker
  def call(env)
    [200, { 'Content-Type' => 'text/plain' }, ['Something happens!']]
  end
end

run Racker.new
