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
  end
end
