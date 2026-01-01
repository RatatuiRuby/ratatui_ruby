# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rdoc/task"

require_relative "rdoc_config"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "tmp/rdoc"
  rdoc.main = RDocConfig::MAIN
  rdoc.rdoc_files.include(RDocConfig::RDOC_FILES)
  rdoc.options << "--template-stylesheets=doc/custom.css"
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
  if Dir.exist?("doc/images")
    FileUtils.mkdir_p "tmp/rdoc/doc/images"
    FileUtils.cp_r Dir["doc/images/*.png"], "tmp/rdoc/doc/images"
    FileUtils.cp_r Dir["doc/images/*.gif"], "tmp/rdoc/doc/images"
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

  if Dir.exist?("examples")
    FileUtils.rm_rf "tmp/rdoc/examples"
    FileUtils.mkdir_p "tmp/rdoc/examples"

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
      target_dir = "tmp/rdoc/examples/#{File.dirname(relative_path)}"
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
    FileUtils.mkdir_p "tmp/rdoc/examples/js"
    search_data = { index: search_entries }
    File.write("tmp/rdoc/examples/js/search_data.js", "var search_data = #{JSON.generate(search_data)};")

    # Copy RDoc search JS files to examples
    rdoc_js_dir = Gem.find_files("rdoc/generator/template/aliki/js").first
    if rdoc_js_dir && Dir.exist?(rdoc_js_dir)
      %w[search_navigation.js search_ranker.js search_controller.js aliki.js].each do |js_file|
        src = File.join(rdoc_js_dir, js_file)
        FileUtils.cp(src, "tmp/rdoc/examples/js/#{js_file}") if File.exist?(src)
      end
    end

    # Generate index.html files for each directory
    files_by_dir.each do |dir, files|
      target_dir = "tmp/rdoc/examples/#{dir}".sub("examples/", "")
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
          <link href="#{doc_root_link.sub('index.html', '')}css/custom.css" rel="stylesheet">
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
        <link href="../css/custom.css" rel="stylesheet">
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

    File.write("tmp/rdoc/examples/index.html", root_index_html)
  end
end

Rake::Task[:rdoc].enhance do
  Rake::Task[:copy_doc_images].invoke
  Rake::Task[:copy_examples].invoke
end

Rake::Task[:rerdoc].enhance do
  Rake::Task[:copy_doc_images].invoke
  Rake::Task[:copy_examples].invoke
end
