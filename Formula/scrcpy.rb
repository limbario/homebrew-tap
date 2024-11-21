# This formula is temporary until this issue is resolved:
# https://github.com/Genymobile/scrcpy/issues/1733

class Scrcpy < Formula
  desc "Display and control your Android device"
  homepage "https://github.com/Genymobile/scrcpy"
  version "v2.7"
  license "Apache-2.0"

  on_macos do
    url "https://github.com/limbario/homebrew-tap/releases/download/v0.8.3/scrcpy-darwin"
    sha256 "731b5c9a744cf598952e0017893aa3917fa9204f49dcd0478313bda5249560ae"
  end

  # on_linux do
  #   if Hardware::CPU.arm?
  #     url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-arm64"
  #     sha256 "a53a3d33ed4c2e1105c89476400643b8d4d081ebfe919fa3c2d5a91a62674958" # replace_with_linux_arm64_sha256
  #   else
  #     url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-amd64"
  #     sha256 "e7f5e91385900055d296eedde9a105c5d1b67e9559d10ed806b231ac6af70e84" # replace_with_linux_amd64_sha256
  #   end
  # end

  def install
    binary_name = "scrcpy"
    binary_path = OS.mac? ? "scrcpy-darwin" : "scrcpy-linux"

    bin.install binary_path => binary_name
  end

  test do
    system "#{bin}/scrcpy", "--version"
  end
end
