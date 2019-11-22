import Clibudev


public class Device {
  let handle: OpaquePointer

  init(handle: OpaquePointer) {
    self.handle = handle
  }

  deinit {
    udev_device_unref(self.handle)
  }

  public var action: String? {
    guard let result = udev_device_get_action(self.handle) else {
      return nil
    }
    return String(cString: result)
  }

  public var systemName: String? {
    guard let result = udev_device_get_sysname(self.handle) else {
      return nil
    }
    return String(cString: result)
  }

  public var devicePath: String? {
    guard let result = udev_device_get_devpath(self.handle) else {
      return nil
    }
    return String(cString: result)
  }

  public var deviceNode: String? {
    guard let result = udev_device_get_devnode(self.handle) else {
      return nil
    }
    return String(cString: result)
  }

  public func value(forProperty name: String) -> String? {
    guard let result = udev_device_get_property_value(self.handle, name) else {
      return nil
    }
    return String(cString: result)
  }

  public struct PropertyGenerator: Sequence, IteratorProtocol {
    var list: OpaquePointer?

    public mutating func next() -> (String, String)? {
      guard let list = self.list else {
        return nil
      }
      guard let name = udev_list_entry_get_name(list), let value = udev_list_entry_get_value(list) else {
        return nil
      }
      self.list = udev_list_entry_get_next(list)
      return (String(cString: name), String(cString: value))
    }
  }

  public var properties: PropertyGenerator {
    let list = udev_device_get_properties_list_entry(self.handle)
    return PropertyGenerator(list: list)
  }
}