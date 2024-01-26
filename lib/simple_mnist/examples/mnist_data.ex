defmodule SimpleMnist.Examples.MnistData do
  @train_image_file "train-images-idx3-ubyte.gz"
  @train_label_file "train-labels-idx1-ubyte.gz"
  @test_image_file "t10k-images-idx3-ubyte.gz"
  @test_label_file "t10k-labels-idx1-ubyte.gz"

  def demo() do
    IO.puts("== #{@train_label_file} ==")
    <<_::32, n_labels::32-big, labels::binary>> = read_and_unzip!(@train_label_file)
    IO.puts("在训练labels文件中共有#{n_labels}个label")
    <<a1, a2, a3, a4, a5, _::binary>> = labels
    IO.puts("前5个labels为 #{a1} #{a2} #{a3} #{a4} #{a5}")

    IO.puts("== #{@test_label_file} ==")
    <<_::32, n_labels::32-big, labels::binary>> = read_and_unzip!(@test_label_file)
    IO.puts("在验证labels文件中共有#{n_labels}个label")
    <<a1, a2, a3, a4, a5, _::binary>> = labels
    IO.puts("前5个labels为 #{a1} #{a2} #{a3} #{a4} #{a5}")

    IO.puts("== #{@train_image_file} ==")

    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      read_and_unzip!(@train_image_file)

    IO.puts("训练图片共有#{n_images}张, 图片数据共有#{n_rows}x#{n_cols}")

    IO.puts(
      "因此images部分binary大小应为 #{n_images}x#{n_rows}x#{n_cols} = #{n_images * n_rows * n_cols}"
    )

    IO.puts("图片binary实际大小为#{byte_size(images)}")

    IO.puts("== #{@test_image_file} ==")

    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      read_and_unzip!(@test_image_file)

    IO.puts("训练图片共有#{n_images}张, 图片数据共有#{n_rows}x#{n_cols}")

    IO.puts(
      "因此images部分binary大小应为 #{n_images}x#{n_rows}x#{n_cols} = #{n_images * n_rows * n_cols}"
    )

    IO.puts("图片binary实际大小为#{byte_size(images)}")
  end

  defp read_and_unzip!(filename) do
    filename
    |> File.read!()
    |> :zlib.gunzip()
  end
end
