defmodule DemoArtisticStyle.Prediction do
  use TflInterp, model: "priv/magenta_arbitrary-image-stylization-v1-256_int8_prediction_1.tflite"
end

defmodule DemoArtisticStyle.Transfer do
  use TflInterp, model: "priv/magenta_arbitrary-image-stylization-v1-256_int8_transfer_1.tflite"
end
