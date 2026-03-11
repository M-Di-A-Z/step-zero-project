module ApplicationHelper
  def render_markdown(text)
    simple_format(text)
  end
end
