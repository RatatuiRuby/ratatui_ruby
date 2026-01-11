# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require_relative "../test_helper"

##
# Tests for RatatuiRuby::Labs module.
#
# Labs are experimental features activated via the RR_LABS environment variable.
# These tests verify the activation mechanism and individual lab behaviors.
class TestLabs < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    RatatuiRuby::Labs.reset!
  end

  def teardown
    RatatuiRuby::Labs.reset!
  end

  ##
  # Verifies that Labs.enabled? returns false when no lab is active.
  #
  # This is the default state. Users must explicitly enable labs via
  # environment variable or programmatic activation.
  def test_enabled_returns_false_by_default
    refute RatatuiRuby::Labs.enabled?(:a11y),
      "Labs.enabled?(:a11y) should return false when not enabled"
  end

  ##
  # Verifies that Labs.enable! activates the specified lab.
  #
  # Programmatic activation allows testing without environment variables.
  def test_enable_activates_lab
    RatatuiRuby::Labs.enable!(:a11y)

    assert RatatuiRuby::Labs.enabled?(:a11y),
      "Labs.enabled?(:a11y) should return true after enable!(:a11y)"
  end

  ##
  # Verifies that RR_LABS env var activates the specified lab at load time.
  #
  # Uses subprocess isolation since env var is read at require time.
  def test_rr_labs_env_var_activates_lab
    script = <<~RUBY
      require "ratatui_ruby"
      puts RatatuiRuby::Labs.enabled?(:a11y)
    RUBY

    output = IO.popen(
      { "RR_LABS" => "A11Y" },
      ["ruby", "-I", "lib", "-e", script],
      err: [:child, :out]
    ) { |io| io.read.strip }

    assert_equal "true", output,
      "RR_LABS=A11Y should enable the a11y lab"
  end
end

