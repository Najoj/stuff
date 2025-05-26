"""
Folds together two files
"""
import os.path
import sys
import argparse

def parse_arguments() -> (str, str, str):
    parser = argparse.ArgumentParser()
    parser.add_argument('left', type=str,
                        help='Dominant file, to be merged into')
    parser.add_argument('right', type=str,
                        help='Flie to merge lines from')
    parser.add_argument('--output', type=str, default=None, required=False)
    argv = sys.argv[1:]
    parsed = parser.parse_args(argv)

    _left = parsed.left
    _right = parsed.right
    _output = parsed.output

    if _left == _right:
        print('Warning: The two inputs are the same file.', file=sys.stderr)
    if not os.path.exists(_left) and not os.path.isfile(_left):
        raise FileNotFoundError(f'{_left} is does not exist or is not a file')
    if not os.path.exists(_right) and not os.path.isfile(_right):
        raise FileNotFoundError(f'{_right} is does not exist or is not a file')
    if _output is not None and os.path.isfile(_right):
        print(f'Warning: Outputfile {_output} already exist.')

    return _left, _right, _output

def main(_left_file, _right_file, _output_file) -> int:
    with open(_left_file, 'r+') as f:
        _left_file_content = f.readlines()
    with open(_right_file, 'r+') as f:
        _right_file_content = f.readlines()

    _output_file_content = []

    _left_file_length = len(_left_file_content)
    _right_file_length = len(_right_file_content)
    _output_file_length = _left_file_length + _right_file_length
    if _output_file_length < 1:
        return 0

    _left_quota = _left_file_length / _output_file_length
    _right_quota = _right_file_length / _output_file_length

    left_line = 0
    right_line = 0

    for n in range(_output_file_length):
        n += 1
        if _left_quota > left_line / n:
            _output_file_content.append(_left_file_content[left_line])
            left_line += 1
        elif _right_quota > right_line / n:
            _output_file_content.append(_right_file_content[right_line])
            right_line += 1
        else:
            print('oh-no')

    if output_file is None:
        sys.stdout.writelines(_output_file_content)
    else:
        with open(output_file, 'w+') as f:
            f.writelines(_output_file_content)
    return 0

if __name__ == '__main__':
    left_file, right_file, output_file = parse_arguments()
    return_code = main(left_file, right_file, output_file)
    sys.exit(return_code)