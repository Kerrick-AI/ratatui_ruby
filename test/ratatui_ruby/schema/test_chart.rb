# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "ratatui_ruby"
require "minitest/autorun"
require_relative "../../test_helper"

module RatatuiRuby
  class TestChart < Minitest::Test
    include RatatuiRuby::TestHelper
    def setup
      RatatuiRuby.init_test_terminal(80, 24)
    end

    def test_chart_rendering
      datasets = [
        Widgets::Dataset.new(
          name: "TestDS",
          data: [[0.0, 0.0], [10.0, 10.0]],
          style: Style::Style.new(fg: :red),
          marker: :dot,
        ),
      ]

      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(title: "Time", bounds: [0.0, 10.0], labels: %w[0 10]),
        y_axis: Widgets::Axis.new(title: "Value", bounds: [0.0, 10.0], labels: %w[0 10]),
        block: Widgets::Block.new(title: "Test Chart"),
      )

      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      buffer = RatatuiRuby.get_buffer_content

      # Check for axis titles
      assert_includes buffer, "Time"
      assert_includes buffer, "Value"
      # Check for block title
      assert_includes buffer, "Test Chart"
      # Check for dataset name
      assert_includes buffer, "TestDS"
      # Check for labels
      assert_includes buffer, "0"
      assert_includes buffer, "10"
    end

    def test_axis_labels_alignment
      datasets = [
        Widgets::Dataset.new(
          name: "TestDS",
          data: [[0.0, 0.0], [10.0, 10.0]],
          style: Style::Style.new(fg: :green),
          marker: :dot,
        ),
      ]

      # Test with centered X-axis labels and right-aligned Y-axis labels
      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(
          title: "Time",
          bounds: [0.0, 10.0],
          labels: %w[0 5 10],
          labels_alignment: :center,
        ),
        y_axis: Widgets::Axis.new(
          title: "Value",
          bounds: [0.0, 10.0],
          labels: %w[0 5 10],
          labels_alignment: :right,
        ),
        block: Widgets::Block.new(title: "Aligned Chart"),
      )

      RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
      buffer = RatatuiRuby.get_buffer_content

      # Verify the chart renders with alignment settings
      assert_includes buffer, "Time"
      assert_includes buffer, "Value"
      assert_includes buffer, "Aligned Chart"
      assert_includes buffer, "TestDS"
    end

    def test_styled_axis_title_renders_content_not_inspect_string
      styled_title = Text::Line.new(
        spans: [Text::Span.new(content: "StyledTime", style: Style::Style.new(fg: :cyan))]
      )

      datasets = [
        Widgets::Dataset.new(name: "DS1", data: [[0.0, 0.0], [10.0, 10.0]], marker: :dot),
      ]

      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(title: styled_title, bounds: [0.0, 10.0]),
        y_axis: Widgets::Axis.new(bounds: [0.0, 10.0])
      )

      with_test_terminal(40, 10) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        content = buffer_content.join("\n")

        # Should render the styled title content, not inspect string
        assert_includes content, "StyledTime", "Styled axis title should appear in output"
        refute_includes content, "#<data", "Inspect string should not appear"

        # Verify styling (cyan = ANSI 36)
        ansi_output = render_rich_buffer
        assert_includes ansi_output, "\e[36m", "Axis title should have cyan foreground"
      end
    end

    def test_styled_dataset_name_renders_content_not_inspect_string
      styled_name = Text::Line.new(
        spans: [Text::Span.new(content: "StyledDS", style: Style::Style.new(fg: :green))]
      )

      datasets = [
        Widgets::Dataset.new(name: styled_name, data: [[0.0, 0.0], [10.0, 10.0]], marker: :dot),
      ]

      chart = Widgets::Chart.new(
        datasets:,
        x_axis: Widgets::Axis.new(bounds: [0.0, 10.0]),
        y_axis: Widgets::Axis.new(bounds: [0.0, 10.0])
      )

      with_test_terminal(40, 10) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        content = buffer_content.join("\n")

        # Should render the styled dataset name, not inspect string
        assert_includes content, "StyledDS", "Styled dataset name should appear in output"
        refute_includes content, "#<data", "Inspect string should not appear"

        # Verify styling (green = ANSI 32)
        ansi_output = render_rich_buffer
        assert_includes ansi_output, "\e[32m", "Dataset name should have green foreground"
      end
    end

    # Edge-center legend positions: :top, :bottom, :left, :right
    # These complement the corner positions (:top_left, :top_right, :bottom_left, :bottom_right)

    def test_legend_position_top
      chart = chart_with_legend_position(:top)

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshot("legend_position_top")
      end
    end

    def test_legend_position_bottom
      chart = chart_with_legend_position(:bottom)

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshot("legend_position_bottom")
      end
    end

    def test_legend_position_left
      chart = chart_with_legend_position(:left)

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshot("legend_position_left")
      end
    end

    def test_legend_position_right
      chart = chart_with_legend_position(:right)

      with_test_terminal(30, 12) do
        RatatuiRuby.draw { |f| f.render_widget(chart, f.area) }
        assert_snapshot("legend_position_right")
      end
    end

    private def chart_with_legend_position(position)
      Widgets::Chart.new(
        datasets: [Widgets::Dataset.new(name: "DS", data: [[0.0, 0.0], [10.0, 10.0]], marker: :dot)],
        x_axis: Widgets::Axis.new(bounds: [0.0, 10.0]),
        y_axis: Widgets::Axis.new(bounds: [0.0, 10.0]),
        legend_position: position
      )
    end
  end
end
