defmodule Testly.SplitTestsFactory do
  defmacro __using__(_opts) do
    quote do
      alias Testly.SplitTests.{
        SplitTest,
        Variation,
        FinishConditionDb,
        PageType,
        PageCategory,
        VariationVisit
      }

      def page_type_factory do
        %PageType{
          name: sequence(:name, &"PageType#{&1}")
        }
      end

      def page_category_factory do
        %PageCategory{
          name: sequence(:name, &"PageCategory#{&1}")
        }
      end

      def split_test_factory do
        %SplitTest{
          name: "Split test",
          page_type: build(:page_type),
          page_category: build(:page_category)
        }
      end

      def active_split_test_factory do
        build(:split_test, %{
          variations: [
            build(:split_test_control_variation),
            build(:split_test_variation)
          ],
          finish_condition_db: build(:visits_finish_condition_db),
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
        %VariationVisit{
          visited_at: DateTime.utc_now()
        }
      end

      def split_test_control_variation_factory do
        build(:split_test_variation, %{control: true})
      end

      def visits_finish_condition_db_factory do
        %FinishConditionDb{
          type: :visits,
          count: 100
        }
      end
    end
  end
end
