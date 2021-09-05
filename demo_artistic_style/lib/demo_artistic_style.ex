defmodule DemoArtisticStyle do

  alias DemoArtisticStyle, as: Demo

  def hello do
    style =
      CImg.create("test/style23.jpg")
      |> CImg.resize([256,256])
      |> CImg.to_flatnorm()
      
    content =
      CImg.create("test/belfry-2611573_1280.jpg")
      |> CImg.resize([384,384])
      |> CImg.to_flatnorm()

    bottleneck =
      Demo.Prediction
      |> TflInterp.set_input_tensor(0, style.data)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)
    
    artistic =
      Demo.Transfer
      |> TflInterp.set_input_tensor(0, content.data)
      |> TflInterp.set_input_tensor(1, bottleneck)
      |> TflInterp.invoke()
      |> TflInterp.get_output_tensor(0)
      |> (&CImg.create_from_f4bin(384, 384, 1, 3, &1)).()
  end
end
