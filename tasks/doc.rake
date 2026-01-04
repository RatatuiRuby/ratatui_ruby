# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rdoc/task"

require_relative "rdoc_config"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = ENV["RDOC_OUTPUT"] || "tmp/rdoc"
  rdoc.main = RDocConfig::MAIN
  rdoc.title = ENV["RDOC_TITLE"] if ENV["RDOC_TITLE"]
  rdoc.rdoc_files.include(RDocConfig::RDOC_FILES)
  custom_css = ENV["RDOC_CUSTOM_CSS"] || "doc/custom.css"
  rdoc.options << "--template-stylesheets=#{custom_css}"
end

# Custom RDoc HTML generator that captures headings for TOC
class CapturingToHtml < RDoc::Markup::ToHtml
  attr_reader :captured_headings

  def initialize(options, markup = nil)
    super
    @captured_headings = []
  end

  def accept_heading(heading)
    start_pos = @res.length
    super
    added = @res[start_pos..-1].join
    if added =~ /id="([^"]+)"/
      @captured_headings << { level: heading.level, text: heading.text, id: $1 }
    end
  end
end

task :copy_doc_images do
  rdoc_dir = ENV["RDOC_OUTPUT"] || "tmp/rdoc"
  if Dir.exist?("doc/images")
    FileUtils.mkdir_p "#{rdoc_dir}/doc/images"
    FileUtils.cp_r Dir["doc/images/*.png"], "#{rdoc_dir}/doc/images"
    FileUtils.cp_r Dir["doc/images/*.gif"], "#{rdoc_dir}/doc/images"
  end
end

def build_tree(all_files, root_dir, max_depth = nil, current_depth = 1)
  return {} if max_depth && current_depth > max_depth

  files_by_dir = all_files.group_by { |f| File.dirname(f) }
  dirs_at_level = files_by_dir.keys.select { |d| d.start_with?(root_dir) && d.count("/") == current_depth }

  tree = {}

  dirs_at_level.each do |dir|
    dir_name = dir.split("/").last
    files = files_by_dir[dir] || []
    subdirs = files_by_dir.keys.select { |d| d.start_with?("#{dir}/") && d.count("/") == current_depth + 1 }

    tree[dir_name] = {
      path: dir.sub("examples/", ""),
      files: files.map { |f|
        {
          name: File.basename(f),
          path: "#{File.basename(f).gsub('.', '_')}.html",
          full_path: f,
        }
      }.sort_by { |f| f[:name] },
      subdirs: build_tree(all_files, dir, max_depth, current_depth + 1),
    }
  end

  tree
end

