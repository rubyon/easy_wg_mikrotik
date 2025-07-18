module RuboCop
  module Cop
    module Layout
      class SpaceInsidePercentLiteralBrackets < Base
        MSG = 'Use spaces inside `%w[ first second ]`.'

        def on_array(node)
          return unless node.percent_literal? && node.loc.expression.source =~ /^%w\[(.+)\]$/

          space_inside = node.loc.expression.source =~ /\[%s+/
          add_offense(node, message: MSG) unless space_inside
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, node.loc.expression.source.gsub('%w[', '%w[ ').gsub(']', ' ]'))
          end
        end
      end
    end
  end
end
