#!/Users/roeeyn/.pyenv/shims/python3
import typer
from rich.prompt import Confirm
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich import print
import subprocess

app = typer.Typer(help="Personal CLI for Rodrigo")

"""
pnpm install
pnpm git-hooks
pnpm download-openapi-generator
pnpm turbo build

cp ~/src/anzen-platform/.local.env .env
cp ~/src/anzen-platform/.me.json .
pnpm ts-node scripts/create-anzen-employee.ts
"""


def pnpm_install():
    subprocess.run(["pnpm", "install"])


def install_git_hooks():
    subprocess.run(["pnpm", "git-hooks"])


def download_openapi_generator():
    subprocess.run(["pnpm", "download-openapi-generator"])


def turbo_build_api():
    subprocess.run(["pnpm", "turbo", "build:anzen-api"])


def copy_dotfiles():
    subprocess.run(
        [
            "cp",
            "/Users/roeeyn/src/anzen-platform/.local.env",
            "./packages/anzen-api/.env",
        ],
    )
    subprocess.run(
        [
            "cp",
            "/Users/roeeyn/src/anzen-platform/.me.json",
            "./packages/anzen-api/.me.json",
        ],
    )


def build_tensorflow_from_source():
    subprocess.run(
        ["npm", "rebuild", "--build-from-source", "@tensorflow/tfjs-node"],
    )


def run_migrations():
    subprocess.run(
        ["pnpm", "run-migrations"],
    )


def create_anzen_employee():
    subprocess.run(
        ["pnpm", "ts-node", "packages/anzen-api/scripts/create-anzen-employee"],
    )


# NOTE: Order here is the execution order
SCAFFOLD_STEPS = {
    "pnpm install": pnpm_install,
    "install git hooks": install_git_hooks,
    "download openapi generator": download_openapi_generator,
    "turbo build api": turbo_build_api,
    "copy dotfiles": copy_dotfiles,
    "run migrations": run_migrations,
    "build tensorflow from source": build_tensorflow_from_source,
    "create anzen employee": create_anzen_employee,
}


@app.command()
def scaffold_anzen_api():
    """Scaffold a new git worktree branch"""
    steps = list(SCAFFOLD_STEPS.keys())
    steps_to_execute = []

    print(
        "[yellow]:warning: Remember to create a new docker-compose and run migrations[/yellow]"
    )

    for step in steps:
        if Confirm.ask(f"Add '{step}'?", default=True):
            steps_to_execute.append(step)

    for step in steps_to_execute:
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            redirect_stdout=False,
            transient=True,
        ) as progress:
            progress.add_task(f"[green]Running {step}[/green]", total=None)
            try:
                SCAFFOLD_STEPS[step]()
            except Exception as e:
                print(f"[bold red]Error running[/bold red]: {step}")
                print(e)


if __name__ == "__main__":
    app()
