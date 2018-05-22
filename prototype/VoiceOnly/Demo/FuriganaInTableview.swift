// demo the FuriganaLabel in TableView

import Foundation
import UIKit
import Promises

private let dataSet = n3

class FuriganaInTableview: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        all(dataSet.map {$0.furiganaAttributedString}).then {_ in
            self.tableView.reloadData()
        }
    }
}

extension FuriganaInTableview: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSet.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "N3SentencesCell", for: indexPath)

        guard let sentenceCell = cell as? N3SentenceCell else { return cell }
        let str = dataSet[indexPath.row]

        if let tokenInfos = kanaTokenInfosCacheDictionary[str] {
            sentenceCell.sentenceLabel.attributedText = getFuriganaString(tokenInfos: tokenInfos)
//            sentenceCell.sentenceLabel.layer.borderWidth = 1.5
//            sentenceCell.sentenceLabel.layer.cornerRadius = 15
        } else {
            sentenceCell.sentenceLabel.text = str
        }

        return sentenceCell
    }
}

class N3SentenceCell: UITableViewCell {
    @IBOutlet weak var sentenceLabel: FuriganaLabel!
}
