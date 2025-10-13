# pyright: reportUndefinedVariable=false
import re

machine1.wait_for_x()

with subtest("GitKraken profile name is customized"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    # Disable splashscreen with '--show-splashscreen' ('-s') set to false
    machine1.succeed("gitkraken --no-sandbox -s false >&2 &")

    # Wait for window to show up
    # WARN: for some reason, this succeeds a few seconds before the window actually
    #       shows up on screen, hence the 15 seconds sleep
    machine1.wait_for_window("GitKraken Desktop")
    machine1.sleep(15)

    # Check if profile name is customized
    # NOTE: we have to loosely test this since OCR is not very precise with case detection
    ocr = machine1.get_screen_text()
    t.assertRegex(ocr, re.compile(r"NixKraken rocks", re.I))

    # Take a screenshot of GitKraken
    machine1.screenshot("snapshot")

# Exit GitKraken
machine1.succeed("pkill -f gitkraken")
