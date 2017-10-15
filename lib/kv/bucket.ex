defmodule KV.Bucket do
    use Agent, restart: :temporary

    @doc """
    Starts a new bucket
    """
    def start_link(_opts) do
        Agent.start_link(fn -> %{} end)
    end

    @doc """
    Gets an item from the bucket
    """
    def get(bucket, key)  do
        Agent.get(bucket, &Map.get(&1, key))
    end

    @doc """
    Puts an item in the bucket
    """
    def put(bucket, key, value) do
        Agent.update(bucket, &Map.put(&1, key, value))
    end

    @doc """
    Deletes a key from the bucket and returns its value
    """
    def delete(bucket, key) do
        Agent.get_and_update(bucket, &Map.pop(&1, key))
    end
end
