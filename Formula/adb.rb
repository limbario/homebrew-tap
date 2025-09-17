class Adb < Formula
  desc "Communicate with Android devices"
  homepage "https://developer.android.com/tools/releases/platform-tools"
  version "v35.0.2-12147458"
  license "Apache-2.0"
  # Source code is in https://android.googlesource.com/platform/packages/modules/adb

  on_macos do
    url "https://dl.google.com/android/repository/platform-tools_r36.0.0-darwin.zip"
    sha256 "d3e9fa1df3345cf728586908426615a60863d2632f73f1ce14f0f1349ef000fd"
  end

  on_linux do
    url "https://dl.google.com/android/repository/platform-tools_r36.0.0-linux.zip"
    sha256 "0ead642c943ffe79701fccca8f5f1c69c4ce4f43df2eefee553f6ccb27cbfbe8"
  end

  def install
    bin.install "adb"
  end

  test do
    system "#{bin}/adb", "--version"
  end
end
