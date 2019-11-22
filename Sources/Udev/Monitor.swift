import Clibudev
import Glibc
import Dispatch


public enum MonitorError: Error {
  case unableToAddSubsystemMatch(subsystem: String, deviceType: String?)
  case unableToAddTagMatch(tag: String)
  case unableToEnableReceiving
  case unableToObtainFileDescriptor
}

public class Observer {
  let eventSource: DispatchSourceRead

  init(eventSource: DispatchSourceRead) {
    self.eventSource = eventSource
  }

  deinit {
    self.cancel()
  }

  public func cancel() {
    self.eventSource.cancel()
  }

  public func suspend() {
    self.eventSource.suspend()
  }

  public func resume() {
    self.eventSource.resume()
  }
}

public class Monitor {
  let udev: Udev
  let handle: OpaquePointer

  init?(udev: Udev, name: String) {
    guard let handle = udev_monitor_new_from_netlink(udev.handle, name) else {
      return nil
    }
    self.udev = udev
    self.handle = handle
  }

  deinit {
    udev_monitor_unref(handle)
  }

  @discardableResult
  public func addMatch(subsystem: String, deviceType: String? = nil) -> MonitorError? {
    let result = udev_monitor_filter_add_match_subsystem_devtype(self.handle, subsystem, deviceType)
    if result >= 0 {
      return nil
    } else {
      return .unableToAddSubsystemMatch(subsystem: subsystem, deviceType: deviceType)
    }
  }

  @discardableResult
  public func addMatch(tag: String) -> MonitorError? {
    let result = udev_monitor_filter_add_match_tag(self.handle, tag)
    if result >= 0 {
      return nil
    } else {
      return .unableToAddTagMatch(tag: tag)
    }
  }

  public func startObserving(queue: DispatchQueue? = nil, _ handler: @escaping ((Device) -> ())) -> Result<Observer, MonitorError> {
    guard udev_monitor_enable_receiving(self.handle) >= 0 else {
      return .failure(.unableToEnableReceiving)
    }

    let descriptor = udev_monitor_get_fd(self.handle)
    if descriptor < 0 {
      return .failure(.unableToObtainFileDescriptor)
    }

    let eventSource = DispatchSource.makeReadSource(fileDescriptor: descriptor, queue: queue)
    eventSource.setCancelHandler() {
      close(descriptor)
    }
    eventSource.setEventHandler() {
      guard let handle = udev_monitor_receive_device(self.handle) else {
        return
      }
      handler(Device(handle: handle))
    }

    return .success(Observer(eventSource: eventSource))
  }
}
