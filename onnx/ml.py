import glob
import time
import onnx
import onnxruntime as ort
import os

from onnx import numpy_helper


def run_model(model, input_dir, iterations):
    input_files = glob.glob(os.path.join(input_dir, "**/*.pb"), recursive=True)

    if not input_files:
        raise ValueError("No input files present")

    model_inputs = []
    for file in input_files:
        tensor = onnx.TensorProto()
        with open(file, 'rb') as f:
            tensor.ParseFromString(f.read())
        model_inputs.append(numpy_helper.to_array(tensor))

    exec_times = []
    for _ in range(iterations):
        start_time = time.perf_counter()

        for input in model_inputs:
            session = ort.InferenceSession(model)
            input_name = session.get_inputs()[0].name
            output_name = session.get_outputs()[0].name
            session.run([output_name], {input_name: input})

        exec_times.append(time.perf_counter() - start_time)

    return exec_times
