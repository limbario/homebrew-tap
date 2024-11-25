class Adb < Formula
  desc "Communicate with Android devices"
  homepage "https://developer.android.com/tools/releases/platform-tools"
  version "v35.0.2-12147458"
  license "Apache-2.0"
  # Source code is in https://android.googlesource.com/platform/packages/modules/adb

  on_macos do
    url "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
    sha256 "1820078db90bf21628d257ff052528af1c61bb48f754b3555648f5652fa35d78"
  end

  on_linux do
    url "https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
    sha256 "acfdcccb123a8718c46c46c059b2f621140194e5ec1ac9d81715be3d6ab6cd0a"
  end

  def install
    bin.install "adb"
  end

  test do
    system "#{bin}/adb", "--version"
  end
end
