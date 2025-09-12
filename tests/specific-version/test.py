# pyright: reportUndefinedVariable=false
with subtest("GitKraken version matches"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    version = machine.wait_until_succeeds(
        "gitkraken --no-sandbox --version | tr -d '\n'"
    )
    t.assertEqual(version, "11.3.0")
