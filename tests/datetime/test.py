# pyright: reportUndefinedVariable=false
machine.wait_for_x()

# Initialize test repository
machine.succeed("mkdir -p ~/test-repo")
machine.succeed("touch ~/test-repo/test")
machine.succeed("git -C ~/test-repo init")
machine.succeed("git -C ~/test-repo add test")
machine.succeed("git -C ~/test-repo commit -m 'test commit'")

# Update configuration to open test repository
machine.succeed(
    "jq --slurpfile merge ~/repoTab.json '. * $merge[0]' ~/.gitkraken/profiles/d6e5a8ca26e14325a4275fc33b17e16f/profile > ~/profile.tmp"
)
machine.succeed(
    "mv ~/profile.tmp ~/.gitkraken/profiles/d6e5a8ca26e14325a4275fc33b17e16f/profile"
)

with subtest("Custom time is displayed"):
    # GitKraken won't launch unless '--no-sandbox' is set when running as root
    # Disable splashscreen with '--show-splashscreen' ('-s') set to false
    machine.succeed("gitkraken --no-sandbox -s false >&2 &")

    # Wait for window to show up
    # WARN: for some reason, this succeeds a few seconds before the window actually
    #       shows up on screen, hence the 15 seconds sleep
    machine.wait_for_window("GitKraken Desktop")
    machine.sleep(15)

    # Hide commit details panel (wait for UI to be updated before doing OCR)
    machine.send_key("ctrl-k")
    machine.sleep(5)

    # Check that:
    # - test repository is opened
    # - custom time is displayed
    # - commit message is not displayed
    ocr = machine.get_screen_text()
    t.assertRegex(ocr, "test-repo")
    t.assertRegex(ocr, "custom time")
    t.assertNotRegex(ocr, "test commit")

    # Take a screenshot of GitKraken
    machine.screenshot("snapshot")

# Exit GitKraken
machine.succeed("pkill -f gitkraken")
