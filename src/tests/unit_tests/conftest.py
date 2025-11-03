import os
import stat
import subprocess
from pathlib import Path

import pytest


def _find_project_root(start: Path) -> Path:
    for p in [*start.parents, start]:
        candidate = p if (p / "src" / "scripts" / "main.sh").exists() else None
        if candidate:
            return p
    try:
        top = subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip()
        if (Path(top) / "src" / "scripts" / "main.sh").exists():
            return Path(top)
    except Exception:
        pass
    raise FileNotFoundError("Не найден корень проекта с src/scripts/main.sh")


@pytest.fixture(scope="session")
def project_root() -> Path:
    return _find_project_root(Path(__file__).resolve())


@pytest.fixture(scope="session")
def main_script(project_root: Path) -> Path:
    p = project_root / "src" / "scripts" / "main.sh"
    if not p.exists():
        raise FileNotFoundError(f"main.sh not found at {p}")
    mode = p.stat().st_mode
    p.chmod(mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    lib_dir = project_root / "src" / "scripts" / "lib"
    if lib_dir.exists():
        for f in lib_dir.glob("*.sh"):
            fm = f.stat().st_mode
            f.chmod(fm | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    return p


@pytest.fixture()
def tmp_labfiles(tmp_path: Path):
    lab_root_parent = tmp_path / "data"
    lab_root = lab_root_parent / "labfiles-25"
    subj1 = lab_root / "Поп-Культуроведение" / "tests"
    subj2 = lab_root / "Цирковое_Дело" / "tests"
    subj1.mkdir(parents=True, exist_ok=True)
    subj2.mkdir(parents=True, exist_ok=True)
    (subj1 / "TEST-1").write_text(
        "Ae-21-22;IvanovII;2025-09-28;4;5\n"
        "Ae-21-22;PetrovPP;2025-09-28;3;4\n"
        "Ae-21-22;SidorovSS;2025-09-28;1;2\n",
        encoding="utf-8",
    )
    (subj1 / "TEST-2").write_text(
        "A-06-04;AlphaAA;2025-09-28;2;3\n"
        "A-06-05;BetaBB;2025-09-28;5;5\n",
        encoding="utf-8",
    )
    (subj2 / "TEST-1").write_text(
        "Ae-21-22;CircusMan;2025-09-28;20;5\n"
        "Ae-21-22;ClownGuy;2025-09-28;7;3\n",
        encoding="utf-8",
    )
    return {"LABFILES_PARENT": lab_root_parent, "LAB_ROOT": lab_root}


@pytest.fixture()
def env_with_dataroot(tmp_labfiles):
    env = os.environ.copy()
    env["DATA_ROOT"] = str(tmp_labfiles["LABFILES_PARENT"])
    return env
