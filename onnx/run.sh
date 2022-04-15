#!/bin/bash

mkdir results
python3 benchmark.py data/mobilenet/mobilenet.onnx data/mobilenet/input > results/mobilenet.txt
python3 benchmark.py data/googlenet/googlenet.onnx data/googlenet/input > results/googlenet.txt
python3 benchmark.py data/resnet/resnet.onnx data/resnet/input > results/resnet.txt