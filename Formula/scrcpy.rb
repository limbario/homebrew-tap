class Scrcpy < Formula
  desc "Display and control your Android device"
  homepage "https://github.com/Genymobile/scrcpy"
  version "3.0"
  license "Apache-2.0"

  depends_on "limbario/tap/adb"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Genymobile/scrcpy/releases/download/v3.0/scrcpy-macos-v3.0.tar.gz"
      sha256 "5db9821918537eb3aaf0333cdd05baf85babdd851972d5f1b71f86da0530b4bf"
    else
      odie "This formula is not compatible with darwin-amd64. Please use `brew install scrcpy`"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      odie "This formula is not compatible with linux-arm64. Please use `brew install scrcpy`"
    else
      url "https://github.com/Genymobile/scrcpy/releases/download/v3.0/scrcpy-linux-v3.0.tar.gz"
      sha256 "06cb74e22f758228c944cea048b78e42b2925c2affe2b5aca901cfd6a649e503"
    end
  end

  def install
    libexec.install "scrcpy_bin"

    share.install "scrcpy-server"
    share.install "icon.png"

    inreplace "scrcpy" do |s|
      # Update cd command to work with symlinked script
      s.gsub! 'cd "$(dirname ${BASH_SOURCE[0]})"', ""
      # We do not use the included adb.
      s.gsub! 'export ADB="${ADB:-./adb}"', ""
      s.gsub! 'export SCRCPY_SERVER_PATH="${SCRCPY_SERVER_PATH:-./scrcpy-server}"',
              "export SCRCPY_SERVER_PATH=\"${SCRCPY_SERVER_PATH:-#{share}/scrcpy-server}\""
      s.gsub! 'export SCRCPY_ICON_PATH="${SCRCPY_ICON_PATH:-./icon.png}"',
              "export SCRCPY_ICON_PATH=\"${SCRCPY_ICON_PATH:-#{share}/icon.png}\""
      s.gsub! './scrcpy_bin', "#{libexec}/scrcpy_bin"
    end

    bin.install "scrcpy"
  end

  test do
    system "#{bin}/scrcpy", "--version"
  end
end
