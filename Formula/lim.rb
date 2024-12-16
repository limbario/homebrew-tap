class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.7.0"
  license "Proprietary"

  depends_on "adb"
  depends_on "scrcpy"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-arm64"
      sha256 "2b0cfeb469aa36cfed192cd786d759ba2ebc962fb2fb32124fb497bae137168d" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-amd64"
      sha256 "a4d6e50570eb3b7f335b631d3daf0836239864c1827ef942b3125940009c3236" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-arm64"
      sha256 "764b00d2c2d1aaeaea514ce0f003d85b345243e88aad037bd8abf3ffa0148e8d" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-amd64"
      sha256 "fe449a6ee85f6d4d63df7b652e91c69230b953def2e27558be99f4abfc028e1d" # replace_with_linux_amd64_sha256
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
