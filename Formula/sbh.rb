class Sbh < Formula
  desc "Disk-pressure defense system for AI coding workloads"
  homepage "https://github.com/Dicklesworthstone/storage_ballast_helper"
  license "MIT"

  depends_on :macos

  # `scripts/dsr_release.sh tap VERSION` renders this skeleton (version in the
  # URLs, both placeholder checksums) and pushes it to Dicklesworthstone/homebrew-sbh.
  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/storage_ballast_helper/releases/download/v0.6.16/" \
          "sbh-v0.6.16-aarch64-apple-darwin.tar.xz"
      sha256 "c696fe2b646e61520e264b88e1fdea43d12c5230e4346406a4f1610fc88ecf2a"
    end

    on_intel do
      url "https://github.com/Dicklesworthstone/storage_ballast_helper/releases/download/v0.6.16/" \
          "sbh-v0.6.16-x86_64-apple-darwin.tar.xz"
      sha256 "0ede25cb3e2f1488dbc2de5cc4282e87f50dd2790ed7397b7d26acbdb2aec884"
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
