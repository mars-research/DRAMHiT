#!/bin/python3

import os
import shutil
import typing
import pathlib

def get_home() -> pathlib.Path:
    return pathlib.Path(os.path.dirname(os.path.realpath(__file__)))

class FatalError:
    pass

def run_synchronous(cwd: str, command: str, args: typing.List[str]):
    cmake_pid = os.fork()
    if cmake_pid == 0:
        os.chdir(cwd)
        os.execvp(command, [command] + args)
    else:
        _, state = os.wait()
        if state != 0:
            raise FatalError()

if __name__ == '__main__':
    source = get_home()
    home = source.joinpath('rundir/figures_9_10')
    if home.exists():
        shutil.rmtree(home)
    
    home.mkdir(parents=True)
    run_synchronous(home, 'cmake', [source, '-GNinja', '-DCMAKE_BUILD_TYPE==Release'])
    run_synchronous(home, 'cmake', ['--build', '.'])

    pass
