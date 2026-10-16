require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "render_ai_markdown returns empty string for blank text" do
    assert_equal "", render_ai_markdown("")
    assert_equal "", render_ai_markdown(nil)
  end

  test "render_ai_markdown renders bold, italic, and blockquotes using GFM" do
    markdown = <<~MD
      Arre wah! Yeh lijiye aapke 2 sentences:

      1. **Daily Life:**
         > *"Yeh restaurant ka khana thoda **expensive** hai!"*
         *(This restaurant is expensive)*
    MD

    html = render_ai_markdown(markdown)
    assert_includes html, "<strong>Daily Life:</strong>"
    assert_includes html, "<blockquote>"
    assert_includes html, "<strong>expensive</strong>"
    assert_includes html, "<em>“Yeh restaurant ka khana thoda"
    assert_includes html, "<ol>"
    assert_includes html, "<li>"
  end

  test "render_ai_markdown sanitizes dangerous HTML scripts and attributes" do
    dangerous_input = 'Hello <script>alert("hack")</script> <a href="javascript:alert(1)">click</a> **safe**'
    html = render_ai_markdown(dangerous_input)

    refute_includes html, "<script>"
    refute_includes html, "javascript:alert"
    assert_includes html, "<strong>safe</strong>"
  end

  test "render_ai_markdown fallback handles bold and blockquotes gracefully" do
    markdown = "> **Quote here**"
    html = render_ai_markdown_fallback(markdown)

    assert_includes html, "<strong>Quote here</strong>"
    assert_includes html, "<blockquote"
  end
end

