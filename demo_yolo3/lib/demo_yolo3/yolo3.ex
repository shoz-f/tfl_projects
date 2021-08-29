defmodule DemoYolo3.Yolo3 do
  use TflInterp, model: "priv/yolov3-416.tflite", label: "priv/coco.label", opts: "-j 2"
end
