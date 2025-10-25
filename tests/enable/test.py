# pyright: reportUndefinedVariable=false
machine1.wait_for_x()

with subtest("GitKraken version matches"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    version = machine1.wait_until_succeeds(
        "gitkraken --no-sandbox --version | tr -d '\n'"
    )
    t.assertEqual(version, "@version@")

with subtest("GitKraken launches"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    # Disable splashscreen with '--show-splashscreen' ('-s') set to false
    machine1.succeed("gitkraken --no-sandbox -s false >&2 &")

    # Wait for window to show up
    # WARN: for some reason, this succeeds a few seconds before the window actually
    #       shows up on screen, hence the sleep delay
    machine1.wait_for_window("GitKraken Desktop")
    machine1.sleep(15)

    # Check if welcome screen is displayed
    ocr = machine1.get_screen_text()
    t.assertRegex(ocr, "Welcome to GitKraken Desktop")

    # Take a screenshot of GitKraken
    machine1.screenshot("snapshot")

with subtest("Config exists"):
    machine1.succeed("stat ~/.gitkraken/config")

with subtest("Default profile config exists"):
    machine1.succeed(
        "stat ~/.gitkraken/profiles/d6e5a8ca26e14325a4275fc33b17e16f/profile"
    )

# Exit GitKraken
machine1.succeed("pkill -f gitkraken")
