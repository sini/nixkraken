# pyright: reportUndefinedVariable=false
machine.wait_for_x()

with subtest("GitKraken launches"):
  # GitKraken won't launch unless '--no-sandbox' is set when running as root
  # Disable splashscreen with '--show-splashscreen' ('-s') set to false
  machine.succeed("gitkraken --no-sandbox -s false >&2 &")

  # Wait for window to show up
  # WARN: for some reason, this succeeds a few seconds before the window actually
  #       shows up on screen, hence the 10 seconds sleep
  machine.wait_for_window("GitKraken Desktop")
  machine.sleep(10)

  # Take a screenshot of GitKraken
  machine.screenshot("gitkraken")

with subtest("GitKraken config exists"):
  machine.succeed("stat ~/.gitkraken/config")

machine.succeed("pkill -f gitkraken")
