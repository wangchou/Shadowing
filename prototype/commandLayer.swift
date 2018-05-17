import Foundation

func download(_ something: String, _ seconds: UInt32 = 1, completionHandler: @escaping () -> Void = {}) {
  print("Downloading \(something)")
  DispatchQueue.global().async {
    sleep(seconds)
    print("\(something) is downloaded")
    completionHandler()
  }
}

let cmdGroup = DispatchGroup()
let cmdQueue = DispatchQueue(label: "for Sync/Blocking version of async functions")
var downloadState = "%"

func dispatch(_ cmd: Command) {
    cmdGroup.enter()
    cmd.exec()
    cmdGroup.wait()
}

enum CommandType {
    case download
}

protocol Command {
    var type: CommandType { get }
    func exec()
}

struct DownloadCommand: Command {
    let type = CommandType.download
    var text: String
    func exec() {
      download(self.text) {
        downloadState = self.text
        cmdGroup.leave()
      }
    }
}

func downloadAB() {
  cmdQueue.async {
    print("just downloaded \(downloadState)")
    dispatch(DownloadCommand(text: "A"))
    print("just downloaded \(downloadState)")
    dispatch(DownloadCommand(text: "B"))
  }
}

func downloadCD() {
  cmdQueue.async {
    print("just downloaded \(downloadState)")
    dispatch(DownloadCommand(text: "C"))
    print("just downloaded \(downloadState)")
    dispatch(DownloadCommand(text: "D"))
  }
}

func runCommands() {
  cmdQueue.async {
    for _ in 1...2 {
      downloadAB()
    }
    downloadCD()
  }
}

print("main thread: dispatch runCommands started")
runCommands()
print("main thread: dispatch runCommands ended")
let group = DispatchGroup()
group.enter()
download("------------------", 7) { group.leave() }
group.wait()
