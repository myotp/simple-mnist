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

    Enum.each(0..4, fn i ->
      all
      |> Nx.slice_along_axis(i, 1)
      |> Nx.reshape({1, 1, 28, 28})
      |> Nx.to_heatmap()
      |> IO.inspect(label: "heatmap")
    end)
  end

  def demo_binary_to_heatmap() do
    <<_::32, _n::32, _r::32, _c::32, first_digit::binary-size(28 * 28), _::binary>> =
      read_and_unzip!("train-images-idx3-ubyte.gz")

    binary_to_heatmap(first_digit)
  end

  defp binary_to_heatmap(image_binary) do
    image_binary
    |> Nx.from_binary({:u, 8})
    |> Nx.reshape({1, 1, 28, 28})
    |> Nx.divide(255)
    |> Nx.to_heatmap()
  end

  defp read_and_unzip!(filename) do
    filename
    |> File.read!()
    |> :zlib.gunzip()
  end
end
