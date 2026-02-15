# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "tmpdir"

module RatatuiRuby
  module Labs
    # A11Y lab: exports widget tree as XML.
    #
    # Writes an XML representation of the widget tree to a temporary file
    # every frame when enabled.
    module A11y
      # Path to the XML output file in the system temp directory.
      OUTPUT_PATH = File.join(Dir.tmpdir, "ratatui_ruby_a11y.xml").freeze

      class << self
        # Dumps the widget tree to XML (single widget for tree mode).
        def dump_widget_tree(widget, _area = nil)
          ensure_rexml_loaded
          doc = REXML::Document.new
          doc.add(REXML::XMLDecl.new("1.0", "UTF-8"))
          doc.add(build_element(widget))
          write_document(doc)
        end

        # Returns startup message for users to see before TUI launches.
        #
        # Since stdout is captured during TUI rendering, users need to know
        # where the XML file will be written before the app starts.
        def startup_message
          <<~MSG
            A11Y Lab enabled! Widget tree will be written to:
              #{OUTPUT_PATH}

            Press Enter to launch the TUI...
          MSG
        end

        # Dumps multiple widgets captured from Frame API mode.
        def dump_widgets(widgets_with_areas)
          ensure_rexml_loaded
          Labs.warn_once!("Labs::A11y (RR_LABS=A11Y)")

          # Reset counter each frame for stable IDs
          @widget_id_counter = 0

          doc = REXML::Document.new
          doc.add(REXML::XMLDecl.new("1.0", "UTF-8"))

          frame = REXML::Element.new("RatatuiFrame")
          widgets_with_areas.each do |widget, area|
            frame.add(build_element_with_area(widget, area))
          end
          doc.add(frame)

          write_document(doc)
        end

        private def write_document(doc)
          output = +""
          formatter = REXML::Formatters::Pretty.new(2)
          formatter.compact = true
          formatter.write(doc, output)
          File.write(OUTPUT_PATH, output)
        end

        private def build_element_with_area(widget, area)
          class_name = widget.class.name&.split("::")&.last || "Unknown"
          element = REXML::Element.new(class_name)

          # Generate unique id for this widget
          @widget_id_counter ||= 0
          @widget_id_counter += 1
          widget_id = "w#{@widget_id_counter}"
          element.add_attribute("id", widget_id)

          # Add area attributes
          element.add_attribute("x", area.x.to_s)
          element.add_attribute("y", area.y.to_s)
          element.add_attribute("width", area.width.to_s)
          element.add_attribute("height", area.height.to_s)

          add_members(element, widget, parent_id: widget_id)
          element
        end

        private def build_element(node)
          class_name = node.class.name&.split("::")&.last || "Unknown"
          element = REXML::Element.new(class_name)

          if node.respond_to?(:to_h) && node.respond_to?(:members)
            add_members(element, node)
          else
            element.text = node.to_s
          end

          element
        end

        private def add_members(element, node, parent_id: nil)
          return unless node.respond_to?(:to_h) && node.respond_to?(:members)

          node.to_h.each do |key, value|
            # Skip nil and empty values entirely (no noise in output)
            next if value.nil?
            next if value.respond_to?(:empty?) && value.empty?

            # Skip objects where all members are nil/empty (like default Style)
            if value.respond_to?(:to_h) && value.respond_to?(:members)
              attrs = value.to_h.compact
              next if attrs.empty? || attrs.values.all? { |v| v.respond_to?(:empty?) && v.empty? }
            end

            # Scalar values → XML attributes
            # Exception: 'text' and 'content' accept Text (multi-line capable)
            # Complex values → XML child elements
            multiline_keys = %w[text content]
            if scalar?(value) && !multiline_keys.include?(key.to_s)
              element.add_attribute(key.to_s, value.to_s)
            else
              # Special handling for 'block' wrapper - add ARIA role and id/for
              is_block_wrapper = key.to_s == "block" && parent_id
              child = build_child_element(key, value, is_wrapper: is_block_wrapper, parent_id:)
              element.add(child) if child
            end
          end
        end

        private def scalar?(value)
          case value
          when String, Symbol, Numeric, TrueClass, FalseClass
            true
          else
            false
          end
        end

        private def build_child_element(key, value, is_wrapper: false, parent_id: nil)
          element = REXML::Element.new(key.to_s)

          # Add ARIA role and id/for association for block wrappers
          if is_wrapper && parent_id
            element.add_attribute("role", "group")
            element.add_attribute("for", parent_id)
          end

          case value
          when Array
            value.each { |item| element.add(build_element(item)) }
          when Hash
            # Plain Hash: serialize keys as attributes
            value.each do |k, v|
              next if v.nil?
              next if v.respond_to?(:empty?) && v.empty?
              element.add_attribute(k.to_s, v.to_s)
            end
          else
            if value.respond_to?(:to_h) && value.respond_to?(:members)
              add_members(element, value)
            else
              element.text = value.to_s
            end
          end

          element
        end

        # Lazily loads REXML when first needed.
        private def ensure_rexml_loaded
          return if defined?(@rexml_loaded) && @rexml_loaded

          require "rexml/document"
          @rexml_loaded = true
        end
      end
    end
  end
end
