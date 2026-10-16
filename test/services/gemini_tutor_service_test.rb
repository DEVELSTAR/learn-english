require "test_helper"

class GeminiTutorServiceTest < ActiveSupport::TestCase
  setup do
    @student = users(:student_one)
    @lesson = lessons(:compare_lesson)
    @service = GeminiTutorService.new(@lesson, @student)
    @original_api_key = ENV["GEMINI_API_KEY"]
  end

  teardown do
    ENV["GEMINI_API_KEY"] = @original_api_key
  end

  test "returns fallback response when GEMINI_API_KEY is not set" do
    ENV["GEMINI_API_KEY"] = nil

    response = @service.ask("How do I use compare?")
    assert_includes response, "Namaste Rahul Sharma!"
    assert_includes response, "GEMINI_API_KEY"
    assert_includes response, "aistudio.google.com"
  end

  test "calls Gemini API and parses response when API key is set" do
    ENV["GEMINI_API_KEY"] = "fake-test-key-12345"

    fake_response_body = {
      "candidates" => [
        {
          "content" => {
            "parts" => [
              { "text" => "Sahi sentence hai! Aap 'compare with' use kar sakte hain." }
            ]
          }
        }
      ]
    }.to_json

    fake_response = Net::HTTPSuccess.new("1.1", "200", "OK")
    fake_response.define_singleton_method(:body) { fake_response_body }

    with_mock_http_response(fake_response) do
      response = @service.ask("Can I say 'compared to'?")
      assert_equal "Sahi sentence hai! Aap 'compare with' use kar sakte hain.", response
    end
  end

  test "handles API failure gracefully" do
    ENV["GEMINI_API_KEY"] = "fake-test-key-12345"

    fake_error_body = {
      "error" => {
        "message" => "API key expired"
      }
    }.to_json

    fake_response = Net::HTTPBadRequest.new("1.1", "400", "Bad Request")
    fake_response.define_singleton_method(:body) { fake_error_body }

    with_mock_http_response(fake_response) do
      response = @service.ask("Can I say this?")
      assert_includes response, "API key expired"
    end
  end

  test "handles network or standard errors gracefully without crashing" do
    ENV["GEMINI_API_KEY"] = "fake-test-key-12345"

    with_mock_http_handler(->(*_args, &_block) { raise Errno::ECONNREFUSED, "Connection refused" }) do
      response = @service.ask("Hello tutor")
      assert_includes response, "Maaf kijiye"
      assert_includes response, "Connection refused"
    end
  end

  test "fails over to secondary model if primary model returns 503 or error" do
    ENV["GEMINI_API_KEY"] = "fake-test-key-12345"

    calls = []
    fake_503 = Net::HTTPServiceUnavailable.new("1.1", "503", "Service Unavailable")
    fake_503.define_singleton_method(:body) { { "error" => { "message" => "The model is overloaded." } }.to_json }

    fake_200 = Net::HTTPSuccess.new("1.1", "200", "OK")
    fake_200.define_singleton_method(:body) { { "candidates" => [ { "content" => { "parts" => [ { "text" => "Fallback model reply!" } ] } } ] }.to_json }

    with_mock_http_handler(->(*_args, &block) {
      mock_http = Object.new
      mock_http.define_singleton_method(:request) do |req|
        calls << req.path
        calls.length == 1 ? fake_503 : fake_200
      end
      block.call(mock_http)
    }) do
      response = @service.ask("Can you explain?")
      assert_equal "Fallback model reply!", response
      assert_equal 2, calls.length
      assert_includes calls[0], "gemini-flash-latest"
      assert_includes calls[1], "gemini-flash-lite-latest"
    end
  end

  private

  def with_mock_http_response(response_obj)
    mock_http = Object.new
    mock_http.define_singleton_method(:request) { |_req| response_obj }
    with_mock_http_handler(->(*_args, &block) { block.call(mock_http) }) do
      yield
    end
  end

  def with_mock_http_handler(handler_proc)
    sc = class << Net::HTTP; self; end
    sc.send(:alias_method, :orig_test_start, :start)
    sc.send(:define_method, :start) do |*args, &block|
      handler_proc.call(*args, &block)
    end
    yield
  ensure
    sc.send(:alias_method, :start, :orig_test_start)
    sc.send(:remove_method, :orig_test_start)
  end
end

