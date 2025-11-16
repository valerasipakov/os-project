import subprocess


def run(main_script, env, args):
    cmd = ["bash", str(main_script)] + args
    return subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", env=env)


def test_group_not_found(main_script, env_with_dataroot):
    r = run(
        main_script,
        env_with_dataroot,
        ["--group=Ae-21-22", "--subject=Поп-Культуроведение", "--test=TEST-2", "--action=both"],
    )
    assert r.returncode != 0
    err = r.stderr
    assert "Группа не найдена: Ae-21-22" in err
    assert "A-06-05" in err


def test_missing_group_flag(main_script, env_with_dataroot):
    r = run(
        main_script,
        env_with_dataroot,
        ["--subject=Поп-Культуроведение", "--test=TEST-1", "--action=both"],
    )
    assert r.returncode != 0
    err = r.stderr
    assert "Необходимо указать флаг --group" in err


def test_unknown_test(main_script, env_with_dataroot):
    r = run(
        main_script,
        env_with_dataroot,
        ["--group=Ae-21-22", "--subject=Поп-Культуроведение", "--test=TEST-999", "--action=both"],
    )
    assert r.returncode != 0
    err = r.stderr
    assert "Тест не найден: TEST-999" in err
