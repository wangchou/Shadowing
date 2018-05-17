// demo the FuriganaLabel in TableView

import Foundation
import UIKit
import Promises

private let dataSet = n4

class PlaygroundView: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        all(dataSet.map {$0.furiganaAttributedString}).then {_ in
            self.tableView.reloadData()
        }
    }
}

extension PlaygroundView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSet.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "N3SentencesCell", for: indexPath) as! N3SentenceCell
        let str = dataSet[indexPath.row]

        if let tokenInfos = kanaTokenInfosCacheDictionary[str] {
            cell.sentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
        } else {
            cell.sentenceLabel.text = str
        }

        return cell
    }
}

class N3SentenceCell: UITableViewCell {
    @IBOutlet weak var sentenceLabel: FuriganaLabel!
}
