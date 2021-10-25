defmodule TflDemo.YoloX.Prediction do
  use TflInterp, model: "priv/yolox_s.tflite"
end

defmodule TflDemo.YoloX do
  @moduledoc false

  def apply_yolox(img_file) do
    img = CImg.create(img_file)

    bin = CImg.dup(img)
      |> CImg.get_packed([640,640], 114)
      |> CImg.to_flatf4(true, true)

    outputs =
      TflDemo.YoloX.Prediction
      |> TflInterp.set_input_tensor(0, bin.data)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)
      |> Nx.from_binary({:f, 32})
      |> Nx.reshape({8400, 85})

    {boxes, scores} = reshape(outputs, {640, 640})
  end

  def reshape(outputs, {hsize, wsize}) do
     # resolution map
     reso = Enum.map([8, 16, 32], fn x -> {Kernel.div(hsize, x), Kernel.div(wsize, x), x} end)

     grid    = Enum.map(reso, &grid/1)    |> Nx.concatenate(axis: 0)
     strides = Enum.map(reso, &strides/1) |> Nx.concatenate(axis: 0)

     box_center = Nx.slice_axis(outputs, 0, 2, 1) |> Nx.add(grid)
     box_wing   = Nx.slice_axis(outputs, 2, 2, 1) |> Nx.exp() |> Nx.divide(2)

     {
       # boxes
       [Nx.subtract(box_center, box_wing), Nx.add(box_center, box_wing)] |> Nx.concatenate(axis: 1) |> Nx.multiply(strides),
       # scores
       Nx.multiply(Nx.slice_axis(outputs, 4, 1, 1), Nx.slice_axis(outputs, 5, 80, 1))
     }
  end

  defp grid({hsize, wsize, _}) do
    xv = Nx.iota({wsize}) |> Nx.tile([hsize, 1])
    yv = Nx.iota({hsize}) |> Nx.tile([wsize, 1]) |> Nx.transpose
    Nx.stack([xv, yv], axis: 2) |> Nx.reshape({:auto, 2})
  end
  
  defp strides({hsize, wsize, stride}) do
    Nx.tensor(stride) |> Nx.tile([hsize*wsize, 1])
  end
end
