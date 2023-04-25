defmodule Testly.SessionEvents.ProxyUrlReplacerTest do
  use ExUnit.Case, async: true

  alias Testly.SessionEvents.{
    ProxyUrlReplacer,
    DOMMutatedEvent,
    PageVisitedEvent,
    AddedOrMovedMutation,
    DOMNode,
    AttributeMutation,
    CharacterMutation,
    ElementAttribute
  }

  defp replace_for(data) do
    ProxyUrlReplacer.replace_for(data, fn _css -> "css_replaced" end, fn _url -> "url_replaced" end)
  end

  describe "replace_for dom snapshot" do
    test "replaces style tag, style attributes" do
      data = %PageVisitedEvent{
        data: %PageVisitedEvent.Data{
          dom_snapshot: %DOMNode{
            id: 123,
            node_type: DOMNode.node_type_id(:element_node),
            attributes: [
              %ElementAttribute{name: "style", value: "test2"},
              %ElementAttribute{name: "other", value: "red"},
              %ElementAttribute{name: "src", value: "data:image/png;base64,iVBOR"}
            ],
            tag_name: "html",
            child_nodes: [
              %DOMNode{
                id: 1234,
                node_type: DOMNode.node_type_id(:element_node),
                tag_name: "stYle",
                attributes: [
                  %ElementAttribute{name: "href", value: "http://google.com"},
                  %ElementAttribute{name: "src", value: "http://test.com"},
                  %ElementAttribute{name: "alt", value: "wow!"}
                ],
                child_nodes: [
                  %DOMNode{
                    id: 12_345,
                    node_type: DOMNode.node_type_id(:text_node),
                    parent_tag: "stYle",
                    data: "color: red"
                  }
                ]
              }
            ]
          }
        }
      }

      assert replace_for(data) === %PageVisitedEvent{
               data: %PageVisitedEvent.Data{
                 dom_snapshot: %DOMNode{
                   id: 123,
                   node_type: DOMNode.node_type_id(:element_node),
                   attributes: [
                    %ElementAttribute{name: "style", value: "css_replaced"},
                    %ElementAttribute{name: "other", value: "red"},
                    %ElementAttribute{name: "src", value: "data:image/png;base64,iVBOR"}
                  ],
                   tag_name: "html",
                   child_nodes: [
                     %DOMNode{
                       id: 1234,
                       node_type: DOMNode.node_type_id(:element_node),
                       tag_name: "stYle",
                       attributes: [
                         %ElementAttribute{name: "href", value: "url_replaced"},
                         %ElementAttribute{name: "src", value: "url_replaced"},
                         %ElementAttribute{name: "alt", value: "wow!"}
                       ],
                       child_nodes: [
                         %DOMNode{
                           id: 12_345,
                           node_type: DOMNode.node_type_id(:text_node),
                           parent_tag: "stYle",
                           data: "css_replaced"
                         }
                       ]
                     }
                   ]
                 }
               }
             }
    end
  end

  describe "replace_for dom mutation" do
    test "replaces for nodes" do
      data = %DOMMutatedEvent{
        data: %DOMMutatedEvent.Data{
          added_or_moved: [
            %AddedOrMovedMutation{
              node: %DOMNode{
                node_type: DOMNode.node_type_id(:text_node),
                attributes: [
                  %ElementAttribute{name: "style", value: "test2"},
                  %ElementAttribute{name: "other", value: "red"}
                ],
                parent_tag: "StYlE",
                data: "test",
                id: 123
              }
            }
          ]
        }
      }

      assert replace_for(data) === %DOMMutatedEvent{
               data: %DOMMutatedEvent.Data{
                 added_or_moved: [
                   %AddedOrMovedMutation{
                     node: %DOMNode{
                       node_type: DOMNode.node_type_id(:text_node),
                       attributes: [
                        %ElementAttribute{name: "style", value: "css_replaced"},
                        %ElementAttribute{name: "other", value: "red"}
                       ],
                       parent_tag: "StYlE",
                       data: "css_replaced",
                       id: 123
                     }
                   }
                 ]
               }
             }
    end

    test "replaces for attributes mutations" do
      data = %DOMMutatedEvent{
        data: %DOMMutatedEvent.Data{
          attributes: [
            %AttributeMutation{
              id: 123,
              name: "StYlE",
              value: "color: red;"
            },
            %AttributeMutation{
              id: 123,
              name: "href",
              value: "http://test.com"
            }
          ]
        }
      }

      assert replace_for(data) === %DOMMutatedEvent{
               data: %DOMMutatedEvent.Data{
                 attributes: [
                   %AttributeMutation{
                     id: 123,
                     name: "StYlE",
                     value: "css_replaced"
                   },
                   %AttributeMutation{
                     id: 123,
                     name: "href",
                     value: "url_replaced"
                   }
                 ]
               }
             }
    end

    test "replaces for character mutations" do
      data = %DOMMutatedEvent{
        data: %DOMMutatedEvent.Data{
          character_data: [
            %CharacterMutation{
              id: 123,
              data: "color: red",
              parent_tag_name: "StYlE"
            },
            %CharacterMutation{
              id: 123,
              data: "color: red",
              parent_tag_name: "div"
            }
          ]
        }
      }

      assert replace_for(data) === %DOMMutatedEvent{
               data: %DOMMutatedEvent.Data{
                 character_data: [
                   %CharacterMutation{
                     id: 123,
                     data: "css_replaced",
                     parent_tag_name: "StYlE"
                   },
                   %CharacterMutation{
                     id: 123,
                     data: "color: red",
                     parent_tag_name: "div"
                   }
                 ]
               }
             }
    end
  end
end
