#Get the PWD environment variable
import std/os
import std/strutils

## If the path contains a value of an environment variable, replace it with the given value
proc substitute_path_env(path: string, env_var: string, replaced_with: string): string =
    let env_path = getEnv(env_var)
    if env_path == "" or not path.startswith(env_path):
        return path
    return replaced_with & path[len(env_path) .. ^1]

func shorten_path(path: string, max_length: int): string =
    if path.len <= max_length:
        return path
    let parts = split(path, "/")
    if parts.len <= 3:
        return path
    # keep the first part and the last two parts
    return join([parts[0], "…", parts[^2], parts[^1]], "/")

proc prompt_path(): string =
    let pwd = getEnv("PWD")
    if pwd == "":
        return r"\w"

    let subsititutions = [
        ("HOME", "~"),
        ("WORKDIR", "$WORKDIR"),
        ("WORKDIR2", "$WORKDIR2")
    ]
    var pwd_substituted = pwd
    for (env_var, substitute) in subsititutions:
        pwd_substituted = substitute_path_env(pwd_substituted, env_var, substitute)

    return shorten_path(pwd_substituted, 12)

echo prompt_path()