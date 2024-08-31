import subprocess

from lib.context import Context

context = Context()


def get_short_commit_hash():

    if context.github_commit:
        return context.github_commit

    context.github_commit = subprocess.run(
        ["git", "rev-parse", "--short", "HEAD"], stdout=subprocess.PIPE, text=True
    ).stdout.strip()
    return get_short_commit_hash()
