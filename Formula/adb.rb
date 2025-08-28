class Adb < Formula
  desc "Communicate with Android devices"
  homepage "https://developer.android.com/tools/releases/platform-tools"
  version "v35.0.2-12147458"
  license "Apache-2.0"
  # Source code is in https://android.googlesource.com/platform/packages/modules/adb

  on_macos do
    url "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
    sha256 "da9632c763fc36d0008752f5e0216cefa028a4ae3c290ebcc5ce08a3174b44cb"
  end

  on_linux do
    url "https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
    sha256 "4804403b06e40a7570f1e3e539d7e4b22a632d557a00c60f1cf3746e6d4ca23b"
  end

  def install
    bin.install "adb"
  end

  test do
    system "#{bin}/adb", "--version"
  end
end
