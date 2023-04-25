defmodule Testly.SplitTestsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.SplitTests.{
        SplitTest,
        Variation,
        FinishCondition,
        PageType,
        PageCategory,
        VariationVisit
      }

      def split_test_page_type_factory do
        %PageType{
          name: sequence(:name, &"PageType#{&1}")
        }
      end

      def split_test_page_category_factory do
        %PageCategory{
          name: sequence(:name, &"PageCategory#{&1}")
        }
      end

      def split_test_factory do
        %SplitTest{
          name: "Split test",
          page_type: build(:split_test_page_type),
          page_category: build(:split_test_page_category)
        }
      end

      def active_split_test_factory do
        build(:split_test, %{
          variations: [
            build(:split_test_control_variation),
            build(:split_test_variation)
          ],
          finish_condition: build(:split_test_visits_finish_condition),
          status: :active
        })
      end

      def split_test_variation_factory do
        %Variation{
          url: "http://example.com",
          name: "Variation"
        }
      end

      def split_test_variation_visit_factory do
        %VariationVisit{}
      end

      def split_test_control_variation_factory do
        build(:split_test_variation, %{control: true})
      end

      def split_test_visits_finish_condition_factory do
        %FinishCondition{
          type: :visits,
          count: 100
        }
      end
    end
  end
end
