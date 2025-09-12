# pyright: reportUndefinedVariable=false
import json

machine.wait_for_x()

# GitKraken won't launch unless '--no-sandbox' is set when running as root
# Disable splashscreen with '--show-splashscreen' ('-s') set to false
machine.succeed("gitkraken --no-sandbox -s false >&2 &")

# Wait for window to show up
# WARN: for some reason, this succeeds a few seconds before the window actually
#       shows up on screen, hence the 15 seconds sleep
machine.wait_for_window("GitKraken Desktop")
machine.sleep(15)

# Get screen text content
ocr = machine.get_screen_text()

with subtest("EULA popup is not displayed"):
    # Check EULA popup is not displayed on screen
    t.assertNotRegex(ocr, "agree to our EULA")

with subtest("Tutorial is skipped"):
    # Check new tab is opened
    ocr = machine.get_screen_text()
    t.assertRegex(ocr, "New Tab")
    t.assertRegex(ocr, "Repositories")
    t.assertRegex(ocr, "Workspaces")

with subtest("Configuration is reporting accepted EULA"):
    # Parse config as JSON
    config = machine.succeed("cat ~/.gitkraken/config")
    data = json.loads(config)

    # Check EULA status is agreed and verified
    t.assertEqual(data["registration"]["EULA"]["status"], "agree_verified")

# Take a screenshot of GitKraken
machine.screenshot("snapshot")

# Exit GitKraken
machine.succeed("pkill -f gitkraken")
