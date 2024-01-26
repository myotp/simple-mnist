defmodule SimpleMnist.Examples.MnistTrain do
  alias SimpleMnist.MNIST

  def run_with_exla() do
    Nx.global_default_backend(EXLA.Backend)

    {train_images, train_labels} =
      MNIST.load("train-images-idx3-ubyte.gz", "train-labels-idx1-ubyte.gz")

    IO.puts("Initializing parameters...\n")
    params = MNIST.init_random_params()

    IO.puts("Wrap the training function in JIT")
    fun = EXLA.jit(&MNIST.update_with_averages/6)

    IO.puts("Training MNIST for 10 epochs...\n\n")
    final_params = MNIST.train(fun, train_images, train_labels, params, epochs: 10)

    IO.puts("Bring the parameters back from the device and print them")
    final_params = Nx.backend_transfer(final_params)
    IO.inspect(final_params, label: "FINAL Params")

    IO.puts("The result of the first batch against the trained network")
    IO.inspect(EXLA.jit(&MNIST.predict/2).(final_params, hd(Enum.to_list(train_images))))
    final_params
  end

  def run_test(params) do
    {images, labels} = load_test()

    Enum.each(0..10, fn i ->
      image = Nx.slice_along_axis(images, i, 1)
      label = Nx.slice_along_axis(labels, i, 1)
      {image, label}

      result =
        MNIST.predict(params, image)
        |> Nx.to_flat_list()
        |> output_to_number()

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
