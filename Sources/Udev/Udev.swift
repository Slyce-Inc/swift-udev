import Clibudev


public class Udev {
  let handle: OpaquePointer

  public init?() {
    guard let handle = udev_new() else {
      return nil
    }
    self.handle = handle
  }

  deinit {
    udev_unref(handle)
  }

  public func createMonitor(name: String) -> Monitor? {
    return Monitor(udev: self, name: name)
  }
}