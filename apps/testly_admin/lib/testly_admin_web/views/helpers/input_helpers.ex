defmodule TestlyAdminWeb.InputHelpers do
  use Phoenix.HTML

  def checkbox_input(form, field, _opts \\ []) do
    content_tag :div, class: "form-check" do
      [
        checkbox(form, field, class: "form-check-input"),
        label(form, field)
      ]
    end
  end

  def input(form, field, opts \\ []) do
    # Code is not clean at all
    # If you have time to refactor - please, do it

    opts =
      Keyword.merge(
        opts,
        label: if(opts[:label] === nil, do: true, else: opts[:label]),
        input_opts:
          Keyword.merge(
            [
              type: Phoenix.HTML.Form.input_type(form, field),
              select_options: []
            ],
            opts[:input_opts] || []
          )
      )

    label = Keyword.get(opts, :label_value) || humanize(field)
    is_required = input_validations(form, field) |> Keyword.get(:required)
    has_errors = form.errors[field]

    content_tag :div, class: "form-group" do
      [
        if(opts[:label],
          do: label(form, field, label <> if(is_required, do: "*", else: "")),
          else: ""
        ),
        apply(
          Phoenix.HTML.Form,
          opts[:input_opts][:type],
          input_arguments(
            opts[:input_opts][:type],
            form,
            field,
            opts[:input_opts],
            Keyword.merge(
              [class: "form-control " <> if(has_errors, do: "is-invalid", else: "")],
              opts[:input_opts]
            )
          )
        ),
        TestlyAdminWeb.ErrorHelpers.error_tag(form, field)
      ]
    end
  end

  defp input_arguments(:select, form, field, opts, select_opts) do
    [form, field, opts[:select_options], Keyword.drop(select_opts, [:type, :select_options])]
  end

  defp input_arguments(:file_input, form, field, _opts, select_opts) do
    [
      form,
      field,
      select_opts
      |> Keyword.merge(class: String.replace(select_opts[:class], "form-control", "") <> " d-block")
      |> Keyword.drop([:type])
    ]
  end

  defp input_arguments(_type, form, field, _opts, select_opts) do
    [form, field, Keyword.drop(select_opts, [:type])]
  end
end