def extract_rdoc_info(content, filename)
  require "rdoc/comment"
  require "rdoc/markup/to_html"

  options = RDoc::Options.new
  store = RDoc::Store.new(options)
  top_level = store.add_file filename
  stats = RDoc::Stats.new(store, 1)

  parser = RDoc::Parser::Ruby.new(top_level, content, options, stats)
  parser.scan

  lines = content.lines

  # Find the first class/module defined in the file
  # We want the one that appears earliest in the file
  # Filter out items with nil lines
  target_class = top_level.classes_or_modules.select(&:line).min_by(&:line)

  if target_class
    # Use the class definition line as the anchor
    # RDoc line numbers are 1-based
    anchor_index = target_class.line - 1
    title = target_class.name
    search_snippet = target_class.respond_to?(:search_snippet) ? target_class.search_snippet : ""
  else
    # Fallback to first line of code if no class defined
    first_code_index = lines.find_index { |l| !l.strip.empty? && !l.strip.start_with?("#") }
    anchor_index = first_code_index
    title = nil
    search_snippet = ""
  end

  # Walk upwards from the line before the anchor to find immediate comments
  comment_lines = []
  if anchor_index && anchor_index > 0
    idx = anchor_index - 1
    while idx >= 0
      line = lines[idx].strip

      # Stop at blank lines
      break if line.empty?

      # Stop if we hit something that isn't a comment (shouldn't happen if we are above code, but safety check)
      break unless line.start_with?("#")

      comment_lines.unshift(lines[idx])
      idx -= 1
    end
  end

  raw_comment = nil
  unless comment_lines.empty?
    # Create RDoc comment from extracted lines
    # Strip leading # and optional space
    cleaned_lines = comment_lines.map do |line|
      line.strip.sub(/^#\s?/, "")
    end
    raw_comment = cleaned_lines.join("\n")
    # Use first line of comment as snippet if RDoc didn't provide one
    search_snippet = cleaned_lines.first if search_snippet.empty?
  end

  {
    title:,
    raw_comment:,
    search_snippet:,
  }
rescue => e
  puts "Warning: Failed to extract RDoc info for #{filename}: #{e.message}"
  { title: nil, raw_comment: nil, search_snippet: "" }
end

def render_tree_html(tree_data, current_path, current_file_html, depth = 0)
  html_parts = []

  # Calculate prefix to return to examples root from current file
  current_depth = current_path.split("/").size - 1
  root_prefix = "../" * current_depth

  tree_data.keys.sort.each do |dir_name|
    item = tree_data[dir_name]
    has_children = item[:files].any? || item[:subdirs].any?

    if has_children
      # Check if this directory is in the path of the current file
      # item[:path] is relative to examples root (e.g., "app_all_events/model")
      # current_path is also relative to examples root (e.g., "app_all_events/model/event_color_cycle")
      # We want to open if current_path starts with this directory's path
      is_in_path = current_path == item[:path] || current_path.start_with?("#{item[:path]}/")
      open_attr = is_in_path ? "open" : ""

      html_parts << "<li>"
      html_parts << "  <details #{open_attr}>"
      html_parts << "    <summary>#{ERB::Util.html_escape(dir_name)}</summary>"
      html_parts << "    <ul class=\"link-list nav-list\">"

      # Add files
      item[:files].each do |file|
        # Check specific file match
        # file[:path] is the HTML filename (e.g., "event_color_cycle.html")
        # current_file_html is the current file's HTML name
        is_active = is_in_path && file[:path] == current_file_html

        active_class = is_active ? ' class="active"' : ""
        file_name_display = ERB::Util.html_escape(file[:name])
        file_name_display = "<strong>#{file_name_display}</strong>" if is_active

        # Link relative to examples root
        file_path = "#{root_prefix}#{item[:path]}/#{file[:path]}"
        html_parts << "      <li><a href=\"#{file_path}\"#{active_class}><span class=\"file\"></span>#{file_name_display}</a></li>"
      end

      # Add subdirectories recursively
      if item[:subdirs].any?
        html_parts << render_tree_html(item[:subdirs], current_path, current_file_html, depth + 1)
      end

      html_parts << "    </ul>"
      html_parts << "  </details>"
      html_parts << "</li>"
    end
  end

  html_parts.join("\n")
end

task :copy_examples do
  puts "Copying examples..."
  require "erb"

  require "rdoc"
  require "rdoc/markdown"
  require "rdoc/markup/to_html"

  rdoc_dir = ENV["RDOC_OUTPUT"] || "tmp/rdoc"

  if Dir.exist?("examples")
    FileUtils.rm_rf "#{rdoc_dir}/examples"
    FileUtils.mkdir_p "#{rdoc_dir}/examples"

    all_files = Dir.glob("examples/**/*.{rb,md}")

    template = File.read("tasks/example_viewer.html.erb")
    erb = ERB.new(template)

    # Find the RDoc icons template
    icons_path = Gem.find_files("rdoc/generator/template/aliki/_icons.rhtml").first
    icons_svg = icons_path ? File.read(icons_path) : ""

    # Group files by directory
    files_by_dir = all_files.group_by { |f| File.dirname(f) }

    # Create a binding context for ERB
    class ExampleViewerContext
      attr_reader :breadcrumb_path, :page_title, :file_content_html, :file_header_html
      attr_reader :current_file_html, :tree_data, :doc_root_link, :icons_svg, :relative_path
      attr_reader :toc_items
      attr_accessor :render_tree_helper

      def initialize(breadcrumb_path, page_title, file_content_html, file_header_html,
        current_file_html, tree_data, doc_root_link, icons_svg, relative_path, toc_items
      )
        @breadcrumb_path = breadcrumb_path
        @page_title = page_title
        @file_content_html = file_content_html
        @file_header_html = file_header_html

        @current_file_html = current_file_html
        @tree_data = tree_data
        @doc_root_link = doc_root_link
        @icons_svg = icons_svg
        @relative_path = relative_path
        @toc_items = toc_items
      end

      def render_tree(tree_data, current_path, current_file_html)
        render_tree_helper.call(tree_data, current_path, current_file_html)
        # Output directly to preserve HTML tags
      end

      def render_toc(items)
        return "" if items.empty?

        html = []
        html << "<ul>"
        base_level = items.first[:level]

        items.each_with_index do |item, i|
          level = item[:level]
          text = item[:text]
          id = item[:id]

          html << "<li><a href=\"##{id}\">#{text}</a>"

          next_item = items[i + 1]

          if next_item
            next_level = next_item[:level]
            if next_level > level
              (next_level - level).times { html << "<ul>" }
            elsif next_level < level
              html << "</li>"
              (level - next_level).times { html << "</ul></li>" }
            else # same level
              html << "</li>"
            end
          else
            # Last item. Close everything back to start.
            html << "</li>"
            (level - base_level).times { html << "</ul></li>" }
          end
        end

        html << "</ul>"
        html.join("\n")
      end

      def get_binding
        binding
      end
    end

    # Collect search index entries
    search_entries = []

    # Generate HTML files for each file
    all_files.each do |file_path|
      relative_path = file_path.sub("examples/", "")
      target_dir = "#{rdoc_dir}/examples/#{File.dirname(relative_path)}"
      FileUtils.mkdir_p target_dir

      content = File.read(file_path)
      ext = File.extname(file_path)
      filename = File.basename(file_path)
      toc_items = []

      if ext == ".md"
        # Markdown files usually have their own H1, so no header needed
        page_title = filename
        breadcrumb_path = relative_path
        file_header_html = ""

        # Parse markdown
        doc = RDoc::Markdown.parse(content)

        # Render and capture headings
        options = RDoc::Options.new
        renderer = CapturingToHtml.new(options)
        file_content_html = doc.accept(renderer)
        toc_items = renderer.captured_headings

        # For Markdown, if we assume the first header is the title and is already captured,
        # we might not need to prepend anything.
        # But if file_header_html is empty, the H1 is in file_content_html.
        # CapturingToHtml should have captured it.
      else
        info = extract_rdoc_info(content, filename)

        if info[:title]
          page_title = info[:title]
          breadcrumb_path = relative_path
        else
          page_title = filename
          breadcrumb_path = "#{File.dirname(relative_path)}/"
        end

        # Add to search index
        html_path = "#{File.dirname(relative_path)}/#{File.basename(file_path).gsub('.', '_')}.html"
        search_entries << {
          name: page_title,
          full_name: relative_path,
          type: info[:title] ? "class" : "file",
          path: html_path,
          snippet: info[:search_snippet],
        }

        file_header_html = "<h1 id=\"top\">#{ERB::Util.html_escape(page_title)}</h1>"

        # Concatenate comment and Source Code section
        parts = []
        if info[:raw_comment] && !info[:raw_comment].strip.empty?
          parts << info[:raw_comment]
        end

        indented_code = content.gsub(/^/, "  ")
        parts << "= Source Code\n\n#{indented_code}"

        combined_doc = parts.join("\n\n")

        # Parse and render
        doc = RDoc::Markup.parse(combined_doc)
        options = RDoc::Options.new
        renderer = CapturingToHtml.new(options)
        file_content_html = doc.accept(renderer)
        toc_items = renderer.captured_headings

        # Add Page Title to TOC
        toc_items.unshift({ level: 1, text: page_title, id: "top" })
      end

      # Calculate link to doc root

      # Calculate link to doc root
      depth = relative_path.split("/").size - 1
      doc_root_link = "#{'../' * (depth + 1)}index.html"

      # Build tree structure for sidebar
      current_file_html = "#{File.basename(file_path).gsub('.', '_')}.html"
      tree_data = build_tree(all_files, "examples", nil)

      context = ExampleViewerContext.new(breadcrumb_path, page_title, file_content_html, file_header_html,
        current_file_html, tree_data, doc_root_link, icons_svg, relative_path, toc_items)
      context.render_tree_helper = lambda { |tree, path, file|
        render_tree_html(tree, path, file)
      }
      html = erb.result(context.get_binding)

      html_file = "#{target_dir}/#{File.basename(file_path).gsub('.', '_')}.html"
      File.write(html_file, html)
    end

    # Write search index for examples
    FileUtils.mkdir_p "#{rdoc_dir}/examples/js"
    search_data = { index: search_entries }
    File.write("#{rdoc_dir}/examples/js/search_data.js", "var search_data = #{JSON.generate(search_data)};")

    # Copy RDoc search JS files to examples
    rdoc_js_dir = Gem.find_files("rdoc/generator/template/aliki/js").first
    if rdoc_js_dir && Dir.exist?(rdoc_js_dir)
      %w[search_navigation.js search_ranker.js search_controller.js aliki.js].each do |js_file|
        src = File.join(rdoc_js_dir, js_file)
        FileUtils.cp(src, "#{rdoc_dir}/examples/js/#{js_file}") if File.exist?(src)
      end
    end

    # Generate index.html files for each directory
    files_by_dir.each do |dir, files|
      target_dir = "#{rdoc_dir}/examples/#{dir}".sub("examples/", "")
      FileUtils.mkdir_p target_dir

      # Get parent directory
      if dir == "examples"
        parent_link = nil
        doc_root_link = "../index.html"
      else
        parent_dir = File.dirname(dir).sub("examples/", "")
        parent_link = (parent_dir == ".") ? "../index.html" : "../index.html"
        depth = dir.sub("examples/", "").split("/").size
        doc_root_link = "#{'../' * (depth + 1)}index.html"
      end

      # Find subdirectories
      subdirs = files_by_dir.keys.select { |d| File.dirname(d) == dir && d != dir }

      # Build combined list of folders and files with icons
      items = []
      subdirs.each { |d| items << { type: :dir, name: File.basename(d), path: "#{File.basename(d)}/index.html", icon: "📁" } }
      files.each { |f| items << { type: :file, name: File.basename(f), path: "#{File.basename(f).gsub('.', '_')}.html", icon: "📄" } }

      # Sort alphabetically
      sorted_items = items.sort_by { |i| i[:name].downcase }

      index_html = <<~HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Examples</title>
          <link href="#{doc_root_link.sub('index.html', '')}css/rdoc.css" rel="stylesheet">
          <link href="#{doc_root_link.sub('index.html', '')}custom.css" rel="stylesheet">
          <script>
            var rdoc_rel_prefix = "#{doc_root_link.sub('index.html', '')}";
          </script>
        </head>
        <body class="file">
          <header class="top-navbar">
            <div class="navbar-brand">Examples</div>
            <div class="navbar-search navbar-search-desktop"></div>
            <button id="theme-toggle" class="theme-toggle" aria-label="Switch to dark mode" type="button" onclick="cycleColorMode()">
              <span class="theme-toggle-icon" aria-hidden="true">🌙</span>
            </button>
          </header>
          
          <nav id="navigation" role="navigation">
            <div id="fileindex-section" class="nav-section">
              <h3>Navigation</h3>
              <ul class="nav-list">
                <li><a href="#{doc_root_link}">← Back to Docs</a></li>
                #{parent_link ? "<li><a href=\"#{parent_link}\">↑ Up to parent directory</a></li>" : ''}
              </ul>
            </div>
          </nav>

          <main role="main">
            <div class="content">
              <ul class="file-list">
                #{sorted_items.map { |item| "<li><a href=\"#{item[:path]}\"><span class=\"icon\">#{item[:icon]}</span>#{item[:name]}#{(item[:type] == :dir) ? '/' : ''}</a></li>" }.join("\n              ")}
              </ul>
            </div>
            <div class="footer"><a href="#{doc_root_link}">← Back to docs</a></div>
          </main>

          <script>
            const modes = ['auto', 'light', 'dark'];
            const icons = { auto: '🌓', light: '☀️', dark: '🌙' };
            
            function setColorMode(mode) {
              if (mode === 'auto') {
                document.documentElement.removeAttribute('data-theme');
                const systemTheme = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? 'dark' : 'light';
                document.documentElement.setAttribute('data-theme', systemTheme);
              } else {
                document.documentElement.setAttribute('data-theme', mode);
              }
              
              const icon = icons[mode];
              const toggle = document.getElementById('theme-toggle');
              if (toggle) {
                toggle.querySelector('.theme-toggle-icon').textContent = icon;
              }
              
              localStorage.setItem('rdoc-theme', mode);
            }
            
            function cycleColorMode() {
              const current = localStorage.getItem('rdoc-theme') || 'auto';
              const currentIndex = modes.indexOf(current);
              const nextMode = modes[(currentIndex + 1) % modes.length];
              setColorMode(nextMode);
            }
            
            const savedMode = localStorage.getItem('rdoc-theme') || 'auto';
            setColorMode(savedMode);
          </script>
        </body>
        </html>
      HTML

      File.write("#{target_dir}/index.html", index_html)
    end

    # Generate root index.html
    root_files = all_files.select { |f| File.dirname(f) == "examples" }
    root_subdirs = files_by_dir.keys.select { |d| File.dirname(d) == "examples" && d != "examples" }

    # Build combined list of root folders and files with icons
    root_items = []
    root_subdirs.each { |d| root_items << { type: :dir, name: File.basename(d), path: "#{File.basename(d)}/index.html", icon: "📁" } }
    root_files.each { |f| root_items << { type: :file, name: File.basename(f), path: "#{File.basename(f).gsub('.', '_')}.html", icon: "📄" } }

    # Sort alphabetically
    sorted_root_items = root_items.sort_by { |i| i[:name].downcase }

    root_index_html = <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Examples</title>
        <link href="../css/rdoc.css" rel="stylesheet">
        <link href="../custom.css" rel="stylesheet">
        <script>
          var rdoc_rel_prefix = "../";
        </script>
      </head>
      <body class="file">
        <header class="top-navbar">
          <div class="navbar-brand">Examples</div>
          <div class="navbar-search navbar-search-desktop"></div>
          <button id="theme-toggle" class="theme-toggle" aria-label="Switch to dark mode" type="button" onclick="cycleColorMode()">
            <span class="theme-toggle-icon" aria-hidden="true">🌙</span>
          </button>
        </header>

        <nav id="navigation" role="navigation">
          <div id="fileindex-section" class="nav-section">
            <h3>Navigation</h3>
            <ul class="nav-list">
              <li><a href="../index.html">← Back to Docs</a></li>
            </ul>
          </div>
        </nav>

        <main role="main">
          <div class="content">
            <ul class="file-list">
              #{sorted_root_items.map { |item| "<li><a href=\"#{item[:path]}\"><span class=\"icon\">#{item[:icon]}</span>#{item[:name]}#{(item[:type] == :dir) ? '/' : ''}</a></li>" }.join("\n            ")}
            </ul>
          </div>
          <div class="footer"><a href="../index.html">← Back to docs</a></div>
        </main>

        <script>
          const modes = ['auto', 'light', 'dark'];
          const icons = { auto: '🌓', light: '☀️', dark: '🌙' };
          
          function setColorMode(mode) {
            if (mode === 'auto') {
              document.documentElement.removeAttribute('data-theme');
              const systemTheme = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? 'dark' : 'light';
              document.documentElement.setAttribute('data-theme', systemTheme);
            } else {
              document.documentElement.setAttribute('data-theme', mode);
            }
            
            const icon = icons[mode];
            const toggle = document.getElementById('theme-toggle');
            if (toggle) {
              toggle.querySelector('.theme-toggle-icon').textContent = icon;
            }
            
            localStorage.setItem('rdoc-theme', mode);
          }
          
          function cycleColorMode() {
            const current = localStorage.getItem('rdoc-theme') || 'auto';
            const currentIndex = modes.indexOf(current);
            const nextMode = modes[(currentIndex + 1) % modes.length];
            setColorMode(nextMode);
          }
          
          const savedMode = localStorage.getItem('rdoc-theme') || 'auto';
          setColorMode(savedMode);
        </script>
      </body>
      </html>
    HTML

    File.write("#{rdoc_dir}/examples/index.html", root_index_html)
  end
end

Rake::Task[:rdoc].enhance do
  Rake::Task[:copy_doc_images].invoke
  Rake::Task[:copy_examples].invoke
  Rake::Task[:rewrite_examples_link].invoke
end

Rake::Task[:rerdoc].enhance do
  Rake::Task[:copy_doc_images].invoke
  Rake::Task[:copy_examples].invoke
  Rake::Task[:rewrite_examples_link].invoke
end

task :rewrite_examples_link do
  require "nokogiri"

  rdoc_dir = ENV["RDOC_OUTPUT"] || "tmp/rdoc"

  # Build a mapping of example READMEs to their H1 titles and categories
  examples_by_category = { "Apps" => [], "Widgets" => [] }

  Dir.glob("examples/*/README.md").each do |readme_path|
    dir_name = File.dirname(readme_path).sub("examples/", "")

    # Skip verify examples entirely
    next if dir_name.start_with?("verify_")

    content = File.read(readme_path)
    if content =~ /^#\s+(.+)$/
      title = $1.strip.sub(/ Example$/, "") # Remove trailing " Example"
      rdoc_path = "examples/#{dir_name}/README_md.html"

      # Categorize by prefix
      category = if dir_name.start_with?("app_")
        "Apps"
      elsif dir_name.start_with?("widget_")
        title = title.sub(/ Widget$/, "") # Also strip trailing " Widget" for widgets
        "Widgets"
      else
        nil
      end

      if category
        examples_by_category[category] << { title:, rdoc_path:, dir_name: }
      end
    end
  end

  # Sort each category alphabetically by title
  examples_by_category.each_value { |list| list.sort_by! { |e| e[:title] } }

  # Process all HTML files
  Dir.glob("#{rdoc_dir}/**/*.html").each do |file|
    content = File.read(file)
    modified = false

    doc = Nokogiri::HTML(content)

    # Find the examples details section to remove from Pages
    examples_detail = doc.css("details summary").find { |s| s.text.strip.downcase == "examples" }&.parent

    # Find the classindex-section to insert Examples section before it
    classindex_section = doc.at_css("#classindex-section")

    if examples_detail && classindex_section
      # Remove examples from Pages section
      examples_detail.remove

      # Build the new Examples section as a top-level nav-section
      current_depth = file.sub("#{rdoc_dir}/", "").count("/")
      prefix = "../" * current_depth

      examples_section = Nokogiri::XML::Node.new("div", doc)
      examples_section["id"] = "exampleindex-section"
      examples_section["class"] = "nav-section"

      examples_section.inner_html = <<~HTML
        <details class="nav-section-collapsible" open>
          <summary class="nav-section-header">
            <span class="nav-section-icon">
              <svg><use href="#icon-layers"></use></svg>
            </span>
            <span class="nav-section-title">Examples</span>
            <span class="nav-section-chevron">
              <svg><use href="#icon-chevron"></use></svg>
            </span>
          </summary>
          <ul class="link-list nav-list">
          </ul>
        </details>
      HTML

      # Build the category structure
      examples_ul = examples_section.at_css("ul.link-list")

      examples_by_category.each do |category_name, examples|
        next if examples.empty?

        cat_li = Nokogiri::XML::Node.new("li", doc)
        cat_details = Nokogiri::XML::Node.new("details", doc)
        # Subcategories closed by default
        cat_summary = Nokogiri::XML::Node.new("summary", doc)
        cat_summary.content = category_name
        cat_details.add_child(cat_summary)

        cat_ul = Nokogiri::XML::Node.new("ul", doc)
        cat_ul["class"] = "link-list nav-list"

        examples.each do |example|
          li = Nokogiri::XML::Node.new("li", doc)
          a = Nokogiri::XML::Node.new("a", doc)
          a["href"] = "#{prefix}#{example[:rdoc_path]}"
          a.content = example[:title]
          li.add_child(a)
          cat_ul.add_child(li)
        end

        cat_details.add_child(cat_ul)
        cat_li.add_child(cat_details)
        examples_ul.add_child(cat_li)
      end

      # Insert Examples section before Classes and Modules
      classindex_section.add_previous_sibling(examples_section)

      # --- GUIDES SECTION ---
      # Build dynamic hierarchical tree from doc/ folder structure
      guides_tree = build_guides_tree

      # Find and remove the doc details section from Pages
      doc_detail = doc.css("details summary").find { |s| s.text.strip.downcase == "doc" }&.parent
      doc_detail&.remove

      # Create the Guides section
      guides_section = Nokogiri::XML::Node.new("div", doc)
      guides_section["id"] = "guidesindex-section"
      guides_section["class"] = "nav-section"

      guides_section.inner_html = <<~HTML
        <details class="nav-section-collapsible" open>
          <summary class="nav-section-header">
            <span class="nav-section-icon">
              <svg><use href="#icon-file"></use></svg>
            </span>
            <span class="nav-section-title">Guides</span>
            <span class="nav-section-chevron">
              <svg><use href="#icon-chevron"></use></svg>
            </span>
          </summary>
          <ul class="link-list nav-list">
          </ul>
        </details>
      HTML

      # Get current file path relative to rdoc_dir (e.g. "doc/getting_started/quickstart_md.html")
      current_file_rel = file.sub("#{rdoc_dir}/", "")

      guides_ul = guides_section.at_css("ul.link-list")
      build_guides_nav(guides_ul, guides_tree, doc, prefix, current_file_rel, "doc")

      # Insert Guides section before Examples
      examples_section.add_previous_sibling(guides_section)

      content = doc.to_html
      modified = true
    end

    # Also rewrite examples_md.html to examples/index.html
    if content.include?("examples_md.html")
      content = content.gsub(/href="([^"]*?)examples_md\.html"/, 'href="\1examples/index.html"')
      modified = true
    end

    File.write(file, content) if modified
  end

  # Delete the now-unused examples_md.html
  examples_page = "#{rdoc_dir}/examples_md.html"
  FileUtils.rm_f(examples_page)

  puts "Created Examples and Guides sections in sidebar"
