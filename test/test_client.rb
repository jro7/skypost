require 'minitest/autorun'
require 'skypost'

class TestSkypostClient < Minitest::Test
  def setup
    @client = Skypost::Client.new
  end

  def test_extract_single_link
    text = 'Check out this <a href="https://example.com">link</a>!'
    facets = @client.extract_links(text)

    assert_equal 1, facets.length
    facet = facets.first

    assert_equal 15, facet[:index][:byteStart] # Position of "link" in plain text
    assert_equal 19, facet[:index][:byteEnd]   # Start + "link".bytesize
    assert_equal "https://example.com", facet[:features].first[:uri]
  end

  def test_extract_multiple_links
    text = 'First <a href="https://one.com">one</a> and <a href="https://two.com">two</a>!'
    facets = @client.extract_links(text)

    assert_equal 2, facets.length

    # Check first link
    assert_equal 6, facets[0][:index][:byteStart]  # Position of "one"
    assert_equal 9, facets[0][:index][:byteEnd]    # Start + "one".bytesize
    assert_equal "https://one.com", facets[0][:features].first[:uri]

    # Check second link
    assert_equal 14, facets[1][:index][:byteStart] # Position of "two"
    assert_equal 17, facets[1][:index][:byteEnd]   # Start + "two".bytesize
    assert_equal "https://two.com", facets[1][:features].first[:uri]
  end

  def test_extract_links_with_unicode
    text = 'Unicode <a href="https://test.com">测试</a> text'
    facets = @client.extract_links(text)

    assert_equal 1, facets.length
    facet = facets.first

    assert_equal 8, facet[:index][:byteStart]
    assert_equal 14, facet[:index][:byteEnd]  # Unicode characters affect bytesize
    assert_equal "https://test.com", facet[:features].first[:uri]
  end

  def test_extract_links_with_emoji
    text = '🌟 Check <a href="https://test.com">this</a> out!'
    facets = @client.extract_links(text)

    assert_equal 1, facets.length
    facet = facets.first

    # 🌟 is 4 bytes in UTF-8 but 2 code units in UTF-16
    # "Check " is 6 bytes
    # Total offset should be 8 code units to the start of "this"
    assert_equal 8, facet[:index][:byteStart]
    assert_equal 12, facet[:index][:byteEnd]  # "this" is 4 characters
    assert_equal "https://test.com", facet[:features].first[:uri]
  end
end
