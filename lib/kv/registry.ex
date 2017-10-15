defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Server Callbacks

  def init(:ok) do
    buckets = %{}
    refs  = %{}
    {:ok, {refs, buckets}}
  end


  def handle_call({:lookup, bucket}, _from, {_, buckets} = registry) do
    {:reply, Map.fetch(buckets, bucket), registry}
  end

  def handle_cast({:create, bucket}, {refs, buckets}) do
    if Map.has_key?(buckets, bucket) do
      {:noreply, {refs, buckets}}
    else
      {:ok, pid} = KV.BucketSupervisor.start_bucket
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, bucket)
      buckets = Map.put(buckets, bucket, pid)
      {:noreply, {refs, buckets}}
    end
  end

  def handle_info({:DOWN, ref, :process, _, _reason}, {refs, buckets}) do
      {bucket, refs} = Map.pop(refs, ref)
      buckets = Map.delete(buckets, bucket)
      {:noreply, {refs, buckets} }
  end

  def handle_info(_msg, registry) do
      {:noreply, registry}
  end
end
