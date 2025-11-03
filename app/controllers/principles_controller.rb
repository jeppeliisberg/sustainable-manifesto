class PrinciplesController < ApplicationController
  caches_page :show

  # Define the order of principles to match the homepage
  PRINCIPLE_ORDER = %w[
    lower-environmental-impact
    enduring-design
    human-wellbeing
    inclusive-creation
    data-sovereignty
    transparent-algorithms
    fair-labor
    open-infrastructure
    collaborative-development
    governance-for-the-common-good
  ].freeze

  def show
    @principle_id = params[:id]
    @content = load_principle_content(@principle_id)

    if @content.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
      return
    end

    # Parse title from first line (expecting "# Title")
    @title = extract_title(@content)
    @description = extract_description(@content)

    # Add navigation logic for next/previous principles
    current_index = PRINCIPLE_ORDER.index(@principle_id)
    if current_index
      @previous_principle_id = PRINCIPLE_ORDER[current_index - 1] if current_index > 0
      @next_principle_id = PRINCIPLE_ORDER[current_index + 1]
    end

    # Render markdown to HTML
    @html_content = render_markdown(@content)
  end

  private

  def load_principle_content(principle_id)
    file_path = Rails.root.join("lib", "content", "principles", "#{principle_id}.md")

    return nil unless File.exist?(file_path)

    File.read(file_path)
  end

  def extract_title(content)
    # Extract first heading (# Title)
    match = content.match(/^#\s+(.+)$/)
    match ? match[1] : "Sustainable Software Manifesto"
  end

  def extract_description(content)
    # Extract first paragraph after title
    lines = content.lines
    paragraphs = []
    in_paragraph = false

    lines.each do |line|
      line = line.strip
      next if line.start_with?("#") # Skip headings

      if line.empty?
        in_paragraph = false
        break if paragraphs.any? # Stop after first paragraph
      elsif !in_paragraph
        paragraphs << line
        in_paragraph = true
      else
        paragraphs << line
      end
    end

    paragraphs.join(" ").presence || "We—developers, designers, and entrepreneurs—shape the world through software. Prioritizing sustainability, inclusivity, and ethics is key to a just and resilient future."
  end

  def render_markdown(content)
    # Custom renderer to add Tailwind classes
    renderer = Class.new(Redcarpet::Render::HTML) do
      def initialize(options = {})
        super
        @first_paragraph = true
      end

      def header(text, header_level)
        case header_level
        when 1
          %(<h1 class="mt-2 text-pretty text-4xl font-semibold tracking-tight text-gray-900 dark:text-gray-300 sm:text-5xl">#{text}</h1>)
        when 2
          %(<h2 class="mt-16 text-pretty text-3xl font-semibold tracking-tight text-gray-900 dark:text-gray-300 sm:text-4xl">#{text}</h2>)
        when 3
          %(<h3 class="mt-10 text-pretty text-2xl font-semibold tracking-tight text-gray-900 dark:text-gray-300">#{text}</h3>)
        else
          "<h#{header_level}>#{text}</h#{header_level}>"
        end
      end

      def paragraph(text)
        if @first_paragraph
          @first_paragraph = false
          %(<p class="mt-6 text-xl/8">#{text}</p>)
        else
          %(<p class="mt-8">#{text}</p>)
        end
      end

      def list(contents, list_type)
        tag = list_type == :ordered ? "ol" : "ul"
        %(<#{tag} role="list" class="mt-8 max-w-xl space-y-4 text-gray-600 dark:text-gray-400">#{contents}</#{tag}>)
      end

      def list_item(text, list_type)
        %(<li class="flex gap-x-3"><span class="text-teal-600 font-bold text-xl flex-none" style="width: 1.25rem; margin-top: 0.125rem;">•</span><span>#{text}</span></li>)
      end

      def link(link, title, content)
        title_attr = title ? %( title="#{title}") : ""
        %(<a href="#{link}"#{title_attr} target="_blank" class="text-teal-600 underline hover:text-teal-800 hover:no-underline">#{content}</a>)
      end
    end.new(
      filter_html: false,
      hard_wrap: true
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true
    )

    markdown.render(content)
  end
end
