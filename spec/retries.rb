module Retries
  def with_retries(retries=3, &body)
    begin
      body.call
    rescue StandardError, RSpec::Expectations::ExpectationNotMetError => e
      retries -= 1
      if retries >= 0
        print '-'
        retry
      else
        raise
      end
    end
  end
end
