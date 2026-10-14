class Sbh < Formula
  desc "Disk-pressure defense system for AI coding workloads"
  homepage "https://github.com/Dicklesworthstone/storage_ballast_helper"
  license "MIT"

  depends_on :macos

  # `scripts/dsr_release.sh tap VERSION` renders this skeleton (version in the
  # URLs, both placeholder checksums) and pushes it to Dicklesworthstone/homebrew-sbh.
  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/storage_ballast_helper/releases/download/v0.7.3/" \
          "sbh-v0.7.3-aarch64-apple-darwin.tar.xz"
      sha256 "2e19613bcd477cb2899e5df7f74c7c75f2048c014bb5909512ae5dc7fc8d6fc2"
    end

    on_intel do
      url "https://github.com/Dicklesworthstone/storage_ballast_helper/releases/download/v0.7.3/" \
          "sbh-v0.7.3-x86_64-apple-darwin.tar.xz"
      sha256 "f6c9ef5996de5ef3839d0305ae5b1b8d02a6bd4183a6abb3a8295bb2a0a76f57"
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
