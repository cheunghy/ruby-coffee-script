begin
  require 'minitest/autorun'
rescue LoadError
  require 'test/unit'
end

TestCase = if defined? Minitest::Test
    Minitest::Test
  elsif defined? MiniTest::Unit::TestCase
    MiniTest::Unit::TestCase
  else
    Test::Unit::TestCase
  end

require 'coffee_script'
require 'stringio'

class TestCoffeeScript < TestCase
  def test_compile
    assert_match "puts('Hello, World!')",
      CoffeeScript.compile("puts 'Hello, World!'\n")
  end

  def test_compile_with_io
    io = StringIO.new("puts 'Hello, World!'\n")
    assert_match "puts('Hello, World!')",
      CoffeeScript.compile(io)
  end

  def test_compile_multiple_strings
    assert_match "puts('Hello, World!')",
      CoffeeScript.compile("puts ", "'Hello, World!\n'")
  end

  def test_compile_with_bare_true
    assert_no_match "function()",
      CoffeeScript.compile("puts 'Hello, World!'\n", :bare => true)
  end

  def test_compile_with_bare_false
    assert_match "function()",
      CoffeeScript.compile("puts 'Hello, World!'\n", :bare => false)
  end

  def test_compile_with_bare_true_and_multiple_strings
    result = CoffeeScript.compile("puts ", "'Hello, World!'\n", :bare => true)
    assert_match "puts('Hello, World!')", result
    assert_no_match "function()", result
  end

  def test_compile_with_no_wrap_true
    assert_no_match "function()",
      CoffeeScript.compile("puts 'Hello, World!'\n", :no_wrap => true)
  end

  def test_compile_with_no_wrap
    assert_match "function()",
      CoffeeScript.compile("puts 'Hello, World!'\n", :no_wrap => false)
  end

  def test_compilation_error
    error_messages = [
      # <=1.4
      "Error: Parse error on line 4: Unexpected 'POST_IF'",
      # 1.5
      "Error: Parse error on line 3: Unexpected 'POST_IF'",
      # 1.6
      "SyntaxError: [stdin]:3:11: unexpected POST_IF",
      # 1.7
      "SyntaxError: [stdin]:3:11: unexpected unless"
    ]
    begin
      src = <<-EOS
        sayHello = ->
          console.log "hello, world"
          unless
      EOS
      CoffeeScript.compile(src)
      flunk
    rescue CoffeeScript::Error => e
      assert error_messages.include?(e.message),
        "message was #{e.message.inspect}"
    end
  end

  def assert_no_match(expected, actual)
    assert !expected.match(actual)
  end
end
