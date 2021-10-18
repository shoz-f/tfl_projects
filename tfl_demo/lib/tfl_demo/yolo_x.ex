defmodule TflDemo.YoloX.Prediction do
  use TflInterp, model: "priv/yolox_s.tflite"
end

defmodule TflDemo.YoloX do
  def apply_yolox(img_file) do
    img = CImg.create(img_file)
    
    bin = img |> CImg.get_packed([640,640], 114) |> CImg.to_flatf4(true, true)

    Npy.save("input.npy", struct(Npy, bin))

    output = 
      TflDemo.YoloX.Prediction
      |> TflInterp.set_input_tensor(0, bin.data)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)

    %{
      descr: "<f4",
      shape: {1, 8400, 85},
      data: output
    }
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
