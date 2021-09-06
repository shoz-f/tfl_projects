#!/usr/bin/sh
mkdir -p priv
wget https://tfhub.dev/google/lite-model/magenta/arbitrary-image-stylization-v1-256/int8/prediction/1?lite-format=tflite -O priv/magenta_arbitrary-image-stylization-v1-256_int8_prediction_1.tflite
wget https://tfhub.dev/google/lite-model/magenta/arbitrary-image-stylization-v1-256/int8/transfer/1?lite-format=tflite -O priv/magenta_arbitrary-image-stylization-v1-256_int8_transfer_1.tflite
mkdir -p test
wget https://storage.googleapis.com/khanhlvg-public.appspot.com/arbitrary-style-transfer/belfry-2611573_1280.jpg -O test/belfry-2611573_1280.jpg
wget https://storage.googleapis.com/khanhlvg-public.appspot.com/arbitrary-style-transfer/style23.jpg -O test/style23.jpg
