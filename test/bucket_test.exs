defmodule KV.BucketTest do
    use ExUnit.Case, async: true

    setup do
        {:ok, bucket} = start_supervised KV.Bucket
        %{bucket: bucket}
    end

    test "stores values by key", %{bucket: bucket} do
        assert KV.Bucket.get(bucket, :milk) == nil

        KV.Bucket.put(bucket, :milk, 3)
        assert KV.Bucket.get(bucket, :milk) == 3

    end

    test "delete value by key and return deleted valued", %{bucket: bucket} do
        KV.Bucket.put(bucket, :milk, 10)
        assert KV.Bucket.delete(bucket, :milk) == 10
    end
end
