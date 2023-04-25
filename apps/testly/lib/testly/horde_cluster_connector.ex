defmodule Testly.HordeClusterConnector do
  def connect(node) do
    case :net_kernel.connect_node(node) do
      true ->
        Horde.Cluster.join_hordes(
          Testly.DistributedSupervisor,
          {Testly.DistributedSupervisor, node}
        )

        Horde.Cluster.join_hordes(
          Testly.GlobalRegistry,
          {Testly.GlobalRegistry, node}
        )

        true

      other ->
        other
    end
  end
end
