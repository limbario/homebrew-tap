class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.9.1"
  license "Proprietary"

  depends_on "limbario/tap/adb"

  def caveats
    <<~EOS
      Get started with:
        lim run android
    EOS
  end

  on_macos do
    if Hardware::CPU.arm?
      depends_on "limbario/tap/scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-arm64"
      sha256 "b0974e93bd6d137bc60cc34db0211d84eec54c38a96a9928176736a9bc467648" # replace_with_darwin_arm64_sha256
    else
      # scrcpy does not yet publish static builds for darwin-amd64
      depends_on "scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-amd64"
      sha256 "6d932b8b2efd313b821f3cbca3689b4b3f1ae510b0c5c6ac28a21655e3d58a58" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      # scrcpy does not yet publish static builds for linux-arm64
      depends_on "scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-arm64"
      sha256 "8a9bdc757ef3cacfaa1f946e7eeae791558664faa885d5d8dd6d373ea8d069d2" # replace_with_linux_arm64_sha256
    else
      depends_on "limbario/tap/scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-amd64"
      sha256 "c74ee7be69150cf388ac821c60c0157e6f6f28697906ee82aabb062dd602d80b" # replace_with_linux_amd64_sha256
    end
  end

  def install
    binary_name = "lim"
    binary_path = "lim"

    if OS.mac?
      binary_path = Hardware::CPU.arm? ? "lim-darwin-arm64" : "lim-darwin-amd64"
    elsif OS.linux?
      binary_path = Hardware::CPU.arm? ? "lim-linux-arm64" : "lim-linux-amd64"
    end

    bin.install binary_path => binary_name
  end

  test do
    system "#{bin}/lim", "--version"
  end
end
