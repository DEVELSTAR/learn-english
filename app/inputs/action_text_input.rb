class ActionTextInput < Formtastic::Inputs::TextInput
  def to_html
    input_wrapping do
      label_html <<
      builder.rich_text_area(method, input_html_options.reverse_merge(style: "min-height: 250px; background: #ffffff; display: block;"))
    end
  end
end

