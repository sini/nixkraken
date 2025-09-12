# pyright: reportUndefinedVariable=false
import json

machine.wait_for_x()

with subtest("Configuration is reporting accepted EULA"):
    # Parse config as JSON
    config = machine.succeed("cat ~/.gitkraken/config")
    data = json.loads(config)

    # Check EULA status is agreed and verified
    t.assertEqual(data["registration"]["EULA"]["status"], "agree_verified")

with subtest("EULA popup is not displayed"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    # Disable splashscreen with '--show-splashscreen' ('-s') set to false
    machine.succeed("gitkraken --no-sandbox -s false >&2 &")

    # Wait for window to show up
    # WARN: for some reason, this succeeds a few seconds before the window actually
    #       shows up on screen, hence the 10 seconds sleep
    machine.wait_for_window("GitKraken Desktop")
    machine.sleep(10)

    # Check EULA popup is not displayed on screen
    ocr = machine.get_screen_text()
    t.assertNotRegex(ocr, "agree to our EULA")

    # Take a screenshot of GitKraken
    machine.screenshot("gitkraken-accept-eula")

machine.succeed("pkill -f gitkraken")
