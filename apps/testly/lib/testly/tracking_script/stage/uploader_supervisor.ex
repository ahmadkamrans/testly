defmodule Testly.TrackingScript.UploaderSupervisor do
  @moduledoc """
    The Uploader Consumer Supervisor. Demands scripts from Collector.
  """
  use ConsumerSupervisor
  require Logger

  alias Testly.TrackingScript.{Collector, Uploader}

  @min_demand 1
  @max_demand 5

  def start_link(args \\ [], opts) do
    ConsumerSupervisor.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    producer = args[:producer] || Collector

    children = [
      %{id: Uploader, start: {Uploader, :start_link, []}, restart: :temporary}
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{producer, min_demand: @min_demand, max_demand: @max_demand}]
    ]

    Logger.info("Start Testly.TrackingScript.UploaderSupervisor")
    ConsumerSupervisor.init(children, opts)
  end
end
