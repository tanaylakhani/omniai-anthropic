# frozen_string_literal: true

module OmniAI
  module Anthropic
    class Chat
      # Overrides message serialize / deserialize.
      module MessageSerializer
        # @param message [OmniAI::Chat::Message]
        # @param context [OmniAI::Context]
        # @return [Hash]
        def self.serialize(message, context:)
          role = message.role
          parts = arrayify(message.content) + arrayify(message.tool_call_list)
          content = parts.map do |part|
            case part
            when String then { type: 'text', text: part }
            else part.serialize(context:)
            end
          end

          { role:, content: }
        end

        # @param data [Hash]
        # @param context [OmniAI::Context]
        # @return [OmniAI::Chat::Message]
        def self.deserialize(data, context:)
          role = data['role']
          parts = arrayify(data['content']).map do |content|
            ContentSerializer.deserialize(content, context:)
          end

          tool_call_list = parts.select { |part| part.is_a?(OmniAI::Chat::ToolCall) }
          content = parts.reject { |part| part.is_a?(OmniAI::Chat::ToolCall) }

          OmniAI::Chat::Message.new(content:, role:, tool_call_list:)
        end

        # @param content [Object]
        # @return [Array<Object>]
        def self.arrayify(content)
          return [] if content.nil?

          content.is_a?(Array) ? content : [content]
        end
      end
    end
  end
end