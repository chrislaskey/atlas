defmodule ArtemisLog.Worker.DeleteHttpRequestLogsOnInterval do
  use ArtemisLog.IntervalWorker,
    enabled: enabled?(),
    interval: get_interval(),
    delayed_start: get_interval(),
    name: :http_request_log_history_on_interval

  alias Artemis.GetSystemUser
  alias ArtemisLog.DeleteAllHttpRequestLogsOlderThan

  # Callbacks

  @impl true
  def call(_data, _config) do
    user = GetSystemUser.call()
    interval = get_max_days() * 24 * 60 * 60

    timestamp =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.-(interval)
      |> DateTime.from_unix!(:second)

    DeleteAllHttpRequestLogsOlderThan.call(timestamp, user)
  end

  # Helpers

  defp enabled?() do
    :artemis_log
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:delete_http_request_logs_on_interval)
    |> Keyword.fetch!(:enabled)
    |> String.downcase()
    |> String.equivalent?("true")
  end

  defp get_max_days() do
    :artemis_log
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:delete_http_request_logs_on_interval)
    |> Keyword.fetch!(:max_days)
    |> String.to_integer()
  end

  defp get_interval(), do: :timer.hours(4)
end
