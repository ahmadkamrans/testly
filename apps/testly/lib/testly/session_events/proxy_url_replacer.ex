defmodule Testly.SessionEvents.ProxyUrlReplacer do
  @moduledoc """
  It will replace URLs in DOM for:
  1) <style></style> content
  2) style="" tag attribute

  NOTE: mot sure if it good to depend on `Page` rather than `url_changed` event
  """

  alias Testly.SessionEvents.{
    PageVisitedEvent,
    DOMMutatedEvent,
    DOMNode,
    AttributeMutation,
    AddedOrMovedMutation,
    CharacterMutation,
    ElementAttribute
  }

  def replace_for(%PageVisitedEvent{} = event, css_replacer, url_replacer) do
    %PageVisitedEvent{
      event
      | data: %PageVisitedEvent.Data{
          event.data
          | dom_snapshot: traverse_node(event.data.dom_snapshot, css_replacer, url_replacer)
        }
    }
  end

  def replace_for(%DOMMutatedEvent{} = event, css_replacer, url_replacer) do
    added_or_moved = event.data.added_or_moved
    attributes = event.data.attributes
    character_data = event.data.character_data

    added_or_moved =
      if added_or_moved do
        for %AddedOrMovedMutation{node: node} = mutation <- added_or_moved do
          %AddedOrMovedMutation{mutation | node: traverse_node(node, css_replacer, url_replacer)}
        end
      else
        added_or_moved
      end

    attributes =
      if attributes do
        for %AttributeMutation{name: name, value: value} = attr <- attributes do
          %AttributeMutation{
            attr
            | value: replace_attr_value(name, value, css_replacer, url_replacer)
          }
        end
      else
        attributes
      end

    character_data =
      if character_data do
        for %CharacterMutation{parent_tag_name: parent_tag_name, data: data} = mutation <- character_data do
          %CharacterMutation{
            mutation
            | data: if(String.downcase(parent_tag_name) === "style", do: css_replacer.(data), else: data)
          }
        end
      else
        character_data
      end

    %DOMMutatedEvent{
      event
      | data: %DOMMutatedEvent.Data{
          event.data
          | added_or_moved: added_or_moved,
            attributes: attributes,
            character_data: character_data
        }
    }
  end

  defp traverse_node(
         %DOMNode{
           parent_tag: parent_tag,
           child_nodes: child_nodes,
           attributes: attributes,
           data: data
         } = node,
         css_replacer,
         url_replacer
       ) do
    data =
      if String.downcase(parent_tag || "") === "style" do
        css_replacer.(data)
      else
        data
      end

    child_nodes = child_nodes && Enum.map(child_nodes, &traverse_node(&1, css_replacer, url_replacer))

    attributes =
      attributes &&
        for attribute <- attributes do
          %ElementAttribute{attribute | value: replace_attr_value(attribute.name, attribute.value, css_replacer, url_replacer)}
        end

    %DOMNode{node | data: data, child_nodes: child_nodes, attributes: attributes}
  end

  defp replace_attr_value(name, value, css_replacer, url_replacer) do
    name = String.downcase(name)

    start_of_value =
      value
      |> String.slice(0..20)
      |> String.trim_leading()
      |> String.downcase()

    cond do
      name in ["href", "src"] &&
      !String.starts_with?(start_of_value, "data") &&
      !String.starts_with?(start_of_value, "blob") ->
        url_replacer.(value)

      name === "style" ->
        css_replacer.(value)

      true ->
        value
    end
  end
end
