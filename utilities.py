import os
import typing
import pathlib


def get_home() -> pathlib.Path:
    return pathlib.Path(os.path.dirname(os.path.realpath(__file__)))


class FatalError(BaseException):
    pass


def run_synchronous(cwd: str, command: str, args: typing.List[str], log: int = os.open('log.log', os.O_RDWR | os.O_CREAT)):
    cmake_pid = os.fork()
    if cmake_pid == 0:
        if log > 2:
            os.dup2(log, 1)
        os.chdir(cwd)
        os.execvp(command, [command] + args)
    else:
        _, state = os.wait()
        if state != 0:
            raise FatalError()