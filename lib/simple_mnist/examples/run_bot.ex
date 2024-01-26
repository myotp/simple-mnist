defmodule SimpleMnist.Examples.RunBot do
  alias SimpleMnist.MnistBot

  def run_test() do
    {images, labels} = load_test()

    Enum.each(0..10, fn i ->
      image = Nx.slice_along_axis(images, i, 1)
      label = Nx.slice_along_axis(labels, i, 1)
      {image, label}

      {:ok, result} = MnistBot.predict(image)

      expected =
        label
        |> Nx.to_flat_list()
        |> output_to_number()

      IO.puts("第#{i}个: Predict结果:#{result} 标准答案:#{expected}")
    end)
  end

  def output_to_number(ten_nums) do
    ten_nums
    |> Enum.zip(0..9)
    |> Enum.sort(:desc)
    |> hd()
    |> elem(1)
  end

  def load_test(
        images_file \\ "t10k-images-idx3-ubyte.gz",
        labels_file \\ "t10k-labels-idx1-ubyte.gz"
      ) do
    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      read_and_unzip!(images_file)

    train_images =
      images
      |> Nx.from_binary({:u, 8})
      |> Nx.reshape({n_images, n_rows * n_cols}, names: [:batch, :input])
      |> Nx.divide(255)

    IO.puts("#{n_images} #{n_rows}x#{n_cols} images\n")

    <<_::32, n_labels::32, labels::binary>> = read_and_unzip!(labels_file)

    train_labels =
      labels
      |> Nx.from_binary({:u, 8})
      |> Nx.reshape({n_labels, 1}, names: [:batch, :output])
      |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))

    IO.puts("#{n_labels} labels\n")

    {train_images, train_labels}
  end

  defp read_and_unzip!(filename) do
    filename
    |> File.read!()
    |> :zlib.gunzip()
  end
end
