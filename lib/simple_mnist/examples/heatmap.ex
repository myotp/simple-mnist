defmodule SimpleMnist.Examples.Heatmap do
  # 前5个训练images的数字50419对应的heatmap
  def demo() do
    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      read_and_unzip!("train-images-idx3-ubyte.gz")

    all =
      images
      |> Nx.from_binary({:u, 8})
      |> Nx.reshape({n_images, 1, n_rows, n_cols})
      |> Nx.divide(255)

    Enum.map(0..4, fn i ->
      all
      |> Nx.slice_along_axis(i, 1)
      |> Nx.reshape({1, 1, 28, 28})
      |> Nx.to_heatmap()
    end)
  end

  defp read_and_unzip!(filename) do
    filename
    |> File.read!()
    |> :zlib.gunzip()
  end
end
