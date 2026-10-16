module ApplicationHelper
  def render_ai_markdown(text)
    return "" if text.blank?

    begin
      ensure_kramdown_loaded!

      html = Kramdown::Document.new(
        text.to_s,
        input: "GFM",
        hard_wrap: true
      ).to_html

      sanitize(
        html,
        tags: %w[p strong em b i blockquote ol ul li br code pre h1 h2 h3 h4 h5 h6 span hr a],
        attributes: %w[class href target rel]
      )
    rescue StandardError => e
      Rails.logger.warn("[ApplicationHelper#render_ai_markdown] Kramdown error: #{e.message}. Falling back.")
      render_ai_markdown_fallback(text)
    end
  end

  private

  def ensure_kramdown_loaded!
    return if defined?(Kramdown::Document) && defined?(Kramdown::Parser::GFM)

    begin
      require "kramdown"
      require "kramdown-parser-gfm"
    rescue LoadError
      # In case a development Puma process was booted before bundle add,
      # dynamically resolve and inject the gem's lib paths into $LOAD_PATH.
      %w[kramdown kramdown-parser-gfm].each do |gem_name|
        if (spec = Gem::Specification.find_all_by_name(gem_name).last)
          lib_dir = File.join(spec.full_gem_path, "lib")
          $LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
        end
      end
      require "kramdown"
      require "kramdown-parser-gfm"
    end
  end

  def render_ai_markdown_fallback(text)
    escaped = ERB::Util.html_escape(text.to_s)
    # Bold: **text**
    escaped.gsub!(/\*\*(.+?)\*\*/m, '<strong>\1</strong>')
    # Italic: *text* (excluding asterisks that are part of bold)
    escaped.gsub!(/(?<!\*)\*([^\*\n]+?)\*(?!\*)/, '<em>\1</em>')
    # Blockquotes (even with leading indentation/spaces)
    escaped.gsub!(/^\s*&gt;\s*(.+)$/, '<blockquote class="border-l-2 border-emerald-600 bg-emerald-50/60 pl-2.5 py-1 my-1.5 text-stone-800 rounded-r">\1</blockquote>')
    simple_format(escaped, {}, sanitize: false)
  end
end
