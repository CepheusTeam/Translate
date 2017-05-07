//
//  Cell.swift
//  RxSwiftSafetyManual
//
//  Created by sunny on 2017/5/7.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Cell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*
    var reuseBag = DisposeBag()
    // Called each time a cell is reused
    func configCell() {
        viewModel
            .subscribe(onNext: { [unowned self] (element) in
                self.sendOpenNewDetailsScreen()
            })
    }
    // Creating a new bag for each cell
    override func prepareForReuse() {
        reuseBag = DisposeBag()
    }
 */

}
