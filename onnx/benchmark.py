import argparse
import os
from ml import run_model


def dir_string(value):
    if os.path.isdir(value):
        return value
    else:
        raise argparse.ArgumentTypeError(f"{value} is not a valid directory")


def file_string(value):
    if os.path.isfile(value):
        return value
    else:
        raise argparse.ArgumentTypeError(f"{value} is not a valid file")


parser = argparse.ArgumentParser(description="Benchmark based on Onnx Runtime")
parser.add_argument(
    "model",
    type=file_string,
    help="Path to a model definition"
)
parser.add_argument(
    "input_dir",
    type=dir_string,
    help="Path to an input file directory"
)
parser.add_argument(
    "--iterations",
    type=int,
    default=10,
    help="Number of iterations"
)

args = parser.parse_args()
print(f"Results for model={args.input_dir}, input_dir={args.input_dir}, iterations={args.iterations}\n")
print(run_model(model=args.model, input_dir=args.input_dir, iterations=args.iterations))
