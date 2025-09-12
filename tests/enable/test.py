# pyright: reportUndefinedVariable=false
machine.wait_for_x()

with subtest("GitKraken launches"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    # Disable splashscreen with '--show-splashscreen' ('-s') set to false
    machine.succeed("gitkraken --no-sandbox -s false >&2 &")

    # Wait for window to show up
    # WARN: for some reason, this succeeds a few seconds before the window actually
    #       shows up on screen, hence the 15 seconds sleep
    machine.wait_for_window("GitKraken Desktop")
    machine.sleep(15)

    # Check if welcome screen is displayed
    ocr = machine.get_screen_text()
    t.assertRegex(ocr, "Welcome to GitKraken Desktop")

    # Take a screenshot of GitKraken
    machine.screenshot("snapshot")

with subtest("Config exists"):
    machine.succeed("stat ~/.gitkraken/config")

with subtest("Default profile config exists"):
    machine.succeed(
        "stat ~/.gitkraken/profiles/d6e5a8ca26e14325a4275fc33b17e16f/profile"
    )

machine.succeed("pkill -f gitkraken")
