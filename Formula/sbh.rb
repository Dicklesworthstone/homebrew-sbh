class Sbh < Formula
  desc "Disk-pressure defense system for AI coding workloads"
  homepage "https://github.com/Dicklesworthstone/storage_ballast_helper"
  license "MIT"

  depends_on :macos

  # `scripts/dsr_release.sh tap VERSION` renders this skeleton (version in the
  # URLs, both placeholder checksums) and pushes it to Dicklesworthstone/homebrew-sbh.
  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/storage_ballast_helper/releases/download/v0.6.22/" \
          "sbh-v0.6.22-aarch64-apple-darwin.tar.xz"
      sha256 "dadf86c8a9112d384cd1a6b3f901d33960a6e1003f7c17e73c1abb9110b32971"
    end

    on_intel do
      url "https://github.com/Dicklesworthstone/storage_ballast_helper/releases/download/v0.6.22/" \
          "sbh-v0.6.22-x86_64-apple-darwin.tar.xz"
      sha256 "d5c85b39073994d49b877ddb5e1bb8b145e25a9fcef903c072cbb6bea36f2e37"
    end
  end

  def install
    bin.install "sbh"
  end

  def post_install
    system bin/"sbh", "setup", "--verify", "--bin-dir", bin
  end

  service do
    run [opt_bin/"sbh", "daemon"]
    keep_alive crashed: true
    process_type :background
    throttle_interval 60
    environment_variables PATH: std_service_path_env
    log_path var/"log/sbh.log"
    error_log_path var/"log/sbh.err.log"
  end

  def caveats
    <<~EOS
      Finish interactive setup when you want shell PATH/completion changes:
        sbh setup --all --bin-dir #{HOMEBREW_PREFIX}/bin

      Start the daemon with Homebrew services:
        brew services start sbh

      On macOS, grant Full Disk Access to the installed sbh binary if scans need
      to inspect protected user locations:
        #{HOMEBREW_PREFIX}/bin/sbh doctor --pal
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sbh --version")
  end
end