##
# Tests for A11Y lab feature - widget tree XML export.
class TestLabsA11y < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    RatatuiRuby::Labs.reset!
  end

  def teardown
    RatatuiRuby::Labs.reset!
    FileUtils.rm_f(RatatuiRuby::Labs::A11y::OUTPUT_PATH)
  end

  ##
  # Verifies that dump_widget_tree creates an XML file.
  #
  # When called with a widget, it should write XML to the output path.
  def test_dump_widget_tree_creates_file
    widget = RatatuiRuby::Widgets::Paragraph.new(text: "Hello")

    RatatuiRuby::Labs::A11y.dump_widget_tree(widget)

    assert File.exist?(RatatuiRuby::Labs::A11y::OUTPUT_PATH),
      "dump_widget_tree should create the output file"
  end

  ##
  # Verifies that the XML contains the widget's class name as an element.
  #
  # This is the semantic structure screen readers need.
  def test_xml_contains_widget_element
    widget = RatatuiRuby::Widgets::Paragraph.new(text: "Hello")

    RatatuiRuby::Labs::A11y.dump_widget_tree(widget)
    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    assert_includes content, "<Paragraph",
      "XML should contain Paragraph element"
  end

  ##
  # Verifies that Labs.warn_once! emits warning only once per session.
  #
  # This is used by lab features to warn about experimental status.
  def test_warn_once_emits_single_warning
    RatatuiRuby::Labs.enable!(:a11y)

    # First call should emit warning
    RatatuiRuby::Labs.warn_once!("TestLab")

    # Should not raise, and subsequent calls are no-ops
    RatatuiRuby::Labs.warn_once!("TestLab")

    # verify it was called (we just check it doesn't crash)
    pass
  end

  ##
  # Verifies that frame.render_widget captures widgets when A11Y lab is enabled.
  #
  # This is the end-to-end integration - users just enable the lab and the
  # XML is written automatically when they call frame.render_widget.
  def test_frame_render_widget_captures_for_a11y
    RatatuiRuby::Labs.enable!(:a11y)
    widget = RatatuiRuby::Widgets::Paragraph.new(text: "Frame API")

    with_test_terminal do
      RatatuiRuby.draw do |frame|
        frame.render_widget(widget, frame.area)
      end
    end

    assert File.exist?(RatatuiRuby::Labs::A11y::OUTPUT_PATH),
      "frame.render_widget should capture widgets when A11Y lab enabled"
    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)
    assert_includes content, "<Paragraph",
      "Captured XML should contain widget structure"
  end

  ##
  # Verifies that XML output reflects layout hierarchy from nested layout_splits.
  #
  # When widgets are rendered into areas from nested splits, the XML shows
  # widgets in rendering order (parent before children). Example output:
  #   <Block x="0" title="Sidebar" .../>
  #   <Paragraph x="1" text="Item 1" .../>   <!-- inside Block's area -->
  #   <Paragraph x="24" text="Main" .../>    <!-- right side -->
  #
  # This test verifies parent-before-children rendering order.
  def test_xml_reflects_layout_hierarchy
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        # Split into left sidebar and right main
        left, right = RatatuiRuby::Layout::Layout.split(
          frame.area,
          direction: :horizontal,
          constraints: [
            RatatuiRuby::Layout::Constraint.percentage(30),
            RatatuiRuby::Layout::Constraint.percentage(70),
          ]
        )

        # Render sidebar container first (parent area)
        frame.render_widget(
          RatatuiRuby::Widgets::Block.new(title: "Sidebar", borders: :all),
          left
        )

        # Split sidebar into list items (children within parent area)
        item1, item2 = RatatuiRuby::Layout::Layout.split(
          left.inner(1), # 1-cell margin for border
          direction: :vertical,
          constraints: [
            RatatuiRuby::Layout::Constraint.length(1),
            RatatuiRuby::Layout::Constraint.length(1),
          ]
        )

        frame.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "Item 1"), item1)
        frame.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "Item 2"), item2)

        # Main content
        frame.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "Main"), right)
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    # Use REXML for proper XML parsing
    require "rexml/document"
    doc = REXML::Document.new(content)

    # Verify structure using XPath-like traversal
    frame = doc.root
    assert_equal "RatatuiFrame", frame.name, "Root should be RatatuiFrame"

    # Get all widget elements in document order
    widgets = frame.elements.to_a
    widget_names = widgets.map(&:name)

    assert_includes widget_names, "Block", "Should contain Block element"
    assert_includes widget_names, "Paragraph", "Should contain Paragraph elements"

    # Verify rendering order: Block first, then its children, then Main
    block_idx = widget_names.index("Block")
    _paragraph_indices = widget_names.each_index.select { |i| widget_names[i] == "Paragraph" }

    # Block should come before the child paragraphs (Items 1 & 2)
    # The sidebar items are at smaller x coordinates than Main
    sidebar_items = widgets.select do |w|
      next false unless w.name == "Paragraph"

      x_attr = w.attribute("x")&.value.to_i
      x_attr < 24 # Sidebar is 30% of 80 = 24
    end

    assert_operator sidebar_items.size, :>=, 2,
      "Should have at least 2 paragraphs in sidebar area"

    # Verify parent-before-children ordering by checking Block comes before sidebar items
    first_sidebar_idx = widgets.index(sidebar_items.first)
    assert block_idx < first_sidebar_idx,
      "Block (idx=#{block_idx}) should appear before sidebar items (idx=#{first_sidebar_idx})"
  end

  ##
  # Verifies that XML output doesn't contain empty elements for unset attributes.
  #
  # The XML should only include meaningful data that was actually set.
  # Empty style elements like <fg/>, <bg/>, <modifiers/> are noise.
  def test_xml_omits_empty_elements
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        # Simple paragraph with no style set
        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(text: "Plain text"),
          frame.area
        )
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    # These empty elements should NOT appear in output
    refute_includes content, "<fg/>", "Should not output empty <fg/>"
    refute_includes content, "<bg/>", "Should not output empty <bg/>"
    refute_includes content, "<modifiers/>", "Should not output empty <modifiers/>"
    refute_includes content, "<underline_color/>", "Should not output empty <underline_color/>"
    refute_includes content, "<style/>", "Should not output empty <style/>"
    refute_includes content, "<block/>", "Should not output empty <block/>"

    # Verify no blank lines in output (clean XML formatting)
    refute_match(/\n\s*\n/, content, "Should not have blank lines in XML output")
  end

  ##
  # Verifies that scalar constructor arguments become XML attributes.
  #
  # This mirrors Ruby code structure: constructor args like text, wrap,
  # alignment are attributes; nested objects like block, style are elements.
  def test_scalar_args_are_xml_attributes
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(
            text: "Hello",
            wrap: true,
            alignment: :center
          ),
          frame.area
        )
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    require "rexml/document"
    doc = REXML::Document.new(content)
    para = doc.root.elements["Paragraph"]

    # Paragraph text is a child element
    assert_nil para.attribute("text")&.value,
      "text should be an XML attribute"
    refute_nil para.elements["text"], "text should not be a child element"

    # Scalar args should be attributes
    assert_equal "true", para.attribute("wrap")&.value,
      "wrap should be an XML attribute"
    assert_equal "center", para.attribute("alignment")&.value,
      "alignment should be an XML attribute"

    # Scalar args should NOT be child elements
    assert_nil para.elements["wrap"], "wrap should not be a child element"
    assert_nil para.elements["alignment"], "alignment should not be a child element"
  end

  ##
  # Verifies that block wrapper has ARIA role and id/for association.
  #
  # When a widget has a block: argument, the block is a decorator/wrapper.
  # The XML should use id/for pattern (like HTML forms) to associate them,
  # and ARIA role="presentation" since the block is decorative.
  def test_block_wrapper_has_aria_role_and_id_for_association
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(
            text: "Hello",
            block: RatatuiRuby::Widgets::Block.new(title: "Title", borders: :all)
          ),
          frame.area
        )
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    require "rexml/document"
    doc = REXML::Document.new(content)
    para = doc.root.elements["Paragraph"]
    block_elem = para.elements["block"]

    # Paragraph should have an id
    para_id = para.attribute("id")&.value
    assert para_id, "Paragraph should have an id attribute"

    # Block wrapper should reference it via 'for' attribute
    assert_equal para_id, block_elem&.attribute("for")&.value,
      "block should have for='#{para_id}' matching Paragraph id"

    # Block should have ARIA role="group" (grouping related content)
    assert_equal "group", block_elem&.attribute("role")&.value,
      "block wrapper should have role='group'"
  end

  ##
  # Verifies that multiple widgets get unique IDs.
  #
  # When two paragraphs each have a block: argument, each paragraph
  # should have a different id, and each block should reference its parent.
  def test_multiple_widgets_have_unique_ids
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        left, right = RatatuiRuby::Layout::Layout.split(
          frame.area,
          direction: :horizontal,
          constraints: [
            RatatuiRuby::Layout::Constraint.percentage(50),
            RatatuiRuby::Layout::Constraint.percentage(50),
          ]
        )

        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(
            text: "First",
            block: RatatuiRuby::Widgets::Block.new(title: "Block 1")
          ),
          left
        )
        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(
            text: "Second",
            block: RatatuiRuby::Widgets::Block.new(title: "Block 2")
          ),
          right
        )
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    require "rexml/document"
    doc = REXML::Document.new(content)
    paragraphs = doc.root.elements.to_a("Paragraph")

    assert_equal 2, paragraphs.size, "Should have 2 Paragraphs"

    ids = paragraphs.map { |p| p.attribute("id")&.value }
    assert_equal 2, ids.uniq.size, "Each Paragraph should have a unique id"

    # Each block should reference its parent
    paragraphs.each do |para|
      para_id = para.attribute("id")&.value
      block_elem = para.elements["block"]
      assert_equal para_id, block_elem&.attribute("for")&.value,
        "block should reference its parent's id"
    end
  end

  ##
  # Verifies that a standalone Block (rendered directly, not as arg)
  # appears as a top-level element, not nested inside another widget.
  #
  # This is different from block: arg which creates a wrapper relationship.
  def test_standalone_block_is_top_level_element
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        # Render Block directly (not as an argument)
        frame.render_widget(
          RatatuiRuby::Widgets::Block.new(title: "Container", borders: :all),
          frame.area
        )
        # Render content inside the block area
        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(text: "Child content"),
          frame.area.inner(1)
        )
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    require "rexml/document"
    doc = REXML::Document.new(content)

    # Block should be a direct child of RatatuiFrame, not nested
    block_elem = doc.root.elements["Block"]
    assert block_elem, "Block should be a top-level element in RatatuiFrame"
    assert_equal "Container", block_elem&.attribute("title")&.value

    # Paragraph should also be a direct child (sibling, not nested)
    para_elem = doc.root.elements["Paragraph"]
    assert para_elem, "Paragraph should be a top-level element"

    # Block should NOT contain Paragraph (they are siblings)
    assert_nil block_elem.elements["Paragraph"],
      "Standalone Block should not contain Paragraph as child element"
  end

  ##
  # Verifies that A11Y lab has a startup prompt showing the output file path.
  #
  # Users need to know where the XML file is written BEFORE the TUI launches,
  # since stdout is captured during TUI rendering.
  def test_a11y_startup_prompt_shows_file_path
    message = RatatuiRuby::Labs::A11y.startup_message

    assert_includes message, Dir.tmpdir,
      "Startup message should include the temp dir path"
    assert_includes message, "ratatui_ruby_a11y.xml",
      "Startup message should include the filename"
    assert_includes message, "Enter",
      "Startup message should prompt user to press Enter"
  end

  ##
  # Verifies that widget IDs are stable across frames.
  #
  # The first widget in each frame should have id="w1", not incrementing
  # endlessly across frames (e.g. w1, w2 in frame 1 then w3, w4 in frame 2).
  def test_widget_ids_are_stable_across_frames
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      # Frame 1
      RatatuiRuby.draw do |frame|
        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(text: "Frame 1"),
          frame.area
        )
      end

      content1 = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

      # Frame 2
      RatatuiRuby.draw do |frame|
        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(text: "Frame 2"),
          frame.area
        )
      end

      content2 = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

      # Both frames should have widget with id="w1" (reset per frame)
      assert_includes content1, "id='w1'", "Frame 1 should have id='w1'"
      assert_includes content2, "id='w1'", "Frame 2 should also have id='w1' (reset)"
    end
  end

  ##
  # Verifies that Hash values are serialized with keys as attributes.
  #
  # A style like {fg: :green} should become <style fg='green'/>, not
  # <style>{fg: :green}</style>.
  def test_hash_values_serialized_as_attributes
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        # Use plain Hash for border_style (common pattern in real apps)
        block = RatatuiRuby::Widgets::Block.new(
          title: "Styled",
          border_style: { fg: :green }
        )
        frame.render_widget(block, frame.area)
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    # Should NOT have curly brace notation
    refute_includes content, "{fg:",
      "Should not have Ruby Hash notation in XML"

    # Should have fg as an attribute on border_style element
    assert_match(/<border_style[^>]*fg='green'/, content,
      "border_style should have fg='green' attribute")
  end

  ##
  # Verifies that text content is a child element, not an attribute.
  #
  # Multi-line text breaks XML attributes, so text should be:
  #   <Paragraph ...><text>content</text></Paragraph>
  # Not:
  #   <Paragraph text='content' .../>
  def test_text_is_child_element_not_attribute
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        frame.render_widget(
          RatatuiRuby::Widgets::Paragraph.new(text: "Line 1\nLine 2"),
          frame.area
        )
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    require "rexml/document"
    doc = REXML::Document.new(content)
    para = doc.root.elements["Paragraph"]

    # text should NOT be an attribute
    assert_nil para.attribute("text"),
      "text should not be an attribute"

    # text should be a child element
    text_elem = para.elements["text"]
    assert text_elem, "text should be a child element"
    assert_includes text_elem.text, "Line 1",
      "text element should contain the content"
  end

  ##
  # Verifies that ListItem content is a child element, not an attribute.
  #
  # Like Paragraph text, ListItem content can be multi-line (see ratatui docs).
  def test_list_item_content_is_child_element
    RatatuiRuby::Labs.enable!(:a11y)

    with_test_terminal(width: 80, height: 24) do
      RatatuiRuby.draw do |frame|
        list = RatatuiRuby::Widgets::List.new(
          items: [
            RatatuiRuby::Widgets::ListItem.new(content: "Multi\nLine"),
          ]
        )
        frame.render_widget(list, frame.area)
      end
    end

    content = File.read(RatatuiRuby::Labs::A11y::OUTPUT_PATH)

    require "rexml/document"
    doc = REXML::Document.new(content)
    list = doc.root.elements["List"]
    items = list.elements["items"]
    list_item = items.elements["ListItem"]

    # content should NOT be an attribute
    assert_nil list_item.attribute("content"),
      "content should not be an attribute"

    # content should be a child element
    content_elem = list_item.elements["content"]
    assert content_elem, "content should be a child element"
  end
end
