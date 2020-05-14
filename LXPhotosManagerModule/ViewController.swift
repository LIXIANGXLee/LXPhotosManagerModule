//
//  ViewController.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXPhotosManager

class ViewController: UIViewController {
    //tableView
       fileprivate lazy var tableView: UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: UITableView.Style.plain)
           t.dataSource = self
           t.delegate = self
           t.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
           t.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
           t.sectionFooterHeight = 0.01
           t.sectionHeaderHeight = 0.01
           
           return t
       }()
       

    let datas = [
        "九宫格展示和图片浏览器(本地图片和网络图片)",
        "UICollectionView图片列表",
        "添加图片的view（从相机选择或者从相册选择）"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "demo展示"
        
        self.view.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
    }
    
}
// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var vc: UIViewController = LXPhotosBrowserViewController()
        if indexPath.row == 0 {
        }else if indexPath.row == 1 {
            vc = LXPhotosListViewController()
        }else if indexPath.row == 2 {
            vc = LXAddPhotoViewController()
        }        
        
        self.navigationController?.pushViewController(vc, animated: true)

    }

}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = datas[indexPath.row]
        return cell
    }
}
