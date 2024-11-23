class Scrcpy < Formula
  desc "Display and control your Android device"
  homepage "https://github.com/Genymobile/scrcpy"
  version "v0.8.4"
  license "Apache-2.0"

  depends_on "limbario/tap/adb"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/scrcpy-darwin-arm64"
      sha256 "a9b5637bb20999bb580347ff12f3762a1f05b669505241ac4f179abd5078c15d" # replace_with_darwin_arm64_sha256
    else
      odie "This formula is not compatible with darwin-amd64. Please use `brew install scrcpy`"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      odie "This formula is not compatible with linux-arm64. Please use `brew install scrcpy`"
    else
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/scrcpy-linux-amd64"
      sha256 "0f21cb13dc7cfc7423ad706e39fcd10e8baba0eed249bc2f59c3605e0b1b3e18" # replace_with_linux_amd64_sha256
    end
  end

  def install
    binary_name = "scrcpy"
    binary_path = "scrcpy"

    if OS.mac?
      binary_path = Hardware::CPU.arm? ? "scrcpy-darwin-arm64" : "scrcpy-darwin-amd64"
    elsif OS.linux?
      binary_path = Hardware::CPU.arm? ? "scrcpy-linux-arm64" : "scrcpy-linux-amd64"
    end

    bin.install binary_path => binary_name
  end

  test do
    system "#{bin}/scrcpy", "--version"
  end
end
