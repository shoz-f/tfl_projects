defmodule TflDemo.DeepLab3 do
  alias TflDemo.DeepLab3.Prediction

  def apply_deeplab3(img_file) do
    img = CImg.create(img_file)

    Prediction.apply(img)
  end
end


defmodule TflDemo.DeepLab3.Prediction do
  use TflInterp, model: "priv/lite-model_deeplabv3_1_metadata_2.tflite"
  
  @deeplab3_shape {257, 257}

  def apply(img) do
    # preprocess
    bin =
      CImg.dup(img)
      |> CImg.resize(@deeplab3_shape)
      |> CImg.to_flat(range: {-1.0, 1.0})

    # prediction
    outputs =
      __MODULE__
      |> TflInterp.set_input_tensor(0, bin.data)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)
      |> Nx.from_binary({:f, 32}) |> Nx.reshape({257, 257, :auto})
      
    # postprocess
    bin =
      outputs
      |> Nx.argmax(axis: 2)
      |> Nx.as_type({:u, 8})
      |> Nx.to_binary()
    
    mask =
      CImg.create_from_u8bin(257, 257, 1, 1, bin)
      |> CImg.map("lines")
  end
end
