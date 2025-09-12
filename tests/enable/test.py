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

    # Check EULA popup is displayed on screen
    # This is a strong indicator that the app successfully launched in the right state
    machine.wait_for_text("agree to our EULA")

    # Take a screenshot of GitKraken
    machine.screenshot("gitkraken-enable")

with subtest("GitKraken config exists"):
    machine.succeed("stat ~/.gitkraken/config")

machine.succeed("pkill -f gitkraken")
