defmodule TflDemo.YoloX.Prediction do
  use TflInterp, model: "priv/yolox_s.tflite"
end

defmodule TflDemo.YoloX do
  def apply_yolox(img_file) do
    img = CImg.create(img_file)
    
    bin = CImg.dup(img) |> CImg.get_packed([640,640], 114) |> CImg.to_flatf4(true, true)

    Npy.save("input.npy", struct(Npy, bin))

    outputs = 
      TflDemo.YoloX.Prediction
      |> TflInterp.set_input_tensor(0, bin.data)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)

#    %{
#      descr: "<f4",
#      shape: {1, 8400, 85},
#      data: output
#    }
    Nx.from_binary(outputs, {:f, 32}) |> Nx.reshape({1, 8400, 85})
  end
  
  def postprocess(outputs, {hsize, wsize}) do
     prms = Enum.map([8, 16, 32], fn x -> {div(hsize, x), div(wsize, x), x} end)

     grid    = Enum.map(prms, &grid/1) |> Nx.concatenate(axis: 1)
     strides = Enum.map(prms, &strides/1) |> Nx.concatenate(axis: 1)

     {
       Nx.slice_axis(outputs, 0,  2, 2) |> Nx.add(grid) |> Nx.multiply(strides),
       Nx.slice_axis(outputs, 2,  2, 2) |> Nx.exp()     |> Nx.multiply(strides),
       Nx.slice_axis(outputs, 4,  1, 2),
       Nx.slice_axis(outputs, 5, 80, 2)
     }
  end
  
  defp grid({hsize, wsize, _}) do
    xv = Nx.iota({wsize}) |> Nx.tile([hsize, 1])
    yv = Nx.iota({hsize}) |> Nx.tile([wsize, 1]) |> Nx.transpose
    Nx.stack([xv, yv], axis: 2) |> Nx.reshape({1, :auto, 2})
  end
  
  defp strides({hsize, wsize, stride}) do
    Nx.tensor(stride) |> Nx.tile([1, hsize*wsize, 1])
  end

  def apply_yolox2(npy_file) do
    {:ok, npy} = Npy.load(npy_file)

    output = 
      TflDemo.YoloX.Prediction
      |> TflInterp.set_input_tensor(0, npy.data)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)

    %{
      descr: "<f4",
      shape: {1, 8400, 85},
      data: output
    }
  end

end
