import argparse
import json
import os


def create_json(folder_path, start_number=1, output="./output.json"):
    """Create a JSON file from SVG files in a folder."""
    file_dict = {}
    for filename in os.listdir(folder_path):
        if filename.endswith(".svg"):
            key = os.path.splitext(filename)[0]
            value = start_number
            start_number += 1
            file_dict[key] = value

    output_file = output
    with open(output_file, "w") as f:
        json.dump(file_dict, f)


def main():
    """Create a mapping of SVG file names to numbers."""
    parser = argparse.ArgumentParser(description="Create JSON file from SVG files")
    parser.add_argument("folder_path", help="Path to folder containing SVG files")
    parser.add_argument(
        "-n", "--start_number", type=int, default=1, help="Starting value for file numbers (default: 1)"
    )
    parser.add_argument(
        "-o", "--output_loc", default="./output.json", help="Output location (default: current directory)"
    )
    args = parser.parse_args()

    create_json(args.folder_path, args.start_number, args.output_loc)


if __name__ == "__main__":
    main()
