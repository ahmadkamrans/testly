defmodule Testly.Heatmaps.ViewsCleaner do
  use GenServer, shutdown: 5000

  require Logger

  alias Testly.Repo
  alias Testly.Heatmaps

  @frequence_seconds 60
  @delete_batch_size 1_000

  # credo:disable-for-next-line
  def start_link(_args) do
    :global.trans(
      {__MODULE__, __MODULE__},
      fn ->
        case GenServer.start_link(__MODULE__, :ok, name: {:global, __MODULE__}) do
          {:ok, pid} ->
            {:ok, pid}

          {:error, {:already_started, pid}} ->
            Process.link(pid)
            {:ok, pid}

          error ->
            error
        end
      end,
      Node.list(:connected),
      5
    )
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)

    send(self(), :clean)

    {:ok, nil}
  end

  def handle_info(:clean, state) do
    start_time = DateTime.utc_now()

    {:ok, deleted_count} =
      Repo.transaction(
        fn ->
          Heatmaps.get_staled_view_ids(limit: @delete_batch_size)
          |> Heatmaps.delete_views()
        end,
        timeout: :infinity
      )

    finish_time = DateTime.utc_now()

    duration = Timex.format_duration(Timex.diff(finish_time, start_time, :duration), :humanized)

    Logger.info("[ViewsCleaner] #{deleted_count} recordings are deleted, it took #{duration}")

    delay_clean(if(@delete_batch_size === deleted_count, do: 0, else: @frequence_seconds))

    {:noreply, state}
  end

  defp delay_clean(after_seconds) do
    Process.send_after(self(), :clean, after_seconds * 1000)
  end
end
