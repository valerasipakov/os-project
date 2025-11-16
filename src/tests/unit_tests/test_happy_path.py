import os
import subprocess


def run(main_script, env, args):
    cmd = ["bash", str(main_script)] + args
    return subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", env=env)


def test_popkult_maxes(main_script, env_with_dataroot):
    r = run(
        main_script,
        env_with_dataroot,
        ["--group=Ae-21-22", "--subject=Поп-Культуроведение", "--test=TEST-1", "--action=both"],
    )
    assert r.returncode == 0
    out = r.stdout
    assert "Студент(ы) с максимальным числом правильных (4)" in out
    assert "IvanovII" in out
    assert "Студент(ы) с максимальным числом неправильных (4)" in out
    assert "SidorovSS" in out


def test_circus_maxes(main_script, env_with_dataroot):
    r = run(
        main_script,
        env_with_dataroot,
        ["--group=Ae-21-22", "--subject=Цирковое_Дело", "--test=TEST-1", "--action=both"],
    )
    assert r.returncode == 0
    out = r.stdout
    assert "Студент(ы) с максимальным числом правильных (20)" in out
    assert "CircusMan" in out
    assert "Студент(ы) с максимальным числом неправильных (18)" in out
    assert "ClownGuy" in out


def test_popkult_maxes_with_lab_root_dataroot(main_script, tmp_labfiles):
    env = os.environ.copy()
    env["DATA_ROOT"] = str(tmp_labfiles["LAB_ROOT"])
    r = run(
        main_script,
        env,
        ["--group=Ae-21-22", "--subject=Поп-Культуроведение", "--test=TEST-1", "--action=both"],
    )
    assert r.returncode == 0
    out = r.stdout
    assert "Студент(ы) с максимальным числом правильных (4)" in out
    assert "IvanovII" in out
    assert "Студент(ы) с максимальным числом неправильных (4)" in out
    assert "SidorovSS" in out


def test_missing_group_flag_reports_error(main_script, env_with_dataroot):
    r = run(
        main_script,
        env_with_dataroot,
        ["--subject=Поп-Культуроведение", "--test=TEST-1", "--action=both"],
    )
    assert r.returncode != 0
    err = r.stderr
    assert "Необходимо указать флаг --group" in err