end

# Build a hierarchical tree structure from doc/**/*.md files
def build_guides_tree
  tree = { files: [], subdirs: {} }

  Dir.glob("doc/**/*.md").each do |md_path|
    # Skip images folder
    next if md_path.include?("/images/")

    relative = md_path.sub("doc/", "")
    parts = relative.split("/")
    filename = parts.pop

    # Get title from H1
    content = File.read(md_path)
    title = if content =~ /^#\s+(.+)$/
      $1.strip
    else
      filename.sub(/\.md$/, "").tr("_-", " ").split.map(&:capitalize).join(" ")
    end

    # Convert to RDoc path
    rdoc_path = "doc/#{relative.gsub('.', '_')}.html"

    # Navigate to correct position in tree
    current = tree
    parts.each do |dir|
      current[:subdirs][dir] ||= { files: [], subdirs: {} }
      current = current[:subdirs][dir]
    end

    current[:files] << { title:, rdoc_path:, filename: }
  end

  # Sort files in each level alphabetically by title
  sort_guides_tree(tree)
  tree
end

def sort_guides_tree(node)
  node[:files].sort_by! { |f| f[:title] }
  node[:subdirs].each_value { |subdir| sort_guides_tree(subdir) }
end

# Recursively build navigation elements from the tree
# current_file_rel: path of current HTML file relative to rdoc_dir (e.g. "doc/getting_started/quickstart_md.html")
# current_tree_path: path in the tree we're building (e.g. "doc", "doc/getting_started")
def build_guides_nav(parent_ul, tree, doc, prefix, current_file_rel, current_tree_path)
  # Add files at this level first
  tree[:files].each do |file|
    # Check if this file is the current page
    is_current = (file[:rdoc_path] == current_file_rel)

    li = Nokogiri::XML::Node.new("li", doc)
    a = Nokogiri::XML::Node.new("a", doc)
    a["href"] = "#{prefix}#{file[:rdoc_path]}"
    if is_current
      a["class"] = "active"
      strong = Nokogiri::XML::Node.new("strong", doc)
      strong.content = file[:title]
      a.add_child(strong)
    else
      a.content = file[:title]
    end
    li.add_child(a)
    parent_ul.add_child(li)
  end

  # Add subdirectories as collapsible details
  tree[:subdirs].each do |dir_name, subtree|
    subdir_path = "#{current_tree_path}/#{dir_name}"

    # Check if current file is inside this subdirectory
    # current_file_rel might be "doc/getting_started/quickstart_md.html"
    # subdir_path would be "doc/getting_started"
    is_current_in_subdir = current_file_rel.start_with?("#{subdir_path}/")

    li = Nokogiri::XML::Node.new("li", doc)
    details = Nokogiri::XML::Node.new("details", doc)
    # Open if current file is inside this subdir
    details["open"] = "open" if is_current_in_subdir
    summary = Nokogiri::XML::Node.new("summary", doc)
    summary.content = dir_name.tr("_-", " ").split.map(&:capitalize).join(" ")
    details.add_child(summary)

    subdir_ul = Nokogiri::XML::Node.new("ul", doc)
    subdir_ul["class"] = "link-list nav-list"
    build_guides_nav(subdir_ul, subtree, doc, prefix, current_file_rel, subdir_path)

    details.add_child(subdir_ul)
    li.add_child(details)
    parent_ul.add_child(li)
  end
end
